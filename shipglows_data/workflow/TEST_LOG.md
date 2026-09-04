# Test Log

## 2026-08-24 - Windows linked developer root resolution

- Scope: BUG-2026-08-24-001 / sales-page-reference-library.md
- Environment: Windows local worktree, Python 3.14 through uv
- Tester: Codex tooling
- Source: 107-sg-test
- Status: pass
- Confidence: high
- Result summary: Before the fix, two public-repository protection tests returned `git_repo_target`; after implementing the canonical linked-channel fallback, all 33 capture-tool tests and the complete 756-test UTF-8 suite passed (4 skipped).
- Bug pointer: BUG-2026-08-24-001 -> shipglows_data/workflow/bugs/BUG-2026-08-24-001.md
- Evidence pointer: synthetic unit tests and local command output only; no private corpus data retained
- Follow-up: none; independently verified and closed on 2026-08-24

## 2026-07-05 - Deploy target matrix founder-app routing proof

- Scope: shipglows_data/workflow/specs/deploy-target-matrix-for-shipglows-managed-app-projects.md
- Environment: local transcript review
- Tester: user
- Source: 107-sg-test
- Status: pass
- Confidence: high
- Result summary: User-provided transcript shows `000-shipglows` routed a generic founder CRUD deploy question to `004-sg-deploy`, recommended Railway by default, and kept the "final choice depends on project context" boundary explicit.
- Bug pointer: none
- Evidence pointer: chat-provided transcript excerpt plus `conversation-000-shipglows-o-je-devrais-d-ployer-une-app-crud-simple-pour.md` for partial export context
- Follow-up: /107-sg-test --preview deploy target matrix for ShipGlows-managed app projects

## 2026-06-11 - Three Digit Runtime Skill Names manual picker proof

- Scope: shipglows_data/workflow/specs/three-digit-runtime-skill-names.md
- Environment: local runtime picker, fresh/reloaded Codex and Claude Code sessions
- Tester: user
- Source: 107-sg-test
- Status: pass
- Confidence: high
- Result summary: User reported all manual picker scenarios pass: `001-sg-build` in Codex, `000-shipglows` in Claude Code, and no old active `sg-build` duplicate.
- Bug pointer: none
- Evidence pointer: chat confirmation; checklist `shipglows_data/workflow/test-checklists/three-digit-runtime-skill-names.md`
- Follow-up: /103-sg-verify Three Digit Runtime Skill Names

## 2026-05-08 - ShipGlows menu startup and Health cleanup guard retest

- Scope: BUG-2026-05-08-001, BUG-2026-05-08-002
- Environment: local
- Tester: Codex tooling
- Source: sg-test
- Status: pass
- Confidence: high
- Result summary: Top-level menu startup completed in 0.495s and isolated Gum render in 0.246s; Health blank input stayed on process/options view and explicit `g` was required for Aggressive Cleanup.
- Bug pointer: BUG-2026-05-08-001 -> shipglows_data/workflow/bugs/BUG-2026-05-08-001.md; BUG-2026-05-08-002 -> shipglows_data/workflow/bugs/BUG-2026-05-08-002.md
- Evidence pointer: `/tmp/sg-test-shipglows-start.out`, `/tmp/sg-test-menu-gum.out`, `/tmp/sg-test-health-blank.out`, `/tmp/sg-test-health-g.out`
- Follow-up: none; both bugs closed by this retest.

## 2026-05-08 - PM2 orphan stop and crash-loop guard retest

- Scope: BUG-2026-05-06-001
- Environment: local
- Tester: Codex tooling
- Source: sg-test
- Status: pass
- Confidence: high
- Result summary: `env_stop` stopped a PM2-only/orphan-style app by name; isolated `batch_stop_all` stopped the temporary PM2-only app; generated ecosystem config contains crash-loop limits.
- Bug pointer: BUG-2026-05-06-001 -> shipglows_data/workflow/bugs/BUG-2026-05-06-001.md
- Evidence pointer: local PM2 commands with temporary `shipglows_retest_*` app names; no secrets or private payloads stored
- Follow-up: completed by `/sg-verify BUG-2026-05-06-001` on 2026-05-08; no further retest required for this bug.

## 2026-05-05 - Flutter + Convex dev command retest

- Scope: BUG-2026-05-04-004
- Environment: local
- Tester: user
- Source: sg-test
- Status: pass
- Confidence: high
- Result summary: ShipGlows restart for `nococaine` detected the Flutter Web command and PM2 launched the app online on port `3002`.
- Bug pointer: BUG-2026-05-04-004 -> shipglows_data/workflow/bugs/BUG-2026-05-04-004.md
- Evidence pointer: chat-provided restart log; no secrets or private payloads stored
- Follow-up: `/sg-verify BUG-2026-05-04-004`

## 2026-05-03 - sg-skill-build runtime visibility retest

