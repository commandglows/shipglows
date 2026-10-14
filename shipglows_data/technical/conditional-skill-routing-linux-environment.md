---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-10-11"
updated: "2026-10-14"
status: active
source_skill: sg-engineering
scope: offline-linux-subject-and-evaluator-access
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - tools/conditional_skill_routing_linux_environment.py
  - tools/conditional-skill-routing-linux.ps1
  - shipglows_data/workflow/specs/conditional-skill-routing-and-minimal-context.md
  - shipglows_data/workflow/reviews/conditional-skill-routing-linux-environment.json
depends_on: []
supersedes: []
evidence:
  - "Current-machine WSL/bubblewrap execution, native ELF verification, evaluator import/formula and synthetic separation probes."
next_step: "Keep offline preparation separate from independent review and any later baseline launch."
---

# Offline Linux subject and evaluator

The requested local environment is installed in WSL Ubuntu at
`/home/claude/.local/share/shipglows-isolated-codex-0.160.1`.
Codex is the native Linux x86_64 ELF, version **0.160.1**, verified against the
existing public download receipt. No Windows Codex wrapper, global installation,
account configuration is mounted into the subject. Subscription access is brokered only by the trusted Windows parent as described below. Project execution uses
no Doppler. Setup downloads only the pinned public npm package.

## Access from PowerShell

Run these from the ShipGlows checkout:

```powershell
# Version, separation checks, evaluator entrypoint
& ./tools/conditional-skill-routing-linux.ps1 subject --version
& ./tools/conditional-skill-routing-linux.ps1 probe
& ./tools/conditional-skill-routing-linux.ps1 evaluator --help

# Separate interactive Linux shells
& ./tools/conditional-skill-routing-linux.ps1 subject-shell
& ./tools/conditional-skill-routing-linux.ps1 evaluator-shell
```

Inside the subject shell, `codex --version` invokes `/opt/bin/codex`.
Inside the evaluator shell, the actual evaluator modules and documentary
snapshots are under `/opt/evaluator`; the writable directory is `/work`.
For evaluator inputs, `/opt/evaluator/inputs` is a writable alias of its own
`/work`. Supply CLI input paths under `/opt/evaluator/inputs`, and serialized
provenance paths relative to `/opt/evaluator`, such as `inputs/cases.json`.
Paths supplied as `/work/...` are deliberately outside the evaluator's canonical
root and are refused. This input mount is absent from the subject environment;
code and documentary snapshots remain read-only.
Every invocation creates fresh OS namespaces, while each role retains its own
work directory. The installed launcher can also be used without the checkout:

```powershell
wsl.exe -d Ubuntu --exec /usr/bin/python3 /home/claude/.local/share/shipglows-isolated-codex-0.160.1/environment.py subject-shell
```

The `setup --source-root ...` Python mode creates a new runtime exclusively and
refuses an existing installation. It reads only the four named public files.
The evaluator entrypoint requires future explicitly staged cases/manifest/runs;
none have been copied or scored here. Missing inputs fail closed.

## Isolation and evidence limits

Subject and evaluator run under bubblewrap 0.11.1 with separate user, mount, PID,
IPC, UTS and network namespaces, nested user namespaces disabled, capabilities
dropped, and inherited environment cleared. Each sees only read-only Linux system
directories, its own writable `/work`, private ephemeral `/tmp`, and its own
role-specific code mount. The evaluator additionally sees its own writable input
alias below the read-only public-code root. The subject cannot see evaluator code, documents
or state. The evaluator cannot see the subject binary or state. Neither sees
Windows drives, host home, host sockets or external network routes.

The two spaces share the trusted WSL host, kernel and coordinator identity.
This is process confinement, not separate VMs, separate physical machines, or
protection against a malicious host administrator/coordinator. An independent
offline runtime review found two P2 issues: no canonical writable input path for
the evaluator, and a read-only probe that could omit a failed check. The fixes
add the isolated input alias and make that probe fail closed. Independent
rechecking is recorded separately from the installation receipt. No held-out
scoring process has been started. This runtime review does not itself satisfy
an independent semantic-review or final campaign-profile gate.

The JSON evidence records observed synthetic probes and exact hashes. Initial
failures are retained there: bubblewrap required explicit `--unshare-user` for
`--disable-userns`; evaluator import required the public activation-budget module
and an explicit read-only module search path under Python isolated mode. Both
were corrected before the final access checks. These are preparation receipts,
not passing campaign/readiness receipts.

## Documentary baseline

Use the current specification **v1.4.7** as the documentary baseline, with
calibration **v1.4.0**. Frozen spec SHA256:

`bf787adcf495967313569ac9a42c9556415e4065fc16fcc8d71b9ac0a8253082`

