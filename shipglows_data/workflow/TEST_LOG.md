# Test Log

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
- Result summary: User reported all manual picker scenarios pass: `001-sg-build` in Codex, `000-shipglows` in Claude Code, and no old active `sf-build` duplicate.
- Bug pointer: none
- Evidence pointer: chat confirmation; checklist `shipglows_data/workflow/test-checklists/three-digit-runtime-skill-names.md`
- Follow-up: /103-sg-verify Three Digit Runtime Skill Names

## 2026-05-08 - ShipGlows menu startup and Health cleanup guard retest

- Scope: BUG-2026-05-08-001, BUG-2026-05-08-002
- Environment: local
- Tester: Codex tooling
- Source: sf-test
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
- Source: sf-test
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
- Source: sf-test
- Status: pass
- Confidence: high
- Result summary: ShipGlows restart for `nococaine` detected the Flutter Web command and PM2 launched the app online on port `3002`.
- Bug pointer: BUG-2026-05-04-004 -> shipglows_data/workflow/bugs/BUG-2026-05-04-004.md
- Evidence pointer: chat-provided restart log; no secrets or private payloads stored
- Follow-up: `/sg-verify BUG-2026-05-04-004`

## 2026-05-03 - sf-skill-build runtime visibility retest

- Scope: BUG-2026-05-03-001
- Environment: local
- Tester: user
- Source: sf-test
- Status: pass
- Confidence: high
- Result summary: Operator invoked `$sf-skill-build hi` and confirmed the skill was recognized by Codex.
- Bug pointer: BUG-2026-05-03-001 -> shipglows_data/workflow/bugs/BUG-2026-05-03-001.md
- Evidence pointer: chat confirmation; no secrets or private runtime data stored
- Follow-up: `/sg-verify BUG-2026-05-03-001`

## 2026-05-02 - Local SSH bare identity key retest

- Scope: BUG-2026-05-02-003
- Environment: local
- Tester: user
- Source: sf-test
- Status: pass
- Confidence: high
- Result summary: Operator confirmed the ShipGlows local SSH connection now works after the bare identity filename fix.
- Bug pointer: BUG-2026-05-02-003 -> shipglows_data/workflow/bugs/BUG-2026-05-02-003.md
- Evidence pointer: chat confirmation, no raw IP or key material stored
- Follow-up: none; verified by sf-verify on 2026-05-02
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
