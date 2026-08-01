# Numeric profile decision register

This register is the human review surface for `S5-T2-A`. It identifies the
numeric architecture choices that must be accepted before PTO can qualify an
independent oracle or publish target-conformance vectors. It does not choose
numeric results from an implementation.

The generated input ledger
`../spec/evidence/numeric-profile-decision-inputs.json` is the
machine-readable source of truth for the questions and their evidence. The
generated proposal ledger
`../spec/evidence/numeric-profile-decision-proposals.json` adds a complete,
reviewable disposition and domain mapping without accepting it. Both are
derived against the pinned public PTO contract and implementation-evidence
revision already used by source reconciliation. The PTO ASL, catalogs, and
accepted architecture decisions remain authoritative.

## Current result

- 24 content-addressed public evidence sources were reviewed: three published
  contract sources and 21 CPU, A2A3, or A5 implementation sources.
- Two of 12 cross-cutting architecture or profile questions are accepted;
  ten remain open.
- Every one of the 20 numeric-contract domains is linked to its exact S5-T2
  lane, operation keys, hooks, open dimensions, questions, and evidence.
- Four versioned numeric configuration identities and five fail-closed
  selection-framework rules are accepted by ADR 0037.
- All 12 question dispositions and all 20 domain-to-profile mappings have
  review proposals. PD-03 and PD-04 have accepted decision records; no complete
  domain result rule is accepted.
- ADR 0038 and `spec/evidence/scalar-numeric-flag-contract.json` close the
  scalar flag state/lifecycle and assign all 30 FSU forms to one producer
  owner. Eleven architecture-owned flag conditions are exact; 19
  profile-owned conditions keep PD-06 open.
- ADRs 0039 and 0047 and
  `spec/evidence/numeric-rounding-selector-contract.json` close PD-03: eight
  scalar raw values, five fixed conversion overrides, eight bundle `RMode`
  codes, seven public conversion values, four external selector classes, 18
  domains, 102 operations, and 25 hooks. All domain rounding points and
  saturation-order rules are accepted; other numeric dimensions remain open.
- ADR 0049 and `spec/evidence/numeric-subnormal-contract.json` close PD-04 for
  `pto-hardware-numeric-0.57.1-ieee-v1`: eleven formats preserve input
  subnormals, produce subnormals by gradual underflow, detect tininess after
  rounding, and expose no FTZ/DAZ mode or operation override. The generated
  contract covers 16 domains, 95 operations, and 1,045 conditional
  operation/type rows without creating support or changing `pto-v0`.
- ADR 0050 and `spec/evidence/numeric-special-value-contract.json` add the
  bounded PD-05-SC2 checkpoint for the named hardware profile: produced NaNs
  are canonical, tile comparison NaN/signed-zero results are fixed, and
  scalar/tile MIN/MAX NaN/signed-zero results are fixed. The generated
  contract covers three accepted special-value rules across eight operations
  and 154 conditional operation/type rows. It is conditional on separate
  support, does not change `pto-v0`, and does not close PD-05.
- ADR 0040 and `spec/evidence/numeric-format-namespace-contract.json` close
  the PD-02 namespace/carrier checkpoint: five separate code spaces, all 25
  raw-carrier widths, every mapped/reserved code, and low-nibble-first packing
  for all five packed four-bit types.
- ADR 0048 and `asl/numeric/formats.asl` close the shared PD-02/PD-05
  value-class checkpoint: all 25 formats are classified, four internal
  encoding constraints reject invalid carriers, and all ten NaN-capable
  formats have canonical NaNs. Operation-specific propagation, flags,
  legality, and target results remain open.
- ADR 0043 and `spec/evidence/public-numeric-type-baseline.json` close the
  next PD-02 checkpoint: all 16 published type identities, 16 accepted catalog
  bindings, and public availability for 11 A2/A3 and 16 A5 types. Nine catalog
  types remain outside the public inventory, and four legality, vector, parity,
  and review residuals remain open. No complete domain rule is accepted.
