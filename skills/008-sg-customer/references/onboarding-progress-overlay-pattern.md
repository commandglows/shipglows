---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-06-12"
updated: "2026-06-12"
status: active
source_skill: 009-sg-skill-build
scope: onboarding-progress-overlay-pattern
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/008-sg-customer/SKILL.md
  - /home/claude/winflowz/winflowz_app/lib/features/shell/presentation/app_shell_screen.dart
  - /home/claude/winflowz/winflowz_app/lib/features/settings/domain/onboarding_permission_contract.dart
  - /home/claude/temu/src/ui/temu-shell/components/TemuOnboardingOverlay.vue
  - /home/claude/temu/src/stores/shoppingSessions.ts
depends_on:
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.0.0"
    required_status: active
  - artifact: skills/references/spec-driven-development-discipline.md
    artifact_version: "1.5.0"
    required_status: active
supersedes:
  - skills/008-sg-customer/references/onboarding-playbook.md
evidence:
  - "WinFlowz onboarding uses a popup-style setup overlay with progress icons, recoverable permission/setup modules, current/completed/skipped/blocked states, and settings recovery."
  - "Temu Shopping Lists port proved the same onboarding overlay can transfer from Flutter to Vue/Tauri when adapted to product-specific value moments."
  - "Diane requested on 2026-06-12 that this onboarding pattern be preserved as a reusable reference for future applications, with enough structure for agents to recreate it precisely."
next_review: "2026-06-26"
next_step: "/103-sg-verify onboarding-progress-overlay-pattern"
---

# Onboarding Progress Overlay Pattern

## Purpose

Preserve the WinFlowz and Temu onboarding popup as a reusable product-activation reference.

Use this reference when an application needs the same kind of first-run or resumable onboarding: a modal/popup overlay with sections, one colored icon per section, clear why/how guidance, safe skip/defer controls, progress state, and a resume path.

This is more than a checklist. It is the canonical onboarding blueprint for this interaction family. Future agents should be able to recreate the same structure from this file, then adapt product steps, copy, icons, routes, and design tokens to the target app.

## Canonical Implementations To Inspect

When local source is available, inspect these files before implementing. If the target framework matches one of them, copy the closest implementation shape first, then adapt only the product-specific parts.

- Flutter/WinFlowz:
  - `/home/claude/winflowz/winflowz_app/lib/features/shell/presentation/app_shell_screen.dart`
    - Copy or port the overlay layout, progress dots, active section body, permission/setup rows, footer actions, and recheck/resume behavior.
  - `/home/claude/winflowz/winflowz_app/lib/features/settings/domain/onboarding_permission_contract.dart`
    - Copy or port the readiness evaluator pattern for permission/setup truth.
  - `/home/claude/winflowz/winflowz_app/test/widget_test.dart`
    - Copy or port the status-priority widget assertions.
- Vue/Tauri/Temu:
  - `/home/claude/temu/src/ui/temu-shell/components/TemuOnboardingOverlay.vue`
    - Copy or port the component anatomy, step rendering, progress dot priority, action handling, and footer flow.
  - `/home/claude/temu/src/stores/shoppingSessions.ts`
    - Copy or port persisted dismissed/completed/skipped state.
  - `/home/claude/temu/src/ui/temu-shell/style.css`
    - Copy or port only the class anatomy; remap colors, spacing, elevation, and typography through the target design-system authority.

Do not rebuild a vague popup from memory when these source files are available. This pattern was created through product work; preserve its exact interaction model.

## Product Contract

The overlay must help the user reach first success, not merely dismiss an introduction.

Required behavior:

- Open from a meaningful trigger: first launch, first feature discovery, settings resume, post-update activation, or support recovery.
- Split setup into narrow independent sections.
- Give each section one recognizable icon and one visible status.
- Explain both value and action for each section.
- Keep required setup, optional enhancers, and expert shortcuts distinct.
- Let users skip or defer optional sections without punishment.
- Keep skipped sections visible and recoverable.
- Recheck state after external settings, permissions, auth, native handoffs, or lifecycle resume.
- Persist enough state to avoid nagging users after they defer or complete the flow.
- Provide a resume path from settings, support, or an equivalent product surface.

