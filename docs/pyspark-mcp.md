# PySpark MCP Server

The **pyspark-mcp** server exposes PySpark capabilities (query planning, DataFrame operations, SQL optimization, cluster management) directly to GitHub Copilot Agent inside VS Code.

---

## Prerequisites

| Requirement | Version |
|---|---|
| Python | 3.8 + |
| Java (JDK) | 11 or 17 |
| Apache Spark | 3.x |
| VS Code | 1.99 + |
| GitHub Copilot extension | latest |

---

## Step 1 — Install the server

```bash
pip install pyspark-mcp
```

Verify the installation:

```bash
pyspark-mcp --version
```

---

## Step 2 — Start the server

Run the server in a terminal **before** opening VS Code (or keep it running in a dedicated terminal inside VS Code):

```bash
pyspark-mcp --master "local[*]" --port 8090
```

| Flag | Description |
|---|---|
| `--master` | Spark master URL. Use `local[*]` for local mode, or `spark://<host>:7077` for a cluster. |
| `--port` | HTTP port the MCP endpoint listens on (default: `8090`). |

The server will print:

```
MCP endpoint ready at http://127.0.0.1:8090/mcp
```

### Running against a remote Spark cluster

```bash
pyspark-mcp --master "spark://my-cluster:7077" --port 8090
```

### Running with YARN / Kubernetes

```bash
# YARN
pyspark-mcp --master "yarn" --port 8090

# Kubernetes
pyspark-mcp --master "k8s://https://<k8s-api-server>" --port 8090
```

---

## Step 3 — Register in VS Code

Create (or update) `.vscode/mcp.json` in your workspace root:

```json
{
  "servers": {
    "pyspark-mcp": {
      "type": "http",
      "url": "http://127.0.0.1:8090/mcp"
    }
  }
}
```

> **Tip:** The master [`.vscode/mcp.json`](../.vscode/mcp.json) in this repo already includes this entry.

---

## Step 4 — Enable in Copilot Agent

1. Open **Copilot Chat** (`Ctrl+Alt+I` / `⌃⌘I`).
2. Switch to **Agent mode** (dropdown at the top of the chat panel).
3. Click **Configure Tools** (⚙️ icon).
4. Confirm **pyspark-mcp** appears in the tool list and is enabled.

---

## Step 5 — Test it

Paste the following prompts in Copilot Chat (Agent mode):

```
Get the optimized execution plan for:
SELECT customer_id, SUM(amount) FROM orders GROUP BY customer_id
```

```
Show the physical plan for a DataFrame that filters rows where age > 30 and selects name and email columns.
```

```
Explain the difference between a SortMergeJoin and a BroadcastHashJoin in Spark.
```

---

## Common Tools Exposed

| Tool | Description |
|---|---|
| `get_query_plan` | Returns the logical and physical plan for a SQL query |
| `explain_dataframe` | Explains the execution plan of a DataFrame operation |
| `list_tables` | Lists available tables in the active Spark session |
| `run_sql` | Executes a SQL query and returns results |
| `get_spark_config` | Reads current Spark configuration |
| `set_spark_config` | Updates a Spark configuration property |

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `Connection refused on port 8090` | Make sure `pyspark-mcp` is running **before** VS Code loads the MCP server. |
| `JAVA_HOME not set` | Export `JAVA_HOME` pointing to your JDK: `export JAVA_HOME=/usr/lib/jvm/java-17-openjdk` |
| `pyspark not found` | Run `pip install pyspark` or activate the correct Python environment. |
| Server hangs on startup | Check that no other process is using port 8090 (`lsof -i :8090`). |

---

## References

- [pyspark-mcp on PyPI](https://pypi.org/project/pyspark-mcp/)
- [Apache Spark documentation](https://spark.apache.org/docs/latest/)
- [VS Code MCP documentation](https://code.visualstudio.com/docs/copilot/chat/mcp-servers)
