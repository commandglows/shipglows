# Vercel Tooling Reference

Use this reference when the bug touches hosting, deploy state, runtime logs, preview behavior, or project-level Vercel wiring.

Sources checked:
- https://vercel.com/docs/agent-resources/vercel-mcp
- https://vercel.com/docs/cli
- https://vercel.com/docs/projects/deploy-from-cli

Last reviewed: 2026-04-26

## Standard ShipGlows Setup

- Vercel MCP endpoint: `https://mcp.vercel.com`
- Vercel CLI install: `pnpm add -g vercel`

## Use Vercel MCP When

- The agent needs deployment status, build logs, runtime logs, toolbar threads, or project metadata.
- The issue may depend on preview vs production state.
- You want agent-native access to Vercel resources without reimplementing dashboard steps.

Typical MCP use cases:

- inspect deployments
- inspect build failures
- inspect runtime logs
- read toolbar feedback threads
- inspect linked project metadata

## Use Vercel CLI When

- You are operating from a local checkout and need to link, deploy, inspect, or test manually.
- You need commands that are naturally terminal-driven.

Primary commands:

- `vercel login`
- `vercel link`
- `vercel list`
- `vercel logs`
- `vercel env`
- `vercel mcp`

## Do Not Use Vercel MCP For

- Replacing browser evidence when the bug is purely client-side auth UI behavior.
- Guessing app-level auth logic that actually lives in Clerk, middleware, or app code.

## Default Debug Policy

1. Use Vercel MCP when the problem may be in platform state, logs, previews, or deployments.
2. Use Vercel CLI when the operator needs to link, deploy, or inspect locally.
3. Fall back to Playwright/browser evidence when the failure is visible in the app UI rather than in the Vercel platform.

## ShipGlows Development Mode

When the project documents `development_mode: vercel-preview-push`, Vercel MCP is the authority for deciding whether the latest pushed auth fix is ready to test. The auth-debug sequence is:

1. `005-sg-ship` pushes the change.
2. `405-sg-prod` waits for the matching Vercel deployment and returns the deployment URL.
3. `109-sg-auth-debug` uses Playwright against that URL for OAuth, callbacks, cookies, sessions, middleware, and protected-route proof.

In `hybrid` mode, use the same sequence for hosted-only auth behavior: OAuth callback domains, provider allowlists, secure cookies, serverless/edge middleware, deployed env vars, and bugs that reproduce only on preview or production.

Do not treat a localhost auth success as evidence that the Vercel preview is fixed when the failure depends on hosted domains, deployment env vars, callback URLs, or provider configuration.
