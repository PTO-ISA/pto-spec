<!-- GENERATED FROM: asl/tile/model/legality/indexed-rearrangement.asl -->
# Indexed Rearrangement

**Normative ASL source:** `asl/tile/model/legality/indexed-rearrangement.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-INDEXED-REARRANGEMENT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-indexed-rearrangement-purpose role=purpose-scope -->
## Purpose and scope

This unit holds the operand legality predicates for the two row-indexed Tile instructions, `TGATHER` and `TSCATTER`. `TileOperandsLegal_TGATHER` and `TileOperandsLegal_TSCATTER` are the `legality_handler` entries of those instructions, and the execution functions in the indexed-rearrangement execution unit assert them before they build a destination.

It also defines the type rules (`InstructionContractValueDataTypeLegal_TGATHER`, `InstructionContractIndexDataTypeLegal_TGATHER`, `InstructionContractTypePairLegal_TSCATTER`) and the index decoders `TileIndexedRowIsNegative` and `TileIndexedRowValue`. Execution reuses `TileIndexedRowValue` to find the selected row.

Each predicate is read-only and returns FALSE for an illegal operand set, so rejection happens in preflight, before any destination element is written.

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-rearrangement-concepts role=concepts-state -->
## Concepts and visible state

An index Tile holds one row selector per coordinate. The column is never changed: `TGATHER` reads `source[index[r,c], c]`, and `TSCATTER` writes `destination[index[r,c], c]`.

- Value types: any type that is not a packed four-bit type (`IndexedTLSUTransferDataTypeLegal`). The destination type must equal the value source type.
- Index types: S16, U16, S32, U32, S64, or U64.
- Index decoding: a signed index is first tested for a negative value. The row is then the unsigned value of the low 16, 32, or 64 bits.

All three operands must pass `TileDescriptorLegal` and be Numeric Tiles. `TileDescriptorLegal` requires generic indexing, which excludes CUBE layouts, so these predicates reject CUBE-layout operands.

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-rearrangement-rules role=rules-interactions -->
## Rules and interactions

`TileOperandsLegal_TGATHER` requires:

- a nonzero destination valid shape equal to the index valid shape;
- source valid columns at least the destination valid columns;
- an index Tile that is defined and validly encoded under the ExecutionMask rules of `TileElementwiseSourceContentsDefined` and `TileElementwiseSourceEncodingsValid`;
- for each active index coordinate, an index that is not negative, a row below the source valid rows, and a defined source element at that row and column.

Design point: the source may have more valid columns than the destination, but not fewer. The index keeps the column, so every destination column must exist in the source.

`TileOperandsLegal_TSCATTER` requires:

- a nonzero source valid shape equal to the index valid shape;
- nonzero destination valid rows and destination valid columns equal to the source valid columns;
- a source and an index Tile whose contents are defined (`TileSourceContentsDefined`) and an index Tile whose encodings are valid;
- for every index coordinate, an index that is not negative, a row below the destination valid rows, and a destination element that no other coordinate has selected.

Design point: `TileScatterReferencesLegal` records each selected destination element in a bitmap and rejects a second selection. Each destination element is written at most once, so the result does not depend on the order in which source coordinates are processed.

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-rearrangement-boundaries role=boundaries -->
## Architectural boundaries

Only the `TGATHER` reference check consults the ExecutionMask; it skips inactive index coordinates. The `TSCATTER` reference and duplicate checks visit every index coordinate.

Neither predicate checks the numeric encoding of value elements. Only the index Tile encodings are checked. Execution copies value bits unchanged, and no numeric helper runs on them.

These predicates do not check capacity, `PE_MASK`, or bundle binding structure. Bundle dispatch owns those checks.

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-rearrangement-example role=example-usage -->
## Non-normative reading example

Consider `TGATHER` with U16 values and U16 indices. The source has valid shape 4 rows by 2 columns. The destination and index have valid shape 2 by 2, and the index rows are `[3, 0]` and `[1, 1]`.

- Destination `[0,0]` reads source `[3,0]`; destination `[0,1]` reads source `[0,1]`.
- Destination `[1,0]` reads source `[1,0]`; destination `[1,1]` reads source `[1,1]`.
- An index of 4 anywhere makes the predicate FALSE, because the source has only 4 valid rows.

For `TSCATTER`, index column 0 with values `[2, 2]` sends two source elements to destination `[2,0]`, so the operand set is rejected.

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-rearrangement-related role=related-owners-navigation -->
## Related owners

- [Indexed rearrangement execution](../execution/indexed-rearrangement.md) builds the destinations after these checks.
- [Execution-mask source schema](execution-mask-source-schema.md) owns the masked index definedness and encoding checks.
- [Descriptor shape](descriptor-shape.md) owns `TileDescriptorLegal` and `TileSourceContentsDefined`.
- [Element definedness](../definedness/elements.md) owns `IndexedTLSUTransferDataTypeLegal`.
- [TGATHER](../../irregular-and-complex/layout/TGATHER.md) and [TSCATTER](../../irregular-and-complex/layout/TSCATTER.md) are the instruction pages.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/indexed-rearrangement.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-INDEXED-REARRANGEMENT","surface":"tile","classification":["model","legality","indexed-rearrangement"],"depends_on":["PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA"]}

pure func InstructionContractValueDataTypeLegal_TGATHER(
    data_type: TileDataType) => boolean
begin
    return IndexedTLSUTransferDataTypeLegal(data_type);
end;

pure func InstructionContractIndexDataTypeLegal_TGATHER(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_S32 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_S16 ||
           data_type == TileDataType_U16 ||
           data_type == TileDataType_S64 ||
           data_type == TileDataType_U64;
end;

pure func InstructionContractTypePairLegal_TSCATTER(
    value_type: TileDataType,
    index_type: TileDataType) => boolean
begin
    return IndexedTLSUTransferDataTypeLegal(value_type) &&
           (index_type == TileDataType_S16 ||
            index_type == TileDataType_U16 ||
            index_type == TileDataType_S32 ||
            index_type == TileDataType_U32 ||
            index_type == TileDataType_S64 ||
            index_type == TileDataType_U64);
end;

pure func TileIndexedRowIsNegative(
    value: Word,
    data_type: TileDataType) => boolean
begin
    if data_type == TileDataType_S16 then
        return SInt(value[15:0]) < 0;
    end;
    if data_type == TileDataType_S32 then
        return SInt(value[31:0]) < 0;
    end;
    if data_type == TileDataType_S64 then
        return SInt(value[63:0]) < 0;
    end;
    return FALSE;
end;

pure func TileIndexedRowValue(
    value: Word,
    data_type: TileDataType) => integer
begin
    if data_type == TileDataType_S16 ||
       data_type == TileDataType_U16 then
        return UInt(value[15:0]);
    end;
    if data_type == TileDataType_S32 ||
       data_type == TileDataType_U32 then
        return UInt(value[31:0]);
    end;
    assert data_type == TileDataType_S64 ||
           data_type == TileDataType_U64;
    return UInt(value[63:0]);
end;

readonly func TileGatherReferencesLegal(
    source: TileIndex,
    indices: TileIndex) => boolean
begin
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   index_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
            let index_element = TileLogicalLinearIndex(
                index_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            let raw_index = TileReadLogicalElement(index_tile, index_element);
            if TileIndexedRowIsNegative(raw_index, index_tile.data_type) then
                return FALSE;
            end;
            let source_row = TileIndexedRowValue(
                raw_index,
                index_tile.data_type);
            if source_row >= source_tile.valid_rows then
                return FALSE;
            end;
            let source_element = TileLogicalLinearIndex(
                source_tile,
                source_row as integer {0..65535},
                column as integer {0..65535});
            if !TileLogicalElementDefined(source_tile, source_element) then
                return FALSE;
            end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileScatterReferencesLegal(
    destination: TileIndex,
    indices: TileIndex) => boolean
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    var selected = Zeros{524288};
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            let index_element = TileLogicalLinearIndex(
                index_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            let raw_index = TileReadLogicalElement(index_tile, index_element);
            if TileIndexedRowIsNegative(raw_index, index_tile.data_type) then
                return FALSE;
            end;
            let destination_row = TileIndexedRowValue(
                raw_index,
                index_tile.data_type);
            if destination_row >= destination_tile.valid_rows then
                return FALSE;
            end;
            let destination_element = TileLogicalLinearIndex(
                destination_tile,
                destination_row as integer {0..65535},
                column as integer {0..65535});
            if selected[destination_element] == '1' then
                return FALSE;
            end;
            selected[destination_element] = '1';
        end;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_TGATHER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source) ||
       !TileDescriptorLegal(indices) then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    if destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.storage_kind != TileStorage_Numeric ||
       index_tile.storage_kind != TileStorage_Numeric ||
       !InstructionContractValueDataTypeLegal_TGATHER(
           source_tile.data_type) ||
       !InstructionContractIndexDataTypeLegal_TGATHER(
           index_tile.data_type) ||
       destination_tile.data_type != source_tile.data_type ||
       destination_tile.valid_rows == 0 ||
       destination_tile.valid_columns == 0 ||
       destination_tile.valid_rows != index_tile.valid_rows ||
       destination_tile.valid_columns != index_tile.valid_columns ||
       source_tile.valid_columns < destination_tile.valid_columns ||
       !TileElementwiseSourceContentsDefined(indices) ||
       !TileElementwiseSourceEncodingsValid(indices) then
        return FALSE;
    end;
    return TileGatherReferencesLegal(source, indices);
end;

readonly func TileOperandsLegal_TSCATTER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source) ||
       !TileDescriptorLegal(indices) then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    if destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.storage_kind != TileStorage_Numeric ||
       index_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.data_type != source_tile.data_type ||
       !InstructionContractTypePairLegal_TSCATTER(
           source_tile.data_type,
           index_tile.data_type) ||
       source_tile.valid_rows == 0 ||
       source_tile.valid_columns == 0 ||
       source_tile.valid_rows != index_tile.valid_rows ||
       source_tile.valid_columns != index_tile.valid_columns ||
       destination_tile.valid_rows == 0 ||
       destination_tile.valid_columns != source_tile.valid_columns ||
       !TileSourceContentsDefined(source) ||
       !TileSourceContentsDefined(indices) ||
       !TileSourceEncodingsValid(indices) then
        return FALSE;
    end;
    return TileScatterReferencesLegal(destination, indices);
end;
```
<!-- GENERATED-ASL-END: unit -->
