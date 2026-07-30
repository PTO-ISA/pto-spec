# Normative sources

This repository is the self-contained normative definition of the **PTO
Instruction Set Architecture**.

## Precedence

Sources are applied in this order:

1. Normative ASL, the selected PTO v0 implementation profile, and accepted
   architecture decisions in this repository.
2. PTO-owned machine-readable catalogs under `spec/catalog/`.
3. PTO-owned requirement, coverage, profile, and validation metadata under
   `spec/`.
4. Backend implementations and performance models, only as non-normative
   implementation evidence.

A lower-precedence source cannot override a higher-precedence source. The PTO
ASL and catalogs are the golden specification for accepted encodings and
architectural behavior.

## Normative catalogs

The scalar catalog contains 474 accepted forms across AGU, ALU, AMO, BRU, FSU,
and SYS. Every row has a stable PTO form ID, assembly grammar, instruction
width, semantic family/group, exact mask/match encoding, operand-field pieces,
signedness, form-local constraints, and semantic handler. The generated ASL
decoder provides a positive witness for every form and every operand
extraction.

The bundle/command catalog contains 107 accepted forms. It covers bundle start,
split, argument, dimension, control attribute, data attribute, scalar IO, tile
IO, hint, stop, and context-control forms. Vector-only bundle and queue forms are
not part of the PTO ISA. The retained `BSTART`, `BSTOP`, `B.*`, and BPC
spellings use `B` for bundle. Separately, `BLOCKNUM`, `BLOCKID`, and
`CROSS_BID` identify virtual core blocks rather than bundles.

The direct tile catalog contains exactly 120 operations: 98 TEPL, 9 TMA, and 13
CUBE. Allocated and reserved selectors are part of the PTO contract, and the
generated ASL selector decoder witnesses every accepted operation.

The system-register catalog defines 72 base, context-family, trap-snapshot,
translation, interrupt, and debug-register entries in a canonical 24-bit
address domain, plus 13 trap-number identities. The 18-entry `EBARG` range is
part of the visible context-family contract. Generated ASL witnesses validate
every register access class.

The numeric-profile identity catalog defines four stable configuration
identities and the accepted fail-closed selection boundary from ADR 0037. The
identity catalog does not define numeric results: its rule-status fields remain
open until the corresponding S5-T2 decisions and domain contracts are accepted.

Catalog changes are normative PTO changes and require the same review and
validation as ASL semantics.

## Active implementation profile

`spec/profile-hooks.json` names the active `pto-v0` profile and is the exact
registry for implementation-defined interfaces. Its entries must equal the ASL
`impdef` declarations, the `implementation func` overrides in
`asl/profiles/pto-v0.asl`, and the direct profile-test calls in
`tests/asl/profile-tests.asl`.

Hook implementation, numeric-contract ownership, and target conformance are
separate grades. PTO-v0 implements all registered hooks deterministically. The
registry marks eight non-numeric reference contracts closed. The checked
`spec/evidence/numeric-contracts.json` inventory closes `S5-T1` by assigning 19
scalar forms and 89 direct-tile operations to all 29 numeric hooks and a profile
owner. Those hooks remain open toward `S5-T2`; a direct PTO-v0 test does not
establish hardware or IEEE numeric conformance.

The profile fixes numeric, memory, ACR, time, and reset behavior. Its
deterministic raw numeric carrier is not an IEEE-754 claim. An alternative
profile cannot silently alter PTO v0; it needs a distinct identity, a complete
implementation of the registry, and conformance evidence for every replaced
interface.

## Instruction reference

`docs/instructions/` is generated from the canonical catalogs. It is
human-readable reference material, not a separate source of truth. Regenerate it
after changing instruction catalogs and keep the generated output fresh in the
same change.

## Architecture ownership

PTO operations execute directly against explicit scalar, bundle, memory, and tile
state. Bundle control state is visible through TPC, BPC, bundle active/body flags,
arguments, dimensions, IO bindings, and attributes. Direct tile operations have
explicit destinations, sources, dimensions, addresses, and attributes.

PTO has no vector instruction execution surface. Adding vector instructions or
target-specific behavior requires a new PTO requirement, catalog update, ASL
state and semantics, executable tests, and profile evidence.

## Evidence policy

Evidence files under `spec/evidence/` support audit and change control. They do
not outrank the PTO-owned ASL, catalogs, or accepted architecture decisions.
Do not publish non-public repository names, local paths, third-party prose,
source code, diagrams, or comparison-specific identities as normative PTO
material.

`scalar-effect-closure.json` is the fail-closed semantic-maturity ledger. Its
members are stable scalar form IDs, and its grades record executable decoded
before/after evidence rather than mnemonic or handler-name presence. Catalog
checks require every closed member to exist exactly once and require the stated
class total to agree with the 474-form inventory.

`scalar-agu-totality.json` is the Stage 4 address, completion, prefetch, alias,
fault, and restart contract. It derives exact inventories from all 183 AGU form
IDs and binds them to 1,464 decoded totality cases, 4,296 decoded alias cases,
and the retained 360 Stage 1 cases. Its independent executable-model comparison
is corroborating evidence only; ADR 0029 and the PTO ASL remain authoritative.

