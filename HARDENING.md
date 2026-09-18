<!-- markdownlint-disable -->

# Hardening Report: cloudposse--github-action-atmos-affected-stacks/v6.14.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **cloudposse--github-action-atmos-affected-stacks/v6.14.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple `uses:` references in action.yml are pinned to mutable tags or version strings instead of immutable 40-character commit SHAs. This exposes the action to supply-chain attacks if any upstream action is compromised or its tag is moved. Unpinned references found:
- `actions/setup-node@v6`
- `actions/checkout@v6` (used twice)
- `cloudposse-github-actions/install-gh-releases@v1` (used twice)
- `hashicorp/setup-terraform@v4`
- `aws-actions/configure-aws-credentials@v6`
- `cloudposse/github-action-matrix-extended@v0`

Only `cloudposse/github-action-setup-atmos@49625d9fcea135fe450ff3baa36283ac67b21cb8` is correctly pinned.

Locations:

- `action.yml:103`
- `action.yml:106`
- `action.yml:111`
- `action.yml:116`
- `action.yml:130`
- `action.yml:135`
- `action.yml:155`
- `action.yml:185`

### github-env-injection (severity: high)

The 'Set vars' step maps `inputs.atmos-config-path` into the env var `ATMOS_CONFIG_PATH` and then writes it to `$GITHUB_ENV` without the required newline-stripping sanitization (`printf '%s' ... | tr -d '\n\r'`). The offending line is:

  echo "ATMOS_CLI_CONFIG_PATH=$(realpath "$ATMOS_CONFIG_PATH")" >> $GITHUB_ENV

Because `ATMOS_CONFIG_PATH` is sourced directly from `inputs.atmos-config-path` (a caller-controlled value), a malicious input containing embedded newlines could inject arbitrary key=value pairs into the runner's environment via `$GITHUB_ENV`. This is a case (d) indirect write of an input via env var without sanitization.

Locations:

- `action.yml:120`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection

**Notes:**

Fixed all 8 unpinned `uses:` references by resolving their full commit SHAs via lookup_action_sha and pinning them in the format `owner/repo@SHA # tag`. Fixed the github-env-injection vulnerability in the 'Set vars' step by capturing the realpath output, stripping newlines with `tr -d '\n\r'`, and using `printf` to write the sanitized value to $GITHUB_ENV.

