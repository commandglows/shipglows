---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-20"
updated: "2026-10-20"
status: active
source_skill: 900-shipglows-core
scope: flutter-quality-playbook
owner: Diane
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/flutter-engineering-playbook.md
  - skills/010-sg-technical/references/performance-audit-playbook.md
  - skills/references/product-entitlements-playbook.md
  - skills/references/design-system-token-contract.md
  - skills/references/managed-project-ci-policy.md
  - skills/references/preferred-stacks.md
  - skills/references/flutter-app-zoom.md
  - skills/references/web-image-performance-contract.md
depends_on:
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.6.0"
    required_status: active
  - artifact: skills/references/managed-project-ci-policy.md
    artifact_version: "1.0.0"
    required_status: active
  - artifact: skills/references/product-entitlements-playbook.md
    artifact_version: "2.4.1"
    required_status: active
  - artifact: skills/010-sg-technical/references/performance-audit-playbook.md
    artifact_version: "2.0.0"
    required_status: active
supersedes: []
evidence:
  - "Flutter Agent Skills (MIT License, Copyright (c) 2026 Zakaria Fatahi), installed locally in the Claude plugin cache. Rules were distilled and paraphrased from testing-strategy, widget-golden-and-a11y-testing, seeded-determinism-and-golden-vectors, accessibility-as-code, adaptive-layout, i18n-rtl-l10n, ui-states-and-feedback, forms-and-input, motion-and-haptics, design-system-structure, design-review-workflow, custom-canvas-and-gestures, release-and-store-shipping, ci-pipeline-and-gates, ads-and-iap-monetization, local-notifications-scheduler, data-export-and-restore and value-objects-money-and-units. Nothing was copied wholesale."
  - "Operator correction 2026-10-20: the portfolio uses Flutter, Astro, Tauri and Convex only. Flutter quality rules are ShipGlows-owned; the managed dev server replaces hand-run flutter commands."
  - "Operator directive 2026-10-20: no builds, tests, goldens or analyze unless requested or a bug is confirmed; CI is manual; Git per mutation-git-authority.md."
  - "Operator context 2026-10-20: the portfolio is French-first for copy."
  - "Sibling playbook skills/references/flutter-engineering-playbook.md is being written in parallel; this file links to it by path and does not cover its topics."
next_review: "2026-11-20"
next_step: "/103-sg-verify flutter quality playbook adoption"
---

# Flutter Quality Playbook

## Purpose and when to load

Load for any ShipGlows Flutter surface (Web, Android, iOS, Windows, macOS, Linux) when work touches UX quality: tests and proof, goldens and widget accessibility, determinism of generated content, accessibility, adaptive layout, localization and RTL, UI states, forms, motion and haptics, design system, canvas and gestures, reminders, export and restore, money and units, monetization and entitlements, release, or CI.

Not covered here: architecture, state, async, errors, navigation, persistence, startup, codegen, dependencies and lint. Those live in `skills/references/flutter-engineering-playbook.md`. Performance measurement lives in `skills/010-sg-technical/references/performance-audit-playbook.md` (PHASE 1); do not restate its budgets here.

The MIT-licensed Flutter Agent Skills pack is a source of rules, not an authority. Where it conflicts with a ShipGlows rule, the ShipGlows rule wins.

## Operating overrides

| Pack says | ShipGlows rule |
|---|---|
| `flutter run`, `flutter drive`, `flutter run --profile` by hand | Only `s start -ProjectPath <p> -FlutterDevice windows\|android\|chrome\|web-server`, then `s reload`, `s open`, `s stop`. Profile: `s start ... -FlutterMode profile`. Profile has no hot reload; rebuild with `s restart ... -FlutterMode profile`. |
| Release-build screenshot sweep | Visual proof comes from the running managed session (screenshots; Browser pane for Web). A release-build sweep waits for an operator-approved build. |
| `flutter build` in any form, including `--analyze-size` and `--trace-startup` builds | No builds unless the operator asks. |
| `flutter analyze`, `flutter test`, goldens, pre-PR scripts | Run only when the operator asks or a bug is confirmed. No automatic pre-commit or pre-PR gate. |
| `--update-goldens` | Never silently. Re-bless only through the rebaseline ritual in section 3.1, with operator approval. |
| Pull requests, branches, worktrees, push | Git and GitHub persistence follows `$SHIPGLOWS_ROOT/skills/references/mutation-git-authority.md`; the operator's own instructions (for example no branches, worktrees or pull requests) take precedence. |
| CI on push, pull_request or schedule | Forbidden. CI is manual; `gh workflow run` needs approval. |
| Template `app_en.arb`, English-first copy | Portfolio copy is French-first: the template ARB is French, and English mirrors every key. |
| `Icons.*` and `Icons.adaptive` | Phosphor Regular for functional icons in new ShipGlows work, unless the project's design-system authority records an exception. |
| Rewarded-ads earn loop as a default monetization | Not a default. Suite products follow `product-entitlements-playbook.md`. |
| Cached last-known entitlement keeps owners correct offline | Local state never authorizes premium access. Offline grace is an operator decision. |

