---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-12"
updated: "2026-06-12"
status: active
source_skill: 009-sg-skill-build
scope: sync-guidance-overlay-and-merge-pattern
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/600-sg-local-cloud-sync/SKILL.md
  - /home/claude/socialglowz/src/ui/setup/pages/SocialGlowz/components/PostAuthSyncOverlay.vue
  - /home/claude/socialglowz/src/lib/postAuthSyncFeedback.ts
  - /home/claude/socialglowz/src/lib/cloudSync.ts
  - /home/claude/socialglowz/src/lib/cloudSyncDecisions.ts
  - /home/claude/socialglowz/src/lib/cloudSyncQueue.ts
  - /home/claude/socialglowz/src/lib/cloudSync.test.ts
  - /home/claude/socialglowz/src/lib/cloudSyncDecisions.test.ts
  - /home/claude/socialglowz/src/lib/cloudSyncQueue.test.ts
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/spec-driven-development-discipline.md
    artifact_version: "1.5.0"
    required_status: active
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "SocialGlowz implements a post-auth sync overlay with real-time stage feedback, cloud/local decision helpers, payload validation, cloud hydration, local seeding, and a durable retry queue."
  - "Diane requested on 2026-06-12 that SocialGlowz become the reference for the most complete sync tracking and guidance widget, including cloud/local merge and real-time information."
  - "Existing 600-sg-local-cloud-sync references covered doctrine and checklists but not a complete reusable implementation blueprint."
next_review: "2026-06-26"
next_step: "/103-sg-verify sync-guidance-overlay-and-merge-pattern"
---

# Sync Guidance Overlay And Merge Pattern

## Purpose

Preserve the SocialGlowz post-auth sync experience as the canonical ShipGlows reference for local-to-cloud sync guidance.

Use this reference when a product needs a guided sync flow that makes account sign-in, cloud hydration, local seeding, merge decisions, retry state, and final readiness visible to the user in real time.

This is not only a visual widget. It is a full sync trust pattern:

- a user-visible overlay that blocks or guides at the right moments
- explicit sync stages tied to real backend/data operations
- local/cloud decision helpers that prevent silent data loss
- remote payload validation before applying cloud state
- queue-backed retry for local edits made while offline or unauthenticated
- copy that tells the user what is happening without overclaiming
- tests for decision logic, payload filtering, queue durability, and retry behavior

## Canonical Implementation To Inspect

When SocialGlowz source is available, inspect these files before building a similar flow.

- `/home/claude/socialglowz/src/ui/setup/pages/SocialGlowz/components/PostAuthSyncOverlay.vue`
  - Copy or port the overlay anatomy, step rendering, stage-to-status mapping, blocking/success modes, dark-mode token handling, mobile constraints, and accessibility role.
- `/home/claude/socialglowz/src/lib/postAuthSyncFeedback.ts`
  - Copy or port the state machine shape, minimum stage dwell time, ready notice, and restart-surviving success feedback.
- `/home/claude/socialglowz/src/lib/cloudSync.ts`
  - Copy or port the hydration sequence, cloud snapshot validation, local seeding, cloud-wins policy, remembered account id, and post-auth finalize flow.
- `/home/claude/socialglowz/src/lib/cloudSyncDecisions.ts`
  - Copy or port pure decision helpers for empty snapshot, local reuse, and empty-cloud local preservation.
- `/home/claude/socialglowz/src/lib/cloudSyncQueue.ts`
  - Copy or port the durable queue shape, coalesced settings patches, retry triggers, operation keys, and idempotent flush guard.
- `/home/claude/socialglowz/src/lib/cloudSync*.test.ts`
  - Copy or port the proof scenarios before adapting provider-specific implementation.

Do not copy bundles from `dist/`. Use source files only.

## Product Contract

The flow exists because account-backed sync is a trust boundary. Users must not wonder whether their local data disappeared, whether cloud data arrived, whether the app is safe to use, or whether a reload is expected.

Required behavior:

