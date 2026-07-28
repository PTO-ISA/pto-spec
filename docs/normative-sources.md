# Normative sources

This repository is the self-contained golden definition of the **PTO
Instruction Set Architecture**.

## Precedence

Sources are applied in this order:

1. Normative ASL, the selected PTO v0 implementation profile, and accepted
   architecture decisions in this repository.
2. PTO-owned machine-readable scalar and tile catalogs under `spec/catalog/`.
3. The public PTO ISA manual and public `PTO_INST` declarations.
4. An anonymized private tile-document snapshot as independent cross-check evidence.
5. Backend implementations as non-normative executable evidence.
6. Public specifications for other ISAs as review-only design comparisons.

A lower-precedence source cannot override a higher-precedence source. Conflicts
are resolved by an architecture decision or remain explicitly incomplete in
`spec/evidence/independent-tile-crosscheck.json`.

## Golden catalog

The scalar catalog contains 473 accepted forms across AGU, ALU, AMO, BRU, FSU,
and SYS. Every row has a stable PTO form ID, assembly grammar, instruction width,
semantic family/group, exact mask/match encoding, operand-field pieces,
signedness, form-local constraints, and catalog-selected family constraints.
The generated ASL decoder provides a positive witness for every form, every
operand extraction, every current family-rule application, and its checked ASL
semantic handler. Negative witnesses prove every declared constraint can reject.

The system-register catalog defines 52 base, context-family, and debug-register
entries in a canonical 24-bit address domain, plus 13 trap-number identities.
Generated ASL witnesses validate every register access class.

The direct tile catalog contains exactly 111 operations: 97 TEPL, 6 TMA, and
8 CUBE. Allocated and reserved selectors are part of the PTO contract, and the
generated ASL selector decoder witnesses every accepted operation.

Neither catalog depends on an external repository or release label. Changes to
them are normative PTO changes and require the same review and validation as ASL
semantics.

## Active implementation profile

`spec/profile-hooks.json` names the active `pto-v0` profile and is the exact
registry for implementation-defined interfaces. Its 34 entries must equal the
ASL `impdef` declarations, the `implementation func` overrides in
`asl/profiles/pto-v0.asl`, and the direct calls in
`tests/asl/profile-tests.asl`. The profile fixes numeric, memory, privilege,
time, and reset behavior; its deterministic raw numeric carrier is not an
IEEE-754 claim. ADR-0005 records the selection and replacement rules.

An alternative profile cannot silently alter PTO v0. It needs a distinct
identity, a complete implementation of the registry, and conformance evidence
for every replaced interface.

## External ISA comparison

Arm ASL and other public ISA specifications may be used to identify questions
that PTO must answer, such as load/store destination and writeback overlap. A
shared mnemonic or design pattern does not import the other ISA's constraint,
fault, constrained-unpredictable choice, or execution order. Any retained rule
must be stated in PTO-owned architecture text, represented in the PTO catalog or
ASL, and covered by PTO tests. ADR-0004 applies this policy to scalar family
constraints.

## One-level execution

PTO operations execute directly against explicit scalar, memory, and tile
operands. The architecture has no nested programmable tile or vector body,
implicit body dispatch, body-local register file, or body replay state.

TEPL, TMA, and CUBE operations have explicit destinations, sources, dimensions,
addresses, and attributes. Selector identities are normative; implementation
command queues and pipelines are not.

## Independent evidence policy

The independent reference is private and has no project-wide redistribution
license. The cross-check records only anonymized document names, hashes, and
review dispositions. No project identity, repository path, prose, source, or
diagram from that reference is copied here.

Where independent evidence and PTO disagree, the canonical PTO ASL and catalogs prevail.
The current explicit conflict is TPREFETCH: PTO defines a destination-free hint
that performs applicable address checks but writes no tile state.
