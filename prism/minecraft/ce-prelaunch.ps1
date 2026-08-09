param(
    [Parameter(Mandatory = $true)]
    [string] $InstanceDir,

    [Parameter(Mandatory = $true)]
    [string] $JavaPath
)

$ErrorActionPreference = 'Stop'
$packUrl = 'https://evander-davis.github.io/ce-minecraft-pack/pack.toml'
$markerPath = Join-Path $InstanceDir '.ce-personal-data-migrated'
$logPath = Join-Path $InstanceDir 'ce-prelaunch.log'

function Write-CeLog {
    param([string] $Message)
    Add-Content -LiteralPath $logPath -Value "[$(Get-Date -Format o)] $Message"
}

function Copy-CeDirectory {
    param(
        [string] $SourceRoot,
        [string] $RelativePath
    )

    $sourcePath = Join-Path $SourceRoot $RelativePath
    if (-not (Test-Path -LiteralPath $sourcePath -PathType Container)) {
        return
    }

    $destinationPath = Join-Path $InstanceDir $RelativePath
    New-Item -ItemType Directory -Force -Path $destinationPath | Out-Null
    Get-ChildItem -LiteralPath $sourcePath -Force | Copy-Item -Destination $destinationPath -Recurse -Force
    Write-CeLog "Copied directory: $RelativePath"
}

function Copy-CeFile {
    param(
        [string] $SourceRoot,
        [string] $RelativePath
    )

    $sourcePath = Join-Path $SourceRoot $RelativePath
    $destinationPath = Join-Path $InstanceDir $RelativePath
    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf) -or (Test-Path -LiteralPath $destinationPath)) {
        return
    }

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destinationPath) | Out-Null
    Copy-Item -LiteralPath $sourcePath -Destination $destinationPath
    Write-CeLog "Copied file: $RelativePath"
}

if (-not (Test-Path -LiteralPath $markerPath -PathType Leaf)) {
    try {
        $candidateRoots = @(
            (Join-Path $env:USERPROFILE 'curseforge\minecraft\Instances\C&E 1.21.1'),
            (Join-Path $env:USERPROFILE 'Documents\Curse\Minecraft\Instances\C&E 1.21.1')
        )

        $sourceRoot = $candidateRoots | Where-Object { Test-Path -LiteralPath $_ -PathType Container } | Select-Object -First 1
        if ($sourceRoot) {
            Write-CeLog "Migrating personal data from: $sourceRoot"

            @(
                'xaero',
                'shaderpacks',
                'resourcepacks',
                'saves',
                'screenshots',
                'schematics',
                'config\inventoryprofilesnext',
                'config\jei\world',
                'config\xaero'
            ) | ForEach-Object { Copy-CeDirectory -SourceRoot $sourceRoot -RelativePath $_ }

            @(
                'options.txt',
                'servers.dat',
                'config\iris.properties',
                'config\xaerohud.txt',
                'config\xaeropatreon.txt'
            ) | ForEach-Object { Copy-CeFile -SourceRoot $sourceRoot -RelativePath $_ }

            Set-Content -LiteralPath $markerPath -Value "Migrated from $sourceRoot on $(Get-Date -Format o)"
            Write-CeLog 'Personal-data migration completed.'
        }
        else {
            Write-CeLog 'No existing CurseForge C&E 1.21.1 profile was found; migration will be retried next launch.'
        }
    }
    catch {
        Write-CeLog "Personal-data migration failed but pack update will continue: $($_.Exception.Message)"
    }
}

$bootstrapPath = Join-Path $InstanceDir 'packwiz-installer-bootstrap.jar'
if (-not (Test-Path -LiteralPath $bootstrapPath -PathType Leaf)) {
    throw "packwiz installer bootstrap is missing: $bootstrapPath"
}

Push-Location $InstanceDir
try {
    & $JavaPath -jar $bootstrapPath $packUrl
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
