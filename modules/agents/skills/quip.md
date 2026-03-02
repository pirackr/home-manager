Work with Quip documents.

## Read a Quip document

Use the `quip2markdown` CLI tool to fetch a Quip document and convert it to Markdown.

```
quip2markdown <url_or_id>
```

- Accepts a full Quip URL (e.g., `https://quip.com/XYZ123/doc-title`) or just the document ID (e.g., `XYZ123`).
- Authentication is handled via the `QUIP_TOKEN` environment variable (already configured).

Ask the user for the Quip URL or document ID if not provided as an argument, then run the command and return the Markdown output.
