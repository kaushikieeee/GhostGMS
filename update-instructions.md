# Update Process Instructions

## When Releasing A New Version

1. Increment Core version numbers in both files:
   - In `module.prop`: Update `version` and `versionCode`
   - In `update.json`: Update `version` and `versionCode`

2. Update `zipUrl` in `update.json` to point to the new Core zip file:
   - Format: `https://github.com/kaushikieeee/GhostGMS/releases/download/<core_version>/GhostGMS-Core-<core_version>.zip`

3. If Legacy is included in the release, also update:
   - `legacy/GhostGMS-1.3/module.prop` (`version`, `versionCode`, `updateJson`)
   - `legacy/GhostGMS-1.3/update.json` (`version`, `versionCode`, `zipUrl`)
   - Legacy `zipUrl` format: `https://github.com/kaushikieeee/GhostGMS/releases/download/<core_release_tag>/GhostGMS-Legacy-1.3.zip`

4. Add new changes to `CHANGELOG.md`

5. Upload all these updated files to your GitHub repository:
   - `update.json` (critical - this is what existing installations check)
   - `legacy/GhostGMS-1.3/update.json` (critical for Legacy installations)
   - `CHANGELOG.md`

6. Create a new release on GitHub with the new version zip file(s)

## Example for v2.1 Release

1. In `module.prop`:
```
version=v2.1
versionCode=21
```

2. In `update.json` (Core):
```json
{
  "version": "v2.1",
  "versionCode": 21,
  "zipUrl": "https://github.com/kaushikieeee/GhostGMS/releases/download/v2.1/GhostGMS-Core-v2.1.zip",
  "changelog": "https://raw.githubusercontent.com/kaushikieeee/GhostGMS/main/CHANGELOG.md"
}
```

3. In `legacy/GhostGMS-1.3/update.json` (Legacy, if included):
```json
{
  "version": "v1.3.2",
  "versionCode": 3,
  "zipUrl": "https://github.com/kaushikieeee/GhostGMS/releases/download/v2.1/GhostGMS-Legacy-1.3.zip",
  "changelog": "https://raw.githubusercontent.com/kaushikieeee/GhostGMS/main/CHANGELOG.md"
}
```

4. Add details to `CHANGELOG.md`:
```md
## v2.1
- Added new feature X
- Fixed bug Y
- Improved Z
```

The most important part is updating both update metadata files in your GitHub repository (`update.json` for Core and `legacy/GhostGMS-1.3/update.json` for Legacy). Existing installations check these files and notify users of available updates.