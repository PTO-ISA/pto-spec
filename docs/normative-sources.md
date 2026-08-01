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

PTO ISA 0.57.1 is the architecture release identity. `pto-v0` is the active
executable reference profile. These identities are independent: the release
selects the Mode/Function encoding ABI, while the profile supplies deterministic
reference implementations for registered hooks. ADR 0045 defines that boundary.

## Normative catalogs

The scalar catalog contains 474 accepted forms across AGU, ALU, AMO, BRU, FSU,
and SYS. Every row has a stable PTO form ID, assembly grammar, instruction
width, semantic family/group, exact mask/match encoding, operand-field pieces,
signedness, form-local constraints, and semantic handler. The generated ASL
decoder provides a positive witness for every form and every operand
extraction.

The bundle/command catalog contains 99 accepted forms. It covers bundle start,
split, argument, dimension, control attribute, data attribute, scalar IO, tile
IO, hint, stop, and context-control forms. Vector-only bundle and queue forms are
not part of the PTO ISA. The retained `BSTART`, `BSTOP`, `B.*`, and BPC
spellings use `B` for bundle. Separately, `BLOCKNUM`, `BLOCKID`, and
`CROSS_BID` identify virtual core blocks rather than bundles.

The direct tile catalog contains exactly 120 operations: 98 TEPL, 9 TMA, and 13
CUBE. Allocated and reserved selectors are part of the PTO contract, and the
generated ASL selector decoder witnesses every accepted operation. CUBE
operations use implicit architectural ACC state as defined by function identity;
ACC is not an ordinary B.IOT tile operand.

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
scalar forms and 89 direct-tile operations to all 30 numeric hooks and a profile
owner. Those hooks remain open toward `S5-T2`; a direct PTO-v0 test does not
establish hardware or IEEE numeric conformance.

The profile fixes numeric, memory, ACR, time, and reset behavior. Its
deterministic raw numeric carrier is not an IEEE-754 claim. An alternative
profile cannot silently alter PTO v0; it needs a distinct identity, a complete
implementation of the registry, and conformance evidence for every replaced
interface.

The separately named `pto-hardware-numeric-0.57.1-ieee-v1` record is a normative
hardware numeric contract, not the active ASL implementation profile. It fixes
format, packed-lane, special-value, rounding, conversion, matrix, and ACC
requirements. Its checked-in vectors define conformance inputs and expected
boundaries; they do not prove hardware, RTL, emulator, or model parity.
`S5-T2` remains open until independent results and review accept those claims.

## Release identity and manifest

`specification.toml` names the 0.57.1 release and its encoding ABI.
`spec/release-manifest.json` is a generated content-addressed projection of the
normative inputs. A draft manifest documents identity and reproducibility; it is
not Stage 6 release evidence. Candidate status requires regeneration from one
signed immutable commit, hosted validation of that same commit, repository
control evidence, and both required review perspectives.

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
The evidence includes all Reg5 queue sources and destinations, MPAR/MSEQ
execution-mask versus commit-argument branch selection, the ignored
`JR.SrcZero` alias field, signed
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
It partitions all 20 numeric domains, 30 hooks, and 108 affected operations
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
for all 12 questions and 20 domains. PD-03 and PD-04 carry accepted decision
records; the other ten questions and all complete domain rules remain open.

`scalar-numeric-flag-contract.json` is generated from the scalar catalog and
numeric ownership ledger. ADR 0038 makes its flag storage, lifecycle, trap
envelope, and 30-form producer-owner partition normative. The ledger keeps 19
profile-owned flag conditions explicitly open and is not a target arithmetic
or independent-oracle claim.

`numeric-rounding-selector-contract.json` is generated from the scalar and
bundle catalogs, accepted profile identities, and numeric decision inputs.
ADR 0039 makes selector discovery and namespace separation normative. ADR 0047
completes PD-03 by accepting the scalar reserved-code fallback, fixed-mnemonic,
bundle, and public translations; exact tie behavior; operation defaults; all
18 domain rounding points; and rounding-before-saturation order. PD-02 and
PD-05 through PD-12 continue to own every other numeric result dimension.

