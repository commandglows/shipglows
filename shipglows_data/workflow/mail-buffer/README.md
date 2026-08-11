# Local mail working buffer

This directory anchors the local Maildir/notmuch working buffer used by the
Neovim Mail Intelligence workflow.

The private runtime data lives under `data/competitors/` and is intentionally
ignored by Git. Raw messages, Maildir state, credentials, and the notmuch index
must never be committed to this public repository.

Local consumers should use this Maildir root:

```text
/home/claude/shipglows/shipglows_data/workflow/mail-buffer/data/competitors
```

Extracted project knowledge belongs in the corresponding project's governed
data corpus; this buffer is short-lived intake and indexing infrastructure.
