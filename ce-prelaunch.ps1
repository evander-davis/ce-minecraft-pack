param()

$ErrorActionPreference = 'Stop'
$InstanceDir = $PSScriptRoot
$packUrl = 'https://evander-davis.github.io/ce-minecraft-pack/pack.toml'
$markerPath = Join-Path $InstanceDir '.ce-personal-data-migrated'
$logPath = Join-Path $InstanceDir 'ce-prelaunch.log'

$instanceConfigPath = Join-Path (Split-Path -Parent $InstanceDir) 'instance.cfg'
if (-not (Test-Path -LiteralPath $instanceConfigPath -PathType Leaf)) {
    throw "Prism instance configuration is missing: $instanceConfigPath"
}

$javaSetting = Get-Content -LiteralPath $instanceConfigPath |
    Where-Object { $_ -like 'JavaPath=*' } |
    Select-Object -First 1

if (-not $javaSetting) {
    throw 'Prism has not recorded a Java path for this instance. Open Edit > Settings > Java, run Auto-detect, and select Java 21.'
}

$JavaPath = $javaSetting.Substring('JavaPath='.Length).Trim()
if (-not (Test-Path -LiteralPath $JavaPath -PathType Leaf)) {
    throw "Prism's configured Java executable was not found: $JavaPath"
}

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

function Copy-CeRestrictedMod {
    param(
        [string] $SourceRoot,
        [string] $FileName,
        [string] $Sha1
    )

    $sourcePath = Join-Path (Join-Path $SourceRoot 'mods') $FileName
    $destinationPath = Join-Path (Join-Path $InstanceDir 'mods') $FileName

    if (Test-Path -LiteralPath $destinationPath -PathType Leaf) {
        if ((Get-FileHash -Algorithm SHA1 -LiteralPath $destinationPath).Hash -eq $Sha1) {
            return
        }

        Write-CeLog "A different local file already uses the restricted-mod filename: $FileName"
        return
    }

    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
        Write-CeLog "Restricted mod was not found in the CurseForge profile: $FileName"
        return
    }

    if ((Get-FileHash -Algorithm SHA1 -LiteralPath $sourcePath).Hash -ne $Sha1) {
        Write-CeLog "Restricted mod in the CurseForge profile has an unexpected hash: $FileName"
        return
    }

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destinationPath) | Out-Null
    Copy-Item -LiteralPath $sourcePath -Destination $destinationPath
    Write-CeLog "Copied locally installed restricted mod: $FileName"
}

$candidateRoots = @(
    (Join-Path $env:USERPROFILE 'curseforge\minecraft\Instances\C&E 1.21.1'),
    (Join-Path $env:USERPROFILE 'Documents\Curse\Minecraft\Instances\C&E 1.21.1')
)
$sourceRoot = $candidateRoots | Where-Object { Test-Path -LiteralPath $_ -PathType Container } | Select-Object -First 1

if (-not (Test-Path -LiteralPath $markerPath -PathType Leaf)) {
    try {
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

if ($sourceRoot) {
    try {
        @(
            @('create-otbwg-compat-1.0.jar', '39F257A8A0251A0BA838D354FFFC439850DB123C'),
            @('MysticalExtendedTier-1.2.1.1-0.9.6.jar', 'B7343E1AB724DB875B63C37C159316104FDEDB55')
        ) | ForEach-Object {
            Copy-CeRestrictedMod -SourceRoot $sourceRoot -FileName $_[0] -Sha1 $_[1]
        }
    }
    catch {
        Write-CeLog "Restricted-mod copy failed but pack update will continue: $($_.Exception.Message)"
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
