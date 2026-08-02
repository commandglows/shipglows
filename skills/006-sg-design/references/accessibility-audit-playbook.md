---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-07-15"
updated: "2026-07-15"
status: active
source_skill: 006-sg-design
scope: accessibility-audit
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/006-sg-design/references/component-system-audit-playbook.md
  - skills/references/design-system-token-contract.md
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.0.0"
    required_status: active
supersedes:
  - skills/409-sg-audit-a11y/SKILL.md
  - skills/409-sg-audit-a11y/references/accessibility-audit-workflow.md
evidence:
  - "Migrated and revalidated from 409-sg-audit-a11y on 2026-07-15."
next_step: "/103-sg-verify accessibility audit"
---

# Accessibility Audit Playbook

## Activation And Scope

Use for `006-sg-design audit a11y [scope]`.

- no scope: full project audit
- file/route scope: deep audit the named component or surface
- `global`: explicit selected-project audit and systemic synthesis

The audit targets WCAG 2.2 A/AA, notes relevant AAA criteria, and checks custom interaction patterns against W3C APG behavior. WCAG 3/APCA may be a forward-looking note but must not replace or fail a WCAG 2.2 conformance judgment.

Audit source is read-only. Operational records may be written only through the active lifecycle and traffic-first record contract after re-reading the target.

## Context Probes

Inventory semantic landmarks/headings, images/media, forms and labels, custom roles, dialogs/popovers, live regions, keyboard handlers, tabindex, focus styles, reduced motion, drag/drop, help surfaces, and custom Flutter interaction widgets. Identify native/headless primitives before judging custom code. Visual screenshots alone never prove accessibility.

## Project Audit — Ten Phases

### 1. WCAG 2.2 Complete Scan

Verify every applicable A/AA criterion, grouped by:

- **Perceivable:** non-text alternatives, media alternatives, relationships/semantics, meaningful order, orientation, input purpose, color independence, text/non-text contrast, 200% resize, 320px reflow, text spacing, and hover/focus content
- **Operable:** keyboard access, no trap, shortcut control, bypass blocks, page title, focus order/purpose/visibility/appearance, pointer cancellation, label-in-name, motion alternatives, dragging alternatives, and target size
- **Understandable:** page/part language, no unexpected context change, consistent help, text-identified errors, visible labels/instructions, suggestions, redundant-entry avoidance, and accessible authentication
- **Robust:** name/role/value/state and announced status messages

For every failure report `file:line`, criterion ID, user impact, severity, and a standards-aligned remediation route.

Key numeric checks include 4.5:1 normal text contrast, 3:1 large text and UI/non-text contrast, focus indicator area equivalent to at least a 2px perimeter with 3:1 adjacent contrast, 24x24 CSS px minimum target with spacing/offset exceptions, and 44x44 recommended primary touch targets. Preserve the exact criterion exceptions when applying thresholds.

### 2. Keyboard Patterns

Check native behavior first, then custom APG contracts:

- buttons: Enter and Space; links: Enter
- checkbox/switch: Space; radio: arrows within one tab stop
- menu/menubar: open keys, arrows, Home/End, Escape, submenu movement, typeahead
- tabs: one tab stop, arrows, Home/End, automatic or explicit activation
- combobox/listbox: popup ownership, active option, arrows, Enter, Escape, selection semantics
- dialog: intentional initial focus, contained Tab/Shift+Tab, Escape where allowed, return focus
- tree/grid/slider/toolbar: pattern-specific arrows, Home/End, Page keys, selection, and one coherent tab stop

List implemented and missing behaviors for every detected custom primitive. Missing mandatory behavior is a violation, not a suggestion.

### 3. Focus Management

Verify focus trap only where modal behavior requires it, roving tabindex for composite widgets, virtual focus through `aria-activedescendant` where appropriate, logical DOM/traversal order, and focus restoration after close/navigation. Check focus is neither lost nor moved unexpectedly during async updates.

### 4. Semantics And ARIA

