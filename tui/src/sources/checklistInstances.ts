import type { Diagnostic, TextSummary } from "../types/models.ts";

const TERMINAL_STATUSES = new Set(["verified", "not_applicable", "retired"]);

function metadata(content: string, key: string): string | undefined {
  return content.match(new RegExp(`^${key}:\\s*"?([^\\n"]+)"?\\s*$`, "m"))?.[1]?.trim();
}

function cells(line: string): string[] {
  return line.trim().replace(/^\||\|$/g, "").split("|").map((cell) => cell.trim());
}

function isSeparator(line: string): boolean {
  return cells(line).every((cell) => /^:?-{3,}:?$/.test(cell));
}

function checklistControls(content: string, source: string, diagnostics: Diagnostic[]): Array<{ id: string; phase: string; status: string; required: boolean; evidence: boolean }> {
  const lines = content.split("\n");
  const heading = lines.findIndex((line) => line.trim() === "## Controls");
  if (heading < 0) return [];
  const headerIndex = lines.findIndex((line, index) => index > heading && line.trim().startsWith("| Control ID |"));
  if (headerIndex < 0 || !lines[headerIndex + 1] || !isSeparator(lines[headerIndex + 1])) {
    diagnostics.push({ code: "CHECKLIST_CONTROLS_UNREADABLE", severity: "warning", source, message: "Checklist instance controls table is missing or malformed" });
    return [];
  }
  const headers = cells(lines[headerIndex]);
  const rows: Array<{ id: string; phase: string; status: string; required: boolean; evidence: boolean }> = [];
  for (const line of lines.slice(headerIndex + 2)) {
    if (!line.trim().startsWith("|")) break;
    const values = cells(line);
    if (values.length !== headers.length) continue;
    const row = Object.fromEntries(headers.map((header, index) => [header, values[index] ?? ""]));
    const id = row["Control ID"]?.replaceAll("`", "").trim();
    if (!id || id === "[master-control-id]") continue;
    const status = (row["Status"] ?? "not_started").replaceAll("`", "").trim().toLowerCase();
    const required = ["yes", "true", "required"].includes((row["Required"] ?? "").toLowerCase());
    const evidence = !["", "-", "none"].includes((row["Evidence"] ?? "").trim().toLowerCase());
    rows.push({ id, phase: row["Phase"]?.trim() ?? "", status: required && status === "verified" && !evidence ? "waiting_for_evidence" : status, required, evidence });
  }
  return rows;
}

export function summarizeChecklistInstance(content: string, project: string, source: string, diagnostics: Diagnostic[]): string | undefined {
  const controls = checklistControls(content, source, diagnostics);
  if (!controls.length) return undefined;
  const done = controls.filter((control) => TERMINAL_STATUSES.has(control.status)).length;
  const current = controls.find((control) => !TERMINAL_STATUSES.has(control.status));
  const blocked = controls.filter((control) => ["blocked", "waiting_for_evidence"].includes(control.status)).map((control) => control.id);
  const checklist = metadata(content, "checklist_id") ?? "unknown-checklist";
  const cycle = metadata(content, "cycle_id") ?? "unknown-cycle";
  return `[${project}] checklist ${checklist} · cycle ${cycle} · progress ${done}/${controls.length}${current?.phase ? ` · phase ${current.phase}` : ""}${current ? ` · next ${current.id}` : " · cycle complete"}${blocked.length ? ` · blocked ${blocked.join(", ")}` : ""}`;
}

export function summarizeChecklistInstances(contents: Array<{ content: string; project: string; source: string }>, diagnostics: Diagnostic[]): TextSummary {
  const lines = contents.flatMap(({ content, project, source }) => {
    const line = summarizeChecklistInstance(content, project, source, diagnostics);
    return line ? [line] : [];
  });
  return { label: "Checklist instances", lines: lines.length ? lines : ["No checklist instances."] };
}
