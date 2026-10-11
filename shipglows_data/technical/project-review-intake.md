# Private project review intake (inactive local implementation)

`tools/project_review_intake.py` is a separate, opt-in stdlib HTTP service bound
only to `127.0.0.1` (default port 8769). It does not run as part of the CLI,
write TASKS.md, generate content, publish, forward email or mutate Gmail.
Repository execution follows the explicit **Doppler NONE** operator decision.

Activation requires `SHIPGLOWS_REVIEW_INTAKE_ENABLED=true` and a server-owned
`SHIPGLOWS_REVIEW_INTAKE_GRANTS` JSON list of `{token_env, project_ids}` records.
Each token_env names an existing environment variable containing a distinct
opaque ASCII bearer secret (32..512 characters, no whitespace). Rights and
stable actor IDs derive only from this server mapping; clients cannot choose
actors/projects outside their grant. Comparison uses constant-time hmac.
No secrets or configuration were created or modified. Token rotation must keep
the same token_env actor key to preserve recovery identity. Changing that actor
key requires a migration/reconciliation decision; do not blindly resend.

POST `/api/projects/{project_id}/review-intake` accepts client_intake_id UUID,
source_key (64 lowercase hex), nonblank summary (1..4000), contribution_type
(newsletter_inspiration, thematic_source, potential_task, other), justification
(default empty, <=2000), confidence (optional finite 0..1) and risks (<=10, <=500
each). Unknown fields and duplicate JSON keys are rejected. Maximum request
body is 65536 bytes; HTTP Content-Length and application/json are required.
Authorization is checked before the HTTP body is read. Email derivatives are
inert private data; raw body/subject/sender/attachments/credentials are excluded.

GET at the collection path lists only this actor/project's pending contributions
(limit 1..100, offset 0..1000000). GET `/{client_intake_id}` reconciles a receipt.
Receipts have schema_version=1, client_intake_id, intake_id UUID, project_id,
state=pending_review and created_at UTC. Missing authenticated entries return
404 detail `{code: intake_not_found, schema_version: 1, client_intake_id,
project_id}`. Generic proxy/routing 404 is not evidence of absence.

SQLite uses WAL, 15-second busy timeout, BEGIN IMMEDIATE and unique
(actor,project_id,client_intake_id). The canonical payload hash makes an exact
retry return the original receipt and a changed payload return 409
idempotency_conflict. Stable records have no automatic expiry. List data is
private and scoped; all responses use Cache-Control no-store. Access/request
and exception logging are disabled for this server; errors expose allowlisted
codes only. No public CORS headers are emitted.

Runtime storage is outside Git: Windows `%LOCALAPPDATA%/ShipGlows/review-intake/`
or POSIX `~/.shipglows/private/review-intake/`, containing intake.sqlite and its
SQLite WAL/SHM sidecars. POSIX umask 077 and directory mode 0700 apply. Windows
inherits the operator profile ACL; **ACL isolation, backup policy, retention,
deletion and proxy/telemetry redaction must be reviewed before activation**.
SQLite is not encrypted. Same-user local processes remain part of the trust
boundary. Do not expose the listener or configure a tunnel without separate
authorization/auth/privacy design. A hosted gateway cannot reach this loopback
service without a separately approved connection architecture.

Synthetic verification: `python tools/test_project_review_intake.py` uses only
temporary databases and callable API/handler objects, no listener or actual HTTP
requests. Concurrency spans independent SQLite connections, plus restart
recovery, idempotency conflicts, grant isolation, body limits and input redaction.
This does not prove production identity, Windows ACLs or real dispatch.
