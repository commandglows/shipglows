#!/usr/bin/env node
"use strict";

const fs = require("node:fs");
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

async function main() {
  const [, , packageJson, pngPath, widthValue, heightValue] = process.argv;
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

  const { url } = await readInput();
  let browser;
  let context;
  try {
    try {
      browser = await playwright.chromium.launch({ headless: true });
    } catch (_error) {
      write({ ok: false, code: "playwright_browser_unavailable" }, 2);
      return;
    }
    context = await browser.newContext({
      viewport: { width: Number(widthValue), height: Number(heightValue) },
      deviceScaleFactor: 1,
      acceptDownloads: false,
      serviceWorkers: "block",
    });
    const page = await context.newPage();
    page.on("dialog", dialog => dialog.dismiss());
    let response;
    try {
      response = await page.goto(url, { waitUntil: "domcontentloaded", timeout: 45_000 });
    } catch (error) {
      const timeout = error && error.name === "TimeoutError";
      write({ ok: false, code: timeout ? "network_timeout" : "browser_error" }, 2);
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
    write({ ok: false, code: "browser_error" }, 2);
  } finally {
    if (context) await context.close().catch(() => {});
    if (browser) await browser.close().catch(() => {});
  }
}

main().catch(() => write({ ok: false, code: "browser_error" }, 2));
