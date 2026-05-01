# Databricks MCP Server

The **Databricks MCP Server** gives GitHub Copilot Agent the ability to interact with Databricks workspaces — running notebooks, querying SQL warehouses, managing clusters, browsing Unity Catalog, and more — directly from VS Code.

---

## Prerequisites

| Requirement | Version |
|---|---|
| VS Code | 1.99 + |
| GitHub Copilot extension | latest |
| Databricks CLI | 0.200 + |
| Databricks workspace | Any edition |
| Python | 3.8 + |

---

## Step 1 — Install the Databricks CLI

```bash
pip install databricks-cli
```

Or using the official standalone installer (recommended):

### macOS / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh
```

### Windows (PowerShell)
```powershell
iwr https://raw.githubusercontent.com/databricks/setup-cli/main/install.ps1 -useb | iex
```

Verify:
```bash
databricks --version   # should be 0.200+
```

---

## Step 2 — Configure authentication

### Option A — OAuth (recommended for interactive use)

```bash
databricks auth login --host https://<your-workspace>.azuredatabricks.net
```

Follow the browser prompts to authenticate. Credentials are stored in `~/.databrickscfg`.

### Option B — Personal Access Token

1. In your Databricks workspace, click your profile icon → **Settings** → **Developer** → **Access tokens** → **Generate new token**.
2. Copy the token.
3. Run:

```bash
databricks configure --token
```

Enter your workspace host URL and the token when prompted.

Verify authentication:
```bash
databricks clusters list
```

---

## Step 3 — Start the MCP server

```bash
databricks mcp start
```

By default the server listens on `stdio`. For HTTP mode (required for the `.vscode/mcp.json` HTTP transport):

```bash
databricks mcp start --http --port 8092
```

The server prints:

```
Databricks MCP server ready at http://127.0.0.1:8092/mcp
```

---

## Step 4 — Register in VS Code

Create (or update) `.vscode/mcp.json` in your workspace root:

```json
{
  "servers": {
    "databricks": {
      "type": "stdio",
      "command": "databricks",
      "args": ["mcp", "start"]
    }
  }
}
```

> **Note:** If using HTTP mode instead of `stdio`, use:
> ```json
> {
>   "servers": {
>     "databricks": {
>       "type": "http",
>       "url": "http://127.0.0.1:8092/mcp"
>     }
>   }
> }
> ```

> **Tip:** The master [`.vscode/mcp.json`](../.vscode/mcp.json) in this repo already includes this entry.

---

## Step 5 — Enable in Copilot Agent

1. Open **Copilot Chat** (`Ctrl+Alt+I` / `⌃⌘I`).
2. Switch to **Agent mode**.
3. Click **Configure Tools** (⚙️ icon).
4. Confirm **databricks** appears in the tool list and is enabled.

---

## Step 6 — Test it

Try the following prompts in Copilot Chat (Agent mode):

```
List all running clusters in my Databricks workspace.
```

```
Show me the tables in the default Unity Catalog schema.
```

```
Run this SQL on my SQL warehouse: SELECT COUNT(*) FROM sales.transactions
```

```
Show the execution plan for: SELECT user_id, SUM(revenue) FROM sales.orders GROUP BY user_id
```

---

## Common Tools Exposed

| Tool | Description |
|---|---|
| `list_clusters` | Lists all clusters in the workspace |
| `run_notebook` | Runs a Databricks notebook job |
| `execute_sql` | Executes SQL on a SQL warehouse |
| `list_catalogs` | Lists Unity Catalog catalogs |
| `list_schemas` | Lists schemas in a catalog |
| `list_tables` | Lists tables in a schema |
| `get_table_info` | Gets schema / metadata for a table |
| `list_jobs` | Lists Databricks jobs |
| `upload_file` | Uploads a file to DBFS or Workspace |

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `databricks: command not found` | Ensure the CLI is on your `PATH`. Re-open your terminal after installation. |
| `Error: 403 Forbidden` | Regenerate your access token or re-run `databricks auth login`. |
| `Connection refused` | Confirm `databricks mcp start` is running or that the `stdio` config is correct. |
| `DEFAULT profile not found` | Run `databricks configure --token` to create a `~/.databrickscfg` profile. |
| Cluster not found | Use `databricks clusters list` to confirm the cluster ID and status. |

---

## References

- [Databricks CLI documentation](https://docs.databricks.com/dev-tools/cli/databricks-cli.html)
- [Databricks MCP Server announcement](https://www.databricks.com/blog/announcing-databricks-mcp-server)
- [Unity Catalog documentation](https://docs.databricks.com/data-governance/unity-catalog/index.html)
- [VS Code MCP documentation](https://code.visualstudio.com/docs/copilot/chat/mcp-servers)
