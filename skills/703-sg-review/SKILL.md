---
name: 703-sg-review
description: "Review session changes, docs, summaries, and next steps."
disable-model-invocation: false
argument-hint: [optional: daily, weekly, sprint, release]
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `pilotage`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and open the report with the opening chantier header. If no unique chantier is identified, do not write to any spec; use a `(local)` chantier header with a short work name.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise review outcome, evidence limits, tracker/docs impact, and opening chantier header when applicable. Use `report=agent` for detailed review reports, tracker anchors, or handoff state.

## Required References

- Load `$SHIPGLOWS_ROOT/skills/references/question-contract.md` before asking project, review-period, closure, or risk-framing questions.
- Load `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md` before creating or mutating task operational records in `TASKS.md`.
- Load `$SHIPGLOWS_ROOT/skills/references/product-decision-chain.md` when the review captures product lessons, decision changes, rework, failed proof or coherence drift.


## Context

- Current directory: !`pwd`
- Project workflow TASKS.md: !`cat shipglows_data/workflow/TASKS.md 2>/dev/null || cat TASKS.md 2>/dev/null || echo "No project TASKS.md"`
- Project-local TASKS.md: !`cat shipglows_data/workflow/TASKS.md 2>/dev/null || cat TASKS.md 2>/dev/null || echo "No project-local TASKS.md"`
- Recent commits (last 10): !`git log --oneline --date=short --pretty=format:"%h %ad %s" -10 2>/dev/null || echo "Not a git repo"`
- Files changed recently: !`git diff --name-status HEAD~5..HEAD 2>/dev/null || echo "N/A"`
- Current branch: !`git branch --show-current 2>/dev/null`
- Git status: !`git status --short 2>/dev/null`
- CHANGELOG.md (last 30 lines): !`tail -30 CHANGELOG.md 2>/dev/null || echo "No CHANGELOG.md"`
- Workspace CLAUDE.md: !`head -20 $HOME/CLAUDE.md 2>/dev/null || echo "N/A"`

## Operational tracker model

Review bookkeeping is local-first for project work.

- For a selected project, update `[project]/shipglows_data/workflow/TASKS.md` when review evidence justifies tracker changes.
- Root `TASKS.md` is a legacy project tracker location; read it as a migration/fallback source only when canonical workflow tasks are absent.
- Legacy central archives are migration evidence only. Use `shipglows_data/workflow/TASKS.md` for per-project discovery and local task state.
- When reviewing from a sub-project directory, consider portfolio concerns only as context unless the user asked for a portfolio review.
- The review summary should reference which project(s) were worked on and, for portfolio-scoped runs only, how the external Dashboard changed.
- When planning next session, suggest tasks from the selected project's local workflow tracker, or from the external control plane only for portfolio-scoped runs.

## Shared tracking file write protocol

- Before creating or mutating task operational records, load `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md` and preserve that format for new `TASKS.md` writes.
- Treat the TASKS snapshots loaded at skill start as informational only.
- Right before editing the project or portfolio TASKS file, re-read the target from disk and use that version as authoritative.
- Apply a minimal targeted edit to the relevant dashboard rows and project sections; never rewrite the whole file from stale context.
- If the expected anchor moved or changed, re-read once and recompute.
- If it is still ambiguous after the second read, stop and ask the user instead of forcing the write.

## Your task

Conduct a comprehensive review of recent work and prepare for the next session.
This is a review and closure aid, not a truth machine. Commits, changed files, updated docs, and changelog entries are evidence of activity; they are not by themselves proof that the product outcome is complete, coherent, or secure.

This skill answers one operator question: what actually changed, what is proven, what remains open, and what should the next session pick up?

It owns retrospective reconstruction, evidence-framed status, review artifacts, changelog/task bookkeeping when justified, and the next-session handoff derived from completed or partial work.

Keep the boundary explicit:
- stay here when the user wants a daily/weekly/sprint/release review, evidence-based closure framing, or a next-session summary
- hand off to `702-sg-priorities` when the main need is to rank active work now rather than summarize what happened
- hand off to `701-sg-backlog` when the main need is to capture or defer future work rather than review the last work period
- hand off to `700-sg-explore` when the user needs open-ended problem framing instead of retrospective synthesis

`703-sg-review` does not become a generic ideation lane, does not own backlog grooming by default, and does not silently convert retrospective evidence into current priority ranking without saying so.

### Workspace root detection

If the current directory has no `.git` directory (not a git repo) BUT contains multiple project subdirectories, you are at the workspace root. Load `$SHIPGLOWS_ROOT/skills/references/question-contract.md`, then ask:
- Question: "Which project(s) should I review?"
- `multiSelect: true`
- One option per project: label = project name, description = recent commit count (run `git -C [path] log --oneline --since="7 days" 2>/dev/null | wc -l` for each)
- Only list projects with recent activity

### Steps

1. **Determine review scope** — if `$ARGUMENTS` is empty, load `$SHIPGLOWS_ROOT/skills/references/question-contract.md`, then ask:
   - Question: "What time scope for this review?"
   - `multiSelect: false`
   - Options:
     - **Daily** — "Last 24 hours of work"
     - **Weekly** — "Last 7 days of commits" (Recommended)
     - **Sprint** — "Since last sprint start (~2 weeks)"
     - **Release** — "All changes since last release"

   If `$ARGUMENTS` is provided (daily/weekly/sprint/release), skip the prompt and use it directly.

