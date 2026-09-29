<!-- GENERATED FROM: asl/tile/model/legality/memory-schema.asl -->
# Memory Schema

**Normative ASL source:** `asl/tile/model/legality/memory-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-memory-schema-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the operand legality predicates for Tile move, regular load and store, prefetch, and indexed gather and scatter. The `PTO-INSTRUCTION` metadata names them as legality handlers:

- `TileOperandsLegal_TMOV` for TMOV.
- `TileOperandsLegal_TLOAD` and `TileOperandsLegal_TSTORE` for TLOAD and TSTORE.
- `TileOperandsLegal_TPREFETCH` for TPREFETCH.
- `TileOperandsLegal_MGATHER`, `TileOperandsLegal_MSCATTER`, `TileOperandsLegal_MGATHER_MASK`, and `TileOperandsLegal_MSCATTER_MASK` for the four indexed transfers.

It also defines `TileOperandsLegal_MGATHER_CAS` and the shared definedness helper `IndexedTLSUExecutionMaskContentsDefined`.

<!-- PTO-READER-BLOCK: tile-model-legality-memory-schema-concepts role=concepts-state -->
## Concepts and visible state

All predicates are `readonly`. They read Tile descriptors, Tile payload definedness, and the bundle ExecutionMask, and do not touch memory.

An index Tile holds one byte displacement from the base address per transfer. A mask Tile holds one U8 value per element that must be 0 or 1. A packed four-bit data Tile holds two elements per byte, so one index covers a pair of data elements.

`IndexedTLSUExecutionMaskContentsDefined` first requires `IndexedTLSUNumericDescriptorLegal`. Without an ExecutionMask it returns `contents_defined`. With one, the Tile must share the mask's layout and valid rows, and its valid columns must equal the mask's, or twice the mask's for a packed type. Each active coordinate must then be defined; for a packed type both nibbles of the pair must be defined.

<!-- PTO-READER-BLOCK: tile-model-legality-memory-schema-rules role=rules-interactions -->
## Rules and interactions

`TileOperandsLegal_TMOV` resolves the operation type with `ResolveTileCarrierOperationType`, requires matching logical shape and storage kind, a same-width source, and a destination backing type equal to the source backing type.

Design point: TMOV is the only operation for which `TileOperationUsesSourceBackingDestination` is TRUE. The destination is allocated with the source's backing type, and legality requires that equality, so TMOV copies raw bits and never retags them.

TLOAD and TSTORE require a legal descriptor and a type accepted by `TileRegularTLSUDataTypeSupported`. That table lists 25 types, including the five packed types. E6M2 and RCPE6M2 are not in it.

The indexed transfers require:

- A RowMajor, CUBE_M16, or CUBE_M32 numeric data Tile and matching layouts across data, index, and mask Tiles.
- An index type of S32, U32, S64, or U64.
- Matching valid rows, and valid columns related by `IndexedTLSUDataShapeMatchesIndex`: equal, or twice the index columns for a packed data type.
- For the masked forms, a mask that passes `IndexedTLSUPredicateValuesLegal` with the index Tile's valid shape.

`TileOperandsLegal_MGATHER_CAS` requires non-packed data and equal data types across destination, expected, and replacement Tiles.

TPREFETCH has no Tile operand. Its predicate requires `ValidCol <= Col`, a power-of-two `Col`, and `ValidRow x ValidCol` no larger than `PTO_MODEL_TILE_ELEMENTS`. The six-argument form also requires `TileCarrierOrPackedBaselineDataTypeSupported`, which excludes 64-bit types.

Design point: source and index payloads are checked for definedness before any memory request. Under an ExecutionMask only active coordinates must be defined, so inactive lanes can hold undefined values without rejecting the bundle.

<!-- PTO-READER-BLOCK: tile-model-legality-memory-schema-boundaries role=boundaries -->
## Architectural boundaries

These predicates run in preflight. In the block dispatch paths for MGATHER, MGATHER_MASK, and MGATHER_CAS, the destination is resolved first; if the predicate then fails, the destination allocation is rolled back and `Fault_TileLegality` is raised before the gather reads memory.

They check operands only. Address translation, permissions, and memory faults belong to the memory units.

The metadata names `GM_ATOM_CAS` as the legality handler for MGATHER_CAS. The block dispatch path calls `TileOperandsLegal_MGATHER_CAS` from this unit and separately restricts the data type to U16, U32, or U64.

<!-- PTO-READER-BLOCK: tile-model-legality-memory-schema-example role=example-usage -->
## Non-normative reading example

An MGATHER destination is U4X2, RowMajor, with valid region 8 x 32. The index Tile is S32, RowMajor, with valid region 8 x 16. There is no ExecutionMask.

- Valid rows match: 8 and 8.
- U4X2 is packed, so the data columns must be even and equal 2 x 16 = 32. They are.
- S32 is a legal index type, and both Tiles are RowMajor.
- The index Tile must be fully defined because no mask is in force.

Each of the 8 x 16 = 128 index elements covers one pair of 4-bit destination elements. A destination with 16 valid columns would fail the pairing rule, and the bundle would be rejected.

<!-- PTO-READER-BLOCK: tile-model-legality-memory-schema-related role=related-owners-navigation -->
## Related owners

- [Indexed layout](indexed-layout.md) owns the indexed descriptor, index type, and shape-pairing helpers.
- [Predicate carriers](predicate-carriers.md) owns `IndexedTLSUPredicateValuesLegal`.
- [Data type and layout tables](dtype-layout.md) owns the TLOAD and TPREFETCH type tables.
- [Gather and scatter](../memory/gather-scatter.md) executes the indexed transfers.
- [MGATHER dispatch](../../../block/model/dispatch/tlsu-mgather.md) shows where the predicate runs in a bundle.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/memory-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA","surface":"tile","classification":["model","legality","memory-schema"],"depends_on":["PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT","PTO-TILE-MODEL-EXECUTION-MASK-STATE"]}
readonly func IndexedTLSUExecutionMaskContentsDefined(index: TileIndex)
    => boolean
begin
    let tile = _Tiles[[index]];
    if !IndexedTLSUNumericDescriptorLegal(index) then return FALSE; end;
    if !_BundleExecutionMask.valid then return tile.contents_defined; end;
    if tile.layout != _BundleExecutionMask.layout ||
       tile.valid_rows != _BundleExecutionMask.valid_rows then
        return FALSE;
    end;
    if TileDataTypeIsFourBit(tile.data_type) then
        if tile.valid_columns !=
           2 * _BundleExecutionMask.valid_columns then return FALSE; end;
    elsif tile.valid_columns != _BundleExecutionMask.valid_columns then
        return FALSE;
    end;
    for row = 0 to _BundleExecutionMask.valid_rows - 1 looplimit 65536 do
        for column = 0 to _BundleExecutionMask.valid_columns - 1
            looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let first_column = if TileDataTypeIsFourBit(tile.data_type)
                    then 2 * column else column;
                let first = TileLogicalLinearIndex(tile,
                    row as integer {0..65535},
                    first_column as integer {0..65535});
                if !TileLogicalElementDefined(tile, first) then
                    return FALSE;
                end;
                if TileDataTypeIsFourBit(tile.data_type) then
                    let second = TileLogicalLinearIndex(tile,
                        row as integer {0..65535},
                        (first_column + 1) as integer {0..65535});
                    if !TileLogicalElementDefined(tile, second) then
                        return FALSE;
                    end;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_TMOV(destination: TileIndex,
                                     source: TileIndex) => boolean
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[source]].data_type);
    return operation_type_valid &&
           TileLogicalShapeMatch(destination, source) &&
           _Tiles[[destination]].storage_kind ==
               _Tiles[[source]].storage_kind &&
           TileCarrierWidthCompatible(
               _Tiles[[source]].data_type, operation_type) &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type;
end;

readonly func TileOperandsLegal_TLOAD(destination: TileIndex,
                                      base_address: Word,
                                      row_stride_bytes: Word) => boolean
begin
    return TileDescriptorLegal(destination) &&
           TileRegularTLSUDataTypeSupported(
               _Tiles[[destination]].data_type);
end;

readonly func TileOperandsLegal_TSTORE(base_address: Word,
                                       row_stride_bytes: Word,
                                       source: TileIndex) => boolean
begin
    return TileDescriptorLegal(source) &&
           TileRegularTLSUDataTypeSupported(
               _Tiles[[source]].data_type);
end;

readonly func TileOperandsLegal_MGATHER(
    destination: TileIndex, base_address: Word,
    indices: TileIndex,
    pad_value: TilePadValue) => boolean
begin
    return IndexedTLSUNumericDescriptorLegal(destination) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUDataShapeMatchesIndex(
               _Tiles[[destination]].valid_rows,
               _Tiles[[destination]].valid_columns,
               _Tiles[[indices]].valid_rows,
               _Tiles[[indices]].valid_columns,
               _Tiles[[destination]].data_type) &&
           _Tiles[[destination]].layout == _Tiles[[indices]].layout &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           IndexedTLSUOrdinaryTransferDataTypeLegal(
               _Tiles[[destination]].data_type);
end;

readonly func TileOperandsLegal_MGATHER(
    destination: TileIndex, base_address: Word,
    indices: TileIndex) => boolean
begin
    return TileOperandsLegal_MGATHER(
        destination, base_address, indices, TilePad_Null);
end;

readonly func TileOperandsLegal_MSCATTER(
    base_address: Word, source: TileIndex, indices: TileIndex) => boolean
begin
    return IndexedTLSUExecutionMaskContentsDefined(source) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           IndexedTLSUOrdinaryTransferDataTypeLegal(
               _Tiles[[source]].data_type) &&
           IndexedTLSUDataShapeMatchesIndex(
               _Tiles[[source]].valid_rows, _Tiles[[source]].valid_columns,
               _Tiles[[indices]].valid_rows, _Tiles[[indices]].valid_columns,
               _Tiles[[source]].data_type) &&
           _Tiles[[source]].layout == _Tiles[[indices]].layout;
end;

readonly func TileOperandsLegal_MGATHER_MASK(
    destination: TileIndex, base_address: Word,
    indices: TileIndex,
    mask: TileIndex, pad_value: TilePadValue) => boolean
begin
    return IndexedTLSUNumericDescriptorLegal(destination) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUPredicateValuesLegal(mask) &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           IndexedTLSUOrdinaryTransferDataTypeLegal(
               _Tiles[[destination]].data_type) &&
           IndexedTLSUDataShapeMatchesIndex(
               _Tiles[[destination]].valid_rows,
               _Tiles[[destination]].valid_columns,
               _Tiles[[indices]].valid_rows,
               _Tiles[[indices]].valid_columns,
               _Tiles[[destination]].data_type) &&
           _Tiles[[indices]].valid_rows == _Tiles[[mask]].valid_rows &&
           _Tiles[[indices]].valid_columns == _Tiles[[mask]].valid_columns &&
           _Tiles[[destination]].layout == _Tiles[[indices]].layout &&
           _Tiles[[destination]].layout == _Tiles[[mask]].layout;
end;

readonly func TileOperandsLegal_MSCATTER_MASK(
    base_address: Word, source: TileIndex, indices: TileIndex,
    mask: TileIndex) => boolean
begin
    return IndexedTLSUExecutionMaskContentsDefined(source) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUPredicateValuesLegal(mask) &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           IndexedTLSUOrdinaryTransferDataTypeLegal(
               _Tiles[[source]].data_type) &&
           IndexedTLSUDataShapeMatchesIndex(
               _Tiles[[source]].valid_rows, _Tiles[[source]].valid_columns,
               _Tiles[[indices]].valid_rows, _Tiles[[indices]].valid_columns,
               _Tiles[[source]].data_type) &&
           _Tiles[[indices]].valid_rows == _Tiles[[mask]].valid_rows &&
           _Tiles[[indices]].valid_columns == _Tiles[[mask]].valid_columns &&
           _Tiles[[source]].layout == _Tiles[[indices]].layout &&
           _Tiles[[source]].layout == _Tiles[[mask]].layout;
end;

readonly func TileOperandsLegal_MGATHER_CAS(
    destination: TileIndex, base_address: Word,
    indices: TileIndex,
    expected: TileIndex, replacement: TileIndex,
    pad_value: TilePadValue) => boolean
begin
    return IndexedTLSUNumericDescriptorLegal(destination) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUExecutionMaskContentsDefined(expected) &&
           IndexedTLSUExecutionMaskContentsDefined(replacement) &&
           IndexedTLSUMemoryIndexDataTypeLegal(_Tiles[[indices]].data_type) &&
           IndexedTLSUTransferDataTypeLegal(
               _Tiles[[destination]].data_type) &&
           _Tiles[[destination]].valid_rows == _Tiles[[indices]].valid_rows &&
           _Tiles[[destination]].valid_columns ==
               _Tiles[[indices]].valid_columns &&
           _Tiles[[destination]].valid_rows == _Tiles[[expected]].valid_rows &&
           _Tiles[[destination]].valid_columns ==
               _Tiles[[expected]].valid_columns &&
           _Tiles[[destination]].valid_rows ==
               _Tiles[[replacement]].valid_rows &&
           _Tiles[[destination]].valid_columns ==
               _Tiles[[replacement]].valid_columns &&
           _Tiles[[destination]].data_type == _Tiles[[expected]].data_type &&
           _Tiles[[destination]].data_type ==
               _Tiles[[replacement]].data_type &&
           _Tiles[[destination]].layout == _Tiles[[indices]].layout &&
           _Tiles[[destination]].layout == _Tiles[[expected]].layout &&
           _Tiles[[destination]].layout == _Tiles[[replacement]].layout;
end;

readonly func TileOperandsLegal_MGATHER_CAS(
    destination: TileIndex, base_address: Word,
    indices: TileIndex,
    expected: TileIndex, replacement: TileIndex) => boolean
begin
    return TileOperandsLegal_MGATHER_CAS(destination, base_address,
        indices, expected, replacement, TilePad_Null);
end;

readonly func TileOperandsLegal_TPREFETCH(
    base_address: Word, row_stride_elements: Word,
    valid_columns: integer {1..65535},
    valid_rows: integer {1..65535},
    columns: integer {1..65535}) => boolean
begin
    return valid_columns <= columns && IsNonzeroPowerOfTwo(columns) &&
           valid_rows * valid_columns <= PTO_MODEL_TILE_ELEMENTS;
end;

readonly func TileOperandsLegal_TPREFETCH(
    base_address: Word, row_stride_elements: Word,
    valid_columns: integer {1..65535},
    valid_rows: integer {1..65535},
    columns: integer {1..65535},
    data_type: TileDataType) => boolean
begin
    return TileOperandsLegal_TPREFETCH(
               base_address, row_stride_elements, valid_columns,
               valid_rows, columns) &&
           TileCarrierOrPackedBaselineDataTypeSupported(data_type);
end;
```
<!-- GENERATED-ASL-END: unit -->
