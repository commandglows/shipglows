import type { Diagnostic, TextSummary } from "../types/models.ts";
import { cellFor, parseMarkdownTableRows } from "../statusMaps.ts";

const OPEN_STATES = new Set(["not_started", "in_progress", "waiting_for_evidence", "overdue", "blocked"]);

export interface LifecycleProjectionItem {
  itemId: string;
  instanceId: string;
  type: string;
  domain: string;
  state: string;
  dueAt?: string;
  evidence: boolean;
  suspended: boolean;
  historyClosed: boolean;
  nextInstanceId?: string;
  nextDueAt?: string;
}

function dueDate(value: string | undefined): Date | undefined {
  if (!value || value === "-") {
    return undefined;
  }
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? undefined : parsed;
}

function hasEvidence(value: string | undefined): boolean {
  return Boolean(value && !["", "-", "none"].includes(value.toLowerCase()));
}

function nextDue(due: Date, cadence: string): Date | undefined {
  const kind = cadence.split(";", 1)[0]?.trim().toLowerCase();
  const next = new Date(due);
  if (kind === "daily") next.setUTCDate(next.getUTCDate() + 1);
  else if (kind === "weekly") next.setUTCDate(next.getUTCDate() + 7);
  else if (kind === "monthly") next.setUTCMonth(next.getUTCMonth() + 1);
  else if (kind === "quarterly") next.setUTCMonth(next.getUTCMonth() + 3);
  else return undefined;
  return next;
}

export function projectLifecycleRows(
  content: string,
  now = new Date()
): LifecycleProjectionItem[] {
  const phase = content.match(/^- Lifecycle phase:\s*`?([^`\n]+)`?\s*$/m)?.[1]?.trim() ?? "unknown";
  const paused = phase.toLowerCase() === "paused";
  return parseMarkdownTableRows(content)
    .filter((row) => row.context === "Lifecycle Items")
    .flatMap((row) => {
      const itemId = cellFor(row, ["item id"]);
      const instanceId = cellFor(row, ["instance id"]);
      const type = cellFor(row, ["type"]);
      const domain = cellFor(row, ["domain"]);
      const state = cellFor(row, ["state"]);
      if (!itemId || !instanceId || !type || !domain || !state || itemId === "-" || itemId === "[stable-item-id]") return [];
      const dueAt = cellFor(row, ["due at"]);
      const due = dueDate(dueAt);
      const required = cellFor(row, ["required"])?.toLowerCase() === "yes";
      const evidence = hasEvidence(cellFor(row, ["evidence"]));
      const suspended = paused && ["recurring", "cyclic", "event_triggered"].includes(type);
      let projectedState = state;
      if (required && state === "verified" && !evidence) projectedState = "waiting_for_evidence";
      else if (due && OPEN_STATES.has(state) && due < now && !suspended) projectedState = "overdue";
      const next = type === "recurring" && projectedState === "verified" && due
        ? nextDue(due, cellFor(row, ["cadence"]) ?? "")
        : undefined;
      return [{
        itemId,
        instanceId,
        type,
        domain,
        state: projectedState,
        ...(dueAt && due ? { dueAt: due.toISOString() } : {}),
        evidence,
        suspended,
        historyClosed: Boolean(next),
        ...(next ? {
          nextInstanceId: `${itemId}:${next.toISOString().slice(0, 10)}`,
          nextDueAt: next.toISOString()
        } : {})
      }];
    });
}

export function summarizeLifecycle(
  content: string,
  project: string,
  diagnostics: Diagnostic[],
  now = new Date()
): TextSummary {
  const phase = content.match(/^- Lifecycle phase:\s*`?([^`\n]+)`?\s*$/m)?.[1]?.trim() ?? "unknown";
  const rows = parseMarkdownTableRows(content).filter((row) => row.context === "Lifecycle Items");
  const projectedRows = projectLifecycleRows(content, now);
  const lines: string[] = [`[${project}] phase: ${phase}`];

  for (const row of rows) {
    const itemId = cellFor(row, ["item id"]);
    const instanceId = cellFor(row, ["instance id"]);
    const type = cellFor(row, ["type"]);
    const domain = cellFor(row, ["domain"]);
    const state = cellFor(row, ["state"]);
    const dueAt = cellFor(row, ["due at"]);
    if (!itemId || !instanceId || !type || !domain || !state) {
      diagnostics.push({
        code: "LIFECYCLE_ROW_INCOMPLETE",
        severity: "warning",
        message: `Lifecycle row is missing an ID, type, domain, or state for ${project}`
      });
      continue;
    }
    const due = dueDate(dueAt);
    if (dueAt && dueAt !== "-" && !due) {
      diagnostics.push({
        code: "LIFECYCLE_DUE_DATE_INVALID",
        severity: "warning",
        message: `Invalid lifecycle due date for ${itemId}`
      });
    }
    const projection = projectedRows.find((item) => item.itemId === itemId && item.instanceId === instanceId);
    const projectedState = projection?.state ?? state;
    const suspended = projection?.suspended ?? false;
    const bucket = projectedState === "overdue"
      ? "overdue"
      : due && due.toISOString().slice(0, 10) === now.toISOString().slice(0, 10)
        ? "today"
        : due && due > now && due.getTime() < now.getTime() + 7 * 24 * 60 * 60 * 1000
          ? "this week"
          : "";
    const next = type === "recurring" && projectedState === "verified" ? " → next occurrence" : "";
    const pause = suspended ? " [suspended: project paused]" : "";
    lines.push(`${projectedState === "overdue" ? "🔴" : projectedState === "verified" ? "🟢" : "🟡"} [${domain}] ${itemId} — ${projectedState}${bucket ? ` · ${bucket}` : ""}${next}${pause}`);
  }
  return { label: "Lifecycle", lines };
}