- Start visible feedback before post-auth data work begins.
- Show concrete stages while waiting for cloud state, receiving data, applying data, restarting/reloading, and becoming ready.
- Keep the UI tied to real sync operations, not fixed fake progress.
- Distinguish blocking sync from a short success confirmation.
- Preserve local data when the current auth flow is allowed to seed an empty cloud.
- Prefer cloud state when the account already has data.
- Block or clear unsafe local replay when the local state belongs to another account or has no proven association.
- Validate remote payloads before applying them to local stores.
- Keep sensitive/session data outside normal cloud sync unless a dedicated secure-sync spec exists.
- Queue local edits durably and replay only when auth, provider config, and network state are valid.
- Provide retry/recheck behavior and non-leaky diagnostics for failures.

Avoid:

- claiming "synced" after only a local save
- using a spinner with no concrete stage labels
- wiping local data on sign-up or sign-in without an explicit policy
- treating empty cloud after existing-account sign-in as permission to seed local data automatically
- replaying queued writes into a different remembered account
- applying unvalidated cloud JSON into stores
- syncing cookies, live sessions, tokens, credentials, raw clipboard payloads, or private logs by convenience
- hiding reload/restart behind an unexplained blank screen

## Reference Interaction Anatomy

The SocialGlowz widget is a modal overlay that sits above the app during post-auth sync and then turns into a brief success notice.

```text
Post-auth sync overlay
  -> Teleport/body modal layer
  -> Blocking or success card
     -> Circular status icon
     -> Kicker: sync mode label
     -> Title: current stage
     -> Copy: what is happening now
     -> Step list
        -> waiting server
        -> data received
        -> data applied
        -> restarting
     -> Success state
        -> ready message
        -> auto-dismiss after short dwell
```

The widget should feel like operational guidance, not marketing. It names what the app is doing now, shows which stages are complete, and gives the user confidence that the app is not frozen.

## Stage Model

Use explicit stages. Do not derive user-visible sync state from arbitrary percentages unless the backend exposes real progress.

```ts
type SyncGuidanceStage =
  | "idle"
  | "waitingServer"
  | "dataReceived"
  | "dataApplied"
  | "restarting"
  | "ready";

type SyncGuidanceMode = "blocking" | "success";

type SyncGuidanceState = {
  visible: boolean;
  mode: SyncGuidanceMode;
  stage: SyncGuidanceStage;
};
```

Stage meanings:

| Stage | Meaning | User promise |
| --- | --- | --- |
| `waitingServer` | Auth is complete enough to request the cloud snapshot. | The app is checking the account. |
| `dataReceived` | Cloud response was fetched and parsed enough to decide next steps. | The app received account data. |
| `dataApplied` | Local stores were hydrated, seeded, merged, or cleared according to policy. | The app applied the correct data. |
| `restarting` | A reload/restart is intentionally happening to reinitialize app state. | The app will come back ready. |
| `ready` | The app is usable after sync. | The setup is ready. |

SocialGlowz enforces a minimum stage dwell time so the overlay does not flash too quickly to read. Keep this behavior for trust-sensitive flows, but tie actual stage transitions to real operations.

## Stage Controller Blueprint

The controller should be framework-light and testable. In Vue, SocialGlowz uses a reactive singleton; in other frameworks, use a store, notifier, atom, or state machine.

```ts
const MIN_STAGE_MS = 1000;
const READY_NOTICE_MS = 3000;

const state = reactive<SyncGuidanceState>({
  visible: false,
  mode: "blocking",
  stage: "idle",
});

function beginSyncGuidance() {
  if (state.visible && state.mode === "blocking" && state.stage !== "idle") return;
  setStage("waitingServer", "blocking");
}

async function advanceSyncGuidanceStage(
  stage: Exclude<SyncGuidanceStage, "idle" | "ready">,
) {
  if (!canAdvanceBlockingStage() || state.stage === stage) return;
  await waitForMinimumStageDwell();
  if (!canAdvanceBlockingStage()) return;
  setStage(stage, "blocking");
}

function showReadyNotice() {
  setStage("ready", "success");
  window.setTimeout(resetSyncGuidance, READY_NOTICE_MS);
}
```

Required properties:

- Re-entrant safe: repeated `begin` calls must not restart active blocking feedback.
- Stage dwell: fast backend responses must still be readable.
- Reset path: failures must hide or replace blocking feedback with a recoverable error state.
- Ready notice persistence: if the app reloads, store a one-time ready flag and show success after boot.
- No secret payloads in state: stage state should never contain raw sync data.

