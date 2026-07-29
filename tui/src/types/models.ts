export type Severity = "info" | "warning" | "error";

export interface Diagnostic {
  code: string;
  message: string;
  severity: Severity;
  source?: string;
}

export interface ProjectItem {
  name: string;
  path?: string;
  stack?: string;
  source: string;
}

export interface SpecItem {
  path: string;
  project?: string;
  title: string;
  status: string;
  userStory: string;
  nextStep: string;
  runHistorySummary: string[];
  chantierFlowSummary: string[];
}

export interface TextSummary {
  label: string;
  lines: string[];
}

export interface DashboardData {
  projects: ProjectItem[];
  specs: SpecItem[];
  tasks: TextSummary;
  lifecycle?: TextSummary;
  checklistInstances?: TextSummary;
  audits: TextSummary;
  operations: TextSummary;
  dependencies: TextSummary;
  skills: TextSummary;
  diagnostics: Diagnostic[];
}

export type DashboardPanel = "projects" | "specs" | "activity" | "audits" | "diagnostics";

export interface DashboardViewState {
  activePanel: DashboardPanel;
  diagnosticChord: string;
  projectFilter: string;
  specFilter: string;
  selectedProjectIndex: number;
  selectedSpecIndex: number;
  selectedTaskIndex: number;
  selectedAuditIndex: number;
}

export interface DashboardKeyInput {
  name?: string;
  sequence?: string;
  raw?: string;
  ctrl?: boolean;
  shift?: boolean;
}

export interface DashboardViewModel {
  header: string;
  activePanel: DashboardPanel;
  projectFilter: string;
  specFilter: string;
  selectedProjectName?: string;
  selectedSpecTitle?: string;
  projectLines: string[];
  specLines: string[];
  activityLines: string[];
  lifecycleLines: string[];
  checklistInstanceLines: string[];
  auditsLines: string[];
  detailLines: string[];
  diagnosticsLines: string[];
}
