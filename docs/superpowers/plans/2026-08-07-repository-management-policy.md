# Repository Management Policy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove automated PR checks and required reviews while preserving the complete ASLRef suite behind one manually invoked release script.

**Architecture:** The merge path becomes deliberately ungated: the hosted workflow and CODEOWNERS routing are removed, documentation stops requiring PR validation or approval, and GitHub branch rules have no required checks or reviews. The release path remains fail-closed through `scripts/validate-release`, with release evidence and repository checkers updated to describe and verify that manual path.

**Tech Stack:** Bash, GNU Make, Python 3, JSON, Markdown, GitHub repository settings

## Global Constraints

- Do not change PTO ASL semantics, catalogs, profiles, or `.aslref-version`.
- Do not add a lightweight PR check or a replacement `pull_request`/`push` workflow.
- Do not require PR approval for any change class, including normative changes.
- Keep ASLRef canaries, strict checking, and executable tests available for manual release validation.
- Do not run ASLRef while implementing this governance change.
- Regenerate checked-in JSON from its owning generator; do not hand-edit generated release evidence.

---

### Task 1: Add the manual release-validation entry point

**Files:**
- Create: `scripts/validate-release`
- Modify: `Makefile`
- Modify: `scripts/check-repository`

**Interfaces:**
- Consumes: existing `make clean`, `make setup`, `make ci`, and `git diff --check` commands.
- Produces: executable `scripts/validate-release` and convenience target `make release-validate`.

- [ ] **Step 1: Add the release script**

```bash
#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo_root"

make clean
make setup
make ci
git diff --check
```

- [ ] **Step 2: Add the Make target**

Add `release-validate` to `.PHONY` and define:

```make
release-validate:
	./scripts/validate-release
```

- [ ] **Step 3: Make repository checks enforce the new policy shape**

Add `scripts/validate-release` to `required_files`, remove `.github/CODEOWNERS`, and fail release-time repository checking if CODEOWNERS exists or if any checked-in workflow contains a `pull_request` or `push` trigger.

- [ ] **Step 4: Verify the entry point without running ASLRef**

Run:

```bash
bash -n scripts/validate-release
make -n release-validate
```

Expected: Bash syntax passes and Make prints `./scripts/validate-release` without executing it.

### Task 2: Remove PR automation and reviewer routing

**Files:**
- Delete: `.github/workflows/asl.yml`
- Delete: `.github/CODEOWNERS`
- Modify: `.github/PULL_REQUEST_TEMPLATE.md`

**Interfaces:**
- Consumes: the approved zero-check, zero-approval policy.
- Produces: a PR surface with no automated workflow trigger, CODEOWNER request, evidence checkbox, or approval condition.

- [ ] **Step 1: Delete the hosted workflow and CODEOWNERS**

Delete both files without adding a no-op or manual-dispatch workflow.

- [ ] **Step 2: Replace the PR template**

Keep only `Summary`, `Architecture impact`, and `Known gaps` sections. State that validation and approval are not merge prerequisites and that release validation is run separately by the release manager.

- [ ] **Step 3: Verify the PR surface**

Run:

```bash
test ! -e .github/CODEOWNERS
test ! -e .github/workflows/asl.yml
! rg -n 'pull_request:|^[[:space:]]*push:' .github/workflows
```

Expected: all commands succeed and no workflow trigger is reported.

### Task 3: Rewrite human governance and contributor guidance

**Files:**
- Modify: `AGENTS.md`
- Modify: `GOVERNANCE.md`
- Modify: `CONTRIBUTING.md`
- Modify: `README.md`
- Modify: `docs/review-checklist.md`
- Modify: `.codex/skills/pto-asl/SKILL.md`

**Interfaces:**
- Consumes: `scripts/validate-release` and `make release-validate` from Task 1.
- Produces: consistent policy text separating ungated PR merge from manual release validation.

- [ ] **Step 1: Update agent and contributor instructions**

Remove per-change `make setup`/`make ci` requirements. Explain that development checks are optional and that release managers run `make release-validate` before publication.

- [ ] **Step 2: Rewrite governance enforcement and merge sections**

Remove CODEOWNERS, required hosted checks, and two-perspective merge review. State zero required PR checks and approvals, retain content/traceability obligations, and describe the manual release gate.

- [ ] **Step 3: Update README validation guidance**

Present `make release-validate` as the single full release command. Keep the lower-level Make target table as voluntary troubleshooting/development detail.

- [ ] **Step 4: Make the review checklist advisory**

Label review as optional guidance and replace hosted-check/approval release claims with manual-script evidence.

- [ ] **Step 5: Update the repo-local skill**

Change its quality gate from “for every change” to “for a release,” retain optional `make repo-check` iteration advice, and remove mandatory review language for PR completion.

