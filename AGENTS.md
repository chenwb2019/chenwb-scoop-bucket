# AGENTS.md

Scoop bucket (Windows-only). Manifests live in `bucket/*.json`; helper scripts in `bin/` and `scripts/`.

## Commands

All `bin/*.ps1` scripts are thin wrappers that delegate to `$env:SCOOP_HOME/bin/<script>.ps1`. They need Scoop installed (or `SCOOP_HOME` set); locally they default to `Convert-Path (scoop prefix scoop)`. Run from repo root:

- Test (Pester 5, requires BuildHelpers module): `.\bin\test.ps1` — imports Scoop's shared bucket tests via `Scoop-Bucket.Tests.ps1`
- Check a single app for new version: `.\bin\checkver.ps1 <app>` ; update it: `.\bin\checkver.ps1 <app> -f`
- Verify hashes: `.\bin\checkhashes.ps1 <app>` / check URLs: `.\bin\checkurls.ps1`
- Format manifests (enforces 4-space indent JSON): `.\bin\formatjson.ps1`

CI (`.github/workflows/ci.yml`) runs `bin/test.ps1` twice — once under Windows PowerShell 5.1 (`powershell`), once under `pwsh` — against a fresh checkout of `ScoopInstaller/Scoop` passed via `SCOOP_HOME`. Manifests must pass under both shells.

## Manifest conventions

- Version bump PRs are automated: the Excavator workflow (`.github/workflows/excavator.yml`, cron daily 00:20 UTC) runs scoop's autoupdate and opens/merges PRs. Commit style: `appname: Update to version X.Y.Z`.
- Apps intentionally without `autoupdate`: `Alas` and `steam` self-update at runtime (see their `notes`); `Typora-free` is pinned to a legacy version and updated manually. `notepad--` has autoupdate.
- `post_install` in manifests dot-sources this bucket's helpers by hardcoded path: `. "$bucketsdir\chenwb-scoop-bucket\scripts\Functions.ps1"`. If you rename the repo/bucket, update every manifest that references it.
- `scripts/Functions.ps1` provides `Move-Data_dir` (junctions app data dir into `$persist_dir` for persistence) and `Add-Startup_menu`; `scripts/` also ships paired install/uninstall `.reg` snippets (file association, context menu, startup, app registration) referenced by manifests.
- New manifests: copy `bucket/app-name.json.template` (or an existing manifest) to `bucket/<app-name>.json`.
- `App_Manifest.md` is the maintainer's planning checklist (planned/done/deprecated apps); `deprecated/` holds retired manifests kept for reference.