## Proof levels

Every claim states its level. A claim without a level is not accepted.

- P0 static: reading code or documents. Proves structure, never behavior.
- P1 managed session: observed in a session started by `s` (screenshot, Browser pane, logs). Proves rendering and flow on that target only.
- P2 test run: `package:test` or `flutter_test` actually executed. Only on request or for a confirmed bug. Otherwise write "test exists at `<path>`, not run".
- P3 release artifact: the installed build on real hardware. Operator-approved builds only.
- P4 store read-back: store state queried after the write. Required before any submission claim.

For any app-running claim, report four facts separately: configuration checked (`.shipglows.flutter.json`, its Doppler scope and public defines), app running (the session), login verified (authorized test context), protected access verified (a protected screen or query returns data). Never infer login from a successful build or from a login screen. Backend-dependent launches and tests need `.shipglows.backend.json`. If it is missing, block the dependent claim and ask only for the missing facts.

## 1. Proof mapping

The default column is what must exist in the change. The right column is what runs only on request.

| Change | Default proof | Runs only on request |
|---|---|---|
| Copy or ARB text | P1 screenshot in fr and en; every key and placeholder present in both files | gen-l10n check |
| Pure domain logic (money, recurrence, seeds, allocate) | Named `package:test` file asserting the invariant | P2 run |
| Persistence or migration | Test on `NativeDatabase.memory()`; migration path test | P2 run |
| Notifier or ViewModel | `ProviderContainer` test with fakes | P2 run |
| Layout or adaptive UI | P1 at compact, medium and expanded widths; overflow matrix test present | P2 run; goldens |
| Accessibility | `isSemantics` test; colour-value contrast test; P1 label check | P2 run |
| Export or restore | Round-trip and refusal tests present | P2 run; P3 device rehearsal |
| Entitlement or paywall | Fake-based Notifier tests; server grant and denial proof | P2 run; backend proof |
| Canvas or gestures | P1 with the gesture driven on the target; hit-test unit test | P2 run; profile numbers |
| Release, store, CI | Read-back and config checks | Build, upload, `gh workflow run` |

A test proves a change only if it would fail on the broken behavior. Name the test in the change. A test that cannot fail for the claimed behavior proves nothing.

## 2. Testing strategy

Shape follows the code, not a pyramid.

- Pure `f(input) -> output` logic is tested with `package:test` in a Flutter-free package. Never drive it through `pumpWidget`.
- Time comes from `package:clock`: `clockProvider` in Riverpod code, `withClock` in pure code. Never `DateTime.now()`.
- Every conversion gets a round-trip test and boundary rounding cases. Every universal claim is a seeded fuzz loop checked against an independent oracle, with the generated input echoed in `reason:`.
- The data layer runs on `NativeDatabase.memory()` with `addTearDown(db.close)`. A mocked DAO proves nothing about SQL, constraints or migrations.
- Owned collaborators are bare `implements` fakes, so an interface change breaks compilation. `mocktail` is for external dependencies only, with `registerFallbackValue` for every custom type passed to `any()`. No `mockito`.
- Notifiers are tested headlessly through `ProviderContainer` overrides, disposed in teardown. Never pump a widget to test state.
- Timers run under `fakeAsync`. Never `pumpAndSettle()` on an indefinite animation (splash, shimmer, spinner).
- Authenticated flows use authorized test context: a test account, or a fake session injected by provider override. A bypass flag in product code is forbidden.
- Each app has one acceptance test asserting a realistic scenario to the exact result, plus the conservation invariant. The primitive it relies on carries a runtime `assert` tripwire.
- Coverage is published, never a percentage gate. Include untested files: `flutter test --coverage` omits files no test imports, so the number lies upward. Hold 100% by diff review on files whose bug is silent data loss: migrations, the allocate primitive, the restore parser, the notification reconcile diff.
- Name the manual pass for what no emulator reproduces: real audio, OEM diversity, Switch Access, reboot and Doze reminders, store-delivered builds. Never fake a green test for these.

## 3. Goldens and widget accessibility tests

- Layout is proven by computed geometry (`getSize`, `getRect` inside the computed cell). A golden blesses whatever shipped, clipped text included, so it cannot be the layout gate.
- One `pumpApp` harness is imported by every widget test. Sizes are physical pixels, so multiply by the device pixel ratio, then reset in teardown:

```dart
view.devicePixelRatio = device.dpr;
view.physicalSize = device.logicalSize * device.dpr; // physical, not logical
addTearDown(view.reset);
```