`scalar-alu-totality.json` is the Stage 4 ALU boundary and alias contract. It
binds the seven ALU effect classes and all 107 accepted ALU form IDs to reviewed
fixed-width boundary dimensions and Reg5 alias equivalence classes. Its 337 raw
decoded boundary cases and 35 decoded alias cases close `S4-T2`; pure helper
vectors alone would not satisfy that closure rule.

`scalar-bru-totality.json` is the Stage 4 BRU totality, alias, predicate, target,
and fault contract. It binds all six BRU effect classes and all 66 accepted form
IDs to 284 raw decoded totality cases and 32 decoded alias/fault obligations.
The evidence includes all Reg5 queue sources and destinations, bundle versus
non-bundle predicate selection, the ignored `JR.SrcZero` alias field, signed
halfword target limits and wrapping, odd-target trap context, and synchronized
return state. These executable cases and ADR 0027 close `S4-T4`.

`scalar-fsu-totality.json` is the Stage 4 FSU carrier, legality, boundary,
rounding-selection, Reg5-alias, sticky-flag, and fault contract. Its format-code
table names Stage 4 raw carriers without claiming target numerical encodings;
the recorded independent comparison is evidence, while PTO ASL and ADR 0028
remain authoritative.

`scalar-amo-totality.json` is the Stage 4 AMO modifier, value, Reg5-alias,
fault/restart, reservation, and DMA contract. It binds 2,474 unique decoded
Stage 4 attempts plus 66 retained Stage 1 attempts to ADR 0030. Its independent
comparison disposition corroborates shared value and reservation-line behavior;
PTO ASL remains authoritative for ordering, faults, restart, reservation
invalidation, Reg5 queues, and executable DMA behavior.

`maturity-closure.json` is the fail-closed stage ledger. It assigns every
target an owner, affected requirement IDs, current evidence, status, and—for
every non-closed target—tracked, classified gaps with explicit acceptance
evidence. The repository checker derives the cumulative maturity floor from
the contiguous closed stages and rejects disagreement with the plan, coverage,
README, requirement metadata, or `specification.toml`.

`numeric-contracts.json` is the fail-closed numeric ownership ledger. It
distinguishes primary portable-profile boundaries from PTO-v0 reference helpers,
binds every affected catalog identity to one numeric contract and owner, and
keeps every target-dependent arithmetic dimension explicitly open under
`S5-T2` until independent conformance evidence exists.

`numeric-conformance-readiness.json` is generated from that ownership ledger.
It partitions all 20 numeric domains, 29 hooks, and 108 affected operations
exactly once across six parallel lanes, records the ordered S5-T2 promotion
dependencies, and leaves profile, oracle, vector, differential-result, and
review fields explicitly empty until their evidence exists. Generation fails
if the inventory is missing, duplicated, stale, or prematurely claims
conformance.

`numeric-profile-decision-inputs.json` is the fail-closed input to S5-T2-A.
It pins 24 public contract and CPU/A2A3/A5 implementation-evidence sources,
classifies 12 unresolved architecture/profile questions, and links every one
of the 20 numeric domains to the exact questions and source evidence that must
be resolved. Implementation evidence exposes variation; it does not select a
PTO result rule. Every selected disposition and decision record remains null
until architecture review accepts it.

`numeric-profile-decision-proposals.json` imports the accepted identity catalog,
records the five accepted selection-framework rules, and proposes dispositions
for all 12 questions and 20 domains. Accepted identities do not imply accepted
numeric results; question and domain acceptance fields remain null.

`scalar-numeric-flag-contract.json` is generated from the scalar catalog and
numeric ownership ledger. ADR 0038 makes its flag storage, lifecycle, trap
envelope, and 30-form producer-owner partition normative. The ledger keeps 19
profile-owned flag conditions explicitly open and is not a target arithmetic
or independent-oracle claim.

`release-traceability-readiness.json` is the generated input to S6-T1. It
enumerates every requirement, accepted scalar and command form, direct tile
operation, system register, trap, profile hook, and top-level ASL state root.
Composite state types are recursively expanded so nested trap-context, bundle,
memory-event, system-register, and `TileInfo` fields cannot disappear silently.
Each unit links to one or more PTO requirements, model paths, executable
witnesses, and a bounded status. State classifications prevent memory-event
capture controls or other verification instrumentation from being published as
ISA registers. The ledger is evidence and claim-hygiene control; it does not
outrank the ASL, catalogs, or accepted architecture decisions.

`release-gate-readiness.json` is the generated input to S6-T2. It freezes the
clone-verifiable release commands, hosted workflow policy, parallel test
topology, external protected-branch obligations, and the two required review
perspectives separately from their future candidate-specific results. A green
run on a moving draft branch is not release evidence. Candidate commit,
clean-tree reproduction, hosted validation, branch-control snapshot, and
review fields remain empty until Stage 5 and S6-T1 close and one immutable
signed candidate can be reviewed.

Where evidence and PTO-owned semantics disagree, the PTO ASL and catalogs
prevail after a reviewed architecture decision.