Avoid:

- permission coercion or fake urgency
- hidden privacy, billing, data sync, or native permission consequences
- treating a skipped optional section as truly enabled
- all-in-one setup screens that hide current state
- styling copied outside the target design-system authority
- intro-only carousels with no product truth, no completion state, and no recovery

## Exact Popup Anatomy

Use this structure unless the target platform has a strong native convention that requires an equivalent shape.

```text
Onboarding overlay / popup
  -> Backdrop / modal layer
  -> Popup card or sheet
     -> Header
        -> small product/setup label
        -> title naming the setup or first-success goal
        -> close/defer icon button
     -> Progress sections row
        -> one circular icon button per step
        -> status color on the circle
        -> short section label below or beside the icon
     -> Active section body
        -> large colored icon matching current step
        -> group/category label
        -> section title
        -> concise description
     -> Why/action panel
        -> "why it matters" explanation
        -> current status badge or blocker text
        -> primary action button
        -> secondary refresh/recheck link when external state can change
     -> Footer
        -> skip/defer button for optional steps
        -> previous/next or continue/finish button
```

The popup may be centered on desktop and bottom-sheet-like on mobile, but the hierarchy stays the same: header, progress icons, active section, why/action, footer.

## Step Data Contract

Each onboarding step should be plain enough to test without rendering the full UI.

```ts
type OnboardingStep = {
  id: string;
  group: string;
  title: string;
  description: string;
  why: string;
  icon: string;
  actionIcon?: string;
  actionLabel: string;
  completed: boolean;
  skipped: boolean;
  supported?: boolean;
  blockerReason?: string;
  routeName?: string;
  deepLink?: string;
  action?: () => Promise<void> | void;
};
```

Framework-specific models can replace `icon`, `routeName`, or `action` with native enum values, callbacks, routes, permission ids, command names, or typed component references. Keep `completed`, `skipped`, `supported`, and `blockerReason` readable and testable.

Recommended step fields:

- `id`: stable key for persistence and tests.
- `group`: category such as Voice, Shopping, Sync, Import, Keyboard, Account, Support.
- `title`: concrete feature label.
- `description`: what the user will enable or learn.
- `why`: value and consequence in user language.
- `icon`: one recognizable icon for the progress dot and active body.
- `actionLabel`: verb-first CTA tied to a real action.
- `completed`: derived from product truth.
- `skipped`: derived from user choice.
- `supported`: false when the platform, plan, provider, or OS cannot support the step.
- `blockerReason`: human-readable reason and recovery path.

## State Priority

State priority is non-negotiable:

1. `skipped`, `rejected`, or explicit refusal: danger/red state.
2. `completed` or `satisfied`: success/green state.
3. `current` and not completed: active/current orange state.
4. `blocked` or `unsupported`: warning/danger variant with visible explanation.
5. `pending` or unavailable information: neutral gray state.

Completed state wins over current state. If the user is currently on the microphone, shopping import, sync, account, keyboard, or setup page and the requirement becomes satisfied, the icon turns green immediately. It must not wait for "Next" or for the user to change pages.

Skipped state is separate from completed state. It may count as resolved for navigation or final dismissal, but it must remain visually distinct and recoverable.

Do not reverse `completed` and `current`. That was the WinFlowz bug fixed on 2026-06-12.

## Status Priority Snippets

Framework-neutral:

```ts
function stepStatus(step: OnboardingStep, isCurrent: boolean): "skipped" | "completed" | "current" | "blocked" | "pending" {
  if (step.skipped) return "skipped";
  if (step.completed) return "completed";
  if (step.supported === false || step.blockerReason) return "blocked";
  if (isCurrent) return "current";
  return "pending";
}

function statusClass(step: OnboardingStep, isCurrent: boolean): string {
  return `is-${stepStatus(step, isCurrent)}`;
}
```