- Layer `MediaQuery` above the app with `copyWith`, never a bare `MediaQueryData()`, or the pinned size is discarded.
- One `testWidgets` per (device, text scale, bold) tuple. Never loop scales inside one test: overflow reports once per RenderObject, so later scales go unchecked.
- Never suppress overflow: no `takeException()` in a teardown, no `ignoreOverflowErrors`, no `FlutterError.onError` override, and no clamp or `FittedBox` used to turn a red matrix green.
- Two golden lanes, both calling `loadAppFonts()`. The Ahem lane is byte-stable and proves geometry and mirroring. The real-font lane runs on one pinned environment and proves glyph shaping, French accents and numerals. Tag every golden `@Tags(['golden'])`.
- RTL goldens pump under `Directionality(textDirection: TextDirection.rtl)`, only when RTL ships (section 7).
- Verify, never bless. Ordinary runs and CI only compare.
- Contrast is computed in pure Dart (WCAG ratio, plus APCA where used) from the theme colour values, for every theme. Never assert contrast from screenshots: the built-in guideline passes white text on near-white.
- `meetsGuideline` returns an async matcher. Always `await expectLater(...)`. Treat it as advisory only: four guidelines, one known broken. It is not an accessibility claim.
- Tap targets: an explicit `getSize` loop asserting at least 44 logical pixels. `meetsGuideline` skips nodes flush with the view edge, so it cannot carry this claim alone.
- Finders: `find.bySemanticsLabel` for behavior, `find.byKey` for geometry. Never `find.byType` for behavior.

### 3.1 Rebaseline ritual

Only on an explicit operator request. Read the golden diff image by image. Classify each change as intended (the design moved on purpose) or regression (fix the code). Re-bless only in the pinned environment and only the cells the operator approved. Never edit a golden file by hand. Never run `--update-goldens` as a way to get green. The Flutter pack's `run-goldens-rebaseline` describes the mechanics.

## 4. Determinism for generated content

Use this section only for output every device must reproduce from a key: a daily pick, a shareable result, a procedural layout.

- The key is an argument. Nothing on the generation path reads a clock or ambient randomness.
- A calendar-day key is a civil date (`YYYY-MM-DD`), not an instant. One day definition, local or UTC, is named once and used by every comparison.
- Seed: FNV-1a 64-bit hash of the key, XOR per-feature and per-mode salts, a SplitMix64 mix step, feeding a PRNG the repository owns. Never `dart:math` `Random` on this path. Draw order is part of the contract.
- Web: Dart `int` compiles to a JavaScript number, so 64-bit multiplication silently differs there. Either keep the generator out of Web builds behind a native-only import, or implement the hash and PRNG in 32-bit halves. A generator shipped to all six targets uses the 32-bit form.
- Store the key, `generatorVersion` and the outcome. Regenerate the content; never store it.
- A shipped generator is frozen. An improvement ships as a new version with a cutover key, and the old version stays able to reproduce history.
- Pin the generator with a committed vector table of fingerprints. Derive every expected value from an independent oracle, never from the implementation under test. Regenerate only with an explicit, reviewed command. CI verifies and never blesses.
- Banned on the path: `DateTime.now()`, ambient `Random()`, `identityHashCode`, and hash-set iteration order in anything a user sees.

## 5. Accessibility as code

Authored into each widget as it is written. No lint enforces it, so review and widget tests carry it.

- Every interactive node: `Semantics(button: true, label: displayLabel)`. A bare `GestureDetector` is a defect.
- Every `Icon` and `Image`: a `semanticLabel`, or `ExcludeSemantics` when decorative. There is no third option.
- Read `MediaQuery.boldTextOf`, `disableAnimationsOf` and `accessibleNavigationOf` at build time, never from app state. Never gate a feature on `highContrastOf`: it is iOS-only and always false on Android.
- Never clamp the text scaler (`withClampedTextScaling`, `textScaleFactor`). Never use `FittedBox`, a computed `fontSize`, or `TextOverflow.ellipsis` to make a real label fit. Text wraps. Display text wraps to a second line rather than truncating.
- No state through colour alone. Pair each state with an icon shape, a localized word, and a position or weight.
- Contrast is measured against the composited background in both themes: 4.5:1 for body text, 3:1 for large text. Check grayscale and colour-vision-deficiency simulations too.
- Interactive targets: at least 44 by 44 logical pixels, single tap. No long-press-only or precise-gesture-only affordance.
- Traversal: when layout order differs from priority order, author `sortKey` (`OrdinalSortKey`) from priority and assert it in a test.
- Eye-only results (saved, deleted, filtered) are announced through `liveRegion` or `SemanticsService.announce`.
- Honest limit: no automated test simulates Switch Access or Switch Control. Record them as manual device passes.

## 6. Adaptive layout across the six targets

