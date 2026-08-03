# Source Engine Launcher Updates

Public update feed for `stephen-cusi/srceng-launcher_cn`.

## Layout

- `stable/manifest.json`: latest stable release metadata
- `stable/apk/`: stable APK files
- `stable/changelog/`: one Markdown changelog per stable version
- `dev/manifest.json`: latest development release metadata
- `dev/apk/`: development APK files
- `dev/changelog/`: one Markdown changelog per development version

The launcher reads only each channel's `manifest.json`. Older APKs and changelogs remain available at their versioned paths.

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

Commit and push the generated APK, changelog, and manifest together.
