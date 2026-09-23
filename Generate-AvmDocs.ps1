#Requires -Version 7.0
[CmdletBinding()]
param (
    [string] $RepositoryPath = $PSScriptRoot,

    [string] $TemplatePath = (Join-Path $PSScriptRoot 'avm.scriban')
)

$ErrorActionPreference = 'Stop'

$RepositoryPath = (Resolve-Path $RepositoryPath).Path
$modulesPath = Join-Path $RepositoryPath 'avm'
$startTime = Get-Date

Write-Host "Generating documentation for all modules in [$modulesPath]"

# The template derives every module-specific value itself, so one Bicep run covers all modules.
$output = & bicep docs generate `
    --pattern (Join-Path $modulesPath '**/main.bicep') `
    --template-file (Resolve-Path $TemplatePath).Path 2>&1
$exitCode = $LASTEXITCODE

$failedModules = foreach ($mainFile in Get-ChildItem $modulesPath -Filter 'main.bicep' -Recurse) {
    $module = [IO.Path]::GetRelativePath($RepositoryPath, $mainFile.DirectoryName).Replace('\', '/')
    $readme = Get-Item (Join-Path $mainFile.DirectoryName 'README.md') -ErrorAction SilentlyContinue

    if ($readme -and $readme.LastWriteTime -ge $startTime) {
        Write-Host "Generated documentation for [$module]."
    }
    else {
        Write-Host "Failed to generate documentation for [$module]."
        $module
    }
}

if ($exitCode -ne 0 -or $failedModules) {
    $output | Write-Host
    throw "Documentation generation failed for $(@($failedModules).Count) module(s)."
}

Write-Host "Generated documentation in $(((Get-Date) - $startTime).TotalSeconds.ToString('0.0'))s."
