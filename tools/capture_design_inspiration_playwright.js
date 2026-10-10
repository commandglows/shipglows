#!/usr/bin/env node
"use strict";

const fs = require("node:fs");
const path = require("node:path");
const { createRequire } = require("node:module");

function write(payload, exitCode = 0) {
  process.stdout.write(JSON.stringify(payload));
  process.exitCode = exitCode;
}

async function readInput() {
  let input = "";
  for await (const chunk of process.stdin) input += chunk;
  return JSON.parse(input);
}

function removeMotionFiles(directory, keep = null) {
  if (!directory || !fs.existsSync(directory)) return;
  for (const name of fs.readdirSync(directory)) {
    const candidate = path.join(directory, name);
    if (candidate !== keep && path.extname(candidate).toLowerCase() === ".webm") {
      try { fs.unlinkSync(candidate); } catch (_unlinkError) { /* best-effort temporary cleanup */ }
    }
  }
}

function accessIsForbidden(finalUrl, title, visibleText, statusCode) {
  const pathTokens = new Set(new URL(finalUrl).pathname.toLowerCase().split(/[^a-z0-9]+/).filter(Boolean));
  const markers = `${title}\n${visibleText}`.toLowerCase();
  const authTokens = ["login", "signin", "sign-in", "auth", "oauth", "sso"];
  const authMarkers = ["sign in", "log in", "authentication required", "enter your password"];
  const blockMarkers = ["access denied", "forbidden", "too many requests", "captcha", "verify you are human"];
  return statusCode === 401 || statusCode === 403 || statusCode === 429 ||
    authTokens.some(token => pathTokens.has(token)) ||
    authMarkers.some(marker => markers.includes(marker)) ||
    blockMarkers.some(marker => markers.includes(marker));
}

