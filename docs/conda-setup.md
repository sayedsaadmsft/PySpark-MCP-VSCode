# Conda Environment Setup for MCP Servers

This guide walks you through creating a dedicated **conda** environment for the MCP servers used in this repository, installing the correct Python version, and getting all required packages in place on Windows.

---

## Prerequisites

| Tool | Minimum version | Download |
|---|---|---|
| Miniconda or Anaconda | latest | https://docs.conda.io/en/latest/miniconda.html |
| PowerShell | 5.1 (Windows 10/11 built-in) | — |
| Node.js | 18 + | https://nodejs.org (for the Filesystem MCP) |
| Java (JDK) | 17 | bundled via conda (see Step 2) |

> **Tip:** Miniconda is the lightweight choice — it installs only conda and Python, without the full Anaconda package suite.

---

## Step 1 — Open a conda-enabled terminal

On Windows, open **Anaconda Prompt** (or **Miniconda Prompt**) from the Start menu, or run this in PowerShell to initialise conda:

```powershell
conda init powershell
# Restart PowerShell after running this once
```

---

## Step 2 — Run the setup script

From the **repository root** in PowerShell:

```powershell
.\scripts\setup-conda-env.ps1
```

The script will:

1. Check that `conda` is on your PATH.
2. Create a conda environment named **`mcp-servers`** with **Python 3.10** and **Java 17** (via the `environment.yml` file).
3. Install all Python MCP packages listed in `requirements.txt` using `pip`.
4. Print a summary with the activation command.

### What gets installed

| Package | Purpose |
|---|---|
| Python 3.10 | Required runtime for all Python-based MCP servers |
| OpenJDK 17 | Required by Apache Spark / PySpark |
| `pyspark>=3.4` | Apache Spark Python runtime |
| `pyspark-mcp>=0.1` | PySpark MCP server |
| `databricks-sdk>=0.20` | Databricks Python bindings (used by the Databricks MCP server) |

---

## Step 3 — Activate the environment

```powershell
conda activate mcp-servers
```

You should see `(mcp-servers)` in your prompt prefix.

To confirm the Python version:

```powershell
python --version   # Python 3.10.x
```

---

## Step 4 — Start the MCP servers

With the environment active, open separate terminal tabs (or VS Code split panes) for each server:

```powershell
# Terminal 1 — PySpark MCP (HTTP on port 8090)
conda activate mcp-servers
pyspark-mcp --master "local[*]" --port 8090
```

```powershell
# Terminal 2 — Databricks MCP (stdio, started automatically by VS Code)
# No manual start needed when using the stdio transport in .vscode/mcp.json
```

The Filesystem MCP (`@modelcontextprotocol/server-filesystem`) is a **Node.js** package and is launched automatically by VS Code via `npx` — no manual start needed.

---

## Step 5 — Install the Node.js Filesystem MCP (once)

If you haven't already, install Node.js 18+ then optionally pre-cache the package:

```powershell
npm install -g @modelcontextprotocol/server-filesystem
```

Verify:

```powershell
node --version   # v18.x or higher
```

---

## Step 6 — Install the Databricks CLI (once)

The Databricks MCP server requires the standalone **Databricks CLI** (Go binary). Run in PowerShell:

```powershell
iwr https://raw.githubusercontent.com/databricks/setup-cli/main/install.ps1 -useb | iex
```

Verify:

```powershell
databricks --version   # 0.200+
```

Then authenticate:

```powershell
databricks auth login --host https://<your-workspace>.azuredatabricks.net
```

---

## Updating packages

To update all MCP packages to the latest versions, re-run the setup script:

```powershell
.\scripts\setup-conda-env.ps1
```

Or manually:

```powershell
conda activate mcp-servers
pip install --upgrade -r requirements.txt
```

---

## Removing the environment

```powershell
conda deactivate
conda env remove --name mcp-servers
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `conda: command not found` | Run `conda init powershell` and restart your terminal. |
| Script fails with "execution policy" error | Run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |
| `pyspark-mcp: command not found` after activation | Ensure `(mcp-servers)` is in your prompt; re-run `conda activate mcp-servers` |
| `JAVA_HOME` errors | Java 17 is bundled via conda; verify with `java -version` inside the active env |
| Port 8090 already in use | Find the process: `netstat -ano | findstr :8090` and stop it, or use a different port via `--port` |

---

## References

- [Conda documentation](https://docs.conda.io)
- [Miniconda installer](https://docs.conda.io/en/latest/miniconda.html)
- [PySpark MCP Server guide](pyspark-mcp.md)
- [Databricks MCP Server guide](databricks-mcp.md)
