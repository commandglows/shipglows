---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.2.0"
project: ShipGlows
created: "2026-05-26"
updated: "2026-08-27"
status: draft
source_skill: sg-docs
scope: github-actions-ci-cost-cache-and-monorepo-guardrails
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - GitHub Actions
  - Blacksmith
  - monorepo CI
  - Flutter Android builds
  - Firebase deploy workflows
depends_on:
  - artifact: "shipglows_data/technical/blacksmith.md"
    artifact_version: "0.3.1"
    required_status: draft
supersedes: []
evidence:
  - "WinFlowz monorepo CI incident on 2026-05-26: Flutter Android workflow used multiple Blacksmith jobs with repeated setup and broad path triggers after monorepo migration."
  - "WinFlowz CI quota review on 2026-05-26: workflow needed concurrency cancellation, narrower monorepo paths, one Android CI job, and deploy gating for Firestore-only changes."
  - "Blacksmith reference now documents provider-specific runner and observability guidance; this note documents GitHub Actions workflow design guardrails."
next_review: "2026-06-26"
next_step: "/sg-docs technical audit"
---

# GitHub Actions

## Purpose

This note preserves ShipGlows's default GitHub Actions rules for CI cost, cache use, and monorepo workflows. Read it before editing `.github/workflows/*`, debugging quota spikes, adding expensive jobs, or moving a project into a monorepo.

GitHub Actions is the workflow orchestrator. Blacksmith, GitHub-hosted runners, or other runner providers are execution surfaces. Optimize the workflow shape first; runner caches cannot compensate for unnecessary jobs, broad triggers, or deploys on unrelated changes.

## When To Read

Load this reference when:

- a task touches `.github/workflows/*`
- a project is migrated into a monorepo
- CI minutes, Blacksmith quota, artifact cost, or repeated cancelled/failed runs matter
- Android, iOS, desktop, Docker, E2E, or deploy jobs are added to pull request or push workflows
- a workflow deploys with secrets, OIDC, cloud credentials, or production artifacts
- a skill is about to push just to test behavior that local checks can prove

## Cost And Quota Guardrails

Every workflow with non-trivial jobs should have:

- `concurrency` with `cancel-in-progress: true` for branch-level superseding runs
- `paths` filters on `push` and `pull_request` in monorepos
- a cheap `changes` job when expensive jobs should be gated by file groups
- separate gates for CI, build artifacts, deploys, and scheduled/manual jobs
- artifact `retention-days` sized to actual use, not the platform default by habit
- minimal `permissions`, elevated only for jobs that need OIDC, package publishing, or deployment
- local validation before push when the local command is allowed and gives equivalent proof

Do not push repeatedly to debug failures covered by local lint, typecheck, unit tests, YAML parsing, or static config checks. Use CI for platform-only proof, runner-only behavior, secrets/OIDC wiring, artifact generation, and deploy evidence.

## Monorepo Triggers

Avoid broad triggers such as a whole app directory when docs, governance, unrelated packages, or generated files live inside the same tree. Prefer path groups that match the actual runtime/build inputs.

For a Flutter Android app, app-impacting paths usually include:

```yaml
paths:
  - "winflowz_app/lib/**"
  - "winflowz_app/test/**"
  - "winflowz_app/android/**"
  - "winflowz_app/assets/**"
  - "winflowz_app/pubspec.yaml"
  - "winflowz_app/pubspec.lock"
  - "winflowz_app/analysis_options.yaml"
  - ".github/workflows/android-build.yml"
```

Keep deploy-only paths separate. Firestore deploy jobs should run for Firestore config/rules/index changes or explicit manual dispatch, not for every app code push.

## Job Topology

The default cost-conscious shape is one setup-heavy job per stack and artifact target.

For Flutter Android debug APK workflows, prefer one Blacksmith/GitHub Actions job that does:

