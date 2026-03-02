Use the Slack MCP tool `get_conversation_history` to read the **#incidents** channel (incident.io integration).

Retrieve messages from the last 24 hours and extract:
- Incident title
- Severity (SEV-0 through SEV-4)
- Current status (active, mitigated, resolved)
- Key updates and timeline

Present a structured summary grouped by status:

1. **Active incidents** (highest severity first)
2. **Mitigated incidents**
3. **Resolved incidents** (last 24h)

For each incident include:
- Title and severity
- Current status and duration
- Brief summary of latest update
- Link to the incident (if available)

If there are no incidents in the last 24 hours, report that clearly.
