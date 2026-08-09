param()

$ErrorActionPreference = 'Stop'

$distRoot = Join-Path $PSScriptRoot 'dist'
$stagingRoot = Join-Path $distRoot '.prism-staging'
$minecraftRoot = Join-Path $stagingRoot 'minecraft'
$outputPath = Join-Path $distRoot 'C&E 1.21.1 Prism Starter-1.2.0.zip'
$bootstrapUrl = 'https://github.com/packwiz/packwiz-installer-bootstrap/releases/latest/download/packwiz-installer-bootstrap.jar'

if (Test-Path -LiteralPath $stagingRoot) {
    Remove-Item -LiteralPath $stagingRoot -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $minecraftRoot | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'prism\instance.cfg') -Destination $stagingRoot
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'prism\mmc-pack.json') -Destination $stagingRoot
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'prism\minecraft\ce-prelaunch.ps1') -Destination $minecraftRoot
Invoke-WebRequest -Uri $bootstrapUrl -OutFile (Join-Path $minecraftRoot 'packwiz-installer-bootstrap.jar')

if (Test-Path -LiteralPath $outputPath) {
    Remove-Item -LiteralPath $outputPath -Force
}

Compress-Archive -Path (Join-Path $stagingRoot '*') -DestinationPath $outputPath -CompressionLevel Optimal
Remove-Item -LiteralPath $stagingRoot -Recurse -Force

$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $outputPath).Hash
Write-Output "Created: $outputPath"
Write-Output "SHA256: $hash"
