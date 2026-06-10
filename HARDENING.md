<!-- markdownlint-disable -->

# Hardening Report: cloudposse--github-action-atmos-affected-stacks/v6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **cloudposse--github-action-atmos-affected-stacks/v6** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple `uses:` references in action.yml are pinned to mutable tags instead of full 40-character commit SHAs, making the action vulnerable to supply-chain attacks if those tags are moved. Unpinned references:
- `actions/setup-node@v6` (line ~101)
- `actions/checkout@v6` (line ~104, first occurrence)
- `cloudposse-github-actions/install-gh-releases@v1` (line ~109, first occurrence)
- `hashicorp/setup-terraform@v4` (line ~131)
- `cloudposse-github-actions/install-gh-releases@v1` (line ~136, second occurrence)
- `actions/checkout@v6` (line ~147, second occurrence)
- `aws-actions/configure-aws-credentials@v6` (line ~163)
- `cloudposse/github-action-matrix-extended@v0` (line ~234)

Only `cloudposse/github-action-setup-atmos@49625d9fcea135fe450ff3baa36283ac67b21cb8` is correctly pinned to a SHA.

Locations:

- `action.yml:101`
- `action.yml:104`
- `action.yml:109`
- `action.yml:131`
- `action.yml:136`
- `action.yml:147`
- `action.yml:163`
- `action.yml:234`

### github-env-injection (severity: high)

The 'Set vars' step maps the untrusted input `inputs.atmos-config-path` into the env var `ATMOS_CONFIG_PATH`, then writes it to `$GITHUB_ENV` without sanitization:

```yaml
env:
  ATMOS_CONFIG_PATH: ${{ inputs.atmos-config-path }}
run: |-
  echo "ATMOS_CLI_CONFIG_PATH=$(realpath "$ATMOS_CONFIG_PATH")" >> $GITHUB_ENV
```

An attacker-controlled value containing newlines could inject arbitrary environment variables into subsequent steps. The required sanitization step (`safe=$(printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r')`) is missing before the write to `$GITHUB_ENV`.

Locations:

- `action.yml:123`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection

**Notes:**

Fixed all 8 unpinned `uses:` references by resolving their full 40-character commit SHAs via lookup_action_sha and appending the original tag as a comment. Fixed the github-env-injection finding in the 'Set vars' step by sanitizing the ATMOS_CONFIG_PATH input with `printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r'` before passing it to realpath and writing to $GITHUB_ENV.

