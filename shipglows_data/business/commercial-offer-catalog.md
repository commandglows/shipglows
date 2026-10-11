---
artifact: business_profile
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-18"
updated: "2026-10-07"
status: reviewed
source_skill: 900-shipglows-core
scope: commercial-offer-catalog
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/business/business.md
  - shipglows_data/business/product.md
  - portfolio:shipglows_app
depends_on: []
supersedes: []
evidence:
  - "The ShipGlows business/product contract says Cockpit may become a separate SaaS later but carries no current pricing or availability promise."
next_review: "2026-11-18"
next_step: "Update this catalog only after a product owner makes a commercial decision."
---

# ShipGlows Commercial Offer Catalog

ShipGlows is a registered product namespace but has no current paid offer. The ShipGlows App repository is a delivery surface of this authority, not a second commercial product.

<!-- commercial-catalog:start -->
```json
{
  "schemaVersion": "1.0",
  "repositoryKey": "shipglows",
  "authorityStatus": "not_monetized",
  "catalogOwner": "Diane",
  "entitlementParticipation": "suite_registered",
  "surfaceOf": null,
  "products": [
    {
      "productId": "shipglows",
      "aliases": [],
      "status": "not_monetized",
      "offers": []
    }
  ],
  "decisionSources": [
    "shipglows_data/business/business.md",
    "shipglows_data/business/product.md"
  ],
  "historicalSources": [],
  "unresolvedDecisions": [
    "Whether ShipGlows becomes a commercial product",
    "Offer, plan, term, price, feature, quota, activation, and provider model if monetized"
  ]
}
```
<!-- commercial-catalog:end -->

Authentication, installation, or a planned Cockpit/Studio capability cannot be presented as a purchased plan.
