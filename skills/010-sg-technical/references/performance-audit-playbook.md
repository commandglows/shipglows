---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "2.0.0"
project: ShipGlows
created: "2026-07-17"
updated: "2026-10-20"
status: active
source_skill: 010-sg-technical
scope: performance-audit-playbook
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/010-sg-technical/SKILL.md
  - skills/references/web-image-performance-contract.md
  - skills/references/web-typography-contract.md
  - skills/references/preferred-stacks.md
depends_on:
  - artifact: skills/references/web-image-performance-contract.md
    artifact_version: "1.0.0"
    required_status: active
  - artifact: skills/references/web-typography-contract.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Transferred exhaustively from the retired performance skill during the 010-sg-technical consolidation."
  - "Operator-approved 2026-08-22 lesson from the ShipGlows terminal transition: process startup was already fast while transport attachment, partial redraw, and opaque incoming-canvas publication still produced visible latency."
  - "Operator correction 2026-10-20: the portfolio never uses React; performance audits cover only Flutter, Astro, Tauri and Convex. Flutter rules adapted from the MIT-licensed Flutter Agent Skills (flutter-performance) installed locally, with the ShipGlows managed profile session replacing hand-run profile commands."
next_step: "/103-sg-verify consolidate technical skills under sg-technical"
---

# Performance Audit Playbook

Load this playbook only for `010-sg-technical performance`. It preserves the retired performance contract; its former invocation is provenance, not an alias.

When web image delivery is in scope, load `$SHIPGLOWS_ROOT/skills/references/web-image-performance-contract.md` before choosing formats, responsive delivery, tools, budgets, safety checks, or proof. When fonts, typography loading, fallback rendering, subsets, or font-related layout shift are in scope, load `$SHIPGLOWS_ROOT/skills/references/web-typography-contract.md`. Keep both gates conditional; they add no package or provider by default.

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and open the report with the opening chantier header. If no unique chantier is identified, do not write to any spec; use a `(local)` chantier header with a short work name.

## Chantier Potential Intake

Because this skill has process role `source-de-chantier`, evaluate the standard threshold from `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` before the final report. If the findings reveal non-trivial future work and no unique chantier owns it, do not write to an existing spec; add a `Chantier potentiel` block with `oui`, `non`, or `incertain`, a proposed title, reason, severity, scope, evidence, recommended `/100-sg-spec ...` command, and next step. If the work is only a direct local fix or already belongs to the current chantier, state `Chantier potentiel: non` with the concrete reason.


## Supported Stacks

ShipGlows audits performance only for the portfolio stacks declared in `$SHIPGLOWS_ROOT/skills/references/preferred-stacks.md`:

| Surface | Stack | Phase |
|---|---|---|
| Application (Web, Android, iOS, Windows, macOS, Linux) | Flutter | Phase 1 |
| Public/SEO site | Astro on Vercel | Phase 2 |
| Native desktop exception | Tauri (Rust host + Vite/Vue webview) | Phase 3 |
| Backend/data | Convex (HTTP API from Flutter, client from Astro/Tauri) | Phase 4 |

Audit only the phases whose stack is detected. Never import checklists from frameworks the portfolio does not use (React, Next.js, React Native/Expo, Svelte, SSR Node servers). A target on any other stack is reported as `hors périmètre` with the detected markers; do not improvise a generic web checklist for it.

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -120 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Flutter: !`find . -maxdepth 3 -name pubspec.yaml -not -path "*/.dart_tool/*" -not -path "*/build/*" 2>/dev/null | head -5 || echo "none"`
- Flutter dependencies: !`for f in $(find . -maxdepth 3 -name pubspec.yaml -not -path "*/.dart_tool/*" -not -path "*/build/*" 2>/dev/null | head -3); do echo "== $f"; sed -n '/^dependencies:/,/^[a-z_]*:$/p' "$f" | head -40; done`
- Flutter managed config: !`cat .shipglows.flutter.json 2>/dev/null | head -40 || echo "none"`
- Astro: !`ls astro.config.* */astro.config.* 2>/dev/null | head -5 || echo "none"`
- Tauri: !`find . -maxdepth 3 -name tauri.conf.json -not -path "*/node_modules/*" -not -path "*/target/*" 2>/dev/null | head -3 || echo "none"`
- Convex: !`find . -maxdepth 3 -name schema.ts -path "*convex*" -not -path "*/node_modules/*" 2>/dev/null | head -3 || echo "none"`
- JS dependencies (Astro/Tauri webview): !`cat package.json 2>/dev/null | head -80 || echo "no package.json"`
- Image/font assets: !`find . -maxdepth 4 \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.webp" -o -name "*.avif" -o -name "*.woff2" -o -name "*.ttf" -o -name "*.otf" \) -not -path "*/node_modules/*" -not -path "*/build/*" -not -path "*/target/*" 2>/dev/null | wc -l`

