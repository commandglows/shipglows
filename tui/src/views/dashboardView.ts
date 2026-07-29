import type { DashboardData, DashboardViewModel, DashboardViewState } from "../types/models.ts";
import type { StyledText, TextChunk } from "@opentui/core";
import {
  buildDashboardViewModel,
  DEFAULT_DASHBOARD_VIEW_STATE,
  reduceDashboardViewState
} from "../viewModels/dashboard.ts";
import { statusColor } from "../statusMaps.ts";

function activeMarker(vm: DashboardViewModel, panel: DashboardViewModel["activePanel"]): string {
  return vm.activePanel === panel ? "*" : " ";
}

function statusLine(vm: DashboardViewModel): string {
  return `${vm.header} | p:"${vm.projectFilter}" s:"${vm.specFilter}"`;
}

const LEFT_MARGIN = "    ";
const MIN_RENDER_WIDTH = 36;
const DEFAULT_RENDER_WIDTH = 80;

function terminalWidth(): number {
  return Math.max(MIN_RENDER_WIDTH, process.stdout.columns || DEFAULT_RENDER_WIDTH);
}

function charWidth(char: string): number {
  const codePoint = char.codePointAt(0) ?? 0;
  return codePoint >= 0x1100 ? 2 : 1;
}

function visibleWidth(value: string): number {
  return Array.from(value).reduce((width, char) => width + charWidth(char), 0);
}

function takeVisible(input: string, maxWidth: number): [string, string] {
  let width = 0;
  let output = "";
  for (const char of Array.from(input)) {
    const nextWidth = width + charWidth(char);
    if (nextWidth > maxWidth) {
      return [output, input.slice(output.length)];
    }
    output += char;
    width = nextWidth;
  }
  return [output, ""];
}

function prefixWidth(line: string): number {
  const prefix =
    line.match(/^((?:🔴|🟠|🟢|🟡)\s+(?:>\s+)?(?:\[[^\]]+\]\s+){1,2})/)?.[1] ??
    line.match(/^((?:🔴|🟠|🟢|🟡)\s+)/)?.[1] ??
    line.match(/^(\d{4}-\d{2}-\d{2}\s+—\s+)/)?.[1] ??
    line.match(/^(\[[^\]]+\]\s+[^:]+:\s+)/)?.[1] ??
    line.match(/^(\s+)/)?.[1] ??
    "";
  return visibleWidth(prefix);
}

function wrapLine(line: string, width: number): string[] {
  const availableWidth = Math.max(12, width - visibleWidth(LEFT_MARGIN));
  if (visibleWidth(line) <= availableWidth) {
    return [`${LEFT_MARGIN}${line}`];
  }

  const continuationIndent = `${LEFT_MARGIN}${" ".repeat(prefixWidth(line))}`;
  const firstWidth = availableWidth;
  const continuationWidth = Math.max(12, width - visibleWidth(continuationIndent));
  const output: string[] = [];
  let remaining = line.trimEnd();
  let currentIndent = LEFT_MARGIN;
  let currentWidth = firstWidth;

  while (remaining) {
    if (visibleWidth(remaining) <= currentWidth) {
      output.push(`${currentIndent}${remaining}`);
      break;
    }

    const [hardSlice] = takeVisible(remaining, currentWidth);
    const breakIndex = Math.max(hardSlice.lastIndexOf(" "), hardSlice.lastIndexOf("—"));
    const splitAt = breakIndex > 8 ? breakIndex + 1 : hardSlice.length;
    output.push(`${currentIndent}${remaining.slice(0, splitAt).trimEnd()}`);
    remaining = remaining.slice(splitAt).trimStart();
    currentIndent = continuationIndent;
    currentWidth = continuationWidth;
  }

  return output;
}

function formatLine(line: string, width = terminalWidth()): string[] {
  return wrapLine(line, width);
}

function withoutLeadingLabel(lines: string[], label: string): string[] {
  return lines[0] === `${label}:` ? lines.slice(1) : lines;
}

