# Update Process Instructions

## When Releasing A New Version

1. Increment version numbers in both files:
   - In `module.prop`: Update `version` and `versionCode`
   - In `update.json`: Update `version` and `versionCode`

2. Update `zipUrl` in `update.json` to point to the new version's zip file:
   - Example: `https://github.com/kaushikieeee/GhostGMS/releases/download/v2.1/GhostGMS-v2.1.zip`

3. Add new changes to `CHANGELOG.md`

4. Upload all these updated files to your GitHub repository:
   - `update.json` (critical - this is what existing installations check)
   - `CHANGELOG.md`

5. Create a new release on GitHub with the new version zip file

## Example for v2.1 Release

1. In `module.prop`:
```
version=v2.1
versionCode=21
```

2. In `update.json`:
```json
{
  "version": "v2.1",
  "versionCode": 21,
  "zipUrl": "https://github.com/kaushikieeee/GhostGMS/releases/download/v2.1/GhostGMS-v2.1.zip",
  "changelog": "https://raw.githubusercontent.com/kaushikieeee/GhostGMS/main/CHANGELOG.md"
}
```

3. Add details to `CHANGELOG.md`:
```md
## v2.1
- Added new feature X
- Fixed bug Y
- Improved Z
```

The most important part is updating the `update.json` file in your GitHub repository. When users with v2.0 installed open their Magisk/KernelSU app, it will check this file and notify them of the available update. 