## Mode detection

- `010-sg-technical performance` answers one specialist question:

```text
What performance risks are limiting this Flutter, Astro, Tauri or Convex scope across startup, rebuild/render, raster/paint, loading weight, data access and memory?
```

- **`$ARGUMENTS` is "global"** → GLOBAL MODE: performance audit across ALL projects.
- **`$ARGUMENTS` is a file path** → FILE MODE: deep performance review of that single file.
- **`$ARGUMENTS` is empty** → PROJECT MODE: full performance audit of the detected stacks.

Keep the boundary explicit: stay in `010-sg-technical performance` when performance is already the dominant audit domain. Route back to `400-sg-audit` only when the operator needs multi-domain audit planning or consolidation beyond performance.

## Evidence Levels And Measurement Paths

Label every claim as `static` (code reading), `dev-session` (diagnostic only), `profile` (Flutter managed profile session), `hosted` (Vercel preview/production), or `production`. Never present a static guess as a measured bottleneck; never optimize without a before/after measurement at the same evidence level.

- **Flutter**: measurements come from the managed profile session: `s start -ProjectPath <p> -FlutterDevice <device> -FlutterMode profile` (the registry records `flutterMode: profile`; `s reload` is refused because Flutter supports neither hot reload nor hot restart in profile, `s restart … -FlutterMode profile` rebuilds; `s stop` is unchanged). Profile compiles like release (AOT, no asserts) while keeping the VM service and DevTools attached, so jank, raster, memory and timeline figures are representative. Debug-mode figures are never performance evidence, release has no attached tooling, and a hand-run `flutter run --profile` or `flutter drive --profile` outside the managed surface is not an accepted measurement path. Prefer a floor device (low-end Android via the provisioned emulator only for relative comparisons; a physical device for absolute frame budgets). Budget: ≤16 ms per frame at 60 Hz, ≤8 ms at 120 Hz, on BOTH the UI and the raster thread. "Track widget rebuilds" runs in debug and is a diagnostic for rebuild counts, not timing evidence.
- **Flutter Web download size, Astro production output, Tauri release startup/binary size**: each requires a build. Builds run only on explicit operator request; otherwise report these items as `static` readiness with the exact command the operator can approve. Hosted Vercel previews are the preferred real-measurement surface for Flutter Web and Astro (Lighthouse/PageSpeed or Vercel Speed Insights on the hosted URL).
- **Astro dev server** serves unbundled Vite modules: never use it for CWV, weight or TTFB figures.
- **Tauri dev session** runs a debug Rust host and the Vite dev server: valid for IPC call counts and interaction diagnostics, never for startup time, CPU cost of Rust code or binary size.

---

## GLOBAL MODE

Audit performance across ALL projects in the workspace.

1. Read `discovered project-local corpora (`shipglows_data/` markers)` — check the **Domain Applicability** table. Identify projects with ✓ in the Perf column, and their stack (Flutter / Astro / Tauri / Convex).

2. Use the runtime's structured question tool when available to let the user choose:
   - Question: "Which projects should I audit for performance?"
   - `multiSelect: true`
   - One option per applicable project: label = project name, description = detected stacks

