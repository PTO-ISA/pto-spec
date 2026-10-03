<!-- GENERATED FROM: asl/tile/model/execution/lea.asl -->
# Lea

**Normative ASL source:** `asl/tile/model/execution/lea.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-LEA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-lea-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the element transformation and publication sequence for `TLEA`. `TileLEAExtendedIndex` performs signed or unsigned extension, `TileLEAByteScale` converts the explicit element width from bits to bytes, `TileLEAByteOffset` forms the low-64-bit product, and `TLEA` applies that transformation across one Local source Tile.

<!-- PTO-READER-BLOCK: tile-model-execution-lea-concepts role=concepts-state -->
## Concepts and visible state

The handler reads the complete source Tile record, the preallocated destination record, the current ExecutionMask, and the current `PadValue`. It publishes one updated destination record and leaves the source unchanged.

The source type controls both extension and destination signedness. `S32` sign-extends and `U32` zero-extends; `S64` and `U64` already occupy the full `Word`. Element widths 8, 16, 32, and 64 map to byte scales 1, 2, 4, and 8.

<!-- PTO-READER-BLOCK: tile-model-execution-lea-rules role=rules-interactions -->
## Rules and interactions

`TileLEAByteOffset` extends the logical index before calling `MultiplyWord` with the byte scale. The word multiplication retains the low 64 bits, so the operation is defined modulo 2^64 and does not use host-language signed arithmetic.

`TLEA` copies the complete source and destination records into locals before building results. For every active logical coordinate it reads the old source element and computes the byte offset. For an inactive CUBE ExecutionMask coordinate it reads no source element and takes the existing ZERO or MERGE destination value. After the valid rectangle is complete, the handler marks it defined, applies the selected padding to the physical tail, and publishes the destination once.

<!-- PTO-READER-BLOCK: tile-model-execution-lea-boundaries role=boundaries -->
## Architectural boundaries

The functions assert that `TileOperandsLegal_TLEA` and the element-width predicate already hold. Schema, descriptor, shape, definedness, and allocation rejection therefore belong to preflight, not to the element loop.

This unit produces byte offsets only. It reads no base GPR, performs no address translation or memory access, generates no memory event, and updates no numeric status. Strict `PE_MASK=0000` handling occurs before the handler is called.

<!-- PTO-READER-BLOCK: tile-model-execution-lea-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

With an `S32` source value of -1 and `element_bits=32`, `TileLEAExtendedIndex` first produces `0xFFFFFFFFFFFFFFFF`. `TileLEAByteScale` returns 4, and `MultiplyWord` produces the low-64-bit pattern `0xFFFFFFFFFFFFFFFC`, representing a byte displacement of -4. A `U32` source row `[0, 1, 2]` under the same scale instead produces `[0, 4, 8]`.

<!-- PTO-READER-BLOCK: tile-model-execution-lea-related role=related-owners-navigation -->
## Related owners

- [TLEA operand legality](../legality/lea-operands.md) establishes the handler preconditions.
- [TLEA bundle schema](../../../block/model/dispatch/lea-schema.md) checks the incoming bindings and scalar width.
- [ExecutionMask state](execution-mask-state.md) owns inactive ZERO and MERGE values.
- [TLEA](../../tile-scalar-and-immediate/arithmetic/TLEA.md) is the instruction page.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/lea.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-LEA","surface":"tile","classification":["model","execution","lea"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-LEA-OPERANDS"]}

pure func TileLEAExtendedIndex(value: Word, data_type: TileDataType) => Word
begin
    case data_type of
        when TileDataType_S32 => return SignExtend{PTO_XLEN}(value[31:0]);
        when TileDataType_U32 => return ZeroExtend{PTO_XLEN}(value[31:0]);
        when TileDataType_S64, TileDataType_U64 => return value;
        otherwise => unreachable;
    end;
end;

pure func TileLEAByteScale(element_bits: Word) => Word
begin
    assert TileLEAElementBitsLegal(element_bits);
    if element_bits == Zeros{PTO_XLEN} + 8 then
        return Zeros{PTO_XLEN} + 1;
    elsif element_bits == Zeros{PTO_XLEN} + 16 then
        return Zeros{PTO_XLEN} + 2;
    elsif element_bits == Zeros{PTO_XLEN} + 32 then
        return Zeros{PTO_XLEN} + 4;
    end;
    return Zeros{PTO_XLEN} + 8;
end;

pure func TileLEAByteOffset(
    value: Word, data_type: TileDataType, element_bits: Word) => Word
begin
    assert TileLEAIndexDataTypeLegal(data_type);
    assert TileLEAElementBitsLegal(element_bits);
    return MultiplyWord(
        TileLEAExtendedIndex(value, data_type),
        TileLEAByteScale(element_bits));
end;

func TLEA(destination: TileIndex, source: TileIndex, element_bits: Word)
begin
    assert TileOperandsLegal_TLEA(destination, source, element_bits);
    let source_tile = _Tiles[[source]];
    var result = _Tiles[[destination]];

    // Snapshot the complete source record before constructing the result.
    // This gives direct S64/U64 destination aliases read-old/write-new behavior.
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLogicalLinearIndex(
                result, row as integer {0..65535},
                column as integer {0..65535});
            var value = Zeros{PTO_XLEN};
            if BundleExecutionMaskActiveAt(
                   source_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let source_element = TileLogicalLinearIndex(
                    source_tile, row as integer {0..65535},
                    column as integer {0..65535});
                value = TileLEAByteOffset(
                    TileReadLogicalElement(source_tile, source_element),
                    source_tile.data_type, element_bits);
            else
                value = BundleExecutionMaskDestinationValue(
                    result.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
            end;
            result = TileInfoWithLogicalElement(
                result, destination_element, value);
        end;
    end;

    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, CurrentBundlePadValue());
    _Tiles[[destination]] = result;
end;
```
<!-- GENERATED-ASL-END: unit -->
