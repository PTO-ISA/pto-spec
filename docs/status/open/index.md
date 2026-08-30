<!-- GENERATED FILE: run scripts/generate-adr-index; do not edit. -->
# Open architecture decisions

Draft numeric decisions are generated from ADR records. They are review inputs and do not define architecture semantics or promote maturity.

Implementation, AVS, validation, and release stages are derived in the [architecture-readiness projection](../../../spec/evidence/architecture-readiness.json).

## [ADR-0086: Numeric profile applicability](../decisions/0086-numeric-profile-applicability.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Affected model contracts: not assigned
- Blockers:
  - Complete every remaining domain operation/type applicability table after the accepted A2A3 MX negative slice.
  - Accept one portable or target disposition for every supported and rejected tuple.

## [ADR-0087: Numeric format legality](../decisions/0087-numeric-format-legality.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Affected model contracts: not assigned
- Blockers:
  - Bind the specialized floating raw carriers and decide the public roles of F64 and E8M0.
  - Publish bit-exact payload fields and exceptional-value classes for every floating type.
  - Complete the scalar and tile operation/type legality matrix.
  - Resolve the E5M2/E5M3FN spelling conflict.
  - Publish positive and negative target-availability vectors for every accepted tuple.

## [ADR-0088: Numeric special values](../decisions/0088-numeric-special-values.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Affected model contracts: not assigned
- Blockers:
  - Extend bit-exact NaN creation rules beyond comparison and min/max.
  - Define infinity arithmetic and special results for conversions, reductions, quantization, and matrix operations.
  - Complete signaling-NaN flag and status interactions for every affected family.

## [ADR-0089: Numeric exception flags](../decisions/0089-numeric-exception-flags.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Affected model contracts: not assigned
- Blockers:
  - Accept exact flag conditions for all 19 profile-owned scalar forms.
  - Define tininess detection and NX coupling in every affected operation/type rule.
  - Publish independent simultaneous-flag and special-value vectors.

## [ADR-0090: Conversion range results](../decisions/0090-conversion-range-results.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Affected model contracts: not assigned
- Blockers:
  - Complete the source/destination/rounding/saturation cross-product.
  - Resolve the public CPU-saturation versus implementation default-OFF conflict.
  - Choose overflow, NaN, and infinity results.
  - Define non-saturating narrowing, wrap behavior, and omitted-saturation defaults per profile/type pair.

## [ADR-0091: Elementary-function accuracy](../decisions/0091-elementary-function-accuracy.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Affected model contracts: not assigned
- Blockers:
  - Choose the oracle and version.
  - Set per-operation/type/profile error bounds.
  - Define domain boundaries and monotonic intervals.

## [ADR-0092: Reduction order and stability](../decisions/0092-reduction-order-and-stability.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Affected model contracts: not assigned
- Blockers:
  - Freeze accumulator widths and trees.
  - Define argument and equal-value ties.
  - Bound floating permutation sensitivity and partial merges.

## [ADR-0093: Quantization contract](../decisions/0093-quantization-contract.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Affected model contracts: not assigned
- Blockers:
  - Resolve whether the affine parameter is scale or inverse-scale/pre-quant multiplier.
  - Freeze format-specific equations and stochastic-rounding state.
  - Define group axes, sizes, and tails.
  - Define sentinels, packing, round-trip tolerances, and whether `SET_QUANT` configuration is architectural state.

## [ADR-0094: Matrix numeric contract](../decisions/0094-matrix-numeric-contract.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Affected model contracts: not assigned
- Blockers:
  - Complete the legal type-tuple table.
  - Freeze dot-product, HF32/TF32 selection, and accumulation arithmetic.
  - Resolve the public A5 MX E4M3-only versus implementation FP4/mixed-FP8 conflict.
  - Define MX scale layout, logical versus capacity K multiples, and non-A5 rejection.

## [ADR-0095: Bounded numeric variation](../decisions/0095-bounded-numeric-variation.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Affected model contracts: not assigned
- Blockers:
  - Select one admissible route for every non-portable variation point.
  - Populate a bounded allowed-result contract for every selected delegation.
  - Add unknown-profile, unknown-mode, and missing-rule rejection vectors.
