<#
.SYNOPSIS
    Creates (or refreshes) the "mcp-servers" conda environment and installs
    all required Python MCP packages from requirements.txt.

.DESCRIPTION
    Run this script once before using the MCP servers in VS Code.
    Re-run it any time you want to update packages to the latest versions.

    Prerequisites:
      - Anaconda or Miniconda must be installed and on your PATH.
      - Run this script from the repository root directory.

.EXAMPLE
    # From the repo root in PowerShell:
    .\scripts\setup-conda-env.ps1

.NOTES
    Tested on Windows 10/11 with Miniconda3.
    Requires PowerShell 5.1 or later.
#>

[CmdletBinding()]
param(
    [string]$EnvName    = "mcp-servers",
    [string]$PythonVer  = "3.10"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# Helper: write a colored status line
# ---------------------------------------------------------------------------
function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

# ---------------------------------------------------------------------------
# 0. Verify conda is available
# ---------------------------------------------------------------------------
Write-Step "Checking conda installation..."

if (-not (Get-Command conda -ErrorAction SilentlyContinue)) {
    Write-Error @"
conda was not found on your PATH.
Please install Miniconda or Anaconda and re-open this terminal.
  Download: https://docs.conda.io/en/latest/miniconda.html
"@
    exit 1
}

$condaVersion = conda --version
Write-Host "Found: $condaVersion" -ForegroundColor Green

# ---------------------------------------------------------------------------
# 1. Locate requirements.txt (must be run from repo root)
# ---------------------------------------------------------------------------
Write-Step "Locating requirements.txt..."

$repoRoot       = Split-Path -Parent $PSScriptRoot
$requirementsFile = Join-Path $repoRoot "requirements.txt"

if (-not (Test-Path $requirementsFile)) {
    Write-Error "requirements.txt not found at: $requirementsFile`nRun this script from the repository root."
    exit 1
}

Write-Host "Found: $requirementsFile" -ForegroundColor Green

# ---------------------------------------------------------------------------
# 2. Create or update the conda environment
# ---------------------------------------------------------------------------
$envExists = conda env list | Select-String -Pattern "^\s*$EnvName\s"

if ($envExists) {
    Write-Step "Conda environment '$EnvName' already exists — updating..."
    conda env update --name $EnvName --file (Join-Path $repoRoot "environment.yml") --prune
} else {
    Write-Step "Creating conda environment '$EnvName' (Python $PythonVer)..."
    conda env create --name $EnvName --file (Join-Path $repoRoot "environment.yml")
}

if ($LASTEXITCODE -ne 0) {
    Write-Error "conda env create/update failed (exit code $LASTEXITCODE)."
    exit $LASTEXITCODE
}

Write-Host "Environment '$EnvName' is ready." -ForegroundColor Green

# ---------------------------------------------------------------------------
# 3. Install / upgrade pip packages inside the environment
# ---------------------------------------------------------------------------
Write-Step "Installing Python MCP packages from requirements.txt..."

conda run --name $EnvName python -m pip install --upgrade pip
conda run --name $EnvName python -m pip install --upgrade -r $requirementsFile

if ($LASTEXITCODE -ne 0) {
    Write-Error "pip install failed (exit code $LASTEXITCODE)."
    exit $LASTEXITCODE
}

# ---------------------------------------------------------------------------
# 4. Verify key packages
# ---------------------------------------------------------------------------
Write-Step "Verifying installed packages..."

$packages = @("pyspark", "pyspark_mcp", "databricks")

foreach ($pkg in $packages) {
    $result = conda run --name $EnvName python -c "import importlib; m = importlib.util.find_spec('$pkg'); print('OK' if m else 'MISSING')" 2>&1
    if ($result -match "OK") {
        Write-Host "  [OK] $pkg" -ForegroundColor Green
    } else {
        Write-Warning "  [WARN] $pkg could not be imported — check the output above."
    }
}

# ---------------------------------------------------------------------------
# 5. Print activation instructions
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "--------------------------------------------------------------" -ForegroundColor Yellow
Write-Host " Setup complete!" -ForegroundColor Yellow
Write-Host ""
Write-Host " To activate the environment in a new terminal, run:" -ForegroundColor Yellow
Write-Host "   conda activate $EnvName" -ForegroundColor White
Write-Host ""
Write-Host " Then start the PySpark MCP server:" -ForegroundColor Yellow
Write-Host "   pyspark-mcp --master `"local[*]`" --port 8090" -ForegroundColor White
Write-Host "--------------------------------------------------------------" -ForegroundColor Yellow
Write-Host ""