Vue shape:

```ts
function dotClass(step: OnboardingStep): string {
  if (step.skipped) return "is-skipped";
  if (step.completed) return "is-completed";
  if (step.supported === false || step.blockerReason) return "is-blocked";
  if (step.id === activeStep.value.id) return "is-current";
  return "is-pending";
}
```

Flutter shape:

```dart
Color dotColor({
  required bool skipped,
  required bool satisfied,
  required bool blocked,
  required bool isCurrent,
  required Color pending,
}) {
  if (skipped) return AppColors.danger;
  if (satisfied) return AppColors.success;
  if (blocked) return AppColors.warning;
  if (isCurrent) return AppColors.warning;
  return pending;
}
```

## Vue Component Blueprint

This is the minimum shape future Vue/Tauri or Vue web implementations should recreate. Use project-local components and tokens where available.

```vue
<template>
  <div v-if="visible" class="onboarding-overlay" role="dialog" aria-modal="true" :aria-labelledby="titleId">
    <section class="onboarding-popup">
      <header class="onboarding-header">
        <div>
          <p class="onboarding-kicker">{{ productLabel }}</p>
          <h2 :id="titleId">{{ title }}</h2>
        </div>
        <button class="icon-button" type="button" :aria-label="closeLabel" @click="dismiss">
          <XIcon aria-hidden="true" />
        </button>
      </header>

      <nav class="onboarding-progress" :aria-label="progressLabel">
        <button
          v-for="step in steps"
          :key="step.id"
          class="onboarding-dot"
          :class="dotClass(step)"
          type="button"
          :aria-current="step.id === activeStep.id ? 'step' : undefined"
          :aria-label="statusLabel(step)"
          @click="selectStep(step.id)"
        >
          <component :is="step.icon" aria-hidden="true" />
          <span>{{ step.group }}</span>
        </button>
      </nav>

      <main class="onboarding-body">
        <div class="onboarding-step-icon" :class="dotClass(activeStep)">
          <component :is="activeStep.icon" aria-hidden="true" />
        </div>
        <p class="onboarding-step-group">{{ activeStep.group }}</p>
        <h3>{{ activeStep.title }}</h3>
        <p>{{ activeStep.description }}</p>
      </main>

      <aside class="onboarding-action-panel">
        <p>{{ activeStep.why }}</p>
        <span class="status-badge" :class="dotClass(activeStep)">
          {{ statusText(activeStep) }}
        </span>
        <button class="primary-button" type="button" @click="runPrimaryAction(activeStep)">
          <component v-if="activeStep.actionIcon" :is="activeStep.actionIcon" aria-hidden="true" />
          <span>{{ activeStep.actionLabel }}</span>
        </button>
        <button v-if="canRefresh(activeStep)" class="text-button" type="button" @click="refreshState">
          {{ refreshLabel }}
        </button>
      </aside>

      <footer class="onboarding-footer">
        <button v-if="canSkip(activeStep)" class="secondary-button" type="button" @click="skipStep(activeStep.id)">
          {{ skipLabel }}
        </button>
        <button class="primary-button" type="button" @click="goNextOrFinish">
          {{ nextOrFinishLabel }}
        </button>
      </footer>
    </section>
  </div>
</template>
```

Minimum CSS class contract:

```css
.onboarding-overlay {}
.onboarding-popup {}
.onboarding-header {}
.onboarding-progress {}
.onboarding-dot {}
.onboarding-dot.is-pending {}
.onboarding-dot.is-current {}
.onboarding-dot.is-completed {}
.onboarding-dot.is-skipped {}
.onboarding-dot.is-blocked {}
.onboarding-body {}
.onboarding-step-icon {}
.onboarding-action-panel {}
.onboarding-footer {}
```

Do not hardcode one-off colors. Map `is-current`, `is-completed`, `is-skipped`, `is-blocked`, and `is-pending` to project tokens.

