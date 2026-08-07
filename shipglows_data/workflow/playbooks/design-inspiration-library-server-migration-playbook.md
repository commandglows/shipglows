---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-07"
updated: "2026-08-07"
status: active
source_skill: 300-sg-docs
scope: design-inspiration-library-server-migration
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/design-inspiration-library.md
  - skills/006-sg-design/references/design-inspiration-library-operations.md
  - tools/capture_design_inspiration.py
  - shipglows_data/workflow/checklists/design-inspiration-library-server-migration-checklist.md
depends_on:
  - artifact: "skills/references/design-inspiration-library.md"
    artifact_version: "1.6.0"
    required_status: active
supersedes: []
evidence:
  - "Operator request 2026-08-07: a server migration must restore the design/copy inspiration corpus without relying on undocumented local setup."
  - "The corpus uses a separately configured private Git remote, Git LFS WebP rules, and a local origin fingerprint before automated synchronization is permitted."
next_review: "2026-11-07"
next_step: "Use during server provisioning or before retiring the current server."
---

# Design Inspiration Library Server Migration Playbook

## Purpose

Restore the private design and sales-page copy inspiration corpus on a new server without exposing source-derived captures, weakening Git LFS storage, or silently redirecting automatic synchronization to a different remote.

This playbook moves the corpus setup, not the public ShipGlows repository or the separate private-data repository under `~/.shipglows/private/data/`.

## Applicability

Use when provisioning a replacement server, restoring a workstation, rotating to a new private corpus repository after a justified purge, or repairing a missing local corpus checkout.

## Safety Invariants

- The configured corpus remote must be private; never put its URL in ShipGlows shared documentation, issues, logs, or public repositories.
- Never copy cookies, browser profiles, credentials, raw HTML mirrors, HAR files, or authenticated content into the corpus.
- Every `full-page.webp`, `thumbnail.webp`, and `segments/*.webp` file must be handled by Git LFS before a capture can synchronize.
- The origin fingerprint lives only in the local Git configuration. It is derived from the effective origin URL and must be regenerated on each new checkout.
- Do not use a routine repository replacement as cleanup. Follow the removal/rotation policy in the library contract for a takedown, justified purge, or material storage cleanup.

## Inputs

- a new server with the same operator account or authorized Git access;
- the private corpus remote URL, supplied through a private channel or local configuration;
- the public ShipGlows checkout and its dependencies already available on the new server;
- sufficient storage for the current Git LFS corpus;
- a maintenance window if the old server is being retired.

## Execution Order

### 1. Prepare Git And Git LFS

Install Git LFS once for the server user with the operating system's supported package or installer. Do not install a separate copy per project.

```bash
git --version
git lfs version
git lfs install --skip-repo
```

Stop here if `git lfs version` fails. A normal Git clone without LFS is not an acceptable recovery path for this corpus.

### 2. Choose The Canonical Local Corpus Path

The default path is:

```text
~/.shipglows/private/design-inspiration-library
```

If the server intentionally uses another private parent directory, set `SHIPGLOWS_PRIVATE_DIR` or `SHIPGLOWS_INSPIRATION_LIBRARY_DIR` consistently before invoking design-library operations. Do not place the corpus inside the public ShipGlows working tree or its plugin caches.

### 3. Clone The Private Corpus

Obtain the remote URL privately. Do not paste it into a shared shell history, a public ticket, or this playbook.

```bash
CORPUS_DIR="$HOME/.shipglows/private/design-inspiration-library"
REMOTE_URL="<private remote supplied outside shared documentation>"
mkdir -p "$(dirname "$CORPUS_DIR")"
git clone "$REMOTE_URL" "$CORPUS_DIR"
git -C "$CORPUS_DIR" lfs pull
```

If the directory already exists, do not clone over it. First inspect `git -C "$CORPUS_DIR" status --short`; reconcile or back up an unexpected working tree through a reviewed migration, then fetch and pull normally.

### 4. Bind The Checkout To Its Verified Origin

Compute the fingerprint from the actual configured origin URL. This makes an accidental `origin` replacement fail safely as `sync=pending reason=private_remote_unverified`.

```bash
ORIGIN_URL="$(git -C "$CORPUS_DIR" remote get-url origin)"
ORIGIN_FINGERPRINT="$(printf '%s' "$ORIGIN_URL" | sha256sum | awk '{print $1}')"
git -C "$CORPUS_DIR" config shipglows.inspirationOriginFingerprint "$ORIGIN_FINGERPRINT"
```

Do not store the origin URL or fingerprint in a committed corpus file. If the remote is intentionally rotated, repeat this step after cloning the replacement repository.

### 5. Verify Storage Rules And Remote Access

```bash
git -C "$CORPUS_DIR" check-attr filter -- \
  references/example/full-page.webp \
  references/example/thumbnail.webp \
  references/example/segments/001.webp
git -C "$CORPUS_DIR" lfs ls-files
git -C "$CORPUS_DIR" push --dry-run origin HEAD
git -C "$CORPUS_DIR" status --short
```

Each `check-attr` result must end in `filter: lfs`. `git lfs ls-files` may be empty for an empty or metadata-only corpus. The final status must be empty. A failed dry-run push is a real setup failure: leave the corpus local and repair private Git access before capturing a source page.

### 6. Verify The ShipGlows Capture Surface Without Adding a Source

Run the bounded synthetic test outside the real corpus:

```bash
SHIPGLOWS_ROOT="${SHIPGLOWS_ROOT:-$HOME/shipglows}"
python3 "$SHIPGLOWS_ROOT/tools/capture_design_inspiration.py" \
  --fixture "$SHIPGLOWS_ROOT/tools/fixtures/design-inspiration/sample-sales-page.html" \
  --output "${TMPDIR:-/tmp}/shipglows-inspiration-migration-test" \
  --id migration-test \
  --no-network
```

Then inspect the real corpus in read-only mode:

```bash
python3 "$SHIPGLOWS_ROOT/tools/capture_design_inspiration.py" --list
```

Do not add a real sales-page URL merely to test migration. The next normal `library add` or `library approve` will automatically synchronize its changed paths when the preceding setup checks pass.

## Decision Gates

- **Private remote unavailable:** stop automatic synchronization; do not substitute a public repository or a shared drive.
- **LFS unavailable or attributes missing:** restore Git LFS and `.gitattributes` before capture; never accept WebP files committed as ordinary Git blobs.
- **Origin fingerprint mismatch:** verify the intended remote privately, recompute the fingerprint, and repeat the dry-run push. Treat an unexplained mismatch as a security incident.
- **Takedown or purge:** create a replacement private corpus from still-authorized content, switch the local checkout, then delete the old managed remote and known local copies. Do not rely on history rewriting alone to remove hosted LFS objects.

## Outputs

- a clean local private corpus checkout at the canonical path;
- Git LFS available once for the server user and active for capture images;
- a locally stored origin fingerprint matching the current private origin;
- successful LFS attribute and dry-run-push proof;
- a completed paired migration checklist.

## Linked Checklist

- [Design Inspiration Library Server Migration Checklist](../checklists/design-inspiration-library-server-migration-checklist.md)

## Common Risks

- Cloning without `git lfs pull` leaves pointer files instead of usable visual evidence.
- Copying the old checkout with an unreviewed remote can preserve stale credentials or send future captures to the wrong place.
- Committing WebP files without LFS expands normal Git history and makes later removal harder.
- A private repository protects access but does not authorize reuse beyond the source's rights policy; preserve attribution and the anti-copy rules in every record.
