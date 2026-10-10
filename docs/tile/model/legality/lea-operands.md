<!-- GENERATED FROM: asl/tile/model/legality/lea-operands.asl -->
# Lea Operands

**Normative ASL source:** `asl/tile/model/legality/lea-operands.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-LEA-OPERANDS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-lea-operands-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the reusable type, width, logical-shape, descriptor, and source-definedness predicates for `TLEA`. Its main predicate, `TileOperandsLegal_TLEA`, checks the already-resolved source and destination immediately before execution.

<!-- PTO-READER-BLOCK: tile-model-legality-lea-operands-concepts role=concepts-state -->
## Concepts and visible state

`TileLEAIndexDataTypeLegal` accepts exactly `S32`, `U32`, `S64`, and `U64`. `TileLEADestinationDataType` maps the signed pair to `S64` and the unsigned pair to `U64`. `TileLEAElementBitsLegal` accepts exactly 8, 16, 32, and 64.

The selected source operation type comes from the current bundle view. When bundle execution is active, `TileLEABundleLogicalShapeMatches` also compares each operand's valid rows, valid columns, and layout with `LB1`, `LB0`, and the current bundle layout.

<!-- PTO-READER-BLOCK: tile-model-legality-lea-operands-rules role=rules-interactions -->
## Rules and interactions

`TileOperandsLegal_TLEA` requires the selected operation type to resolve, equal the source backing type, and belong to the four accepted index types. It requires a legal element width, numeric source and destination storage, the same supported elementwise layout, and the same logical valid shape.

The source and destination descriptors are checked independently with `TileElementwiseDescriptorLegal`; their physical rows, columns, and capacities need not be identical. The destination type must be the corresponding `S64` or `U64`, the source coordinates that execution can read must be defined, and both operands must match the bundle logical shape.

<!-- PTO-READER-BLOCK: tile-model-legality-lea-operands-boundaries role=boundaries -->
## Architectural boundaries

This unit does not bind commands, validate unused `B.IOR` fields, allocate the destination, or compute the byte-offset product. Those responsibilities belong to bundle schema, destination allocation, and execution respectively.

The predicates permit only Local numeric descriptors in `RowMajor` or `CUBE_M32`. Shared, packed four-bit, floating, narrower integer, `CUBE_M16`, and `CUBE_N8` forms fail through the type, storage, or descriptor checks. `CUBE_M16` is excluded because every result is `S64` or `U64`.

<!-- PTO-READER-BLOCK: tile-model-legality-lea-operands-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative rules.

An `S32` source and `S64` destination can both have logical shape 7 x 60 in `CUBE_M32` while using different physical storage. The source uses ordinary 32-bit CELL geometry; the destination charges a complete low/high CELL pair per logical column. The pair is legal when each descriptor independently satisfies that geometry and capacity, both match the bundle's 7 x 60 logical shape, and active source coordinates are defined.

<!-- PTO-READER-BLOCK: tile-model-legality-lea-operands-related role=related-owners-navigation -->
## Related owners

- [TLEA bundle schema](../../../block/model/dispatch/lea-schema.md) checks command bindings before allocation.
- [TLEA execution](../execution/lea.md) consumes these preconditions.
- [Data type and layout legality](dtype-layout.md) owns elementwise descriptor and layout checks.
- [TLEA](../../tile-scalar-and-immediate/arithmetic/TLEA.md) is the instruction page.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/lea-operands.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-LEA-OPERANDS","surface":"tile","classification":["model","legality","lea-operands"],"depends_on":["PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA","PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"]}

pure func TileLEAIndexDataTypeLegal(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_S32 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_S64 ||
           data_type == TileDataType_U64;
end;

pure func TileLEADestinationDataType(data_type: TileDataType) => TileDataType
begin
    assert TileLEAIndexDataTypeLegal(data_type);
    if data_type == TileDataType_S32 || data_type == TileDataType_S64 then
        return TileDataType_S64;
    end;
    return TileDataType_U64;
end;

pure func TileLEAElementBitsLegal(element_bits: Word) => boolean
begin
    return element_bits == Zeros{PTO_XLEN} + 8 ||
           element_bits == Zeros{PTO_XLEN} + 16 ||
           element_bits == Zeros{PTO_XLEN} + 32 ||
           element_bits == Zeros{PTO_XLEN} + 64;
end;

readonly func TileLEASourceOperationType(source: TileIndex)
    => (boolean, TileDataType)
begin
    return ResolveTileSelectedOperationType(_Tiles[[source]].data_type);
end;

readonly func TileLEABundleLogicalShapeMatches(index: TileIndex) => boolean
begin
    if !BundleTileOperationSelected() then return TRUE; end;
    let valid_columns_raw = UInt(_BundleDimensions[[0]]);
    let valid_rows_raw = if _BundleDimensionPresent[[1]] then
        UInt(_BundleDimensions[[1]]) else 1;
    if valid_columns_raw < 1 || valid_columns_raw > 65535 ||
       valid_rows_raw < 1 || valid_rows_raw > 65535 then
        return FALSE;
    end;
    let tile = _Tiles[[index]];
    return tile.valid_columns == valid_columns_raw &&
           tile.valid_rows == valid_rows_raw &&
           tile.layout == CurrentBundleTileLayout();
end;

readonly func TileOperandsLegal_TLEA(
    destination: TileIndex, source: TileIndex, element_bits: Word) => boolean
begin
    let (operation_type_valid, operation_type) =
        TileLEASourceOperationType(source);
    let source_tile = _Tiles[[source]];
    let destination_tile = _Tiles[[destination]];
    if !operation_type_valid ||
       operation_type != source_tile.data_type ||
       !TileLEAIndexDataTypeLegal(operation_type) ||
       !TileLEAElementBitsLegal(element_bits) ||
       !TileElementwiseLayoutSupported(source_tile.layout) ||
       source_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.layout != destination_tile.layout ||
       source_tile.valid_rows != destination_tile.valid_rows ||
       source_tile.valid_columns != destination_tile.valid_columns ||
       destination_tile.data_type != TileLEADestinationDataType(operation_type) ||
       !TileElementwiseDescriptorLegal(source) ||
       !TileElementwiseDescriptorLegal(destination) ||
       !TileElementwiseSourceContentsDefined(source) ||
       !TileLEABundleLogicalShapeMatches(source) ||
       !TileLEABundleLogicalShapeMatches(destination) then
        return FALSE;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