## Flutter Widget Blueprint

Recreate this hierarchy for Flutter apps. Use existing app tokens and widgets.

```dart
class OnboardingOverlay extends StatelessWidget {
  const OnboardingOverlay({
    super.key,
    required this.steps,
    required this.activeStepId,
    required this.onSelectStep,
    required this.onRunAction,
    required this.onSkip,
    required this.onDismiss,
    required this.onNextOrFinish,
    required this.onRefresh,
  });

  final List<OnboardingStep> steps;
  final String activeStepId;
  final ValueChanged<String> onSelectStep;
  final ValueChanged<OnboardingStep> onRunAction;
  final ValueChanged<String> onSkip;
  final VoidCallback onDismiss;
  final VoidCallback onNextOrFinish;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final active = steps.firstWhere((step) => step.id == activeStepId);

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _OnboardingHeader(onDismiss: onDismiss),
          _OnboardingProgressDots(
            steps: steps,
            activeStepId: activeStepId,
            onSelectStep: onSelectStep,
          ),
          _OnboardingActiveStep(step: active),
          _OnboardingActionPanel(
            step: active,
            onRunAction: () => onRunAction(active),
            onRefresh: onRefresh,
          ),
          _OnboardingFooter(
            step: active,
            onSkip: () => onSkip(active.id),
            onNextOrFinish: onNextOrFinish,
          ),
        ],
      ),
    );
  }
}
```

Required widget responsibilities:

- `_OnboardingProgressDots`: owns visual state priority and accessible labels.
- `_OnboardingActiveStep`: mirrors the selected step with large icon, group, title, description.
- `_OnboardingActionPanel`: shows why text, status badge, primary action, and refresh/recheck.
- `_OnboardingFooter`: skip/defer plus next/finish.

## Behavior Sequence

Opening:

- If there is an unresolved non-skipped step, open on the first one.
- If all steps are completed or skipped, do not auto-open unless the user explicitly resumes from settings/support.
- If a previously selected step is still unresolved, reopening may restore it.

Selecting:

- Progress icons are clickable when the platform pattern allows it.
- Selecting a completed step still shows it as green.
- Selecting a skipped step shows the skipped state and the recovery action.

Primary action:

- If the action is local, run it and refresh product truth without closing the overlay unless the action itself is the final success moment.
- If the action leaves the app, persist resume context and recheck on lifecycle return.
- If the action opens a settings/provider/native page, show a refresh/recheck path when the user returns.

Next/finish:

- `Next` moves to the next unresolved step.
- Completed steps remain green while selected.
- Skipped steps remain red or explicit skipped state while selected.
- `Finish` appears when all required steps are complete and optional unresolved steps are skipped or intentionally deferred.

Skip/defer:

- Skipping an optional step persists the skipped id and moves to the next unresolved step.
- Required steps should normally allow defer, not fake completion.
- A skipped step must be recoverable later.

Dismiss:

- Closing the popup persists a dismissed/deferred state, not completed state.
- The app must expose a resume route unless the whole onboarding is complete.

## Persistence Contract

Persist the user-control layer. Derive capability truth from the product wherever possible.

```ts
type OnboardingProgress = {
  onboardingDismissed: boolean;
  onboardingCompleted: boolean;
  onboardingSkippedStepIds: string[];
  lastOnboardingStepId?: string;
};
```

Completed status should usually come from live product truth:

- permission granted
- keyboard active
- account authenticated
- first shopping list created
- first product imported
- sync enabled
- diagnostics available
- notification enabled
- file/camera/microphone access granted

Skipped and dismissed status come from user choice. Do not store fake completion for permissions, auth, billing, account state, native settings, or data sync.

## Copy And Content Contract

Each step needs four pieces of user-facing copy:

- `group`: a short category for the progress row.
- `title`: what this step enables.
- `description`: what the user will do.
- `why`: why this matters and what still works if skipped.

Good copy:

- "Autorise le micro pour dicter dans le clavier."
- "Tu peux creer ta premiere liste maintenant, puis importer des produits plus tard."
- "La connexion sert aux fonctions cloud protegees. L'app reste utilisable sans compte si cette etape est optionnelle."
- "Tu peux reprendre cette configuration depuis les parametres."

Avoid:

- "Required" for optional features.
- "Almost done" when a step is blocked by OS settings or external approval.
- Technical labels without value explanation.
- Permission prompts before explaining value and fallback.
- Shame, pressure, countdowns, or fake urgency.

## Example Step Matrix

WinFlowz-style examples:

| Step | Product truth | Primary action | Completed state | Skipped/deferred state |
| --- | --- | --- | --- | --- |
| Microphone | OS microphone permission granted | Open permission/settings action | green, even while selected | red/deferred with settings recovery |
| Keyboard | WinFlowz keyboard active | Open keyboard setup/settings | green, even while selected | red/deferred with setup recovery |
| Notifications | notification permission granted | Open notification prompt/settings | green, even while selected | red/deferred with explanation |
| Diagnostics | diagnostics/share path available | Open diagnostics/support view | green after available | skipped/recoverable |

Temu-style examples:

| Step | Product truth | Primary action | Completed state | Skipped/deferred state |
| --- | --- | --- | --- | --- |
| First list | at least one shopping list exists | Create list | green, even while selected | optional defer if app allows browsing first |
| Product capture | product saved/imported | Open Temu capture/import action | green after saved | skipped/recoverable |
| Shopping session | active session exists | Start session | green after session starts | skipped/recoverable |
| Organization | labels/priority/filter used | Open organize view | green after configured | skipped/recoverable |

Adapt the labels to the product. Preserve the structure.

## Required Tests

Minimum scenarios:

- `active-completed-stays-success`: select a step, satisfy it, and verify the active icon becomes success/green immediately.
- `skipped-stays-visible`: skip an optional step and verify it remains danger/red or explicit skipped state, not hidden and not green.
- `defer-resume`: close or defer the overlay, then resume it from settings/support.
- `external-refresh`: complete setup outside the app, return, refresh, and verify state updates.
- `all-resolved-completion`: complete or skip all steps and verify the flow reaches completion without claiming skipped steps are enabled.

Example status-priority unit test:

```ts
it("keeps a completed active step in success state", () => {
  const step = {
    id: "microphone",
    completed: true,
    skipped: false,
    supported: true,
  } as OnboardingStep;

  expect(stepStatus(step, true)).toBe("completed");
});
```

For Flutter, prefer widget tests plus Flutter Web smoke when the UI is shared. For Vue/React/web, prefer component/store tests plus Playwright smoke. Reserve native device proof for OS permissions, native WebView, IME, notifications, file pickers, overlays, or provider-native behavior.

## Do Not Ship Amateur Versions

Block or revise the implementation when any of these are missing:

- It is visibly an onboarding popup with sections, not a generic welcome modal.
- Every section has a colored icon with pending/current/completed/skipped/blocked semantics.
- Completed green wins over current orange.
- Skipped state remains visible and recoverable.
- The active section has a title, description, why text, status, and real action.
- External settings/provider/native handoffs have recheck/resume behavior.
- Optional setup can be deferred without fake completion.
- Persistence avoids nagging while preserving real capability truth.
- The design uses project tokens/components, not one-off visual hacks.
- Accessibility covers dialog semantics, focus, keyboard activation, labels, and touch target size.
- Tests cover status priority, skip visibility, defer/resume, and completion.
- Docs/support copy is updated when setup promises or recovery paths change.

## Documentation Impact

When this pattern is used in a product, check impact on:

- README/setup docs
- help/support pages
- settings labels
- FAQ and troubleshooting
- screenshots or app-store/public pages
- changelog/release notes
- manual QA scripts

Public claims must match the onboarding truth. If the app says setup is automatic, the overlay must not reveal manual-only steps. If the overlay says a permission is optional, docs and support must not call it mandatory.
