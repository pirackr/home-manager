# Repository Guidelines

## Project Structure & Module Organization
- The root `flake.nix` ties nixpkgs/home-manager inputs and assembles host entries `pirackr@work` and `pirackr@home`; keep new hosts under `users/` and register them here.
- Shared behaviour belongs in `modules/` (e.g., `modules/common.nix` imports editor, UI, and tooling modules); prefer a subdirectory such as `modules/ui/` when adding themed components.
- Place per-user overrides in `users/*.nix`; keep machine-specific secrets out of Git and source them through `home-manager` options or environment variables.
- CLI and editor test assets live in `tests/`; mirror any new module with a matching `tests/test-<name>.sh`.
- Use `configurations/` for experimental setups before promoting them into `users/`.

## Build, Test, and Development Commands
- `nix develop` opens the flake dev shell so every command uses the pinned `nixpkgs`.
- `nix flake check` validates the flake graph; run after editing `flake.nix` or inputs.
- `home-manager switch --flake .#pirackr@work` (or `.#pirackr@home`) applies a target profile; prefer `--dry-run` when reviewing incoming changes.
- `./tests/run-all-tests.sh` executes every shell test; `./tests/test-vim.sh` etc. isolate modules.

## Coding Style & Naming Conventions
- Nix files use two-space indentation, trailing semicolons on attribute sets, and camel-case identifiers only for options that require them; otherwise prefer `kebab-case` attribute names.
- Group related options and sort package lists alphabetically inside `home.packages`.
- Run `nixpkgs-fmt <file.nix>` (or editor integration) before committing; shell helpers follow `#!/usr/bin/env bash`, `set -euo pipefail`, and kebab-cased filenames.

## Testing Guidelines
- Add a focused script in `tests/` whenever you introduce a module or host-specific behaviour; return non-zero on failure and echo clear ✅/❌ markers.
- Keep tests idempotent and environment-aware; guard Linux-only assertions with `[[ "$(uname)" == "Linux" ]]`.
- Update `tests/run-all-tests.sh` to include new scripts and document usage in `tests/README.md`.

## Commit & Pull Request Guidelines
- Follow the existing Conventional Commits pattern: `type(scope): short summary` (e.g., `feat(modules): add wezterm profile`); use imperative mood.
- Reference issues in the body and describe behavioural impact plus testing evidence.
- PRs should link to the relevant host profile, note any new dependencies, and include before/after screenshots for UI changes.

## Security & Configuration Tips
- Never commit secrets; instead reference `git-crypt` entries or pass them via environment variables.
- When adding binaries, verify they exist in `nixpkgs`; prefer `home.packages` over vendored files to keep builds reproducible.
