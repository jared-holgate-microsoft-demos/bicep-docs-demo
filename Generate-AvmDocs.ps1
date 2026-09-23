$moduleRoots = Get-ChildItem (Join-Path $PSScriptRoot 'demo-module') `
    -Filter 'main.bicep' `
    -Recurse |
    ForEach-Object Directory

foreach ($moduleRoot in $moduleRoots) {
    $mainPath = Join-Path $moduleRoot 'main.bicep'
    $readmePath = Join-Path $moduleRoot 'README.md'
    $compiledTemplatePath = Join-Path $moduleRoot 'main.json'

    if (-not (Test-Path $readmePath)) {
        throw "README not found for module [$mainPath]."
    }

    $readme = Get-Content $readmePath -Raw
    $sections = @{
        resourceTypes = [regex]::Match($readme, '(?ms)^## Resource Types\r?\n.*?(?=^## |\z)').Value.TrimEnd()
        usageExamples = [regex]::Match($readme, '(?ms)^## Usage [Ee]xamples\r?\n.*?(?=^## |\z)').Value.TrimEnd()
        parameters = [regex]::Match($readme, '(?ms)^## Parameters\r?\n.*?(?=^## |\z)').Value.TrimEnd()
        crossReferencedModules = [regex]::Match($readme, '(?ms)^## Cross-referenced modules\r?\n.*?(?=^## |\z)').Value.TrimEnd()
        notes = [regex]::Match($readme, '(?ms)^## Notes\r?\n.*?(?=^## |\z)').Value.TrimEnd()
    }

    $primaryResourceType = [regex]::Match(
        $readme,
        '^# .+? `\[(.+?)\]`',
        'Multiline').Groups[1].Value
    $moduleReferenceMatch = [regex]::Match(
        $readme,
        "(?m)^module\s+(\w+)\s+'br/public:(.+?):<version>'")
    $compiledTemplate = Get-Content $compiledTemplatePath -Raw | ConvertFrom-Json -AsHashtable
    $typelessOutputNames = @(
        if ($compiledTemplate.outputs) {
            $compiledTemplate.outputs.Keys |
                Where-Object { -not $compiledTemplate.outputs[$_].ContainsKey('type') }
        }
    )

    $customValues = [ordered]@{
        primaryResourceType = $primaryResourceType
        moduleSymbolName = $moduleReferenceMatch.Groups[1].Value
        moduleReference = $moduleReferenceMatch.Groups[2].Value
        typelessOutputs = '|' + ($typelessOutputNames -join '|') + '|'
        hasCrossReferences = (-not [string]::IsNullOrEmpty($sections.crossReferencedModules)).ToString().ToLowerInvariant()
        hasNotes = (-not [string]::IsNullOrEmpty($sections.notes)).ToString().ToLowerInvariant()
        resourceTypes = $sections.resourceTypes
        usageExamples = $sections.usageExamples
        parameters = $sections.parameters
        crossReferencedModules = $sections.crossReferencedModules
        notes = $sections.notes
    }

    $customValuesPath = Join-Path $moduleRoot 'custom-values.json'

    try {
        [IO.File]::WriteAllText(
            $customValuesPath,
            ($customValues | ConvertTo-Json),
            [Text.UTF8Encoding]::new($false))

        & bicep docs generate $mainPath `
            --template-file (Join-Path $PSScriptRoot 'avm.scriban') `
            --custom-template-value-file-path $customValuesPath

        if ($LASTEXITCODE -ne 0) {
            throw "Failed to generate documentation for module [$mainPath]."
        }
    }
    finally {
        Remove-Item $customValuesPath -ErrorAction SilentlyContinue
    }
}
