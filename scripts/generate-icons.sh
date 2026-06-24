#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") <source-image> [output-dir]"
  echo
  echo "Generate code-server favicon and PWA icon files from a source image."
  echo
  echo "Arguments:"
  echo "  source-image  Path to the source image (PNG, SVG, JPG, etc.)"
  echo "  output-dir    Output directory (default: ./media)"
  echo
  echo "Requires: ImageMagick (convert/magick)"
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

SOURCE="$1"
OUTDIR="${2:-./media}"

if [[ ! -f "$SOURCE" ]]; then
  echo "Error: source image '$SOURCE' not found" >&2
  exit 1
fi

if command -v magick &>/dev/null; then
  IM="magick"
elif command -v convert &>/dev/null; then
  IM="convert"
else
  echo "Error: ImageMagick is required but not found." >&2
  echo "Install it with:" >&2
  echo "  macOS:  brew install imagemagick" >&2
  echo "  Ubuntu: sudo apt-get install imagemagick" >&2
  echo "  Nix:    nix-env -iA nixpkgs.imagemagick" >&2
  exit 1
fi

mkdir -p "$OUTDIR"

echo "Generating icons from '$SOURCE' into '$OUTDIR'..."

CLEANED=$(mktemp "${TMPDIR:-/tmp}/icon-cleaned-XXXXXX.png")
trap 'rm -f "$CLEANED"' EXIT
echo "  Preparing source image..."
$IM "$SOURCE" -background none -alpha on PNG:"$CLEANED"

# pwa-icon.png (original size, square, 512x512 as baseline)
echo "  pwa-icon.png (512x512)"
$IM "$CLEANED" -background none -resize 512x512 -gravity center -extent 512x512 "$OUTDIR/pwa-icon.png"

# pwa-icon-512.png
echo "  pwa-icon-512.png (512x512)"
cp "$OUTDIR/pwa-icon.png" "$OUTDIR/pwa-icon-512.png"

# pwa-icon-192.png
echo "  pwa-icon-192.png (192x192)"
$IM "$CLEANED" -background none -resize 192x192 -gravity center -extent 192x192 "$OUTDIR/pwa-icon-192.png"

# favicon.ico (multi-resolution)
echo "  favicon.ico (16x16, 32x32, 48x48, 64x64, 128x128, 256x256)"
$IM "$CLEANED" \
  \( -clone 0 -resize 16x16 \) \
  \( -clone 0 -resize 32x32 \) \
  \( -clone 0 -resize 48x48 \) \
  \( -clone 0 -resize 64x64 \) \
  \( -clone 0 -resize 128x128 \) \
  \( -clone 0 -resize 256x256 \) \
  -delete 0 \
  -background none \
  "$OUTDIR/favicon.ico"

# favicon.svg - if source is SVG, copy it; otherwise create a simple SVG wrapper
if [[ "$SOURCE" == *.svg ]]; then
  echo "  favicon.svg (copied from source)"
  cp "$SOURCE" "$OUTDIR/favicon.svg"
  echo "  favicon-dark-support.svg (copied from source)"
  cp "$SOURCE" "$OUTDIR/favicon-dark-support.svg"
else
  echo "  favicon.svg (rasterized to 256x256 PNG, embedded in SVG)"
  $IM "$CLEANED" -background none -resize 256x256 PNG:"$OUTDIR/.favicon-tmp.png"
  B64=$(base64 -w0 "$OUTDIR/.favicon-tmp.png" 2>/dev/null || base64 -i "$OUTDIR/.favicon-tmp.png")
  cat > "$OUTDIR/favicon.svg" <<SVGEOF
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="256" height="256" viewBox="0 0 256 256">
  <image width="256" height="256" xlink:href="data:image/png;base64,${B64}"/>
</svg>
SVGEOF
  cp "$OUTDIR/favicon.svg" "$OUTDIR/favicon-dark-support.svg"
  rm -f "$OUTDIR/.favicon-tmp.png"
fi

echo
echo "Done. Generated files:"
ls -lh "$OUTDIR"
