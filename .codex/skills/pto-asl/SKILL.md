---
name: pto-asl
description: Use in pto-spec for normative ASL1 changes and reviews, mnemonic ASL/docs/AVS closure, ASLRef or validation tooling, and formal-spec governance. Do not load the full normative workflow for unrelated repository maintenance.
---

# PTO ASL

Keep PTO architectural meaning singular, executable, and traceable without
turning every repository task into a release exercise.

## Route before reading

Always read `AGENTS.md` and the files you will change. Then select the smallest
matching lane:

- **Repository maintenance**: inspect only the affected tooling, docs, and
  tests. Do not preload ASL owners, ADRs, or release evidence unless the change
  can alter their contract.
- **Normative modeling or semantic review**: start from the linked NDF issue,
  affected `PTO-*` clauses, owning ASL, matching AVS points, and relevant ADR
  index entries. Read [formal-quality.md](references/formal-quality.md).
- **Mnemonic authoring or readability refactor**: also read
  [arm-style.md](references/arm-style.md).
- **ASLRef, language, pin, or runner work**: read
  [aslref.md](references/aslref.md).
- **Migration or source reconciliation**: read
  [source-map.md](references/source-map.md).
- **Agent PR preparation, dependent PR, rebase, or merge closeout**: read
  [pr-closeout.md](references/pr-closeout.md). Use `scripts/prepare-pr` for the
  final commit handoff; one independent agent reviews the exact inputs. Reuse
  fresh checks and reject stale receipts instead of repeating whole gates.
- **Release verification or publication**: read
  [release-operations.md](references/release-operations.md).

Read `GOVERNANCE.md`, `CONTRIBUTING.md`, status records, and release evidence
only when the selected lane needs those contracts. A review may combine lanes;
ordinary maintenance should not.

## Decide whether an ADR is needed

Default to the existing owner. ASL/NDF/test/documentation corrections do not
receive a new ADR when the public interface is already decided. Reuse and amend
the topic ADR that owns the interface. Allocate a new ADR only for a genuinely
new externally visible decision boundary with no current owner, and set
`interface_change=true` before implementation. For the complete allocation
test, classification table, filename contract, and examples, read
[adr-governance.md](references/adr-governance.md).

## Preserve these invariants

Current semantics: owning ASL/NDF -> generated mirror -> AVS -> commit-scoped evidence.
Decision history: ADR index -> affected ASL/NDF.

- Never infer or add semantics without an explicit architecture requirement.
  Record an architecture decision gap instead.
- Treat mnemonic ASL metadata and `DOC-BEGIN` regions as golden. Generated
  Markdown, catalogs, decoder witnesses, coverage, and release evidence are
  projections; regenerate them and never hand-edit generated decoder output.
- Keep portable PTO semantics free of unnamed target or backend behavior and
  preserve the one-level architecture model.
- For accepted instructions, preserve exact encoding, operand, constraint,
  selector, decoder-witness, semantic-handler, and state-transition coverage.
- Keep executable points under the exact `tests/asl/{arch,block,scalar,tile}`
  mirror, with one stable ID and one observable purpose per file. Generated
  exhaustive coverage remains one case per result file.
- Never weaken a validator, canary, or check to make a change pass. Keep
  generated `build/` and `.cache/` content untracked.

## Work incrementally

1. Classify the change and state whether architectural meaning may change.
2. Inspect the smallest owner and existing evidence that can answer the task.
3. For new behavior, add the smallest focused test and observe the intended
   failure before editing the owner.
4. Make the smallest owner change. Separate normative, toolchain, governance,
   and mechanical changes.
5. Regenerate only affected projections while iterating.
6. Run focused checks first; run broader gates once the candidate is stable.

For a normative instruction change, close the ASL owner, generated catalog and
decoder witness, exact Markdown mirror, and independent AVS points together.
Regenerate NDF traceability and coverage with those surfaces. Successful parse
or execution alone does not prove architectural correctness.

For a frozen mnemonic audit, continue until
`python3 scripts/manual_semantic_audit.py` reports every active mnemonic and
occupied reservation `FORMAL-COMPLETE`; an audit-review count is not
implementation evidence.

## Choose validation by scope

- During iteration, run the smallest affected generator check, script test, or
  exact ASL IDs. Select focused ASL points with
  `scripts/print-asl-test-matrix --ids-file` and run the emitted page with
  `scripts/run-asl-page -j`.
- For an existing pull request whose task is review-and-merge, use the hosted
  required checks already attached to its exact head. Do not repeat local
  repository, site, matrix, or release gates unless a concrete failure needs
  reproduction or the user explicitly asks for additional validation.
- For implementation work, finish with the smallest local check that proves
  the changed contract. Avoid repeatedly running broad gates while the branch
  is changing.
- Release authority comes only from the operator-initiated exact-commit
  GitHub Actions release workflow. Local release commands may diagnose a
  failure but never authorize publication or trigger another release attempt.

Report fresh evidence for the selected lane and any remaining architecture
decision or validation gap. Do not claim release readiness from a partial,
stale, pending, skipped, failed, or different-commit run.

## Review output

Lead with correctness findings and exact file/line evidence. Distinguish
specification defects, ASLRef/tool limitations, missing architecture decisions,
and non-normative maintenance observations.
