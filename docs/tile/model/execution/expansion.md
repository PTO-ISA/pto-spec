<!-- GENERATED FROM: asl/tile/model/execution/expansion.asl -->
# Expansion

**Normative ASL source:** `asl/tile/model/execution/expansion.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-EXPANSION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-expansion-purpose role=purpose-scope -->
## Purpose and scope

This unit owns `ExecuteTileExpand`, the shared handler for row and column broadcast operations. It is reached by the eight TROWEXPAND forms (TROWEXPAND, TROWEXPANDADD, TROWEXPANDSUB, TROWEXPANDMUL, TROWEXPANDDIV, TROWEXPANDMAX, TROWEXPANDMIN, TROWEXPANDEXPDIF) and the eight matching TCOLEXPAND forms.

It carries the accepted clause `PTO-TILE-MODEL-EXECUTION-MASK-EXPANSION-001`.

<!-- PTO-READER-BLOCK: tile-model-execution-expansion-concepts role=concepts-state -->
## Concepts and visible state

Each operation has three Tile operands: the destination, the full-size source, and the broadcast source. The axis selects which broadcast element pairs with each destination coordinate:

- Row axis: the element in the same row of the broadcast source, at the broadcast slot column.
- Column axis: the element in row 0 of the broadcast source, in the same column.

The broadcast slot is column 0 for RowMajor. For CUBE_M16 or CUBE_M32 row forms, `TileExpansionBroadcastSlot` divides the BroadcastByteOffset from B.DATR RMode by the element size in bytes.

The operation kind selects the element function. COPY returns the broadcast element. ADD, SUB, MUL, DIV, MAX, and MIN apply `TileProfileBinaryWithFlags` to the source element and the broadcast element. EXPDIF uses the EXPDIF element helper.

<!-- PTO-READER-BLOCK: tile-model-execution-expansion-rules role=rules-interactions -->
## Rules and interactions

The handler loops over the destination valid region. For an active coordinate it reads the broadcast element and, except for COPY, the source element at the same coordinate. It stores the value and ORs the element flags, NV, DZ, OF, UF, and NX from bit 0 to bit 4.

After the loop it marks the valid region defined, applies the bundle padding, records the ORed flags, and publishes the destination.

Design point: the three operand records are snapshotted before the loop and the result is built privately. A destination that names the source still reads the old values.

Design point: COPY requires the source and broadcast operands to name the same Tile. The source element is never read for COPY, so no second full-size operand is involved.

Design point: EXPDIF alone may have a destination type that differs from the source operation type. Every other kind requires the two types to be equal, so the arithmetic always runs in the destination type.

<!-- PTO-READER-BLOCK: tile-model-execution-expansion-boundaries role=boundaries -->
## Architectural boundaries

Under an ExecutionMask, an inactive coordinate reads neither source, contributes no flags, and takes the ZERO or MERGE value. A broadcast element is therefore read only if some active coordinate uses it.

For integer DIV, legality requires a nonzero divisor for active outputs before the handler runs. Floating arithmetic follows the type limits of `TileProfileBinaryWithFlags`: ADD, SUB, MUL, and DIV use `ScalarFPBinaryProfile`, which accepts FP64, FP32, FP16, and BF16.

<!-- PTO-READER-BLOCK: tile-model-execution-expansion-example role=example-usage -->
## Non-normative reading example

Take TROWEXPANDSUB on RowMajor S32 Tiles with a valid region of 2 rows by 3 columns and no ExecutionMask:

```text
TROWEXPANDSUB <Row=32, Col=4, ValidRow=2, ValidCol=3, S32>, T#1, T#2, ->T<512B>
```

The source rows are 10, 20, 30 and 5, 6, 7. The broadcast source holds 1 in row 0 and 5 in row 1, at column 0.

1. Row 0 subtracts 1: 9, 19, 29.
2. Row 1 subtracts 5: 0, 1, 2.

The integer path returns no flags, so the sticky status is unchanged.

<!-- PTO-READER-BLOCK: tile-model-execution-expansion-related role=related-owners-navigation -->
## Related owners

- [Reduction and expansion legality](../legality/reduction-and-expansion.md) owns the operand checks and the broadcast slot.
- [Elementwise execution](elementwise.md) owns the binary element helper.
- [EXPDIF execution](expdif.md) owns the EXPDIF element helper.
- [Reduction execution](reduction.md) owns the matching row and column reductions.
- [Execution-mask state](execution-mask-state.md) owns inactive coordinate handling.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/expansion.asl -->
```asl
// NDF-BEGIN: PTO-TILE-MODEL-EXECUTION-MASK-EXPANSION-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Predicated expansion reads and validates source coordinates only when the mapped output coordinate is active. A selected row-broadcast element is read only if at least one active output consumes it; inactive outputs use the common MERGE/ZERO rule and contribute no numeric flags. Integer division-by-zero checks apply only to active outputs.
// NDF-END: PTO-TILE-MODEL-EXECUTION-MASK-EXPANSION-001
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-EXPANSION","surface":"tile","classification":["model","execution","expansion"],"depends_on":["PTO-TILE-MODEL-EXECUTION-EXPDIF","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-EXECUTION-REDUCTION","PTO-TILE-MODEL-EXECUTION-UNARY","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}
// PTO-REQ-TEPL-EXPAND-001: exact typed row and column broadcast operations.