Calibration SHA256:

`5e617dd1de6e64e17164374af729dd02385b25a2b6795a5a995f094e8f4082bd`

Both exact public files are copied into the evaluator's read-only mount. The
canonical spec text is unchanged. On 2026-10-14, checkout line-ending changes
alter its byte hash; the verified execution copy uses the exact frozen bytes
under `.csr-v5-runtime-20261014`, without rewriting tracked source files.
The current spec's
historical shared-host exception applies only to its named historical consumer;
it grants no launch authority for this new isolated consumer. Preserve AC5,
O1-O9, 96 runs / 48 pairs and every numerical threshold. Migration remains NO-GO.

This documentary reference is distinct from the experimental **baseline variant**:
the latter still needs eight new observations before refreshed candidate
authoring. The old shared-host results cannot substitute for them. Installation
receipts establish the runtime boundary only; current source-closure and profile
decisions belong to the separately reviewed preparation stage below. Historical
pending packets are preserved rather than promoted to PASS.

No held-out file was listed, opened, copied or imported by this setup. The
operator's previously reported filename-only exposure is recorded as such; it
does not establish content exposure. The operator subsequently authorized real execution with `gpt-6-luna` through the existing ChatGPT subscription. The independent
evaluator may prepare a new synthetic sealed set within its own isolated state;
the author receives only public attestations, counts and hashes.

## Current preparation stage

From `.csr-v5-runtime-20261014`, use
`tools/fixtures/conditional_skill_routing/preparation-revisions/linux-offline-readiness-v5-20261011/readiness-stage-20261014.json`
with `tools/conditional_skill_routing_real_comparison_preflight.py --template`.
The original default template remains deliberately inactive. Exit 0 means
`prepared_for_authorized_baseline=true`; real launch still requires
`ready_to_launch_baseline=true`, with separately supplied provider, budget and
concrete execution authority. None is inferred from this environment's access.

The current generic consumer profile retains the compatibility filename
`codex-linux-real-v3-consumer-profile.json`. New independent synthetic held-out
generation v5 has its own opaque seal and exact evaluator-owned bindings; the
historical v3 set and historical results do not become this new campaign's input.
The immutable profile/contract contain no receipt backreferences, so review
receipts and the active stage can be hashed without a cycle.

See `shipglows_data/workflow/reviews/conditional-skill-routing-linux-test-handoff.md`
for the handoff, actual checked flags, evidence scope and test exclusions.

## Subscription execution — 2026-10-14

The operator chose `gpt-6-luna`, authorized the necessary subscription usage and
explicitly requested use of the existing ChatGPT subscription. An API key is
not required. Do not request one, switch to API billing or purchase extra credits.

The new execution root is `.csr-sub-20261014`. Its profile SHA256 is
`b123eb7c863fa5bb595cc3daaa5622c8796cd24ab7ccb3f6d3ed15304ba9293a`;
21 code files and the five original frozen baseline artifacts are hash-bound.
The exact reviewed stage is under
`tools/fixtures/conditional_skill_routing/preparation-revisions/subscription-20261014/stage.json`.
The earlier recovered root remains historical evidence, not the live launch stage.

`conditional_skill_routing_subscription_run.py` reads the existing Windows Codex
ChatGPT session only in the trusted parent. It checks expiry/account binding and
forwards the captured native request, unchanged except the approved tool filtering,
to `https://chatgpt.com/backend-api/codex/responses`. The token/account ID is never
mounted into the subject or evaluator, printed, or included in capture receipts.
There is no redirect, API-key fallback, credit purchase or automatic login/refresh.

A single guard and exclusive durable campaign claim cover all eight public baseline
observations. Request/byte/provider-deadline bounds are enforced; token usage is
observed from actual server responses and stops further requests after a threshold,
unknown usage or quota refusal. The subscription catalog exposes no verified hard
output cap. Remaining quota and immutable backend model revision are UNKNOWN.
Provider deadline and the distinct 305-second subject watchdog must not be conflated.

After the subject stops, all raw captures, including failed or partial provider
attempts, enter the evaluator's own `subscription-observations` state. The installed
helper `/opt/evaluator/subscription-support/validate_observation.py` is read-only,
hash-verified and tested with synthetic input through the delivered evaluator.
An intact inventory yields INCONCLUSIVE until independent semantic scoring; it
never becomes a case PASS merely because transport succeeded. Typed generated
reasoning receives no instruction-coverage or retention credit. True opaque
compaction/context loss still retires the case.

The documentary baseline remains specification v1.4.7 and calibration v1.4.0.
Actual baseline observations, later candidate tuning and the final 96-run comparison
remain distinct gates. Consult the handoff for the latest observed run status.
