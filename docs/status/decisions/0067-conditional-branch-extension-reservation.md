# ADR 0067: conditional branch extension reservation

- Status: accepted
- Scope: `B.EQ`, `B.NE`, `B.LT`, `B.GE`, `B.LTU`, `B.GEU`, `B.Z`, `B.NZ`
- Requirement: PTO-ARCH-CONDITIONAL-BRANCH-RESERVATION-001
- Supersedes: only the active-PTO conditional-branch clauses of ADR 0008,
  ADR 0027, and ADR 0046

## Decision

The eight named conditional branch families are not active PTO instructions.
Their complete 32-bit encoding forms are occupied extension space. PTO scalar
decode rejects every matching form before operand reads or architectural
effects, and PTO assembly/disassembly does not expose their spellings.

This reservation does not remove scalar comparison, `SETC.*`, `J`, `JR`, or
the block commit-target mechanisms. It changes no encoding outside the eight
reserved families.

## Rationale

The forms belong to the two-level block-body architecture. Keeping them in the
active PTO scalar catalog would contradict that ownership boundary and allow a
PTO implementation to consume extension encodings that must remain
collision-protected.
