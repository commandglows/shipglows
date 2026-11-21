# ShipGlows Model Routing

Model IDs last aligned on 2026-11-21: OpenAI tiers from the official latest-model/migration guide snapshot of 2026-10-08 plus the operator's current subagent rule; Claude IDs and the paid relay from the operator's current runtime configuration.

This reference must stay short and is the only detailed model catalogue in ShipGlows. If a question depends on "latest", exact availability, default model, pricing, or a recent change, revalidate against official provider docs and the runtime model list before answering.

Before applying this matrix, load `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`. Model routing optimizes first for reliability, security, performance relevance, maintainability, excellence, and proof quality. Speed, cost, and latency are tie-breakers only between quality- and excellence-equivalent options.

## Freshness sources

- OpenAI/Codex: use `https://developers.openai.com/api/docs/guides/latest-model` before making latest/current/default or migration claims. Check the current runtime's supported model list separately: provider documentation does not guarantee session access.
- Claude Code: prefer aliases from Anthropic docs (`opusplan`, `opus`, `sonnet`, `sonnet[1m]`, `haiku`) unless an orchestration tool or the operator requires a full model ID.
- Operator rules (for example a global `CLAUDE.md`) take precedence over these defaults for subagent model, effort, and relay choice.
- Never invent pricing, model availability, context windows, or provider-specific parameters.

## Current model IDs

| Provider | Tier / alias | Current ID | Notes |
| --- | --- | --- | --- |
| OpenAI/Codex | Sol (frontier) | `gpt-6-astra` | Flagship tier; succeeded `gpt-5.6-sol`. |
| OpenAI/Codex | Terra (balanced) | `gpt-5.6-terra` | Last documented balanced tier; confirm a GPT-6 successor in the runtime list before pinning. |
| OpenAI/Codex | Luna (light) | `gpt-6-luna` | Default cheap subagent model. |
| Anthropic | `opus` | `claude-opus-5-5` | Strongest Claude model; risk-path escalation target. |
| Anthropic | `sonnet` | `claude-sonnet-5-5` | Balanced execution. |
| Anthropic | `haiku` | `claude-haiku-5-5` | Default cheap Claude subagent model. |
| Anthropic | full ID only | `claude-fable-5-2` | Use only when the operator or runtime names it. |
| Paid relay | `grok` provider | `grok-4.7` | Relay when OpenAI or Anthropic cannot launch the child; otherwise the newest usable `grok-4*`. |

Earlier IDs (`gpt-5.5`, `gpt-5.4-mini`, `gpt-5.3-codex`, `gpt-5.6-sol`, `gpt-5.6-luna`) are historical: keep them in archived specs and logs, never as new defaults.

## Codex/OpenAI map

- Sol tier (`gpt-6-astra`)
  - frontier model for complex, ambiguous, cross-project, tool-heavy, product-spec-to-plan, and high-error-cost work
  - default OpenAI choice for transverse audits, automatic task prioritization, prompt/docs migrations, business-risk synthesis, model-policy updates, and coherent tracker/project-fiche updates
  - starts well at `medium` reasoning; use `high` or `xhigh` only when the task justifies latency/cost
- Terra tier (`gpt-5.6-terra`)
  - balanced option when frontier quality is likely overkill or cost/latency control matters
  - good fit for bounded architecture and important tradeoffs
- Luna tier (`gpt-6-luna`)
  - lightweight quality-equivalent entry point for small and medium low-risk tasks
  - good for triage, exploration, sub-tasks, and repeated iterations when the cost of error is low
- `codex`
  - ShipGlows implementation profile for long implementation, refactors, hard debugging, multi-file coding, and terminal-heavy agentic work
  - resolve to the current Codex-recommended implementation model before execution; do not pin this alias to a deprecated slug
- Spark
  - optional targeted iteration path only when requested and a Spark model is exposed by the runtime; it is not an assumed fallback

## Codex/OpenAI routing matrix

