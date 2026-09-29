<!-- GENERATED FROM: asl/tile/model/execution/minmax.asl -->
# Minmax

**Normative ASL source:** `asl/tile/model/execution/minmax.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-MINMAX}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-minmax-purpose role=purpose-scope -->
## Purpose and scope

This unit defines one pure helper, `TileFloatingMinMaxValue`. It computes the floating minimum or maximum of two raw element carriers and reports whether the invalid-operation condition occurred.

It is the Tile-level adapter over the architecture profile `HardwareNumericFloatingMinMax`. Callers include `TileProfileBinaryWithFlags` in [elementwise execution](elementwise.md) for floating MIN and MAX, and the `InstructionContractFloatingValue_TMAX` and `InstructionContractFloatingValue_TMIN` helpers of TMAX and TMIN.

<!-- PTO-READER-BLOCK: tile-model-execution-minmax-concepts role=concepts-state -->
## Concepts and visible state

The helper has no state. Its inputs are a `TileBinaryOperation`, a data type, and two carriers. It returns the selected carrier and a Boolean `invalid`.

The profile resolves special cases first through `HardwareNumericMinMaxSpecial`:

- Two NaNs give the canonical NaN of the type.
- One NaN gives the other operand.
- `invalid` is TRUE when either operand is a signaling NaN.
- Two zeros of any sign: MAX gives -0.0 only when both are -0.0, and +0.0 otherwise. MIN gives -0.0 when either is -0.0, and +0.0 otherwise.

Otherwise each operand is mapped to an unsigned order key. A negative carrier is bit-inverted and a nonnegative carrier has its sign bit set, so larger keys mean larger values.

<!-- PTO-READER-BLOCK: tile-model-execution-minmax-rules role=rules-interactions -->
## Rules and interactions

The helper asserts that the operation is MIN or MAX. It then asserts that the profile reported the result as available. The profile reports unavailable when an operand has an invalid encoding or when the type has no ordering key.

On equal keys the left operand is returned, because MAX uses `>=` and MIN uses `<=`.

Whether `invalid` reaches the sticky status depends on the caller. `TileProfileBinaryWithFlags` turns it into the NV flag. `ExecuteTileScalar`, `ExecuteTileExpand`, and `ExecuteTileReduction` record the flags they receive. `ExecuteTileBinary`, used by TMAX and TMIN, calls `TileProfileBinary`, which drops the flags.

Design point: a single quiet NaN does not poison the result; the numeric operand wins. A max or min over data with missing values therefore returns the extreme of the numbers that are present.

Design point: signed zeros are ordered explicitly, -0.0 below +0.0, even though they compare equal. The result is deterministic for every zero pairing instead of depending on operand order.

<!-- PTO-READER-BLOCK: tile-model-execution-minmax-boundaries role=boundaries -->
## Architectural boundaries

The ordering key exists for FP64, FP32, TF32, HF32, FP16, BF16, E4M3, and E5M2. These are the floating members of the 16-type VEC arithmetic set used by TMAX and TMIN legality.

Integer MIN and MAX do not use this unit. They use `TileIntegerMinMaxValue` in [elementwise execution](elementwise.md).

Legality validates the floating source encodings before execution, so the availability assertion is not expected to fail on a legal operation.

<!-- PTO-READER-BLOCK: tile-model-execution-minmax-example role=example-usage -->
## Non-normative reading example

All values are FP32.

| Operation | Left | Right | Result | `invalid` |
| --- | --- | --- | --- | --- |
| MAX | 1.5 (`0x3fc00000`) | -2.0 (`0xc0000000`) | 1.5 | FALSE |
| MAX | +0.0 | -0.0 | +0.0 | FALSE |
| MIN | +0.0 | -0.0 | -0.0 | FALSE |
| MAX | quiet NaN | 3.0 | 3.0 | FALSE |
| MAX | signaling NaN | 3.0 | 3.0 | TRUE |

For the first row, the key of 1.5 is `0x3fc00000` with the sign bit set, `0xbfc00000`. The key of -2.0 is its bitwise inverse, `0x3fffffff`. The first key is larger, so MAX returns the left operand.

<!-- PTO-READER-BLOCK: tile-model-execution-minmax-related role=related-owners-navigation -->
## Related owners

- [Min/max profile](../../../arch/features/minmax.md) owns `HardwareNumericFloatingMinMax` and the order key.
- [MX formats](../../../arch/features/mx-formats.md) owns `HardwareNumericMinMaxSpecial` and the canonical NaNs.
- [Elementwise execution](elementwise.md) routes floating MIN and MAX here and decides whether flags are recorded.
- [TMAX](../../elementwise-tile-tile/arithmetic/TMAX.md) and [TMIN](../../elementwise-tile-tile/arithmetic/TMIN.md) are the Tile-Tile instructions.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/minmax.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-MINMAX","surface":"tile","classification":["model","execution","minmax"],"depends_on":["PTO-ARCH-FEATURES-MINMAX","PTO-TILE-MODEL-STATE-TYPES"]}
pure func TileFloatingMinMaxValue(
    operation: TileBinaryOperation,
    data_type: TileDataType,
    left: Word,
    right: Word) => (Word, boolean)
begin
    assert operation == TileBinary_MIN || operation == TileBinary_MAX;
    let maximum = operation == TileBinary_MAX;
    let (available, result, invalid) =
        HardwareNumericFloatingMinMax(
            maximum,
            data_type,
            left,
            right);
    assert available;
    return (result, invalid);
end;
```
<!-- GENERATED-ASL-END: unit -->
