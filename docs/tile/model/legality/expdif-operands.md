<!-- GENERATED FROM: asl/tile/model/legality/expdif-operands.asl -->
# Expdif Operands

**Normative ASL source:** `asl/tile/model/legality/expdif-operands.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-EXPDIF-OPERANDS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-expdif-operands-purpose role=purpose-scope -->
## Purpose and scope

This unit owns operand legality for `TEXPDIF`, which computes natural `exp(source0 - source1)` for each valid coordinate (each active coordinate when an ExecutionMask is in force). `source0` is the minuend and `source1` is the subtrahend.

- `TileExpdifSourceOperationType` finds the source operation type.
- `TileExpdifBundleGeometryMatches` compares one Tile with the bundle's `B.DIM` values.
- `TileExpdifLogicalShapeMatch` compares two Tiles' valid region and layout.
- `TileExpdifSourcesLegal` checks both sources.
- `TileOperandsLegal_ExecuteTileExpdif` checks the whole operand set, including the destination.

<!-- PTO-READER-BLOCK: tile-model-legality-expdif-operands-concepts role=concepts-state -->
## Concepts and visible state

The source operation type is the type used to read both sources. When a bundle Tile operation is selected, it comes from the `BSTART` DataType; if that DataType is not valid, the predicates return FALSE. Outside a bundle, it is `source0`'s stored type.

The selected layout is `CurrentBundleTileLayout` inside a bundle, or `source0`'s layout otherwise. `TileElementwiseLayoutSupported` accepts only RowMajor, CUBE_M16, and CUBE_M32.

Bundle geometry comes from `B.DIM`: LB0 is ValidCol, LB1 is ValidRow (1 when omitted), and LB2 is Col (ValidCol when omitted). Each must be in 1 to 65535. Outside a bundle, the geometry match always passes.

<!-- PTO-READER-BLOCK: tile-model-legality-expdif-operands-rules role=rules-interactions -->
## Rules and interactions

`TileExpdifSourcesLegal` requires all of the following:

- A valid source operation type and a supported selected layout.
- Both sources are numeric storage and both use the selected layout.
- Equal valid rows, valid columns, and layout for the two sources.
- `TileElementwiseDescriptorLegal` for each source.
- Each source matches the bundle geometry.
- `TileElementwiseSourceEncodingsValidAs` for each source under the operation type, which also checks definedness and `TileCarrierWidthCompatible`.

`TileOperandsLegal_ExecuteTileExpdif` adds the type pair and the destination. `TileExpdifTypePairLegal` admits exactly (FP16, FP16), (BF16, BF16), (FP32, FP32), (FP16, FP32), and (BF16, FP32). The destination must be numeric, use the selected layout, pass `TileElementwiseDescriptorLegal`, match the bundle geometry, and share the valid region with `source0`.

Design point: for CUBE layouts, the expected physical column count is `TileCubeStorageColumns` of the bundle's Col, computed with each Tile's own data type. An FP16 source and an FP32 destination can therefore have different physical widths for the same logical Col, while sharing one logical valid region.

Design point: the source backing type may differ from the operation type if the carrier widths are compatible. The source descriptor is not retagged. Its bits are validated and read as the operation type.

Every destination type admitted by the type pair is FP16, BF16, or FP32. The EXP step runs at the destination type, or at FP32 for a mixed pair. When no special value applies, it calls `TileProfileUnary`, which routes EXP to `ReferenceTileUnaryFinite`; that helper asserts FP32, FP16, or BF16, so the admitted pairs stay within its range.

Bundle dispatch checks the type pair and `TileExpdifSourcesLegal` before it allocates the destination. The full `TileOperandsLegal_ExecuteTileExpdif` check then runs as the legality handler before any source snapshot or payload write; if it fails, `Fault_TileLegality` is raised and the allocated destination is rolled back. `ExecuteTileExpdif` also asserts the same predicate.

<!-- PTO-READER-BLOCK: tile-model-legality-expdif-operands-boundaries role=boundaries -->
## Architectural boundaries

`TEXPDIF` calls `TileOperandsLegal_ExecuteTileExpdif` as its operand legality handler. The bundle Tile schema calls `TileExpdifSourcesLegal` directly, after `SelectedBundleExponentialDifferenceTypes` has checked the type pair.

`TileOperandsLegal_ExecuteTileBinary` returns FALSE for `TileBinary_EXPDIF`, so `TEXPDIF` cannot pass through the generic binary path.

This unit does not check the B.DATR field schema, PE_MASK handling, or destination capacity. Those belong to bundle dispatch.

<!-- PTO-READER-BLOCK: tile-model-legality-expdif-operands-example role=example-usage -->
## Non-normative reading example

Consider `TEXPDIF` with operation type FP16, a B.DATR destination type of FP32, RowMajor layout, and `B.DIM LB0=16`, with LB1 and LB2 omitted.

- The pair (FP16, FP32) is admitted.
- The bundle geometry is ValidCol 16, ValidRow 1, Col 16.
- Both FP16 sources and the FP32 destination must have valid region 1 by 16, RowMajor, and 16 physical columns.
- A source stored as U16 is accepted, because U16 and FP16 are both 16 bits wide, and its bits are read as FP16.

A pair of (FP32, FP16) is rejected before any effect.

<!-- PTO-READER-BLOCK: tile-model-legality-expdif-operands-related role=related-owners-navigation -->
## Related owners

- [EXPDIF execution](../execution/expdif.md) computes the result after this check.
- [Data type and layout](dtype-layout.md) owns `TileExpdifTypePairLegal` and `TileElementwiseLayoutSupported`.
- [ExecutionMask source schema](execution-mask-source-schema.md) owns the source encoding checks.
- [Operand schema](operand-schema.md) owns `TileElementwiseDescriptorLegal`.
- [EXPDIF schema](../../../block/model/dispatch/expdif-schema.md) resolves the bundle type pair.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/expdif-operands.asl -->
```asl
// PTO-UNIT: {"classification":["model","legality","expdif-operands"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"],"id":"PTO-TILE-MODEL-LEGALITY-EXPDIF-OPERANDS","surface":"tile"}
readonly func TileExpdifSourceOperationType(source0: TileIndex)
    => (boolean, TileDataType)
