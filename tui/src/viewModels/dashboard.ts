import type {
  DashboardData,
  DashboardKeyInput,
  DashboardPanel,
  DashboardViewModel,
  DashboardViewState,
  ProjectItem,
  SpecItem,
  TextSummary
} from "../types/models.ts";
import { trafficFromSpecStatus, trafficFromAudit, trafficPriority } from "../statusMaps.ts";

export const DEFAULT_DASHBOARD_VIEW_STATE: DashboardViewState = {
  activePanel: "projects",
  diagnosticChord: "",
  projectFilter: "",
  specFilter: "",
  selectedProjectIndex: 0,
  selectedSpecIndex: 0,
  selectedTaskIndex: 0,
  selectedAuditIndex: 0
};

const TAB_PANEL_ORDER: DashboardPanel[] = ["projects", "specs", "activity", "audits"];
const PROJECT_GRID_COLUMNS = 3;
const PROJECT_GRID_COLUMN_WIDTH = 16;
const PROJECT_VISIBLE_COUNT = 12;
const SPEC_VISIBLE_COUNT = 8;
const TASK_VISIBLE_COUNT = 10;
const AUDIT_VISIBLE_COUNT = 12;

function clampIndex(index: number, length: number): number {
  if (length <= 0) {
    return 0;
  }
  return Math.min(Math.max(index, 0), length - 1);
}

function normalizeComparable(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, "");
}

function matchesFilter(value: string, filter: string): boolean {
  const rawFilter = filter.trim().toLowerCase();
  if (!rawFilter) {
    return true;
  }
  return value.toLowerCase().includes(rawFilter) ||
    normalizeComparable(value).includes(normalizeComparable(rawFilter));
}

function filteredProjects(data: DashboardData, filter: string): ProjectItem[] {
  return data.projects.filter((project) => matchesFilter(`${project.name} ${project.path ?? ""} ${project.stack ?? ""}`, filter));
}

function normalizedParts(value: string | undefined): string[] {
  if (!value) {
    return [];
  }
  return value
    .toLowerCase()
    .split(/[^a-z0-9._-]+/)
    .map((part) => part.trim())
    .filter(Boolean);
}

function projectAliases(project: ProjectItem): string[] {
  const pathBaseName = project.path?.split("/").filter(Boolean).at(-1);
  const aliases = [
    ...normalizedParts(project.name),
    ...normalizedParts(pathBaseName)
  ];
  return [...new Set(aliases)];
}

function specMatchesProjectScope(spec: SpecItem, project: ProjectItem | undefined, projectFilter: string): boolean {
  const aliases = project ? projectAliases(project) : normalizedParts(projectFilter);
  const specProject = spec.project?.toLowerCase().trim();
  if (specProject) {
    return aliases.some((alias) => specProject === alias || specProject.includes(alias) || alias.includes(specProject));
  }

  const specText = `${spec.title} ${spec.path} ${spec.userStory} ${spec.nextStep}`.toLowerCase();
  return aliases.some((alias) => specText.includes(alias));
}

function filteredSpecs(
  data: DashboardData,
  filter: string,
  project: ProjectItem | undefined,
  projectFilter: string
): SpecItem[] {
  const projectScoped = Boolean(projectFilter.trim());
  return data.specs.filter((spec) => {
    const matchesProject = !projectScoped || specMatchesProjectScope(spec, project, projectFilter);
    const matchesSpec = matchesFilter(`${spec.project ?? ""} ${spec.title} ${spec.status} ${spec.userStory} ${spec.nextStep}`, filter);
    return matchesProject && matchesSpec;
  });
}

function sectionLines(summary: TextSummary, max = 6): string[] {
  const lines = summary.lines.slice(0, max);
  return lines.length ? [`${summary.label}:`, ...lines] : [`${summary.label}: none`];
}

function withBlankLinesBetween(items: string[]): string[] {
  return items.flatMap((item, index) => (index === items.length - 1 ? [item] : [item, ""]));
}

function visibleWindowStart(selectedIndex: number, total: number, max: number): number {
  if (total <= max) {
    return 0;
  }
  return Math.max(0, Math.min(selectedIndex - max + 1, total - max));
}

