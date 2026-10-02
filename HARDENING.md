<!-- markdownlint-disable -->

# Hardening Report: cloudposse--github-action-atmos-affected-stacks/v6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **cloudposse--github-action-atmos-affected-stacks/v6** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple `uses:` references in action.yml use mutable version tags instead of pinned 40-character SHA commit hashes, making the action vulnerable to supply-chain attacks if those tags are moved. Failing references: `actions/setup-node@v6`, `actions/checkout@v6` (used twice), `cloudposse-github-actions/install-gh-releases@v1` (used twice), `hashicorp/setup-terraform@v4`, `aws-actions/configure-aws-credentials@v6`, `cloudposse/github-action-matrix-extended@v0`. Only `cloudposse/github-action-setup-atmos@49625d9fcea135fe450ff3baa36283ac67b21cb8` is correctly pinned.

Locations:

- `action.yml:110`
- `action.yml:114`
- `action.yml:119`
- `action.yml:155`
- `action.yml:162`
- `action.yml:173`
- `action.yml:196`
- `action.yml:263`

### github-env-injection (severity: high)

The 'Set vars' step maps the untrusted input `inputs.atmos-config-path` into the env var `ATMOS_CONFIG_PATH`, then writes it to `$GITHUB_ENV` without sanitization: `echo "ATMOS_CLI_CONFIG_PATH=$(realpath "$ATMOS_CONFIG_PATH")" >> $GITHUB_ENV`. An attacker-controlled value containing newlines could inject arbitrary environment variables. The required sanitization (`printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r'`) is absent before the write.

Locations:

- `action.yml:137`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection

**Notes:**

Fixed all 8 unpinned action references by resolving their full commit SHAs via lookup_action_sha: actions/setup-node@v6 → @249970729cb0ef3589644e2896645e5dc5ba9c38, actions/checkout@v6 (×2) → @d23441a48e516b6c34aea4fa41551a30e30af803, cloudposse-github-actions/install-gh-releases@v1 (×2) → @33b15dbedceb0a3425d72f54a2300202d5c3418d, hashicorp/setup-terraform@v4 → @dfe3c3f87815947d99a8997f908cb6525fc44e9e, aws-actions/configure-aws-credentials@v6 → @e1253824e5c10ff9df46874f81ed3ec929e19cfd, cloudposse/github-action-matrix-extended@v0 → @5e66a04f8e0e6532dd8248954677d5038955b690. Fixed github-env-injection in the 'Set vars' step by sanitizing ATMOS_CONFIG_PATH with `printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r'` before passing it to realpath and writing to $GITHUB_ENV.

