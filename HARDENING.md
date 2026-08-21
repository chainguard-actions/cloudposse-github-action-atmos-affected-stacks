<!-- markdownlint-disable -->

# Hardening Report: cloudposse--github-action-atmos-affected-stacks/v6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **cloudposse--github-action-atmos-affected-stacks/v6** was hardened automatically. 5 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

action.yml contains multiple unpinned `uses:` references that use mutable version tags instead of full 40-character SHA digests, making the action vulnerable to supply-chain attacks if those tags are moved. Unpinned references: `actions/setup-node@v6`, `actions/checkout@v6` (appears twice), `cloudposse-github-actions/install-gh-releases@v1` (appears twice), `hashicorp/setup-terraform@v4`, `aws-actions/configure-aws-credentials@v6`, `cloudposse/github-action-matrix-extended@v0`. Only `cloudposse/github-action-setup-atmos` is correctly pinned to a SHA.

Locations:

- `action.yml:97`
- `action.yml:100`
- `action.yml:104`
- `action.yml:148`
- `action.yml:155`
- `action.yml:175`
- `action.yml:199`
- `action.yml:296`

### unpinned-uses (severity: high)

Workflow files contain unpinned `uses:` references using mutable tags (@v6, @v1, @v2, @main) instead of full SHA digests. Affected references include: `actions/checkout@v6`, `cloudposse-github-actions/install-gh-releases@v1`, `nick-fields/assert-action@v2`, `cloudposse/.github/.github/workflows/shared-github-action.yml@main`, `cloudposse/.github/.github/workflows/shared-release-branches.yml@main`.

Locations:

- `.github/workflows/_test-negative.yml:21`
- `.github/workflows/_test-negative.yml:29`
- `.github/workflows/branch.yml:21`
- `.github/workflows/release.yml:8`
- `.github/workflows/test-matrix-2-levels.yml:33`
- `.github/workflows/test-matrix-2-levels.yml:47`
- `.github/workflows/test-matrix-3-levels.yml:33`
- `.github/workflows/test-matrix-3-levels.yml:47`
- `.github/workflows/test-no-changes.yml:32`
- `.github/workflows/test-no-changes.yml:44`
- `.github/workflows/test-positive.yml:33`
- `.github/workflows/test-positive.yml:47`

### script-injection (severity: high)

Sub-rule (a): `run:` blocks directly interpolate `${{ runner.temp }}` and `${{ github.workspace }}` expressions inside shell commands. Although `runner.*` and `github.workspace` are not attacker-controlled in the same way as `github.head_ref`, any `${{ ... }}` expression inside a `run:` block is substituted by the YAML template engine before the shell sees it, bypassing shell quoting and constituting a script-injection risk. Offending lines include: `mkdir -p ${{ runner.temp }}`, `cp ./tests/atmos.yaml ${{ runner.temp }}/atmos.yaml`, `sed -i -e '...' ${{ runner.temp }}/atmos.yaml`, and `sed -i -e 's#base_path: "./tests"#base_path: "${{ github.workspace }}/tests"#g' ${{ runner.temp }}/atmos.yaml`. These should use the `$RUNNER_TEMP` and `$GITHUB_WORKSPACE` environment variables instead.

Locations:

- `.github/workflows/test-positive.yml:37`
- `.github/workflows/test-matrix-2-levels.yml:37`
- `.github/workflows/test-matrix-3-levels.yml:37`
- `.github/workflows/test-no-changes.yml:36`
- `.github/workflows/test-no-changes.yml:39`

### github-env-injection (severity: high)

The 'Set vars' step in action.yml writes the value of `$ATMOS_CONFIG_PATH` (sourced from `inputs.atmos-config-path` via the `env:` block) to `$GITHUB_ENV` without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). An attacker-controlled value for `atmos-config-path` containing newlines could inject arbitrary environment variables into subsequent steps. The offending line is: `echo "ATMOS_CLI_CONFIG_PATH=$(realpath "$ATMOS_CONFIG_PATH")" >> $GITHUB_ENV`.

Locations:

- `action.yml:118`

### missing-permissions (severity: medium)

The workflow file `_test-negative.yml` has no top-level `permissions:` key and none of its jobs (`setup`, `test`, `assert`, `teardown`) define job-level `permissions:` blocks. This means the workflow runs with the default (potentially broad) repository permissions.

Locations:

- `.github/workflows/_test-negative.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection, github-env-injection, missing-permissions

**Notes:**

Fixed all findings across action.yml and .github/workflows/ files:

1. **unpinned-uses (action.yml)**: Pinned 8 action references to full SHA digests: actions/setup-node@v6→@249970729..., actions/checkout@v6(×2)→@d23441a4..., cloudposse-github-actions/install-gh-releases@v1(×2)→@33b15dbe..., hashicorp/setup-terraform@v4→@dfe3c3f8..., aws-actions/configure-aws-credentials@v6→@e6de0542..., cloudposse/github-action-matrix-extended@v0→@c599eed8...

2. **unpinned-uses (workflow files)**: Pinned actions/checkout@v6→@d23441a4..., cloudposse-github-actions/install-gh-releases@v1→@33b15dbe..., nick-fields/assert-action@v2→@aa0067e0..., and cloudposse/.github shared workflows @main→@3911c663... in all affected workflow files.

3. **script-injection**: Replaced ${{ runner.temp }} with $RUNNER_TEMP and ${{ github.workspace }} with $GITHUB_WORKSPACE in run: blocks across test-positive.yml, test-matrix-2-levels.yml, test-matrix-3-levels.yml, and test-no-changes.yml.

4. **github-env-injection**: Fixed 'Set vars' step in action.yml to sanitize the realpath output with tr -d '\n\r' before writing to $GITHUB_ENV.

5. **missing-permissions**: Added 'permissions: {}' top-level block to _test-negative.yml.

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in 4 workflow files (.github/workflows/test-matrix-2-levels.yml, test-matrix-3-levels.yml, test-no-changes.yml, test-positive.yml). In each file, moved the ${{ secrets.TERRAFORM_PLAN_ROLE }} expression from inside the run: shell command string into an env: block on the step. Changed the sed command from using single-quoted 's#__PLAN_ROLE__#${{ secrets.TERRAFORM_PLAN_ROLE }}#g' (which embedded the template expression directly in the shell command) to double-quoted "s#__PLAN_ROLE__#${TERRAFORM_PLAN_ROLE}#g" (which references the safe env var). The ${{ }} expression now only appears in the env: block where it is safely handled by GitHub Actions before the shell runs.

