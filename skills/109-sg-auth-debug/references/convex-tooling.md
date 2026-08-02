# Convex Tooling Reference

Use this reference when the bug touches Convex project setup, auth sync, backend deployment state, or Convex-assisted agent workflows.

Sources checked:
- https://docs.convex.dev/cli
- https://docs.convex.dev/ai/convex-mcp-server
- https://docs.convex.dev/auth/clerk
- https://docs.convex.dev/auth/debug

Last reviewed: 2026-04-26

## Standard ShipGlows Setup

- Convex MCP command: `npx -y convex@latest mcp start`
- Convex CLI install: `pnpm add -g convex`

## Use Convex MCP When

- The agent needs Convex-aware help tied to the project schema, functions, or deployment context.
- You want agent tooling around Convex code and deployment metadata.

## Use Convex CLI When

- You need to set up or sync a real Convex project.
- You changed `convex/auth.config.ts` or other backend config that must be pushed.
- You need deployment control, local dev sync, or account logout/login behavior.

Primary commands:

- `npx convex dev`
- `npx convex deploy`
- `npx convex logout`
- `npx convex`

## Clerk + Convex Auth Bugs

Use the tools together:

1. Clerk CLI for Clerk-side config or environment diagnostics.
2. Convex CLI for syncing backend auth config and deployment state.
3. Playwright or browser/network evidence for proving whether the Clerk token handoff reaches Convex correctly.

Important rule:

- If `convex/auth.config.ts` changes, rerun `npx convex dev` or deploy sync before trusting any diagnosis.

## Do Not Use Convex MCP For

- Replacing a required `convex dev` or deploy sync after config changes.
- Proving browser cookie or redirect behavior on its own.

## Default Debug Policy

1. Use Convex MCP when the agent needs Convex-aware code or deployment context.
2. Use Convex CLI when the issue may depend on auth config sync, deployment state, or project setup.
3. Use Playwright/browser evidence when the break happens across the Clerk-to-Convex browser handoff.
