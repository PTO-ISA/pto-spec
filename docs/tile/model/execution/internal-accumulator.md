<!-- GENERATED FROM: asl/tile/model/execution/internal-accumulator.asl -->
# Internal Accumulator

**Normative ASL source:** `asl/tile/model/execution/internal-accumulator.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-INTERNAL-ACCUMULATOR}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-internal-accumulator-purpose role=purpose-scope -->
## Purpose and scope

This unit states that the CUBE internal accumulator, InternalAcc, is a transparent implementation cache. It contains one NDF clause, `PTO-CUBE-INTERNAL-ACCUMULATOR-001`, and two implementation-defined hint hooks.

The unit has no executable state of its own. Both hooks have an empty body (`pass`), so the portable model neither reads nor writes cached payload.

<!-- PTO-READER-BLOCK: tile-model-execution-internal-accumulator-concepts role=concepts-state -->
## Concepts and visible state

- InternalAcc is a transparent cache that an implementation may keep. It is not architectural state.
- TileReg C is the explicit accumulator input of an ACC form. TileReg D is the destination.
- CCTRL is the two-bit matrix control carried in the B.DATR PadValueOrByteId field.

The two hooks are `TileProfileInternalAccumulatorPrefetchHint` and `TileProfileInternalAccumulatorReplacementHint`. Each receives a Tile index and a byte count from 0 to 262144.

<!-- PTO-READER-BLOCK: tile-model-execution-internal-accumulator-rules role=rules-interactions -->
## Rules and interactions

`ExecuteBundleTMATMULOperation` in CUBE TMATMUL dispatch is the only caller found in the ASL. It calls the prefetch hint for C when the form uses an accumulator and CCTRL bit 1 is set. The call happens after operand resolution and before the product is computed.

The same function calls the replacement hint for D when CCTRL bit 0 selects raw-partial output. That call happens only after the result is published without a fault.

The NDF clause requires C to remain the architectural accumulator input. It also requires D to be allocated and published on every successful operation.

Design point: cache hit, miss, capacity, residency, replacement, and timing must not change results, faults, allocation, publication, source lifetime, or ordering. A program therefore gets the same D whether or not an implementation honors a hint.

Design point: C stays an explicit Tile operand even when an implementation keeps a copy in InternalAcc. The value used is always the architectural value of C, which the CUBE unit reads before D is written.

<!-- PTO-READER-BLOCK: tile-model-execution-internal-accumulator-boundaries role=boundaries -->
## Architectural boundaries

The hooks are `impdef` functions. A profile may give them a body, but the clause forbids cache behavior from changing results, faults, allocation, publication, source lifetime, or ordering.

The hooks do not skip allocation of D. Raw-partial output still allocates and publishes D, with the accumulator type.

This unit defines no instruction, field, or fault.

<!-- PTO-READER-BLOCK: tile-model-execution-internal-accumulator-example role=example-usage -->
## Non-normative reading example

Consider two FP32 TMATMUL_ACC operations that accumulate into the same running result.

1. The first operation sets CCTRL to `01`. It publishes raw-partial D1, and the model then calls the replacement hint for D1.
2. The second operation names D1 as C and sets CCTRL to `10`. The model calls the prefetch hint for D1 before the product.
3. The second operation reads D1 as C and publishes a new D2, exactly as it would with CCTRL `00`.

If D1 held 21.0 and the new product sum is 8.0, D2 holds 29.0 in every case.

<!-- PTO-READER-BLOCK: tile-model-execution-internal-accumulator-related role=related-owners-navigation -->
## Related owners

- [CUBE execution](cube.md) owns the product, accumulation, and raw-partial commit.
- [Matrix scale](matrix-scale.md) owns the initial value read from C.
- [CUBE TMATMUL dispatch](../../../block/model/dispatch/cube-tmatmul.md) calls both hooks.
- [CUBE accumulator routing](../../../block/model/dispatch/cube-accumulator-routing.md) decodes the CCTRL bits.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/internal-accumulator.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-INTERNAL-ACCUMULATOR","surface":"tile","classification":["model","execution","internal-accumulator"],"depends_on":["PTO-TILE-MODEL-EXECUTION-MATRIX-SCALE"]}

// NDF-BEGIN: PTO-CUBE-INTERNAL-ACCUMULATOR-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// InternalAcc MUST be a transparent implementation cache. Explicit TileReg C
// MUST remain the architectural accumulator input and explicit TileReg D MUST
// be allocated and published on every successful operation. CCTRL MAY provide
// non-binding input-prefetch and output-replacement hints, but cache hit, miss,
// capacity, residency, replacement, and timing MUST NOT change architectural
// results, faults, allocation, publication, source lifetime, or ordering.
// NDF-END: PTO-CUBE-INTERNAL-ACCUMULATOR-001

// These hooks are non-binding implementation hints. The portable model does
// not read or write cached payload and does not observe whether a hint is used.
impdef func TileProfileInternalAccumulatorPrefetchHint(
    source: TileIndex, required_bytes: integer {0..262144})
begin
    pass;
end;

impdef func TileProfileInternalAccumulatorReplacementHint(
    destination: TileIndex, required_bytes: integer {0..262144})
begin
    pass;
end;
```
<!-- GENERATED-ASL-END: unit -->
