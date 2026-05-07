#!/usr/bin/env bash
set -euo pipefail

payload=".trust-edge-deploy"
rm -rf "$payload"
mkdir -p "$payload"

copy_source_dir() {
  source_dir="$1"
  test -d "$source_dir"
  cp -R "$source_dir"/. "$payload"/
}

copy_root_static() {
  copied=false
  for file in .htaccess index.html robots.txt styles.css; do
    if [ -f "$file" ]; then
      cp "$file" "$payload"/
      copied=true
    fi
  done
  if "$copied"; then
    for dir in assets tmp vision; do
      if [ -d "$dir" ]; then
        cp -R "$dir" "$payload"/
      fi
    done
  fi
  "$copied"
}

if [ -n "${TRUST_EDGE_SOURCE_DIR:-}" ]; then
  copy_source_dir "$TRUST_EDGE_SOURCE_DIR"
elif [ -d dist ]; then
  copy_source_dir dist
elif [ -d out ]; then
  copy_source_dir out
elif [ -f progressiveone-trustedge-index.html ] && [ ! -f index.html ]; then
  cp progressiveone-trustedge-index.html "$payload/index.html"
  [ -d tmp ] && cp -R tmp "$payload"/
elif ! copy_root_static; then
  echo "No Trust Edge deploy payload found. Set TRUST_EDGE_SOURCE_DIR or add a static index.html/dist/out payload." >&2
  exit 1
fi

find "$payload" -name .DS_Store -delete
test -n "$(find "$payload" -type f -print -quit)"
