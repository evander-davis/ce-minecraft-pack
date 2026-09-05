# C&E 1.21.1 packwiz pack

This directory is the source of truth for C&E 1.21.1. It was initially imported from the CurseForge export `C&E 1.21.1-1.2.0.zip`; the current version is declared in `pack.toml`.

The pack uses CurseForge metadata for publicly hosted dependencies and serves the C&E-specific compatibility JARs directly with the pack. The live CurseForge instance is not used as pack source.

## Pack distribution

The raw Packwiz pack files are committed to the repository root on `main` and published by GitHub Pages at:

```text
https://evander-davis.github.io/ce-minecraft-pack/
```

`pack.toml` is the production entry point. It references `index.toml`, which in turn references the configuration, custom JARs, and mod metadata files served from the same Pages location. Prism runs Packwiz against `https://evander-davis.github.io/ce-minecraft-pack/pack.toml` before each launch.

Do not upload third-party mod JARs to this repository when Packwiz can resolve them from CurseForge. Add a CurseForge-hosted mod with metadata instead:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Invoke-Packwiz.ps1 cf add <project-slug-or-url>
```

This creates a small `mods/<project>.pw.toml` file containing the CurseForge project ID, file ID, filename, and hash. Commit that metadata file and the refreshed `index.toml`; Packwiz Installer will download the JAR directly from CurseForge and can resolve future updates with `Invoke-Packwiz.ps1 update <project>`. If CurseForge blocks third-party downloads, follow the official-alternate-host or hash-verified local-copy process under [Custom mods](#custom-mods).

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

Build the one-time Prism import ZIP with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Build-Prism-Starter.ps1
```

The generated ZIP is written under `dist/`. On its first launch, the included pre-launch script looks for the existing CurseForge `C&E 1.21.1` profile and copies player-owned data into Prism. It copies rather than moves, and never deletes the CurseForge copy.

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

The editable sources for the custom Fortune/refinement and biome-precipitation JARs are kept on the maintainer workstation at `C:\Documents\minecraft\CreateEnchantableMachineryFortune` and `C:\Documents\minecraft\ce-rain-everywhere`. Build those projects with Java 21, then copy only their release JARs into this repository's `mods/` directory.

Some third-party CurseForge projects disable downloads through other launchers. Where the author also publishes on Modrinth, this pack uses that official source. For restricted projects with no official alternate host, the Prism pre-launch script copies the exact hash-verified JAR from the player's existing CurseForge `C&E 1.21.1` profile. If that profile is absent, packwiz may require a one-time manual download from CurseForge; do not rehost those JARs in this public repository.

## Publishing

1. Push this directory to `https://github.com/evander-davis/ce-minecraft-pack`.
2. Enable GitHub Pages from the `main` branch and repository root.
3. Confirm that `https://evander-davis.github.io/ce-minecraft-pack/pack.toml` loads in a browser.
4. Run `Test-Pack.ps1`, commit the refreshed `index.toml`, and push only tested releases.
5. Configure the Prism instance pre-launch command after the final URL is known:

```text
"$INST_JAVA" -jar packwiz-installer-bootstrap.jar https://evander-davis.github.io/ce-minecraft-pack/pack.toml
```

The initial Prism instance is distributed as a GitHub Release asset. After that one-time import, its pre-launch script migrates personal data once and packwiz updates the same instance before every launch.

## Crystal Flower enchanting integration (1.4.11)

Occultism and Gateways to Eternity are referenced through their CurseForge uploads, together with the required Modonomicon and SmartBrainLib releases.

`ce-crystal-enchanting-1.0.0.jar` is a standalone C&E addon. A Bumblezone Crystalline Flower whose base occupies a valid, unobstructed bookshelf position contributes +5 Eterna, +10 Quanta, and +2 enchanting hints. Normal Apothic stat and player caps apply. Grown flowers count once per plant; keep the flower's normal support block beneath it (for example, amethyst).

The enchanting screen gains a **Reroll (5 XP)** button. Each reroll costs five experience points, preserves the item and lapis, and updates the player's persistent enchanting seed. Creative mode is free. The server validates the open table, flower placement, item, and XP before rerolling.

The editable addon source on this Linux workstation is `/home/evand/Work/ce-crystal-enchanting`, beside this pack repository. Build with Java 21 using `./gradlew build` and run `./gradlew runGameTestServer` before copying its release JAR into `mods/`. Never ship the development `-smoketest.jar`.

On Linux, the repository wrapper selects `../.toolchains/packwiz/packwiz`. With PowerShell installed, run `pwsh -NoProfile -File ./Invoke-Packwiz.ps1 refresh` and `pwsh -NoProfile -File ./Test-Pack.ps1` for the same validation used on Windows.

## Exploration and accessory loot (1.4.12)

Added Mob Grinding Utils, Fargo's Talismans, Relics, Artifacts, and Reliquified Artifacts as CurseForge references, with Caelus, EventsLib, and OctoLib dependencies. Artifacts is pinned to **13.2.3**, which Reliquified Artifacts 1.0.8 requires exactly.

The existing `ce-loot-integration` addon is updated to **1.2.0**. It preserves the existing magic-loot integrations and adds tier-aware accessory coverage for 550 structure chest tables, including 249 with nonstandard paths. Relics and Reliquified Artifacts share one roll with the author's biome/dimension selection; unusual chest paths use curated location-themed pools. At default settings, the added accessory chances are 3% in common/storage chests, 8% in guarded rooms, 12% in treasure, and 16% in endgame rewards. Native vanilla loot remains unchanged.

Fargo's existing integrations are excluded from the extra rolls. New base chances are 3%, 5%, 6%, and 8% respectively; legendary bases appear only in the endgame pool at 0.8% overall. Finished talismans are not injected. Decorative containers, junk, progression dispensers, spawners, entity loot, and nested helper tables are excluded.

Editable source: `/home/evand/Projects/minecraft/ce_pack_tools/`. Build through `Build-LootAddon.ps1` from a hash-verified canonical inventory and run its regression validation. The generated `META-INF/ce-accessory-loot-audit.json` inside the addon records exact targets, probabilities, themes, and exclusions. Prism/Minecraft validation launches use workspace 2.
