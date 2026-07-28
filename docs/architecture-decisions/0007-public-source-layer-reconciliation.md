# ADR-0007: Reconcile public source and direct binary layers

- Status: Accepted
- Date: 2026-07-28
- Requirement: PTO-REQ-SOURCE-RECONCILIATION-001

## Context

The public PTO repository exposes a typed C++ intrinsic API, PTO-AS syntax, and
manual pages. This repository defines direct binary scalar forms and direct
tile selectors. Those layers describe related operations, but they are not
required to have identical operand lists, result carriers, or spelling.

The earlier anonymized tile cross-check recorded 97 agreements, 13 incomplete
source pages, and one conflict. It is valuable raw evidence, but its private
source cannot become a public normative dependency. The accepted 473 scalar
forms also need an honest disposition against the public source layer: the
public manual uses shared MLIR arithmetic and scalar/control operations rather
than promising a one-to-one source mnemonic for every binary form.

## Decision

The PTO ASL, canonical catalogs, and accepted architecture decisions remain
authoritative for the direct binary architecture. Public PTO source material is
pinned by commit and content hash as source-API and lowering evidence.

The machine-readable reconciliation ledger classifies every accepted scalar
form and tile operation. Its audited tile-symbol inventory is independent of
the local catalog and is bound to the pinned intrinsic-header hash, so a new
catalog operation fails closed until the public audit is repeated:

- all 473 scalar forms are closed as normative direct binary forms; no
  one-to-one public source mnemonic is required;
- 110 tile operations have the same public intrinsic spelling;
- `TSORT` maps to the public source spelling `TSORT32`;
- the 13 incomplete private observations are closed using public PTO sources
  and PTO-owned decisions; and
- the `TPREFETCH` conflict is closed by preserving destination-free direct
  architecture semantics while documenting the typed intrinsic's
  destination-shaped lowering context.

The raw private ledger is not edited to manufacture agreement. Its 97/13/1
counts remain visible, while the public ledger records 111 closed tile
dispositions and zero open source-reconciliation items.

Arm ASL and other ISA specifications remain review-only comparisons. A shared
mnemonic or familiar instruction shape does not import an external constraint,
fault, constrained-unpredictable choice, or ordering rule. ADR-0004 records the
PTO-owned load/store overlap rules selected after that comparison. The bounded
official-source review and its non-import decisions are recorded in
`docs/arm-asl-comparison.md`; it is not part of the public PTO source ledger.

## Consequences

- Reviewers can reproduce the public evidence from one pinned public PTO
  commit without access to private material.
- CI rejects missing rows, stale generated evidence, unpinned URLs, source-hash
  drift, and any reopened disposition.
- Source-level overloads and lowering-only operands cannot silently become
  binary architectural state.
- A public API change does not automatically change the binary ISA. It requires
  an explicit PTO architecture decision, catalog update, and executable tests.
