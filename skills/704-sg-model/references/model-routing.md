# ShipGlows Model Routing

OpenAI Codex model guidance checked against official OpenAI docs on 2026-06-10.
Claude Code aliases checked against official Anthropic Claude Code model configuration docs on 2026-04-26.

This reference must stay short. If a question depends on "latest", exact availability, default model, pricing, or a recent change, revalidate against official provider docs before answering.

Before applying this matrix, load `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`. Model routing optimizes first for reliability, security, performance relevance, maintainability, excellence, and proof quality. Speed, cost, and latency are tie-breakers only between quality- and excellence-equivalent options.

## Freshness sources

- OpenAI/Codex: use the official Codex manual or OpenAI docs for `https://developers.openai.com/codex/models` before making latest/current/default Codex model claims.
- Claude Code: prefer aliases from Anthropic docs (`opusplan`, `opus`, `sonnet`, `sonnet[1m]`, `haiku`) instead of dated slugs unless the user asks for a full model name.
- Never invent pricing, model availability, context windows, or provider-specific parameters.

## Codex/OpenAI map

- `gpt-5.5`
  - premium current model for complex, ambiguous, cross-project, tool-heavy, product-spec-to-plan, and high-error-cost work
  - default OpenAI choice for transverse audits, automatic task prioritization, prompt/docs migrations, business-risk synthesis, model-policy updates, and coherent tracker/project-fiche updates
  - starts well at `medium` reasoning; use `high` or `xhigh` only when the task justifies latency/cost
- `gpt-5.4`
  - premium balanced option when `gpt-5.5` is likely overkill or cost control matters
  - good fit for bounded architecture and important tradeoffs
- `gpt-5.4-mini`
  - lightweight quality-equivalent entry point for small and medium low-risk tasks
  - good for triage, exploration, sub-tasks, and repeated iterations when the cost of error is low
- `codex`
  - ShipGlows implementation profile for long implementation, refactors, hard debugging, multi-file coding, and terminal-heavy agentic work
  - resolve to the current Codex-recommended implementation model before execution; do not pin this alias to a deprecated slug
- `gpt-5.3-codex`
  - legacy implementation model; use only when explicitly requested by the operator and actually available in the current Codex/API authentication path
  - official Codex docs checked on 2026-06-10 mark it deprecated for Codex with ChatGPT sign-in
- `gpt-5.3-codex-spark`
  - fastest quality-equivalent local iteration path, especially for UI deltas or tightly scoped edits
- `gpt-5.2`
  - previous generation; avoid by default except continuity or explicit user preference

## Codex/OpenAI routing matrix

| Situation | Primary | Reasoning | Fast fallback | Cheap fallback |
| --- | --- | --- | --- | --- |
| Ambiguous spec, architecture, high error cost | `gpt-5.5` | `high` | `gpt-5.4` | `gpt-5.4-mini` |
| Transverse audit, task prioritization, prompt/docs migration, business-risk synthesis | `gpt-5.5` | `medium` or `high` | `gpt-5.4` | `gpt-5.4-mini` |
| Bounded premium architecture or tradeoff | `gpt-5.4` | `medium` or `high` | `gpt-5.4-mini` | `gpt-5.4-mini` |
| Long implementation, multi-file implementation, refactor, hard bug | `codex` implementation profile | `medium` or `high` | `gpt-5.3-codex-spark` when quality-equivalent and credits/availability permit | `gpt-5.4-mini` only for bounded low-risk slices |
| Small feature, local fix, triage with low error cost | `gpt-5.4-mini` | `low` or `medium` | `gpt-5.3-codex-spark` when quality-equivalent | `gpt-5.4-mini` |
| Targeted UI iteration with bounded risk | `gpt-5.3-codex-spark` | `low` or `medium` | `gpt-5.4-mini` when quality-equivalent | `gpt-5.4-mini` |
| Long terminal-heavy agentic loop | `codex` implementation profile | `medium` | `gpt-5.5` | `gpt-5.4-mini` only for bounded low-risk slices |

