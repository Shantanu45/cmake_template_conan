[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Name,

    [Parameter(Position = 1)]
    [string]$Destination,

    [string]$Namespace,

    [switch]$InitializeGit
)

$ErrorActionPreference = "Stop"

function Convert-ToSafeIdentifier([string]$Value) {
    $safe = $Value.ToLowerInvariant() -replace '[^a-z0-9_]+', '_'
    $safe = $safe.Trim('_')
    if ($safe -match '^[0-9]') {
        $safe = "project_$safe"
    }
    return $safe
}

$ProjectName = Convert-ToSafeIdentifier $Name
if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    throw "Project name '$Name' does not contain any usable identifier characters."
}

$TemplateRoot = Split-Path -Parent $PSCommandPath
if ([string]::IsNullOrWhiteSpace($Destination)) {
    $Destination = Join-Path (Split-Path -Parent $TemplateRoot) $ProjectName
}

$Destination = [System.IO.Path]::GetFullPath($Destination)
$TemplateRoot = [System.IO.Path]::GetFullPath($TemplateRoot)
$templatePrefix = $TemplateRoot.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
if ($Destination.StartsWith($templatePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Destination must be outside the template directory to avoid copying a project into itself."
}
if (Test-Path -LiteralPath $Destination) {
    throw "Destination '$Destination' already exists. Choose a new directory."
}

Write-Host "Creating '$ProjectName' in '$Destination'..."
New-Item -ItemType Directory -Path $Destination | Out-Null

try {
    $excludedRootEntries = @('.git', '.vs', 'out')
    Get-ChildItem -LiteralPath $TemplateRoot -Force |
        Where-Object { $_.Name -notin $excludedRootEntries } |
        Copy-Item -Destination $Destination -Recurse -Force

    $renameArguments = @($Name)
    if (-not [string]::IsNullOrWhiteSpace($Namespace)) {
        $renameArguments += $Namespace
    }
    & (Join-Path $Destination 'RenameProject.ps1') @renameArguments

    foreach ($documentationFile in @('README.md', 'README_building.md')) {
        $documentationPath = Join-Path $Destination $documentationFile
        $documentation = Get-Content -LiteralPath $documentationPath -Raw
        $documentation = $documentation -replace '(?s)\r?\n<!-- template-usage-start -->.*?<!-- template-usage-end -->\r?\n?', "`r`n"
        Set-Content -LiteralPath $documentationPath -Value $documentation.TrimEnd() -NoNewline
    }

    Remove-Item -LiteralPath (Join-Path $Destination 'RenameProject.ps1') -Force
    Remove-Item -LiteralPath (Join-Path $Destination 'NewProject.ps1') -Force
    Remove-Item -LiteralPath (Join-Path $Destination 'NewProject.bat') -Force

    if ($InitializeGit) {
        & git -C $Destination init
        if ($LASTEXITCODE -ne 0) {
            throw "git init failed with exit code $LASTEXITCODE."
        }
    }
}
catch {
    Write-Warning "Project creation failed. The partial directory was left at '$Destination' for inspection."
    throw
}

Write-Host "Project created successfully."
Write-Host "Next: cd '$Destination'"
Write-Host "      .\build.bat windows-msvc-debug test"
