# PTO dependent PR and merge closeout

Use this contract when a PTO-ASL task updates an existing pull request, depends
on another active pull request, rebases after a predecessor lands, or is asked
to merge without performing a release.

## Resolve dependencies before editing

- Recover the requested task before searching the repository broadly. Resolve
  the exact pull request, writable source branch, current head, base branch,
  and only the dependencies that can affect its merge.
- Inventory active pull requests that touch the same ASL owners, NDF clauses,
  generated projections, or evidence inputs. Treat shared ownership as a
  dependency decision, not as a conflict to discover at final merge time.
- Choose and state the landing order. Base a dependent branch on the reviewed
  head of its predecessor when it consumes that predecessor's semantics. After
  the predecessor lands, rebase once onto the new `main`, resolve the owning
  sources, and regenerate projections from the reconciled tree.
- Use an isolated worktree only when the pull request needs edits. A clean
  review-and-merge request does not require a local checkout or local test run.
- Never let two parallel pull requests create competing normative meanings for
  the same owner. The later pull request must consume or explicitly supersede
  the earlier accepted rule.

## Lock the requested scope

- Translate the user's boundary into an explicit lane before running commands.
  Examples include: merge only the named pull request; do not inspect or modify
  other pull requests; do not browse or validate the documentation site; do not
  run release preparation, publish artifacts, tag, or create a release.
- Use the smallest evidence set that proves that lane. A merge request normally
  needs the pull request metadata, exact source head, required checks,
  branch-protection state, merge result, and resulting `main` commit. It does
  not automatically authorize release or site work.
- When the user narrows the task after work has started, stop any now-out-of-
  scope investigation and preserve the narrower boundary through completion.
- Keep unrelated dirty worktrees, branches, and pull requests read-only. Do not
  clean them up as incidental work.

## Keep decision provenance stable

- Prefer an accepted ADR/NDF decision record as the first change on the stable
  pre-change base, followed by ASL implementation and independent evidence.
  The decision baseline must resolve and be an ancestor of the first-landing
  parent; it is not required to equal that parent.
- Do not point an ADR baseline at an earlier implementation commit in the same
  rewriteable pull request. Rebase, squash preparation, or commit signing would
  invalidate that self-reference.
- Finalize commit ordering and signatures before generating any projection
  whose content depends on commit identity. Avoid rewriting history after that
  generation pass; if a rewrite is unavoidable, refresh the commit-sensitive
  projection once from the final history and rerun its owning check.

## Keep merge closeout lightweight

- For a new or edited change, use `scripts/prepare-pr --base origin/main --head HEAD`
  after commits are final. `--json` provides the exact input and reviewer
  template; `--inspect-working-tree` provides only a preliminary edit plan.
- Hand the final input to one independent reviewer agent. Validate its returned
  receipt with `--review FILE` and keep the execution record with PR evidence.
  A different input requires fresh review. Agent executions may share a GitHub
  account; local reviewer IDs are not authenticated identities or GitHub approvals.
- A merge-only request normally needs only exact PR/head identity,
  mergeability, commit-signature state when required, hosted branch-protection
  checks, the merge result, and the resulting `main` commit.
- Do not run `make pr-check`, `make repo-check`, site builds, ASL matrices,
  model closure, or release preparation merely to merge an already validated
  pull request.
- If a required hosted check fails, inspect and reproduce only that failure.
  Do not expand into unrelated advisory workflows.
- Poll compactly and report state transitions. Do not narrate unchanged checks
  or repeatedly fetch broad status.

## Merge only the requested lane

- Before investigating a hosted failure, distinguish required branch-protection
  checks from advisory workflows. Required checks gate the merge. Treat a
  non-required site, nightly, or release failure as a separate follow-up unless
  the user asked for that lane or the failure demonstrates an in-scope
  specification defect.
- Preserve explicit scope such as "merge, do not release". Do not run
  release verification, create tags or releases, publish a site, or expand the
  task merely because those workflows exist.
- Push only the intended PR source branch, using an exact force-with-lease when
  a reviewed rebase requires history replacement. Re-resolve the PR head ref;
  do not confuse a locally fetched `pull/<n>/head` alias with the writable
  source branch.
- After the exact head is pushed, enable the repository's normal auto-merge
  path when available. Wait only for checks required by branch protection for
  that head; never wait for advisory work unless its failure is in scope.
- Classify a hosted failure before changing code: distinguish a real in-scope
  regression from cancellation, stale-head results, infrastructure failure, or
  an advisory workflow outside the requested lane. Rerun or repair only the
  failing contract that can affect the requested merge.
- Verify completion from the merged PR state and the resulting `main` commit.
  Do not infer success merely because a push or merge command returned without
  output, and do not touch unrelated pull requests or dirty worktrees.

## Efficient closeout sequence

1. Resolve the exact pull request, head, base, mergeability, and required checks.
2. If no edit is needed, merge through the normal protected path without local
   checkout or validation.
3. If an edit is needed, make the smallest change, run only its focused check,
   sign and push the final head once.
4. Wait only for fresh branch-protection checks, then merge.
5. Verify the merged state and resulting `main` commit.
