<!-- markdownlint-disable -->

# Hardening Report: cloudposse--github-action-atmos-affected-stacks/v6.13.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **cloudposse--github-action-atmos-affected-stacks/v6.13.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

8 out of 9 `uses:` references in action.yml use mutable version tags instead of pinned full-length SHA digests, making the action vulnerable to supply-chain attacks if those upstream actions are compromised or their tags are moved. Only `cloudposse/github-action-setup-atmos@49625d9fcea135fe450ff3baa36283ac67b21cb8` is correctly pinned. The unpinned references are:
- `actions/setup-node@v6`
- `actions/checkout@v6` (used twice)
- `cloudposse-github-actions/install-gh-releases@v1` (used twice)
- `hashicorp/setup-terraform@v4`
- `aws-actions/configure-aws-credentials@v6`
- `cloudposse/github-action-matrix-extended@v0`

Locations:

- `action.yml:99`
- `action.yml:102`
- `action.yml:107`
- `action.yml:138`
- `action.yml:143`
- `action.yml:153`
- `action.yml:174`
- `action.yml:228`

### github-env-injection (severity: high)

The 'Set vars' step writes the caller-controlled input `inputs.atmos-config-path` to `$GITHUB_ENV` without sanitization. The value is placed into the env var `ATMOS_CONFIG_PATH` and then written via `echo "ATMOS_CLI_CONFIG_PATH=$(realpath "$ATMOS_CONFIG_PATH")" >> $GITHUB_ENV`. A calling workflow can supply a value containing embedded newline characters, which would allow injection of arbitrary additional environment variables into subsequent steps. The required sanitization step (`printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r'`) is absent before the write.

Locations:

- `action.yml:120`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection

**Notes:**

Fixed all 8 unpinned `uses:` references by resolving their full commit SHAs via lookup_action_sha and pinning them in the format `owner/repo@<sha> # tag`. The pinned actions are: actions/setup-node@249970729cb0ef3589644e2896645e5dc5ba9c38 (v6), actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803 (v6, used twice), cloudposse-github-actions/install-gh-releases@33b15dbedceb0a3425d72f54a2300202d5c3418d (v1, used twice), hashicorp/setup-terraform@dfe3c3f87815947d99a8997f908cb6525fc44e9e (v4), aws-actions/configure-aws-credentials@e1253824e5c10ff9df46874f81ed3ec929e19cfd (v6), and cloudposse/github-action-matrix-extended@5e66a04f8e0e6532dd8248954677d5038955b690 (v0). Fixed the github-env-injection in the 'Set vars' step by sanitizing the caller-controlled `inputs.atmos-config-path` value with `printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r'` before passing it to `realpath` and writing to $GITHUB_ENV.