| Situation | Primary | Reasoning | Fast fallback | Cheap fallback |
| --- | --- | --- | --- | --- |
| Ambiguous spec, architecture, high error cost | Sol | `high` | Terra | Luna only for safe slices |
| Transverse audit, task prioritization, prompt/docs migration, business-risk synthesis | Sol | `medium` or `high` | Terra | Luna only for safe slices |
| Bounded premium architecture or tradeoff | Terra | `medium` or `high` | Luna | Luna |
| Long implementation, multi-file implementation, refactor, hard bug | `codex` implementation profile | `medium` or `high` | Terra | Luna only for bounded low-risk slices |
| Small feature, local fix, triage with low error cost | Luna | `low` or `medium` | Spark only if requested and available | Luna |
| Targeted UI iteration with bounded risk | Luna | `low` or `medium` | Spark only if requested and available | Luna |
| Long terminal-heavy agentic loop | `codex` implementation profile | `medium` | Sol | Luna only for bounded low-risk slices |

## Claude Code map

- `opusplan`
  - hybrid alias: Opus during Plan Mode, Sonnet during execution
  - best default for difficult work that benefits from explicit planning before implementation
- `opus` (`claude-opus-5-5`)
  - strongest Claude Code alias for complex reasoning, architecture, adversarial review, and high-error-cost decisions
- `sonnet` (`claude-sonnet-5-5`)
  - balanced default for daily coding, implementation, debugging, and most ShipGlows execution loops
- `sonnet[1m]`
  - Sonnet with extended context for very long sessions or large codebase context
  - use only when context length is the main constraint
- `haiku` (`claude-haiku-5-5`)
  - fast and efficient alias for simple low-risk tasks, triage, classification, and quality-equivalent side work

## Claude Code routing matrix

| Situation | Primary | Behavior | Fast fallback | Cheap fallback |
| --- | --- | --- | --- | --- |
| Plan-heavy architecture or ambiguous spec | `opusplan` | Opus for planning, Sonnet for execution | `sonnet` | `haiku` |
| High-risk reasoning, review, security, product arbitration | `opus` | maximum reasoning quality | `opusplan` | `sonnet` |
| Daily multi-file coding or debugging | `sonnet` | balanced execution | `haiku` for side tasks | `haiku` |
| Very long Claude Code session/context | `sonnet[1m]` | extended context Sonnet | `sonnet` | `haiku` |
| Small local fix, triage, classification with low error cost | `haiku` | fastest quality-equivalent alias | `sonnet` | `haiku` |

## Default heuristics

- If the task is simple, local, reversible, and low-risk, use the runtime's lightest quality-equivalent model: Luna in OpenAI, `haiku` or `sonnet` in Claude Code.
- If the task is long implementation or implementation-heavy, prefer the `codex` implementation profile in Codex and `sonnet` in Claude Code.
- If the task is ambiguous, cross-project, governance-heavy, or high-error-cost, prefer Sol in OpenAI and `opusplan` or `opus` in Claude Code.
- If the user already ran `100-sg-spec` and `101-sg-ready`, the clearer contract usually reduces the need for the largest model.
- If two choices are close and quality-equivalent, choose by latency, cost, agentic execution fit, and how costly a wrong decision would be.

## Subagent defaults

When ShipGlows delegates bounded work to subagents, use the smallest quality-equivalent model that fits the delegated mission, then apply the risk-path escalation below:

| Subagent mission | Codex/OpenAI default | Claude default | Reasoning |
| --- | --- | --- | --- |
| Default small bounded mission, triage, read, docs check, lightweight validation with low error cost | Luna | `haiku` | `low` or `medium` (operator may require `high`) |
| Micro-code or targeted UI/local edit with bounded risk | Luna | `haiku` | `low` or `medium` |
| Long implementation, multi-file coding, refactor, hard debugging, terminal-heavy execution | `codex` implementation profile | `sonnet` | `medium` or `high` |
| Transverse audit, risky arbitration, product/architecture decision, business-risk synthesis | Sol | `opus` | `medium` or `high` |

