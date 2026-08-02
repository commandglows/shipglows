import { describe, expect, it } from "bun:test";
import {
  buildDashboardViewModel,
  DEFAULT_DASHBOARD_VIEW_STATE,
  reduceDashboardViewState
} from "../src/viewModels/dashboard.ts";
import { renderDashboardText } from "../src/views/dashboardView.ts";
import type { DashboardData, DashboardViewState } from "../src/types/models.ts";

function pressDown(data: DashboardData, state: DashboardViewState, count: number): DashboardViewState {
  return Array.from({ length: count }).reduce<DashboardViewState>(
    (currentState) => reduceDashboardViewState(data, currentState, { name: "arrowdown" }),
    state
  );
}

describe("buildDashboardViewModel", () => {
  const dashboardData: DashboardData = {
    projects: [
      { name: "alpha", path: "/tmp/alpha", stack: "Astro", source: "s" },
      { name: "beta", path: "/tmp/beta", stack: "Flutter", source: "s" },
      { name: "gamma", path: "/tmp/gamma", stack: "Next", source: "s" },
      { name: "delta", path: "/tmp/delta", stack: "Svelte", source: "s" }
    ],
    specs: [
      {
        path: "x",
        project: "alpha",
        title: "Spec X",
        status: "ready",
        userStory: "story",
        nextStep: "next",
        runHistorySummary: ["sf-ready: ready"],
        chantierFlowSummary: ["sf-start=done"]
      },
      {
        path: "y",
        project: "beta",
        title: "Filtered Spec",
        status: "draft",
        userStory: "other",
        nextStep: "later",
        runHistorySummary: [],
        chantierFlowSummary: []
      }
    ],
    tasks: { label: "Tasks", lines: ["[alpha] task a", "[beta] task b"] },
    checklistInstances: { label: "Checklist instances", lines: ["[alpha] checklist seo-technical · progress 1/2"] },
    audits: { label: "Audits", lines: ["2026-05-20 — alpha / audit a — B", "2026-05-21 — beta / audit b — C"] },
    operations: { label: "Operations", lines: ["c"] },
    dependencies: { label: "Dependencies", lines: ["d"] },
    skills: { label: "Skills", lines: ["e"] },
    diagnostics: []
  };

  it("maps dashboard data to lines", () => {
    const vm = buildDashboardViewModel(dashboardData);

    expect(vm.projectLines[0]).toContain("alpha");
    expect(vm.projectLines[0]).toContain("beta");
    expect(vm.projectLines[0]).toContain("gamma");
    expect(vm.projectLines).toContain("");
    expect(vm.projectLines[2]).toContain("delta");
    expect(vm.projectLines[0]).not.toContain("/tmp/alpha");
    expect(vm.projectLines[0]).not.toContain("Astro");
    expect(vm.detailLines).not.toContain("Path: /tmp/alpha");
    expect(vm.detailLines).not.toContain("Stack: Astro");
    expect(vm.specLines[0]).toContain("Filtered Spec");
    expect(vm.specLines[0]?.startsWith("🟠")).toBe(true);
    expect(vm.specLines[2]).toContain("Spec X");
    expect(vm.specLines[2]?.startsWith("🟢")).toBe(true);
    expect(vm.activityLines.join("\n")).toContain("Tasks:");
    expect(vm.activityLines.join("\n")).not.toContain("Audits:");
    expect(vm.auditsLines.join("\n")).toContain("Audits:");
    expect(vm.detailLines).toContain("Run history:");
    expect(vm.detailLines).toContain("  none");
    expect(vm.detailLines).toContain("Current chantier flow:");
    expect(vm.detailLines).toContain("  none");
    expect(vm.diagnosticsLines[0]).toContain("No diagnostics");
  });

  it("does not render the shortcut footer bar", () => {
    const text = renderDashboardText(buildDashboardViewModel(dashboardData));

    expect(text).not.toContain("Tab panel");
    expect(text).not.toContain("Up/Down navigate");
    expect(text).toContain("* Projects");
  });

  it("adds a left margin and hanging continuation indent to wrapped lines", () => {
    const previousColumns = process.stdout.columns;
    Object.defineProperty(process.stdout, "columns", { value: 54, configurable: true });
    try {
      const data: DashboardData = {
        ...dashboardData,
        specs: [
          {
            ...dashboardData.specs[0]!,
            title: "Very Long ShipGlows Terminal Specification Name That Must Wrap Cleanly"
          }
        ]
      };
      const specsState = reduceDashboardViewState(data, DEFAULT_DASHBOARD_VIEW_STATE, { name: "tab" });
      const text = renderDashboardText(buildDashboardViewModel(data, specsState));
      const lines = text.split("\n");
      const specLineIndex = lines.findIndex((line) => line.includes("Very Long ShipGlows"));

      expect(lines[0]?.startsWith("    ShipGlows TUI")).toBe(true);
      expect(lines.some((line) => line.startsWith("    * Specs"))).toBe(true);
      expect(specLineIndex).toBeGreaterThan(0);
      expect(lines[specLineIndex]?.startsWith("    🟢 > [alpha] [ready] Very Long")).toBe(true);
      expect(lines[specLineIndex + 1]?.startsWith("                         ")).toBe(true);
      expect(lines[specLineIndex + 1]).toContain("Specification");
    } finally {
      Object.defineProperty(process.stdout, "columns", { value: previousColumns, configurable: true });
    }
  });

  it("renders a compact multi-section phone layout", () => {
    const projectsText = renderDashboardText(buildDashboardViewModel(dashboardData));
    expect(projectsText).toContain("* Projects");
    expect(projectsText).toContain("    Specs");
    expect(projectsText).not.toContain("Recent");
    expect(projectsText).not.toContain("Tasks:");
    expect(projectsText).not.toContain("Audits:");

    const specsState = reduceDashboardViewState(dashboardData, DEFAULT_DASHBOARD_VIEW_STATE, { name: "tab" });
    const specsText = renderDashboardText(buildDashboardViewModel(dashboardData, specsState));
    expect(specsText).toContain("    Projects");
    expect(specsText).toContain("* Specs");
    expect(specsText).toContain("Spec X");

    const activityState = reduceDashboardViewState(dashboardData, specsState, { name: "tab" });
    const activityText = renderDashboardText(buildDashboardViewModel(dashboardData, activityState));
    expect(activityText).toContain("    Projects");
    expect(activityText).toContain("* Tasks");
    expect(activityText).not.toContain("Recent");
    expect(activityText).not.toContain("Tasks:");
    expect(activityText).not.toContain("Audits:");
    expect(activityText).not.toContain("Specs");

    const auditsState = reduceDashboardViewState(dashboardData, activityState, { name: "tab" });
    const auditsText = renderDashboardText(buildDashboardViewModel(dashboardData, auditsState));
    expect(auditsText).toContain("    Projects");
    expect(auditsText).toContain("* Audits");
    expect(auditsText).not.toContain("Audits:");
    expect(auditsText).not.toContain("Tasks:");
    expect(auditsText).not.toContain("Specs");
  });

  it("keeps projects visible and filters activity pages by project filter", () => {
    const specsState = reduceDashboardViewState(dashboardData, DEFAULT_DASHBOARD_VIEW_STATE, { name: "tab" });
    const activityState = reduceDashboardViewState(dashboardData, specsState, { name: "tab" });
    const betaActivityState = "beta".split("").reduce(
      (state, letter) => reduceDashboardViewState(dashboardData, state, { name: letter, sequence: letter }),
      activityState
    );
    const activityVm = buildDashboardViewModel(dashboardData, betaActivityState);

    expect(activityVm.projectFilter).toBe("beta");
    expect(activityVm.projectLines.join("\n")).toContain("beta");
    expect(activityVm.activityLines.join("\n")).toContain("[beta] task b");
    expect(activityVm.activityLines.join("\n")).not.toContain("[alpha] task a");

    const auditsState = reduceDashboardViewState(dashboardData, betaActivityState, { name: "tab" });
    const auditsVm = buildDashboardViewModel(dashboardData, auditsState);

    expect(auditsVm.auditsLines.join("\n")).toContain("beta / audit b");
    expect(auditsVm.auditsLines.join("\n")).not.toContain("alpha / audit a");
  });

  it("navigates tasks and audits with the same arrow behavior as specs", () => {
    const specsState = reduceDashboardViewState(dashboardData, DEFAULT_DASHBOARD_VIEW_STATE, { name: "tab" });
    const activityState = reduceDashboardViewState(dashboardData, specsState, { name: "tab" });
    const movedTaskState = reduceDashboardViewState(dashboardData, activityState, { name: "arrowdown" });
    const taskVm = buildDashboardViewModel(dashboardData, movedTaskState);

    expect(movedTaskState.selectedProjectIndex).toBe(0);
    expect(movedTaskState.selectedTaskIndex).toBe(1);
    expect(taskVm.activityLines.join("\n")).toContain("> [beta] task b");
    expect(taskVm.activityLines.join("\n")).toContain("  [alpha] task a");

    const auditsState = reduceDashboardViewState(dashboardData, movedTaskState, { name: "tab" });
    const movedAuditState = reduceDashboardViewState(dashboardData, auditsState, { name: "arrowdown" });
    const auditVm = buildDashboardViewModel(dashboardData, movedAuditState);

    expect(movedAuditState.selectedProjectIndex).toBe(0);
    expect(movedAuditState.selectedAuditIndex).toBe(1);
    expect(auditVm.auditsLines.join("\n")).toContain("> 2026-05-21");
    expect(auditVm.auditsLines.join("\n")).toContain("  2026-05-20");
  });

  it("scrolls visible windows when the selection moves past the displayed rows", () => {
    const manyData: DashboardData = {
      ...dashboardData,
      projects: Array.from({ length: 14 }, (_, index) => ({
        name: `project-${String(index + 1).padStart(2, "0")}`,
        path: `/tmp/project-${String(index + 1).padStart(2, "0")}`,
        source: "s"
      })),
      specs: Array.from({ length: 10 }, (_, index) => ({
        path: `spec-${index + 1}.md`,
        project: "project-01",
        title: `Spec ${String(index + 1).padStart(2, "0")}`,
        status: "ready",
        userStory: "story",
        nextStep: "next",
        runHistorySummary: [],
        chantierFlowSummary: []
      })),
      tasks: {
        label: "Tasks",
        lines: Array.from({ length: 12 }, (_, index) => `task ${String(index + 1).padStart(2, "0")}`)
      },
      audits: {
        label: "Audits",
        lines: Array.from({ length: 14 }, (_, index) => `audit ${String(index + 1).padStart(2, "0")}`)
      }
    };

    const projectState = pressDown(manyData, DEFAULT_DASHBOARD_VIEW_STATE, 12);
    const projectsVm = buildDashboardViewModel(manyData, projectState);
    expect(projectsVm.projectLines.join("\n")).toContain("> project-13");
    expect(projectsVm.projectLines.join("\n")).not.toContain("project-01");

    const specsState = { ...DEFAULT_DASHBOARD_VIEW_STATE, activePanel: "specs" as const };
    const specScrolledState = pressDown(manyData, specsState, 8);
    const specsVm = buildDashboardViewModel(manyData, specScrolledState);
    expect(specsVm.specLines.join("\n")).toContain("> [project-01] [ready] Spec 09");
    expect(specsVm.specLines.join("\n")).not.toContain("Spec 01");

    const activityState = { ...DEFAULT_DASHBOARD_VIEW_STATE, activePanel: "activity" as const };
    const taskScrolledState = pressDown(manyData, activityState, 10);
    const taskVm = buildDashboardViewModel(manyData, taskScrolledState);
    expect(taskVm.activityLines.join("\n")).toContain("> task 11");
    expect(taskVm.activityLines.join("\n")).not.toContain("task 01");

    const auditsState = { ...DEFAULT_DASHBOARD_VIEW_STATE, activePanel: "audits" as const };
    const auditScrolledState = pressDown(manyData, auditsState, 12);
    const auditVm = buildDashboardViewModel(manyData, auditScrolledState);
    expect(auditVm.auditsLines.join("\n")).toContain("> audit 13");
    expect(auditVm.auditsLines.join("\n")).not.toContain("audit 01");
  });

  it("scopes specs to the matching project when the project filter is active", () => {
    const betaState = "beta".split("").reduce(
      (state, letter) => reduceDashboardViewState(dashboardData, state, { name: letter, sequence: letter }),
      DEFAULT_DASHBOARD_VIEW_STATE
    );
    const vm = buildDashboardViewModel(dashboardData, betaState);

    expect(vm.projectLines.join("\n")).toContain("beta");
    expect(vm.specLines.join("\n")).toContain("Filtered Spec");
    expect(vm.specLines.join("\n")).not.toContain("Spec X");
  });

  it("uses the typed project filter as spec scope even when no project row matches", () => {
    const alphaAppState = "alpha_app".split("").reduce(
      (state, letter) => reduceDashboardViewState(dashboardData, state, { name: letter, sequence: letter }),
      DEFAULT_DASHBOARD_VIEW_STATE
    );
    const data = {
      ...dashboardData,
      specs: [
        { ...dashboardData.specs[0]!, project: "alpha_app" },
        { ...dashboardData.specs[1]!, project: "beta" }
      ]
    };
    const vm = buildDashboardViewModel(data, alphaAppState);

    expect(vm.projectLines.join("\n")).toContain("No projects match");
    expect(vm.specLines.join("\n")).toContain("Spec X");
    expect(vm.specLines.join("\n")).not.toContain("Filtered Spec");
  });

  it("does not match unrelated specs through generic path segments", () => {
    const data: DashboardData = {
      ...dashboardData,
      projects: [
        { name: "gocharbon", path: "/home/claude/gocharbon", stack: "Astro", source: "s" },
        { name: "gocharbon_quiz", path: "/home/claude/gocharbon_quiz", stack: "Expo", source: "s" }
      ],
      specs: [
        {
          ...dashboardData.specs[0]!,
          path: "/home/claude/shipglowz_app/app/shipglows_data/workflow/specs/shipglows-terminal-tui-v1.md",
          project: "shipglows_app",
          title: "ShipGlows Terminal TUI V1"
        },
        {
          ...dashboardData.specs[1]!,
          path: "/home/claude/shipglowz_app/app/shipglows_data/workflow/specs/gocharbon-quiz.md",
          project: "gocharbon_quiz",
          title: "GoCharbon Quiz Spec"
        }
      ]
    };
    const filteredState = "gocharb".split("").reduce(
      (state, letter) => reduceDashboardViewState(data, state, { name: letter, sequence: letter }),
      { ...DEFAULT_DASHBOARD_VIEW_STATE, selectedProjectIndex: 1 }
    );
    const vm = buildDashboardViewModel(data, filteredState);

    expect(vm.projectLines.join("\n")).toContain("gocharbon_quiz");
    expect(vm.specLines.join("\n")).toContain("GoCharbon Quiz Spec");
    expect(vm.specLines.join("\n")).not.toContain("ShipGlows Terminal TUI V1");
  });

  it("filters and navigates selected dashboard lists", () => {
    const filteredState = reduceDashboardViewState(dashboardData, DEFAULT_DASHBOARD_VIEW_STATE, {
      name: "f",
      sequence: ""
    });
    expect(filteredState.projectFilter).toBe("f");

    const specsState = reduceDashboardViewState(dashboardData, filteredState, { sequence: "\t", raw: "\t" });
    expect(specsState.activePanel).toBe("specs");

    const typed = "Filtered".split("").reduce(
      (state, letter) => reduceDashboardViewState(dashboardData, state, { name: letter.toLowerCase(), sequence: letter }),
      specsState
    );
    const vm = buildDashboardViewModel(dashboardData, typed);
    expect(vm.specLines[0]).toContain("Filtered Spec");
    expect(vm.detailLines).toContain("Title: Filtered Spec");
  });

  it("supports keyboard aliases seen in terminals", () => {
    const specsState = reduceDashboardViewState(dashboardData, DEFAULT_DASHBOARD_VIEW_STATE, { name: "tab" });
    const moved = reduceDashboardViewState(dashboardData, specsState, { name: "arrowdown" });
    const filtered = reduceDashboardViewState(dashboardData, moved, { name: "backspace", raw: "\x7f" });

    expect(moved.selectedSpecIndex).toBe(1);
    expect(filtered.activePanel).toBe("specs");
  });

  it("keeps diagnostics behind a dedicated !!! chord instead of the Tab cycle", () => {
    const specsState = reduceDashboardViewState(dashboardData, DEFAULT_DASHBOARD_VIEW_STATE, { name: "tab" });
    const activityState = reduceDashboardViewState(dashboardData, specsState, { name: "tab" });
    const auditsState = reduceDashboardViewState(dashboardData, activityState, { name: "tab" });
    const projectsState = reduceDashboardViewState(dashboardData, auditsState, { name: "tab" });
    const firstBang = reduceDashboardViewState(dashboardData, projectsState, { name: "!", sequence: "!" });
    const secondBang = reduceDashboardViewState(dashboardData, firstBang, { name: "!", sequence: "!" });
    const diagnosticsState = reduceDashboardViewState(dashboardData, secondBang, { name: "!", sequence: "!" });
    const afterDiagnosticsTab = reduceDashboardViewState(dashboardData, diagnosticsState, { name: "tab" });

    expect(activityState.activePanel).toBe("activity");
    expect(auditsState.activePanel).toBe("audits");
    expect(projectsState.activePanel).toBe("projects");
    expect(firstBang.activePanel).toBe("projects");
    expect(firstBang.projectFilter).toBe("");
    expect(secondBang.activePanel).toBe("projects");
    expect(secondBang.projectFilter).toBe("");
    expect(diagnosticsState.activePanel).toBe("diagnostics");
    expect(diagnosticsState.projectFilter).toBe("");
    expect(afterDiagnosticsTab.activePanel).toBe("specs");
  });

  it("keeps d as filter text", () => {
    const stateWithD = reduceDashboardViewState(dashboardData, DEFAULT_DASHBOARD_VIEW_STATE, { name: "d", sequence: "d" });

    expect(stateWithD.activePanel).toBe("projects");
    expect(stateWithD.projectFilter).toBe("d");
  });

  it("keeps j and k as filter text instead of navigation shortcuts", () => {
    const stateWithJ = reduceDashboardViewState(dashboardData, DEFAULT_DASHBOARD_VIEW_STATE, { name: "j" });
    const stateWithK = reduceDashboardViewState(dashboardData, stateWithJ, { name: "k" });

    expect(stateWithJ.projectFilter).toBe("j");
    expect(stateWithJ.selectedProjectIndex).toBe(0);
    expect(stateWithK.projectFilter).toBe("jk");
    expect(stateWithK.selectedProjectIndex).toBe(0);
  });
});