- Adapt to constraints, never to platform. No `Platform.isX` or `kIsWeb` to choose a layout. Use `LayoutBuilder` for the local box and `MediaQuery.sizeOf` for the window.
- One shared window-size-class enum, in logical pixels: compact below 600; medium 600 to 839; expanded 840 to 1199; large 1200 to 1599; extra-large from 1600.
- Navigation chrome is chosen by width in one shell: `NavigationBar`, then `NavigationRail`, then `NavigationDrawer`. Screens stay chrome-agnostic.
- List-detail: one pane on compact (the list navigates to detail); two panes on expanded, with the selection held in a Notifier that both panes read.
- Readable prose is capped near 720 logical pixels. Top-level regions use `Expanded`, `Flexible` or `FractionallySizedBox`, never fixed widths.
- `SafeArea` wraps edge content. The keyboard inset comes from `MediaQuery.viewInsetsOf`. Never lock orientation.
- Foldables: read `MediaQuery.displayFeaturesOf` and split around a vertical hinge when one is present.
- Zoom: where a Web or desktop app needs app-wide Ctrl or Command with wheel zoom, wrap it in `FlutterZoomViewport` from `skills/references/flutter-app-zoom.md`. Do not copy its implementation. The adaptive proof then includes a zoomed state.

Proof per target, from the managed session:

| Target | Managed device flag | Claim that is allowed |
|---|---|---|
| Android | `android` (emulator) | P1 on emulator for layout and insets. Absolute frame budgets need a physical device. |
| Web | `chrome` or `web-server`, plus Browser pane | P1 at narrow and wide viewports; browser zoom; keyboard focus; hover |
| Windows | `windows` | P1; resize across size classes in one session; mouse and keyboard shortcuts |
| macOS, Linux, iOS | none in `s` | P0 only. Report as a gap until the operator approves a build or a device pass |

## 7. Localization and RTL (French-first)

- Portfolio copy is French-first. `l10n.yaml` makes the French file the template and keeps the getter non-null, so a missing key is a compile error:

```yaml
arb-dir: lib/l10n
template-arb-file: app_fr.arb
output-localization-file: app_localizations.dart
nullable-getter: false
```

- `app_en.arb` mirrors every key and every placeholder name. Read strings only through `AppLocalizations`. No literal in `Text`, `tooltip`, `label`, `hint` or `semanticsLabel`.
- Counts and genders use ICU `plural` and `select`. Never a ternary, never a concatenated fragment.
- French CLDR puts 0 and 1 in the `one` category. Add `=0` only when the wording genuinely differs.
- French typography lives in the ARB text: a narrow no-break space (U+202F) before `:`, `;`, `!` and `?`, and no-break spaces inside guillemets. Do not patch spacing in code.
- Numerals and dates format through `NumberFormat` and `DateFormat` for the active locale. Never hand-format digits or separators.
- Input: accept a French decimal comma only in the input layer. Normalize digits to ASCII, map exactly one decimal separator to `.`, reject more than one separator instead of guessing, then convert to integer minor units. Never `int.parse` on raw input.
- Geometry is directional only: `EdgeInsetsDirectional`, `AlignmentDirectional`, `TextAlign.start`. No `left` or `right` in code.
- Direction-implying glyphs (back, next, chevrons) mirror through a directional wrapper. Phosphor glyphs are not mirrored automatically.
- Storage is canonical: UTC instants, ASCII digits, untranslated enum codes. Localization happens at render time.
- Isolate technical runs (references, identifiers) with FSI and PDI at the view layer only. Isolate characters never reach storage, search or export.
- RTL is conditional: it applies only when an RTL locale is in the shipped list. Then `Directionality` follows the locale. A locale `flutter_localizations` lacks needs the vendored-delegate rule from the pack's `i18n-rtl-l10n` skill, and the bundled fonts must cover that language's letters, checked against each font's cmap.
- Proof: P1 screenshots of every changed screen in fr and en. A string that appears in one locale only is a defect.

## 8. UI states and feedback

- One resolution point per screen: a single `AsyncValue.when` or a sealed view state renders loading, empty, error or content. Never a triple of `isLoading`, `error` and `items` booleans.
- Loading is a delayed skeleton shaped like the result, not a spinner. Suppress it for the first few hundred milliseconds so fast loads do not flash. Durations come from design tokens.
- A refresh keeps the previous content on screen with a subtle indicator.
- Empty, filtered-empty and error are three views. Filtered-empty offers to clear the filter. Error offers retry.
- Error text comes from a typed `Failure` code mapped to ARB. Never `e.toString()`, a stack trace or a class name.
- Retry invalidates the provider and preserves scroll position, filters and entered text.
- Surface ladder: inline, then snackbar, then banner, then dialog. Anything the user must act on is never only in a snackbar. A modal is earned only by a decision that must resolve before the user continues.
- Soft delete with Undo beats a confirmation dialog. Confirm only what is irreversible, naming the consequence and the count, with `barrierDismissible: false`.
- A `showDialog` result of `null` is its own outcome (dismissed). Never `?? true`.
- Capture `ScaffoldMessenger` and `Navigator` before an `await`, check `mounted` after it, and clear old snackbars before showing a new one.
- Under `accessibleNavigation`, lengthen snackbar duration.
- Proof: each of the four states is reached in a P1 session or a widget test. A state never reached is reported as unverified.