Prefer native semantics. For custom patterns verify accessible name, role, state, property, ownership, relationships, and valid references. Audit combobox, menu, dialog, tabs, listbox, grid, tree/treegrid, slider/spinbutton, toolbar, tooltip, switch, disclosure/accordion, carousel, and feed against the applicable APG pattern.

Do not add ARIA that conflicts with native semantics. Link findings to the exact WCAG criterion or APG pattern in detailed reports.

### 5. Live Regions And Dynamic State

Verify polite status updates, assertive/alert errors only when interruption is justified, live regions present before their content changes, no double announcement, sensible atomic/relevant behavior, and loading/saved/error states that do not rely on visual change alone.

### 6. Screen-Reader Output

For each custom interactive element, derive what a screen reader announces: name, role, value/state, position, instructions, and description. Check name precedence (`aria-labelledby`, `aria-label`, native/text alternatives), visible-label consistency for voice control, and state properties such as pressed, checked, expanded, selected, disabled, and current.

Static reasoning identifies likely defects; claim real assistive-technology compatibility only with the corresponding VoiceOver, NVDA, JAWS, TalkBack, or platform evidence.

### 7. Focus Appearance

Verify every focusable control has an unclipped visible indicator across light/dark/high-contrast states and 200% zoom. Flag `outline: none/0` without a proven replacement and focus styling that appears only for pointer interaction.

### 8. Target Size

Check minimum target geometry, spacing/offset exceptions, inline-link exemptions, icon-button padding, and primary mobile touch targets. Do not infer hit area from icon dimensions alone.

### 9. Dragging And Pointer Alternatives

Every drag-to-reorder, drag-to-resize, path gesture, or canvas placement needs a non-drag single-pointer/keyboard alternative. Sliders need keyboard operation; sortable items need actions such as move up/down or an equivalent accessible control.

### 10. Consistent Help

Help/contact/chat/FAQ/self-service mechanisms must remain in a consistent relative location across relevant pages. Distinguish a truly absent mechanism from one moved behind an inconsistent interaction.

## Flutter Mapping

For Flutter, verify `Semantics` labels/roles/values/states on custom controls, `ExcludeSemantics` for duplicate decoration, `MergeSemantics` for compound announcements, `Focus`/`FocusNode`/`FocusScope`/traversal groups, `Shortcuts` + `Actions`, and `SemanticsService.announce` only when a live announcement is warranted.

Flag custom `GestureDetector` or `InkWell` controls that lack semantics, keyboard/focus behavior, or minimum hit area. Built-in widgets provide a baseline but still require meaningful labels, state, order, scaling, contrast, and error behavior.

## File And Global Modes

File mode applies all locally provable criteria plus keyboard, focus, ARIA, screen-reader naming, focus appearance, and target size. State which cross-page checks—live-region lifecycle, consistent help, global landmarks/theme modes—remain unproven.

Global mode selects projects explicitly, runs one project audit per selection, and reports systemic patterns without flattening platform-specific risks.

## Severity And Report

- `critical`: A/AA failure that blocks keyboard, screen-reader, or other users from a core action; inaccessible authentication; missing dialog/combobox semantics that makes operation impossible
- `high`: materially degraded operation such as missing focus indicator, ambiguous critical announcement, unannounced important state, or undersized required targets
- `medium`: bounded clarity/polish issue that does not block the task

Report WCAG A/AA failure counts, AAA notes, grades for keyboard, focus, semantics/ARIA, live regions, screen-reader output, focus appearance, target size, dragging, and consistent help, plus blockers, high findings, priority improvements, proof gaps, and chantier potential.

Be appropriately strict: “mostly accessible” is not a conformance result. The quality target for custom primitives is the interaction rigor of mature native/headless systems, not merely the presence of ARIA attributes.

## Design-System Interaction And Stops

Route contrast, focus, target-size, typography, spacing, and motion remediation through the canonical design-system authority. If the authority cannot satisfy WCAG, report a design-system defect rather than prescribing a local bypass.

Stop when scope is not auditable, a required reference contradicts the contract, a safety/auth/production/redaction guardrail would be weakened, or the requested action crosses from audit into unowned remediation. Every stop includes the concrete next owner route.
