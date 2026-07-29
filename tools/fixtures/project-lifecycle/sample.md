---
artifact: project_lifecycle
project: Example Site
status: draft
---

# Project Lifecycle: Example Site

## Lifecycle Items

| Item ID | Instance ID | Type | Domain | Title | Required | State | Due At | Cadence | Timezone | Evidence | Tracker Route | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| seo-launch-gate | example-site:seo-launch-gate:launch | one_time | seo | SEO launch gate | yes | verified | 2026-07-20T10:00:00+00:00 | - | UTC | reports/seo-launch.md | technical_task | None |
| security-review | example-site:security-review:2026-07-27 | recurring | cybersecurity | Weekly security review | yes | verified | 2026-07-27T09:00:00+00:00 | weekly | UTC | reports/security-2026-07-27.md | technical_task | Review dependency and access findings |
| copy-review | example-site:copy-review:2026-07-29 | recurring | copywriting | Copy review | yes | not_started | 2026-07-29T10:00:00+00:00 | monthly | UTC | - | editorial_task | Review public copy |
| performance-fix | example-site:performance-fix:2026-07-26 | one_time | performance | Fix LCP regression | yes | in_progress | 2026-07-26T12:00:00+00:00 | - | UTC | - | technical_task | Attach Lighthouse report |
