# C&E pack maintenance instructions

These instructions apply to every change in this repository.

## Canonical locations

- Treat this repository as the only pack source. Do not build releases from either player's live Minecraft instance or from an old CurseForge export.
- The Git remote is `https://github.com/evander-davis/ce-minecraft-pack.git` (`origin`).
- Tested pack releases go to `origin/main`. GitHub Pages serves the repository root from `main`.
- The production packwiz URL is `https://evander-davis.github.io/ce-minecraft-pack/pack.toml`.
- The checked-in Prism starter source is under `prism/`. Generated Prism ZIPs belong under ignored `dist/` and, when released, as GitHub Release assets.
- The runtime pre-launch script is `ce-prelaunch.ps1` at the repository root. Packwiz manages it after the first successful install, and the Prism starter builder copies it into new instances.

## Required update process

1. Start from an up-to-date `main` branch and keep unrelated or player-created files out of the repository.
2. Make pack changes only in this repository. For a CurseForge mod, use packwiz metadata rather than committing its JAR when packwiz can resolve it. For a private/custom mod, place only its active JAR in `mods/` and remove the superseded JAR.
3. Run packwiz through the repository wrapper, for example:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Invoke-Packwiz.ps1 refresh
   ```

4. Run the mandatory validation before committing or pushing:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Test-Pack.ps1
   ```

5. Inspect `git diff`, including `pack.toml` and `index.toml`. Commit the refreshed index together with every file it describes. Do not manually edit hashes in `index.toml`.
6. Test material mod/config changes in the maintainer's Prism instance before publishing. Do not use the live instance as the source for a subsequent refresh.
7. Push the tested commit to `origin/main`, then confirm the Pages build points at that commit and that the production `pack.toml` is reachable. A push to another branch does not update either player's pack.

Ordinary pack updates do not require a new Prism ZIP: both players receive them from Pages at launch. Rebuild and publish the starter only when its Prism metadata, Minecraft/NeoForge version, bootstrap, or pre-launch/migration behavior changes:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Build-Prism-Starter.ps1
```

When publishing a new starter, update its version consistently with `pack.toml`, test importing the ZIP into Prism, and attach the generated ZIP to the corresponding GitHub Release.

## Player-owned state is untouchable

Packwiz must never index, replace, delete, or distribute either player's personal state. This includes:

- `options.txt` and keybinds
- `servers.dat`
- `xaero/`, including waypoints and map history
- `shaderpacks/` and `config/iris.properties`
- `saves/`, `screenshots/`, `schematics/`, and backups
- world-specific JEI, Inventory Profiles Next, and Xaero configuration/state
- logs, caches, crash reports, authentication data, and generated local credentials

Keep these exclusions in `.packwizignore`, and extend `Test-Pack.ps1` whenever a new player-specific path is discovered. Default mod configuration may be managed only when it is genuinely shared by both players and does not contain machine-specific paths, secrets, account data, history, or per-world state.

## Packwiz and Git rules

- Preserve `.gitattributes` behavior. Packwiz hashes the exact hosted bytes, so broad Git line-ending normalization can invalidate downloads.
- Do not commit `dist/`, the downloaded bootstrap JAR, packwiz caches, personal instances, or CurseForge exports.
- Do not upload third-party CurseForge-hosted JARs directly when their packwiz `.pw.toml` metadata works. The C&E custom compatibility JARs may be committed because the public repository is their distribution source.
- Prefer an author's official Modrinth release when CurseForge blocks automatic third-party downloads. For a restricted mod with no official alternate host, preserve the CurseForge metadata and have `ce-prelaunch.ps1` copy an exact, hash-verified JAR from the player's existing CurseForge profile. Never commit or rehost a restricted third-party JAR.
- When a locally copied restricted mod is updated, change its filename and SHA-1 in `ce-prelaunch.ps1` together with its `.pw.toml`, then test both an existing instance and a fresh starter import.
- Do not rename or move the production `pack.toml` without updating `ce-prelaunch.ps1` and testing a fresh Prism import.
- Preserve the one-time migration's copy-only behavior. It must never move or delete data from the CurseForge profile.

## Compatibility target

Every published change must work in both players' long-lived Prism instances and in a fresh import of the current starter. Pack changes should update managed mods/configuration while leaving each player's controls, worlds, Xaero data, shaders, and other personal choices intact.
