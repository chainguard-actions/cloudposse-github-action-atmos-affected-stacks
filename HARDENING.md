<!-- markdownlint-disable -->

# Hardening Report: cloudposse--github-action-atmos-affected-stacks/v6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **cloudposse--github-action-atmos-affected-stacks/v6** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple `uses:` references in action.yml use mutable tags or version strings instead of pinned 40-character commit SHAs, making the action vulnerable to supply-chain attacks if any of those upstream actions are compromised or their tags are moved. The following references are unpinned:
- `actions/setup-node@v6` (line 96)
- `actions/checkout@v6` (line 99, first occurrence)
- `cloudposse-github-actions/install-gh-releases@v1` (line 103, first occurrence)
- `hashicorp/setup-terraform@v4` (line 131)
- `cloudposse-github-actions/install-gh-releases@v1` (line 136, second occurrence)
- `actions/checkout@v6` (line 148, second occurrence)
- `aws-actions/configure-aws-credentials@v6` (line 163)
- `cloudposse/github-action-matrix-extended@v0` (line 220)

Only `cloudposse/github-action-setup-atmos@49625d9fcea135fe450ff3baa36283ac67b21cb8` is correctly pinned.

Locations:

- `action.yml:96`
- `action.yml:99`
- `action.yml:103`
- `action.yml:131`
- `action.yml:136`
- `action.yml:148`
- `action.yml:163`
- `action.yml:220`

### github-env-injection (severity: high)

The 'Set vars' step writes the caller-controlled input `inputs.atmos-config-path` to `$GITHUB_ENV` without sanitization. The input is mapped to the `ATMOS_CONFIG_PATH` env var and then written via:

  echo "ATMOS_CLI_CONFIG_PATH=$(realpath "$ATMOS_CONFIG_PATH")" >> $GITHUB_ENV

If a calling workflow passes a value containing newline characters (e.g. `\nFOO=bar`), the attacker can inject arbitrary key=value pairs into the runner's environment for all subsequent steps. The required sanitization step (`safe=$(printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r')`) is absent before the write.

Locations:

- `action.yml:114`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection

**Notes:**

Fixed all 8 unpinned `uses:` references by pinning them to full 40-character commit SHAs: actions/setup-node@v6→249970729cb0ef3589644e2896645e5dc5ba9c38, actions/checkout@v6→d23441a48e516b6c34aea4fa41551a30e30af803 (both occurrences), cloudposse-github-actions/install-gh-releases@v1→33b15dbedceb0a3425d72f54a2300202d5c3418d (both occurrences), hashicorp/setup-terraform@v4→dfe3c3f87815947d99a8997f908cb6525fc44e9e, aws-actions/configure-aws-credentials@v6→e1253824e5c10ff9df46874f81ed3ec929e19cfd, cloudposse/github-action-matrix-extended@v0→5e66a04f8e0e6532dd8248954677d5038955b690. Fixed the github-env-injection vulnerability in the 'Set vars' step by stripping newlines from the ATMOS_CONFIG_PATH input with `safe=$(printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r')` before using it in the realpath call and writing to GITHUB_ENV.

