<!-- markdownlint-disable -->

# Hardening Report: cloudposse--github-action-atmos-affected-stacks/v6.13.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **cloudposse--github-action-atmos-affected-stacks/v6.13.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple `uses:` references in action.yml use mutable tags instead of full 40-character SHA commit hashes, making the action vulnerable to supply-chain attacks if the referenced tag is moved. Unpinned references: `actions/setup-node@v6`, `actions/checkout@v6` (used twice), `cloudposse-github-actions/install-gh-releases@v1` (used twice), `hashicorp/setup-terraform@v4`, `aws-actions/configure-aws-credentials@v6`, `cloudposse/github-action-matrix-extended@v0`. Only `cloudposse/github-action-setup-atmos@49625d9fcea135fe450ff3baa36283ac67b21cb8` is correctly pinned.

Locations:

- `action.yml:100`
- `action.yml:103`
- `action.yml:108`
- `action.yml:118`
- `action.yml:152`
- `action.yml:158`
- `action.yml:175`
- `action.yml:296`

### github-env-injection (severity: high)

In the 'Set vars' step, the value of `$ATMOS_CONFIG_PATH` (sourced from `inputs.atmos-config-path`, a caller-controlled input) is written to `$GITHUB_ENV` via `echo "ATMOS_CLI_CONFIG_PATH=$(realpath "$ATMOS_CONFIG_PATH")" >> $GITHUB_ENV` without sanitization. The `realpath` call does not strip newline characters, so a crafted input containing embedded newlines could inject additional key=value pairs into `$GITHUB_ENV`. The required sanitization step (`printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r'`) is missing before the write.

Locations:

- `action.yml:131`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection

**Notes:**

Fixed all 8 unpinned `uses:` references by resolving their full commit SHAs via lookup_action_sha: actions/setup-node@v6 → @249970729cb0ef3589644e2896645e5dc5ba9c38, actions/checkout@v6 (×2) → @d23441a48e516b6c34aea4fa41551a30e30af803, cloudposse-github-actions/install-gh-releases@v1 (×2) → @33b15dbedceb0a3425d72f54a2300202d5c3418d, hashicorp/setup-terraform@v4 → @dfe3c3f87815947d99a8997f908cb6525fc44e9e, aws-actions/configure-aws-credentials@v6 → @e1253824e5c10ff9df46874f81ed3ec929e19cfd, cloudposse/github-action-matrix-extended@v0 → @5e66a04f8e0e6532dd8248954677d5038955b690. Fixed github-env-injection in the 'Set vars' step by sanitizing ATMOS_CONFIG_PATH with `printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r'` before passing to realpath and writing to $GITHUB_ENV.