## Overlay Component Blueprint

This is the minimum Vue-style component shape to recreate.

```vue
<template>
  <Teleport to="body">
    <Transition name="sync-overlay">
      <div
        v-if="feedback.visible"
        class="sync-overlay"
        role="alertdialog"
        aria-modal="true"
        aria-live="polite"
      >
        <section class="sync-card" :class="`is-${feedback.mode}`">
          <div class="sync-icon-wrap">
            <StatusIcon :stage="feedback.stage" />
          </div>

          <p class="sync-kicker">{{ modeLabel }}</p>
          <h2 class="sync-title">{{ title }}</h2>
          <p class="sync-copy">{{ message }}</p>

          <div class="sync-steps">
            <div
              v-for="step in steps"
              :key="step.key"
              class="sync-step"
              :class="`is-${step.status}`"
            >
              <StepIcon :status="step.status" />
              <span>{{ step.label }}</span>
            </div>
          </div>
        </section>
      </div>
    </Transition>
  </Teleport>
</template>
```

Minimum class contract:

```css
.sync-overlay {}
.sync-card {}
.sync-card.is-blocking {}
.sync-card.is-success {}
.sync-icon-wrap {}
.sync-kicker {}
.sync-title {}
.sync-copy {}
.sync-steps {}
.sync-step {}
.sync-step.is-done {}
.sync-step.is-current {}
.sync-step.is-upcoming {}
```

Map these classes to project tokens. The SocialGlowz implementation uses token-derived backgrounds, borders, text colors, dark-mode overrides, mobile safe-area constraints, and a restrained transition. Preserve the hierarchy, not the exact color values.

## Step Status Mapping

The step list is derived from stage order:

```ts
const blockingOrder = [
  "waitingServer",
  "dataReceived",
  "dataApplied",
  "restarting",
] as const;

function syncStepStatus(
  currentStage: SyncGuidanceStage,
  index: number,
): "done" | "current" | "upcoming" {
  if (currentStage === "ready") return "done";
  const currentIndex = blockingOrder.indexOf(currentStage as any);
  if (index < currentIndex) return "done";
  if (index === currentIndex) return "current";
  return "upcoming";
}
```

Status semantics:

- `done`: completed stage, show check icon and stable success styling.
- `current`: active stage, show spinner or progress affordance.
- `upcoming`: not yet reached, show neutral icon.

Do not mark a step done until the corresponding operation actually completed.

## Copy Contract

Each stage needs:

- short title
- one-sentence explanation
- step label
- blocking/success kicker

Example copy shape:

```json
{
  "auth_sync": {
    "blocking_kicker": "Synchronisation",
    "success_kicker": "Pret",
    "titles": {
      "waitingServer": "Connexion au cloud",
      "dataReceived": "Donnees recues",
      "dataApplied": "Configuration appliquee",
      "restarting": "Redemarrage de l'app"
    },
    "messages": {
      "waitingServer": "Nous verifions les donnees liees a votre compte.",
      "dataReceived": "Le cloud a repondu. L'app prepare la fusion avec l'etat local.",
      "dataApplied": "Les profils, reglages et comptes compatibles sont appliques.",
      "restarting": "L'app se recharge pour repartir avec l'etat synchronise."
    },
    "ready_title": "Synchronisation terminee",
    "ready_message": "Votre espace est pret."
  }
}
```

Use natural localized copy in product code. This reference stays ASCII for portability.

## Data Domain Contract

Before implementing the overlay, list the synced domains. The overlay is useful only when each stage maps to real domain work.

```ts
type SyncDomain = {
  id: string;
  label: string;
  localStore: string;
  cloudStore: string;
  businessKey: string;
  canSeedCloud: boolean;
  canHydrateLocal: boolean;
  canDelete: boolean;
  sensitiveClass: "none" | "personal" | "secret" | "session" | "regulated";
  conflictPolicy: "cloudWins" | "localSeedIfEmpty" | "mergeByKey" | "manualConflict" | "localOnly";
};
```

SocialGlowz-style domains:

| Domain | Cloud behavior | Local behavior | Sensitive boundary |
| --- | --- | --- | --- |
| settings | patch/upsert | localStorage/store preferences | no tokens or sessions |
| profiles | list/upsert/remove | profile store | profile metadata only |
| custom links | list/upsert/remove | per-profile links | validate URLs |
| friends filters | list/set by network | filter store | names are personal data |
| social accounts | list/upsert/remove/active | account store | account labels only, not live cookies |
| active accounts | set active per network | account selection | no provider session payload |

Live login cookies, connected sessions, raw localStorage snapshots for third-party sites, tokens, credentials, and private browser state stay outside normal cloud sync.

## Cloud Snapshot Contract

Fetch all relevant cloud domains in one logical snapshot before deciding whether to hydrate, seed, merge, or clear local state.

```ts
type CloudSnapshot = {
  settings: CloudSettings | null;
  profiles: CloudProfile[];
  customLinks: CloudCustomLink[];
  friendsFilters: CloudFriendFilter[];
  socialAccounts: CloudSocialAccount[];
  activeAccounts: CloudActiveAccount[];
};
```

The snapshot is empty only when every domain is empty or null:

```ts
function isCloudSnapshotEmpty(snapshot: CloudSnapshotShape) {
  return !snapshot.settings
    && snapshot.profiles.length === 0
    && snapshot.customLinks.length === 0
    && snapshot.friendsFilters.length === 0
    && snapshot.socialAccounts.length === 0
    && snapshot.activeAccounts.length === 0;
}
```

Do not treat a partially empty snapshot as empty. A single cloud domain with records means the account already has cloud state and needs a domain-specific hydrate/merge policy.

## Account Association Decision Contract

The core SocialGlowz decision is: local state can be reused only for anonymous users or the same remembered cloud user.

```ts
function canReuseLocalCloudState(options: {
  isAnonymousUser: boolean;
  rememberedUserId: string | null;
  currentUserId: string;
}) {
  return options.isAnonymousUser
    || options.rememberedUserId === options.currentUserId;
}
```

Empty cloud can keep local data only when local reuse is valid or the current flow explicitly allows sign-up seeding:

```ts
function shouldKeepLocalWhenCloudEmpty(options: {
  canReuseLocalState: boolean;
  allowLocalSeedIfEmpty?: boolean;
}) {
  return options.canReuseLocalState
    || options.allowLocalSeedIfEmpty === true;
}
```

Decision table:

| Situation | Decision | User/data reason |
| --- | --- | --- |
| anonymous user after sign-up, cloud empty | seed cloud from local | same flow created local data and account |
| remembered same cloud user, cloud empty | flush queue or seed local | same account association |
| remembered different cloud user | clear queue and cloud-backed local state before applying cloud | blocks cross-account replay |
| existing account with non-empty cloud | cloud wins or domain merge | account already has authority |
| local queue pending for same reusable user | flush before deciding if cloud is still empty | preserves recent local edits |
| cloud non-empty after queue flush | clear queue and apply cloud | avoids stale pre-auth writes |

## Hydration And Merge Sequence

Use this sequence as the default implementation contract.

```text
finalize sign-in
  -> begin sync overlay
  -> fetch authenticated user
  -> read remembered local cloud user id
  -> decide whether local state can be reused
  -> clear unsafe queue if account mismatch
  -> fetch cloud snapshot
  -> advance overlay to dataReceived
  -> if cloud empty and local reuse allowed:
       -> flush pending queue if same reusable user
       -> refetch cloud snapshot
       -> if still empty: seed cloud from local domains
       -> else: clear queue and apply cloud snapshot
     else:
       -> clear queue
       -> if local state belongs to another account: clear cloud-backed local state
       -> apply cloud snapshot
  -> advance overlay to dataApplied
  -> remember cloud user id
  -> restart/reload when app state needs a clean boot
  -> show ready notice after reload
```

This is a high-trust default. A product may choose richer per-domain merge later, but it must keep the same safety properties: no silent wipe, no cross-account replay, no fake synced state, no unvalidated remote data.

## Apply Cloud Snapshot

Applying cloud means replacing or updating local stores through domain-owned APIs. Do not mutate scattered localStorage keys from the sync controller except for cross-domain preferences that already have a documented source.