2. **Analyze what was accomplished**:
   - Review completed tasks in the selected project's `shipglows_data/workflow/TASKS.md`, or the legacy external-control-plane tracker only for portfolio reviews
   - Examine git commits for actual changes
   - Identify files modified (from git diff)
   - Note any deployed changes or releases
   - Reconstruct the intended user story or user-facing outcome when possible
   - Distinguish clearly between `implemented`, `verified`, and `assumed`
   - Identify docs, README, guides, FAQ, onboarding, examples, pricing, changelog or support surfaces changed or made stale

3. **Assess work quality**:
   - Are there tests for new features?
   - Is documentation updated?
   - Are there any quick fixes that need proper solutions?
   - Any technical debt introduced?
   - Security or performance concerns?
   - Does the work preserve product coherence with the surrounding flow, terminology, permissions model, and expected user journey?
   - Does the documentation preserve the same feature behavior, limits, setup steps and promises as the code?
   - Are there evidence gaps where the review should explicitly avoid claiming `done` or `safe`?

4. **Update CHANGELOG.md**:
   - Add new section for this review period if needed
   - Use semantic versioning or date-based sections
   - Categorize changes:
     ```markdown
     ## [Version/Date]

     ### Added
     - New features

     ### Changed
     - Updates to existing features

     ### Fixed
     - Bug fixes

     ### Security
     - Security updates

     ### Deprecated
     - Features marked for removal
     ```
   - Keep entries user-focused (what changed, why it matters)
   - Keep entries evidence-based; do not overstate readiness, safety, or completeness

5. **Generate work summary**:
   - **User Story / Outcome**: What user-facing promise this work aimed to advance
   - **Completed**: What was finished (with evidence)
   - **In Progress**: What's partially done
   - **Blocked**: What's stuck and why
   - **Learned**: Key insights or discoveries
   - For every reusable lesson: evidence, causal status, applicability boundary, keep/change/retire decision and the next related verification hook
   - Recheck applicable lessons from the previous related review and report whether they were used and whether they helped
   - **Security / Product Risks**: Remaining risks, abuse cases, or coherence gaps
   - **Documentation Coherence**: Docs updated, not impacted, or stale
   - **Metrics**: Commits, files changed, tests added, etc.

6. **Plan next session**:
   - Review remaining tasks in the selected project's `shipglows_data/workflow/TASKS.md`, or the legacy external-control-plane tracker only for portfolio reviews
   - Identify what should be prioritized next
   - Note any blockers that need addressing
   - Suggest 1-3 tasks for immediate focus
   - Flag anything that needs discussion/decisions

7. **Update the selected TASKS.md**:
   - Archive completed tasks to a "Recently Completed" section
   - Add completion dates
   - Move old completed tasks to CHANGELOG or separate archive
   - Ensure In Progress and Todo sections are current
   - When evidence is partial, keep items in progress with a precise note instead of marking them done prematurely

### Clarification prompts

Ask a concise user question before concluding the review when the answer materially changes the closure or risk framing. Typical triggers:
- the review period includes work that was merged or deployed but not functionally verified
- it is unclear whether the intended outcome was internal tooling, a partial iteration, or a user-facing completion
- security-sensitive changes were made and the available evidence is too thin to classify them confidently
- user-facing behavior changed but docs/support/pricing/onboarding were not checked or updated
- the review summary would otherwise imply stronger closure than the evidence supports

Examples:
- "Do you want this review to frame the work as iteration progress, or as feature closure?"
- "This looks shipped but not fully validated on the user flow. Should I keep the summary explicit about partial verification?"
- "There are security-sensitive changes with thin evidence. Do you want them called out as open risks in the review?"
- "The feature behavior changed but docs were not clearly updated. Should I keep that as an open task?"

8. **Create review report**:
   - Save to `shipglows_data/workflow/reviews/REVIEW-[DATE].md` when the project uses the canonical workflow corpus, otherwise use the nearest existing review/docs folder.
   - Start the report with YAML frontmatter:
     ```yaml
     ---
     artifact: review
     project: "[project name]"
     created: "[YYYY-MM-DD]"
     updated: "[YYYY-MM-DD]"
     status: "[draft|reviewed|partial]"
     source_skill: 703-sg-review
     scope: "[daily|weekly|sprint|release]"
     user_story: "[main outcome if inferable]"
     confidence: "[high|medium|low]"
     risk_level: "[low|medium|high]"
     security_impact: "[none|yes|unknown]"
     docs_impact: "[none|yes|unknown]"
     evidence: []
     next_step: "[recommended command]"
     ---
     ```
   - Include all sections above
   - Add links to relevant commits, PRs, issues
   - Make it readable for stakeholders (team, future you)

### Important

- Default to the selected project's `shipglows_data/workflow/TASKS.md` for review bookkeeping.
- Update project-local `shipglows_data/workflow/TASKS.md` only when review changes local workflow state.
- Be honest about progress - if less was done than planned, say why
- Focus on outcomes, not just activity
- Keep outcome claims tied to evidence; distinguish shipped, reviewed, verified, and assumed
- Highlight wins and learnings
- Use metrics to show progress (# of tests, coverage, performance improvements)
- Flag technical debt clearly
- Flag product coherence gaps and security risks clearly
- Flag documentation coherence gaps clearly when feature behavior changed
- Make next steps actionable and specific
- Keep review concise but comprehensive
- Update CHANGELOG.md for user-facing changes only
- Archive old completed tasks to keep TASKS.md manageable
- Suggest process improvements if patterns emerge (e.g., always missing tests)
- When planning next session, pull top priorities from the selected project's local workflow tracker, or from the external Dashboard only for portfolio-scoped runs.