async function main() {
  const [, , packageJson, pngPath, widthValue, heightValue, motionPath] = process.argv;
  let playwright;
  try {
    playwright = createRequire(packageJson)("playwright");
  } catch (_playwrightError) {
    try {
      playwright = createRequire(packageJson)("@playwright/test");
    } catch (_testPackageError) {
      write({ ok: false, code: "playwright_package_unavailable" }, 2);
      return;
    }
  }

  const input = await readInput();
  const { url } = input;
  const motionMode = input.mode === "motion";
  const motionDirectory = motionMode && motionPath ? path.dirname(motionPath) : null;
  let browser;
  let context;
  let motionSucceeded = false;
  try {
    try {
      browser = await playwright.chromium.launch({ headless: true });
    } catch (_error) {
      write({ ok: false, code: "playwright_browser_unavailable" }, 2);
      return;
    }

    const contextOptions = {
      viewport: { width: Number(widthValue), height: Number(heightValue) },
      deviceScaleFactor: 1,
      acceptDownloads: false,
      serviceWorkers: "block",
    };
    if (motionMode) {
      if (!motionPath || !input.motion) {
        write({ ok: false, code: "motion_video_finalize_failed" }, 2);
        return;
      }
      contextOptions.recordVideo = {
        dir: motionDirectory,
        size: { width: Number(input.motion.videoWidth), height: Number(input.motion.videoHeight) },
      };
    }
    context = await browser.newContext(contextOptions);
    if (motionMode && input.noNetwork) {
      await context.route("**/*", route => route.abort());
    }
    const page = await context.newPage();
    page.on("dialog", dialog => dialog.dismiss());
    let response = null;
    try {
      if (motionMode && input.noNetwork) {
        if (typeof input.fixtureHtml !== "string") throw new Error("fixture missing");
        await page.setContent(input.fixtureHtml, {
          waitUntil: "domcontentloaded",
          timeout: Number(input.motion.navigationTimeoutMs),
        });
      } else {
        response = await page.goto(url, {
          waitUntil: "domcontentloaded",
          timeout: motionMode ? Number(input.motion.navigationTimeoutMs) : 45_000,
        });
      }
    } catch (error) {
      const timeout = error && error.name === "TimeoutError";
      write({ ok: false, code: timeout ? "network_timeout" : "browser_error" }, 2);
      return;
    }

    if (motionMode) {
      const startedAt = Date.now();
      const title = await page.title();
      const visibleText = (await page.locator("body").innerText({ timeout: 5_000 })).slice(0, 5000);
      if (accessIsForbidden(page.url(), title, visibleText, response ? response.status() : null)) {
        await context.close();
        context = null;
        removeMotionFiles(motionDirectory);
        write({ ok: false, code: "motion_access_forbidden" }, 2);
        return;
      }

      const maxSteps = Math.min(6, Math.max(0, Number(input.motion.maxScrollSteps)));
      const distanceLimit = Math.min(3600, Math.max(0, Number(input.motion.maxScrollDistancePx)));
      let scrollSteps = 0;
      let maxScrollDistancePx = 0;
      await page.waitForTimeout(350);
      while (scrollSteps < maxSteps && maxScrollDistancePx < distanceLimit) {
        const next = await page.evaluate(limit => {
          const maximum = Math.max(0, document.documentElement.scrollHeight - window.innerHeight);
          const target = Math.min(maximum, window.scrollY + Math.min(600, limit - window.scrollY));
          window.scrollTo(0, target);
          return { position: Math.round(window.scrollY), maximum: Math.round(maximum) };
        }, distanceLimit);
        scrollSteps += 1;
        maxScrollDistancePx = Math.max(maxScrollDistancePx, Math.min(distanceLimit, next.position));
        await page.waitForTimeout(150);
        if (next.position >= next.maximum || next.position >= distanceLimit) break;
      }
      await page.evaluate(() => window.scrollTo(0, 0));
      await page.waitForTimeout(350);
      const durationMs = Date.now() - startedAt;
      const video = page.video();
      await context.close();
      context = null;
      if (durationMs <= 0 || durationMs > Number(input.motion.durationLimitMs) || !video) {
        removeMotionFiles(motionDirectory);
        write({ ok: false, code: durationMs > Number(input.motion.durationLimitMs) ? "motion_duration_exceeded" : "motion_video_finalize_failed" }, 2);
        return;
      }
      let source;
      try {
        source = await video.path();
        if (!source || !fs.existsSync(source) || fs.statSync(source).size <= 0) throw new Error("empty video");
        if (source !== motionPath) fs.copyFileSync(source, motionPath);
        if (!fs.existsSync(motionPath) || fs.statSync(motionPath).size <= 0) throw new Error("copy failed");
        removeMotionFiles(motionDirectory, motionPath);
      } catch (_error) {
        removeMotionFiles(motionDirectory);
        write({ ok: false, code: "motion_video_finalize_failed" }, 2);
        return;
      }
      motionSucceeded = true;
      write({
        ok: true,
        motionStatus: "captured",
        durationMs,
        scrollSteps,
        maxScrollDistancePx,
      });
      return;
    }

    await page.waitForTimeout(500);
    for (let index = 0; index < 30; index += 1) {
      const reachedBottom = await page.evaluate(() => {
        window.scrollBy(0, Math.max(600, window.innerHeight * 0.8));
        return window.scrollY + window.innerHeight >= document.documentElement.scrollHeight - 4;
      });
      await page.waitForTimeout(100);
      if (reachedBottom) break;
    }
    await page.evaluate(() => window.scrollTo(0, 0));

    const extracted = await page.locator("body").evaluate(body => {
      const selectors = "h1,h2,h3,h4,h5,h6,p,li,button,label,a,nav,input,textarea,select";
      const boilerplate = /(?:^|[-_ ])(?:cookie|consent|gdpr|cmp-banner|privacy-banner)(?:$|[-_ ])/i;
      const entries = [...body.querySelectorAll(selectors)].filter(el => {
        const style = window.getComputedStyle(el);
        const rect = el.getBoundingClientRect();
        const identity = `${el.id || ""} ${el.className || ""}`;
        return style.display !== "none" && style.visibility !== "hidden" &&
          el.getAttribute("aria-hidden") !== "true" && rect.width > 0 && rect.height > 0 &&
          !boilerplate.test(identity);
      }).map((el, order) => ({
        order,
        tag: el.tagName.toLowerCase(),
        text: (el.innerText || el.getAttribute("aria-label") || el.getAttribute("placeholder") || el.getAttribute("name") || "").replace(/\s+/g, " ").trim(),
        href: el.tagName.toLowerCase() === "a" ? el.getAttribute("href") : null,
      })).filter(item => item.text);
      const unsupported = [...new Set([...body.querySelectorAll("video,canvas,[role=carousel],.carousel,.slider")]
        .map(el => el.tagName.toLowerCase() + (el.getAttribute("role") ? `:${el.getAttribute("role")}` : "")))];
      return { entries, unsupported };
    });
    const title = await page.title();
    const visibleText = (await page.locator("body").innerText({ timeout: 5_000 })).slice(0, 5000);
    let screenshotFailed = false;
    try {
      await page.screenshot({ path: pngPath, fullPage: true, animations: "disabled", timeout: 45_000 });
    } catch (_error) {
      screenshotFailed = true;
      try { fs.unlinkSync(pngPath); } catch (_unlinkError) { /* no temporary PNG to remove */ }
    }
    write({
      ok: true,
      finalUrl: page.url(),
      statusCode: response ? response.status() : null,
      title,
      visibleText,
      entries: extracted.entries,
      unsupported: extracted.unsupported,
      screenshotFailed,
    });
  } catch (_error) {
    write({ ok: false, code: motionMode ? "motion_video_finalize_failed" : "browser_error" }, 2);
  } finally {
    if (context) await context.close().catch(() => {});
    if (browser) await browser.close().catch(() => {});
    if (motionMode && !motionSucceeded) removeMotionFiles(motionDirectory);
  }
}

main().catch(() => write({ ok: false, code: "browser_error" }, 2));
