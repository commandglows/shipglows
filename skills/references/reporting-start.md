---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: active
source_skill: 900-shipglows-core
scope: reporting-start
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

# Reporting Start

Select directly from reporting-contract.md only at the approved substantive start.

After approval and at the true start of a substantive chantier, render this card once. Do not use it while approval is pending or for a branch-free micro-action.

```text
✨ OBJECTIF
<one compact outcome promise>

📐 PÉRIMÈTRE
✅ <in scope> · ➖ <material out of scope>

🛡️ GARDE-FOUS
✅ <applicable mandatory implementation rules>

🧪 PREUVES ATTENDUES
✅ <proof 1> · <proof 2> · <proof 3>

📖 DOCUMENTATION PRÉVUE
✅ Impactée · <mapped documentation scope>
```

Use `🎯 VERDICT (HH:mm) : 🚀 Démarré` in the header. Translate labels and explanatory text into the user's active language while preserving the main icons. Keep the content beneath scope, expected proof, and planned documentation each on exactly one line; the guardrails line follows the same rule and uses ` · `. Objective, scope, expected proof, and planned documentation are always mandatory. `🛡️ GARDE-FOUS` is additionally mandatory for substantive authored or materially modified code and follows `implementation-excellence-preflight.md`; omit it for `IEP-MICRO-EDIT` and non-code chantiers. Add `🧭 APPROCHE` only when the strategy materially improves operator understanding.

The planned documentation line uses exactly one of: `✅ Impactée · <scope included in the chantier>`, `➖ Non impactée · <concrete reason>`, or `⚠️ À confirmer · <surface>`. It is a plan, not a closure claim; only the closure card may use `updated`, `not impacted`, or `needs review`.
