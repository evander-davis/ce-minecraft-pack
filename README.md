# C&E 1.21.1 packwiz pack

This directory is the source of truth for C&E 1.21.1 version 1.2.0. It was imported from the CurseForge export `C&E 1.21.1-1.2.0.zip`.

The pack uses CurseForge metadata for publicly hosted dependencies and serves the C&E-specific compatibility JARs directly with the pack. The live CurseForge instance is not used as pack source.

## Local tooling

The workspace-local packwiz executable is located at:

```text
C:\Documents\minecraft\.toolchains\packwiz\packwiz.exe
```

Use the wrapper from this directory so packwiz's cache and configuration also stay inside the workspace:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Invoke-Packwiz.ps1 list
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Invoke-Packwiz.ps1 refresh
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Invoke-Packwiz.ps1 update <mod-name>
```

Review and test updates individually. Avoid publishing an untested `update --all` result.

Run the pack validation before publishing:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Test-Pack.ps1
```

## Player-owned files

The updater must never manage the following player state:

- `options.txt` (including keybinds)
- `xaero/` (waypoints and map history)
- `shaderpacks/`
- `config/iris.properties` (selected shader)
- `saves/`, `screenshots/`, and `schematics/`
- `servers.dat`
- world-specific JEI and Inventory Profiles Next state

`.packwizignore` prevents these paths from entering `index.toml`. `Test-Pack.ps1` independently checks the resulting index.

## Custom mods

JARs without a matching `.pw.toml` file under `mods/` are served directly from this pack. Keep only the active version of each custom mod here. Superseded builds belong in release archives, not beside the active pack.

## Publishing

1. Push this directory to `https://github.com/evander-davis/ce-minecraft-pack`.
2. Enable GitHub Pages from the `main` branch and repository root.
3. Confirm that `https://evander-davis.github.io/ce-minecraft-pack/pack.toml` loads in a browser.
4. Run `Test-Pack.ps1`, commit the refreshed `index.toml`, and push only tested releases.
5. Configure the Prism instance pre-launch command after the final URL is known:

```text
"$INST_JAVA" -jar packwiz-installer-bootstrap.jar https://evander-davis.github.io/ce-minecraft-pack/pack.toml
```

The initial Prism instance and bootstrap JAR should be distributed separately from the Pages pack source. After that one-time import, packwiz updates the same instance before every launch.