- Scope: BUG-2026-05-03-001
- Environment: local
- Tester: user
- Source: sg-test
- Status: pass
- Confidence: high
- Result summary: Operator invoked `$sg-skill-build hi` and confirmed the skill was recognized by Codex.
- Bug pointer: BUG-2026-05-03-001 -> shipglows_data/workflow/bugs/BUG-2026-05-03-001.md
- Evidence pointer: chat confirmation; no secrets or private runtime data stored
- Follow-up: `/sg-verify BUG-2026-05-03-001`

## 2026-05-02 - Local SSH bare identity key retest

- Scope: BUG-2026-05-02-003
- Environment: local
- Tester: user
- Source: sg-test
- Status: pass
- Confidence: high
- Result summary: Operator confirmed the ShipGlows local SSH connection now works after the bare identity filename fix.
- Bug pointer: BUG-2026-05-02-003 -> shipglows_data/workflow/bugs/BUG-2026-05-02-003.md
- Evidence pointer: chat confirmation, no raw IP or key material stored
- Follow-up: none; verified by sg-verify on 2026-05-02
## 2026-07-13 - Mail Intelligence structured AI classification

- Scope: daily-mail-intake-review-v2.md / Task 4
- Environment: local Neovim + Mail Intelligence
- Tester: user
- Source: 107-sg-test
- Status: fail
- Confidence: high
- Result summary: first run crashed on the ACP provider lookup; after that fix, Avante received the source but ended with `-32603 Internal error`.
- Bug pointer: BUG-2026-07-13-001 -> shipglows_data/workflow/bugs/BUG-2026-07-13-001.md
- Evidence pointer: chat-provided Neovim stack trace; no private email content stored
- Follow-up: /107-sg-test --retest BUG-2026-07-13-001

## 2026-07-13 - Password-to-SSH-key promotion on retained Hetzner QA server

- Scope: shipglows_data/workflow/specs/password-to-ssh-key-promotion.md
- Environment: retained Hetzner QA VM plus isolated Linux local-device homes; Android Termux pending
- Tester: Codex tooling
- Source: 107-sg-test
- Status: blocked
- Confidence: high
- Result summary: SSHKEY-M01, M02, M04, and M05 passed; Linux key-mode tunnel proof passed after closing the password master, but required Android Termux scenario SSHKEY-M03 is not run.
- Bug pointer: BUG-2026-07-13-002 -> shipglows_data/workflow/bugs/BUG-2026-07-13-002.md
- Evidence pointer: shipglows_data/workflow/test-checklists/password-to-ssh-key-promotion.md; provider VM retained by operator request; no host, password, token, or key material recorded
- Follow-up: /107-sg-test password-to-ssh-key-promotion from Android Termux on the retained QA server

## 2026-08-09 - Physical Android Termux SSH-key and tunnel proof

- Scope: shipglows_data/workflow/specs/password-to-ssh-key-promotion.md
- Environment: physical Android Termux plus retained QA VM
- Tester: operator with Codex-assisted diagnostics
- Source: 107-sg-test
- Status: pass
- Confidence: high
- Result summary: The operator completed password-first pairing, device-key creation and installation, key-only reconnection, session identity lookup, registered-port selection, and a browser localhost tunnel proof. No subsequent server-password prompt occurred.
- Evidence pointer: shipglows_data/workflow/test-checklists/password-to-ssh-key-promotion.md; no host, credential, key material, or raw SSH output retained
- Follow-up: none

## 2026-07-17 - Public ShipGlows bootstrap on Android Termux

- Scope: BUG-2026-07-17-001
- Environment: production public endpoint on Android Termux
- Tester: user
- Source: 107-sg-test
- Status: fail
- Confidence: high
- Result summary: The documented sudo pipeline fails because Termux has no sudo; without sudo, the public bootstrap exits on its root guard and never routes to `local/install.sh`.
- Bug pointer: BUG-2026-07-17-001 -> shipglows_data/workflow/bugs/BUG-2026-07-17-001.md
- Evidence pointer: user-reported real-device reproduction plus supplied HTTP 200, short SHA-prefix mismatch, and public route ownership; no secrets or device identifiers stored
- Follow-up: /106-sg-fix BUG-2026-07-17-001

## 2026-08-25 - Windows dependency setup log encoding retest

- Scope: BUG-2026-08-24-002
- Environment: Windows 11; Windows PowerShell 5.1; PowerShell Core 7.6.5; Git Bash
- Tester: Codex tooling
- Source: 107-sg-test
- Status: pass
- Confidence: high
- Result summary: The dependency setup path replaced a pre-existing UTF-16 log with strict UTF-8 output, preserved non-ASCII and console output, retained failure handling, and passed the complete Windows DevServer contract.
- Bug pointer: BUG-2026-08-24-002 -> shipglows_data/workflow/bugs/BUG-2026-08-24-002.md
- Evidence pointer: focused dependency regression plus complete Windows contract; no raw project log, credential, or private payload retained
- Follow-up: /103-sg-verify BUG-2026-08-24-002