1. checkout
2. Java setup with Gradle cache
3. Flutter setup with pub cache
4. one `flutter pub get`
5. `flutter analyze`
6. `flutter test`
7. `flutter build apk --debug`
8. artifact verification and upload

Avoid splitting analyze, tests, and debug build into separate runner jobs unless parallel wall-clock time is explicitly worth the extra runner starts and repeated dependency setup. Cache hits still consume setup time and runner quota.

Separate deploy jobs only when their permissions, credentials, or trigger rules differ. Expensive deploy jobs must be independently gated by relevant file changes or manual dispatch.

## Cache Strategy

Use the cache mechanisms built into official setup actions before adding manual `actions/cache` steps.

- Flutter: `subosito/flutter-action@v2` with `cache: true`
- Java/Gradle: `actions/setup-java@v5` with `cache: gradle`
- Node package managers: prefer `actions/setup-node` cache support when it fits the package manager and lockfile
- pnpm: use setup-node cache plus package-manager setup in the local project pattern

Do not stack duplicate cache strategies for the same directory unless a measured log proves the built-in cache is insufficient. Cache keys must include OS, lockfiles, and relevant toolchain identifiers when dependencies or generated outputs differ by platform or version.

Caches reduce dependency fetch and setup time. They do not make unnecessary runner jobs free.

## Reference Pattern

Use this shape for branch-superseded CI in monorepos:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  changes:
    runs-on: ubuntu-latest
    outputs:
      app: ${{ steps.filter.outputs.app }}
      deploy: ${{ steps.filter.outputs.deploy }}
    steps:
      - uses: actions/checkout@v6
      - uses: dorny/paths-filter@v3
        id: filter
        with:
          filters: |
            app:
              - "app/lib/**"
              - "app/test/**"
              - "app/pubspec.yaml"
              - "app/pubspec.lock"
              - ".github/workflows/app.yml"
            deploy:
              - "firebase.json"
              - "firestore.rules"
              - "firestore.indexes.json"
              - ".github/workflows/app.yml"

  app_ci:
    needs: changes
    if: needs.changes.outputs.app == 'true'
    runs-on: blacksmith-2vcpu-ubuntu-2404
    steps:
      - uses: actions/checkout@v6
      - uses: actions/setup-java@v5
        with:
          distribution: temurin
          java-version: "17"
          cache: gradle
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - run: flutter pub get
        working-directory: app
      - run: flutter analyze
        working-directory: app
      - run: flutter test
        working-directory: app
      - run: flutter build apk --debug
        working-directory: app
```

Adapt runner names, stack setup, and build commands to the project. Do not copy this as a release workflow without adding the project's signing, permissions, and artifact retention requirements.

## Deploy And Secrets

Production or cloud deploy jobs must be stricter than CI jobs:

- set job-level `permissions` explicitly
- use OIDC/WIF where available instead of long-lived credentials
- run only on trusted refs, manual dispatch, or relevant deploy-path changes
- never run secrets-backed deploys on untrusted fork pull requests
- keep secret validation redacted
- separate deploy validation from app build validation when their change scopes differ

If a workflow uses Firebase Firestore deploys, also read `shipglows_data/technical/firebase-firestore-oidc-ci-playbook.md`.

## Branch Protection and `paths`-Filtered Workflows

When a workflow is skipped because `paths` filters do not match, branch protection must not fail the PR on that missing status.

For active ShipGlows-managed GitHub repositories, use the canonical pattern from `skills/references/managed-project-ci-policy.md`:

- Require only the exact `ShipGlows required gate` status.
- Trigger its owning workflow on every pull request into the production branch, every push to that branch, and `workflow_dispatch`; never use top-level `paths` or `paths-ignore` there.
- Classify paths inside that workflow, run only relevant stack lanes, and emit explicit successful no-impact results for the others.
- Resolve the Core-owned tool from `$SHIPGLOWS_ROOT`, then run `python "$SHIPGLOWS_ROOT/tools/shipglows_required_gate.py" audit --project <path>` locally. Generate the workflow before enabling protection, then prove the exact status succeeds on the production branch.
- Node lanes inherit the project's runtime contract from the nearest `.node-version` or `.nvmrc`, with `package.json#engines.node` as fallback. The generator refuses to invent a Node version when none is declared.
- Inspect provider drift with `ruleset-plan`; use the separately explicit guarded `ruleset-apply` only inside approved GitHub reconciliation scope.

