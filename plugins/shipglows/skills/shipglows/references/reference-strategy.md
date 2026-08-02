# ShipGlows Reference Strategy

ShipGlows uses a hybrid documentation model.

The simplest public packaging model is:

- a small `shipglows` plugin for routing, orientation, docs links, and complete-corpus setup
- optional hosted docs for reading and discovery
- an optional cloned GitHub repo for the complete skill/reference corpus

## Local Plugin References

Keep execution-critical contracts inside the plugin:

- activation and routing rules
- stop conditions
- validation and proof obligations
- final-report contracts
- operator-last-resort behavior
- minimal pack catalogs and install state
- exact local scripts needed by the plugin

These files must be available without browsing. If a workflow cannot be executed correctly without a reference, package that reference locally.

## Hosted Public Docs

Use hosted docs for material that improves understanding but is not required for the agent to obey a skill:

- long examples
- tutorials
- screenshots
- public product explanations
- expanded playbooks
- changelogs
- upgrade paths to paid ShipGlows products
- public pack documentation

Hosted docs should be versioned. A plugin version should point to docs that match the shipped behavior.

## Runtime Rule

Do not browse by default just to execute a ShipGlows workflow.

Browsing hosted docs is acceptable when:

- the operator asks for documentation, examples, or public explanation
- the local plugin says the hosted doc is optional
- the answer depends on current public product or pricing information
- the user explicitly asks to verify the latest docs

If browsing is unavailable, continue from local references and report that hosted docs were not consulted.

## Packaging Rule

Before moving a private ShipGlows skill into a public plugin pack:

1. Identify every required local reference.
2. Package execution-critical references inside the plugin.
3. Move long explanatory material to hosted docs when it is safe to publish.
4. Add a docs link entry for optional web material.
5. Validate that the pack still works without `$SHIPGLOWS_ROOT`.

## Product Rule

The public user should install one plugin first:

```text
ShipGlows
```

Hosted docs help discovery, onboarding, SEO, and paid-product conversion. They must not be the hidden dependency that makes the plugin work.

## Complete Corpus Rule

When the lightweight plugin is not enough, clone the public ShipGlows repo instead of making the plugin huge.

Default repo:

```text
https://github.com/dianedef/ShipGlows.git
```

Default target:

```text
${SHIPGLOWS_ROOT:-$HOME/.shipglows/source}
```

The complete-corpus checkout is sparse and includes only the skill/runtime corpus: `skills/`, `templates/`, `tools/`, `shipglows_data/`, and `local/`. It excludes the public site, TUI, generated builds, and dependency directories; canonical workflow history and records remain inside `shipglows_data/`.

This keeps one source of truth. The repo remains versioned; the plugin stays small; hosted docs stay optional. The complete-corpus setup route still needs explicit operator approval because it uses network and writes to disk.