- ADR 0044 and `spec/evidence/public-integer-conversion-contract.json` close
  `S5-T2-A6`: three portable rules determine all 48 unequal-width public
  integer `TCVT` results. Profile support remains a separate open decision;
  six same-width, floating, support, overflow/saturation, rounding/flag, and
  conformance-vector residuals keep PD-07 open.
- ADR 0041 and `spec/evidence/numeric-profile-applicability-closure.json`
  close one PD-01 applicability checkpoint: A2/A3 rejects the six MX CUBE
  selectors for every `TileDataType` before effects. All result rules and the
  rest of the applicability matrix remain open.
- ADR 0042 and `spec/evidence/numeric-variation-point-ownership.json` close
  PD-12 discovery and current-owner assignment: 99 stable variation points
  cover all 20 domains, 108 operations, and 30 hooks. Eighteen rounding routes
  are selected; the hardware profile is not yet a generic PD-12 selection
  identity, so the PD-04 contract does not silently claim another route.
- The current maturity floor remains M4. This register improves decision
  readiness; it does not close `S5-T2-A` or numeric conformance.

The machine-derived closure snapshot is 2 accepted and 10 open decisions,
0 accepted and 20 open complete domain rules, and 18 selected and 81 open
variation routes.

## Profile partitions requiring a decision

| Partition input | Accepted identity | Role | Current status |
| --- | --- | --- | --- |
| Portable numeric contract | `pto-numeric-v1` | Results and pre-effect rejection rules shared by every conforming target | Identity accepted; rules open |
| CPU observation | `pto-cpu-observation-v1` | Implementation-under-test evidence and developer diagnostics | Identity accepted; never an oracle |
| A2A3 target | `pto-a2a3-numeric-v1` | Support restrictions and explicitly bounded variation points | Identity accepted; rules open |
| A5 target | `pto-a5-numeric-v1` | Support restrictions and explicitly bounded variation points | Identity accepted; rules open |

A support restriction and a result-semantic difference are not the same
thing. A target may reject a type or operation through a named profile. If it
accepts an operation but produces a target-dependent result, that result needs
a named profile rule or an explicit, bounded implementation-defined result
set.

ADR 0037 applies one fail-closed rule everywhere: an unknown profile,
numeric mode, format, operation/type tuple, or missing numeric rule rejects
before architectural effects. A backend default is not an architectural
default.

## Proposed dispositions for review

These rows are proposals, not accepted PTO semantics. The generated ledger
contains the complete affected-domain, source, residual-evidence, and null
acceptance-record fields.

