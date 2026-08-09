param()

$PackwizArguments = $args

$ErrorActionPreference = 'Stop'

$workspaceRoot = Split-Path -Parent $PSScriptRoot
$packwiz = Join-Path $workspaceRoot '.toolchains\packwiz\packwiz.exe'
$cache = Join-Path $workspaceRoot '.toolchains\packwiz-cache'
$config = Join-Path $workspaceRoot '.toolchains\packwiz-config.toml'

if (-not (Test-Path -LiteralPath $packwiz -PathType Leaf)) {
    throw "packwiz was not found at $packwiz"
}

Push-Location $PSScriptRoot
try {
    & $packwiz --cache $cache --config $config @PackwizArguments
    if ($LASTEXITCODE -ne 0) {
        throw "packwiz exited with code $LASTEXITCODE"
    }
}
finally {
    Pop-Location
}
