# Agent Feature Import Design

## Goal

Add two targeted agent features to this Home Manager-managed setup:

1. A repo-owned `init-deep` command/skill cloned from `omo`
2. Ralph loop support for OpenCode and Codex using the upstream `snarktank/ralph` source instead of the local Claude plugin cache

## Context

- This repo already has a shared integration layer in `modules/agents/default.nix` that renders agent assets into Claude, OpenCode, and Codex.
- Local custom commands already flow through `modules.agents.commands` and are emitted per tool with tool-specific frontmatter.
- OpenCode and Codex already consume shared agent assets from this repo, so the new work should extend that path rather than introduce a separate installer.
- The user explicitly does not want todo-enforcer work as part of this change.

## Scope

### In scope

- Create a local `init-deep` asset derived from `omo`
- Install Ralph loop for OpenCode and Codex from the upstream GitHub source
- Keep the integration reproducible through Home Manager
- Minimize adapter logic to only format and path translation required by each tool

### Out of scope

- Importing any other `omo` features
- Reimplementing todo-enforcer
- Building an update workflow for `init-deep`
- Broad refactors of the existing agents module

## Source of Truth

### `init-deep`

- `omo` is used once as a reference source.
- The resulting `init-deep` content becomes a local repo-owned asset.
- No ongoing sync or upstream update mechanism is required.

### Ralph loop

- The canonical source is the upstream GitHub repo `snarktank/ralph`.
- The local Claude plugin cache under `~/.claude/plugins/...` is not used as an input.
- Only the specific Ralph assets needed for OpenCode and Codex are imported.

## Architecture

### 1. Local `init-deep` asset

- Create a local command/skill source file in this repo containing the `init-deep` workflow text derived from `omo`.
- Register it through the existing `modules.agents.commands` pipeline so Claude, OpenCode, and Codex all receive generated versions from the same local source.
- Treat this file the same way the repo currently treats other local command assets.

### 2. Upstream Ralph asset import

- Add a pinned upstream source for `snarktank/ralph` to the flake inputs or another reproducible fetch path managed by Nix.
- Pull only the relevant Ralph files, specifically the two command markdown files and the setup script they depend on.
- Keep the imported files close to their upstream structure so future inspection is easy.

### 3. Thin adapter layer

- Use this repo as the integration layer that translates upstream Ralph assets into each tool's required file layout.
- Keep rewrites minimal and explicit:
  - frontmatter normalization
  - command/path placeholder translation
  - destination path mapping
- Do not rewrite command behavior unless required for compatibility.

### 4. Existing Home Manager distribution path

- Continue using `modules/agents/default.nix` as the single place that writes agent assets into:
  - `~/.claude/...`
  - `~/.config/opencode/...`
  - `~/.codex/...`
  - `.agents/...` where applicable
- The repo remains the orchestration layer; upstream sources only provide content.

## Component Breakdown

### `modules/agents/default.nix`

Responsibility:

- Extend the existing render and file-output logic to include the new local `init-deep` asset and the upstream Ralph assets for OpenCode and Codex.

Constraints:

- Must preserve existing behavior for unrelated commands and skills
- Must avoid coupling the new work to user-local state outside Home Manager-managed sources

### Local `init-deep` source file

Responsibility:

- Store the repo-owned text for the imported `init-deep` workflow.

Constraints:

- No update automation
- Content can diverge from upstream after import

### Ralph upstream source

Responsibility:

- Provide reproducible command/script source content for `ralph-loop` and `cancel-ralph`.

Constraints:

- Must come from GitHub, not local Claude plugin cache
- Must be pinned so builds are reproducible

## Data Flow

### `init-deep`

1. Local repo source file is added
2. `modules.agents.commands` references it
3. `modules/agents/default.nix` renders per-tool output
4. Home Manager writes generated files into Claude, OpenCode, and Codex locations

### Ralph loop

1. Pinned upstream Ralph source is fetched by Nix
2. Relevant command/script files are selected
3. Minimal local adapter logic rewrites metadata/path details if needed
4. Home Manager installs generated outputs for OpenCode and Codex

## Error Handling

- If the upstream Ralph repo layout changes, evaluation or build should fail loudly rather than silently omitting files.
- If a required Ralph file is missing, the Home Manager build should surface the failure immediately.
- If OpenCode or Codex require different metadata syntax from Claude, the transformation must be explicit and localized.
- `init-deep` should have no upstream failure mode after the initial import because it is fully local.

## Verification Strategy

### Build verification

- Run the relevant Home Manager or Nix build for the active configuration.
- Confirm the generated files for OpenCode and Codex exist in the expected outputs.

### Output verification

- Inspect rendered `init-deep` command/skill files for each target tool.
- Inspect rendered Ralph command files and verify referenced setup script paths exist.
- Confirm unrelated generated agent assets remain unchanged.

### Optional future hardening

- Add tests that assert generated files contain expected command metadata and translated paths.
- Keep this out of initial scope unless implementation pressure makes regressions likely.

## Design Decisions

### Why clone `init-deep` locally?

- The user wants only this feature, with no update burden.
- The command is prompt/spec content rather than runtime hook logic.
- A local copy is simpler than maintaining a partial upstream dependency.

### Why use GitHub for Ralph?

- It is reproducible across machines.
- It avoids dependence on mutable local plugin installation state.
- It satisfies the requirement to use the exact same upstream Ralph implementation as the Claude plugin source.

### Why keep adapters thin?

- The more behavior we rewrite locally, the harder it becomes to trust parity with upstream Ralph.
- Small, explicit transformations are easier to inspect and debug.

## Approved Outcome

After implementation:

- `init-deep` is locally owned in this repo and available through the existing command distribution path.
- Ralph loop is installed for OpenCode and Codex from a pinned GitHub upstream source.
- The integration is reproducible, Home Manager-managed, and independent from the local Claude plugin cache.
