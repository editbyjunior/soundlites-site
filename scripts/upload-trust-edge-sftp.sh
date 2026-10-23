#!/usr/bin/env bash
# Upload a prepared deploy payload to a Trust Edge website over SFTP.
#
# The server is authenticated only against the pinned host key in
# TRUST_EDGE_SSH_KNOWN_HOSTS (strict checking, no ssh-keyscan, no TOFU).
#
# Required env: TRUST_EDGE_SSH_HOST, TRUST_EDGE_SSH_USERNAME,
#   TRUST_EDGE_SSH_PRIVATE_KEY, TRUST_EDGE_SSH_KNOWN_HOSTS
# Optional env: TRUST_EDGE_SSH_PORT (default 22),
#   TRUST_EDGE_SSH_REMOTE_ROOT (default public_html, relative to the SSH home),
#   TRUST_EDGE_SFTP_DRY_RUN=1 (print the batch instead of connecting)
set -euo pipefail

payload="${1:-.trust-edge-deploy}"
test -d "$payload"

host="${TRUST_EDGE_SSH_HOST:?TRUST_EDGE_SSH_HOST is required}"
user="${TRUST_EDGE_SSH_USERNAME:?TRUST_EDGE_SSH_USERNAME is required}"
port="${TRUST_EDGE_SSH_PORT:-22}"
root="${TRUST_EDGE_SSH_REMOTE_ROOT:-public_html}"
root="${root#/}"
root="${root%/}"
test -n "$root"

case "$port" in
  '' | *[!0-9]*)
    echo "TRUST_EDGE_SSH_PORT must be a number" >&2
    exit 1
    ;;
esac

workdir="$(mktemp -d "${RUNNER_TEMP:-/tmp}/trust-edge-sftp.XXXXXX")"
trap 'rm -rf "$workdir"' EXIT
chmod 700 "$workdir"

# sftp batch files quote paths with double quotes; refuse names that would
# break that quoting rather than trying to escape them. Checked up front
# because a failure inside $(...) would not stop the script.
check_path() {
  case "$1" in
    *'"'* | *\\* | *$'\n'* | *$'\r'*)
      echo "Unsupported character in path: $1" >&2
      exit 1
      ;;
  esac
}
check_path "$root"
while IFS= read -r -d '' path; do
  check_path "$path"
done < <(find "$payload" -mindepth 1 -print0)

quote() {
  printf '"%s"' "$1"
}

batch="$workdir/batch"
{
  # Create the remote tree parents-first; "-" lets mkdir on an existing
  # directory pass while any other failed command aborts the batch.
  prefix=""
  IFS=/ read -r -a parts <<< "$root"
  for part in "${parts[@]}"; do
    [ -n "$part" ] || continue
    prefix="${prefix:+$prefix/}$part"
    printf -- '-mkdir %s\n' "$(quote "$prefix")"
  done
  while IFS= read -r -d '' dir; do
    name="${dir#"$payload"/}"
    printf -- '-mkdir %s\n' "$(quote "$root/$name")"
  done < <(find "$payload" -mindepth 1 -type d -print0 | sort -z)

  # Upload assets first and entry points last, so a partial upload does not
  # serve a new index.html that points at assets which have not arrived yet.
  while IFS= read -r -d '' file; do
    name="${file#"$payload"/}"
    case "${name##*/}" in
      index.html | index.php | .htaccess) continue ;;
    esac
    printf 'put %s %s\n' "$(quote "$file")" "$(quote "$root/$name")"
  done < <(find "$payload" -type f -print0 | sort -z)
  while IFS= read -r -d '' file; do
    name="${file#"$payload"/}"
    case "${name##*/}" in
      index.html | index.php | .htaccess)
        printf 'put %s %s\n' "$(quote "$file")" "$(quote "$root/$name")"
        ;;
    esac
  done < <(find "$payload" -type f -print0 | sort -z)
} > "$batch"

if [ "${TRUST_EDGE_SFTP_DRY_RUN:-}" = "1" ]; then
  cat "$batch"
  exit 0
fi

: "${TRUST_EDGE_SSH_PRIVATE_KEY:?TRUST_EDGE_SSH_PRIVATE_KEY is required}"
: "${TRUST_EDGE_SSH_KNOWN_HOSTS:?TRUST_EDGE_SSH_KNOWN_HOSTS is required}"

key="$workdir/id_deploy"
known_hosts="$workdir/known_hosts"
(
  umask 077
  printf '%s\n' "$TRUST_EDGE_SSH_PRIVATE_KEY" > "$key"
  printf '%s\n' "$TRUST_EDGE_SSH_KNOWN_HOSTS" > "$known_hosts"
)

# Show the pinned fingerprint (public data) so a run log can be checked
# against the value recorded when the key was pinned.
echo "Pinned host key:"
ssh-keygen -l -f "$known_hosts"

sftp -b "$batch" \
  -P "$port" \
  -i "$key" \
  -o BatchMode=yes \
  -o IdentitiesOnly=yes \
  -o StrictHostKeyChecking=yes \
  -o UserKnownHostsFile="$known_hosts" \
  -o GlobalKnownHostsFile=/dev/null \
  -o UpdateHostKeys=no \
  -o ConnectTimeout=20 \
  "$user@$host"

echo "Uploaded $(grep -c '^put ' "$batch") files to $root over SFTP"