3. Use available parallel agent/tooling to launch one bounded worker per **selected** project in a single parallel batch when supported. If unavailable, run the selected projects sequentially.

   Agent prompt must include:
   - `cd [path]` then read `CLAUDE.md` for project context
   - The absolute date, exact project path, and the stack markers already surfaced by this skill
   - The **Supported Stacks**, **Evidence Levels And Measurement Paths**, complete **PROJECT MODE** section (only the phases for detected stacks), and **Tracking** sections from this skill
   - Rule: before scoring, identify linked systems and performance consequences across surfaces (Astro site → Flutter app handoff, Flutter → Convex, Tauri webview → Rust host)
   - Rule: do not ask follow-up questions; if context is missing, state assumptions / confidence limits and continue
   - Required sub-report sections: `Scope understood`, `Context read`, `Linked systems & consequences`, `Findings`, `Confidence / missing context`

4. After all agents return, compile a **cross-project performance report**:

   ```
   GLOBAL PERFORMANCE AUDIT — [date]
   ═══════════════════════════════════════
   PROJECT SCORES
     [project] [stacks]   [A/B/C/D]  —  summary
     ...
   CROSS-PROJECT PATTERNS
     [Shared issues: same Flutter anti-pattern across apps, shared heavy package, Convex query shape]
   ALL ISSUES BY SEVERITY
     🔴 [project] file:line — description [evidence level]
     🟠 [project] file:line — description [evidence level]
     🟡 [project] file:line — description [evidence level]
   Total: X critical, Y high, Z medium across N projects
   ═══════════════════════════════════════
   ```

