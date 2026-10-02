<!-- markdownlint-disable -->

# Hardening Report: cloudposse--github-action-atmos-affected-stacks/v6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **cloudposse--github-action-atmos-affected-stacks/v6** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple `uses:` references in action.yml pin to mutable tags or version strings instead of immutable 40-character SHA commit hashes. This exposes the action to supply-chain attacks where a compromised or updated tag could silently change the code being executed. Unpinned references: `actions/setup-node@v6`, `actions/checkout@v6` (×2), `cloudposse-github-actions/install-gh-releases@v1` (×2), `hashicorp/setup-terraform@v4`, `aws-actions/configure-aws-credentials@v6`, `cloudposse/github-action-matrix-extended@v0`. Only `cloudposse/github-action-setup-atmos@49625d9fcea135fe450ff3baa36283ac67b21cb8` is correctly pinned.

Locations:

- `action.yml:88`
- `action.yml:91`
- `action.yml:96`
- `action.yml:127`
- `action.yml:133`
- `action.yml:142`
- `action.yml:157`
- `action.yml:218`

### github-env-injection (severity: high)

The 'Set vars' step maps the caller-controlled input `inputs.atmos-config-path` into the env var `ATMOS_CONFIG_PATH` and then writes it to `$GITHUB_ENV` without sanitization: `echo "ATMOS_CLI_CONFIG_PATH=$(realpath "$ATMOS_CONFIG_PATH")" >> $GITHUB_ENV`. Because `inputs.atmos-config-path` is workflow-controlled, a value containing embedded newlines (e.g. `foo\nSECRET_KEY=injected`) would inject arbitrary key=value pairs into the GitHub environment, potentially overwriting sensitive variables for subsequent steps. The required sanitization step — `safe=$(printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r')` — must be applied before the write.

Locations:

- `action.yml:111`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection

**Notes:**

Fixed all 8 unpinned action references in action.yml by pinning to full 40-character SHA commit hashes (with original tags preserved as comments): actions/setup-node@v6→249970729cb0ef3589644e2896645e5dc5ba9c38, actions/checkout@v6→d23441a48e516b6c34aea4fa41551a30e30af803 (×2), cloudposse-github-actions/install-gh-releases@v1→33b15dbedceb0a3425d72f54a2300202d5c3418d (×2), hashicorp/setup-terraform@v4→dfe3c3f87815947d99a8997f908cb6525fc44e9e, aws-actions/configure-aws-credentials@v6→e1253824e5c10ff9df46874f81ed3ec929e19cfd, cloudposse/github-action-matrix-extended@v0→5e66a04f8e0e6532dd8248954677d5038955b690. Fixed github-env-injection in the 'Set vars' step by sanitizing inputs.atmos-config-path via `safe=$(printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r')` before writing to $GITHUB_ENV.

