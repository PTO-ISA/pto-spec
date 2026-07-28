# Formal review checklist

## Traceability

- Stable requirement IDs and public source links are present.
- The ASL claims no more than the normative source.
- Requirement, definition, and test links are recorded in `docs/traceability.md`.

## Semantics

- Legal domains, results, visible state, faults, ordering, and profile scope are explicit.
- Reset state, privilege checks, access permissions, and architectural time are explicit.
- Fixed widths, integer constraints, indices, conversions, and aliases are type-safe.
- Every legal case is total; every nondeterministic case is intentional.
- Family-wide operand restrictions are catalog-owned, generated before effects,
  and have positive and negative application witnesses.
- Verification-only bounds are not presented as architectural limits.
- Backend behavior is isolated from portable PTO semantics.

## Evidence

- Strict ASLRef type-checking passes at the pinned commit.
- The gate self-test and toolchain canaries pass, so the checks above are known to be capable of failing.
- Positive, boundary, negative-legality, and state-transition cases are covered where applicable.
- New semantic tests are listed in `ASL_TESTS` and therefore actually execute.
- The profile registry, all ASL `impdef` declarations, active
  `implementation func` overrides, and direct profile-test calls have exactly
  equal hook names.
- Numeric review distinguishes the deterministic PTO v0 raw-carrier contract
  from IEEE-754 or target-hardware behavior.
- Known coverage gaps and ASLRef limitations are disclosed.
- Toolchain updates are isolated from normative changes, and any canary fixture they change is explained.
