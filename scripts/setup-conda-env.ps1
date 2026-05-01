# setup-conda-env.ps1
# Creates the "mcp-servers" conda environment if it does not exist,
# installs required Python packages, and installs the Node.js MCP server.
# Run from the repository root: .\scripts\setup-conda-env.ps1

$EnvName = "mcp-servers"
$PythonVer = "3.10"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$RequirementsFile = Join-Path $RepoRoot "requirements.txt"

# ---------------------------------------------------------------------------
# Step 1 — Check conda
# ---------------------------------------------------------------------------
Write-Host "==> Checking conda..." -ForegroundColor Cyan

$condaCheck = Get-Command conda -ErrorAction SilentlyContinue
if (-not $condaCheck) {
    Write-Host "ERROR: conda not found. Install Miniconda or Anaconda first." -ForegroundColor Red
    exit 1
}

Write-Host "conda found: $(conda --version)" -ForegroundColor Green

# ---------------------------------------------------------------------------
# Step 2 — Create conda environment if it does not exist
# ---------------------------------------------------------------------------
Write-Host "==> Checking conda environment '$EnvName'..." -ForegroundColor Cyan

$envList = conda env list
$envExists = $envList | Select-String $EnvName

if ($envExists) {
    Write-Host "Environment '$EnvName' already exists. Skipping creation." -ForegroundColor Green
} else {
    Write-Host "Creating environment '$EnvName' with Python $PythonVer..." -ForegroundColor Cyan
    conda create --name $EnvName python=$PythonVer -y
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: conda create failed." -ForegroundColor Red
        exit 1
    }
    Write-Host "Environment '$EnvName' created." -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# Step 3 — Install required Python packages
# ---------------------------------------------------------------------------
Write-Host "==> Installing Python packages from requirements.txt..." -ForegroundColor Cyan

if (-not (Test-Path $RequirementsFile)) {
    Write-Host "ERROR: requirements.txt not found at $RequirementsFile" -ForegroundColor Red
    exit 1
}

conda run --name $EnvName python -m pip install --upgrade pip
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: pip upgrade failed." -ForegroundColor Red
    exit 1
}

conda run --name $EnvName python -m pip install -r $RequirementsFile
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: pip install failed." -ForegroundColor Red
    exit 1
}

Write-Host "Python packages installed." -ForegroundColor Green

# ---------------------------------------------------------------------------
# Step 4 — Install Node.js MCP server if not already installed
# ---------------------------------------------------------------------------
Write-Host "==> Checking Node.js MCP filesystem server..." -ForegroundColor Cyan

$npmCheck = Get-Command npm -ErrorAction SilentlyContinue
if (-not $npmCheck) {
    Write-Host "WARNING: npm not found. Skipping Node.js MCP server install." -ForegroundColor Yellow
    Write-Host "Install Node.js from https://nodejs.org/ then run:" -ForegroundColor Yellow
    Write-Host "  npm install -g @modelcontextprotocol/server-filesystem" -ForegroundColor White
} else {
    $mcpInstalled = npm list -g --depth=0 2>$null | Select-String "server-filesystem"
    if ($mcpInstalled) {
        Write-Host "MCP filesystem server already installed." -ForegroundColor Green
    } else {
        Write-Host "Installing @modelcontextprotocol/server-filesystem..." -ForegroundColor Cyan
        npm install -g @modelcontextprotocol/server-filesystem
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: npm install failed." -ForegroundColor Red
            exit 1
        }
        Write-Host "MCP filesystem server installed." -ForegroundColor Green
    }
}

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Yellow
Write-Host "Activate the environment with:  conda activate $EnvName" -ForegroundColor White
Write-Host "Start the PySpark MCP server:   pyspark-mcp --master local[*] --port 8090" -ForegroundColor White
Write-Host ""