```ts
function applyCloudSnapshot(snapshot: CloudSnapshot) {
  const settings = asCloudSettings(snapshot.settings);
  applyCloudSettings(settings);
  profilesStore.replaceFromCloud(snapshot.profiles, settings?.activeProfileId);
  customLinksStore.replaceFromCloud(snapshot.customLinks);
  friendsStore.replaceFromCloud(
    snapshot.friendsFilters,
    settings?.friendsFilterEnabled ?? false,
  );
  accountsStore.replaceFromCloud(snapshot.socialAccounts, snapshot.activeAccounts);
}
```

Required store methods:

- `replaceFromCloud(records, context?)`
- `seedCloud()`
- `clearLocal()`
- `enqueue...` or `sync...` mutation helper for local edits

These methods keep sync policy out of UI components.

## Seed Cloud From Local

Seeding cloud from local is allowed only after the empty-cloud and account-association rules pass.

```ts
async function seedCloudFromLocalIfEmpty(snapshot: CloudSnapshot) {
  if (!snapshot.settings) {
    await syncSettingsPatch(readLocalSettingsPatch());
  }

  if (snapshot.profiles.length === 0 && profilesStore.profiles.length > 0) {
    await profilesStore.seedCloud();
  }

  if (snapshot.customLinks.length === 0 && hasLocalCustomLinks()) {
    await customLinksStore.seedCloud();
  }

  if (snapshot.friendsFilters.length === 0 && hasLocalFriendsFilters()) {
    await friendsStore.seedCloud();
  }

  if (snapshot.socialAccounts.length === 0 && accountsStore.accounts.length > 0) {
    await accountsStore.seedCloud();
  }
}
```

Do not seed local default placeholders that the user has not actually customized. SocialGlowz explicitly avoids polluting existing cloud accounts with auto-created local defaults.

## Remote Payload Validation

Remote data is untrusted. Validate shape, identifiers, limits, URLs, enum values, duplicate arrays, and bounded sizes before applying cloud state.

Validation patterns to preserve:

- ids are trimmed, bounded, and match a safe pattern
- network ids use expected lowercase slug shape
- languages match the supported locale shape
- URLs are only `http:` or `https:`
- avatars are bounded and either safe image data URLs or HTTP URLs
- arrays are capped and de-duplicated
- text zoom and numeric settings are finite and inside allowed range
- unsupported fields are ignored, not applied
- malformed records are dropped, not partially trusted

Example shape:

```ts
function asCloudProfiles(value: unknown): CloudProfile[] {
  if (!Array.isArray(value)) return [];
  return value.flatMap((item) => {
    const profile = asCloudProfile(item);
    return profile ? [profile] : [];
  });
}
```

Payload validation is part of the sync security boundary. The overlay can reassure users only if the data path actually rejects malformed cloud state.

## Durable Queue Contract

Local edits made while offline, signed out, provider-unconfigured, or transiently failing need a durable queue.

```ts
type CloudSyncOperation =
  | { type: "settingsPatch"; key: "settings"; patch: CloudSettingsPatch; updatedAt: number; attempts: number }
  | { type: "profileUpsert"; key: `profile:${string}`; profile: CloudProfile; updatedAt: number; attempts: number }
  | { type: "profileRemove"; key: `profile:${string}`; profileId: string; updatedAt: number; attempts: number }
  | { type: "customLinkUpsert"; key: `customLink:${string}`; link: CloudCustomLink; updatedAt: number; attempts: number }
  | { type: "customLinkRemove"; key: `customLink:${string}`; linkId: string; updatedAt: number; attempts: number };
```

Operation requirements:

- stable operation key
- `updatedAt` revision so a later queue item does not get removed by an older completion
- `attempts` count
- idempotent provider mutation or idempotency key where remote writes may repeat
- payload redaction policy for logs
- account/auth/entitlement recheck before flush

Settings patches should coalesce by key:

```ts
if (operation.type === "settingsPatch" && existing.type === "settingsPatch") {
  queue[index] = {
    ...existing,
    patch: { ...existing.patch, ...operation.patch },
    updatedAt: operation.updatedAt,
  };
}
```

Do not let a settings toggle create dozens of obsolete queued writes when the final patch can represent the current truth.

## Queue Flush Contract

Flush only when provider config, auth, and network are valid.

```ts
function canFlushQueue() {
  return isProviderConfigured.value && isAuthenticated.value && isOnline();
}
```

Flush triggers:

- after enqueue
- online event
- window focus
- visibility returns to visible
- periodic timer
- before empty-cloud seeding decision when local state belongs to the same account

Failure behavior:

- failed operations stay in the queue
- attempts increment
- retry is scheduled with backoff or bounded delay
- successful operation removes only the matching key and revision
- queue is cleared when account mismatch makes replay unsafe

The queue is a reliability tool, not a cross-account import tool.

## Sign-In Finalization Flow

Post-auth sync should run through one owner function, not scattered UI callbacks.

```ts
async function finalizeSignIn(options?: {
  email?: string;
  flow?: "signIn" | "signUp";
  reload?: boolean;
  reopenSettings?: boolean;
}) {
  beginSyncGuidance();

  try {
    await hydrateCloudState({
      allowLocalSeedIfEmpty: options?.flow === "signUp",
    });

    if (options?.reload ?? true) {
      await advanceSyncGuidanceStage("restarting");
      queueReadyNotice();
      window.setTimeout(() => window.location.reload(), AUTH_RELOAD_DELAY_MS);
      return;
    }

    showReadyNotice();
  } catch (error) {
    resetSyncGuidance();
    throw error;
  }
}
```

This function owns user feedback, hydration, seed policy, reload, and failure reset. Login views, settings sheets, and signup nudges should call it instead of duplicating sync logic.

## Error And Recovery States

SocialGlowz currently resets the blocking overlay on thrown error and lets the caller show the auth/settings error. Future implementations should preserve the same separation and may add explicit error UI.

Minimum error contract:

- stop blocking overlay on failure
- keep queued operations if retry is safe
- clear queue if account mismatch makes retry unsafe
- show an error outside the overlay with a retry/recheck action
- distinguish provider unavailable, offline, auth denied, invalid payload, conflict, and tenant mismatch when possible
- never dump raw payloads, tokens, cookies, or private user data into visible errors or logs

Optional richer overlay states:

```ts
type SyncGuidanceStage =
  | "idle"
  | "waitingServer"
  | "dataReceived"
  | "dataApplied"
  | "restarting"
  | "ready"
  | "blocked"
  | "retrying"
  | "conflict";
```

Add these only when they are tied to real recovery actions.

## Accessibility And Visual Requirements

The overlay should:

- use `role="alertdialog"` or an equivalent modal role when it blocks interaction
- use `aria-modal="true"` while blocking
- use `aria-live="polite"` for stage updates
- keep stage labels visible, not icon-only
- preserve readable dwell time
- support dark mode
- respect mobile safe areas and bottom navigation space
- keep content within viewport with scroll when needed
- avoid full-screen blanking during restart
- use project design tokens for color, radius, shadow, spacing, and motion
- avoid one-off hardcoded design values unless they are project tokens or named platform constants

For a non-blocking success notice, ensure it does not steal focus from the next user task unless the product needs confirmation.

## Product Copy Rules

Good sync copy:

- says what data class is moving: profiles, preferences, lists, settings, drafts
- says what remains local: sessions, cookies, secrets, device-only state
- says when a restart/reload is expected
- uses calm operational language
- avoids claiming cloud backup until remote write and hydration are proven

Avoid:

- "Everything is synced" when sessions or secrets remain local
- "Backup complete" after local-only save
- "Merging" when the product is actually applying cloud-priority replacement
- "Secure cloud sync" without naming what is excluded and what is protected
- technical provider errors without a next action

## Implementation Checklist

Before coding:

- list sync domains and sensitive classes
- define remote authority and local durability
- define account association and empty-cloud rules
- define whether sign-up may seed local data
- define cloud-priority, local-seed, merge-by-key, or conflict policy per domain
- define queue operations and idempotency
- define invalid payload behavior
- define user-visible stages and copy
- define reload/restart needs
- define proof path and tests

During implementation:

- create pure decision helpers first
- add payload validators before applying cloud data
- add durable queue before UI claims retry/sync
- wire store methods: `replaceFromCloud`, `seedCloud`, `clearLocal`
- create one sign-in finalizer
- attach overlay globally at app shell/root
- persist one-time ready notice when reload occurs
- keep provider-specific code behind adapters or client helpers

After implementation:

- test decision helpers
- test payload validation
- test queue coalescing and retry
- test sign-up empty-cloud seeding
- test existing-account cloud-priority
- test remembered different account clearing/replay block
- smoke the overlay stage sequence
- update product docs and public claims

## Required Tests

Minimum scenarios:

- `snapshot-empty-detection`: null settings plus empty arrays is empty; any populated domain is non-empty.
- `same-user-local-reuse`: anonymous or remembered same user may reuse local state.
- `different-user-replay-block`: remembered different user cannot replay local queue into current account.
- `signup-empty-cloud-seed`: sign-up flow with empty cloud can seed local data.
- `existing-cloud-hydrate`: non-empty cloud applies cloud state and clears stale queue.
- `pending-queue-flush-before-seed`: same-user pending queue flushes before deciding cloud is still empty.
- `settings-patch-coalesces`: consecutive settings patches merge into one queued operation.
- `failed-operation-retries`: failed operation increments attempts and stays queued.
- `malformed-cloud-records-filtered`: invalid ids, URLs, enum values, duplicates, and oversize fields do not enter stores.
- `overlay-stage-order`: stages advance waitingServer -> dataReceived -> dataApplied -> restarting -> ready.
- `ready-notice-survives-reload`: queued ready notice shows after reload and auto-dismisses.

Example decision test:

```ts
expect(canReuseLocalCloudState({
  isAnonymousUser: false,
  rememberedUserId: "u1",
  currentUserId: "u2",
})).toBe(false);
```

Example queue test:

```ts
enqueueSettingsPatch({ language: "fr" });
enqueueSettingsPatch({ theme: "dark" });

expect(readQueue()).toMatchObject([
  { type: "settingsPatch", patch: { language: "fr", theme: "dark" } },
]);
```

Example overlay proof:

```ts
beginSyncGuidance();
await advanceSyncGuidanceStage("dataReceived");
await advanceSyncGuidanceStage("dataApplied");

expect(feedback.stage).toBe("dataApplied");
expect(feedback.visible).toBe(true);
expect(feedback.mode).toBe("blocking");
```

## Provider And Backend Requirements

Provider-specific work still needs fresh official docs when SDK behavior controls correctness. This reference does not remove that gate.

Check:

- authenticated user id source
- anonymous vs permanent user semantics
- provider-side authorization rules
- mutation idempotency
- offline behavior and retry semantics
- server timestamp availability
- conflict metadata availability
- delete/tombstone support
- rate limits and payload limits
- tenant/org path rules

The client overlay is never the security boundary. Remote writes must still be authorized by provider/server rules.

## Do Not Ship Weak Sync Guidance

Block or revise when any of these are true:

- the widget is only a spinner with no stage labels
- stage labels are not tied to real operations
- local data can disappear on auth transition
- existing-account empty cloud seeds local data without explicit policy
- remembered different account can replay queued writes
- remote payload is applied without validation
- queue retry can write under stale auth
- "synced" appears before durable remote success criteria
- cloud and local merge policy is not named
- sensitive/session data is synced by convenience
- reload/restart happens without user-visible explanation
- tests cover UI rendering but not decision, payload, queue, and account-boundary logic
- public copy promises reinstall recovery without write-and-hydrate proof

## Relationship To Existing References

Use this guide as the high-detail implementation pattern.

Keep the shorter references for focused checks:

- `local-cloud-sync-doctrine.md`: decision matrices and core doctrine.
- `ux-security-checklist.md`: UX states, sensitive-data policy, tenant/account boundaries, logging, and abuse.
- `flutter-implementation-checklist.md`: Flutter/Riverpod proof order.

When a future app asks for "the SocialGlowz sync widget", load this guide first, then load the shorter reference that matches the risk or stack.

## Documentation Impact

When this pattern is used in a product, update or audit:

- feature pages that claim cloud sync, backup, or reinstall recovery
- pricing/plan copy for sync scope
- privacy policy and data retention notes
- account creation/sign-in support docs
- backup/export/import docs
- troubleshooting for pending, retrying, conflict, blocked, and offline states
- screenshots or videos that show the sync overlay
- manual QA checklist for auth transition and reload

Public copy must name what sync covers and what remains local. SocialGlowz is explicit that profiles, app preferences, links, filters, and account labels sync, while live cookies and connected sessions remain local unless a separate encrypted backup/export flow is used.
