# Numeric profile decision register

This register is the human review surface for `S5-T2-A`. It identifies the
numeric architecture choices that must be accepted before PTO can qualify an
independent oracle or publish target-conformance vectors. It does not choose
numeric results from an implementation.

The generated
`../spec/evidence/numeric-profile-decision-inputs.json` ledger is the
machine-readable source of truth. It is derived against the pinned public PTO
contract and implementation-evidence revision already used by source
reconciliation. The PTO ASL, catalogs, and accepted architecture decisions
remain authoritative.

## Current result

- 24 content-addressed public evidence sources were reviewed: three published
  contract sources and 21 CPU, A2A3, or A5 implementation sources.
- 12 cross-cutting architecture or profile questions remain open.
- Every one of the 20 numeric-contract domains is linked to its exact S5-T2
  lane, operation keys, hooks, open dimensions, questions, and evidence.
- No target profile identity or domain rule has been selected.
- The current maturity floor remains M4. This register improves decision
  readiness; it does not close `S5-T2-A` or numeric conformance.

## Profile partitions requiring a decision

| Partition input | Role | Current status |
| --- | --- | --- |
| Portable numeric contract | Results shared by every conforming target | Identity and rules required |
| CPU observation | Implementation-under-test evidence and developer diagnostics | Not an oracle |
| A2A3 target | Candidate named target profile | Identity and rules required |
| A5 target | Candidate named target profile | Identity and rules required |

A support restriction and a result-semantic difference are not the same
thing. A target may reject a type or operation through a named profile. If it
accepts an operation but produces a target-dependent result, that result needs
a named profile rule or an explicit, bounded implementation-defined result
set.

## Open decision questions

| ID | Decision required | Evidence finding | Closure target |
| --- | --- | --- | --- |
| `PD-01` | Profile identity and support-versus-semantics boundary | Published profiles are described as support narrowing, but the numeric contract also permits target-dependent results. | Versioned profile taxonomy and complete domain-to-profile applicability matrix |
| `PD-02` | Numeric format encodings and availability | Public and backend surfaces span IEEE, BF16, FP8, specialized eight-bit, four-bit, and integer carriers with different target availability. | Bit-exact format table and complete operation/type legality matrix |
| `PD-03` | Rounding taxonomy, selection, and ties | Public prose names four directional modes; backend paths expose additional round, odd, part, and saturation combinations. | Exact encoding and operation mapping with positive and negative halfway vectors |
| `PD-04` | Subnormal handling, FTZ, and mode state | Default FTZ, target controls, and selected explicit subnormal paths coexist. | Input/result FTZ rules plus reset, visibility, lifetime, and override behavior for mode state |
| `PD-05` | NaN, infinity, signed zero, and payloads | Quieting, propagation, sentinel, payload, infinity, and signed-zero behavior is not defined uniformly across operations. | Bit-exact special-value table covering every numeric family |
| `PD-06` | Scalar numeric exception flags | The formal model exposes NV, DZ, OF, UF, and NX, but the public contract lacks a complete production and priority table. | Producer, simultaneous-flag, stickiness, reset, and trap-preservation rules |
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

When all 12 decisions are accepted, `S5-T2-A` may close and each domain row in
the generated ledger must contain a profile rule and decision record. Only then
may `S5-T2-B` qualify an independent oracle for each numeric lane. Oracle,
vector, result, adjudication, and review evidence remain separate promotion
gates.

Regenerate and validate the decision inputs with:

```bash
scripts/generate-numeric-conformance-readiness --check
scripts/generate-numeric-profile-decision-inputs --check
make repo-check
```