begin
    if BundleTileOperationSelected() then
        if !_BundleOperation.data_type_valid then
            return (FALSE, TileDataType_FP64);
        end;
        return (
            TRUE,
            TileDataTypeFromEncoding(
                CurrentBundleTileOperationDataTypeCode()
                    as TileDataTypeEncoding));
    end;
    return (TRUE, _Tiles[[source0]].data_type);
end;

readonly func TileExpdifBundleGeometryMatches(index: TileIndex)
    => boolean
begin
    if !BundleTileOperationSelected() then return TRUE; end;
    let valid_columns_raw = UInt(_BundleDimensions[[0]]);
    let valid_rows_raw = if _BundleDimensionPresent[[1]] then
        UInt(_BundleDimensions[[1]]) else 1;
    let columns_raw = if _BundleDimensionPresent[[2]] then
        UInt(_BundleDimensions[[2]]) else valid_columns_raw;
    if valid_columns_raw < 1 || valid_columns_raw > 65535 ||
       valid_rows_raw < 1 || valid_rows_raw > 65535 ||
       columns_raw < 1 || columns_raw > 65535 then
        return FALSE;
    end;
    let valid_columns = valid_columns_raw as integer {1..65535};
    let valid_rows = valid_rows_raw as integer {1..65535};
    let columns = columns_raw as integer {1..65535};
    let tile = _Tiles[[index]];
    let selected_layout = CurrentBundleTileLayout();
    let expected_columns = if TileLayoutIsCube(selected_layout) then
        TileCubeStorageColumns(selected_layout, columns, tile.data_type)
    else
        columns;
    return tile.layout == selected_layout &&
           tile.valid_rows == valid_rows &&
           tile.valid_columns == valid_columns &&
           tile.columns == expected_columns;
end;

readonly func TileExpdifLogicalShapeMatch(
    left: TileIndex, right: TileIndex) => boolean
begin
    return _Tiles[[left]].valid_rows == _Tiles[[right]].valid_rows &&
           _Tiles[[left]].valid_columns == _Tiles[[right]].valid_columns &&
           _Tiles[[left]].layout == _Tiles[[right]].layout;
end;

readonly func TileExpdifSourcesLegal(
    source0: TileIndex, source1: TileIndex) => boolean
begin
    let (operation_type_valid, operation_type) =
        TileExpdifSourceOperationType(source0);
    if !operation_type_valid then return FALSE; end;
    let selected_layout = if BundleTileOperationSelected() then
        CurrentBundleTileLayout()
    else
        _Tiles[[source0]].layout;
    if !TileElementwiseLayoutSupported(selected_layout) ||
       _Tiles[[source0]].storage_kind != TileStorage_Numeric ||
       _Tiles[[source1]].storage_kind != TileStorage_Numeric ||
       _Tiles[[source0]].layout != selected_layout ||
       _Tiles[[source1]].layout != selected_layout ||
       !TileExpdifLogicalShapeMatch(source0, source1) ||
       !TileElementwiseDescriptorLegal(source0) ||
       !TileElementwiseDescriptorLegal(source1) ||
       !TileExpdifBundleGeometryMatches(source0) ||
       !TileExpdifBundleGeometryMatches(source1) ||
       !TileElementwiseSourceEncodingsValidAs(source0, operation_type) ||
       !TileElementwiseSourceEncodingsValidAs(source1, operation_type) then
        return FALSE;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_ExecuteTileExpdif(
    destination: TileIndex,
    source0: TileIndex,
    source1: TileIndex) => boolean
begin
    let (operation_type_valid, operation_type) =
        TileExpdifSourceOperationType(source0);
    let destination_tile = _Tiles[[destination]];
    let selected_layout = if BundleTileOperationSelected() then
        CurrentBundleTileLayout()
    else
        _Tiles[[source0]].layout;
    if !operation_type_valid ||
       !TileExpdifTypePairLegal(operation_type,
           destination_tile.data_type) ||
       !TileExpdifSourcesLegal(source0, source1) ||
       destination_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.layout != selected_layout ||
       !TileElementwiseDescriptorLegal(destination) ||
       !TileExpdifBundleGeometryMatches(destination) ||
       !TileExpdifLogicalShapeMatch(destination, source0) then
        return FALSE;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
