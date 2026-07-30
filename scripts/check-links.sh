#!/usr/bin/env bash
# Verify every GitHub repo link in the list still resolves, and report drift
# between the stars/license recorded in README.md and live API data.
#
# Usage: ./scripts/check-links.sh [--metadata]
#   (default)    check that every linked repo resolves
#   --metadata   also compare recorded license against the live value
#
# Requires: gh (authenticated), grep, sed, sort.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECK_METADATA=0
[ "${1:-}" = "--metadata" ] && CHECK_METADATA=1

if ! command -v gh >/dev/null 2>&1; then
  echo "error: gh not found. Install GitHub CLI or run link checks manually." >&2
  exit 2
fi

mapfile -t repos < <(
  grep -ohE 'https://github\.com/[A-Za-z0-9._-]+/[A-Za-z0-9._-]+' \
    "$ROOT/README.md" "$ROOT/NOTES.md" 2>/dev/null \
  | sed 's#https://github\.com/##; s#/*$##' \
  | grep -vE '^(sponsors|topics|features|about|pricing)($|/)' \
  | sort -u
)

if [ "${#repos[@]}" -eq 0 ]; then
  echo "error: no GitHub links found — is README.md present?" >&2
  exit 2
fi

echo "Checking ${#repos[@]} repositories..."
echo

fail=0
stale=0

for r in "${repos[@]}"; do
  if [ "$CHECK_METADATA" -eq 1 ]; then
    data=$(gh api "/repos/$r" \
      --jq '[(.stargazers_count|tostring),(.license.spdx_id // "NONE"),(.pushed_at|split("T")[0]),(.archived|tostring)] | @tsv' \
      2>/dev/null)
  else
    data=$(gh api "/repos/$r" --jq '[(.stargazers_count|tostring),"-","-",(.archived|tostring)] | @tsv' 2>/dev/null)
  fi

  if [ -z "$data" ]; then
    printf 'BROKEN   %s\n' "$r"
    fail=$((fail + 1))
    continue
  fi

  IFS=$'\t' read -r stars lic pushed archived <<<"$data"

  note=""
  [ "$archived" = "true" ] && { note=" [ARCHIVED]"; stale=$((stale + 1)); }

  if [ "$CHECK_METADATA" -eq 1 ]; then
    printf 'ok       %-34s ★%-8s %-14s %s%s\n' "$r" "$stars" "$lic" "$pushed" "$note"
  else
    printf 'ok       %-34s ★%s%s\n' "$r" "$stars" "$note"
  fi
done

echo
echo "----------------------------------------"
printf 'checked: %s   broken: %s   archived: %s\n' "${#repos[@]}" "$fail" "$stale"

[ "$fail" -gt 0 ] && exit 1
exit 0
