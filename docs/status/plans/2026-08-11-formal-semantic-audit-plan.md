# PTO Formal Implementation Closure Plan

## Status

The mnemonic audit is complete and frozen at 634/634 active mnemonics and
40/40 occupied reservations. Accepted ADR-family coverage counts as mnemonic
review coverage. This plan now tracks the later ASL, documentation, and test
implementation closure only; it MUST NOT be used to reduce or recompute the
frozen audit count.

## Goal

Complete the formal definition of every active PTO mnemonic and every reserved
encoding directly in the owning ASL units. ASL is the only authored
architecture source. Catalogs, instruction pages, navigation, tests, evidence,
and release artifacts are projections or checks of that source.

## Review unit

Review one mnemonic at a time. Each review covers these subjects:

1. canonical assembly;
2. encoding and field domains;
3. omitted-field defaults;
4. operation and result definition;
5. architectural state reads and writes;
6. memory effects;
7. ordering and atomicity;
8. faults and before-effects rejection; and
9. assigned and reserved encoding space.

The source-free review record is embedded in the mnemonic's ASL owner:

```text
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
```

Allowed outcomes are `FORMAL-COMPLETE`, `FORMAL-INCOMPLETE`, `AMBIGUOUS`, and
`RESERVED`. A review record contains no repository, document, branch, commit,
blob, or human-source provenance.

## Formal repair rule

- If an ASL owner is complete and internally consistent, record
  `FORMAL-COMPLETE` without changing its meaning.
- If a required subject is absent, record `FORMAL-INCOMPLETE` and add an NDF
  issue describing only the missing PTO contract.
- If two PTO clauses conflict or a choice is not derivable, record
  `AMBIGUOUS` and stop that mnemonic until the architecture decision is made.
- If an encoding is intentionally unavailable, define its mask, match,
  rejection, and ownership in PTO ASL and record `RESERVED`.
- Never fill a PTO gap by citing or importing a second instruction source.

## Execution order

1. Finish block lifecycle, operand binding, attributes, and commit-state units.
2. Review scalar mnemonics by their existing ASL subcategories.
3. Review Tile mnemonics by VEC, TLSU, CUBE, and SFU engine ownership.
4. Review arch units for data types, register state, memory, faults, encoding
   ownership, and instruction classification.
5. Resolve each incomplete or ambiguous PTO contract through its linked NDF
   issue, then update ASL first.
6. Regenerate catalogs, pages, navigation, AVS points, traceability evidence,
   and the release manifest.

## Formal implementation closure gates

Formal implementation is complete only when:

- every active mnemonic has one source-free review record;
- every extension reservation has one source-free `RESERVED` record;
- every record covers all nine review subjects;
- no active ADR, NDF record, plan, or ASL owner cites another instruction
  source;
- generated instruction pages and catalogs are fresh;
- lightweight repository checks pass; and
- the manual release workflow succeeds for the exact clean commit.

Use:

```bash
python3 scripts/manual_semantic_audit.py --allow-incomplete
make pr-check
make repo-check
```

The first command reports ASL formal-implementation progress while incomplete
owners remain. It does not report mnemonic-audit coverage. Formal release is
blocked until the same implementation-closure check passes without
`--allow-incomplete`.
