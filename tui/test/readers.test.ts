import { describe, expect, it } from "bun:test";
import { mkdir, mkdtemp, writeFile, symlink } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { readDashboardData } from "../src/sources/readers.ts";
import {
  buildDashboardViewModel,
  DEFAULT_DASHBOARD_VIEW_STATE,
  reduceDashboardViewState
} from "../src/viewModels/dashboard.ts";

async function makeProjectFixture(baseDir: string, projectName: string): Promise<string> {
  const projectRoot = path.join(baseDir, projectName);
  await mkdir(path.join(projectRoot, "shipglows_data/workflow/specs"), { recursive: true });
  await writeFile(path.join(projectRoot, "AGENT.md"), `---\nproject: ${projectName}\n---\n`, "utf8");
  return projectRoot;
}

describe("readDashboardData", () => {
  it("reads local project corpora and specs from discovered projects", async () => {
    const appRoot = await mkdtemp(path.join(tmpdir(), "sg-tui-app-"));
    const projectRoot = await makeProjectFixture(appRoot, "shipglows_app");
    const shipglowsRepo = path.join(appRoot, "shipglows");

    await writeFile(
      path.join(projectRoot, "shipglows_data/workflow/TASKS.md"),
      [
        "🔴 [shipglows_app] task: Review local task reader | status: todo | area: shipglows_app",
        ""
      ].join("\n"),
      "utf8"
    );
    await writeFile(
      path.join(projectRoot, "shipglows_data/workflow/AUDIT_LOG.md"),
      [
        "🟢 [shipglows_app] audit: Local audit scope | date: 2026-05-21 | overall: B | issues: 0/0/0 | scope: reader",
        ""
      ].join("\n"),
      "utf8"
    );
    await writeFile(
      path.join(projectRoot, "shipglows_data/workflow/project_lifecycle.md"),
      [
        "- Lifecycle phase: `operate`",
        "",
        "## Lifecycle Items",
        "",
        "| Item ID | Instance ID | Type | Domain | Title | Required | State | Due At | Cadence | Timezone | Evidence | Tracker Route | Next Action |",
        "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |",
        "| security-review | shipglows_app:security-review:2026-07-28 | recurring | cybersecurity | Security review | yes | not_started | 2026-07-28T10:00:00+00:00 | weekly | UTC | - | technical_task | Review posture |"
      ].join("\n"),
      "utf8"
    );
    await writeFile(
      path.join(projectRoot, "shipglows_data/workflow/specs/demo.md"),
      [
        "status: ready",
        "project: shipglows_app",
        "user_story: \"check local discovery\"",
        "next_step: \"run tui\"",
        "",
        "# Title",
        "",
        "Local Discovery Spec",
        "",
        "# Skill Run History",
        "",
        "| Date UTC | Skill | Model | Action | Result | Next step |",
        "|----------|-------|-------|--------|--------|-----------|",
        "| 2026-05-17 00:00:00 UTC | sg-ready | GPT-5 | checked | ready | /sg-start |",
        "",
        "# Current Chantier Flow",
        "",
        "| Phase | Status | Evidence | Next step |",
        "|-------|--------|----------|-----------|",
        "| sg-start | done | implemented | /sg-verify |"
      ].join("\n"),
      "utf8"
    );

    await mkdir(path.join(shipglowsRepo, "skills/sg-spec"), { recursive: true });

    const data = await readDashboardData({
      projectRoot,
      workspaceRoots: [appRoot],
      shipglowsRepoRoot: shipglowsRepo
    });

    expect(data.projects.map((project) => project.name)).toContain("shipglows_app");
    expect(data.projects.length).toBe(1);
    expect(data.specs).toHaveLength(1);
    expect(data.specs[0]?.title).toBe("Local Discovery Spec");
    expect(data.specs[0]?.path).toContain("shipglows_data/workflow/specs/demo.md");
    expect(data.tasks.lines[0]).toContain("Review local task reader");
    expect(data.lifecycle?.lines.some((line) => line.includes("security-review"))).toBe(true);
    expect(data.checklistInstances?.lines).toEqual(["No checklist instances."]);
    expect(data.audits.lines[0]).toContain("reader");
    expect(data.skills.lines).toContain("sg-spec");
    expect(data.diagnostics).toHaveLength(0);
  });

  it("projects checklist instance progression separately from tasks", async () => {
    const appRoot = await mkdtemp(path.join(tmpdir(), "sg-tui-app-"));
    const projectRoot = await makeProjectFixture(appRoot, "shipglows_app");
    await mkdir(path.join(projectRoot, "shipglows_data/workflow/checklist-instances"), { recursive: true });
    await writeFile(
      path.join(projectRoot, "shipglows_data/workflow/checklist-instances/seo.md"),
      [
        "---",
        "project_id: shipglows_app",
        "checklist_id: seo-technical",
        "cycle_id: shipglows_app:seo-technical:2026-07-28",
        "---",
        "",
        "## Controls",
        "",
        "| Control ID | Phase | Control | Required | Status | Evidence | Notes |",
        "| --- | --- | --- | --- | --- | --- | --- |",
        "| technical-scope | Périmètre | Scope | yes | verified | evidence/scope.md | |",
        "| technical-crawl | Crawl | Robots | yes | in_progress | - | |"
      ].join("\n"),
      "utf8"
    );
    await writeFile(
      path.join(projectRoot, "shipglows_data/workflow/checklist-instances/cybersecurity.md"),
      [
        "---",
        "project_id: shipglows_app",
        "checklist_id: cybersecurity-readiness",
        "cycle_id: shipglows_app:cybersecurity-readiness:2026-07-28",
        "---",
        "",
        "## Controls",
        "",
        "| Control ID | Phase | Control | Required | Status | Evidence | Notes |",
        "| --- | --- | --- | --- | --- | --- | --- |",
        "| access-review | Accès | Review access | yes | verified | evidence/access.md | |"
      ].join("\n"),
      "utf8"
    );
    const data = await readDashboardData({ projectRoot, workspaceRoots: [appRoot], shipglowsRepoRoot: appRoot });
    expect(data.checklistInstances?.lines[0]).toContain("checklist seo-technical");
    expect(data.checklistInstances?.lines[0]).toContain("progress 1/2");
    expect(data.checklistInstances?.lines.some((line) => line.includes("checklist cybersecurity-readiness"))).toBe(true);
    expect(data.tasks.lines.some((line) => line.includes("technical-crawl"))).toBe(false);
  });

  it("summarizes task and audit table entries from local project tables", async () => {
    const appRoot = await mkdtemp(path.join(tmpdir(), "sg-tui-app-"));
    const projectRoot = await makeProjectFixture(appRoot, "shipglows_app");

    await writeFile(
      path.join(projectRoot, "shipglows_data/workflow/TASKS.md"),
      [
        "# Tasks",
        "",
        "## Current Active Backlog",
        "",
        "| Pri | Task | Status |",
        "| --- | --- | --- |",
        "| 🔴 | Fix activity parsing | 📋 todo |",
        "| ✅ | Old completed task | ✅ done |",
        "",
        "## onboarding",
        "",
        "| Pri | Task | Status |",
        "| --- | --- | --- |",
        "| 🟠 | Align project prefixes | 📋 todo |",
        "",
        "# Legacy Tasks",
        "",
        "| Pri | Task | Status |",
        "| --- | --- | --- |",
        "| 🔴 | Legacy task should stay hidden | 📋 todo |"
      ].join("\n"),
      "utf8"
    );

    await writeFile(
      path.join(projectRoot, "shipglows_data/workflow/AUDIT_LOG.md"),
      [
        "# Audit Log",
        "",
        "| Date | Scope | Overall | Issues |",
        "| ---- | ----- | ------- | ------ |",
        "| 2026-05-19 | old audit | C | 1/1/1 |",
        "| 2026-05-20 | recent audit | B | 0/1/2 |",
        ""
      ].join("\n"),
      "utf8"
    );

    const data = await readDashboardData({
      projectRoot,
      workspaceRoots: [appRoot],
      shipglowsRepoRoot: appRoot
    });

    expect(data.tasks.lines[0]).toContain("🔴 [shipglows_app] Fix activity parsing");
    expect(data.tasks.lines[0]?.startsWith("🔴")).toBe(true);
    expect(data.tasks.lines.every((line) => /^[🔴🟠🟡🟢]/u.test(line))).toBe(true);
    expect(data.tasks.lines).not.toContain("Legacy task should stay hidden");
    expect(data.audits.lines[0]).toContain("2026-05-20");
    expect(data.audits.lines[0]?.startsWith("🟢")).toBe(true);
  });

  it("prefers canonical task/audit lines and removes canonical/legacy duplicates", async () => {
    const appRoot = await mkdtemp(path.join(tmpdir(), "sg-tui-app-"));
    const projectRoot = await makeProjectFixture(appRoot, "shipglows_app");

    await writeFile(
      path.join(projectRoot, "shipglows_data/workflow/TASKS.md"),
      [
        "🔴 [shipglows_app] task: Replace canonical parser in TUI | status: todo | area: shipglows_app",
        "",
        "# Tasks",
        "",
        "## shipglows_app",
        "",
        "| Pri | Task | Status |",
        "| --- | --- | --- |",
        "| 🟢 | Replace canonical parser in TUI | ✅ done |",
        ""
      ].join("\n"),
      "utf8"
    );
    await writeFile(
      path.join(projectRoot, "shipglows_data/workflow/AUDIT_LOG.md"),
      [
        "🟠 [shipglows_app] audit: Dependency scan | date: 2026-05-21 | scope: parser | overall: C | issues: 1/0/0",
        "",
        "# Audit Log",
        "",
        "| Date | Scope | Overall | Issues |",
        "| ---- | ----- | ------- | ------ |",
        "| 2026-05-21 | parser | C | 1/0/0 |",
        "| 2026-05-20 | old scope | B | 0/1/2 |"
      ].join("\n"),
      "utf8"
    );

    const data = await readDashboardData({
      projectRoot,
      workspaceRoots: [appRoot],
      shipglowsRepoRoot: appRoot
    });

    expect(data.tasks.lines[0]).toContain("🔴 [shipglows_app] Replace canonical parser in TUI — todo");
    expect(data.audits.lines.some((line) => line.includes("🟠 [shipglows_app] 2026-05-21 — parser — C — 1/0/0"))).toBe(true);
    expect(data.audits.lines.some((line) => line.includes("| 2026-05-21 | parser | C | 1/0/0 |"))).toBe(false);
  });

  it("reads canonical spec summary fields and keeps canonical precedence", async () => {
    const appRoot = await mkdtemp(path.join(tmpdir(), "sg-tui-app-"));
    const projectRoot = await makeProjectFixture(appRoot, "shipglows_app");

    await writeFile(
      path.join(projectRoot, "shipglows_data/workflow/specs/spec-canonical.md"),
      [
        "status: draft",
        "project: shipglows_app",
        "user_story: \"read canonical first\"",
        "next_step: \"legacy step\"",
        "",
        "# Spec: Canonical Spec",
        "",
        "🟢 [shipglows_app] spec: Canonical Spec | status: ready | path: shipglows_data/workflow/specs/spec-canonical.md | next: /sg-ready Canonical Spec",
        "",
        "# Current Chantier Flow",
        "",
        "| Phase | Status | Evidence | Next step |",
        "|-------|--------|----------|-----------|",
        "| sg-ready | done | canonical parser | /sg-ready |"
      ].join("\n"),
      "utf8"
    );

    const data = await readDashboardData({
      projectRoot,
      workspaceRoots: [appRoot],
      shipglowsRepoRoot: appRoot
    });

    expect(data.specs).toHaveLength(1);
    expect(data.specs[0]?.title).toBe("Canonical Spec");
    expect(data.specs[0]?.status).toBe("ready");
    expect(data.specs[0]?.nextStep).toBe("/sg-ready Canonical Spec");
    expect(data.specs[0]?.path).toBe("shipglows_data/workflow/specs/spec-canonical.md");
    expect(data.specs[0]?.project).toBe("shipglows_app");
  });

  it("preserves filtering on canonical task/audit/spec project prefixes across discovered projects", async () => {
    const appRoot = await mkdtemp(path.join(tmpdir(), "sg-tui-app-"));
    const primaryRoot = await makeProjectFixture(appRoot, "shipglows_app");
    const betaRoot = await makeProjectFixture(appRoot, "beta");

    await writeFile(
      path.join(primaryRoot, "shipglows_data/workflow/TASKS.md"),
      "🔴 [shipglows_app] task: shipglows task | status: todo | area: alpha\n",
      "utf8"
    );
    await writeFile(
      path.join(betaRoot, "shipglows_data/workflow/TASKS.md"),
      "🟢 [beta] task: beta task | status: todo | area: beta\n",
      "utf8"
    );

    await writeFile(
      path.join(primaryRoot, "shipglows_data/workflow/AUDIT_LOG.md"),
      "🟠 [shipglows_app] audit: shipglows scope | date: 2026-05-21 | overall: C | issues: 1/0/0 | scope: shipglows\n",
      "utf8"
    );
    await writeFile(
      path.join(betaRoot, "shipglows_data/workflow/AUDIT_LOG.md"),
      "🟢 [beta] audit: beta scope | date: 2026-05-21 | overall: B | issues: 0/0/0 | scope: beta\n",
      "utf8"
    );

    await writeFile(
      path.join(primaryRoot, "shipglows_data/workflow/specs/shipglows.md"),
      [
        "status: ready",
        "project: shipglows_app",
        "# Title",
        "ShipGlows Spec"
      ].join("\n"),
      "utf8"
    );
    await writeFile(
      path.join(betaRoot, "shipglows_data/workflow/specs/beta.md"),
      [
        "status: draft",
        "project: beta",
        "# Title",
        "Beta Spec"
      ].join("\n"),
      "utf8"
    );

    const data = await readDashboardData({
      projectRoot: primaryRoot,
      workspaceRoots: [appRoot],
      shipglowsRepoRoot: appRoot
    });

    const filteredState = "shipglows_app".split("").reduce(
      (state, letter) => reduceDashboardViewState(data, state, { name: letter, sequence: letter }),
      DEFAULT_DASHBOARD_VIEW_STATE
    );
    const activityState = reduceDashboardViewState(data, filteredState, { name: "tab", sequence: "\t" });
    const auditsState = reduceDashboardViewState(data, activityState, { name: "tab", sequence: "\t" });
    const vm = buildDashboardViewModel(data, auditsState);

    expect(vm.activityLines.join("\n")).toContain("[shipglows_app] shipglows task");
    expect(vm.activityLines.join("\n")).not.toContain("beta task");
    expect(vm.auditsLines.join("\n")).toContain("[shipglows_app]");
    expect(vm.auditsLines.join("\n")).not.toContain("beta");
    expect(vm.specLines.join("\n")).toContain("ShipGlows Spec");
    expect(vm.specLines.join("\n")).not.toContain("Beta Spec");
  });

  it("discovers multiple projects and ignores symlinked non-directories", async () => {
    const appRoot = await mkdtemp(path.join(tmpdir(), "sg-tui-app-"));
    const realProject = await makeProjectFixture(appRoot, "shipglows_app");
    const realSibling = await makeProjectFixture(appRoot, "beta");

    await writeFile(path.join(realProject, "shipglows_data/workflow/TASKS.md"), "🔴 [shipglows_app] task: base\n", "utf8");
    await writeFile(path.join(realSibling, "shipglows_data/workflow/TASKS.md"), "🟢 [beta] task: beta\n", "utf8");

    const symlinkTarget = path.join(appRoot, "symlinked");
    await symlink(realProject, symlinkTarget);

    const data = await readDashboardData({
      projectRoot: realProject,
      workspaceRoots: [appRoot],
      shipglowsRepoRoot: appRoot
    });

    expect(data.projects.map((project) => project.name).sort()).toEqual(["beta", "shipglows_app"]);
    expect(data.tasks.lines.some((line) => line.includes("symlink"))).toBe(false);
  });

  it("skips oversized discovery directories and records diagnostics", async () => {
    const appRoot = await mkdtemp(path.join(tmpdir(), "sg-tui-app-"));
    const projectRoot = await makeProjectFixture(appRoot, "shipglows_app");
    const noisyDir = path.join(appRoot, "noisy");
    await mkdir(noisyDir, { recursive: true });
    await Promise.all([
      writeFile(path.join(noisyDir, "a.md"), "", "utf8"),
      writeFile(path.join(noisyDir, "b.md"), "", "utf8"),
      writeFile(path.join(noisyDir, "c.md"), "", "utf8")
    ]);

    const data = await readDashboardData({
      projectRoot,
      workspaceRoots: [appRoot],
      shipglowsRepoRoot: appRoot,
      projectDiscoveryDirectoryEntriesLimit: 2
    });

    expect(data.projects.some((project) => project.name === "shipglows_app")).toBe(true);
    expect(data.diagnostics.some((diagnostic) => diagnostic.code === "PROJECT_DISCOVERY_DIR_TOO_LARGE")).toBe(true);
  });
});