function selectableSectionLines(summary: TextSummary, selectedIndex: number, max = 6): string[] {
  const start = visibleWindowStart(selectedIndex, summary.lines.length, max);
  const lines = summary.lines.slice(start, start + max);
  if (!lines.length) {
    return [`${summary.label}: none`];
  }

  return [
    `${summary.label}:`,
    ...withBlankLinesBetween(lines.map((line, index) => {
      const actualIndex = start + index;
      const marker = actualIndex === selectedIndex ? ">" : " ";
      const trafficMatch = line.match(/^((?:🔴|🟠|🟢|🟡)\s+)(.*)$/);
      if (trafficMatch) {
        return `${trafficMatch[1]}${marker} ${trafficMatch[2]}`;
      }
      return `${marker} ${line}`;
    }))
  ];
}

function filteredSummaryLines(summary: TextSummary, projectFilter: string, selectedProject: ProjectItem | undefined): string[] {
  const filter = projectFilter.trim().toLowerCase();
  if (!filter) {
    return summary.lines;
  }

  const projectName = selectedProject?.name.toLowerCase().trim();
  const terms = [filter, projectName].filter((term): term is string => Boolean(term));
  return summary.lines.filter((line) => {
    const normalized = line.toLowerCase();
    return terms.some((term) => normalized.includes(term));
  });
}

function listProjectLines(projects: ProjectItem[], selectedIndex: number): string[] {
  if (!projects.length) {
    return ["No projects match the current filter."];
  }

  const start = Math.floor(selectedIndex / PROJECT_VISIBLE_COUNT) * PROJECT_VISIBLE_COUNT;
  const visibleProjects = projects.slice(start, start + PROJECT_VISIBLE_COUNT);
  const lines: string[] = [];
  for (let row = 0; row < Math.ceil(visibleProjects.length / PROJECT_GRID_COLUMNS); row += 1) {
    const cells: string[] = [];
    for (let column = 0; column < PROJECT_GRID_COLUMNS; column += 1) {
      const visibleIndex = row * PROJECT_GRID_COLUMNS + column;
      const index = start + visibleIndex;
      const project = visibleProjects[visibleIndex];
      if (!project) {
        continue;
      }
      const marker = index === selectedIndex ? ">" : " ";
      const rawCell = `${marker} ${project.name}`;
      const cell = rawCell.length > PROJECT_GRID_COLUMN_WIDTH
        ? `${rawCell.slice(0, PROJECT_GRID_COLUMN_WIDTH - 3)}...`
        : rawCell;
      cells.push(cell.padEnd(PROJECT_GRID_COLUMN_WIDTH, " "));
    }
    lines.push(cells.join(" ").trimEnd());
    if (row < Math.ceil(visibleProjects.length / PROJECT_GRID_COLUMNS) - 1) {
      lines.push("");
    }
  }
  return lines;
}

function listSpecLines(specs: SpecItem[], selectedIndex: number): string[] {
  if (!specs.length) {
    return ["No specs match the current filter."];
  }
  const start = visibleWindowStart(selectedIndex, specs.length, SPEC_VISIBLE_COUNT);
  return withBlankLinesBetween(specs.slice(start, start + SPEC_VISIBLE_COUNT).map((spec, index) => {
    const actualIndex = start + index;
    const marker = actualIndex === selectedIndex ? ">" : " ";
    const project = spec.project ? `[${spec.project}] ` : "";
    return `${trafficFromSpecStatus(spec.status)} ${marker} ${project}[${spec.status}] ${spec.title}`;
  }));
}

function buildDetailLines(selectedProject: ProjectItem | undefined, selectedSpec: SpecItem | undefined): string[] {
  const lines: string[] = [];

  if (selectedProject) {
    lines.push("Selected project", `Name: ${selectedProject.name}`);
    lines.push("");
  }

  if (selectedSpec) {
    lines.push(
      "Selected chantier/spec",
      `Title: ${selectedSpec.title}`,
      `Status: ${selectedSpec.status}`,
      `User story: ${selectedSpec.userStory}`,
      `Next step: ${selectedSpec.nextStep}`,
      `Path: ${selectedSpec.path}`,
      "Run history:"
    );
    lines.push(...(selectedSpec.runHistorySummary.length ? selectedSpec.runHistorySummary.map((line) => `  ${line}`) : ["  none"]));
    lines.push("Current chantier flow:");
    lines.push(...(selectedSpec.chantierFlowSummary.length ? selectedSpec.chantierFlowSummary.map((line) => `  ${line}`) : ["  none"]));
    return lines;
  }

  lines.push("No spec details available.");
  return lines;
}

