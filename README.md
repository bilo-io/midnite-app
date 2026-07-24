# midnite

**midnite** is a multitask orchestrator for Claude Code — a desktop app (and gateway) that runs a pool of Claude Code agents against a kanban board of tasks.

This repo hosts the **downloads** (release installers + auto-update feed) and the **issue tracker**.

## Install

### macOS (Apple Silicon) — recommended

```sh
curl -fsSL https://raw.githubusercontent.com/bilo-io/midnite-app/main/install.sh | sh
```

The script downloads the latest release and installs it to `/Applications`. Installing with `curl` (rather than a browser) means macOS never quarantines the app, so it opens normally on first launch — no "unverified app" popup. Read the script first if you like: [`install.sh`](install.sh).

**Updating:** when the app tells you a new version is available, re-run the same command — it replaces the app in place.

Options: `MIDNITE_VERSION=0.5.0` installs a specific version; `MIDNITE_NO_OPEN=1` skips launching the app afterwards.

### macOS — manual download

If you'd rather download the `.dmg` from the [releases page](https://github.com/bilo-io/midnite-app/releases/latest) in a browser, macOS will quarantine it and block the first launch with *"Apple could not verify midnite is free of malware"* (the builds aren't notarized yet). To open it anyway, either:

1. Double-click the app (dismiss the popup), then go to **System Settings → Privacy & Security**, scroll down, and click **Open Anyway** (the button appears for about an hour after the blocked attempt), **or**
2. Clear the quarantine flag in a terminal:

   ```sh
   xattr -dr com.apple.quarantine /Applications/midnite.app
   ```

> Note: on macOS 15 (Sequoia) and later, the old *right-click → Open* trick no longer works for unnotarized apps — use one of the two options above.

### Windows

Download `midnite-<version>-x64.exe` from the [releases page](https://github.com/bilo-io/midnite-app/releases/latest). SmartScreen will warn about an unrecognized app — click **More info → Run anyway**.

### Linux

Download `midnite-<version>-x86_64.AppImage` from the [releases page](https://github.com/bilo-io/midnite-app/releases/latest), then:

```sh
chmod +x midnite-*.AppImage && ./midnite-*.AppImage
```

## The `midnite` CLI

The app bundles the `midnite` CLI. The macOS installer links it to `/usr/local/bin` when it can; otherwise:

```sh
sudo ln -sf /Applications/midnite.app/Contents/Resources/bin/midnite /usr/local/bin/midnite
```

## Issues

Found a bug? [Open an issue](https://github.com/bilo-io/midnite-app/issues).

## Changelog

See [CHANGELOG.md](CHANGELOG.md).
