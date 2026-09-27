# PTO release operations

Use this contract only for an explicitly requested release verification or
publication. Release is a cautious cloud operation, separate from ordinary
pull-request merge work.

## Freeze one exact candidate

- Merge every known PTO-SPEC fix first. Freeze the exact PTO-SPEC commit and
  verify its checked-in NDF and ASLRef pins.
- Do not dispatch against a commit that is about to be replaced, a dirty
  candidate, an open fix branch, or a partially updated dependency graph.
- Record the candidate once and use it consistently in the workflow dispatch,
  monitoring, failure report, evidence download, tag, and release.
- LLVM/ASL-MODEL integration and site publication have independent checks in
  their owning workflows. They are not PTO-SPEC release inputs or evidence.

## Dispatch manually and singly

- The operator may be an agent. An already authorized release task does not
  require a second human confirmation; it still requires a verified candidate.
- Release verification runs in the protected GitHub Actions release workflow.
  Dispatch it manually for the frozen PTO-SPEC commit.
- Never dispatch a second release while any release for the active candidate is
  queued or in progress. A queued run is already an active attempt.
- Never put release dispatch, rerun, tagging, or publication authority into a
  heartbeat, scheduler, or monitoring automation. Monitoring may be read-only.
- Never automatically rerun a failed job or workflow. A new attempt is allowed
  only after the completed failure set has been reviewed and all real defects
  are closed.

## Wait for the complete result

- Let the entire workflow reach a terminal state before starting repairs. Do
  not react to the first failed job while other independent jobs are running.
- After completion, collect every failed job, failed step, log, annotation, and
  missing artifact. Separate specification defects, coverage gaps, test flakes,
  infrastructure failures, and stale or mismatched component inputs.
- Start from the workflow's preflight and diagnostics artifacts. Diagnostic
  uploads can be partial; their existence never establishes a passing gate.
- Treat repeated failures from the same tuple as evidence that the retry policy
  is wrong, not as a reason for another blind run.

## Fix once, then run once

- Close the whole known failure set through ordinary pull requests. Keep those
  merges lightweight and do not use release workflows as PR checks.
- Re-freeze the PTO-SPEC commit after the final merge and perform one fresh
  manual GitHub Actions release attempt.
- If that attempt fails, repeat the complete-result audit. Do not dispatch
  again until every known real failure from the completed run is addressed.

## Publish only exact success

- Publication requires the final `Release / validate` job to succeed for the
  exact frozen PTO-SPEC commit, with every required artifact present and verified.
- Run `scripts/prepare-release-publication --run-id RUN_ID --output build/publication-RUN_ID`
  to retrieve and verify the completed hosted run. Follow the JSON next action;
  retain its handoff and checksums with the permanent release evidence. This is
  read-only preparation and does not grant publication authority.
- Revalidate the hosted run immediately before the authorized publication step.
  Use actual published metadata to emit the PTO-only release-event v2; never
  invent a release ID/time for a candidate. Preserve historical release-event
  v1 validation without filling its model digest with invented evidence.
- Create the signed immutable tag and GitHub Release only after that success.
  Never reuse a partial, stale, cancelled, skipped, failed, or different-commit
  result.

## Keep monitoring economical

- Poll compact status and act only on a terminal result or meaningful state
  transition. Do not stream unchanged job lists or narrate every poll.
- Prefer one durable record of the candidate tuple, run ID, complete failure
  set, fixes, and final evidence over repeated broad status scans.
