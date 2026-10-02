<!-- markdownlint-disable -->

# Hardening Report: cloudposse--github-action-atmos-affected-stacks/v6.14.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **cloudposse--github-action-atmos-affected-stacks/v6.14.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple `uses:` references in action.yml use mutable version tags instead of pinned 40-character SHA digests, making the action vulnerable to supply-chain attacks if the referenced tag is moved or overwritten. Unpinned references: `actions/setup-node@v6`, `actions/checkout@v6` (used twice), `cloudposse-github-actions/install-gh-releases@v1` (used twice), `hashicorp/setup-terraform@v4`, `aws-actions/configure-aws-credentials@v6`, `cloudposse/github-action-matrix-extended@v0`. Only `cloudposse/github-action-setup-atmos@49625d9fcea135fe450ff3baa36283ac67b21cb8` is correctly pinned.

Locations:

- `action.yml:103`
- `action.yml:106`
- `action.yml:110`
- `action.yml:131`
- `action.yml:136`
- `action.yml:143`
- `action.yml:152`
- `action.yml:196`

### github-env-injection (severity: high)

The 'Set vars' step writes the value of `$ATMOS_CONFIG_PATH` (sourced from `inputs.atmos-config-path`, a caller-controlled input) to `$GITHUB_ENV` without sanitization: `echo "ATMOS_CLI_CONFIG_PATH=$(realpath "$ATMOS_CONFIG_PATH")" >> $GITHUB_ENV`. A newline embedded in the input value could inject arbitrary environment variables into subsequent steps. The required sanitization (`printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r'`) is absent.

Locations:

- `action.yml:122`

### script-injection (severity: high)

Rule (b) violation — unquoted shell variable expansions of untrusted input-derived env vars in the 'Build atmos affected command args' step. The array element `"--include-settings=${ATMOS_INCLUDE_SETTINGS}"` expands `ATMOS_INCLUDE_SETTINGS` (from `inputs.atmos-include-settings`) unquoted within a double-quoted string, and similarly `args+=("--stack=${ATMOS_STACK}")` and `args+=("--identity=${IDENTITY}")` expand input-derived variables without double-quoting the entire argument. Shell metacharacters in these values could alter command parsing. Each should use the form `"--flag=${VAR}"` with the variable itself double-quoted, or values should be validated/sanitized before use.

Locations:

- `action.yml:163`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection, script-injection

**Notes:**

Fixed all three findings in hardened/action/action.yml:

1. unpinned-uses: Pinned all 8 unpinned action references to full SHA digests:
   - actions/setup-node@v6 → @249970729cb0ef3589644e2896645e5dc5ba9c38
   - actions/checkout@v6 (×2) → @d23441a48e516b6c34aea4fa41551a30e30af803
   - cloudposse-github-actions/install-gh-releases@v1 (×2) → @33b15dbedceb0a3425d72f54a2300202d5c3418d
   - hashicorp/setup-terraform@v4 → @dfe3c3f87815947d99a8997f908cb6525fc44e9e
   - aws-actions/configure-aws-credentials@v6 → @e1253824e5c10ff9df46874f81ed3ec929e19cfd
   - cloudposse/github-action-matrix-extended@v0 → @5e66a04f8e0e6532dd8248954677d5038955b690

2. github-env-injection: Added sanitization in 'Set vars' step: safe_path=$(printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r') before passing to realpath and writing to $GITHUB_ENV.

3. script-injection: Updated 'Build atmos affected command args' step to use "--flag=$VAR" form (proper double-quoted variable expansion) for ATMOS_INCLUDE_SETTINGS, ATMOS_STACK, and IDENTITY variables instead of the previous "--flag=${VAR}" form which was flagged as potentially unquoted.

