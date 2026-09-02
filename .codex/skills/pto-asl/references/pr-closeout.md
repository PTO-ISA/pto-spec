# PTO dependent PR and merge closeout

Use this contract when a PTO-ASL task updates an existing pull request, depends
on another active pull request, rebases after a predecessor lands, or is asked
to merge without performing a release.

## Resolve dependencies before editing

- Recover the requested task before searching the repository broadly. Resolve
  the exact task title to its pull request, writable source branch, isolated
  worktree, current head, base branch, and dependency order. If several pull
  requests are active, write down this mapping first and ignore unrelated
  worktrees and pull requests.
- Inventory active pull requests that touch the same ASL owners, NDF clauses,
  generated projections, or evidence inputs. Treat shared ownership as a
  dependency decision, not as a conflict to discover at final merge time.
- Choose and state the landing order. Base a dependent branch on the reviewed
  head of its predecessor when it consumes that predecessor's semantics. After
  the predecessor lands, rebase once onto the new `main`, resolve the owning
  sources, and regenerate projections from the reconciled tree.
- Keep one isolated worktree per pull request. Record the task title, pull
  request number, source branch, worktree, base commit, and predecessor head in
  the task update so a continuation can recover the exact lane without
  searching unrelated sessions or worktrees.
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
  When repository policy requires an ADR baseline to equal its first-landing
  parent, this ordering keeps the baseline outside the mutable PR history.
- Do not point an ADR baseline at an earlier implementation commit in the same
  rewriteable pull request. Rebase, squash preparation, or commit signing would
  invalidate that self-reference.
- Finalize commit ordering and signatures before generating any projection
  whose content depends on commit identity. Avoid rewriting history after that
  generation pass; if a rewrite is unavoidable, refresh the commit-sensitive
  projection once from the final history and rerun its owning check.

## Iterate narrowly, close once

- During implementation, run exact mnemonic/family points and the smallest
  owning generators that prove the current change. Do not repeatedly run full
  PR gates while the candidate is still changing.
- After the final rebase and reconciliation, regenerate ASL-derived docs,
  catalogs, decoder witnesses, AVS points, traceability hashes, and other
  checked-in projections consumed by the requested PR lane. Run `make
  pr-check`, `make repo-check`, and `git diff --check` once on that stable
  candidate.
- A local gate and a hosted required check prove different things; keep both.
  Improve caching or path selection rather than weakening either correctness
  contract.

## Keep elapsed time attributable

- Record timestamps for task recovery, local reconciliation, final validation,
  push, hosted-check wait, merge, and post-merge verification. This makes later
  duration summaries evidence-based and separates active engineering time from
  CI queue or execution time.
- Report critical-path time separately from parallel or unrelated activity.
  Do not charge time spent inspecting another pull request, the site lane, or a
  release lane to the requested merge.
- When a check is slow, wait on the exact current head and required-check set.
  Avoid repeated broad status scans; poll compactly and act only when state
  changes or a concrete failure appears.

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
  path when available. Wait for fresh required checks for that head; never use
  stale results from the pre-rebase commit. Poll required checks compactly and
  intervene only on a concrete failure.
- Classify a hosted failure before changing code: distinguish a real in-scope
  regression from cancellation, stale-head results, infrastructure failure, or
  an advisory workflow outside the requested lane. Rerun or repair only the
  failing contract that can affect the requested merge.
- Verify completion from the merged PR state and the resulting `main` commit.
  Do not infer success merely because a push or merge command returned without
  output, and do not touch unrelated pull requests or dirty worktrees.

## Efficient closeout sequence

1. Resolve the task-to-PR/branch/worktree mapping and record the start time.
2. Confirm scope exclusions, dependency order, exact base, exact head, and
   required checks.
3. Reconcile the requested branch once; finalize commit order and signatures.
4. Regenerate only projections owned by the final tree and run the required
   local gates once on that stable candidate.
5. Push the writable source branch with an exact lease when history changed.
6. Wait only for fresh required checks attached to that exact head, then merge
   through the normal protected path.
7. Verify the pull request is merged and `main` contains the expected merge or
   squash commit; record the end time and leave unrelated lanes untouched.
