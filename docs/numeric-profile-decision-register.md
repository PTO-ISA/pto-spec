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
- 12 cross-cutting architecture or profile questions remain open.
- Every one of the 20 numeric-contract domains is linked to its exact S5-T2
  lane, operation keys, hooks, open dimensions, questions, and evidence.
- Four versioned numeric configuration identities and five fail-closed
  selection-framework rules are accepted by ADR 0037.
- All 12 question dispositions and all 20 domain-to-profile mappings have
  review proposals, but no question or domain result rule is accepted. Their
  acceptance-record fields remain null.
- ADR 0038 and `spec/evidence/scalar-numeric-flag-contract.json` close the
  scalar flag state/lifecycle and assign all 30 FSU forms to one producer
  owner. Eleven architecture-owned flag conditions are exact; 19
  profile-owned conditions keep PD-06 open.
- ADR 0039 and `spec/evidence/numeric-rounding-selector-contract.json` close
  selector discovery and ownership for PD-03: eight active scalar codes, five
  fixed conversion overrides, eight bundle `RMode` codes, four external
  selector classes, 18 domains, 102 operations, and 25 hooks. All domain
  rounding and saturation-order rules remain open.
- ADR 0040 and `spec/evidence/numeric-format-namespace-contract.json` close
  the PD-02 namespace/carrier checkpoint: five separate code spaces, all 19
  raw-carrier widths, every mapped/reserved code, and low-nibble-first packing
  for all four 4-bit types. Eight format, exceptional-value, legality,
  target-availability, and vector residuals remain open.
- The current maturity floor remains M4. This register improves decision
  readiness; it does not close `S5-T2-A` or numeric conformance.

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
| `PD-01` | Portable results plus named support restrictions and bounded target variations | Complete the applicability matrix for the accepted identities; keep CPU observational |
| `PD-02` | ADR 0040 fixes five separate code namespaces, all 19 raw-carrier widths, reserved rejection, and packed four-bit order; numeric meanings remain profile-bound | Resolve bit-exact floating meanings, exceptional values, the complete operation/type/profile legality matrix, target availability, and positive/reserved vectors |
| `PD-03` | Selector namespaces and owners fixed by ADR 0039; portable core is RNE/RTZ/RTP/RTM | Decide active codes 4–7, map named bundle/public/matrix/stochastic controls, and define all domain rounding and saturation-order rules |
| `PD-04` | Named input/result subnormal rules selected by visible mode state or a fixed target profile | Define reset, lifetime, transitions, operation applicability, and unknown-mode rejection |
| `PD-05` | Bit-exact special-value rules or an enumerated target result set | Choose canonicalization/payload, signaling, infinity, signed-zero, and flag interactions |
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
| `PD-02` | Numeric format encodings and availability | ADR 0040 closes structural namespace/carrier ownership, but public and backend surfaces still conflict or remain incomplete for FP8, FPL8, FP4, FPL4, E8M0, exceptional values, and target support. | Bit-exact format table, complete operation/type/profile legality matrix, target availability, and positive/reserved vectors |
| `PD-03` | Rounding taxonomy, selection, and ties | ADR 0039 inventories every known selector namespace and owner. Scalar RNE/RTM/RTP/RTZ plus fixed FCVT overrides are structurally bound; active codes 4–7 and all cross-namespace/domain result mappings remain decisions. | Accepted per-domain mapping, saturation order, and signed halfway vectors for all 18 affected domains |
| `PD-04` | Subnormal handling, FTZ, and mode state | Default FTZ, target controls, and selected explicit subnormal paths coexist. | Input/result FTZ rules plus reset, visibility, lifetime, and override behavior for mode state |
| `PD-05` | NaN, infinity, signed zero, and payloads | Quieting, propagation, sentinel, payload, infinity, and signed-zero behavior is not defined uniformly across operations. | Bit-exact special-value table covering every numeric family |
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
The PD-02, PD-03, and PD-06 structural checkpoints do not accept any complete
result decision. `S5-T2-A` closes only when all 12 decisions and each of the 20 domain
rows have an accepted profile rule and decision record. Only then
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
make repo-check
```