## 2026-08-25 - Windows dependency setup log encoding verification

- Scope: BUG-2026-08-24-002
- Environment: Windows 11; Windows PowerShell 5.1; PowerShell Core 7.6.5; Git Bash
- Tester: Codex independent verification
- Source: 103-sg-verify
- Status: pass
- Confidence: high
- Result summary: Independent verification confirmed strict UTF-8 without NUL bytes, preserved console and non-ASCII output, native failure handling, repeated and concurrent setup behavior, and the complete Windows DevServer contract.
- Bug pointer: BUG-2026-08-24-002 -> shipglows_data/workflow/bugs/BUG-2026-08-24-002.md
- Evidence pointer: focused PS5.1 and PowerShell Core regressions plus complete Windows contract exit 0; no raw logs, credentials, or private payload retained
- Follow-up: none

## 2026-08-25 - OWASP application security contract test Windows UTF-8 retest

- Scope: BUG-2026-08-25-001 / `tools.test_owasp_application_security_contract`
- Environment: Windows, PowerShell, Python 3.14 through uv, default CP-1252 mode
- Tester: Codex tooling
- Source: sg-bug
- Status: verified locally; delivery blocked by baseline
- Result summary: Independent retest confirms all four contract-test `Path.read_text()` calls declare `encoding="utf-8"`; the module, bug metadata lint, and `git diff --check` pass without `-X utf8`. Delivery remains blocked by six independent pre-existing baseline failures (budgets, autonomy contracts, and the new skill).
- Bug pointer: BUG-2026-08-25-001 -> `shipglows_data/workflow/bugs/BUG-2026-08-25-001.md`
- Evidence pointer: focused module retest output and `git diff --check`
- Follow-up: none; bug closed after local verification, pending baseline repair before delivery

## 2026-08-25 - Global contract baseline after Windows UTF-8 repair

- Scope: autonomy hierarchy, activation budgets, `603-sg-private` accounting, and BUG-2026-08-25-001
- Environment: Windows, PowerShell, Python 3.14 through uv, default encoding mode
- Tester: Codex tooling
- Source: sg-engineering
- Status: pass
- Confidence: high
- Result summary: The six independent baseline regressions were repaired without raising thresholds; 78 focused tests and the complete 812-test suite pass with 4 intentional skips.
- Bug pointer: BUG-2026-08-25-001 -> `shipglows_data/workflow/bugs/BUG-2026-08-25-001.md`
- Evidence pointer: activation baselines `010=4729` and `103=4851`, valid 15/53 graph, metadata lint, strict skill budget, execution-fidelity audit, and `git diff --check`
- Follow-up: commit locally; push remains outside the approved scope

## 2026-08-25 - GitHub required Windows gate and conversation-contract salvage

- Scope: `git-github-hygiene-and-ci.md`; PR 34; replacement PR 35 for draft PR 29
- Environment: Windows 11; Git Bash; GitHub Actions Windows runner; GitHub ruleset 20563834
- Tester: Codex tooling and GitHub Actions
- Source: 102-sg-start
- Status: partially passed; integration gate pending
- Confidence: high
- Result summary: PR 34's exact heads passed `ShipGlows required gate` with the complete Windows contract, while a deliberate manual failure at SHA `92b113f` failed as expected. A transient anonymous GitHub API `403` on the first `761a49b` run passed unchanged on retry and exposed a redundant API lookup for already-complete SHAs; strict SHA resolution now bypasses only that lookup and passes the focused regression plus complete local Windows contract. PR 35 preserves the three PR 29 patches on current main and passes 20 focused tests, metadata lint, and `git diff --check`; GitHub cannot schedule its newly required check until PR 34 installs that workflow on main. The independent `d18e779` replay stopped cleanly on two documentation conflicts and its original branch remains untouched.
- Evidence pointer: GitHub PRs 34 and 35; Actions runs 32880874842 and 32881079150; local focused and complete Windows-contract outputs; no credential, private payload, or destructive operation retained
- Follow-up: obtain separate merge authority for PR 34, verify PR 35's exact-head gate after integration, and obtain explicit semantic-merge authority before reconciling `d18e779`

## 2026-08-25 - CLI SaaS capability snapshot salvage

