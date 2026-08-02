import { describe, expect, it } from "bun:test";
import { readFile } from "node:fs/promises";
import path from "node:path";
import { projectLifecycleRows, summarizeLifecycle } from "../src/sources/lifecycle.ts";
import type { Diagnostic } from "../src/types/models.ts";

const fixturePath = path.resolve(import.meta.dir, "../../tools/fixtures/project-lifecycle/sample.md");
const now = new Date("2026-07-28T08:00:00Z");

describe("lifecycle source parity", () => {
  it("projects the canonical fixture fields used by the Python reader", async () => {
    const markdown = await readFile(fixturePath, "utf8");
    const rows = projectLifecycleRows(markdown, now);
    const byId = new Map(rows.map((row) => [row.itemId, row]));

    expect([...byId.keys()]).toEqual([
      "seo-launch-gate",
      "security-review",
      "copy-review",
      "performance-fix"
    ]);
    expect(byId.get("seo-launch-gate")).toMatchObject({
      state: "verified",
      dueAt: "2026-07-20T10:00:00.000Z",
      evidence: true,
      historyClosed: false
    });
    expect(byId.get("security-review")).toMatchObject({
      state: "verified",
      dueAt: "2026-07-27T09:00:00.000Z",
      evidence: true,
      historyClosed: true,
      nextInstanceId: "security-review:2026-08-03",
      nextDueAt: "2026-08-03T09:00:00.000Z"
    });
    expect(byId.get("copy-review")).toMatchObject({ state: "not_started", evidence: false });
    expect(byId.get("performance-fix")).toMatchObject({ state: "overdue", evidence: false });
  });

  it("renders the same projected state and keeps missing evidence visible", async () => {
    const markdown = await readFile(fixturePath, "utf8");
    const missingEvidence = markdown.replace("reports/seo-launch.md", "-");
    const diagnostics: Diagnostic[] = [];
    const summary = summarizeLifecycle(missingEvidence, "Example Site", diagnostics, now);

    expect(diagnostics).toHaveLength(0);
    expect(summary.lines).toContain("🟡 [seo] seo-launch-gate — waiting_for_evidence");
    expect(summary.lines.some((line) => line.includes("[cybersecurity] security-review") && line.includes("next occurrence"))).toBe(true);
    expect(summary.lines.some((line) => line.includes("[performance] performance-fix — overdue"))).toBe(true);
  });
});
