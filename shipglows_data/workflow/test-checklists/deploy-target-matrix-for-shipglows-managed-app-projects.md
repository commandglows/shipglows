# Test Checklist: Deploy Target Matrix for ShipGlows-Managed App Projects

## Scope

Manual coherence checklist for the advisory deploy-target matrix and its owner-skill/doc integration.

## Scenarios

| Scenario ID | Surface | Scenario | Required | Expected | Status | Observed | Evidence pointer | Notes | Bug Link |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| DTM-001 | web hosting | Ordinary website or Vercel-compatible web app | yes | Vercel is recommended without consulting the dedicated-server ranking. | PASS | Canonical rule states Vercel web default. | skills/references/deploy-target-matrix.md | Operator decision plus focused scan on 2026-07-16. | |
| DTM-002 | server hosting | Dedicated FastAPI or equivalent server | yes | Railway is the default only after a real dedicated-server requirement is established. | PASS | Canonical rule enters the Railway-first matrix only after dedicated-server classification. | skills/references/deploy-target-matrix.md | Operator boundary decision plus focused scan on 2026-07-16. | |
| DTM-003 | server hosting | Dedicated preview-heavy server workflow | yes | Render can override Railway because the server review workflow dominates. | PASS | Canonical dedicated-server exception selects Render for preview-heavy review workflows. | skills/references/deploy-target-matrix.md | Focused scenario scan on 2026-07-16. | |
| DTM-004 | server hosting | Dedicated server with advanced topology | yes | Fly.io can override the server default because infra/topology control dominates. | PASS | Canonical dedicated-server exception selects Fly.io for advanced topology and networking control. | skills/references/deploy-target-matrix.md | Focused scenario scan on 2026-07-16. | |
| DTM-005 | server hosting | Dedicated server with sovereignty or private-cloud needs | yes | Codesphere can override the server default because sovereignty or private-cloud posture dominates. | PASS | Canonical dedicated-server exception selects Codesphere for sovereignty and private-cloud needs. | skills/references/deploy-target-matrix.md | Focused scenario scan on 2026-07-16. | |
| DTM-006 | split hosting | Compatible web frontend plus dedicated backend | yes | Keep the web frontend on Vercel by default and apply the server matrix only to the backend. | PASS | Canonical rule classifies and recommends each surface separately. | skills/references/deploy-target-matrix.md | Focused scan on 2026-07-16. | |

## Coherence Checks

- [ ] `skills/references/deploy-target-matrix.md` is the only canonical source of the full ranking logic.
- [ ] `skills/004-sg-deploy/SKILL.md` points to the matrix without overstating automation support.
- [ ] `skills/000-shipglows/SKILL.md` and `skills/references/entrypoint-routing.md` route deploy-target advice through `004-sg-deploy`.
- [ ] Public/operator docs keep the advice boundary explicit: ShipGlows advises, final choice remains project-contextual.

## Evidence Notes

- `2026-07-05`: the original `DTM-001` exposed the old undifferentiated rule by recommending Railway for a generic founder app.
- `2026-07-16`: operator correction establishes the missing classification boundary: ordinary sites and compatible web apps default to Vercel; Railway begins only in the dedicated-server lane. Focused scans then replayed all six web, server, exception, and split-surface scenarios successfully.
