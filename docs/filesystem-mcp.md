# Filesystem MCP Server

The **@modelcontextprotocol/server-filesystem** server gives GitHub Copilot Agent the ability to read, write, list, and search files in your workspace — including PySpark notebooks stored as JSON (`.ipynb` files) and Python scripts.

---

## Prerequisites

| Requirement | Version |
|---|---|
| Node.js | 18 + |
| npm / npx | bundled with Node.js |
| VS Code | 1.99 + |
| GitHub Copilot extension | latest |

---

## Step 1 — Install Node.js (if not already installed)

### Windows
Download and install from [https://nodejs.org](https://nodejs.org) (LTS version recommended).

### macOS
```bash
brew install node
```

### Linux (Debian / Ubuntu)
```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

Verify:
```bash
node --version   # should be 18+
npx --version
```

---

## Step 2 — (Optional) Install the package globally

`npx` will automatically download and run the package on first use, so a global install is optional. To install globally for offline use:

```bash
npm install -g @modelcontextprotocol/server-filesystem
```

---

## Step 3 — Register in VS Code

Create (or update) `.vscode/mcp.json` in your workspace root:

```json
{
  "servers": {
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "${workspaceFolder}"
      ]
    }
  }
}
```

The `${workspaceFolder}` variable is automatically replaced by VS Code with the path of your open workspace, so Copilot can only access files within it.

> **Tip:** The master [`.vscode/mcp.json`](../.vscode/mcp.json) in this repo already includes this entry.

---

## Step 4 — Enable in Copilot Agent

1. Open **Copilot Chat** (`Ctrl+Alt+I` / `⌃⌘I`).
2. Switch to **Agent mode**.
3. Click **Configure Tools** (⚙️ icon).
4. Confirm **filesystem** appears in the tool list and is enabled.

---

## Step 5 — Test it

Try the following prompts in Copilot Chat (Agent mode):

```
List all .ipynb notebook files in my workspace.
```

```
Read the first cell of my notebook and explain what it does.
```

```
Find all Python files that import pyspark and show me the import statements.
```

```
Create a new PySpark notebook scaffold at notebooks/new_analysis.ipynb.
```

---

## Common Tools Exposed

| Tool | Description |
|---|---|
| `read_file` | Reads the full content of a file |
| `write_file` | Creates or overwrites a file |
| `list_directory` | Lists files and directories at a path |
| `search_files` | Searches for files matching a glob pattern |
| `get_file_info` | Returns metadata (size, modified date) for a file |
| `create_directory` | Creates a new directory |
| `move_file` | Moves or renames a file |

---

## Restricting Access

To limit access to specific subdirectories (recommended for security), pass multiple paths:

```json
"args": [
  "-y",
  "@modelcontextprotocol/server-filesystem",
  "${workspaceFolder}/notebooks",
  "${workspaceFolder}/src"
]
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `npx: command not found` | Install Node.js (see Step 1). |
| `EACCES: permission denied` | Run `npx` with a user-writable npm cache: `npm config set cache ~/.npm` |
| Agent cannot see notebook files | Ensure the workspace path passed in `args` is correct. |
| `Cannot find module` error | Delete the npx cache and retry: `npx clear-npx-cache` |

---

## References

- [@modelcontextprotocol/server-filesystem on npm](https://www.npmjs.com/package/@modelcontextprotocol/server-filesystem)
- [VS Code MCP documentation](https://code.visualstudio.com/docs/copilot/chat/mcp-servers)
