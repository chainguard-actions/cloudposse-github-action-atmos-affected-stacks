#!/usr/bin/env bash
# Inline implementation of cloudposse/github-action-matrix-extended logic.
# Generates a GitHub Actions matrix from a JSON array of affected stacks.
#
# Inputs (via environment variables set by action.yml):
#   MATRIX_FILE           - path to JSON array file (default: affected-stacks.json)
#   MATRIX_SORT_BY        - field to sort by (optional)
#   MATRIX_GROUP_BY       - field to group by (optional)
#   MATRIX_NESTED_COUNT   - number of nested matrices: 1, 2, or 3 (default: 2)
#
# Outputs: writes matrix=<json> to $GITHUB_OUTPUT

set -euo pipefail

MATRIX_FILE="${MATRIX_FILE:-affected-stacks.json}"
SORT_BY="${MATRIX_SORT_BY:-}"
GROUP_BY="${MATRIX_GROUP_BY:-}"
NESTED_COUNT="${MATRIX_NESTED_COUNT:-2}"

if [[ ! -f "$MATRIX_FILE" ]]; then
  printf '%s\n' 'matrix={"include":[]}' >> "$GITHUB_OUTPUT"
  exit 0
fi

# Read and optionally sort the input array
if [[ -n "$SORT_BY" && "$SORT_BY" != "null" ]]; then
  ITEMS=$(jq -c --arg s "$SORT_BY" 'sort_by(.[$s] // "")' "$MATRIX_FILE")
else
  ITEMS=$(jq -c '.' "$MATRIX_FILE")
fi

LENGTH=$(echo "$ITEMS" | jq 'length')

if [[ "$LENGTH" -eq 0 ]]; then
  printf '%s\n' 'matrix={"include":[]}' >> "$GITHUB_OUTPUT"
  exit 0
fi

case "$NESTED_COUNT" in
  1)
    # Flat matrix: {"include": [...items...]}
    MATRIX=$(echo "$ITEMS" | jq -c '{"include": .}')
    ;;
  2)
    # 2-level nested matrix
    # Outer matrix: each element has an "items" key containing a chunk of stacks
    # Inner matrix (per outer element): the items themselves
    if [[ -n "$GROUP_BY" && "$GROUP_BY" != "null" ]]; then
      # Group by field: each group becomes one outer matrix entry
      MATRIX=$(echo "$ITEMS" | jq -c --arg g "$GROUP_BY" '
        group_by(.[$g] // "") |
        map({
          "name": (.[0][$g] // "default"),
          "items": (. | tojson)
        }) |
        {"include": .}
      ')
    else
      # No grouping: split into chunks of up to 10
      MATRIX=$(echo "$ITEMS" | jq -c '
        . as $all |
        [range(0; length; 10)] |
        map({
          "name": ("chunk-" + (. | tostring)),
          "items": ($all[.:. + 10] | tojson)
        }) |
        {"include": .}
      ')
    fi
    ;;
  3)
    # 3-level nested matrix
    if [[ -n "$GROUP_BY" && "$GROUP_BY" != "null" ]]; then
      MATRIX=$(echo "$ITEMS" | jq -c --arg g "$GROUP_BY" '
        group_by(.[$g] // "") |
        map({
          "name": (.[0][$g] // "default"),
          "items": (. | tojson)
        }) |
        {"include": .}
      ')
    else
      MATRIX=$(echo "$ITEMS" | jq -c '{"include": .}')
    fi
    ;;
  *)
    # Default: flat matrix
    MATRIX=$(echo "$ITEMS" | jq -c '{"include": .}')
    ;;
esac

# Validate output is valid JSON
if ! echo "$MATRIX" | jq . > /dev/null 2>&1; then
  MATRIX=$(jq -c '{"include": .}' "$MATRIX_FILE")
fi

printf '%s\n' "matrix=$MATRIX" >> "$GITHUB_OUTPUT"
