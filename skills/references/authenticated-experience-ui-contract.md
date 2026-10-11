---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-18"
updated: "2026-08-18"
status: active
source_skill: 006-sg-design
scope: authenticated-experience-ui
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/109-sg-auth-debug/SKILL.md
  - skills/006-sg-design/references/component-system-audit-playbook.md
  - skills/006-sg-design/references/accessibility-audit-playbook.md
  - skills/109-sg-auth-debug/references/auth-browser-proof.md
depends_on:
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/human-centered-interaction-heuristics.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "CommandGlows authenticated-navigation implementation on 2026-08-18 exposed the need for one provider-neutral contract spanning global session representation, account access, private navigation, recovery, accessibility, and browser proof."
next_review: "2026-11-18"
next_step: "/103-sg-verify authenticated experience UI contract"
---

# Authenticated Experience UI Contract

## Purpose And Ownership

Use this contract whenever ShipGlows designs, implements, audits, or proves frontend UI whose visible behavior depends on authentication state. It governs the customer-facing experience around identity; it does not authenticate users or authorize data.

- `006-sg-design` owns composition, interaction, visual-system integration, accessibility, responsive behavior, and visible proof.
- `109-sg-auth-debug` owns session/provider diagnosis, callbacks, cookies, redirects, protected-route behavior, auth-safe evidence, and the technical explanation for visible state.
- `product-access-and-license-ui-contract.md` owns purchased plan, feature, quota, activation, device, expiry/renewal, and license-recovery presentation after identity resolves.
- The project backend, middleware, and authorization layer remain the enforcement authority. Hidden or visible UI is never an access-control boundary.
- The project design-system authority owns tokens and styled component adapters. This contract does not introduce a parallel palette, spacing scale, typography system, or component library.

## State Model

Every global auth surface must represent these states deliberately:

| State | Global representation | Private surface behavior | Recovery |
| --- | --- | --- | --- |
| Loading or unresolved | Stable, non-interactive account placeholder or reserved space; never a misleading sign-in or avatar action | Do not reveal protected content while authority is unresolved | Resolve once, then announce only a meaningful state change |
| Signed out | One clear sign-in action using the product's navigation language | Public content remains usable; private entry preserves a safe return intent | Start the approved provider flow |
| Signed in | One recognizable account trigger, normally the user's avatar with a non-image fallback | Show coherent private navigation and current-location state | Account management and sign-out remain reachable |
| Expired or revoked | Explain that the session ended rather than implying data loss or an application crash | Preserve safe, non-sensitive work or intent where the project permits it; hide protected content | Reauthenticate without an open redirect or loop |
| Unauthorized | Explain lack of access separately from signed-out state | Do not advertise inaccessible content as available | Offer an allowed destination or account switch when supported |
| Provider or callback error | Honest error state with retry or safe exit | Never claim success, persist a false signed-in state, or expose private data | Retry from a clean boundary or return to a public destination |

Exactly one coherent global account affordance is visible after state resolution. A page fails this contract when sign-in and avatar controls appear together, both disappear indefinitely, or responsive duplicates register conflicting account menus.

## Global Account Trigger

- Signed-out users receive a discoverable text action such as `Sign in`; an unlabeled icon alone is insufficient.
- Signed-in users receive a stable account trigger. Prefer the actual profile image when available and an intentional initials/person fallback when it is not.
- The accessible name identifies the action, not the person's private email address. The trigger exposes expanded state when it controls a menu or dialog.
- Keep one behavioral instance whenever possible. If responsive composition requires more than one rendered instance, assign unique provider/component identities and prove that hidden copies do not register duplicate menus, focus traps, listeners, portals, or IDs.
- Reserve enough space to prevent navigation movement when auth resolves. Do not flash protected identity data or a clickable wrong-state control during hydration.

## Account Menu Information Architecture

The account menu is a compact orientation and account-control surface, not a second sitemap.

Recommended order:

1. Optional identity summary, limited to information the user expects in this context.
2. Primary private destination such as overview or workspace.
3. A small set of frequent private destinations such as tasks.
4. Product profile or settings.
5. Provider-owned account/security management when it differs from product settings.
6. Sign out as the final session action.