When OpenAI or Anthropic cannot launch the child (missing auth, quota, empty model list, refused child), relay the subagent to a usable provider: the paid relay `grok` / `grok-4.7` at `high` effort, never a model costlier than the relay except under risk-path escalation.

## Risk-path escalation

This override sits on top of the mission-type tables; it never replaces them for other work.

- Trigger: the subagent writes (not only reads) a risk surface:
  - authentication and sessions: paths or symbols matching `auth`, `login`, `signin`, `session`, `token`, `oauth`, `jwt`, `password`, `clerk`, route guards;
  - payments and billing: `payment`, `billing`, `stripe`, `checkout`, `invoice`, `subscription`, `entitlement`, and their webhook handlers;
  - data migrations: `migrations/`, `migrate`, `schema`, `*.sql`, ORM schema files, drift/prisma/alembic migrations, backfills;
  - secrets: `.env*`, `doppler`, `secrets`, `credentials`, key vaults or KMS, CI secret wiring.
- Escalation: strongest model of the active provider: `opus` (`claude-opus-5-5`) in Claude, Sol in OpenAI, the strongest usable model of any other provider. Keep reasoning at least `high`.
- Precedence: overrides cheap defaults (`haiku`, Luna, `mini`, Spark) and the relay cost cap. If no strong model is usable, report `degraded` and keep the write in the orchestrator or stop.
- Known limit: a dangerous change can look small or sit outside matching paths (a config flag, a shared helper, a dependency bump). Path matching is a floor, not a ceiling: escalate whenever the effect reaches those surfaces, and never downgrade a matching path because the diff is small.

## Subagent argument aliases

When a ShipGlows skill invocation includes one of these model-topology arguments, interpret it as a delegated subagent request, not as an internal text option:

| Argument | Meaning | Model policy |
| --- | --- | --- |
| `spark`, `--spark` | Run the requested bounded skill mission in a Spark subagent. | Use a Spark model only when exposed by the runtime; otherwise report it unavailable and use Luna only when quality-equivalent. |
| `codex`, `--codex` | Run the requested bounded skill mission in the Codex implementation profile. | Resolve via current official Codex guidance and the runtime's available model set; do not pin the profile to an old slug. |
| `sous-agent`, `subagent`, `agents`, `--sous-agent`, `--subagent`, `--agents` | Run the requested bounded skill mission in a subagent using the current model unless a stronger alias is supplied. | Inherit the current model/profile and still state model application status in the delegated mission. |
| `mini`, `--mini` | Run the requested bounded skill mission in a fast low-cost subagent. | Luna (`haiku` in Claude), `low` or `medium`, only when quality-equivalent and no risk-path escalation applies. |

If a requested alias would weaken correctness, security, performance, maintainability, excellence, or proof quality for the mission, escalate to the correct model or stop with a degraded/recommended-only report.

## Runtime application rule

- The main conversation can recommend a better model, route through `704-sg-model`, or tell the operator which model to use next; it must not claim that it can always switch its own active runtime model mid-thread.
- When subagents are available and the orchestration tool accepts model overrides, delegated missions should include the selected model and reasoning effort explicitly.
- When the runtime cannot apply a model override, report the recommendation as advisory and continue only if the degraded mode is safe for the work item.

## Model policy promotion

Treat a routing update as a measured migration, not a global default flip:

1. Preserve the current model and reasoning effort as the baseline.
2. Compare representative hard and routine missions, changing one model or reasoning variable at a time.
3. Record task success, completeness, required evidence, retries or tool errors, token use, latency, and cost.
4. Lower reasoning by one level first; retain a heavier model or effort only when the quality gain is measurable for the mission risk.
5. Promote a new default only after it wins on the quality contract and acceptable operational cost; otherwise retain or roll back the baseline.

`none` is a latency baseline only when the runtime supports it. Use `high`, `xhigh`, or `max` only after evidence that the added reasoning improves the result enough to justify it.