- Scope: `d18e779`; PR 36; private CLI-to-SaaS discovery contract
- Environment: Windows 11; Git Bash; Python 3.14
- Tester: Codex tooling
- Source: sg-engineering
- Status: pass with one documented unrelated baseline failure
- Confidence: high
- Result summary: The unique capability-snapshot work was reapplied to current main with only document-version reconciliation. The focused cloud-preview catalogue contract passes, including closed capability IDs/states, redaction boundaries, zero/one/many fixtures, byte limits, and preservation of the last valid snapshot. POSIX `0600` remains asserted on Unix-like filesystems and is skipped only on MSYS/MINGW/Cygwin where NTFS does not expose chmod semantics. The neighboring startup-cache test fails identically on clean main at its emoji picker assertion and is not caused by this change.
- Evidence pointer: PR 36 commit `f575916`; focused Bash syntax/contract output; metadata lint; `git diff --check`
- Follow-up: review PR 36 and run its exact-head required gate; Linux permission proof remains represented by the retained Unix assertion

## 2026-08-25 - Git, GitHub, runtime, and CI hygiene closeout

- Scope: `git-github-hygiene-and-ci.md`; PRs 34-36; approved temporary-artifact cleanup batch
- Environment: Windows 11; PowerShell; GitHub Actions; GitHub ruleset 20563834
- Tester: Codex tooling and GitHub Actions
- Source: sg-engineering / sg-docs
- Status: pass with three explicit retained artifacts
- Confidence: high
- Result summary: PRs 34, 35, and 36 passed their exact-head required gates, merged through protected `main`, and passed post-merge gates. The canonical runtime reached merge commit `67c6688` with 68/68 skill links valid. Six clean, unused, ancestry-proven worktrees and local branches plus seven ancestry-proven remote branches were removed under separate approval. The original PR 29, development, and UTF-8 artifacts remain retained because their exact tips are not ancestors of `main`; the development worktree also had active Dart processes during audit. The unrelated operator-owned runtime modification remained content-identical.
- Evidence pointer: GitHub PRs 34-36 and their required-gate runs; refreshed Git ancestry and worktree/process preflight; post-cleanup local/remote ref audit; canonical skill-link check
- Follow-up: review retained artifacts no earlier than 2026-08-26 and resolve the unrelated runtime modification before requiring a clean canonical worktree

## 2026-09-04 - Managed Flutter Windows startup regression retest

- Scope: BUG-2026-09-04-001 / ContentGlows managed Windows cold start
- Environment: Windows, ShipGlows DevServer source checkout on `main`, `flutter run -d windows`, attached visible session
- Tester: Codex tooling
- Source: sg-bug
- Status: passed locally; installed-runtime proof pending protected-main integration
- Confidence: high
- Result summary: Controlled stop proved no residual ContentGlows Debug runner. The next cold start emitted `app.debugPort`, `app.devTools`, `app.dtd`, and `app.started`; registry reconciliation produced `status=running`, `flutterStartupState=running`, `flutterHeadless=false`, and `lastError=null`. Explicit hot reload completed with `Reloaded 0 libraries` in 521 ms.
- Bug pointer: BUG-2026-09-04-001 -> `shipglows_data/workflow/bugs/BUG-2026-09-04-001.md`
- Evidence pointer: protected supervisor state and Flutter machine-event logs under the active ShipGlows launch identity
- Follow-up: merge through the protected main gate, synchronize the installed runtime, and repeat the proof through `s`

### Follow-up attempt

A second cold-start attempt reached Flutter compilation but was blocked by a current ContentGlows type error in `windows_capture_studio.dart`. The DevServer preserved the bounded compiler diagnostic and no Debug runner survived. No ContentGlows file was changed as part of this ShipGlows repair.

### Progress-aware cold-build follow-up

The current ContentGlows source passed targeted Dart analysis. An installed-runtime start then reproduced a healthy `app.progress` build crossing the fixed 90-second deadline and exposed premature termination. With the source repair, the same managed Windows cold start continued beyond 90 seconds and reached `running` with a valid app ID and daemon; targeted stop subsequently proved zero residual Debug runners. Focused tests cover the extended active-build window and prompt supervisor-death detection. Installed-runtime cold start and reload remain pending protected-main integration.

A subsequent regenerated ContentGlows build completed after the original 90-second boundary and exposed an immediate post-build attachment timeout. The focused regression now proves that finishing active build progress starts a fresh bounded VM Service attachment window.

Repeated installed attempts then exposed a late native runner appearing after the first empty process snapshot and locking the next link with `LNK1168`. The focused cleanup regression now injects that late appearance and proves it is reaped before a stable quiet period completes.

The installed command surface also exposed that `s reload -ProjectPath <path>` was no longer routed even though authenticated supervisor reload remained available. The explicit command is restored with running-session validation and a focused dispatch contract.

### Final installed-runtime verification

After merging and installing the stable-extinction and reload-command repairs, ContentGlows started from zero Debug runners and reached registry `running` with `flutterHeadless=false`, a valid app ID, a Flutter daemon PID, and no error. Installed `s reload -ProjectPath` succeeded and the expected single Debug runner remained attached. BUG-2026-09-04-001 is closed with monitored recurrence risk.