Keep these responsibilities distinct:

- **Product navigation** moves within the product.
- **Product profile/settings** manages product preferences or public profile data.
- **Account/security management** manages identity, credentials, MFA, devices, and provider-owned account data.
- **Sign out** ends the current session; it is not a navigation shortcut.
- **Delete account, revoke all sessions, remove organization, or destructive billing actions** do not belong in the lightweight menu without their own confirmation and recovery contract.

Using a provider-owned account panel is valid. The provider may own secure behavior and semantics while the project owns placement, surrounding navigation, design-token integration where supported, and proof that the panel remains readable and trustworthy. Do not fork provider internals merely to force visual parity.

## Private Navigation Shell

- Private destinations share one persistent navigation model across dashboard, tasks, settings, and private documentation or equivalent project surfaces.
- Mark the current destination semantically, for example with `aria-current="page"` on web.
- Use the same destination names and order in the private shell and account menu unless the menu intentionally contains only a documented subset.
- The private shell adapts to available space without hiding the only route to account settings or sign-out.
- Public and private navigation may coexist, but their hierarchy must remain understandable. An authenticated user can still reach public product content without losing account orientation.
- Route visibility is not authorization. Protected routes and data enforce access independently on the server or approved platform authority.

## Sign-In, Return Intent, And Recovery

- Preserve the user's intended project-owned destination across sign-in when safe and useful.
- Validate return targets against an allowlisted same-origin or app-owned route model. Reject external, malformed, circular, stale, or unauthorized targets.
- Do not bounce a user between sign-in, callback, and a protected route indefinitely. Detect and expose a recoverable loop boundary.
- Distinguish provider cancellation, callback failure, expired session, missing entitlement, and backend-data failure. They require different recovery language and ownership.
- If authentication interrupts unsaved work, preserve only non-sensitive state the project is authorized to retain. Never put secrets, tokens, or private payloads in return URLs or client-visible diagnostics.

## Sign-Out Contract

- Sign out remains reachable from every authenticated surface through the global account affordance or a consistently linked account surface.
- Use explicit wording. Do not represent sign out with an ambiguous close, power, or exit icon without a text label.
- A normal current-session sign out may execute directly when product policy permits; broader actions such as `sign out all devices` require explicit scope and confirmation.
- While sign out is pending, prevent accidental duplicate activation and expose progress when delay is perceptible.
- On success, clear private UI, close menus/dialogs, restore a safe public state, and avoid redirect loops.
- On failure, do not falsely render signed out. Explain recovery without revealing provider details or session artifacts.
- Automated or agent-driven proof must not click a real human user's sign-out action without explicit action-time authority. Prefer structural, isolated-session, mocked, or disposable-account proof.

## Accessibility And Interaction

- Use native or mature headless/provider primitives for menus, dialogs, and focus management. Project wrappers own composition and tokens, not reimplementation of keyboard semantics.
- Support keyboard opening, arrow or documented menu navigation, activation, `Escape`, outside dismissal where appropriate, and focus restoration to the account trigger.
- Provide visible focus in every theme and state. Hover must not be the only way to reveal account actions.
- Interactive targets meet the project's governed minimum and are at least 44 CSS pixels where WCAG target-size expectations apply, subject to documented exceptions.
- At 200% zoom, text-spacing overrides, narrow reflow, large dynamic type, RTL, and long localized labels, controls remain visible, operable, and non-overlapping.
- Profile images have appropriate alternative treatment; decorative icons are hidden from assistive technology and never replace the menu item's accessible name.
- Announce meaningful session loss or recovery, but avoid noisy announcements during routine hydration.
- Respect reduced motion and forced colors. Auth state changes must not depend on animation or color alone.

## Responsive And Platform Adaptation

- On desktop, the account trigger normally remains directly visible in the global chrome.
- On mobile, keeping the account trigger beside the primary navigation control is preferable when space permits; burying both sign-in and account access inside a closed drawer requires explicit discoverability proof.
- Web/PWA surfaces prove SSR/client hydration agreement, popover placement, focus, zoom, reflow, and history/redirect behavior.
- Native mobile and desktop surfaces translate the same roles through platform navigation, account, back, window, and secure-session conventions. Do not copy web ARIA mechanics into native widgets.
- Multi-window, multi-tab, or multi-device products define how visible state reacts when another context signs in, signs out, revokes, or expires the session.