For repositories outside ShipGlows management, use one of these compatible patterns:

- Keep path-filtered jobs out of branch protection; protect only an always-on umbrella status workflow instead.
- Keep an always-on status workflow (for example, `ci-status`) that runs every PR and records:
  - which CI jobs were expected for changed paths
  - which jobs were intentionally skipped by path filters
  - whether skipped jobs are acceptable for the scope

If branch protection still requires path-specific checks directly, document a migration plan before adding or expanding `paths` filters.

`workflow_dispatch` is required for forced full-surface validation when path-filtered workflows are intentionally optional.

Minimum scope matrix for path-driven workflow ownership:

- **Docs/site edits**: `shipglows_data/**`, `docs/**`, `README.md`, `CLAUDE.md`, `AGENT.md`, `site/**`
- **Governance/surface updates**: `CHANGELOG.md`, `shipglows_data/workflow/BUGS.md`, `TASKS.md`, `BUG-*.md`, `shipglows_data/workflow/**`
- **Skill/runtimes edits**: `skills/**`, `tools/**`, `templates/**`, `site/src/content/skills/**`, `site/src/content/reference/**`
- **App/backend edits**: project paths that actually build/deploy (for example, `apps/**`, `packages/**`, `src/**`, `api/**`, `functions/**`)

Use this matrix as the evidence source when AC 11/12/13 are validated in repositories that actually host CI workflows.

## Artifact Rules

Artifacts should be uploaded only when a human, QA flow, release process, or downstream job needs them.

- Debug APKs for device QA are valid artifacts.
- Set `retention-days` to the shortest useful period for daily QA.
- Verify the expected file path before upload so a successful job cannot publish an empty or wrong artifact.
- Do not upload broad build directories unless the consumer needs the whole directory.

## Validation

Before pushing workflow edits when quota matters:

```bash
python3 -c 'import yaml; yaml.safe_load(open(".github/workflows/android-build.yml", encoding="utf-8")); print("YAML OK")'
git diff --check
```

Then run local project checks that are allowed by the repository guardrails. For Android projects with a no-local-build rule, do not run APK or Gradle builds locally; use CI only for the build artifact proof.

## Agent Routing Contract

- `sg-check` should run allowed local checks before recommending CI retries.
- `sg-deploy` may trigger/push CI only when its ship workflow requires it or Diane explicitly asks.
- `sg-prod` owns live CI/deploy proof, job logs, artifacts, and provider-specific runner evidence.
- `sg-docs` owns this reference and should update it after repeated CI cost incidents.
- `sg-start` and code-changing skills should load this reference before editing `.github/workflows/*`.

## Reader Checklist

- [ ] Are branch superseded runs cancelled?
- [ ] Are monorepo paths narrow enough?
- [ ] Are expensive jobs gated by relevant change groups?
- [ ] Are setup-heavy checks combined when parallelism is not worth the quota?
- [ ] Are caches enabled through official setup actions?
- [ ] Are duplicate cache steps avoided?
- [ ] Are deploy jobs separated from CI and guarded by trusted refs or manual dispatch?
- [ ] Are artifact uploads verified and retention-limited?
- [ ] Are local checks used before pushing when local proof is allowed?

## Maintenance Rule

Update this note when GitHub Actions workflow policy changes, a new stack gets a standard CI pattern, a quota incident reveals a missing guardrail, or ShipGlows skill routing around CI/deploy proof changes.
