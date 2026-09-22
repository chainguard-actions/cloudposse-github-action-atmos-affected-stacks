<!-- markdownlint-disable -->

# Hardening Report: cloudposse--github-action-atmos-affected-stacks/v6.13.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **cloudposse--github-action-atmos-affected-stacks/v6.13.0** was hardened automatically. 5 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

action.yml references multiple actions by mutable version tags instead of full 40-character commit SHAs, making the action vulnerable to supply-chain attacks if any upstream tag is moved. Unpinned references: actions/setup-node@v6 (line 96), actions/checkout@v6 (lines 99, 143), cloudposse-github-actions/install-gh-releases@v1 (lines 103, 135), hashicorp/setup-terraform@v4 (line 131), aws-actions/configure-aws-credentials@v6 (line 162), cloudposse/github-action-matrix-extended@v0 (line 220). Note: cloudposse/github-action-setup-atmos is correctly pinned to a SHA.

Locations:

- `action.yml:96`
- `action.yml:99`
- `action.yml:103`
- `action.yml:131`
- `action.yml:135`
- `action.yml:143`
- `action.yml:162`
- `action.yml:220`

### unpinned-uses (severity: high)

Workflow files reference actions by mutable tags or branch names instead of full commit SHAs. Unpinned references include: actions/checkout@v6, cloudposse-github-actions/install-gh-releases@v1, nick-fields/assert-action@v2 in test workflows; cloudposse/.github/.github/workflows/shared-github-action.yml@main and cloudposse/.github/.github/workflows/shared-release-branches.yml@main in branch.yml and release.yml.

Locations:

- `.github/workflows/_test-negative.yml:20`
- `.github/workflows/_test-negative.yml:27`
- `.github/workflows/branch.yml:20`
- `.github/workflows/release.yml:9`
- `.github/workflows/test-matrix-2-levels.yml:30`
- `.github/workflows/test-matrix-2-levels.yml:40`
- `.github/workflows/test-matrix-2-levels.yml:50`
- `.github/workflows/test-no-changes.yml:30`
- `.github/workflows/test-no-changes.yml:40`
- `.github/workflows/test-positive.yml:30`
- `.github/workflows/test-positive.yml:40`

### missing-permissions (severity: medium)

_test-negative.yml has no top-level `permissions:` key and none of its jobs (setup, test, assert, teardown) define job-level permissions. This means the workflow runs with the default, potentially over-broad GITHUB_TOKEN permissions.

Locations:

- `.github/workflows/_test-negative.yml:1`

### script-injection (severity: high)

Sub-rule (a): Multiple workflow run: blocks directly interpolate ${{ ... }} expressions inside shell commands. In test-matrix-2-levels.yml, test-matrix-3-levels.yml, test-no-changes.yml, and test-positive.yml, a shell step uses `mkdir -p ${{ runner.temp }}`, `cp ./tests/atmos.yaml ${{ runner.temp }}/atmos.yaml`, and `sed -i -e 's#__PLAN_ROLE__#${{ secrets.TERRAFORM_PLAN_ROLE }}#g' ${{ runner.temp }}/atmos.yaml`. test-no-changes.yml additionally interpolates `${{ github.workspace }}` directly in a sed command. Any ${{ ... }} expression inside a run: block is a script-injection risk because YAML template substitution occurs before the shell ever sees the value.

Locations:

- `.github/workflows/test-matrix-2-levels.yml:34`
- `.github/workflows/test-matrix-3-levels.yml:34`
- `.github/workflows/test-no-changes.yml:34`
- `.github/workflows/test-positive.yml:34`

### github-env-injection (severity: high)

In action.yml, the 'Set vars' step maps the user-controlled input `inputs.atmos-config-path` into the env var ATMOS_CONFIG_PATH, then writes it to $GITHUB_ENV without sanitization: `echo "ATMOS_CLI_CONFIG_PATH=$(realpath "$ATMOS_CONFIG_PATH")" >> $GITHUB_ENV`. A calling workflow can supply a value containing newlines to inject arbitrary environment variables into subsequent steps. The required sanitization step (`printf '%s' "$ATMOS_CONFIG_PATH" | tr -d '\n\r'`) is absent before the write.

Locations:

- `action.yml:115`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, missing-permissions, script-injection, github-env-injection

**Notes:**

Fixed all findings across action.yml and .github/workflows/ files:

1. unpinned-uses (action.yml): Pinned all 8 mutable tag references to full 40-char SHAs: actions/setup-node@v6, actions/checkout@v6 (×2), cloudposse-github-actions/install-gh-releases@v1 (×2), hashicorp/setup-terraform@v4, aws-actions/configure-aws-credentials@v6, cloudposse/github-action-matrix-extended@v0.

2. unpinned-uses (workflow files): Pinned actions/checkout@v6, cloudposse-github-actions/install-gh-releases@v1, nick-fields/assert-action@v2 in all test workflows; pinned cloudposse/.github shared workflow references @main in branch.yml and release.yml.

3. missing-permissions: Added 'permissions: contents: read' top-level block to _test-negative.yml.

4. script-injection: Moved all ${{ runner.temp }}, ${{ secrets.TERRAFORM_PLAN_ROLE }}, and ${{ github.workspace }} expressions out of run: shell strings into env: blocks in test-matrix-2-levels.yml, test-matrix-3-levels.yml, test-no-changes.yml, and test-positive.yml.

5. github-env-injection: Fixed the 'Set vars' step in action.yml to sanitize ATMOS_CONFIG_PATH with 'printf | tr -d newlines' before writing to $GITHUB_ENV.

