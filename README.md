# PySpark MCP Servers for VS Code

> A guide for PySpark developers who write notebooks (`.ipynb` JSON files) in VS Code and want to supercharge GitHub Copilot Agent with Spark-aware tools.

---

## What is MCP?

**Model Context Protocol (MCP)** is an open standard that lets AI assistants (like GitHub Copilot) call external tools and data sources in a structured way. Each MCP server exposes a set of *tools* that Copilot Agent can invoke on your behalf — reading files, running Spark queries, browsing GitHub, and more.

---

## Required MCP Servers

| # | MCP Server | Purpose | Guide |
|---|---|---|---|
| 1 | **pyspark-mcp** | Query planning, SQL optimization, DataFrame explain, Spark config | [docs/pyspark-mcp.md](docs/pyspark-mcp.md) |
| 2 | **filesystem** | Read / write notebook JSON files and Python scripts in your workspace | [docs/filesystem-mcp.md](docs/filesystem-mcp.md) |
| 3 | **github** | Browse repos, manage issues & PRs, search code on GitHub | [docs/github-mcp.md](docs/github-mcp.md) |
| 4 | **databricks** | Run notebooks, query SQL warehouses, browse Unity Catalog | [docs/databricks-mcp.md](docs/databricks-mcp.md) |

---

## Quick Start

### 1 — Prerequisites

| Tool | Minimum version | How to check |
|---|---|---|
| VS Code | 1.99 | `code --version` |
| GitHub Copilot extension | latest | Extensions panel |
| Python | 3.8 | `python --version` |
| Java (JDK) | 11 | `java -version` |
| Node.js | 18 | `node --version` |
| Databricks CLI | 0.200 | `databricks --version` |

### 2 — Install the servers

```bash
# PySpark MCP (Python)
pip install pyspark-mcp

# Filesystem MCP (Node.js — downloaded automatically by npx)
# No install needed; npx fetches it on first use.

# GitHub MCP — run via Docker or npm
docker pull ghcr.io/github/github-mcp-server:latest
# or: npm install -g @github/github-mcp-server

# Databricks CLI (includes the MCP server)
pip install databricks-cli
# or follow the standalone installer in docs/databricks-mcp.md
```

### 3 — Start the servers

Open a terminal for each server (or use VS Code's integrated terminal with split panes):

```bash
# Terminal 1 — PySpark MCP
pyspark-mcp --master "local[*]" --port 8090

# Terminal 2 — GitHub MCP
docker run -i --rm \
  -e GITHUB_PERSONAL_ACCESS_TOKEN=<YOUR_TOKEN> \
  -p 8091:8091 \
  ghcr.io/github/github-mcp-server:latest

# Terminal 3 — Databricks MCP (stdio, started by VS Code automatically)
# No manual start needed when using the stdio transport in mcp.json.

# The Filesystem MCP is also started automatically by VS Code via npx.
```

### 4 — Configure VS Code

The `.vscode/mcp.json` file in this repository already contains all four servers. Copy it to your own project:

```bash
cp .vscode/mcp.json <your-project>/.vscode/mcp.json
```

Or create it manually — see the full reference config: [`.vscode/mcp.json`](.vscode/mcp.json).

### 5 — Enable in Copilot Agent

1. Open **Copilot Chat** (`Ctrl+Alt+I` / `⌃⌘I`).
2. Switch to **Agent mode** (dropdown at the top of the chat panel).
3. Click **Configure Tools** (⚙️ icon).
4. You should see all four servers listed:
   - ✅ `pyspark-mcp`
   - ✅ `filesystem`
   - ✅ `github`
   - ✅ `databricks`

### 6 — Test it

```
Get the optimized execution plan for:
SELECT customer_id, SUM(amount) FROM orders GROUP BY customer_id
```

```
List all .ipynb files in my workspace and summarize the first notebook.
```

```
Show me the open issues in my GitHub repo related to PySpark.
```

```
List all running clusters in my Databricks workspace.
```

---

## Repository Structure

```
.
├── .vscode/
│   └── mcp.json          # VS Code MCP server registrations (all 4 servers)
├── docs/
│   ├── pyspark-mcp.md    # PySpark MCP server — full guide
│   ├── filesystem-mcp.md # Filesystem MCP server — full guide
│   ├── github-mcp.md     # GitHub MCP server — full guide
│   └── databricks-mcp.md # Databricks MCP server — full guide
└── README.md             # This file
```

---

## Detailed Guides

Each MCP server has its own step-by-step guide with installation, configuration, available tools, and troubleshooting:

- 🔥 [PySpark MCP Server](docs/pyspark-mcp.md)
- 📁 [Filesystem MCP Server](docs/filesystem-mcp.md)
- 🐙 [GitHub MCP Server](docs/github-mcp.md)
- 🧱 [Databricks MCP Server](docs/databricks-mcp.md)

---

## References

- [VS Code MCP documentation](https://code.visualstudio.com/docs/copilot/chat/mcp-servers)
- [Model Context Protocol specification](https://modelcontextprotocol.io)
- [Apache Spark documentation](https://spark.apache.org/docs/latest/)
- [Databricks documentation](https://docs.databricks.com/)
- [GitHub MCP Server](https://github.com/github/github-mcp-server)
