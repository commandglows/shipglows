# Continuation Playbook

Load this playbook only after `706-continue` has confirmed that the request is an actual continuation rather than recap, help, tracker repair, prioritization, or new-scope discovery.

## Focused Evidence

Read the smallest durable surface capable of proving the current target and its next boundary:

- the explicit focus in `$ARGUMENTS` and latest operator request;
- one active `shipglows_data/workflow/specs/*.md` item when clearly implicated;
- the focused `shipglows_data/workflow/TASKS.md` or legacy `TASKS.md` entry;
- the active bug, release, or validation artifact;
- branch/status and dirty files only when they affect ownership or proof;
- recent tool output that establishes a failure or completed gate.

Do not broadly scan project trees, re-read unrelated specs, or use conversation memory as the sole source of truth.

## Target Resolution

Resolve candidates in this order:

1. An explicit focus that matches durable local evidence.
2. The work item already being advanced in the current conversation.
3. A unique active spec, bug, release scope, failed validation, or owned dirty-write scope.
4. A focused tracker entry that is current and action-ready.

Select only when one candidate is materially dominant. Recency alone is not enough when candidates have different outcomes, risks, owners, or side effects.

If several unrelated candidates remain plausible, load `question-contract.md` and ask one bounded selection question. If none exists and the work is non-trivial, route to `100-sg-spec`, `700-sg-explore`, bug intake, or backlog ownership. Never invent a hidden continuation target.

## Next Ready Action

For the resolved target, read its source of truth and select the first unresolved ready boundary:

- next unchecked implementation task;
- next spec lifecycle gate;
- next bug reproduction, fix, or retest step;
- next validation or evidence command;
- next dependency or owner handoff;
- next closure or ship step only after all earlier gates pass.

Read required dependency artifacts before dependent work. Do not skip an earlier failed check because a later action looks easier. A task is ready only when its inputs, authority, write ownership, and proof path are clear.

## Bounded Unit

Define one unit with:

- a concrete outcome;
- explicit owned and forbidden surfaces;
- required inputs and prior evidence;
- the applicable execution owner;
- validation proportional to risk;
- a stop condition.

Use a direct answer for conversational work, local execution for a truly tiny coupled action, bounded investigation for missing read-only evidence, bounded implementation for clear writes, or the canonical lifecycle owner for a formal gate.

Do not split a coherent tiny change merely to create activity. Do not combine independent future steps into the current unit merely to appear end-to-end.

## Completion Check

After the unit:

1. Compare the result with the selected boundary and its acceptance evidence.
2. Confirm that only owned surfaces changed.
3. Run or review the focused proof.
4. Update attached chantier history only under the chantier-tracking contract.
5. Identify what is newly unlocked.
6. Report one next concrete step rather than reopening broad planning.

If the unit fails, keep the same target unless evidence proves a reroute. Report the failing proof, the smallest recovery action, and any decision that now requires the operator.