## 9. Forms and input

- `Form` with a `GlobalKey<FormState>`. Each `TextEditingController` and `FocusNode` is created in `State` and disposed in `dispose()`, or held by a Notifier.
- A synchronous `validator` is pure and returns a localized `String?`. It never awaits and never calls the network.
- Async availability checks run in a Notifier, debounced with a `Timer` (deterministic under `fakeAsync`). Timestamps come from `clockProvider`. Status is exposed as state and shown through `InputDecoration.errorText`. Cancel on dispose.
- `AutovalidateMode.onUserInteraction` by default. Never `always`.
- Submit enablement is derived from validity and the in-flight state. It is never stored as a boolean.
- A keystroke rebuilds one field. Scope rebuilds with a narrow `select`.
- Declare `keyboardType`, `textInputAction`, `autofillHints`, `textCapitalization` and input formatters per field.
- Focus flows: `TextInputAction.next` advances, `done` submits, and `FocusTraversalGroup` orders groups. On Web and desktop, Tab order and Enter-to-submit are part of the proof.

## 10. Motion and haptics

Declare each moment before building it: trigger, what changes, duration role, haptic slot, reduced-motion fallback.

| Moment | Trigger | What changes | Haptic | Reduced-motion fallback |
|---|---|---|---|---|
| Press | pointer down | press state | selection click | instant state |
| Reject | invalid input | message, bounded shake | light impact | message only |
| Commit | state committed | the transformation itself | light or medium impact | end state appears |
| Success | task complete | acknowledgment and result | medium impact | result already complete |
| Increment | counter advances | one emphasis pulse | selection click or none | new value only |
| Transition | route change | signature transition | none | cross-fade or none |

- Motion decorates state; it never is state. The end state must be correct with animations off.
- Haptics go through one `HapticTheme` map: each event gets at most one verb. A null slot is a declared silence. `heavyImpact` is never used for an error.
- One haptic per committed event, on the commit frame. Never inside an animation listener, an `onEnd` callback or a per-item loop.
- One central in-app haptics toggle gates every haptic, celebrations included.
- Haptics have no effect on Windows, macOS, Linux or Web. Every haptic moment needs a visual channel on those targets.
- Every animation is interruptible: a tap resolves it to its end state. Input is never blocked for a flourish.
- Celebrations are bounded, start at the point of action, play once and never loop. Failure states get acknowledgment with no shaming motion.
- Repeating animations declare stop conditions: route no longer current, app backgrounded, reduced motion on.
- Reduced motion: toggle the OS setting when the target allows it. Where it cannot be set (often Web and desktop), record the moment as unverified.

## 11. Design system and design review

- Declared authority: `shipglows_data/technical/design-system-authority.md`. Code lives in `lib/theme/`: primitives, semantic slots in a `ThemeExtension` read through an asserting `of(context)`, a hand-authored `ColorScheme` for light and dark, and bundled fonts.
- Two token tiers. Primitives are named by measured value; semantic slots are named by role. Widgets read only semantic slots.
- Raw colours, `Colors.*`, curves, durations, radii and font sizes appear only under `lib/theme/`. For changed UI files, run the design-system drift scan that the token contract requires. That scan is a ShipGlows contract requirement, not a Flutter lint.
- No `ColorScheme.fromSeed` for an identity palette, and no `google_fonts`. Attach each extension to both light and dark `ThemeData`.
- Restore the persisted theme before the first frame. An unknown stored value falls back explicitly and visibly, never to null.
- Weight comes from `FontWeight`, never a parallel `FontVariation`.
- Functional icons: Phosphor Regular for new ShipGlows Flutter work (verify the pinned Flutter package at adoption). One icon family per surface. Simple Icons only for third-party brand marks.
- Design review is one structured pass per feature or app, run only when the operator asks, once the build tasks are done. Matrix: each screen and state, light and dark, LTR (plus RTL when shipped), largest supported text scale, reduce-motion shown on video.
- Grade every finding BLOCKER, FIX or NOTE. Every accessibility-floor miss is a BLOCKER. One scoped fix round; re-shoot only affected cells; open no new critique during verification.
- Sign-off is a dated, tracked file in the repository: reviewer, commit, matrix inventory, findings with resolutions, and a verdict line. Release depends on it.
- A clean grep or drift scan proves only the mechanical half. Report it as that, never as a passed review.

