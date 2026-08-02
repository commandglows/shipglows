# Tasks — tubeflow_lab

> **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
> **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred

---

## Setup

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Review project structure and configure environment | ✅ done |
| 🔴 | Repair Flox worker runtime so healthcheck reports all required binaries and Python packages | ✅ done |
| 🔴 | Rebuild the local `.venv` on Flox Python 3.12 and FFmpeg 8 | ✅ done |
| 🟠 | Update README / CHANGELOG / TASKS to reflect the standalone Flox-based deployment flow | ✅ done |
| 🟠 | Add configurable warning thresholds, optional hard caps, and concurrency guardrails before worker transcription jobs start | ✅ done |
| 🟠 | Investigate YouTube anti-bot extraction failures on some videos | ✅ done |
| 🟡 | Add a stable strategy for bot-gated YouTube downloads (`cookies`, alternate extraction path, or clearer fallback) | ✅ done |

---

## Backlog

| Pri | Task | Status |
|-----|------|--------|
| 🟡 | Add startup verification script for `/health` plus one real `/transcribe` smoke test | 📋 todo |
| 🟡 | Tighten worker docs around supported video cases and known `yt-dlp` limits | 📋 todo |
| 🟡 | Expose queue depth / active job metrics in structured logs or monitoring | ✅ done |

---

## Audit Findings
<!-- Populated by /sg-audit — dated sections added automatically -->