| ID | Proposed disposition | Review target |
| --- | --- | --- |
| `PD-01` | ADR 0041 fixes the A2/A3 unsupported-in-profile MX CUBE slice; portable results plus other named support restrictions and bounded target variations remain open | Complete the full applicability matrix for the accepted identities; keep CPU observational |
| `PD-02` | ADRs 0040 and 0048 fix five separate code namespaces, all 25 raw-carrier identities and value classes, reserved/internal rejection, packed four-bit order, and ten canonical NaNs | Resolve operation-specific format results, exceptional-value propagation, the complete operation/type/profile legality matrix, target availability, and positive/reserved vectors |
| `PD-03` | Accepted by ADR 0047: separate scalar/fixed/bundle/public mappings, RNE/RTM/RTP/RTZ/RNA/RTO/RHB ties, operation defaults, 18 domain rounding points, and round-before-saturation | Closed; retain PD-02 and PD-05 through PD-12 boundaries for formats, exceptional values, flags, range results, accuracy, quantization, and matrix detail |
| `PD-04` | Accepted by ADR 0049 for `pto-hardware-numeric-0.57.1-ieee-v1`: preserve input subnormals, gradual underflow, after-rounding tininess, no FTZ/DAZ state, and no operation override | Closed for the named profile; support legality and Stage 5 oracle/vector/result/review evidence remain separate |
| `PD-05` | ADR 0048 fixes format-level NaN, infinity, signed-zero, subnormal, and canonical-NaN classification; ADR 0050 fixes the named-hardware produced-canonical-NaN, comparison NaN/signed-zero, and MIN/MAX NaN/signed-zero checkpoint across eight operations and 154 conditional rows | Complete infinity arithmetic, broader NaN creation, conversions, reductions, quantization, matrix results, and full flag/status behavior |
| `PD-06` | Portable sticky NV/DZ/OF/UF/NX state; lifecycle and producer owners fixed by ADR 0038 | Accept exact flag conditions and independent vectors for all 19 profile-owned forms |
| `PD-07` | Deterministic conversion, enumerated target result set, or pre-effect rejection | Eliminate unbounded overflow; complete saturation-on/off/default and narrowing tables |
| `PD-08` | Versioned independent oracle with per-profile error bounds | Set accuracy, domains, monotonicity, and special-value rules per operation/type |
| `PD-09` | Exact integer/order rules plus exact or bounded floating reduction trees | Freeze widths, ordering, ties, NaNs, zeros, overflow, and partial merges |
| `PD-10` | Format-specific equations; reject formats without a complete profile rule | Define scaling, grouping, tails, packing, sentinels, clamping, and inverse behavior |
| `PD-11` | Type-tuple/profile matrix with explicit product and accumulation arithmetic | Define rounding, saturation, bias/source-accumulator order, MX scales, and exceptions |
| `PD-12` | Every variation point has a named selector and testable allowed set | Define discovery and reject unknown profiles, modes, and absent rules |

## Open decision questions

| ID | Decision required | Evidence finding | Closure target |
| --- | --- | --- | --- |
| `PD-01` | Profile identity and support-versus-semantics boundary | Published profiles are described as support narrowing, but the numeric contract also permits target-dependent results. | Versioned profile taxonomy and complete domain-to-profile applicability matrix |
| `PD-02` | Numeric format encodings and availability | ADRs 0040 and 0048 close namespace/carrier ownership and value classification for all 25 types, but public bindings, operation results, legality, and target support remain incomplete. | Complete operation/type/profile legality and result matrices, target availability, and positive/reserved vectors |
| `PD-03` | Rounding taxonomy, selection, and ties | ADR 0047 accepts scalar reserved values 4–7 as RNE fallback, fixed FCVT overrides, bundle/public translations, seven exact semantic modes, operation defaults, and all 18 domain rounding and saturation-order rules. | Closed by ADR 0047 and executable signed halfway, reserved-code, public-translation, operation-default, and saturation-carrier witnesses |
| `PD-04` | Subnormal handling, FTZ, and mode state | ADR 0049 fixes input preservation, gradual underflow, after-rounding tininess, and the absence of architectural FTZ/DAZ state for the named hardware profile. | Closed by the generated eleven-format boundary table, eight configuration cases, 95-operation applicability matrix, and executable ASL assertions |
| `PD-05` | NaN, infinity, signed zero, and payloads | ADR 0048 classifies every encoding and fixes canonical NaNs. ADR 0050 accepts produced canonical NaNs, comparison NaN/signed-zero results, and MIN/MAX NaN/signed-zero results for the named hardware profile, but broader NaN creation, infinity arithmetic, conversions, reductions, quantization, matrix results, and full flag/status behavior remain incomplete. | Bit-exact operation-result table covering every numeric family |
| `PD-06` | Scalar numeric exception flags | ADR 0038 closes CORE_STATE storage, reset, sticky OR, software replacement, rejection, no-numeric-trap, trap recovery, and all 30 producer owners. | Exact NV/DZ/OF/UF/NX conditions, simultaneous cases, tininess/NX coupling, and independent vectors for 19 profile-owned forms |
| `PD-07` | Conversion overflow, saturation, wrap, and indefinite results | Public hardware overflow may be undefined while CPU paths may saturate; target paths also expose non-saturating wrap and control combinations. | Deterministic result or explicit bounded result set for the complete conversion cross-product |
| `PD-08` | Elementary-function accuracy and domains | CPU and target paths use different libraries, intrinsics, or approximations. Shared names do not prove equal results. | Correct-rounding rule or profile-specific error bound, plus domain and monotonicity vectors |
| `PD-09` | Reduction width, order, ties, and stability | Reduction trees and optimized grouping differ; selected integer reductions widen and later narrow. | Accumulation/order contract, allowed-result set if needed, and permutation/tie/overflow evidence |
| `PD-10` | Quantization and dequantization scale contract | Multiple format, shared-exponent, scale, zero-point, clamping, packing, and sentinel paths exist. | Format equations and group, tail, special-value, clamp, packing, and round-trip vectors |
| `PD-11` | Matrix product, accumulation, bias, and MX arithmetic | CPU host/FMA behavior, hardware matrix paths, and A5 MX scaling do not define one common arithmetic contract. | Legal type tuples and exact product, accumulator, rounding, saturation, bias, scale, and exception rules |
| `PD-12` | Bounded implementation-defined behavior | Target variation is permitted without a complete allowed-result set or discovery contract. | Named selector or visible mode, bounded results, and unknown-profile or missing-rule rejection |

