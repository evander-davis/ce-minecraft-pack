[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

& (Join-Path $PSScriptRoot 'Invoke-Packwiz.ps1') refresh

$indexPath = Join-Path $PSScriptRoot 'index.toml'
$indexedPaths = Select-String -LiteralPath $indexPath -Pattern '^file = "(.+)"$' |
    ForEach-Object { $_.Matches[0].Groups[1].Value.Replace('\', '/') }

$forbiddenPrefixes = @(
    '.git/',
    '.github/',
    'dist/',
    'prism/',
    'xaero/',
    'shaderpacks/',
    'saves/',
    'screenshots/',
    'schematics/',
    'config/ars_nouveau/search_index/',
    'config/inventoryprofilesnext/',
    'config/jei/world/',
    'config/xaero/'
)

$forbiddenFiles = @(
    '.gitattributes',
    '.gitignore',
    '.nojekyll',
    '.packwizignore',
    'AGENTS.md',
    'Build-Prism-Starter.ps1',
    'Invoke-Packwiz.ps1',
    'README.md',
    'Test-Pack.ps1',
    'options.txt',
    'servers.dat',
    'config/iris.properties',
    'config/resourceful-config-web.json',
    'config/sodium-fingerprint.json',
    'config/xaerohud.txt',
    'config/xaeropatreon.txt'
)

$violations = $indexedPaths | Where-Object {
    $path = $_
    ($forbiddenFiles -contains $path) -or
    ($forbiddenPrefixes | Where-Object { $path.StartsWith($_, [StringComparison]::OrdinalIgnoreCase) })
}

if ($violations) {
    throw "Personal, runtime, or repository-only files are indexed:`n$($violations -join "`n")"
}

$metadataCount = (Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'mods') -Filter '*.pw.toml' -File).Count
$localModCount = (Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'mods') -File |
    Where-Object { $_.Name -notlike '*.pw.toml' }).Count

Write-Output "Pack validation passed. Indexed files: $($indexedPaths.Count); external mods: $metadataCount; local custom mods: $localModCount."
