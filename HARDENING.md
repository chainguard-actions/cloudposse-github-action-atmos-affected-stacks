<!-- markdownlint-disable -->

# Hardening Report: cloudposse--github-action-atmos-affected-stacks/v6.13.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **cloudposse--github-action-atmos-affected-stacks/v6.13.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple `uses:` references in action.yml use mutable tags instead of full 40-character SHA commit digests, making the action vulnerable to supply-chain attacks. Unpinned references: `actions/setup-node@v6` (line 92), `actions/checkout@v6` (lines 96 and 147), `cloudposse-github-actions/install-gh-releases@v1` (lines 101 and 136), `hashicorp/setup-terraform@v4` (line 131), `aws-actions/configure-aws-credentials@v6` (line 165), `cloudposse/github-action-matrix-extended@v0` (line 253). Only `cloudposse/github-action-setup-atmos@49625d9fcea135fe450ff3baa36283ac67b21cb8` is correctly pinned.

Locations:

- `action.yml:92`
- `action.yml:96`
- `action.yml:101`
- `action.yml:131`
- `action.yml:136`
- `action.yml:147`
- `action.yml:165`
- `action.yml:253`

### github-env-injection (severity: high)

The 'Set vars' step writes the caller-controlled input `inputs.atmos-config-path` (via the `ATMOS_CONFIG_PATH` env var) to `$GITHUB_ENV` without sanitization: `echo "ATMOS_CLI_CONFIG_PATH=$(realpath "$ATMOS_CONFIG_PATH")" >> $GITHUB_ENV`. A calling workflow can supply a value containing newline characters to inject arbitrary key=value pairs into the runner environment. The required sanitization (`printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r'`) is missing before the write.

Locations:

- `action.yml:119`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection

**Notes:**

Fixed all 8 unpinned `uses:` references by resolving them to full 40-character SHA digests via lookup_action_sha: actions/setup-node@v6→48b55a0, actions/checkout@v6→df4cb1c (both instances), cloudposse-github-actions/install-gh-releases@v1→33b15db (both instances), hashicorp/setup-terraform@v4→dfe3c3f, aws-actions/configure-aws-credentials@v6→e7f100c, cloudposse/github-action-matrix-extended@v0→c599eed. Fixed github-env-injection in the 'Set vars' step by sanitizing the caller-controlled ATMOS_CONFIG_PATH value with `printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r'` before passing it to `realpath` and writing to $GITHUB_ENV.

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed the 'Set vars' step in action.yml (line 109) by adding a second sanitization pass on the output of `realpath`. The original code sanitized `$ATMOS_CONFIG_PATH` into `safe_path` but then wrote `$(realpath "$safe_path")` directly to $GITHUB_ENV without re-sanitizing. The fix captures the realpath output into a `safe` variable via `safe=$(printf '%s' "$(realpath "$safe_path")" | tr -d '\n\r')` and then writes `$safe` to $GITHUB_ENV, ensuring no embedded newlines can inject additional key=value pairs.