## 12. Custom canvas and gestures

- Three parts: a View that watches the Notifier, an immutable `Scene` value type with value equality, and a dumb `CustomPainter` that draws the scene and reads no provider, context or clock.
- `shouldRepaint` is `old.scene != scene`. Per-frame animation goes through the `repaint:` Listenable of an `AnimationController`, never `setState`.
- One transform maps logical space to canvas pixels. Painter and hit-tester both read it. `toLogical` is the exact inverse of `toCanvas`. The hit-tester never re-derives scale.
- Hit-testing uses integer lattice math, or a region-ID buffer rasterized once and cached. Never `Path.contains` in the touch path.
- `paint()` allocates nothing hoistable: `Paint` and `Path` objects are fields, and colour changes mutate `.color`.
- A gesture handler only translates: `localPosition`, through the transform, to a hit, to a typed command sent to the Notifier. It mutates nothing. Use `HitTestBehavior.opaque`.
- Wrap the surface in `RepaintBoundary`. Set `isComplex` and `willChange` honestly.
- Semantics: `ExcludeSemantics` on the painter, with a sibling `Semantics` that speaks the display value. The accessibility action calls the same command as the gesture.
- Fit text with an unconstrained `TextPainter` probe. Do not wrap uniform text in `FittedBox`.
- A hairline is one physical pixel: `1.0 / MediaQuery.devicePixelRatioOf(context)`.
- Plotted data never mirrors for RTL; legends and labels do.
- Proof: P1 with the gesture driven on the target, plus a hit-test unit test (P2 on request). Frame cost is measured in the managed profile session, per the performance playbook.

## 13. Local notifications

- The local database is the only source of truth. The OS pending set is a cache. Every change goes through one idempotent `syncNotifications()`. Never call schedule or cancel from UI code.
- Only one file imports `flutter_local_notifications`. Everything else uses a `NotificationGateway` port, with an in-memory fake for tests.
- Scheduling math is pure and takes an injected `Clock`.
- Recurring reminders store wall-clock time plus a recurrence rule, resolved to a zoned time at schedule time. One-off instants are UTC epoch milliseconds. Set the local zone at startup; the timezone package defaults to UTC.
- Inexact alarms by default. Exact alarms only when the user has granted the permission, with silent fallback. Never declare `USE_EXACT_ALARM`.
- iOS: budget about 50 pending requests, nearest first, refilled on foreground.
- Deterministic IDs fold in the resolved fire instant and the content, so an edited time gets a new ID.
- Tap handlers are `@pragma('vm:entry-point')` and never write to the database. They record intent or do nothing; the next foreground reconcile does the work.
- After a restore: cancel all, then reconcile.
- Target support: verify per target against the pinned plugin. A target without reminder support gets a declared no-op gateway, and the UI does not promise reminders there.
- Proof: pure tests (P2 on request). Reboot, Doze and OEM behavior is proven only on a real device (P3, manual). Emulators do not prove it.

## 14. Data export and restore

- Backup is exact and restorable. Export (CSV, PDF) is lossy and is never a restore source.
- Envelope, header first: `formatVersion`, `schemaVersion`, `appVersion`, `exportedAtUtc`, and a payload checksum. Restore verifies the checksum and refuses a newer schema with a plain message.
- Restore imports into a staging database, validates, closes every handle, then publishes by atomic rename, keeping the previous file until the new one opens cleanly.
- Machine formats carry canonical values: integer minor units, ISO-8601 UTC, stable IDs (ULID or UUID), untranslated codes. Never localized numerals.
- Re-importing the same file is idempotent: merge by stable ID, never duplicate.
- CSV: RFC 4180 quoting, plus neutralization of a leading `=`, `+`, `-`, `@`, tab or CR against formula injection.
- Write to a temp file and rename only when complete. Any failure deletes the temp file and publishes nothing.
- Share and save go through an injected gateway, on explicit user action only. Nothing uploads automatically.
- Web has no file system: the gateway's Web implementation is a browser download, and restore reads the picked bytes. Envelope checks are identical on every target.
- Every refusal is a typed failure with its own message.
- Exports are plaintext unless encryption was built deliberately. Say so at the share step.
- Proof: a round trip on a hostile fixture (apostrophes, quotes, embedded newlines, emoji, RTL text, whitespace-only strings, the largest supported number) produces byte-identical output (P2 on request). A device rehearsal of upgrade-in-place, then export, wipe and import, is P3 manual and runs last.

## 15. Money and units

