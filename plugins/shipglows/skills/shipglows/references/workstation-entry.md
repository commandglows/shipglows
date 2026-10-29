# Workstation entry without a required local runtime

Use only for `shipglows init [context|agents|memory|resume]` with optional
`role=<local|remote|consult|test>` and `lifetime=<persistent|ephemeral>`. Preserve
all arguments, execution-posture tags, language and authority through handoff.
Implementing/discussing init does not run it. `context` is read-only; `#nolocal`
and `#ci` defer every write. Reject conflicting/unknown options before action.

1. Identify the operator device and agent execution host separately from exposed
   evidence. Do not assume a browser on a phone can write files or execute SSH.
   Ask one role choice only if the intended use cannot be established. A role is
   an intent, never proof of a capability. VM/container never implies ephemeral.
2. On a filesystem-capable execution host, resolve `SHIPGLOWS_ROOT` from process
   environment; on Windows if empty, check the user environment then
   `%USERPROFILE%\.shipglows\development-channel.json`. A valid absolute linked
   root with `skills/000-shipglows/SKILL.md` wins before `$HOME/.shipglows/runtime`.
   Conflicting explicit roots block dependent writes. No drive scans or guessed
   checkout paths. Inspect the exact engine and init reference before handoff.
3. When both exist, load the canonical engine from that root and continue the
   original init request through `skills/references/workstation-initialization.md`.
   That reference owns root/cache/agent/memory persistence, existing updater reuse,
   device-role journeys and resumable checkpoints; do not duplicate it here.
4. Without a valid complete corpus, continue bounded portable guidance: consult
   through current-turn app/browser tools, identify an explicitly selected remote
   execution surface if relevant, and report unsupported local work as pending.
   Do not require local runtime installation for consult-only use. Browser-only
   iPhone/iPad/tablet guidance is not a new native install or configured connection.
5. For local development, name the exact absent root/engine/reference and the
   existing official bootstrap at `https://shipglows.com/shipglows-script`
   (native Windows: `?format=powershell`) or the plugin's existing sparse-corpus
   setup route as appropriate. Read the applicable installed/bundled recipe before
   executing anything. Mode/channel choices remain explicit; never silently switch
   to a maintainer checkout, download/install tools or start services from init.

Do not invent a local context/cache on a host without filesystem access or without
a verified root. With no persistent writer, state session-only progress; do not
claim memory, agent files or restoration were saved. Authentication, remote
connections, backups and data synchronization need their own existing authority.
End with evidenced role/capabilities, completed versus pending work and at most
one user-owned next action. A fresh plugin session is separate discovery evidence.
