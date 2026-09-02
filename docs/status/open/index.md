<!-- GENERATED FILE: run scripts/generate-adr-index; do not edit. -->
# Open architecture decisions

Draft numeric decisions are generated from ADR records. They are review inputs and do not define architecture semantics or promote maturity.

Implementation, AVS, validation, and release stages are derived in the [architecture-readiness projection](../../../spec/evidence/architecture-readiness.json).

## [ADR-NUM-0013: Numeric profile applicability](../decisions/ADR-NUM-0013-numeric-profile-applicability.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Blockers:
  - Complete every remaining domain operation/type applicability table after the accepted A2A3 MX negative slice.
  - Accept one portable or target disposition for every supported and rejected tuple.

## [ADR-NUM-0014: Numeric format legality](../decisions/ADR-NUM-0014-numeric-format-legality.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Blockers:
  - Bind the specialized floating raw carriers and decide the public roles of F64 and E8M0.
  - Publish bit-exact payload fields and exceptional-value classes for every floating type.
  - Complete the scalar and tile operation/type legality matrix.
  - Resolve the E5M2/E5M3FN spelling conflict.
  - Publish positive and negative target-availability vectors for every accepted tuple.

## [ADR-NUM-0015: Numeric special values](../decisions/ADR-NUM-0015-numeric-special-values.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Blockers:
  - Extend bit-exact NaN creation rules beyond comparison and min/max.
  - Define infinity arithmetic and special results for conversions, reductions, quantization, and matrix operations.
  - Complete signaling-NaN flag and status interactions for every affected family.

## [ADR-NUM-0016: Numeric exception flags](../decisions/ADR-NUM-0016-numeric-exception-flags.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Blockers:
  - Accept exact flag conditions for all 19 profile-owned scalar forms.
  - Define tininess detection and NX coupling in every affected operation/type rule.
  - Publish independent simultaneous-flag and special-value vectors.

## [ADR-NUM-0017: Conversion range results](../decisions/ADR-NUM-0017-conversion-range-results.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Blockers:
  - Complete the source/destination/rounding/saturation cross-product.
  - Resolve the public CPU-saturation versus implementation default-OFF conflict.
  - Choose overflow, NaN, and infinity results.
  - Define non-saturating narrowing, wrap behavior, and omitted-saturation defaults per profile/type pair.

## [ADR-NUM-0018: Elementary-function accuracy](../decisions/ADR-NUM-0018-elementary-function-accuracy.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Blockers:
  - Choose the oracle and version.
  - Set per-operation/type/profile error bounds.
  - Define domain boundaries and monotonic intervals.

## [ADR-NUM-0019: Reduction order and stability](../decisions/ADR-NUM-0019-reduction-order-and-stability.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Blockers:
  - Freeze accumulator widths and trees.
  - Define argument and equal-value ties.
  - Bound floating permutation sensitivity and partial merges.

## [ADR-NUM-0020: Quantization contract](../decisions/ADR-NUM-0020-quantization-contract.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Blockers:
  - Resolve whether the affine parameter is scale or inverse-scale/pre-quant multiplier.
  - Freeze format-specific equations and stochastic-rounding state.
  - Define group axes, sizes, and tails.
  - Define sentinels, packing, round-trip tolerances, and whether `SET_QUANT` configuration is architectural state.

## [ADR-NUM-0021: Matrix numeric contract](../decisions/ADR-NUM-0021-matrix-numeric-contract.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Blockers:
  - Complete the legal type-tuple table.
  - Freeze dot-product, HF32/TF32 selection, and accumulation arithmetic.
  - Resolve the public A5 MX E4M3-only versus implementation FP4/mixed-FP8 conflict.
  - Define MX scale layout, logical versus capacity K multiples, and non-A5 rejection.

## [ADR-NUM-0022: Bounded numeric variation](../decisions/ADR-NUM-0022-bounded-numeric-variation.md)

- Target release: unassigned
- Implementation issue: not assigned
- Affected NDF clauses: not assigned
- Blockers:
  - Select one admissible route for every non-portable variation point.
  - Populate a bounded allowed-result contract for every selected delegation.
  - Add unknown-profile, unknown-mode, and missing-rule rejection vectors.