function normalizeState(data: DashboardData, state: DashboardViewState): DashboardViewState {
  const projects = filteredProjects(data, state.projectFilter);
  const selectedProjectIndex = clampIndex(state.selectedProjectIndex, projects.length);
  const selectedProject = projects[selectedProjectIndex];
  const specs = filteredSpecs(data, state.specFilter, selectedProject, state.projectFilter);
  const tasks = filteredSummaryLines(data.tasks, state.projectFilter, selectedProject);
  const audits = filteredSummaryLines(data.audits, state.projectFilter, selectedProject);
  return {
    ...state,
    selectedProjectIndex,
    selectedSpecIndex: clampIndex(state.selectedSpecIndex, specs.length),
    selectedTaskIndex: clampIndex(state.selectedTaskIndex, tasks.length),
    selectedAuditIndex: clampIndex(state.selectedAuditIndex, audits.length)
  };
}

export function buildDashboardViewModel(
  data: DashboardData,
  inputState: DashboardViewState = DEFAULT_DASHBOARD_VIEW_STATE
): DashboardViewModel {
  const state = normalizeState(data, inputState);
  const projects = filteredProjects(data, state.projectFilter);
  const selectedProject = projects[state.selectedProjectIndex];
  const specs = filteredSpecs(data, state.specFilter, selectedProject, state.projectFilter).sort((left, right) => {
    const leftPriority = trafficPriority(trafficFromSpecStatus(left.status));
    const rightPriority = trafficPriority(trafficFromSpecStatus(right.status));
    if (leftPriority !== rightPriority) {
      return leftPriority - rightPriority;
    }
    return left.title.localeCompare(right.title);
  });
  const selectedSpec = specs[state.selectedSpecIndex];

  const rawTaskLines = filteredSummaryLines(data.tasks, state.projectFilter, selectedProject);
  const sortedTaskLines = rawTaskLines.slice().sort((left, right) => {
    const leftTraffic = (left.match(/^(🔴|🟠|🟡|🟢)/u)?.[1] ?? "🟡");
    const rightTraffic = (right.match(/^(🔴|🟠|🟡|🟢)/u)?.[1] ?? "🟡");
    const diff = trafficPriority(leftTraffic) - trafficPriority(rightTraffic);
    if (diff !== 0) {
      return diff;
    }
    return left.localeCompare(right);
  });
  const activityLines = selectableSectionLines(
    { ...data.tasks, lines: sortedTaskLines },
    state.selectedTaskIndex,
    TASK_VISIBLE_COUNT
  );
  const lifecycleLines = sectionLines(data.lifecycle ?? { label: "Lifecycle", lines: [] }, 12);
  const checklistInstanceLines = sectionLines(data.checklistInstances ?? { label: "Checklist instances", lines: [] }, 12);

  const rawAuditLines = filteredSummaryLines(data.audits, state.projectFilter, selectedProject);
  const sortedAuditLines = rawAuditLines.slice().sort((left, right) => {
    const leftTraffic = (left.match(/^(🔴|🟠|🟡|🟢)/u)?.[1] ?? "🟡");
    const rightTraffic = (right.match(/^(🔴|🟠|🟡|🟢)/u)?.[1] ?? "🟡");
    const diff = trafficPriority(leftTraffic) - trafficPriority(rightTraffic);
    if (diff !== 0) {
      return diff;
    }
    return left.localeCompare(right);
  });
  const auditsLines = selectableSectionLines(
    { ...data.audits, lines: sortedAuditLines },
    state.selectedAuditIndex,
    AUDIT_VISIBLE_COUNT
  );

  const diagnosticsLines = data.diagnostics.length
    ? data.diagnostics.map((d) => `[${d.severity}] ${d.code}: ${d.message} ${d.source ? `(${d.source})` : ""}`)
    : ["No diagnostics."];

  return {
    header: "ShipGlowz TUI",
    activePanel: state.activePanel,
    projectFilter: state.projectFilter,
    specFilter: state.specFilter,
    selectedProjectName: selectedProject?.name,
    selectedSpecTitle: selectedSpec?.title,
    projectLines: listProjectLines(projects, state.selectedProjectIndex),
    specLines: listSpecLines(specs, state.selectedSpecIndex),
    activityLines,
    lifecycleLines,
    checklistInstanceLines,
    auditsLines,
    detailLines: buildDetailLines(selectedProject, selectedSpec),
    diagnosticsLines
  };
}

