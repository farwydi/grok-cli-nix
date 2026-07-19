#!/usr/bin/env bash
# Regenerate sources.json with the latest Grok CLI version and per-system hashes.
# Pin a version with: ./update.sh 0.2.103
set -euo pipefail
cd "$(dirname "$0")"

ver="${1:-$(curl -fsSL https://x.ai/cli/stable | head -n1 | tr -d '[:space:]')}"
[[ "$ver" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]] || { echo "bad version: $ver" >&2; exit 1; }

systems="x86_64-linux:linux-x86_64 aarch64-linux:linux-aarch64"

json=$(jq -n --arg version "$ver" '{version: $version, systems: {}}')
for entry in $systems; do
  sys="${entry%%:*}"; target="${entry#*:}"
  url="https://x.ai/cli/grok-$ver-$target"
  hash=$(nix store prefetch-file --json "$url" | jq -r .hash)
  json=$(jq --arg s "$sys" --arg t "$target" --arg h "$hash" \
    '.systems[$s] = {target: $t, hash: $h}' <<<"$json")
done

printf '%s\n' "$json" > sources.json
echo "updated to $ver"
