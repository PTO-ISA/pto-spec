# Formal review checklist

## Traceability

- Stable requirement IDs and PTO-owned source links are present.
- The ASL claims no more than the accepted PTO requirement and catalog.
- Requirement, definition, and test links are recorded in
  `spec/requirements.json`.
- Every accepted form or operation has a catalog entry, generated witness,
  semantic handler, and requirement/test trace.
- `release-traceability-readiness.json` regenerates without missing, duplicate,
  or stale rows across requirements, forms, operations, registers, traps,
  hooks, and ASL state roots.
- Composite state leaves are recursively inventoried, and every state root is
  classified as architectural state, an architectural abstraction, or
  verification-only instrumentation.
- Every open requirement or hook names its exact maturity blocker; no reference
  totality status is presented as target numeric or release conformance.

## Semantics

- Legal domains, results, visible state, faults, ordering, and profile scope are explicit.
- Reset state, ACR checks, access permissions, and architectural time are explicit.
- Concurrent memory candidates define program order, reads-from, coherence,
  from-read, preserved order, fences, atomicity, validity, and allowed outcomes.
- Fixed widths, integer constraints, indices, conversions, and aliases are type-safe.
- Every legal case is total; every nondeterministic case is intentional.
- Operand restrictions are catalog-owned, generated before effects, and have
  positive and negative witnesses where applicable.
- Verification-only bounds are not presented as architectural limits.
- Backend behavior is isolated from portable PTO semantics.

## Evidence

- Strict ASLRef type-checking passes at the pinned commit.
- Toolchain canaries pass, so parser, type-checker, interpreter, and diagnostic
  failures are known to be observable.
- Positive, boundary, negative-legality, and state-transition cases are covered where applicable.
- New semantic tests are listed in `ASL_TESTS` and therefore actually execute.
- The profile registry, all ASL `impdef` declarations, active
  `implementation func` overrides, and direct profile-test calls have exactly
  equal hook names.
- Numeric review distinguishes the deterministic PTO v0 raw-carrier contract
  from IEEE-754 or target-hardware behavior.
- Memory-model changes include both allowed and forbidden litmus outcomes and
  state whether mixed-size or overlapping accesses are modeled or rejected.
- Known coverage gaps and ASLRef limitations are disclosed.
- Release review records one immutable commit, reviewer identity, review date,
  and disposition; empty review fields keep S6-T1 open.
- `release-gate-readiness.json` keeps gate definitions distinct from candidate
  results and rejects a release claim while any local, hosted, external-control,
  or approval field is missing.
- Local and hosted results name the same signed candidate commit; passing CI on
  an earlier or moving branch head is not release evidence.
- The candidate records a GitHub protection/repository snapshot covering the
  required `PR / validate` check, administrator enforcement, signatures, linear
  history, conversation resolution, force-push/deletion protection, merge
  authority/method, and web signoff.
- Mnemonic spelling alone imports no semantics. Every retained rule must be
  stated in PTO ASL, catalog metadata, an accepted ADR, and executable tests.
- Toolchain updates are isolated from normative changes, and any canary fixture they change is explained.
- Publication additionally requires a successful manual `Release / validate`
  run naming the same exact candidate commit.
