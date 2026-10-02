<!-- markdownlint-disable -->

# Hardening Report: cloudposse--github-action-atmos-affected-stacks/v6.14.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **cloudposse--github-action-atmos-affected-stacks/v6.14.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

action.yml contains 7 unpinned `uses:` references that use mutable tags instead of full 40-character commit SHAs. A supply-chain attacker who compromises any of these upstream repositories can push a new tag and inject malicious code into this action. Only `cloudposse/github-action-setup-atmos@49625d9fcea135fe450ff3baa36283ac67b21cb8` is correctly pinned. Unpinned references:
- `actions/setup-node@v6` (line 110)
- `actions/checkout@v6` (line 114, first occurrence)
- `cloudposse-github-actions/install-gh-releases@v1` (line 119, first occurrence)
- `hashicorp/setup-terraform@v4` (line 152)
- `cloudposse-github-actions/install-gh-releases@v1` (line 158, second occurrence)
- `actions/checkout@v6` (line 168, second occurrence)
- `aws-actions/configure-aws-credentials@v6` (line 190)
- `cloudposse/github-action-matrix-extended@v0` (line 228)

Locations:

- `action.yml:110`
- `action.yml:114`
- `action.yml:119`
- `action.yml:152`
- `action.yml:158`
- `action.yml:168`
- `action.yml:190`
- `action.yml:228`

### github-env-injection (severity: high)

The 'Set vars' step writes the value of `inputs.atmos-config-path` (an untrusted caller-controlled input) to `$GITHUB_ENV` without sanitization. The input is mapped to the `ATMOS_CONFIG_PATH` env var and then written via: `echo "ATMOS_CLI_CONFIG_PATH=$(realpath "$ATMOS_CONFIG_PATH")" >> $GITHUB_ENV`. A malicious caller could supply a value containing newlines to inject arbitrary environment variable definitions (e.g., `ATMOS_CONFIG_PATH=$'legit\nSECRET_TOKEN=injected'`). The required sanitization step (`printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r'`) is absent before the write to `$GITHUB_ENV`.

Locations:

- `action.yml:137`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection

**Notes:**

Fixed all 8 unpinned `uses:` references by resolving each to its full 40-character commit SHA (keeping the original tag as a comment): actions/setup-node@v6 → 249970729cb0ef3589644e2896645e5dc5ba9c38, actions/checkout@v6 → d23441a48e516b6c34aea4fa41551a30e30af803 (both occurrences), cloudposse-github-actions/install-gh-releases@v1 → 33b15dbedceb0a3425d72f54a2300202d5c3418d (both occurrences), hashicorp/setup-terraform@v4 → dfe3c3f87815947d99a8997f908cb6525fc44e9e, aws-actions/configure-aws-credentials@v6 → e1253824e5c10ff9df46874f81ed3ec929e19cfd, cloudposse/github-action-matrix-extended@v0 → 5e66a04f8e0e6532dd8248954677d5038955b690. Fixed the github-env-injection finding in the 'Set vars' step by sanitizing the caller-controlled ATMOS_CONFIG_PATH input with `printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r'` before using it in the realpath call and writing to $GITHUB_ENV.

