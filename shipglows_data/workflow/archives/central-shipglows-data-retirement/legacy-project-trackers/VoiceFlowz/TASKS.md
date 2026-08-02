# Tasks — VoiceFlowz (legacy name for WinFlowz app)

VoiceFlowz, sometimes written VoiceFlows, is the old name of the current WinFlowz app. Keep this tracker as historical context only; new implementation work should be moved into WinFlowz app specs/tasks before execution.

> **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
> **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred

---

## Setup

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Legacy VoiceFlowz migration context to reconcile into WinFlowz app architecture (spec-first before any implementation) | 🔄 in progress |
| 🔴 | Configure Convex deployment (`npx convex dev`) and set EXPO_PUBLIC_CONVEX_URL | 📋 todo |
| 🔴 | Create GitHub repo and push initial code | 📋 todo |
| 🟠 | Set up EAS Build account for native Android builds | 📋 todo |
| 🟠 | Configure Clerk for auth (shared with WinFlowz) | 📋 todo |
| 🟡 | Replace TEMP_USER_ID with Clerk userId in clipboard.tsx and useVoiceRecording.ts | 📋 todo |

---

## Core — Voice Recording

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Test free mode (expo-speech-recognition) on real Android device | 📋 todo |
| 🟠 | Test advanced mode (Whisper API) end-to-end | 📋 todo |
| 🟡 | Add transcription history screen (list from Convex, tap to copy) | 📋 todo |
| 🟡 | Support `requiresOnDeviceRecognition: false` fallback if offline model not available | 📋 todo |
| 🟢 | Add language auto-detection display after transcription | 💤 deferred |

---

## Core — Floating Overlay (Android)

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Build and test native FloatingOverlayModule on real device | 📋 todo |
| 🟠 | Wire overlay events to useVoiceRecording hook (record/stop/cancel flow) | 📋 todo |
| 🟡 | Test text injection via AccessibilityService on Chrome, WhatsApp, Gmail | 📋 todo |
| 🟡 | Persist FAB position across app restarts (SharedPreferences) | 📋 todo |
| 🟡 | Add OEM-specific overlay instructions (MIUI, OneUI, EMUI) | 📋 todo |
| 🟢 | Notification actions (Stop, Hide, Open app) | 💤 deferred |

---

## Core — Clipboard Sync

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Android Clipboard Sync Verify Gaps (controller + logout purge + native sensitive skip + verification docs) | 🔄 in progress |
| 🟡 | Test clipboard sync between two devices via Convex | 📋 todo |
| 🟡 | Add "code" content type detection (backticks, indentation) | 📋 todo |
| 🟢 | Add clipboard search/filter | 💤 deferred |

---

## UX / Design

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Design app icon and splash screen (match WinFlowz branding) | 📋 todo |
| 🟡 | Add onboarding flow (first launch permissions + API key setup) | 📋 todo |
| 🟡 | Dark/light theme toggle (colors already defined in constants.ts) | 📋 todo |
| 🟢 | Haptic feedback on record start/stop | 💤 deferred |

---

## Backlog

| Pri | Task | Status |
|-----|------|--------|
| ⚪ | Reprendre le cadrage de la transcription OpenAI avancee apres test APK Flutter: verifier le contrat modele/`response_format`, mapper les erreurs 401/403/413/429/timeout, borner upload/retries, proteger contre double traitement stop+timeout, et garder les cles BYOK hors logs/sync. Reference: `docs/openai-transcription-spec.md` comme note legacy a trier. | 💤 deferred |
| 🟢 | Integrate react-native-executorch Whisper for 100% offline high-quality STT | 💤 deferred |
| 🟢 | Snippets management UI (create, edit, delete triggers) | 💤 deferred |
| 🟢 | Personal dictionary UI | 💤 deferred |
| 🟢 | iOS build and test | 💤 deferred |
| 🟢 | Desktop app (Tauri or Electron) | 💤 deferred |
| ⚪ | Google Play Store listing | 💤 deferred |
| ⚪ | Integration with WinFlowz Pro tier as premium feature | 💤 deferred |

---

## Audit Findings
<!-- Populated by /shipglows-audit -->

### Audit: Deps

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Refresh compatible npm dependency tree and remove critical/high audit findings | ✅ done |
| ✅ | Add Node/npm version pins and Dependabot dependency automation | ✅ done |
| 🟡 | Track npm audit residuals in Expo toolchain: PostCSS and uuid advisories remain moderate and currently require `npm audit fix --force`, which proposes an incompatible Expo downgrade/migration path | 📋 todo |
| 🟡 | Plan framework/runtime migration separately before upgrading React Native, React, TypeScript 6, or newer Expo-adjacent majors | 📋 todo |
| 🟡 | Run `npx convex dev` before full TypeScript verification so generated Convex types remove existing implicit-any errors | 📋 todo |