- [ ] **Step 6: Scan for contradictory merge-policy text**

Run targeted `rg` searches for CODEOWNERS, required `validate`, hosted validation, required approval, and per-PR `make ci` language. Expected: no active policy text contradicts the new design.

### Task 4: Update generated release-governance evidence

**Files:**
- Modify: `scripts/generate-release-gate-readiness`
- Modify: `scripts/check-catalogs`
- Modify: `spec/evidence/maturity-closure.json`
- Modify: `docs/maturity-bringup-plan.md`
- Modify: `docs/maturity-stage-targets.md`
- Modify: `docs/coverage.md`
- Regenerate: `spec/evidence/release-gate-readiness.json`
- Regenerate: `spec/release-manifest.json`

**Interfaces:**
- Consumes: `scripts/validate-release`, `make release-validate`, zero hosted workflow, zero required approval.
- Produces: S6-T2 evidence with a manual release contract, nine retained external controls, no approvals, and no hosted-run fields.

- [ ] **Step 1: Replace workflow validation with release-script validation**

In the generator, remove CODEOWNERS/workflow source inputs and `validate_workflow()`. Add `scripts/validate-release`, validate its exact ordered commands, and emit `manual_release_contract` instead of `workflow_contract`.

- [ ] **Step 2: Remove required review and hosted-check evidence**

Set `required_approval_count` to `0`, remove the hosted-check external control, set `required_external_control_count` to `9`, emit an empty `approvals` array, and remove hosted-run candidate fields and hosted wording.

- [ ] **Step 3: Update release-gate schema assertions**

Change `scripts/check-catalogs` to require `manual_release_contract`, nine controls, zero approvals, and no hosted candidate fields.

- [ ] **Step 4: Align maturity evidence and explanatory documentation**

Change S6-T2 gaps and stage descriptions from local/hosted/approval requirements to a clean `make release-validate` result plus retained branch-control snapshot. Do not remove independent numeric-conformance or claim-hygiene work that is not a PR approval requirement.

- [ ] **Step 5: Regenerate owned artifacts**

Run:

```bash
scripts/generate-release-gate-readiness
scripts/generate-release-manifest
```

- [ ] **Step 6: Verify generators without ASLRef**

Run:

```bash
scripts/generate-release-gate-readiness --check
scripts/check-release-manifest
python3 -m py_compile scripts/generate-release-gate-readiness scripts/check-catalogs
```

Expected: generated evidence is fresh, release manifest matches, and Python parses.

### Task 5: Update GitHub branch policy

**Files:**
- External state: GitHub `main` branch protection or repository ruleset

**Interfaces:**
- Consumes: authenticated `gh` access to the repository remote.
- Produces: zero required status checks, zero required approving reviews, no CODEOWNER approval requirement, with unrelated protections preserved.

- [ ] **Step 1: Read repository identity and current rules**

Run `git remote get-url origin`, `gh auth status`, and read the branch-protection/ruleset APIs before changing state.

- [ ] **Step 2: Apply the narrow settings change**

Remove required status-check and pull-request-review requirements only. Preserve signed commits, linear history, conversation resolution, force-push/deletion protection, merge policy, and signoff settings where represented independently.

- [ ] **Step 3: Read back the settings**

Query the same API and record evidence that required check contexts are empty and required approving reviews are zero/absent.

### Task 6: Policy-focused completion verification

**Files:**
- Verify all modified files

**Interfaces:**
- Consumes: Tasks 1–5.
- Produces: evidence that the repository has no PR checks/review routing and retains a syntactically valid manual release gate.

- [ ] **Step 1: Run syntax and policy checks**

Run Bash/Python/JSON/Make parsing, targeted absence checks, generated-evidence checks, and `git diff --check`. Do not invoke `scripts/validate-release`, `make ci`, `make check`, `make test`, or `make toolchain-check`.

- [ ] **Step 2: Inspect the complete diff**

Confirm no ASL, catalog, profile, or ASLRef pin changed and no generated `build/` or `.cache/` file is tracked.

- [ ] **Step 3: Commit the implementation**

Stage only the policy implementation and plan, then commit with:

```bash
git commit -m "chore: move validation to manual releases"
```

## Execution note

Policy-focused verification passes without invoking ASLRef. Two broader
release checks remain blocked by repository state that predates this policy
change:

- `python3 scripts/check-catalogs` reports numeric-rounding source/hash drift;
- `scripts/check-release-manifest` reports the incomplete `TMA` to `TLSU`
  projection in the release-manifest generator.

The missing TLSU shard rename was repaired in the separate commit `1992b25`.
The remaining ISA projection and evidence-refresh work is deliberately outside
this governance change and will be surfaced by `make release-validate` before a
release is published.