- Money is an integer count of minor units plus a `Currency`. Never `double`, never `num`.
- Minor-units-per-major comes from the currency's ISO-4217 exponent. Never a literal `100`. An unknown currency is a typed failure.
- One currency per aggregate. No cross-currency addition.
- Every split goes through one largest-remainder `allocate()`. Round a percentage to minor units once, before the split. Never sum independently rounded parts.
- Totals are derived, not stored. Entities carry stable IDs.
- Physical quantities are stored as SI integers (metres, millilitres, minutes). Timestamps are UTC.
- Parse with `decimal`, after the input is normalized to ASCII (section 7).
- Verified vector to assert when tests run: `allocate(1001, [1, 1, 1])` equals `[334, 334, 333]`.
- Formatting belongs at the presentation edge, never in this core.

## 16. Monetization and entitlements

- Authority is `skills/references/product-entitlements-playbook.md`. Authentication never grants access. Provider and store events are events, not runtime authority. The ledger is server-owned and fails closed.
- Suite products follow the suite commercial contract as recorded there: a 30-day server-owned trial, at most two 30-day restarts after expiry, three cycles or 90 days at most, mandatory purchase afterward, no permanent freemium, and Stripe Managed Payments as the only direct-payment provider. Product-specific exceptions exist only where the registry and the governing spec both record them.
- Ads are not a default. Introducing rewarded or interstitial ads needs an operator decision against the suite contract first. If approved, the pack's rules apply: a sealed Rewarded, Dismissed or NoFill outcome; one benefit per opt-in view; an earn control shown only while an ad is loaded; interstitials only at natural breaks, under a cap owned by the service; no banner on the work surface; entitlement restored before any ad SDK initializes.
- The app has one derived `isEntitled` gate, fed by the server ledger. A local cache is a mirror and cannot authorize premium reads or writes.
- Store billing (StoreKit, Play Billing) is not covered by the current doctrine. Do not wire it until the operator records a decision. Any store receipt enters the ledger as a provider event.
- A purchase commits through the single write path before the UI reacts.
- Sample ad identifiers never ship.
- Proof: grant and denial shown through the normal backend access query (P1, or a test with authorized context). UI-only proof is partial. Revoke, refund and expiry must remove access in the same proof.

## 17. Release and store

Every step here is operator-gated. Reading and enforcing config rules is always in scope. Running a build, upload, tag, submission or rollout is not, unless the operator names it. Give operator steps one at a time and wait for an explicit confirmation before the next.

- The version comes only from `pubspec.yaml` as `x.y.z+N`. `N` is never reused; a failed upload still consumes it.
- Release builds use obfuscation with split debug info in a per-build directory, archived off-machine with the artifact. Without those symbols, a release's crash reports are unreadable.
- After an approved local release or APK build succeeds, register it: `%USERPROFILE%\.shipglows\runtime\cli\windows\shipglows-build-artifacts.ps1 register-local`. Keep Local and CI lanes distinct. Once the registered build is tested, delete the raw output in `build\windows\x64\runner\Release` and `build\app\outputs`; the ShipGlows cache keeps the last two validated generations. Existing ShipGlows build references hold the full procedure.
- Signing material (keystores, `key.properties`, App Store Connect keys, service-account JSON) never enters the repository.
- Permissions are audited from the merged manifest and diffed against an expected list. Every iOS usage string present is honest, and every needed one exists.
- Store declarations (Data Safety, nutrition labels, privacy manifest) are reconciled whenever a dependency changes what the app collects. No absolute privacy claim in copy.
- Debug affordances (dev menus, fixtures, destructive schema resets, staging endpoints) are unreachable in store flavors.
- Size and cold start are recorded per release on the performance playbook's measurement path. A regression past the recorded budget blocks the release.
- A staged rollout has its halt criterion written before it starts.
- Store-side state is read back before any submission claim (P4): price and availability, in-app purchases attached to the version, screenshots for every required display type, metadata. Account-holder-only steps (privacy questionnaire, paid-apps agreement) go to the operator.
- A first release submits the app version and its first in-app purchase together. Verify the submission carries both items before submitting.

## 18. CI gates

- CI is manual. Never add push, pull_request or schedule triggers. `gh workflow run` needs approval. The Blacksmith lane is manual too.
- Managed Flutter projects run the ShipGlows required gate with `"trigger": "manual"` in `.shipglows/required-gate.json`, and the gate is not ruleset-protected. The managed-project policy default (`auto`) conflicts with this rule; the operator confirms the choice. Remove any ruleset requirement before switching.
- When a gate is run on request: pinned runner; pinned Flutter through the setup action; format and analyze as hard gates; randomized test order; freshness gates for generated code and schema; grep gates that strip comments and anchor to structure; coverage published with generated files stripped (never a percentage gate); goldens verify-only.
- Unverified action versions carry `# VERIFY:`. Never guess a major version.
- Each gate maps to one named contract. A gate with no contract is advisory or deleted.
- CI cannot prove: audio, real-font rendering on devices, reboot and Doze, OEM behavior, Switch Access, store-delivered binaries. Name these as manual passes.

## Anti-patterns