## Privacy, Security, And Trust

- Never treat avatar presence, menu visibility, route visibility, or client state as authentication or authorization proof.
- Minimize displayed identity data. Do not expose an email address, tenant, role, or organization in global chrome unless it materially helps orientation and is appropriate for the viewing context.
- Prevent open redirects, private-content flashes, stale protected caches, and cross-user UI residue after session changes.
- Never log or capture cookies, authorization headers, tokens, OAuth codes or state, OTPs, passwords, magic links, private profile payloads, or unredacted provider responses.
- Account switching, impersonation, organization switching, MFA, deletion, and recovery flows inherit their specialist security, audit, and confirmation contracts.

## Proof Matrix

Use the smallest representative matrix that can prove the product claim:

1. Public route, signed out: exactly one discoverable sign-in action.
2. Public route, signed in: exactly one account trigger and no sign-in action.
3. Private route, signed in: account trigger plus private navigation and correct current destination.
4. Protected route, signed out or expired: no protected-content flash, safe sign-in/recovery path, validated return intent.
5. Menu: expected product links, account management, and sign out; keyboard open/dismissal and focus restoration.
6. Responsive: supported narrow and wide widths, long localized labels, no horizontal overflow, minimum targets.
7. Accessibility: focus visibility, zoom/reflow, forced colors, reduced motion, assistive names, and current-page semantics.
8. Failure: provider/callback error, session expiry, unauthorized access, and sign-out failure do not claim success.
9. Synchronization where applicable: another tab/window changes session state without leaving stale private UI.

Evidence order:

- Inspect project authority and source/component boundaries.
- Run focused automated component/contract tests.
- Use an isolated signed-out browser context for signed-out proof.
- Use an authorized signed-in session for non-destructive menu and navigation proof.
- Use mocked, disposable, or explicitly authorized state for sign-out, expiry, revocation, and destructive account scenarios.
- Record only redacted URLs, visible states, relevant console/network status, representative screenshots, and exact proof gaps.

Do not claim complete authenticated-experience proof from static code inspection, a successful backend token check, one signed-in screenshot, or a provider dashboard configuration alone.

## Pressure Scenarios

### AUTH-UI-GLOBAL-STATE

A user is signed in and returns to a public landing page. The page must show one recognizable account trigger rather than `Sign in`; the same global behavior holds on private pages. An isolated signed-out context must show the sign-in action. Neither state may leave the action region empty after loading.

### AUTH-UI-RESPONSIVE-DUPLICATE

A navbar renders desktop and mobile variants simultaneously in the DOM. If two provider widgets register against one implicit identity, emit console errors, duplicate menu items, or break focus, the implementation fails even when only one widget is visually visible. Prefer one behavioral widget or prove unique scoping and inactive-copy isolation.

### AUTH-UI-PRIVATE-ORIENTATION

A signed-in user opens dashboard, tasks, settings, and private docs. Every surface exposes the same private navigation model, marks the current destination, and keeps account access available without relying on browser Back.

### AUTH-UI-SESSION-LOSS

A private session expires while the user is active. Protected content disappears safely, the interface distinguishes session loss from data failure, safe intent is preserved, and reauthentication returns only to an authorized destination without a redirect loop.

### AUTH-UI-PROOF-SAFETY

An agent validates a real signed-in profile menu. It may open and dismiss the menu, inspect links, and navigate to non-destructive destinations, but it must not click sign out, revoke sessions, delete an account, or expose private session evidence without explicit action-time authority.

## Stop Conditions

Stop or narrow the claim when identity owner, route protection, authorization authority, return-target policy, account-management owner, session-loss behavior, destructive-action policy, design-system authority, supported platforms/locales, or representative proof route is unknown. Route provider/session mechanics to `109-sg-auth-debug`, visual and interaction design to `006-sg-design`, implementation repair to the project development/fix owner, and deployment-specific callback or cookie truth to hosted production proof.
