---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-05-30"
updated: "2026-05-30"
status: draft
source_skill: sg-docs
scope: external-platform-lemonsqueezy
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/documentation-freshness-gate.md
  - templates/project_platform_usage.md
  - shipglows_data/technical/external-platforms/README.md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "0.5.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Fresh external docs checked on 2026-05-30 against Lemon Squeezy docs, API reference, official GitHub organization, and public MCP registries/search results."
next_review: "2026-06-30"
next_step: "/sg-docs technical audit"
---

# Lemon Squeezy Platform Note

## Purpose

This note is the global ShipGlows source map for Lemon Squeezy. Use it before relying on assumptions about Lemon Squeezy API behavior, checkout creation, webhooks, refunds, license keys, test mode, SDKs, CLI, MCP, or Merchant of Record operations.

It does not replace Lemon Squeezy documentation. It records source links, current tool availability, and ShipGlows rules for payment-provider integrations.

## Source Map

Primary sources for Freshness Gate:

| Need | Source |
| --- | --- |
| API reference and endpoint list | https://docs.lemonsqueezy.com/api |
| API request/authentication rules | https://docs.lemonsqueezy.com/api/getting-started/requests |
| Checkout creation | https://docs.lemonsqueezy.com/api/checkouts/create-checkout |
| Webhook requests | https://docs.lemonsqueezy.com/help/webhooks/webhook-requests |
| Webhook signing | https://docs.lemonsqueezy.com/help/webhooks/signing-requests |
| Webhook event types | https://docs.lemonsqueezy.com/help/webhooks/event-types |
| Simulate webhook events | https://docs.lemonsqueezy.com/help/webhooks/simulate-webhook-events |
| Test mode | https://docs.lemonsqueezy.com/help/getting-started/test-mode |
| Merchant account activation | https://docs.lemonsqueezy.com/help/getting-started/activate-your-store |
| Fees / supported countries / prohibited products | https://docs.lemonsqueezy.com/help/getting-started/fees, https://docs.lemonsqueezy.com/help/getting-started/supported-countries, https://docs.lemonsqueezy.com/help/getting-started/prohibited-products |
| Official SDKs | https://docs.lemonsqueezy.com/api and https://github.com/lmsqueezy |
| Platform status | https://status.lemonsqueezy.com/ |

Freshness evidence on 2026-05-30:

- Official docs describe Lemon Squeezy as a JSON:API REST API with API-key authentication, test/live API keys, and a 300 requests/minute API rate limit.
- Official SDKs listed by Lemon Squeezy are JavaScript (`@lmsqueezy/lemonsqueezy.js`) and Laravel (`@lmsqueezy/laravel`); the official GitHub organization is `lmsqueezy`.
- No official Lemon Squeezy CLI was identified in the official docs or official GitHub organization.
- No official Lemon Squeezy MCP server was identified in the official docs or official GitHub organization.
- Third-party MCP options exist, including Pipedream-hosted Lemon Squeezy MCP and community GitHub MCP servers. Treat these as untrusted automation wrappers until individually reviewed.

## Freshness Gate Use

Use `fresh-docs checked` only after checking the relevant official Lemon Squeezy page and local project usage note.

Use `fresh-docs gap` when:

- A task depends on Lemon Squeezy CLI or MCP availability and no current source confirms the tool.
- Checkout creation relies on request fields not verified against the current Create Checkout docs.
- Webhook parsing assumes custom data, signature headers, event names, refund events, or test/live markers without checking current webhook docs.
- Refund, subscription, discount, license-key, or customer operations are added without checking the exact endpoint docs and permission model.
- A project uses Lemon Squeezy for payments/webhooks but lacks a governance-root usage note.

Use `fresh-docs conflict` when current official docs contradict local implementation or a planned integration.

## ShipGlows Decision Rules