function compactSections(vm: DashboardViewModel): Array<{ title: string; lines: string[]; panel: DashboardViewModel["activePanel"] }> {
  if (vm.activePanel === "activity") {
    return [
      { title: "Projects", lines: vm.projectLines, panel: "projects" },
      { title: "Lifecycle", lines: withoutLeadingLabel(vm.lifecycleLines, "Lifecycle"), panel: "activity" },
      { title: "Checklist instances", lines: withoutLeadingLabel(vm.checklistInstanceLines, "Checklist instances"), panel: "activity" },
      { title: "Tasks", lines: withoutLeadingLabel(vm.activityLines, "Tasks"), panel: "activity" }
    ];
  }
  if (vm.activePanel === "audits") {
    return [
      { title: "Projects", lines: vm.projectLines, panel: "projects" },
      { title: "Audits", lines: withoutLeadingLabel(vm.auditsLines, "Audits"), panel: "audits" }
    ];
  }
  if (vm.activePanel === "diagnostics") {
    return [{ title: "Diagnostics", lines: vm.diagnosticsLines, panel: "diagnostics" }];
  }
  return [
    { title: "Projects", lines: vm.projectLines, panel: "projects" },
    { title: "Specs", lines: vm.specLines, panel: "specs" }
  ];
}

export function renderDashboardText(vm: DashboardViewModel): string {
  const width = terminalWidth();
  const lines = [...formatLine(statusLine(vm), width), ""];
  for (const section of compactSections(vm)) {
    lines.push(...formatLine(`${activeMarker(vm, section.panel)} ${section.title}`, width));
    for (const line of section.lines) {
      lines.push(...formatLine(line, width));
    }
    lines.push("");
  }
  return lines.join("\n").trimEnd();
}

type StyleFn = (input: string | number | boolean | TextChunk) => TextChunk;

interface ThemeKit {
  StyledText: new (chunks: TextChunk[]) => StyledText;
  brightGreen: StyleFn;
  brightYellow: StyleFn;
  brightRed: StyleFn;
  white: StyleFn;
}

function plain(text: string): TextChunk {
  return { __isChunk: true, text };
}

function lineColor(line: string, theme: ThemeKit): StyleFn {
  switch (statusColor(line)) {
    case "red": return theme.brightRed;
    case "yellow": return theme.brightYellow;
    case "green": return theme.brightGreen;
  }
  if (line.startsWith(">")) {
    return theme.brightGreen;
  }
  if (line.startsWith("  ")) {
    return theme.white;
  }
  return theme.white;
}

function pushLine(chunks: TextChunk[], line: string, style: StyleFn, width: number): void {
  for (const renderedLine of formatLine(line, width)) {
    chunks.push(style(renderedLine), plain("\n"));
  }
}

function pushSection(chunks: TextChunk[], title: string, lines: string[], active: boolean, theme: ThemeKit, width: number): void {
  const marker = active ? "*" : " ";
  pushLine(chunks, `${marker} ${title}`, active ? theme.brightYellow : theme.white, width);
  for (const line of lines) {
    pushLine(chunks, line, lineColor(line, theme), width);
  }
  chunks.push(plain("\n"));
}

function renderDashboardStyledText(vm: DashboardViewModel, theme: ThemeKit): StyledText {
  const chunks: TextChunk[] = [];
  const width = terminalWidth();

  pushLine(chunks, statusLine(vm), theme.white, width);
  chunks.push(plain("\n"));

  for (const section of compactSections(vm)) {
    pushSection(chunks, section.title, section.lines, vm.activePanel === section.panel, theme, width);
  }
  return new theme.StyledText(chunks);
}

export async function mountOpenTuiDashboard(
  data: DashboardData,
  initialState: DashboardViewState = DEFAULT_DASHBOARD_VIEW_STATE
): Promise<void> {
  const {
    createCliRenderer,
    TextRenderable,
    StyledText,
    brightGreen,
    brightYellow,
    brightRed,
    white
  } = await import("@opentui/core");
  const theme: ThemeKit = {
    StyledText,
    brightGreen,
    brightYellow,
    brightRed,
    white
  };

  const renderer = await createCliRenderer({
    exitOnCtrlC: false,
    screenMode: "alternate-screen"
  });

  let state = initialState;
  const text = new TextRenderable(renderer, {
    content: renderDashboardStyledText(buildDashboardViewModel(data, state), theme),
    selectable: false
  });

  const repaint = () => {
    text.content = renderDashboardStyledText(buildDashboardViewModel(data, state), theme);
  };

  renderer.root.add(text);

  const destroy = () => {
    try {
      renderer.destroy();
    } catch {
      // Ignore cleanup errors so interrupt handling remains deterministic.
    }
  };

  renderer.keyInput.on("keypress", (key: { name?: string; sequence?: string; raw?: string; ctrl?: boolean; shift?: boolean }) => {
    const isQuit = key.name === "q" || key.name === "escape" || (key.ctrl && key.name === "c");
    if (isQuit) {
      destroy();
      process.exit(0);
    }

    state = reduceDashboardViewState(data, state, key);
    repaint();
  });

  process.on("SIGINT", () => {
    destroy();
    process.exit(130);
  });
}
