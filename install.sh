#!/bin/sh
# midnite installer — macOS (Apple Silicon)
#
#   curl -fsSL https://raw.githubusercontent.com/bilo-io/midnite-app/main/install.sh | sh
#
# Downloads the latest release .zip with curl and installs it to /Applications.
# Because curl (unlike a browser) never sets the com.apple.quarantine attribute,
# the app opens normally on first launch — no Gatekeeper "unverified app" popup.
#
# Options (environment variables):
#   MIDNITE_VERSION=0.5.0   install a specific version instead of the latest
#   MIDNITE_NO_OPEN=1       don't launch the app after installing

set -eu

REPO="bilo-io/midnite-app"
APP="midnite.app"
DEST="/Applications"

say() { printf '%s\n' "$*"; }
fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

# ── Preflight ────────────────────────────────────────────────────────────────
[ "$(uname -s)" = "Darwin" ] || fail "this installer is macOS-only. Downloads for Windows/Linux: https://github.com/$REPO/releases/latest"
[ "$(uname -m)" = "arm64" ] || fail "midnite ships Apple Silicon (arm64) builds only, and this Mac reports $(uname -m)."
command -v curl >/dev/null 2>&1 || fail "curl is required."

# ── Resolve version ──────────────────────────────────────────────────────────
if [ -n "${MIDNITE_VERSION:-}" ]; then
  version="${MIDNITE_VERSION#v}"
else
  # releases/latest redirects to releases/tag/vX.Y.Z — read the final URL.
  latest_url=$(curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/$REPO/releases/latest") ||
    fail "could not reach github.com to resolve the latest release."
  tag="${latest_url##*/}"
  version="${tag#v}"
  [ -n "$version" ] && [ "$version" != "latest" ] || fail "could not determine the latest version from $latest_url"
fi

asset="midnite-${version}-arm64.zip"
url="https://github.com/$REPO/releases/download/v${version}/${asset}"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

say "Downloading midnite v${version} …"
curl -fL --progress-bar "$url" -o "$tmp/$asset" || fail "download failed: $url"

# ditto (not unzip/cp) preserves the code-signing seal and extended attributes.
ditto -xk "$tmp/$asset" "$tmp/extracted" || fail "could not extract $asset"
[ -d "$tmp/extracted/$APP" ] || fail "archive did not contain $APP"

# ── Install ──────────────────────────────────────────────────────────────────
# Quit a running copy so the bundle can be replaced (best-effort).
if pgrep -xq "midnite" 2>/dev/null; then
  say "Quitting the running midnite …"
  osascript -e 'tell application "midnite" to quit' >/dev/null 2>&1 || true
  sleep 2
fi

install_app() {
  # $1 = optional "sudo"
  ${1:-} rm -rf "$DEST/$APP"
  ${1:-} ditto "$tmp/extracted/$APP" "$DEST/$APP"
}

say "Installing to $DEST/$APP …"
if [ -w "$DEST" ] && { [ ! -e "$DEST/$APP" ] || [ -w "$DEST/$APP" ]; }; then
  install_app
else
  say "(administrator password needed to write to $DEST)"
  install_app sudo
fi

# curl doesn't quarantine, but clear the bit defensively (e.g. re-runs over a
# browser-downloaded copy). Best-effort: the attribute usually isn't there.
xattr -dr com.apple.quarantine "$DEST/$APP" 2>/dev/null || true

# ── Optional CLI symlink ─────────────────────────────────────────────────────
cli="$DEST/$APP/Contents/Resources/bin/midnite"
if [ -e "$cli" ]; then
  if [ -d /usr/local/bin ] && [ -w /usr/local/bin ]; then
    ln -sf "$cli" /usr/local/bin/midnite
    say "Linked the midnite CLI: /usr/local/bin/midnite"
  else
    say "To put the midnite CLI on your PATH:"
    say "  sudo ln -sf \"$cli\" /usr/local/bin/midnite"
  fi
fi

say ""
say "✓ midnite v${version} installed."
if [ -z "${MIDNITE_NO_OPEN:-}" ]; then
  open "$DEST/$APP"
else
  say "Launch it with: open -a midnite"
fi
