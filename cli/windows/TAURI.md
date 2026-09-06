# Tauri development sessions

A repository that also contains a browser extension can select its active
development surface with `.shipglows.runtime.json`:

```json
{ "surface": "tauri" }
```

`browser-extension` selects the existing Chrome workflow. Without this file,
framework detection remains unchanged. A child Astro site remains a separate
registered project. Selection does not allocate an additional port or registry
identity for the same project directory.

Stop the managed session before changing the selection, then register the
project again. Start uses the project's declared Tauri `beforeDevCommand` and
requires `build.devUrl` to match the assigned loopback port. Vite should use
`strictPort: true` so a conflict fails rather than moving to another port.

The browser preview and native app share the same Vite frontend. HTTP readiness
means the frontend is ready; Cargo may still be compiling the native app.
Confirm the native process separately before reporting the Windows app running.
Rust changes are watched by Tauri and frontend changes use Vite HMR.

The launcher requires native `cargo.exe` rather than a `.cmd` shim. When present,
the managed Windows Rust version is reused unless the project declares a Rust
toolchain. Project authentication and service configuration remains in the
declared Tauri/frontend recipe.

Validation: `tests/windows/devserver-tauri.ps1`,
`tests/windows/devserver-monorepo-detection.ps1`, and
`tests/windows/devserver-project-catalog.ps1`.
