# Exploration Posture and Techniques

Use this playbook for bounded non-implementation exploration.

## Exploration posture

- Explore to reduce uncertainty, not to validate final product truth.
- Ask only necessary questions.
- Stop once execution-ready understanding is reached.
- Keep the operator out of unnecessary loops unless the answer changes behavior, safety, cost, or scope.

## Techniques

- Build a 2 to 4 option set.
- For each option, list:
  - why it fits,
  - what it changes,
  - hidden risk,
  - evidence gap.
- Separate speculative ideas from constraints backed by evidence.
- Keep visual models optional; use only when they improve decision clarity.

## Non-negotiables

- No implementation, mutation, or deployment steps.
- No acceptance claims (ready/verified/done/shipped) from this phase.
- Keep `TASKS.md` and changelog untouched unless explicit reporting scope is requested.

## Transition to next owner

- If direction becomes clear: handoff `/100-sg-spec`.
- If priority ordering is required: handoff `/011-sg-pilotage priorities`.
- If explicit execution is requested: handoff `/102-sg-start`.

## Persistent report trigger

When at least 2 of the following are true, propose writing an `exploration_report`:

- at least 3 relevant project artifacts are reviewed,
- at least 2 real options were compared,
- internet or external source context was required,
- a blocking risk was identified that changes execution,
- `/100-sg-spec` is directly recommended.