## Claude Code map

- `opusplan`
  - hybrid alias: Opus during Plan Mode, Sonnet during execution
  - best default for difficult work that benefits from explicit planning before implementation
- `opus`
  - strongest Claude Code alias for complex reasoning, architecture, adversarial review, and high-error-cost decisions
- `sonnet`
  - balanced default for daily coding, implementation, debugging, and most ShipGlows execution loops
- `sonnet[1m]`
  - Sonnet with extended context for very long sessions or large codebase context
  - use only when context length is the main constraint
- `haiku`
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

- If the task is simple, local, reversible, and low-risk, use the runtime's lightest quality-equivalent model: `gpt-5.4-mini`/`gpt-5.3-codex-spark` in Codex, `haiku` or `sonnet` in Claude Code.
- If the task is long implementation or implementation-heavy, prefer the `codex` implementation profile in Codex and `sonnet` in Claude Code.
- If the task is ambiguous, cross-project, governance-heavy, or high-error-cost, prefer `gpt-5.5` in Codex and `opusplan` or `opus` in Claude Code.
- If the user already ran `100-sg-spec` and `101-sg-ready`, the clearer contract usually reduces the need for the largest model.
- If two choices are close and quality-equivalent, choose by latency, cost, agentic execution fit, and how costly a wrong decision would be.

## Subagent defaults

When ShipGlows delegates bounded work to subagents, use the smallest quality-equivalent model that fits the delegated mission:

| Subagent mission | Codex/OpenAI default | Reasoning |
| --- | --- | --- |
| Default small bounded mission, triage, read, docs check, lightweight validation with low error cost | `gpt-5.4-mini` | `low` or `medium` |
| Micro-code or targeted UI/local edit with bounded risk | `gpt-5.3-codex-spark` | `low` or `medium` |
| Long implementation, multi-file coding, refactor, hard debugging, terminal-heavy execution | `codex` implementation profile | `medium` or `high` |
| Transverse audit, risky arbitration, product/architecture decision, business-risk synthesis | `gpt-5.5` | `medium` or `high` |

## Subagent argument aliases

When a ShipGlows skill invocation includes one of these model-topology arguments, interpret it as a delegated subagent request, not as an internal text option:

| Argument | Meaning | Model policy |
| --- | --- | --- |
| `spark`, `--spark` | Run the requested bounded skill mission in a Spark subagent. | `gpt-5.3-codex-spark`, `low` by default; only for text-only, summary, micro-code, targeted UI/local edits, or other low-risk bounded work when Spark credits/availability permit. |
| `codex`, `--codex` | Run the requested bounded skill mission in the Codex implementation profile. | Resolve via current official Codex guidance and this matrix; prefer legacy `gpt-5.3-codex` only when explicitly requested and available. |
| `sous-agent`, `subagent`, `agents`, `--sous-agent`, `--subagent`, `--agents` | Run the requested bounded skill mission in a subagent using the current model unless a stronger alias is supplied. | Inherit the current model/profile and still state model application status in the delegated mission. |
| `mini`, `--mini` | Run the requested bounded skill mission in a fast low-cost subagent. | `gpt-5.4-mini`, `low` or `medium`, only when quality-equivalent for the risk. |

If a requested alias would weaken correctness, security, performance, maintainability, excellence, or proof quality for the mission, escalate to the correct model or stop with a degraded/recommended-only report.

## Runtime application rule

- The main conversation can recommend a better model, route through `704-sg-model`, or tell the operator which model to use next; it must not claim that it can always switch its own active runtime model mid-thread.
- When subagents are available and the orchestration tool accepts model overrides, delegated missions should include the selected model and reasoning effort explicitly.
- When the runtime cannot apply a model override, report the recommendation as advisory and continue only if the degraded mode is safe for the work item.
