# Repository management policy redesign

## Goal

Remove validation and approval requirements from the pull-request path. Keep
the repository's complete ASLRef validation available as an explicit manual
release operation.

This is a repository-governance change. It does not change PTO instruction
semantics, catalogs, profiles, ASL source, or the ASLRef version pin.

## Policy outcome

Pull requests and direct updates to `main` have no repository-defined status
check or approval prerequisite:

- no GitHub Actions workflow runs on `pull_request` or `push`;
- no lightweight substitute check replaces the current full validation job;
- no CODEOWNERS file requests or requires committer review;
- normative changes do not require a PR approval to merge; and
- contributor documentation does not instruct authors to run ASLRef or the
  complete validation suite for each PR.

Full validation becomes a release-manager action. Before publishing a release,
the release manager runs one checked-in script that prepares the pinned ASLRef
toolchain and executes the complete repository validation suite.

## Repository changes

### Pull-request automation

Delete `.github/workflows/asl.yml`. A disabled or no-op replacement would still
present a misleading status context, while a manually dispatched workflow
would make GitHub Actions rather than the repository script the release entry
point.

Delete `.github/CODEOWNERS`. Ownership information and reviewer routing are no
longer repository policy.

Simplify `.github/PULL_REQUEST_TEMPLATE.md` so it requests a change summary,
architecture impact, and known gaps without validation checkboxes or reviewer
requirements. These fields communicate content; they do not gate merge.

### Manual release validation

Add executable `scripts/validate-release` as the canonical release-validation
entry point. It runs, in order:

1. `make clean` to discard generated build output;
2. `make setup` to prepare the exact ASLRef commit in `.aslref-version`;
3. `make ci` to run repository checks, ASLRef canaries, strict type-checking,
   and the complete executable test shards; and
4. `git diff --check` to reject whitespace errors in the release tree.

Add a `release-validate` Make target that delegates to the script. The script
is authoritative; the Make target is a discoverable convenience alias.

The existing lower-level targets remain available for voluntary development
use, but repository policy does not require them before a PR is merged.

### Written governance

Update `AGENTS.md`, `GOVERNANCE.md`, `CONTRIBUTING.md`, `README.md`, and the
repo-local `pto-asl` skill so they consistently state:

- PR validation is optional and not automated;
- PR approval is not required, including for normative changes;
- architecture requirements and traceability remain content obligations for
  normative changes, not merge-approval obligations; and
- full ASLRef validation is required only when preparing a release.

The formal review checklist may remain as optional guidance, but no policy or
machine-readable gate may treat committer review as a prerequisite.

### Machine-readable governance evidence

Update repository checkers, release-manifest inputs, and generated release-gate
evidence so they no longer require or hash `.github/CODEOWNERS` or the deleted
workflow. The release-gate inventory will identify `scripts/validate-release`
and `make release-validate` as the manual full-validation path.

Remove hosted-PR validation and required-review claims from generated evidence.
Regenerate affected checked-in manifests from their generators rather than
editing generated JSON directly.

### GitHub repository settings

For `main`, remove required status checks and set required approving reviews to
zero. Disable CODEOWNER approval because CODEOWNERS is removed. Retain unrelated
protections such as signed commits, linear history, resolved conversations,
force-push prevention, and deletion prevention unless the existing GitHub rule
cannot represent them independently.

Repository files remain the durable policy source. A post-change read of the
GitHub rule records the external settings used to implement that policy.

## Verification

This governance change will not run ASLRef, because doing so would contradict
the new rule that ASLRef is a release-only gate. Implementation verification is
limited to checks that prove the management policy itself:

- parse all changed YAML, JSON, TOML, Python, Bash, and Make syntax;
- confirm no workflow has `pull_request` or `push` triggers;
- confirm `.github/CODEOWNERS` is absent and no required-file inventory expects
  it;
- confirm policy text contains no required PR validation or approval language;
- run the repository's clone-only policy/generator checks that are necessary
  to validate regenerated governance artifacts, without invoking ASLRef;
- run `git diff --check`; and
- query the `main` branch rule to confirm zero required checks and zero required
  approvals when GitHub credentials permit the settings update.

The new release script itself is verified by shell syntax and command-order
inspection during this change. Its expensive ASLRef execution occurs when a
release manager invokes it for a release.

## Risks and boundaries

Merging without automated validation can admit invalid ASL, stale generated
evidence, broken scripts, or documentation inconsistencies. This is an
accepted management-policy tradeoff. The manual release gate is the point at
which those defects must be found before publication.

The change does not remove ASLRef, `.aslref-version`, test shards, canaries, or
validation targets. It changes when the full suite is required and removes
repository-enforced PR review.
