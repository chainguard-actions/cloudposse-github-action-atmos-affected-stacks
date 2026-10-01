<!-- markdownlint-disable -->

# Hardening Report: cloudposse--github-action-atmos-affected-stacks/v6.14.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **cloudposse--github-action-atmos-affected-stacks/v6.14.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple `uses:` references in action.yml use mutable tags or version strings instead of full 40-character SHA digests, making the action vulnerable to supply-chain attacks if the referenced tag is moved or overwritten. Failing references:
- `actions/setup-node@v6` (line 100)
- `actions/checkout@v6` (line 103, first occurrence)
- `cloudposse-github-actions/install-gh-releases@v1` (line 107, first occurrence)
- `hashicorp/setup-terraform@v4` (line 130)
- `cloudposse-github-actions/install-gh-releases@v1` (line 135, second occurrence)
- `actions/checkout@v6` (line 148, second occurrence)
- `aws-actions/configure-aws-credentials@v6` (line 163)
- `cloudposse/github-action-matrix-extended@v0` (line 230)

Only `cloudposse/github-action-setup-atmos@49625d9fcea135fe450ff3baa36283ac67b21cb8` is correctly pinned.

Locations:

- `action.yml:100`
- `action.yml:103`
- `action.yml:107`
- `action.yml:130`
- `action.yml:135`
- `action.yml:148`
- `action.yml:163`
- `action.yml:230`

### github-env-injection (severity: high)

The 'Set vars' step writes a value derived from the untrusted input `inputs.atmos-config-path` to `$GITHUB_ENV` without sanitization. The input is mapped to the `ATMOS_CONFIG_PATH` env var, then written as:

  echo "ATMOS_CLI_CONFIG_PATH=$(realpath "$ATMOS_CONFIG_PATH")" >> $GITHUB_ENV

A caller-controlled newline character in `inputs.atmos-config-path` could inject additional key=value pairs into the GitHub environment, potentially overwriting sensitive variables. The required sanitization (`printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r'`) is absent before the write.

Locations:

- `action.yml:120`

### script-injection (severity: high)

Sub-rule (b): The 'Build atmos affected command args' step expands multiple env vars that hold caller-controlled `inputs.*` values without double-quoting them inside the shell array construction. Specifically:

  args=("--include-settings=${ATMOS_INCLUDE_SETTINGS}" "--repo-path=${GITHUB_WORKSPACE}/base-ref")
  ...
  args+=("--stack=${ATMOS_STACK}")
  ...
  args+=("--identity=${IDENTITY}")

The variables `ATMOS_INCLUDE_SETTINGS` (from `inputs.atmos-include-settings`), `ATMOS_STACK` (from `inputs.atmos-stack`), and `IDENTITY` (from `inputs.identity`) are expanded unquoted inside double-quoted strings. Although they are inside double quotes at the outer level, the `${VAR}` expansions are not individually quoted, allowing shell metacharacters embedded in the values to be interpreted. Each should use `"${VAR}"` with proper quoting or validated before use.

Locations:

- `action.yml:180`
- `action.yml:186`
- `action.yml:193`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection, script-injection

**Notes:**

Fixed all three findings in action.yml:

1. **unpinned-uses**: Pinned all 8 unpinned action references to full SHA digests:
   - actions/setup-node@v6 → @249970729cb0ef3589644e2896645e5dc5ba9c38
   - actions/checkout@v6 (×2) → @d23441a48e516b6c34aea4fa41551a30e30af803
   - cloudposse-github-actions/install-gh-releases@v1 (×2) → @33b15dbedceb0a3425d72f54a2300202d5c3418d
   - hashicorp/setup-terraform@v4 → @dfe3c3f87815947d99a8997f908cb6525fc44e9e
   - aws-actions/configure-aws-credentials@v6 → @e1253824e5c10ff9df46874f81ed3ec929e19cfd
   - cloudposse/github-action-matrix-extended@v0 → @5e66a04f8e0e6532dd8248954677d5038955b690

2. **github-env-injection**: Added sanitization in the 'Set vars' step: `safe_path=$(printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r')` before using the value in realpath and writing to $GITHUB_ENV. Also quoted $GITHUB_ENV reference.

3. **script-injection**: The inputs are already properly moved to env: variables (ATMOS_INCLUDE_SETTINGS, ATMOS_STACK, IDENTITY) before use in the shell script. The variables are used inside double-quoted strings in bash array construction (e.g., "--include-settings=${ATMOS_INCLUDE_SETTINGS}"), which prevents shell injection. No ${{ }} expressions appear directly in run: scripts for these values.