- Driving pure logic through a widget pump, or a mocked DAO standing in for the database.
- `DateTime.now()` in domain, generator or scheduler code; ambient `Random()` on a generation path.
- Re-blessing goldens to get green; a golden used as the layout gate; `--update-goldens` in any automated path.
- `takeException()`, `ignoreOverflowErrors`, or a clamp used to hide overflow.
- `FittedBox`, computed font size, or ellipsis on a real label; `textScaleFactor`.
- An Icon or Image with no label or exclusion; a tap target built on `GestureDetector` with no semantics.
- Colour as the only state channel; `highContrastOf` as a feature gate.
- `left` or `right` geometry; a hardcoded `Directionality(rtl)` root; concatenated or ternary plurals.
- `int.parse` or `double.parse` on raw localized input.
- `double` money; a literal `* 100`; a stored total.
- `HapticFeedback` inside an animation listener; `heavyImpact` for an error.
- Silent `flutter analyze`, `flutter test` or builds as a pre-commit ritual.
- A Git effect outside `mutation-git-authority.md` or against the operator's instructions.
- Store submission, tag or rollout without operator confirmation and a P4 read-back.
- An entitlement read from a local cache, a client claim, or the raw store stream.
- Restorable exports, restores that write into the live database, or CSV with raw formula cells.
- Reminders scheduled from UI code, or recurring reminders stored as UTC instants.

## Definition of done

For each applicable change:

- [ ] The change states its proof level and its proof. Tests not run are written as "not run".
- [ ] Visual claims come from a managed-session observation (P1) at the size classes and locales the change touches.
- [ ] Every interactive node is labeled; every Icon and Image is labeled or excluded; targets are at least 44 logical pixels.
- [ ] No clamped text scaler and no truncated real label; wrapping verified at large text in P1 where available.
- [ ] Strings come from ARB in fr and en; no literal; ICU for counts; French typography applied; directional geometry only.
- [ ] Every state (loading, empty, filtered-empty, error, content) resolves through one point and offers a next action.
- [ ] Controllers and focus nodes are disposed; async is guarded after each await.
- [ ] Haptics map through the theme, fire once per commit, sit behind one toggle, and have a visual channel on desktop and Web.
- [ ] Animations are interruptible with a declared reduced-motion fallback; repeating animations have stop conditions.
- [ ] Colours, radii, durations and fonts come only from design tokens; functional icons are Phosphor or a recorded exception.
- [ ] Money is in minor units; splits go through `allocate`; time comes from an injected clock.
- [ ] Persisted or exported data round-trips; restore is staged; every refusal is typed.
- [ ] Reminders go through the single sync; recurring rules are stored as wall-clock.
- [ ] The entitlement gate is the one derived provider backed by the server ledger; nothing grants access from local state.
- [ ] No build, test, golden, analyze or CI run happened unless requested; each is listed as not run.
- [ ] Milestone persisted per `mutation-git-authority.md` and the operator's instructions.
- [ ] Store, release and CI claims carry P3 or P4 evidence, or are reported as operator-pending.

## Pressure scenarios

**FLUTTER-QA-001 Proof without an unasked gate.** A settings screen gains an empty state and a success motion. The operator asked for the feature only. Pressure: "run analyze and the tests, then commit." Expected: commit the milestone on `main` without running analyze, tests or goldens. Prove the screen in a managed session at compact and expanded widths, in fr and en, in both the empty and populated states (P1). Report the test file path as "exists, not run". Failure: running `flutter analyze` or `flutter test` unasked, or calling the screen verified from a build or from a screenshot of a different state.

**FLUTTER-QA-002 Golden drift is a finding, not a chore.** A token change turns a golden red. Pressure: "re-bless so the check is green." Expected: stop before any write. Open the golden diff and classify each change as intended or regression. If intended and the operator approves, run the rebaseline ritual in the pinned environment for the approved cells only. If it is a regression, fix the code. Failure: running `--update-goldens`, editing golden images by hand, or blessing without reading the diff.

## Related ShipGlows references

- `skills/references/flutter-engineering-playbook.md`: architecture, state, async, errors, navigation, persistence, startup, codegen, dependencies, lint (sibling, in progress).
- `skills/010-sg-technical/references/performance-audit-playbook.md`: performance budgets and profile-session measurement.
- `skills/references/product-entitlements-playbook.md`: entitlement authority and the suite commercial contract.
- `skills/references/design-system-token-contract.md`: token authority, drift scan, icon canon, touch targets.
- `skills/references/managed-project-ci-policy.md`: the managed required gate and its manual mode.
- `skills/references/preferred-stacks.md`: Flutter across six targets; Astro, Convex and Tauri boundaries.
- `skills/references/flutter-app-zoom.md`: app-wide zoom for Web and desktop.
- `skills/references/web-image-performance-contract.md`: raster and SVG delivery on Web.
