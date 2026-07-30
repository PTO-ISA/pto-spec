# Normative sources

This repository is the self-contained normative definition of the **PTO
Instruction Set Architecture**.

## Precedence

Sources are applied in this order:

1. Portable normative ASL and accepted architecture decisions in this
   repository, excluding the result values of named `impdef` implementations.
2. PTO-owned machine-readable catalogs under `spec/catalog/` and, for a
   hardware numeric claim, `spec/hardware-conformance-profile.json`.
3. The selected `pto-v0` implementation profile, only for its explicitly named
   deterministic reference-test identity.
4. PTO-owned requirement, coverage, release, and validation metadata under
   `spec/`.
5. Backend implementations and performance models, only as non-normative
   implementation evidence.

A lower-precedence source cannot override a higher-precedence source. The PTO
ASL and catalogs are the golden specification for accepted encodings and
portable architectural behavior. The hardware numeric profile refines named
numeric boundaries without turning the raw-carrier ASL implementation into a
hardware oracle.

## Normative catalogs

The scalar catalog contains 474 accepted forms across AGU, ALU, AMO, BRU, FSU,
and SYS. Every row has a stable PTO form ID, assembly grammar, instruction
width, semantic family/group, exact mask/match encoding, operand-field pieces,
signedness, form-local constraints, and semantic handler. The generated ASL
decoder provides a positive witness for every form and every operand
extraction.

The block/command catalog contains 99 accepted forms. It covers block start,
split, argument, dimension, control attribute, data attribute, scalar IO, tile
IO, hint, stop, and context-control forms. Vector-only block and queue forms are
not part of the PTO ISA.

The direct tile catalog contains exactly 120 operations: 98 TEPL, 9 TMA, and 13
CUBE. Allocated and reserved selectors are part of the PTO contract, and the
generated ASL selector decoder witnesses every accepted operation.

The system-register catalog defines 54 base, context-family, translation,
interrupt, and debug-register entries in a canonical 24-bit address domain,
plus 13 trap-number identities. Generated ASL witnesses validate every register
access class.

Catalog changes are normative PTO changes and require the same review and
validation as ASL semantics.

## Active implementation profile

`spec/profile-hooks.json` names the active `pto-v0` profile and is the exact
registry for implementation-defined interfaces. Its entries must equal the ASL
`impdef` declarations, the `implementation func` overrides in
`asl/profiles/pto-v0.asl`, and the direct calls in
`tests/asl/profile-tests.asl`.

The profile fixes numeric, memory, ACR, time, and reset behavior. Its
deterministic raw numeric carrier is not the PTO ISA 0.57.1 IEEE-754 hardware
conformance profile. A profile cannot silently alter PTO v0; it needs a
distinct identity, a complete implementation of the registry, and conformance
evidence for every replaced interface.

## Hardware numeric profile

`spec/hardware-conformance-profile.json` is the machine-readable authority for
PTO ISA 0.57.1 hardware numeric claims. It freezes exact low-precision raw
encodings, distinct DataType identities, logical packed-lane order, available
canonical NaNs, signed-zero behavior, B.DATR comparison/round/saturation/
canonicalization rules, integer conversion indefinite values, reductions,
stable 32-element TSORT, and ordinary/MX matrix types, scaling, bias, ACC, and
publication order. Its identity is distinct from `pto-v0`.

The repository generates
`spec/evidence/pto-isa-0571-hardware-numeric-vectors.json` and binds its profile
hash into the release manifest. These files define conformance tests; they do
not report a passing hardware implementation. A downstream conformance claim
requires the exact profile ID and release hash plus independent execution and
effect evidence.

## Instruction reference

`docs/instructions/` is generated from the canonical catalogs. It is
human-readable reference material, not a separate source of truth. Regenerate it
after changing instruction catalogs and keep the generated output fresh in the
same change.

## Architecture ownership

PTO operations execute directly against explicit scalar, block, memory, and tile
state. Block control state is visible through TPC, BPC, block active/body flags,
arguments, dimensions, IO bindings, and attributes. Direct tile operations have
cataloged explicit operands and declared implicit state such as ACC, dimensions,
addresses, and attributes.

PTO has no vector instruction execution surface. Adding vector instructions or
target-specific behavior requires a new PTO requirement, catalog update, ASL
state and semantics, executable tests, and profile evidence.

## Evidence policy

Evidence files under `spec/evidence/` support audit and change control. They do
not outrank the PTO-owned ASL, catalogs, hardware conformance profile, or
accepted architecture decisions.
Do not publish non-public repository names, local paths, third-party prose,
source code, diagrams, or comparison-specific identities as normative PTO
material.

Where evidence and PTO-owned semantics disagree, the PTO ASL and catalogs
prevail after a reviewed architecture decision.
