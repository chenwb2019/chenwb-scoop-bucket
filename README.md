# A third-party scoop bucket

[![Tests](https://github.com/chenwb2019/chenwb-scoop-bucket/actions/workflows/ci.yml/badge.svg)](https://github.com/<username>/<bucketname>/actions/workflows/ci.yml) [![Excavator](https://github.com/chenwb2019/chenwb-scoop-bucket/actions/workflows/excavator.yml/badge.svg)](https://github.com/<username>/<bucketname>/actions/workflows/excavator.yml)

### The software in this bucket

| class            | Applicatons                                                       |
| ---------------- | ----------------------------------------------------------------- |
| Network Agency   | steampp, clashmi, zju-connect-for-windows                         |
| Environment      | dotnet-scoop, dotnet-default                                      |
| Beautify         | nofences, bongocat, xdiary, dskmanager, see-yue-typora(typora-cn) |
| Entertainment    | onlywrite, steam, Alas, firefox-scoop                             |
| Music Player     | ikun-music, musicfree                                             |
| Editor and Tools | typora-cn, notepad--, ccompare, easy-spider, webdav               |

### Original Readme

1. Generate your own copy of this repository with the "Use this template" button.
2. Allow all GitHub Actions:
   - Navigate to `Settings` - `Actions` - `General` - `Actions permissions`.
   - Select `Allow all actions and reusable workflows`.
   - Then `Save`.
3. Allow writing to the repository from within GitHub Actions:
   - Navigate to `Settings` - `Actions` - `General` - `Workflow permissions`.
   - Select `Read and write permissions`.
   - Then `Save`.
4. Document the bucket in `README.md`.
5. Replace the placeholder repository string in `bin/auto-pr.ps1`.
6. Create new manifests by copying `bucket/app-name.json.template` to `bucket/<app-name>.json`.
7. Commit and push changes.
8. If you'd like your bucket to be indexed on `https://scoop.sh`, add the topic `scoop-bucket` to your repository.

### Thanks

[scoopInstaller/extras](https://github.com/scoopInstaller/extras) 
[xrgzs/sdoog](https://github.com/xrgzs/sdoog)
