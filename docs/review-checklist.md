# Formal review checklist

## Traceability

- Stable requirement IDs and public source links are present.
- The ASL claims no more than the normative source.
- Requirement, definition, and test links are recorded in `docs/traceability.md`.

## Semantics

- Legal domains, results, visible state, faults, ordering, and profile scope are explicit.
- Fixed widths, integer constraints, indices, conversions, and aliases are type-safe.
- Every legal case is total; every nondeterministic case is intentional.
- Verification-only bounds are not presented as architectural limits.
- Backend behavior is isolated from portable PTO semantics.

## Evidence

- Strict ASLRef type-checking passes at the pinned commit.
- Positive, boundary, negative-legality, and state-transition cases are covered where applicable.
- Known coverage gaps and ASLRef limitations are disclosed.
- Toolchain updates are isolated from normative changes.
