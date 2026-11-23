---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-11-23"
updated: "2026-11-23"
status: active
source_skill: 900-shipglows-core
scope: product-feedback-triage
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - tools/feedback_triage.py
  - tools/test_feedback_triage.py
  - tools/context_history.py
  - tools/product_updates.py
  - skills/references/product-feedback-triage.md
  - shipglows-app-engine/typescript/shipglows_feedback_convex
depends_on:
  - artifact: shipglows_data/technical/product-updates-projection.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "2026-11-23: 14 unit tests (tools/test_feedback_triage.py) with a fake runner cover discovery, the deployment guard, inbox privacy and suggestions, decision-file validation, dry run, confirmed apply through the history projection and stop-on-failure."
  - "2026-11-23: real read-only inbox against CommandGlows dev (gallant-yak-850, Doppler commandglows/dev) returned 0 new feedback, 0 pending requests and 8 roadmap items in the registry; an apply dry run planned a hidden item without writing."
next_review: "2027-01-23"
next_step: none
---

# Product Feedback Triage

Each product keeps its feedback, feature requests and votes in its own Convex
deployment (`@shipglows/feedback-convex`). `tools/feedback_triage.py` lets an agent
working in ONE product repository read that inbox, propose decisions, and apply
the ones the operator validated. There is no cross-project aggregation.

## Flow

1. `inbox` (read-only): new feedback, pending requests of the product's keys,
   roadmap vote counts, and suggestions.
2. The agent proposes decisions; the operator validates them explicitly.
3. The agent writes a decision file; `apply` prints the plan (dry run).
4. `apply --confirm` executes it. Created roadmap items stay `visibility: hidden`;
   the site changes only after `context_history.py pending` / `publish`, commit and deploy.

```powershell
$t = "C:\Users\Diane\ShipGlows\shipglows\tools\feedback_triage.py"
python $t --project-root <repo> discover                    # what would be called; no call
python $t --project-root <repo> inbox [--format text] [--product <key>] [--limit 50] [--verify-tallies]
python $t --project-root <repo> apply --decisions <file.json> [--format text]   # dry run
python $t --project-root <repo> apply --decisions <file.json> --confirm
# --env prd only on an explicit operator decision; --backend-dir <dir> when several backends exist
```

## Discovery (never guessed)

- Backend: a `.shipglows.backend.json` (`shipglows.backend.v1`, `provider: convex`)
  at most two levels deep, next to a `convex/` directory whose `.ts` file calls
  `defineFeedbackFunctions`; the module is its `module:` option or the file name.
  Several candidates require `--backend-dir`.
- Doppler dev: the `doppler` block of `.shipglows.node.json` / `.shipglows.flutter.json`
  in that directory (then the repository root), else an `ENVIRONMENT.md` mention
  ``Doppler `<project>/dev` ``.
- Doppler prd (`--env prd` only): an `ENVIRONMENT.md` mention ``Doppler `<project>/prd` ``
  for the same project; absent, the command refuses.
- Deployment guard: before any call, `doppler run ... -- node -e` prints only the
  deployment selector (`dev:<name>`, the part of a deploy key before `|`). Dev must
  be `dev:` and match the `readiness.url` host of `.shipglows.backend.json`; prd must
  be `prod:`. The decision file names the same deployment.
- Calls: `doppler run --project <p> --config <c> --no-fallback -- node <backend>/node_modules/convex/bin/main.js run <module>:<fn> <json>`
  (the product's installed CLI, same as `npx convex run`, without a shell, so JSON
  arguments survive on Windows). No secret value is read, stored or printed;
  CLI errors are redacted and truncated.
- Product keys and roadmap items: the sites of `.shipglows.product-updates.json`
  that declare `@shipglows/astro-roadmap` (`src/content/roadmap/<locale>/<id>.md`).

## Inbox

Calls only `triageListFeedback` (`status: new`, per product key),
`triageListRequests` (`moderation: pending`, filtered on the product keys) and the
public `counts` query; `--verify-tallies` adds `verifyVoteTallies` without `fix`.
Account keys (`userId`, `authorId`), signed audio URLs and build hashes are dropped.

Suggestions are lexical (accent-folded tokens, stop words removed, prefix match):
`matchingItems` (score ≥ 0.3 against item titles and ids), the requester's declared
`possibleDuplicates`, and likely duplicate feedback or requests (score ≥ 0.6).
They are hints for the agent's proposal, never decisions.

## Decision file

```json
{
  "schema": "shipglows.feedback-triage-decisions/v1",
  "env": "dev",
  "deployment": "dev:gallant-yak-850",
  "operator": "diane",
  "decisions": [
    { "action": "create-item", "id": "dark-theme", "status": "considering",
      "title": { "en": "Dark theme", "fr": "Thème sombre" },
      "summary": { "en": "…", "fr": "…" } },
    { "action": "approve-request", "requestId": "req_…", "itemId": "dark-theme", "note": "Ajouté." }
  ]
}
```

| Action | Convex call |
| --- | --- |
| `create-item` (`id`, `status` considering/planned/in_progress, bilingual `title`/`summary`) | none: one `CONTEXT_DECISION` history event with `public.roadmap`, projected hidden into every declared site |
| `approve-request` (`requestId`, `itemId`, `note?`) | `moderateRequest` `approved` |
| `merge-request` (`requestId`, `itemId` or `intoRequestId`, `note?`) | `moderateRequest` `merged` |
| `reject-request` (`requestId`, `note?`) | `moderateRequest` `rejected` |
| `merge-items` (`fromItemId`, `toItemId`) | `mergeItems` (vote transfer) |
| `link-feedback` (`feedbackId`, `itemId?`, `requestId?`, `classification?`, `status?`, `note?`) | `triageFeedback` |
| `mark-bug` (`feedbackId`, `itemId?`, `status?`, `note?`) | `triageFeedback` `classification: bug` |
| `mark-duplicate` (`feedbackId`, `duplicateOfFeedbackId`, `status?` default archived, `note?`) | `triageFeedback` `classification: duplicate` |
| `archive-feedback` (`feedbackId`, `classification?`, `note?`) | `triageFeedback` `status: archived` |
| `verify-tallies` (`itemIds?`, `fix?`) | `verifyVoteTallies` |

The whole file is validated before anything runs: unknown fields, invalid slugs,
statuses or classifications, secret-like notes, a referenced item that is neither in
the site content nor created by the file, or creating an existing item are refused.
`operator` is passed to the module's audit log (`operator:<name>`). With `--confirm`,
items are created first, then Convex calls run in file order and stop at the first
failure (`not-run` for the rest). The exit code is 1 when a step failed.

## Limits

- Suggestions are lexical, not semantic; the agent still reads the texts.
- Requests carry no votes: counts are per roadmap item and exist only for items
  present in the backend registry (`inRegistry`).
- A new item becomes votable after publication, deploy and the backend registry
  sync (`refreshRegistry` or `syncRegistry`, see the module README).
- Production triage is never a default; the prd deployment cannot be matched
  against a declared name, only its `prod:` kind.

## Proof

- `python -m unittest tools.test_feedback_triage tools.test_product_updates tools.test_context_history`
- Read-only: `python tools/feedback_triage.py --project-root <repo> inbox --format text` on dev.
