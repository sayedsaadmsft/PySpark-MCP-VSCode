# GitHub MCP Server

The **GitHub MCP Server** gives GitHub Copilot Agent direct access to GitHub — searching repositories, reading issues and pull requests, managing files through the API, and more — without leaving VS Code.

---

## Prerequisites

| Requirement | Version |
|---|---|
| VS Code | 1.99 + |
| GitHub Copilot extension | latest |
| GitHub Personal Access Token (PAT) | classic or fine-grained |

---

## Step 1 — Generate a GitHub Personal Access Token

1. Go to [https://github.com/settings/tokens](https://github.com/settings/tokens).
2. Click **Generate new token** → **Generate new token (classic)**.
3. Give it a descriptive name, e.g. `vscode-mcp`.
4. Select the following scopes:
   - `repo` — Full repository access (read/write code, issues, PRs).
   - `read:org` — Read organization membership (optional, for org repos).
   - `read:user` — Read user profile data.
5. Click **Generate token** and copy it — you will not see it again.

> **Fine-grained tokens:** If using a fine-grained PAT, grant **Contents**, **Issues**, **Pull requests**, and **Metadata** read/write permissions on the target repositories.

---

## Step 2 — Store the token securely

### Option A — VS Code secret store (recommended)

VS Code's MCP `inputs` feature will prompt you for the token once and store it in the system secret store. The `.vscode/mcp.json` in this repo already uses this approach (see `${input:github_token}`).

### Option B — Environment variable

```bash
export GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
```

Add this line to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.) so it persists across sessions.

---

## Step 3 — Run the GitHub MCP server

### Using Docker (recommended, no local install needed)

```bash
docker run -i --rm \
  -e GITHUB_PERSONAL_ACCESS_TOKEN=<YOUR_TOKEN> \
  -p 8091:8091 \
  ghcr.io/github/github-mcp-server:latest
```

### Using npm (alternative)

```bash
npm install -g @github/github-mcp-server
github-mcp-server --port 8091
```

The server prints:

```
GitHub MCP server listening at http://127.0.0.1:8091/mcp
```

---

## Step 4 — Register in VS Code

Create (or update) `.vscode/mcp.json` in your workspace root:

```json
{
  "servers": {
    "github": {
      "type": "http",
      "url": "http://127.0.0.1:8091/mcp",
      "headers": {
        "Authorization": "Bearer ${input:github_token}"
      }
    }
  },
  "inputs": [
    {
      "id": "github_token",
      "description": "GitHub Personal Access Token",
      "type": "promptString",
      "password": true
    }
  ]
}
```

> **Tip:** The master [`.vscode/mcp.json`](../.vscode/mcp.json) in this repo already includes this entry.

---

## Step 5 — Enable in Copilot Agent

1. Open **Copilot Chat** (`Ctrl+Alt+I` / `⌃⌘I`).
2. Switch to **Agent mode**.
3. Click **Configure Tools** (⚙️ icon).
4. Confirm **github** appears in the tool list and is enabled.

---

## Step 6 — Test it

Try the following prompts in Copilot Chat (Agent mode):

```
Search GitHub for open-source PySpark ETL pipeline examples.
```

```
List the open issues in my current repository.
```

```
Show me the latest pull requests merged into the main branch.
```

```
Create a new GitHub issue titled "Add Spark streaming notebook example".
```

---

## Common Tools Exposed

| Tool | Description |
|---|---|
| `search_repositories` | Searches GitHub for repositories |
| `get_file_contents` | Reads a file from any GitHub repo |
| `list_issues` | Lists issues in a repository |
| `create_issue` | Creates a new issue |
| `list_pull_requests` | Lists pull requests |
| `get_commit` | Fetches commit details |
| `search_code` | Searches code across GitHub |
| `list_commits` | Lists commits on a branch |

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `401 Unauthorized` | Check that your PAT is valid and not expired. |
| `403 Forbidden` | Add the required scopes to your PAT (see Step 1). |
| `Connection refused on port 8091` | Ensure the GitHub MCP server is running. |
| Token prompt appears every time | Allow VS Code to save the secret in the system keychain when prompted. |

---

## References

- [GitHub MCP Server on GitHub](https://github.com/github/github-mcp-server)
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
- [VS Code MCP documentation](https://code.visualstudio.com/docs/copilot/chat/mcp-servers)
