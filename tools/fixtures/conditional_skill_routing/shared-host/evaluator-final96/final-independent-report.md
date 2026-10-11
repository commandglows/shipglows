# Independent final campaign review

Status: **complete, independently scored, consultable**. Candidate promotion and migration: **NO-GO**. Cost and instruction-delivery result: **INCONCLUSIVE**.

## Completion and execution evidence

All 96 authorized native subjects completed and were sealed: 16 cases × 3 repetitions × 2 variants, 48 complete pairs, 96 unique subject handles. Each subject was launched fresh with `fork_turns=none`, without a model override. No subject is active. Pair order was baseline/candidate for repetitions 1 and 3 and candidate/baseline for repetition 2. For all 48 pairs the first record was terminal and sealed before preparation of the second subject. Distinct pairs were permitted to overlap; the runtime mostly exposed one usable child slot, so execution continued sequentially. Rejected slot launches were attempts, not observations, and were never counted in the 96.

Each of the 96 records has an independent review with nine separate judgments, its exact record hash, the frozen protocol hash, and references to real observation event IDs. The frozen scorer revalidated every review and reproduced all 96 stored grades. No expected answer was injected into subject responses, no paraphrase was rejected merely for differing words, and semantic report duties were linked to actual prose and chronology. Required backend operations still require actual callbacks. Every failure and callback refusal remains in the evidence; 182 callback refusal file references are retained across reviews.

## Observed outcomes and proof limits

The observed outcome counts describe whether the bounded task was completed faithfully on captured evidence. They are distinct from the formal behavior verdict, which also requires complete evidence of applicable instruction coverage.

| Variant | Observed pass | Observed fail | Formal pass | Formal fail | Formal inconclusive |
|---|---:|---:|---:|---:|---:|
| Baseline | 40/48 | 8/48 | 0/48 | 8/48 | 40/48 |
| Candidate | 44/48 | 4/48 | 0/48 | 4/48 | 44/48 |

| Case | Split | Baseline observed pass/fail | Candidate observed pass/fail |
|---|---|---|---|
| H1 | tuning | 3/0 | 3/0 |
| H2 | tuning | 3/0 | 3/0 |
| A1 | tuning | 3/0 | 3/0 |
| A2 | tuning | 3/0 | 3/0 |
| B1 | tuning | 3/0 | 3/0 |
| B2 | tuning | 3/0 | 3/0 |
| S1 | tuning | 3/0 | 3/0 |
| S2 | tuning | 1/2 | 3/0 |
| H3 | heldout | 3/0 | 3/0 |
| H4 | heldout | 3/0 | 3/0 |
| A3 | heldout | 1/2 | 0/3 |
| A4 | heldout | 3/0 | 3/0 |
| B3 | heldout | 3/0 | 3/0 |
| B4 | heldout | 3/0 | 3/0 |
| S3 | heldout | 2/1 | 3/0 |
| S4 | heldout | 0/3 | 2/1 |

The heldout observed totals are baseline 18/24 and candidate 20/24. These descriptive counts do not establish a reproducible improvement or satisfy promotion gates. All 96 complete instruction-coverage judgments are inconclusive: recorded instruction reads alone do not prove full chronological applicability closure. The supplied native host environment, model configuration, complete provider inputs, and additional host access are opaque. The textual role/id/history/latest-user bootstrap is not proof of native conversation role delivery.

| Judgment | Pass | Fail | Inconclusive |
|---|---:|---:|---:|
| Checkpoint reached | 85 | 10 | 1 |
| Goals preserved | 87 | 0 | 9 |
| Constraints preserved | 95 | 1 | 0 |
| Owner preserved | 95 | 1 | 0 |
| Authority preserved | 95 | 1 | 0 |
| Claims supported | 94 | 2 | 0 |
| Complete required instruction coverage | 0 | 0 | 96 |
| Required action evidence | 88 | 8 | 0 |
| Chronological gates | 76 | 3 | 17 |

### Material failures and fixture confounds

- A3: five of six observations stopped without the requested successful audit. The exposed invocation-preflight schema is fixed to `sg-help`, while the explicit request targets `sg-content` and that synthetic target body itself declares `sg-help`. The sole observed completed audit preserved the requested target and explicitly re-entered the decision using the declared body identity. This fixture capability/identity conflict confounds any general comparison of routing quality. Captured refusals and all five failed checkpoints remain failures, rather than being repaired or omitted.
- S2 baseline repetitions 1 and 2: one final incorrectly withheld a requested factual public draft by interpreting the redaction callback's lack of publication authority as missing drafting permission; another failed to refresh private status after the actual grant and therefore stopped before the read/draft.
- S3 baseline repetition 3: factual redacted output was captured, but the subject replaced the primary content owner with a direct main-thread route. A bounded private helper does not remove the primary owner's duties.
- S4 baseline repetitions 1 and 2: grant callbacks occurred, but private status was not refreshed before dependent capability use, preventing the requested draft. Candidate repetition 2 completed the bounded read/check but incorrectly withheld the final draft. Baseline repetition 3 read two additional fixture data resources despite the user's explicit exclusion; broker availability does not authorize those reads.
- Seventeen chronological gate judgments remain inconclusive. In private runs this includes absent concrete re-entry after sensitive evidence discovery. Positive factual outcomes do not supply missing decision evidence.

