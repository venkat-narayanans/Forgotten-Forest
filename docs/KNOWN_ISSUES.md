# KNOWN ISSUES — THE FORGOTTEN FOREST

This document tracks known issues, bugs, limitations, and their status.

| ID | Severity | System | Description | Status | Workaround / Mitigation |
| :--- | :--- | :--- | :--- | :--- | :--- |
| KI-001 | Low | QA / Testing | Direct multi-client automated launch is not supported via single-client MCP commands. | Open | Implement server-side multi-player simulation harness for concurrency validation; recommend manual Studio multi-client test for final release gates. |
| KI-002 | Low | Persistence | Studio places without API access enabled cannot access live DataStoreService. | Open | Implement in-memory MockDataStore provider for local Studio playtests. |
