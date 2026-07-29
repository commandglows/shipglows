import { readdir } from "node:fs/promises";
import path from "node:path";
import { SourcePolicy, type SourceReadResult } from "./sourcePolicy.ts";
import {
  parseCanonicalRecords,
  specDedupeKey,
  registerDedupe,
  type CanonicalOperationalRecord,
  type DedupEntry
} from "./canonicalRecords.ts";
import {
  summarizeTasks,
  summarizeAudits
} from "./summarizers.ts";
import { summarizeLifecycle } from "./lifecycle.ts";
import { summarizeChecklistInstances } from "./checklistInstances.ts";
import { topLines } from "../statusMaps.ts";
import type { DashboardData, Diagnostic, ProjectItem, SpecItem, TextSummary } from "../types/models.ts";

export interface ReaderConfig {
  projectRoot: string;
  workspaceRoots?: string[];
  shipflowRepoRoot: string;
  projectDiscoveryDepth?: number;
  projectDiscoveryDirectoryEntriesLimit?: number;
  projectDiscoveryMaxProjects?: number;
}

function parseMetadataValue(content: string | undefined, key: string): string | undefined {
  const match = content?.match(new RegExp(`^${key}:\\s*"?([^\\n"]+?)"?\\s*$`, "m"));
  return match?.[1]?.trim().replace(/^["']|["']$/g, "");
}

function projectNameFromMetadata(content: string | undefined): string | undefined {
  return parseMetadataValue(content, "project");
}

function projectStackFromMetadata(content: string | undefined): string | undefined {
  return parseMetadataValue(content, "stack");
}

function hasProjectMarkers(entries: string[]): boolean {
  const markers = new Set([
    "AGENT.md",
    "CLAUDE.md",
    "package.json",
    "pyproject.toml",
    "Cargo.toml",
    "go.mod",
    "pubspec.yaml"
  ]);
  return entries.some((entry) => markers.has(entry));
}

function disambiguateProjectNames(items: { name: string; path: string; stack?: string; source: string }[]): ProjectItem[] {
  const counts = new Map<string, number>();
  return items.map((item) => {
    const normalized = normalizedProjectKey(item.name);
    const existing = counts.get(normalized) ?? 0;
    counts.set(normalized, existing + 1);
    const name = existing === 0 ? item.name : `${item.name} (${path.basename(item.path)})`;
    return { name, path: item.path, stack: item.stack, source: item.source };
  });
}

function normalizedProjectKey(value: string | undefined): string {
  return (value ?? "").toLowerCase().replace(/[^a-z0-9]+/g, "");
}

function extractTableRows(content: string, heading: string): string[][] {
  const lines = content.split("\n");
  const headingIndex = lines.findIndex((line) => line.trim().toLowerCase() === heading.toLowerCase());
  if (headingIndex === -1) {
    return [];
  }

  const rows: string[][] = [];
  for (const rawLine of lines.slice(headingIndex + 1)) {
    const line = rawLine.trim();
    if (line.startsWith("# ")) {
      break;
    }
    if (!line.startsWith("|")) {
      continue;
    }
    const cells = line.split("|").map((cell) => cell.trim()).filter(Boolean);
    if (!cells.length || cells.every((cell) => /^-+$/.test(cell)) || cells[0]?.toLowerCase() === "date utc") {
      continue;
    }
    rows.push(cells);
  }

  return rows;
}

function parseSpecs(content: string, filePath: string, diagnostics: Diagnostic[]): SpecItem {
  const canonicalRecords = parseCanonicalRecords(content, filePath, diagnostics).filter((record) => record.kind === "spec");
  const canonicalByKey = new Map<string, CanonicalOperationalRecord>();

  let canonicalSpec: CanonicalOperationalRecord | undefined;
  for (const record of canonicalRecords) {
    const key = specDedupeKey(record.project, record.fields.id, record.fields.path, record.title);
    if (!canonicalByKey.has(key)) {
      canonicalByKey.set(key, record);
      if (!canonicalSpec) {
        canonicalSpec = record;
      }
      continue;
    }

    const existing = canonicalByKey.get(key);
    if (existing) {
      diagnostics.push({
        code: "SPEC_RECORD_DUPLICATE",
        severity: "warning",
        source: `${filePath}:${record.line}`,
        message: `Duplicate spec canonical record "${record.title}" ignored; canonical record kept from ${filePath}:${existing.line}`
      });
    }
  }

  const specProject = canonicalSpec?.project ??
    content.match(/^project:\s*"?(.+?)"?$/m)?.[1]?.trim();

  const canonicalTitle = canonicalSpec?.title;
  const explicitTitle = content.match(/^#\s+Title\s*\n+([^\n#].+)$/m)?.[1]?.trim();
  const headingTitle = content.match(/^#\s+(.+)$/m)?.[1]?.trim();
  const title = canonicalTitle ?? explicitTitle ?? headingTitle ?? path.basename(filePath);

  const frontmatterStatus = content.match(/^status:\s*(.+)$/m)?.[1]?.trim();
  const canonicalStatus = canonicalSpec?.fields.status?.trim();
  const status = canonicalStatus ?? frontmatterStatus ?? "unknown";
  const userStory = content.match(/^user_story:\s*"?(.+?)"?$/m)?.[1]?.trim() ?? "n/a";

  const frontmatterNextStep = content.match(/^next_step:\s*"?(.+?)"?$/m)?.[1]?.trim();
  const canonicalNextStep = canonicalSpec?.fields.next?.trim();
  const nextStep = canonicalNextStep ?? frontmatterNextStep ?? "n/a";

  const canonicalPath = canonicalSpec?.fields.path?.trim();
  const specPath = canonicalPath ?? filePath;

  if (canonicalSpec) {
    if (!canonicalStatus) {
      diagnostics.push({
        code: "SPEC_RECORD_MISSING_FIELD",
        severity: "warning",
        source: `${filePath}:${canonicalSpec.line}`,
        message: `Canonical spec summary missing required "status" field for ${canonicalSpec.title}`
      });
    }
    if (!canonicalSpec.fields.path) {
      diagnostics.push({
        code: "SPEC_RECORD_MISSING_FIELD",
        severity: "warning",
        source: `${filePath}:${canonicalSpec.line}`,
        message: `Canonical spec summary missing required "path" field for ${canonicalSpec.title}`
      });
    }
    if (!canonicalSpec.fields.next) {
      diagnostics.push({
        code: "SPEC_RECORD_MISSING_FIELD",
        severity: "warning",
        source: `${filePath}:${canonicalSpec.line}`,
        message: `Canonical spec summary missing required "next" field for ${canonicalSpec.title}`
      });
    }
  }

  const runHistorySummary = extractTableRows(content, "# Skill Run History")
    .slice(-4)
    .map((cells) => `${cells[1] ?? "unknown"}: ${cells[4] ?? "unknown result"}`);
  const chantierFlowSummary = extractTableRows(content, "# Current Chantier Flow")
    .filter((cells) => cells[0]?.toLowerCase() !== "phase")
    .map((cells) => `${cells[0] ?? "phase"}=${cells[1] ?? "unknown"}`);

  return {
    path: specPath,
    project: specProject,
    title,
    status,
    userStory,
    nextStep,
    runHistorySummary,
    chantierFlowSummary
  };
}

const DEFAULT_PROJECT_DISCOVERY_DEPTH = 4;
const DEFAULT_PROJECT_DISCOVERY_DIRECTORY_ENTRIES_LIMIT = 2500;
const DEFAULT_PROJECT_DISCOVERY_MAX_PROJECTS = 200;

interface ProjectCandidate {
  name: string;
  path: string;
  source: string;
  stack?: string;
}

async function discoverLocalProjects(config: {
  projectRoot: string;
  workspaceRoots?: string[];
  policy: SourcePolicy;
  discoveryDepth: number;
  directoryEntriesLimit: number;
  maxProjects: number;
  diagnostics: Diagnostic[];
}): Promise<ProjectCandidate[]> {
  const roots = Array.from(new Set(
    [config.projectRoot, ...(config.workspaceRoots ?? []), path.dirname(config.projectRoot)]
      .filter(Boolean)
      .map((root) => path.resolve(root))
  ));
  const nodes: { dir: string; depth: number }[] = roots.map((root) => ({ dir: root, depth: 0 }));
  const visited = new Set<string>();
  const candidates: ProjectCandidate[] = [];

  while (nodes.length) {
    if (candidates.length >= config.maxProjects) {
      break;
    }

    const node = nodes.shift();
    if (!node) {
      break;
    }
    if (node.depth > config.discoveryDepth) {
      continue;
    }

    let entries: Array<{ name: string; isDirectory: boolean; isSymbolicLink: boolean }>;
    try {
      const dirEntries = await readdir(node.dir, { withFileTypes: true });
      entries = dirEntries.map((entry) => ({
        name: entry.name,
        isDirectory: entry.isDirectory(),
        isSymbolicLink: entry.isSymbolicLink()
      }));
    } catch {
      config.diagnostics.push({
        code: "PROJECT_DISCOVERY_DIR_UNREADABLE",
        severity: "warning",
        message: "Project discovery directory unreadable",
        source: config.policy.redactPath(node.dir)
      });
      continue;
    }

    const childNames = entries.map((entry) => entry.name);
    if (entries.length > config.directoryEntriesLimit) {
      config.diagnostics.push({
        code: "PROJECT_DISCOVERY_DIR_TOO_LARGE",
        severity: "warning",
        message: "Skipping directory scan because too many entries",
        source: config.policy.redactPath(node.dir)
      });
      continue;
    }

    const shipflowDataEntry = entries.find((entry) => entry.name === "shipglowz_data" && entry.isDirectory && !entry.isSymbolicLink);
    if (shipflowDataEntry) {
      if (path.basename(node.dir) !== "shipglowz_data" && path.basename(node.dir) !== ".git") {
        const markerEntries = childNames;
        if (hasProjectMarkers(markerEntries)) {
          const sourceMarker = path.join(node.dir, "AGENT.md");
          const localAgentResult = await config.policy.safeRead(sourceMarker);
          const localClaudeResult = await config.policy.safeRead(path.join(node.dir, "CLAUDE.md"));
          const localProjectName = localAgentResult.ok
            ? projectNameFromMetadata(localAgentResult.content)
            : projectNameFromMetadata(localClaudeResult.ok ? localClaudeResult.content : undefined);
          const projectName = localProjectName || path.basename(node.dir);
          const stack = projectStackFromMetadata(
            localAgentResult.ok
              ? localAgentResult.content
              : localClaudeResult.ok
                ? localClaudeResult.content
                : undefined
          );

          const candidate: ProjectCandidate = {
            name: projectName,
            path: node.dir,
            source: localAgentResult.ok
              ? (localAgentResult.realPath ?? sourceMarker)
              : localClaudeResult.ok
                ? (localClaudeResult.realPath ?? path.join(node.dir, "CLAUDE.md"))
                : node.dir,
            stack
          };
          if (!candidates.some((item) => normalizedProjectKey(item.path) === normalizedProjectKey(candidate.path))) {
            candidates.push(candidate);
          }
        }
      }
    }

    if (node.depth === config.discoveryDepth) {
      continue;
    }

    for (const name of childNames) {
      const entry = entries.find((item) => item.name === name);
      if (!entry || !entry.isDirectory || entry.isSymbolicLink) {
        continue;
      }
      if (name.startsWith(".") || name === "node_modules" || name === ".git" || name === "dist" || name === "build") {
        continue;
      }
      const next = path.join(node.dir, name);
      if (visited.has(next)) {
        continue;
      }
      if (name.toLowerCase() === "shipglowz_data") {
        continue;
      }
      const normalizedPath = path.resolve(next);
      if (visited.has(normalizedPath)) {
        continue;
      }
      visited.add(normalizedPath);
      nodes.push({ dir: normalizedPath, depth: node.depth + 1 });
    }
  }

  return candidates;
}

export async function readDashboardData(config: ReaderConfig): Promise<DashboardData> {
  const diagnostics: Diagnostic[] = [];
  const discoveryDepth = config.projectDiscoveryDepth ?? DEFAULT_PROJECT_DISCOVERY_DEPTH;
  const directoryEntriesLimit = config.projectDiscoveryDirectoryEntriesLimit ?? DEFAULT_PROJECT_DISCOVERY_DIRECTORY_ENTRIES_LIMIT;
  const maxProjects = config.projectDiscoveryMaxProjects ?? DEFAULT_PROJECT_DISCOVERY_MAX_PROJECTS;
  const workspaceRoots = config.workspaceRoots ? config.workspaceRoots.filter(Boolean) : [];
  const skillsRoot = path.join(config.shipflowRepoRoot, "skills");
  const policy = new SourcePolicy({
    roots: [config.projectRoot, ...workspaceRoots, config.shipflowRepoRoot]
  });

  const read = async (filePath: string) => {
    const result = await policy.safeRead(filePath);
    if (!result.ok && result.diagnostic) {
      diagnostics.push(result.diagnostic);
    }
    return result;
  };
  const readOptional = async (filePath: string) => policy.safeRead(filePath);
  const readFirstExisting = async (filePaths: string[], reportMissing = false): Promise<SourceReadResult | undefined> => {
    for (const filePath of filePaths) {
      const result = await policy.safeRead(filePath);
      if (result.ok) {
        return result;
      }
      if (reportMissing && result.diagnostic) {
        diagnostics.push(result.diagnostic);
      }
    }
    return undefined;
  };
  const summarizeTopLines = (label: string, values: string[], max = 12): TextSummary =>
    values.length ? { label, lines: values.slice(0, max) } : topLines(label, "", max);

  const discoveredProjects = await discoverLocalProjects({
    projectRoot: config.projectRoot,
    workspaceRoots,
    policy,
    discoveryDepth,
    directoryEntriesLimit,
    maxProjects,
    diagnostics
  });

  const normalizedNameCount = new Map<string, number>();
  for (const candidate of discoveredProjects) {
    const count = normalizedNameCount.get(normalizedProjectKey(candidate.name)) ?? 0;
    normalizedNameCount.set(normalizedProjectKey(candidate.name), count + 1);
  }
  for (const [normalized, count] of normalizedNameCount.entries()) {
    if (count > 1) {
      const duplicateCandidates = discoveredProjects.filter((candidate) => normalizedProjectKey(candidate.name) === normalized);
      for (const duplicate of duplicateCandidates.slice(1)) {
        diagnostics.push({
          code: "PROJECT_NAME_DUPLICATE",
          severity: "warning",
          source: policy.redactPath(duplicate.path),
          message: `Duplicate project name "${duplicate.name}" detected; keeping separate entries by path`
        });
      }
    }
  }

  const projects = disambiguateProjectNames(discoveredProjects).map((project) => ({
    name: project.name,
    path: project.path ?? config.projectRoot,
    stack: project.stack ?? undefined,
    source: project.source
  }));

  const localAgentResult = await readOptional(path.join(config.projectRoot, "AGENT.md"));
  const localClaudeResult = localAgentResult.ok
    ? undefined
    : await readOptional(path.join(config.projectRoot, "CLAUDE.md"));
  const localProjectFallbackName =
    projectNameFromMetadata(localAgentResult.ok ? localAgentResult.content : undefined) ??
    projectNameFromMetadata(localClaudeResult?.ok ? localClaudeResult.content : undefined) ??
    path.basename(config.projectRoot);
  if (!projects.some((project) => normalizedProjectKey(project.path) === normalizedProjectKey(config.projectRoot))) {
    projects.push({
      name: localProjectFallbackName,
      path: config.projectRoot,
      stack: undefined,
      source: localAgentResult.ok ? localAgentResult.realPath ?? "AGENT.md" : config.projectRoot
    });
  }

  const dedupedProjects: Array<{ name: string; path: string; stack: string | undefined; source: string }> = [];
  const seenProjectPaths = new Set<string>();
  for (const project of projects) {
    const projectPath = project.path ?? config.projectRoot;
    const normalizedPath = path.resolve(projectPath).toLowerCase();
    if (seenProjectPaths.has(normalizedPath)) {
      continue;
    }
    seenProjectPaths.add(normalizedPath);
    dedupedProjects.push(project);
  }
  projects.splice(0, projects.length, ...dedupedProjects);

  const specs: SpecItem[] = [];
  const seenSpecs = new Map<string, DedupEntry>();
  for (const project of projects) {
    const projectPath = project.path ?? config.projectRoot;
    const specsRoot = path.join(projectPath, "shipglowz_data/workflow/specs");
    try {
      const entries = await readdir(specsRoot, { withFileTypes: true });
      for (const entry of entries) {
        if (!entry.isFile() || !entry.name.endsWith(".md")) {
          continue;
        }
        const specPath = path.join(specsRoot, entry.name);
        const specResult = await read(specPath);
        if (!specResult.ok || !specResult.content) {
          continue;
        }
        const spec = parseSpecs(specResult.content, specPath, diagnostics);
        const specPathForDedupe = spec.path;
        const dedupeKey = specDedupeKey(spec.project ?? "", undefined, specPathForDedupe, spec.title);
        if (!registerDedupe(seenSpecs, dedupeKey, "spec", policy.redactPath(specPath), 1, "canonical", diagnostics)) {
          continue;
        }
        specs.push(spec);
      }
    } catch {
      diagnostics.push({
        code: "SPECS_DIR_UNREADABLE",
        severity: "warning",
        message: "Specs directory missing or unreadable",
        source: policy.redactPath(specsRoot)
      });
    }
  }

  const skills: string[] = [];
  try {
    const entries = await readdir(skillsRoot, { withFileTypes: true });
    for (const entry of entries) {
      if (entry.isDirectory() && !entry.name.startsWith(".")) {
        skills.push(entry.name);
      }
    }
  } catch {
    diagnostics.push({
      code: "SKILLS_DIR_UNREADABLE",
      severity: "warning",
      message: "Skills directory missing or unreadable",
      source: policy.redactPath(skillsRoot)
    });
  }

  const taskSources: { content: string; defaultProject?: string; sourcePath: string; redactedSourcePath: string }[] = [];
  for (const project of projects) {
    const projectPath = project.path ?? config.projectRoot;
    const fallback = await readFirstExisting([
      path.join(projectPath, "shipglowz_data/workflow/TASKS.md"),
      path.join(projectPath, "shipglowz_data/TASKS.md")
    ]);
    if (!fallback?.ok || !fallback.content) {
      continue;
    }
    const sourcePath = fallback.realPath ?? path.join(projectPath, "shipglowz_data/workflow/TASKS.md");
    taskSources.push({
      content: fallback.content,
      defaultProject: project.name,
      sourcePath,
      redactedSourcePath: policy.redactPath(sourcePath)
    });
  }

  const auditSources: { content: string; defaultProject?: string; sourcePath: string; redactedSourcePath: string }[] = [];
  const lifecycleLines: string[] = [];
  const checklistInstanceSources: { content: string; project: string; source: string }[] = [];
  for (const project of projects) {
    const projectPath = project.path ?? config.projectRoot;
    const fallback = await readFirstExisting([
      path.join(projectPath, "shipglowz_data/workflow/AUDIT_LOG.md"),
      path.join(projectPath, "shipglowz_data/AUDIT_LOG.md")
    ]);
    if (!fallback?.ok || !fallback.content) {
      continue;
    }
    const sourcePath = fallback.realPath ?? path.join(projectPath, "shipglowz_data/workflow/AUDIT_LOG.md");
    auditSources.push({
      content: fallback.content,
      defaultProject: project.name,
      sourcePath,
      redactedSourcePath: policy.redactPath(sourcePath)
    });
  }

  for (const project of projects) {
    const projectPath = project.path ?? config.projectRoot;
    const lifecycle = await readFirstExisting([
      path.join(projectPath, "shipglowz_data/workflow/project_lifecycle.md"),
      path.join(projectPath, "shipglowz_data/project_lifecycle.md")
    ]);
    if (lifecycle?.ok && lifecycle.content) {
      lifecycleLines.push(...summarizeLifecycle(lifecycle.content, project.name, diagnostics).lines);
    }
    const instancesRoot = path.join(projectPath, "shipglowz_data/workflow/checklist-instances");
    try {
      const entries = await readdir(instancesRoot, { withFileTypes: true });
      for (const entry of entries) {
        if (!entry.isFile() || !entry.name.endsWith(".md")) continue;
        const instancePath = path.join(instancesRoot, entry.name);
        const instance = await readOptional(instancePath);
        if (instance.ok && instance.content) {
          checklistInstanceSources.push({ content: instance.content, project: project.name, source: policy.redactPath(instance.realPath ?? instancePath) });
        }
      }
    } catch {
      // Optional source: legacy projects remain readable without a checklist directory.
    }
  }

  const operationLines: string[] = [];
  const dependencyLines: string[] = [];
  for (const project of projects) {
    const projectPath = project.path ?? config.projectRoot;
    const ops = await readFirstExisting([
      path.join(projectPath, "shipglowz_data/workflow/OPERATIONS_LOG.md"),
      path.join(projectPath, "shipglowz_data/OPERATIONS_LOG.md")
    ]);
    if (ops?.ok && ops.content) {
      operationLines.push(...ops.content.split("\n").map((line) => line.trim()).filter(Boolean));
    }
    const deps = await readFirstExisting([
      path.join(projectPath, "shipglowz_data/workflow/DEPENDENCY_LOG.md"),
      path.join(projectPath, "shipglowz_data/DEPENDENCY_LOG.md")
    ]);
    if (deps?.ok && deps.content) {
      dependencyLines.push(...deps.content.split("\n").map((line) => line.trim()).filter(Boolean));
    }
  }

  const taskLines = summarizeTasks(taskSources, diagnostics);
  const auditLines = summarizeAudits(auditSources, diagnostics);

  const opsLines = summarizeTopLines("Operations", operationLines);
  const depLines = summarizeTopLines("Dependencies", dependencyLines);

  return {
    projects,
    specs,
    tasks: taskLines,
    lifecycle: { label: "Lifecycle", lines: lifecycleLines },
    checklistInstances: summarizeChecklistInstances(checklistInstanceSources, diagnostics),
    audits: auditLines,
    operations: opsLines,
    dependencies: depLines,
    skills: topLines("Skills", skills.join("\n")),
    diagnostics
  };
}
