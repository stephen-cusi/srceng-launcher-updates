# Source Engine Launcher Updates

Public update feed for `stephen-cusi/srceng-launcher_cn`.

## Layout

- `stable/manifest.json`: latest stable release metadata
- `stable/releases.json`: all stable releases indexed by exact version name
- `stable/apk/`: stable APK files
- `stable/changelog/`: one Markdown changelog per stable version
- `dev/manifest.json`: latest development release metadata
- `dev/releases.json`: all development releases indexed by exact version name
- `dev/apk/`: development APK files
- `dev/changelog/`: one Markdown changelog per development version

The launcher reads each channel's `manifest.json` to check for a newer release. It reads `releases.json` to look up the changelog for the exact installed `versionName`, so older installations continue to show their own release notes after a newer version is published. Older APKs and changelogs remain available at their versioned paths.

`releases.json` embeds every Markdown changelog under `releasesByVersion.<versionName>.changelog.content` and also retains the direct Markdown URL. Regenerate both channel indexes with:

```bash
./generate_releases.py
```

## Publishing

Prepare a Markdown changelog, then run:

```bash
./publish.sh dev 1.17.40-dev3 3 /path/to/srceng.apk /path/to/changelog.md
```

Use one monotonically increasing build sequence across both channels. For example, if development build 3 is the newest published release, the next stable or development release must use build 4:

```bash
./publish.sh stable 1.17.40 4 /path/to/srceng.apk /path/to/changelog.md
```

Set the launcher's `res/values/build_info.xml` `update_build` value to the same build number before compiling the APK.

`publish.sh` regenerates both `releases.json` files automatically. Commit and push the generated APK, changelog, manifest, and release indexes together.