`numeric-subnormal-contract.json` is generated from the accepted PD-04 record,
hardware profile, numeric-domain inventory, format classifier, and independent
comparison ledger. ADR 0049 fixes input preservation, gradual underflow,
after-rounding tininess, and the absence of FTZ/DAZ state or operation override
for `pto-hardware-numeric-0.57.1-ieee-v1`. Its 95 operation rows expand to
1,045 conditional operation/type obligations across eleven subnormal-capable
formats. The conditions do not create operation/type support, do not change
`pto-v0`, and are not Stage 5 arithmetic-conformance vectors.

`numeric-special-value-contract.json` is generated from ADR 0050, the hardware
profile, the format classifier, scalar FP MIN/MAX and comparison contracts, and
an independently reviewed executable ISA model. That model corroborates only
the shared FP32/FP64 subset: the comparison model returns `+0` for
`FMAX(-0, -0)`, whereas PTO preserves `-0`; the equal-negative-zero result is
therefore an intentional PTO-owned divergence rather than independent
corroboration. The contract records three accepted PD-05-SC2 special-value
rules: produced NaNs are canonical, tile comparison NaN and signed-zero results
are fixed, and scalar/tile MIN/MAX NaN and signed-zero results are fixed. The
eight operation identities expand to 154
conditional operation/type rows. These rows require separate profile support,
do not alter `pto-v0`, and do not close PD-05, any complete numeric domain, or
the generic PD-12 variation-route ledger.

`numeric-format-namespace-contract.json` is generated from the accepted ASL
carrier types, scalar and command catalogs, TMA closure ledger, pinned public
evidence, and independent model comparison. ADR 0040 makes the five namespace
boundaries, all 25 raw-carrier identities, mapped/reserved code tables, and
packed 4-bit order normative. ADR 0048 adds the executable value-class
checkpoint: all 25 formats have a typed class, four internal encoding
constraints are checked, and all ten NaN-capable formats have canonical NaN
encodings. Operation-specific exceptional-value results, flags, the
complete legality matrix, target availability, and independent vectors remain
explicit PD-02/PD-05 work.

`public-numeric-type-baseline.json` is generated from the pinned public type,
target-profile, and portability sources plus the closed namespace inventory.
ADR 0043 makes all 16 published type identities, 11 unambiguous catalog
bindings, and the 11-type A2/A3 / 16-type A5 availability baseline normative.
It leaves six catalog names unbound and seven bit-exact format, legality, and
vector residuals open. Its independent-model comparison is structural only and
supplies no PTO type binding or numeric result.

`public-integer-conversion-contract.json` is generated from the pinned public
type-system lines, the accepted public type baseline, the numeric ownership
inventory, and executable PTO witnesses. ADR 0044 makes its three result rules
and 48 unequal-width public integer `TCVT` tuples normative, conditional on a
profile accepting the tuple. The pinned independent vector-conversion
comparison is algorithmic corroboration only: its type codes, predicates,
packing, and support rules are not PTO authority. Same-width and floating
conversions, legality, rounding, saturation, exceptional values, and flags
remain open.

`numeric-profile-applicability-closure.json` is generated from the profile
applicability catalog, direct tile catalog, PD-02 namespace ledger, pinned
public profile evidence, public intrinsic inventory, and independent structural
comparison. ADR 0041 makes six A2/A3 MX CUBE unsupported rules normative for
all 25 `TileDataType` identities. The comparison is selector/decode
corroboration only; it does not define MX arithmetic or close `cube-matrix`.

`numeric-variation-point-ownership.json` is generated from the closed numeric
inventory, decision inputs, profile identities, hook registry, selector and
format contracts, and accepted applicability slice. ADR 0042 makes the 99-row
variation-point inventory and current portable decision owner normative. Its
admissible routes are review choices, not accepted results: all selected-route,
result-rule, and result-acceptance fields remain null.

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
