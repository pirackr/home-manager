# /ralph

Use the installed Ralph skill and Ralph script from this Home Manager setup.

## What this command is for

- Turn an existing PRD into Ralph's `prd.json` format
- Prepare a task set for autonomous Ralph iterations
- Point the user to the managed Ralph runner script

## Workflow

1. Read the PRD or requirements document the user wants converted.
2. Use the installed Ralph skill for the conversion rules and output format.
3. Write or update `prd.json` following the Ralph format.
4. Tell the user how to run Ralph from this environment:

```bash
~/.config/opencode/scripts/ralph.sh
```

For Codex-managed environments, the runner path is:

```bash
~/.codex/scripts/ralph.sh
```

## Notes

- Prefer the linked Ralph skill for story-sizing and acceptance-criteria guidance.
- If the user does not have a PRD yet, ask them for the requirements document to convert first.