pure func TileExpandBinaryOperation(
    operation: TileExpandOperation) => TileBinaryOperation
begin
    case operation of
        when TileExpand_ADD =>
            return TileBinary_ADD;
        when TileExpand_SUB =>
            return TileBinary_SUB;
        when TileExpand_MUL =>
            return TileBinary_MUL;
        when TileExpand_DIV =>
            return TileBinary_DIV;
        when TileExpand_MAX =>
            return TileBinary_MAX;
        when TileExpand_MIN =>
            return TileBinary_MIN;
        otherwise =>
            unreachable;
    end;
end;

func TileExpandValueWithTypesAndFlags(
    operation: TileExpandOperation,
    source_type: TileDataType,
    destination_type: TileDataType,
    left: Word,
    broadcast: Word) => (Word, bits(5))
begin
    if operation == TileExpand_COPY then
        return (broadcast, Zeros{5});
    end;

    if operation == TileExpand_EXPDIF then
        return TileExpdifValueWithTypesAndFlags(
            source_type, destination_type, left, broadcast);
    end;

    return TileProfileBinaryWithFlags(
        TileExpandBinaryOperation(operation),
        destination_type,
        left,
        broadcast);
end;

func TileProfileExpand(op: TileExpandOperation,
                                      data_type: TileDataType,
                                      left: Word, broadcast: Word) => Word
begin
    return TileExpandValue(
        op,
        data_type,
        left,
        broadcast);
end;

func TileExpandValueWithFlags(
    operation: TileExpandOperation,
    data_type: TileDataType,
    left: Word,
    broadcast: Word) => (Word, bits(5))
begin
    return TileExpandValueWithTypesAndFlags(
        operation,
        data_type,
        data_type,
        left,
        broadcast);
end;

func TileExpandValue(
    operation: TileExpandOperation,
    data_type: TileDataType,
    left: Word,
    broadcast: Word) => Word
begin
    let (result, -) = TileExpandValueWithFlags(
        operation,
        data_type,
        left,
        broadcast);
    return result;
end;

func ExecuteTileExpand(op: TileExpandOperation, axis: TileAxis,
                       destination: TileIndex, source: TileIndex,
                       broadcast_source: TileIndex)
begin
    assert TileOperandsLegal_ExecuteTileExpand(
        op,
        axis,
        destination,
        source,
        broadcast_source);

    let source_tile = _Tiles[[source]];
    let broadcast_tile = _Tiles[[broadcast_source]];
    var result_tile = _Tiles[[destination]];
    let expdif = op == TileExpand_EXPDIF;
    let (operation_type_valid, selected_type) =
        ResolveTileSelectedOperationType(result_tile.data_type);
    assert operation_type_valid;
    let source_operation_type = if expdif && !BundleTileOperationSelected() then
        source_tile.data_type else selected_type;
    let destination_operation_type = if expdif then
        result_tile.data_type else selected_type;
    let broadcast_slot = TileExpansionBroadcastSlot(
        axis, broadcast_tile.layout, source_operation_type);
    var accumulated_flags = Zeros{5};

    for row = 0 to result_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to result_tile.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLogicalLinearIndex(
                result_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   result_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let broadcast_row = if axis == TileAxis_Row then row else 0;
                let broadcast_column = if axis == TileAxis_Row then
                    broadcast_slot else column;
                let broadcast_element = TileLogicalLinearIndex(broadcast_tile,
                    broadcast_row as integer {0..65535},
                    broadcast_column as integer {0..65535});
                var left = TileReadLogicalElement(broadcast_tile,
                    broadcast_element);
                if op != TileExpand_COPY then
                    let source_element = TileLogicalLinearIndex(
                        source_tile,
                        row as integer {0..65535},
                        column as integer {0..65535});
                    left = TileReadLogicalElement(source_tile, source_element);
                end;
                let (value, element_flags) = TileExpandValueWithTypesAndFlags(
                    op,
                    source_operation_type,
                    destination_operation_type,
                    left,
                    TileReadLogicalElement(broadcast_tile, broadcast_element));
                result_tile = TileInfoWithLogicalElement(result_tile,
                    destination_element, value);
                accumulated_flags = accumulated_flags OR element_flags;
            else
                let value = BundleExecutionMaskDestinationValue(
                    result_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
                result_tile = TileInfoWithLogicalElement(
                    result_tile, destination_element, value);
            end;
        end;
    end;

    result_tile = TileWithValidRegionDefined(result_tile);
    result_tile = TileWithPadding(
        result_tile,
        CurrentBundlePadValue());
    RecordNumericStatusFlags(accumulated_flags);
    _Tiles[[destination]] = result_tile;
end;
```
<!-- GENERATED-ASL-END: unit -->