export function reduceDashboardViewState(
  data: DashboardData,
  inputState: DashboardViewState,
  key: DashboardKeyInput
): DashboardViewState {
  const state = normalizeState(data, inputState);
  const next = { ...state };
  const activeIndex = TAB_PANEL_ORDER.indexOf(state.activePanel);
  const sequence = key.sequence ?? "";
  const raw = key.raw ?? "";
  const name = key.name ?? "";
  const printable = sequence.length === 1 ? sequence : name.length === 1 ? name : "";

  if (printable === "!" && !key.ctrl) {
    next.diagnosticChord = `${state.diagnosticChord}!`.slice(-3);
    if (next.diagnosticChord === "!!!") {
      next.activePanel = "diagnostics";
      next.diagnosticChord = "";
    }
    return normalizeState(data, next);
  }

  next.diagnosticChord = "";

  if (name === "tab" || sequence === "\t" || raw === "\t") {
    const direction = key.shift ? -1 : 1;
    const currentIndex = activeIndex === -1 ? 0 : activeIndex;
    next.activePanel = TAB_PANEL_ORDER[(currentIndex + direction + TAB_PANEL_ORDER.length) % TAB_PANEL_ORDER.length] ?? "projects";
    return normalizeState(data, next);
  }

  if (state.activePanel === "projects" || state.activePanel === "specs" || state.activePanel === "activity" || state.activePanel === "audits") {
    const projects = filteredProjects(data, state.projectFilter);
    const selectedProject = projects[state.selectedProjectIndex];
    const selectedKey = state.activePanel === "specs"
      ? "selectedSpecIndex"
      : state.activePanel === "activity"
        ? "selectedTaskIndex"
        : state.activePanel === "audits"
          ? "selectedAuditIndex"
          : "selectedProjectIndex";
    const length = state.activePanel === "specs"
      ? filteredSpecs(data, state.specFilter, selectedProject, state.projectFilter).length
      : state.activePanel === "activity"
        ? filteredSummaryLines(data.tasks, state.projectFilter, selectedProject).length
        : state.activePanel === "audits"
          ? filteredSummaryLines(data.audits, state.projectFilter, selectedProject).length
          : projects.length;
    const filterKey = state.activePanel === "specs" ? "specFilter" : "projectFilter";

    if (name === "down" || name === "arrowdown") {
      next[selectedKey] = clampIndex(state[selectedKey] + 1, length);
      return normalizeState(data, next);
    }
    if (name === "up" || name === "arrowup") {
      next[selectedKey] = clampIndex(state[selectedKey] - 1, length);
      return normalizeState(data, next);
    }
    if (name === "backspace" || name === "delete" || raw === "\x7f") {
      next[filterKey] = state[filterKey].slice(0, -1);
      next[selectedKey] = 0;
      if (filterKey === "projectFilter") {
        next.selectedTaskIndex = 0;
        next.selectedAuditIndex = 0;
      }
      return normalizeState(data, next);
    }
    if (printable && !key.ctrl && name !== "return" && name !== "escape") {
      next[filterKey] = `${state[filterKey]}${printable}`;
      next[selectedKey] = 0;
      if (filterKey === "projectFilter") {
        next.selectedTaskIndex = 0;
        next.selectedAuditIndex = 0;
      }
      return normalizeState(data, next);
    }
  }

  return state;
}