5. Update project-local `shipglows_data/workflow/AUDIT_LOG.md` (one traffic-first audit record per project, Perf column) and project-local `shipglows_data/workflow/TASKS.md` (each project's `### Audit: Perf` subsection).

6. Ask: **"Which projects should I fix?"** — list projects with scores. Fix only approved projects, one at a time.

---

## FILE MODE

### Step 1: Gather context

1. Read the target file (`$ARGUMENTS`).
2. Read files it imports/depends on (1 level deep) and the state/provider or Convex function it reads.
3. Identify the file's role and apply the matching checklist below; a file type outside them is `hors périmètre`.

### Step 2: Audit the file

Score each applicable category **A/B/C/D**.

#### `.dart` (Flutter widget, screen, controller, service)
- **Rebuild scope**: `const` on every legal constructor; state read through the narrowest subscription (Riverpod `ref.watch(p.select(...))`, `context.select`, `ValueListenableBuilder`); no `setState` high in a large tree; widgets split into small classes, not `_buildX()` helpers.
- **Build purity**: no `jsonDecode`, sort, regex, date math, I/O or large allocation inside `build()`.
- **Lists & layout**: `ListView.builder`/`GridView.builder`/slivers for variable content; no `shrinkWrap: true` list inside another scrollable; no `IntrinsicHeight`/`IntrinsicWidth` per row; `itemExtent`/`prototypeItem` when rows are uniform.
- **Paint & raster**: no `Opacity`, `ClipPath`, `ShaderMask`, `BackdropFilter` or other `saveLayer` source in scrolling or animated paths; `RepaintBoundary` only around independently repainting subtrees; `CustomPainter` allocates nothing in `paint()` and `shouldRepaint` is one value compare.
- **Animation**: `AnimatedBuilder`/`ValueListenableBuilder` pass the static subtree through `child:`; no ticker-driven `setState` rebuilding a screen.
- **Images**: `cacheWidth`/`cacheHeight` or `ResizeImage` matching the display slot; above-the-fold images precached.
- **Isolates & async**: large parsing or CPU work through `compute`/`Isolate.run`; input-driven work debounced.
- **Memory & cleanup**: every controller, subscription, timer, focus node and recognizer disposed (`dispose` / `ref.onDispose`); screen-scoped providers `autoDispose`.

#### `.astro`
- Zero client JS by default; every `client:*` island justified, with `client:visible`/`client:idle` preferred over `client:load`; no UI framework pulled in for an interaction a small inline `<script>` can do.
- Images through `astro:assets` `<Image>`/`<Picture>` with explicit dimensions; LCP image eager with `fetchpriority="high"`, everything below the fold lazy.
- Fonts per `web-typography-contract.md`; no render-blocking third-party script in `<head>`.
- Data fetched at build time (frontmatter in prerendered pages), not on the client.

#### `.vue` / `.ts` in a Tauri webview
- Large reactive data held in `shallowRef`/`markRaw`; computed values instead of watchers recomputing on every change; long lists virtualized; heavy routes/components lazy (`defineAsyncComponent`, route-level dynamic import).
- IPC: no `invoke` per frame or per list item; payloads batched or streamed; listeners from `listen()` unregistered on unmount.

#### `.rs` in `src-tauri`
- Commands doing I/O or CPU work are `async` or use `spawn_blocking`; nothing blocks the main/event-loop thread; no large buffer clones; large binary payloads use `tauri::ipc::Response`/channels rather than JSON arrays.

#### `convex/*.ts`
- Every filtered read uses `withIndex` on an index declared in `schema.ts`; no `.collect()` on unbounded tables; `.take(n)`/`.paginate()` for lists; no per-item query fan-out; external calls in actions, not queries/mutations.

### Step 3: Fix

Remain read-only by default. Fix issues rated B or worse only when the operator explicitly authorizes the exact fix scope or an active lifecycle contract already does. Stop for architecture, behavior, permission, destructive, or cross-scope decisions. Explain each authorized change.

### Step 4: Report

```
PERFORMANCE REVIEW: [file name] — [stack]
─────────────────────────────────────
[Category]          [A/B/C/D] — one-line summary [evidence level]
...
─────────────────────────────────────
OVERALL             [A/B/C/D]

Fixed: X issues | Needs decision: Y
```

---

## PROJECT MODE

### Workspace root detection

If the current directory has no project markers (no `pubspec.yaml`, no `astro.config.*`, no `src-tauri/`, no `convex/`, no `package.json`) BUT contains multiple project subdirectories — you are at the **workspace root**, not inside a project.

Use the runtime's structured question tool when available, or a concise plain-text question:
- Question: "You're at the workspace root. Which project(s) should I audit for performance?"
- `multiSelect: true`
- Options:
  - **All projects** — "Run performance audit across every project" (Recommended)
  - One option per project from `discovered project-local corpora (`shipglows_data/` markers)`: label = project name, description = stacks

Then proceed to **GLOBAL MODE** with the selected projects.

### PHASE 1: FLUTTER APPLICATION

When a Flutter task needs the deeper rule set, load the matching installed Flutter skill if the current agent exposes it (`flutter-performance`, `widget-composition`, `state-management-riverpod`, `app-startup-and-bootstrap`, `custom-canvas-and-gestures`, `async-safety`). Those skills never override the ShipGlows measurement path above: their `flutter run --profile` instruction is replaced by the managed profile session.

#### 1.1 Rebuild scope (UI thread / build)
- [ ] `prefer_const_constructors` and `prefer_const_literals_to_create_immutables` enabled in `analysis_options.yaml`; `const` used wherever legal
- [ ] State consumed through the narrowest subscription (`select`, `Selector`, `ValueListenableBuilder`); a leaf never watches a whole state object for one field
- [ ] No `setState` at screen/root level for local changes; animation or timer ticks never rebuild heavy siblings
- [ ] Screens composed of small widget classes, not long `_buildX()` methods
- [ ] No parsing, sorting, regex, date math, I/O or large allocation in `build()`; derived values computed once in the controller/notifier and held in immutable state with real equality
- [ ] `InheritedWidget`/`Theme`/`MediaQuery` lookups use the narrow accessors (`MediaQuery.sizeOf`, `paddingOf`) to avoid rebuilding on unrelated changes

#### 1.2 Lists, scrolling and layout
- [ ] Variable or long content uses `ListView.builder`/`GridView.builder`/`SliverList`/`SliverGrid`; never `ListView(children: list.map(...).toList())` for unbounded data
- [ ] No `shrinkWrap: true` scrollable nested in another scrollable; slivers (`CustomScrollView`) instead
- [ ] `itemExtent`, `prototypeItem` or `itemExtentBuilder` for uniform rows
- [ ] No `IntrinsicHeight`/`IntrinsicWidth` or multi-pass layout inside list rows
- [ ] Stable `Key`s on reorderable or animated list items
- [ ] Pagination/infinite scroll loads pages from the data layer, not the whole collection

#### 1.3 Paint and raster thread
- [ ] No `Opacity` widget in animated or scrolling paths (`FadeTransition`, `AnimatedOpacity`, or alpha in colors instead)
- [ ] `ClipPath`, `ClipRRect` with anti-alias, `ShaderMask`, `BackdropFilter`, `ColorFilter` and other `saveLayer` sources absent from scrolling lists and per-frame animations
- [ ] Cheapest widget chosen (`ColoredBox`/`DecoratedBox`/`SizedBox` over `Container` in hot paths)
- [ ] `RepaintBoundary` only around independently repainting subtrees (charts, live indicators, animations), not sprinkled everywhere
- [ ] `CustomPainter`: no `Paint`/`Path`/`Gradient` allocation in `paint()`; `shouldRepaint` is a single value compare; animation drives `repaint:` rather than `setState`
- [ ] Raster cost verified in the profile session on the target renderer (Impeller on mobile; note shader-compilation jank on first run of an effect)

#### 1.4 Images, fonts and assets
- [ ] Decoded size matches the display slot (`cacheWidth`/`cacheHeight`/`ResizeImage`); no full-resolution decode into thumbnails
- [ ] Resolution-aware asset variants (`1.0x/2.0x/3.0x`) for raster assets; vector assets used where cheaper
- [ ] Above-the-fold images precached; network images cached with a bounded cache
- [ ] `ImageCache` limits reviewed for image-heavy screens
- [ ] Bundled fonts limited to used families/weights; no runtime font download on startup without fallback

#### 1.5 Startup and first frame
- [ ] `main()` does only what the first frame needs before `runApp`; other initialization deferred (post-frame callback or lazy providers)
- [ ] No sequential awaits of independent services before `runApp` (run in parallel or defer)
- [ ] Auth/session restore does not block a blank screen without a branded first frame
- [ ] Heavy features loaded lazily; Flutter Web uses `deferred as` imports for rarely used large features
- [ ] Startup measured in the profile session (time to first frame and to first useful content), cold and warm

#### 1.6 Isolates, async and I/O
- [ ] Large JSON parsing, crypto, image processing and heavy loops run through `compute`/`Isolate.run`
- [ ] No synchronous file/`SharedPreferences` reads in hot paths; batched writes
- [ ] Search/input-driven work debounced; network calls cancellable or ignored after dispose
- [ ] Independent network requests run in parallel (`Future.wait`), never as accidental waterfalls

#### 1.7 Memory and lifecycle
- [ ] Every `AnimationController`, `TextEditingController`, `ScrollController`, `FocusNode`, `StreamSubscription`, `Timer` and gesture recognizer disposed
- [ ] Screen-scoped providers/state use `autoDispose` (or equivalent) and do not outlive navigation
- [ ] No unbounded in-memory caches or listener lists; DevTools Memory checked for growth across repeated navigation
- [ ] App lifecycle pauses timers, polling and animations in background

#### 1.8 Flutter Web specifics
- [ ] Renderer choice explicit and justified (CanvasKit vs `skwasm`/WebAssembly build); fallback understood for browsers without WasmGC
- [ ] Initial download weight known (`main.dart.js`/`.wasm`, CanvasKit, fonts, assets) — measured on a hosted preview or a build the operator approved
- [ ] `web/index.html` shows a lightweight loading state before the engine boots; no blank page during engine download
- [ ] Hashed build assets served with long-lived immutable `Cache-Control` on Vercel; `index.html` and the service worker not cached long
- [ ] Rarely used large features behind deferred imports; no icon font or `cupertino_icons` shipped unused (`--tree-shake-icons` left on)
- [ ] Astro → Flutter Web handoff (marketing site to app) does not force a second cold engine download on every navigation

#### 1.9 Desktop and mobile targets
- [ ] Windows/macOS/Linux: window resize and large-viewport layouts stay within frame budget (no layout recomputing whole trees per resize event)
- [ ] Android/iOS: frame budget verified at the device refresh rate (60/90/120 Hz); no work scheduled on every frame while idle
- [ ] Platform channels/plugins called off hot paths; no synchronous native calls per frame

#### 1.10 Observability cost
- [ ] Sentry Flutter tracing, profiling and replay sample rates proportionate to the environment; instrumentation does not add work to key interactions
- [ ] Logging is not string-building large payloads in release/profile

---

### PHASE 2: ASTRO SITE

Load `web-image-performance-contract.md` and `web-typography-contract.md` when images or fonts are in scope.

#### 2.1 Zero-JS default and islands
- [ ] Content pages ship 0 KB of client JS unless an island is justified
- [ ] Each `client:*` directive is the laziest that works (`client:visible`/`client:idle`/`client:media` before `client:load`); no `client:only` without reason
- [ ] Islands use the lightest option: inline `<script>` or a small Vue/vanilla component; no UI framework added for a single toggle
- [ ] No duplicate island frameworks on the same page

#### 2.2 Rendering mode and delivery
- [ ] Pages prerendered (`output: 'static'` or `export const prerender = true`); on-demand rendering only with a stated reason
- [ ] On-demand pages on Vercel use caching (ISR/`Cache-Control`) where content allows
- [ ] Hashed assets immutable-cached; HTML revalidated
- [ ] `prefetch` configured deliberately (hover/viewport) and not prefetching every link on large pages
- [ ] View Transitions / `<ClientRouter />` only when the navigation benefit outweighs its client-side cost

#### 2.3 Images and fonts
- [ ] All content images through `astro:assets` (`<Image>`/`<Picture>`) with modern formats, `widths`/`sizes`, and explicit dimensions
- [ ] LCP image `loading="eager"` + `fetchpriority="high"`; all others lazy
- [ ] Fonts self-hosted WOFF2, subset, `font-display` set, LCP font preloaded, metric-compatible fallback to avoid CLS
- [ ] SVGs optimized; no raster image where a small SVG suffices

#### 2.4 Scripts, CSS and third parties
- [ ] Analytics, consent, Sentry and embeds loaded `async`/`defer` or after interaction; none synchronous in `<head>`
- [ ] Third-party embeds (video, maps, social) use a facade until interaction
- [ ] CSS scoped per component; global CSS minimal; unused utility classes purged; no large CSS framework imported whole
- [ ] Sentry browser tracing/replay not bundled into pages that do not need it

#### 2.5 Core Web Vitals readiness
- [ ] **LCP**: LCP element present in the initial HTML, not injected by JS; no render-blocking CSS/JS ahead of it
- [ ] **CLS**: images/video/embeds have dimensions; no content injected above the fold after load; font swap metric-matched
- [ ] **INP**: island event handlers short (<50 ms tasks); heavy work deferred or chunked; input debounced
- [ ] **TTFB**: static pages served from the Vercel edge; on-demand pages avoid data waterfalls

#### 2.6 Budgets
- [ ] Per-page budgets declared (client JS, total transfer, LCP target ≤2.5 s, CLS ≤0.1, INP ≤200 ms on the hosted surface)
- [ ] Budgets checked on a hosted preview (PageSpeed/Lighthouse or Vercel Speed Insights), mobile profile first

---

### PHASE 3: TAURI DESKTOP

#### 3.1 Startup
- [ ] Main window created hidden and shown once the webview has painted useful content (no white flash)
- [ ] `setup` hook does no blocking I/O or network; heavy initialization spawned asynchronously
- [ ] Plugins limited to those used; plugin initialization not serialized on the startup path
- [ ] Startup measured on a release build only when the operator approves the build

#### 3.2 IPC between webview and Rust
- [ ] Commands performing I/O or CPU work are `async` or use `tauri::async_runtime::spawn_blocking`; nothing blocks the event loop
- [ ] No `invoke` per frame, per keystroke or per list item; calls batched and debounced
- [ ] Large or binary payloads use `tauri::ipc::Response` or channels, never large JSON arrays
- [ ] Event emission throttled; frontend `listen()` handles unregistered on unmount

#### 3.3 Rust host
- [ ] Release profile tuned when size/speed matter (`lto`, `codegen-units = 1`, `opt-level`, `strip`, `panic = "abort"` where acceptable)
- [ ] No needless clones of large buffers; shared state behind cheap locks held briefly
- [ ] Unused Cargo features of heavy crates disabled

#### 3.4 Webview frontend (Vite + Vue)
- [ ] Routes and heavy components lazily loaded
- [ ] Large datasets in `shallowRef`/`markRaw`; no deep reactivity over big arrays; long lists virtualized
- [ ] Dependency weight reviewed (no heavy library for a small feature; tree-shakeable imports)
- [ ] On Windows, WebView2 memory checked across long sessions

---

### PHASE 4: DATA AND CONVEX BACKEND

#### 4.1 Query shape
- [ ] Every filtered read uses `withIndex` on an index declared in `schema.ts`; no `.filter()` scans on growing tables
- [ ] No `.collect()` on unbounded tables; `.take(n)` or `.paginate()` everywhere a list can grow
- [ ] No N+1: a list screen does not issue one query per item (from Flutter or Astro); related data joined in one query/function
- [ ] Queries return only the fields the client renders

#### 4.2 Client access
- [ ] Flutter → Convex HTTP: independent calls parallelized, timeouts set, retries bounded with backoff, responses cached where freshness allows
- [ ] Reactive subscriptions scoped to what is on screen and released when the screen closes
- [ ] Mutations use optimistic updates where rollback is safe, with visible failure feedback
- [ ] Astro pages read Convex at build time when content is static

#### 4.3 Work placement
- [ ] External API calls in actions; heavy or slow work in scheduled functions, not in user-facing mutations
- [ ] Rate limits of third-party APIs respected; no polling where a subscription or webhook exists

---

### PHASE 5: PERCEIVED LATENCY AND ATOMIC TRANSITIONS

Apply this framework-neutral gate to stateful interfaces, embedded runtimes,
editors, terminals, media surfaces, canvases, route transitions, and any flow
that replaces one useful state with another.

- [ ] Measure the complete user-visible timeline separately: trigger, resource
  admission, process/provider readiness, transport attachment, component mount,
  first complete content, and first stable paint. Do not optimize the easiest
  phase merely because it is measurable.
- [ ] Distinguish cold start, warm start, repeat navigation, reconnect, and
  return-to-surface behavior. Report both objective latency and perceived
  continuity; one does not prove the other.
- [ ] Preserve the last trustworthy state while the replacement prepares when
  product and privacy boundaries allow it. A blank, skeleton, or partially
  redrawn replacement is not faster merely because it appears earlier.
- [ ] Stage or coalesce incremental replacement data offscreen and publish one
  coherent state at an explicit readiness boundary. A fade, morph, or opacity
  transition never substitutes for atomic visual commit.
- [ ] When the incoming surface must mount before it can size or request its
  final data, mount it behind the stable state, wait for a bounded quiet or
  readiness condition, then reveal it. Bound the hold so continuous output
  cannot hide the live state indefinitely.
- [ ] Keep reused state volatile and bounded unless persistence is explicitly
  required. Invalidate it on identity, tenant, project, permission, schema, or
  freshness-boundary changes; never trade isolation for perceived speed.
- [ ] Prefetch only a likely safe next state and never allocate a second
  privileged session, duplicate mutation lease, or hidden paid resource merely
  to make navigation look instant.
- [ ] Prove rapid repeated switching, resize/remount, slow or fragmented input,
  continuous output, reduced motion, and cache-boundary changes. Canvas or
  other visually stateful surfaces require rendered evidence; green unit tests
  alone cannot prove the absence of flashes or partial frames.

Pressure scenario `PERF-PERCEIVED-ATOMIC-TRANSITION`: a measured process starts
in tens of milliseconds, yet users see a two-second blank or a redraw flash.
The audit must decompose the timeline through first stable paint, test whether
output is lost before attachment or painted incrementally, preserve the last
safe frame, and require atomic replacement plus rendered proof. It must not
recommend process tuning or a cosmetic fade as the primary fix without evidence.

Pressure scenario `PERF-FLUTTER-DEBUG-NUMBERS`: an agent reports "the list
scrolls at 40 fps" from a debug session and proposes `RepaintBoundary` on every
row. The audit must reject the figure as non-evidence, re-measure in the managed
profile session, split UI vs raster time, and fix the measured side only.

---

### PHASE 6: FIX + REPORT

#### Fix Priority
Remain read-only unless the exact fix scope is authorized by the operator or an active lifecycle contract. For authorized fixes, use this priority:

1. **Critical** — UI-isolate blocking work, unbounded Convex reads or N+1, memory leaks, frames consistently over budget in profile
2. **High** — eager lists over unbounded data, `saveLayer` sources in scrolling/animation, full-resolution image decode, Astro pages shipping avoidable JS, blocking Tauri commands
3. **Medium** — broad rebuild scope, missing `const`, startup work that can be deferred, weak caching, minor CWV issues
4. **Low** — prefetching, optimistic updates, minor weight improvements

#### Report

Include only the sections of detected stacks.

```
PERFORMANCE AUDIT: [project name] — [stacks detected]
═══════════════════════════════════════════════════

FLUTTER APP                          [A/B/C/D]
  Rebuild scope                      [A/B/C/D]
  Lists & layout                     [A/B/C/D]
  Paint & raster                     [A/B/C/D]
  Images & assets                    [A/B/C/D]
  Startup                            [A/B/C/D]
  Isolates & async                   [A/B/C/D]
  Memory & lifecycle                 [A/B/C/D]
  Web specifics                      [A/B/C/D]

ASTRO SITE                           [A/B/C/D]
  Zero-JS & islands                  [A/B/C/D]
  Rendering & delivery               [A/B/C/D]
  Images & fonts                     [A/B/C/D]
  Scripts & CSS                      [A/B/C/D]
  Core Web Vitals readiness          [A/B/C/D]

TAURI DESKTOP                        [A/B/C/D]
  Startup                            [A/B/C/D]
  IPC                                [A/B/C/D]
  Rust host                          [A/B/C/D]
  Webview frontend                   [A/B/C/D]

CONVEX DATA                          [A/B/C/D]
  Query shape                        [A/B/C/D]
  Client access                      [A/B/C/D]
  Work placement                     [A/B/C/D]

PERCEIVED LATENCY                    [A/B/C/D]
═══════════════════════════════════════════════════
OVERALL                              [A/B/C/D]
Evidence: static | profile | hosted | production (per finding)

Fixed: X issues | Needs decision: Y
```

---

## Tracking (all modes)

Shared file write protocol for `AUDIT_LOG.md` and `TASKS.md`:
- First load `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md`; new audit and task records must use that traffic-first operational format.
- Treat the snapshots loaded at skill start as informational only.
- Right before each write, re-read the target file from disk and use that version as authoritative.
- Append or replace only the intended row or subsection; never rewrite the whole file from stale context.
- If the expected anchor moved or changed, re-read once and recompute.
- If it is still ambiguous after the second read, stop and ask the user instead of forcing the write.

After generating the report and applying fixes:

### Log the audit

Create or update traffic-first audit operational records in the target audit logs:

1. **Project-local `shipglows_data/workflow/AUDIT_LOG.md`**: create or update a traffic-first `audit:` record for the Perf audit.
2. **Project-local `./AUDIT_LOG.md`**: same project-explicit traffic-first record; keep the required `[project]` token.

Create either file if missing with a short heading and traffic-first audit records per the shared operational record format.

### Update TASKS.md

1. **Local TASKS.md** (project root): create or update traffic-first task records for the Perf audit findings.
2. **Project-local `shipglows_data/workflow/TASKS.md`**: create or update the same traffic-first task records.

---

## Important

- audit-seo keeps its own SEO-specific performance checks (render-blocking resources, LCP for SEO ranking). This skill does **deep** performance analysis.
- SEO ranking decisions route to `406-sg-seo`; hosted and live runtime truth routes to `405-sg-prod`.
- Label every claim as static readiness, local measurement, browser measurement, hosted/runtime evidence, or production evidence. Never present an unmeasured optimization guess as a proven bottleneck.
- Audit and performance findings are read-only by default and never imply permission to mutate project state.
- Be specific about file paths and line numbers for every issue.
- Detect the stack automatically. Only audit the phases of detected stacks; never apply React, Next.js, Expo or other non-portfolio checklists.
- Performance issues are never optional — a slow site is a broken site.