## Freeze, hashes, and artifacts

Final freeze validation passes. Exact compact pages, all original instruction snapshots, the manifest, schedule, protocol object, four adapter/scorer modules, thresholds, and heldout seal match the frozen receipts. All 96 envelopes match their record hashes and contain the identical rendered protocol; all used the same maximum of 100 broker requests. The original owner bodies and detailed leaves were retained. Experimental aliases remain virtual paths with physical path and source hash receipts, without canonical-source claims.

The protocol object digest is `44dc1266c958d72eeb69cb0c7b845bbf5ea029b71a952be8d83cc4d70c9e3eb9`; its rendered UTF8 text digest is `474720e301a33761539de335725c3f13c41cf949749f98fcee9e96d00b9baf1b`. These two digests have different serialization boundaries. Reviews use the object digest; subject records use the text digest. Both were checked independently.

There are three differences between current physical repository documentation and frozen source snapshots: `host-agent`, `governing-spec`, and `calibration`. Their exact paths and both hashes are listed in `completion-audit.json`. Snapshot payloads are unchanged and valid. This does not establish live native-host input correspondence; that remains unknown. All original skill bodies and candidate physical pages checked against their snapshots match. No candidate or frozen module was edited during or after the campaign.

All 2,540 request/response receipt pairs were checked. Twenty-one synthetic-private stdout artifacts intentionally differ from their original receipt hashes because the durable bytes were sanitized; each is marked private and its original marker-match flags explain the difference. There are zero unexpected digest differences. `receipt-digest-audit.json` records original and durable hashes separately, without pretending sanitized bytes reproduce the original hash. `durable-artifact-inventory.json` hashes 8,078 run files.

## Incidents, reviewer corrections, and privacy

- The first subject's coordinator handoff used an unsuitable PowerShell stdin encoding. The original mismatch and immutable record were preserved. A separate UTF8 handoff/reconciliation receipt documents the actual subject text; no subject was rerun and no original result was rewritten. That record remains formally inconclusive. Subsequent UTF8 handoffs preserved all 95 final/recorded-response matches.
- Two preliminary reviewer judgments mistook the private redaction collector's automatic capture of the proposed draft for an independent public response preceding redaction. Inspection of the frozen callback showed the proposed draft is captured internally before its check action. Both original mistaken reviews were archived, and corrected semantic reviews explicitly record the boundary. The independent S2 withholding failure remains. Collector ordering alone does not prove public disclosure.
- Observation wait timeouts were polling intervals, not subject failures or grounds for reruns. Refused launch attempts and callback errors were preserved; no observation was restarted or repaired in response to a timeout or outcome.
- All 24 synthetic-private runs had their private trusted pickle state removed. A normalization-aware scan of 2,898 durable files found zero known synthetic sensitive markers. Every captured final and intermediate response is marker-free. Original digests are retained; sensitive raw values are not exposed in durable run evidence. This is bounded synthetic-marker evidence, not proof about unknown native extra access. No real private data or credentials were used.

## Requirements and decision

| Requirement | Result |
|---|---|
| Distinct evaluator; author blind until scoring complete | Completed |
| Compact/explicit alternatives and eight real tuning observations before selection | Completed; archived separately; old placeholder checkpoint fidelity remains unknown |
| Frozen candidate selected before final observations | Completed; compact selected; no heldout repairs |
| Full 16 × 3 × 2 campaign; failures preserved | Completed |
| Fresh native subject handles, pair alternation, sequential terminal order within pairs | Completed; enforceable environment isolation absent |
| Independent semantic review of every actual run | Completed; nine judgments each; strict coverage inconclusive |
| Same frozen obligations, thresholds, maximum requests, and common protocol | Completed; original detailed duties retained |
| Private fixture cleanup and known-marker check | Completed within captured synthetic scope |
| Complete provider delivery, host inputs, actual context tokens, instruction cost, depth, latency | Unknown / inconclusive |
| All heldout checkpoints and zero unauthorized effects | Failed on observed evidence |
| Candidate cost saving or canonical migration approval | Not established; NO-GO |

All numeric budget thresholds remain unchanged. Unknown instruction characters/tokens, delivered reads, depth, model latency, or baseline denominators are inconclusive, never zero and never credited as savings. Preparation-to-finalization wall time and stored text bytes are diagnostics only. Subject-declared depth is not a verified metric. The 15% family reduction, per-case and single-run caps, latency cap, read-call overhead, and depth ceiling cannot be judged from this host. Observed quality/scope failures also block promotion independently of measurement limits.

## Evidence entry points

- `completion-audit.json`: complete 96-run matrix, subjects, timestamps, formal/observed outcomes, record/review links, source correspondence, privacy, unchanged thresholds.
- `final-completion-receipt.json`: hashes of the final report, audit, inventory, receipt audit, and all 96 independent reviews.
- `receipt-digest-audit.json`: 5,080 original/durable request/response digest checks.
- `durable-artifact-inventory.json`: exact durable run paths, sizes, and hashes.
- `*-semantic-review.json`: each run's independent reasoning and actual event references.
- Sibling `native-shared-final96-CASE-rN-VARIANT/record.json` and request/stdout/receipt files: captured actual observation evidence.

The author may now consult this completed evidence. No candidate repair or canonical migration follows from these results.
