---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: active
source_skill: 900-shipglows-core
scope: reporting-closure
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/reporting-contract.md
depends_on: []
supersedes: []
evidence:
  - "Approved progressive loading pilot preserves the existing behavior in directly selected references."
next_review: "2026-10-05"
next_step: none
---

# Reporting Closure

Select directly only when claiming closed, complete, done, resolved, or shipped.
The reporting owner has already selected the independent documentation and editorial
reflection authorities. Apply their results; this leaf loads no sibling.

For every successful closure report, render this stable card after the header. Keep the two header lines adjacent. Then render every section as one complete line containing its icon, translated label, colon when the section contains prose, and content; insert exactly one blank line between sections. Keep proof items, statuses, scopes, and reasons compact on their section line and separate them with ` · `.

Before rendering the documentation line, apply `documentation-reflection-gate.md` to the exact task-owned changed paths and canonical code-docs map. The report must not invent or infer the classification from unchanged public copy, generic test success, memory, graph output, or a plausible sentence; it renders the gate result. Editorial impact remains independent.

```text
✨ RÉSULTAT : <one compact outcome paragraph>

🧪 PREUVES ✅ <proof 1> · <proof 2> · <proof 3>

📖 DOCUMENTATION ✅ updated · <aligned documentation scope>

✏️ ÉDITORIAL ➖ not impacted · <concrete reason>

📰 CHANGELOG 🔒 internal-only · <concrete reason>

📦 LIVRAISON ✅ Commit local : `<sha>` · ➖ Push : non effectué
```

Translate the six labels and explanatory text into the user's active language while preserving the main icons, the ` · ` separator, stable status values, hashes, and machine labels. `✨ RÉSULTAT`, `🧪 PREUVES`, `📖 DOCUMENTATION`, `✏️ ÉDITORIAL`, `📰 CHANGELOG`, and `📦 LIVRAISON` are mandatory for closure; `⚠️ LIMITES` is conditional; `🧭 SUITE` is mandatory. Delivery remains truthful when Git is irrelevant, for example `➖ Aucun commit ni push · tâche sans mutation`. Never use that form for modified files, including documentation.


The documentation line uses exactly one of: `✅ updated · <scope>`, `➖ not impacted · <concrete reason>`, or `⚠️ needs review · <surface>`. A material `needs review` result forbids closure or shipping language. Non-closure progress reports omit the documentation block unless its status materially affects trust.

The editorial line independently uses the same three status values. A material editorial `needs review` result forbids closure or shipping language. `No declared public surface` is a valid concrete `not impacted` reason; never create filler content to avoid that result.

Editorial alignment and editorial/product opportunity are separate decisions. The visible `✏️ ÉDITORIAL` line reports existing-surface alignment only. Classify opportunity independently as `candidate`, `no evidenced opportunity`, or `not assessed`; `not impacted` alignment never proves or implies no opportunity. A credible `candidate` is non-blocking and appears in `🧭 SUITE` with its audience and value. It never authorizes content, product work, publication, or a roadmap write. Omit the two negative opportunity states from user reports and never run extra research solely to classify them.

The changelog line classifies every managed-repository closure independently from documentation and editorial work. Use exactly one of: `✅ public-ready · <eligible user-facing change and prepared projection>`, `🔒 internal-only · <significant internal event and concrete reason>`, `➖ not applicable · <no significant changelog event and concrete reason>`, or `⚠️ needs review · <unresolved public eligibility, copy, safety, or evidence gap>`. `public-ready` means the allowlisted public projection is complete enough for its declared delivery path; it never means published, deployed, or available. Those claims require matching delivery evidence. Record at most one significant event for the closure when structured history is adopted. A material `needs review` result forbids clean closure or shipping language; `internal-only` and `not applicable` are honest successful outcomes and never justify filler public content.

After the mandatory `🧭 SUITE`, a completed chantier may additionally offer this compact continuation choice block only when the delivered result has a useful decision surface:

```text
1. 🔎 Approfondir — examiner davantage les opportunités, risques, hypothèses ou enseignements du résultat.
2. 🧭 Réorienter — explorer des directions alternatives concrètes à partir du résultat livré.
```

Selecting `Approfondir` or `Réorienter` starts guided follow-up, does not reopen the completed chantier, and never grants mutation approval. Omit the block when no useful continuation exists; do not append a ceremonial menu to every closure.