- REST API plus signed webhooks are the canonical integration layer unless Lemon Squeezy publishes an official CLI/MCP that meets our security bar.
- Prefer the official JavaScript SDK only when it reduces real integration risk; REST calls are acceptable and often clearer for narrow checkout/webhook flows.
- Treat Lemon Squeezy as a provider event source, not an entitlement source of truth. Product access must live in the suite/product entitlement ledger.
- Webhook verification must use the exact raw body and official signature rules before JSON parsing is trusted.
- Checkout success redirect is not proof of payment. Access changes must be driven by verified webhook events and idempotent fulfillment.
- Test mode proof must use test-mode API keys/store data and must not be confused with production entitlement grants.
- API keys are broad secrets. Never expose them to client code or automation tools that can execute arbitrary write operations.
- Do not use third-party MCPs for production refunds, product edits, webhook mutation, or customer data access without a reviewed threat model and explicit operator approval.
- Use direct API calls or official dashboard evidence for payment smoke proof until an MCP/CLI has been explicitly adopted in a project usage note.

## MCP / CLI Assessment

Current status:

- Official CLI: not identified.
- Official MCP: not identified.
- Official automation interface: REST API, official JavaScript SDK, official Laravel SDK, webhooks, dashboard, and documented integrations.
- Third-party MCPs: possible future convenience layer, not an architectural dependency.

Allowed future MCP use cases after review:

- Read-only inspection of stores, products, variants, orders, and webhooks in test mode.
- Creating test-mode checkout links for local/preview smoke.
- Fetching redacted order/refund metadata for support diagnosis.

Disallowed by default:

- Production refunds, subscription cancellations, product/price changes, webhook endpoint changes, or customer/license mutations.
- Any MCP operation where API key scope cannot be constrained or operation logs cannot be redacted.
- Any MCP hosted by an unreviewed third party for production customer/payment data.

## Common Project-Local Fields

A Lemon Squeezy usage note should maintain:

- store/test/live mode strategy
- product and variant mapping by internal offer id
- required environment variable keys, never values
- checkout route, success redirect, and cancel/retry behavior
- webhook URL, signature secret key name, and idempotency key strategy
- refund/revoke behavior and entitlement-ledger owner
- manual/provider smoke checklist
- MCP/CLI status: official, third-party, blocked, or intentionally not used

Use `templates/project_platform_usage.md` as the starter structure.

## Security Notes

- Never store Lemon Squeezy API keys, webhook secrets, customer emails, order payloads, checkout URLs containing sensitive query data, or raw webhook bodies in ShipGlows docs.
- Treat API keys as live payment credentials. Prefer isolated test-mode keys for automation.
- Treat webhook secrets as server-only. Do not expose them to public sites, mobile apps, MCP clients, or browser scripts.
- Redact customer identifiers in support and verification evidence unless a private support artifact explicitly requires them.
- Treat third-party MCPs as supply-chain and data-exposure risk until reviewed.

## Validation

For documentation-only changes:

```bash
python3 /home/claude/shipglows/tools/shipglows_metadata_lint.py /home/claude/shipglows/shipglows_data/technical/external-platforms/lemonsqueezy.md
rg -n "Freshness Gate|Source Map|MCP / CLI Assessment|ShipGlows Decision Rules|Maintenance Rule" /home/claude/shipglows/shipglows_data/technical/external-platforms/lemonsqueezy.md
```

For project code changes:

```bash
pnpm test tests/commerce/*.test.ts
pnpm build:check
```

Provider smoke remains manual/provider-backed until a reviewed tool exists:

```text
Create test-mode checkout -> complete order -> receive signed order_created webhook -> verify suite entitlement/code path -> simulate or perform refund -> verify non-granting access.
```

## Reader Checklist

- `LEMONSQUEEZY_*`, checkout routes, webhook routes, provider adapters, refunds, license keys, or product/variant mapping changed -> read this note and the project usage note.
- User asks for CLI/MCP automation -> verify official availability first; if third-party, classify as untrusted until reviewed.
- Payment or entitlement behavior changes -> verify product ledger ownership and no email-only auto-grant.
- Provider smoke requested -> prefer official dashboard/API evidence, not unreviewed MCP writes.

## Maintenance Rule

Update this note when Lemon Squeezy publishes an official CLI, official MCP, changes official SDKs, changes checkout/webhook/refund/API behavior, changes test-mode/live-mode rules, changes rate limits, or when ShipGlows adopts a reviewed MCP/CLI path.