## Decision acceptance rule

Each question closes only through an accepted PTO architecture decision that:

- names the portable rule, target-profile rule, bounded
  implementation-defined rule, or unsupported profile disposition;
- lists every affected numeric domain, operation/type combination, and visible
  mode or selector;
- defines bit-exact results or a finite/testable allowed-result or error-bound
  contract;
- links normal, boundary, exceptional, rounding, saturation, reduction, and
  accumulation vectors as applicable;
- states whether hardware capture is required and why a software arithmetic
  oracle is insufficient; and
- updates the formal profile implementation without changing `pto-v0`
  silently.

Implementation evidence can reveal choices and conflicts. It cannot select
the PTO rule by itself. The CPU implementation is under test, and the existing
independent executable comparison validates identities and bounded structural
semantics rather than numeric differential results.

## Promotion path

The four identities and five selection-framework rules close `S5-T2-A1`.
The exhaustive variation-point ownership inventory closes `S5-T2-A4` without
accepting a result rule.
The public type baseline closes `S5-T2-A5`, and the conditional 48-tuple
integer-conversion result subset closes `S5-T2-A6`; neither accepts a complete
numeric domain rule or target support matrix.
The PD-01 negative-applicability checkpoint and the PD-02, PD-05, and PD-06
structural checkpoints do not accept complete result decisions. ADR 0050 adds
three bounded PD-05 special-value rules but likewise does not close a complete
decision or domain. PD-03 is the first accepted numeric decision and selects
18 rounding variation routes. The accepted-decision count remains 2/12 with
ten open decisions, 0/20 complete domains, and 18/99 selected generic
variation routes. `S5-T2-A` closes only when all 12 decisions and each of the
20 domain rows have an
accepted profile rule and decision record. Only then
may `S5-T2-B` qualify an independent oracle for each numeric lane. Oracle,
vector, result, adjudication, and review evidence remain separate promotion
gates.

Regenerate and validate the decision inputs with:

```bash
scripts/generate-numeric-conformance-readiness --check
scripts/generate-numeric-profile-decision-inputs --check
scripts/generate-numeric-profile-decision-proposals --check
scripts/generate-scalar-numeric-flag-contract --check
scripts/generate-numeric-rounding-selector-contract --check
scripts/generate-numeric-format-namespace-contract --check
scripts/generate-public-numeric-type-baseline --check
scripts/generate-public-integer-conversion-contract --check
scripts/generate-numeric-profile-applicability-closure --check
scripts/generate-numeric-variation-point-ownership --check
make repo-check
```
