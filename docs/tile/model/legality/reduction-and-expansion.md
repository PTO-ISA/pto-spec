<!-- GENERATED FROM: asl/tile/model/legality/reduction-and-expansion.asl -->
# Reduction And Expansion

**Normative ASL source:** `asl/tile/model/legality/reduction-and-expansion.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-reduction-and-expansion-purpose role=purpose-scope -->
## Purpose and scope

This unit holds the operand legality predicates for three instruction families:

- `TileOperandsLegal_ExecuteTileReduction` for the row and column reductions, for example `TROWSUM`, `TCOLMAX`, and `TROWARGMIN`.
- `TileOperandsLegal_ExecuteTileExpand` for the row and column expansions, for example `TROWEXPAND`, `TROWEXPANDADD`, and `TCOLEXPANDEXPDIF`.
- `TileOperandsLegal_ExecuteTileFillScalar` for `TEXPANDS`.

Each instruction's `InstructionContractOperandsLegal_*` returns one of these predicates. `ExecuteTileReduction`, `ExecuteTileExpand`, and `ExecuteTileFillScalar` assert the same predicate before they build a result. A predicate returns FALSE instead of changing state, so an illegal operand set writes no destination element.

<!-- PTO-READER-BLOCK: tile-model-legality-reduction-and-expansion-concepts role=concepts-state -->
## Concepts and visible state

Supported layouts are `RowMajor`, `CUBE_M16`, and `CUBE_M32` (`TileReductionAndExpansionLayoutSupported`). A RowMajor Tile must pass `TileDescriptorLegal`; a CUBE Tile must pass `TileCubeDescriptorLegal`.

A source is legal for an operation type when it is a Numeric Tile, its stored type has the same carrier width as the operation type (`TileCarrierWidthCompatible`), its contents are defined, and each consumed element has a valid encoding for the operation type. With an ExecutionMask in force, the source must match the mask layout and valid shape, and only active elements are checked.

A broadcast Tile supplies one value per destination row or column. The row axis uses column slot 0 for RowMajor. For CUBE layouts, the slot comes from the byte offset in `B.DATR.RMode` divided by the element size. The column axis always uses broadcast row 0.

<!-- PTO-READER-BLOCK: tile-model-legality-reduction-and-expansion-rules role=rules-interactions -->
## Rules and interactions

Reductions require a destination that differs from the source, the same layout on both, and a nonzero source valid shape. `ARGMIN` and `ARGMAX` require a source type from `TileArgReductionSourceDataTypeSupported` and a U32 destination. The other reductions require a type from `TileVecArithmeticDataTypeSupported`, and the destination type equals it. A row reduction produces valid shape rows by 1; a column reduction produces 1 by columns. The physical destination shape is also checked: for RowMajor it is derived from capacity with `DerivedTileRows`, and for CUBE it is the cell-aligned storage extent.

Design point: `TileReductionSourceLegalAs` rejects any bundle with a valid ExecutionMask and any source of type RCPE6M2. The ASL comment states that reductions scan every valid coordinate and do not support the ExecutionMask validation state. The dispatch reduction schema applies the same mask rejection, so a reduction cannot run under an ExecutionMask.

Expansions require the destination, source, and broadcast Tiles to share one layout and be Numeric. The destination type must be in `TileVecArithmeticDataTypeSupported` and equal the operation type. Non-EXPDIF operations use one type for source and destination; EXPDIF uses the pair rule `TileExpdifTypePairLegal`. The broadcast must match the destination valid rows for the row axis, or valid columns for the column axis. Non-copy operations also require the source valid shape to equal the destination's.

Design point: for integer `DIV` expansions, `TileExpansionBroadcastNonzero` requires every broadcast value consumed by an active output to be defined and nonzero. Division by zero is rejected in preflight, and inactive outputs are not checked.

Design point: the copy form (`TROWEXPAND`, `TCOLEXPAND`) passes the broadcast as its source and checks consumed broadcast elements for definedness only, not encoding. The copied bits are not interpreted by any numeric helper.

`TEXPANDS` requires only a legal descriptor in a supported layout, a Numeric destination, and a type in `TileFillPadDataTypeSupported`; it places no rule on the scalar value.

<!-- PTO-READER-BLOCK: tile-model-legality-reduction-and-expansion-boundaries role=boundaries -->
## Architectural boundaries

`TileVecArithmeticDataTypeSupported` admits FP64, FP32, TF32, HF32, FP16, BF16, E4M3, and E5M2 among the floating types. Floating `SUM` and `PRODUCT` reductions and floating `ADD`, `SUB`, `MUL`, and `DIV` expansions reach `ScalarFPBinaryProfile`, which asserts that the type is FP64, FP32, FP16, or BF16. For TF32, HF32, E4M3, and E5M2 these operations pass legality but the numeric helper asserts against the type. `MIN`, `MAX`, `ARGMIN`, and `ARGMAX` use the floating order key, which accepts all eight types.

The CUBE row-broadcast selector is checked by `TileExpansionBroadcastSelectorLegal`: RowMajor requires offset 0; CUBE requires an offset aligned to the element size, below 8 for `CUBE_M16` or 4 for `CUBE_M32`, and a slot inside both the cell columns and the broadcast valid columns.

`TileReductionAndExpansionSourceLegal` is defined here, but a search of `asl/` finds no caller.

<!-- PTO-READER-BLOCK: tile-model-legality-reduction-and-expansion-example role=example-usage -->
## Non-normative reading example

Consider `TROWSUM` on an FP32 RowMajor source with valid shape 8 by 64 and no ExecutionMask. The destination has capacity 128 bytes.

- The destination valid shape must be 8 by 1.
- `DerivedTileRows(128, 1, FP32)` is 128 x 8 / 32 = 32, so the destination must have 32 rows and 1 column.
- The source contents must be defined, and each of the 512 source elements must have a valid FP32 encoding.

If the same bundle carried an ExecutionMask, the predicate would return FALSE and no destination element would be written.

<!-- PTO-READER-BLOCK: tile-model-legality-reduction-and-expansion-related role=related-owners-navigation -->
## Related owners

- [Reduction execution](../execution/reduction.md) and [expansion execution](../execution/expansion.md) run the operations after these checks.
- [Data type and layout legality](dtype-layout.md) owns the type sets and `TileExpdifTypePairLegal`.
- [Reduction schema](../../../block/model/dispatch/reduction-schema.md) and [expansion schema](../../../block/model/dispatch/expansion-schema.md) apply these rules during bundle dispatch.
- [CUBE cell geometry](../shape/cube-cell.md) owns the CUBE storage extents.
- [TROWSUM](../../reduce-and-expand/row-reduction/TROWSUM.md), [TROWEXPANDDIV](../../reduce-and-expand/row-expansion/TROWEXPANDDIV.md), and [TEXPANDS](../../tile-scalar-and-immediate/initialization/TEXPANDS.md) are representative instruction pages.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/reduction-and-expansion.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION","surface":"tile","classification":["model","legality","reduction-and-expansion"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}

pure func TileReductionAndExpansionLayoutSupported(layout: TileLayout)
    => boolean
begin
    return layout == TileLayout_RowMajor ||
           layout == TileLayout_CUBE_M16 ||
           layout == TileLayout_CUBE_M32;
end;

readonly func TileReductionAndExpansionDescriptorLegal(index: TileIndex)
    => boolean
begin
    let tile = _Tiles[[index]];
    if !TileReductionAndExpansionLayoutSupported(tile.layout) then
        return FALSE;
    end;
    if tile.layout == TileLayout_RowMajor then
        return TileDescriptorLegal(index);
    end;
    return TileCubeDescriptorLegal(tile);
end;

readonly func TileReductionAndExpansionSourceContentsDefined(index: TileIndex)
    => boolean
begin
    let tile = _Tiles[[index]];
    if !TileReductionAndExpansionDescriptorLegal(index) ||
       tile.storage_kind != TileStorage_Numeric then
        return FALSE;
    end;
    if !_BundleExecutionMask.valid then return tile.contents_defined; end;
    if tile.layout != _BundleExecutionMask.layout ||
       tile.valid_rows != _BundleExecutionMask.valid_rows ||
       tile.valid_columns != _BundleExecutionMask.valid_columns then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) &&
               !TileElementDefined(index, row as integer {0..65535},
                   column as integer {0..65535}) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileReductionAndExpansionSourceLegal(index: TileIndex)
    => boolean
begin
    let tile = _Tiles[[index]];
    if !TileReductionAndExpansionSourceContentsDefined(index) then
        return FALSE;
    end;
    if tile.layout == TileLayout_RowMajor then
        return TileSourceEncodingsValid(index);
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let element = TileLogicalLinearIndex(
                    tile, row as integer {0..65535},
                    column as integer {0..65535});
                if !TileNumericEncodingValid(
                       tile.data_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileReductionAndExpansionSourceLegalAs(
    index: TileIndex, operation_type: TileDataType) => boolean
begin
    let tile = _Tiles[[index]];
    if !TileReductionAndExpansionSourceContentsDefined(index) ||
       !TileCarrierWidthCompatible(tile.data_type, operation_type) then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let element = TileLogicalLinearIndex(
                    tile, row as integer {0..65535},
                    column as integer {0..65535});
                if !TileNumericEncodingValid(
                       operation_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileReductionSourceLegalAs(
    index: TileIndex, operation_type: TileDataType) => boolean
begin
    // Reductions scan every valid coordinate and do not support the shared
    // Local CUBE ExecutionMask validation state. Keep this rejection in the
    // reduction-only entry point so expansion retains its mask behavior.
    return !_BundleExecutionMask.valid &&
           _Tiles[[index]].data_type != TileDataType_RCPE6M2 &&
           TileReductionAndExpansionSourceLegalAs(index, operation_type);
end;

readonly func TileExpansionBroadcastElementsLegalAs(
    index: TileIndex, axis: TileAxis,
    operation_type: TileDataType, validate_encoding: boolean) => boolean
begin
    let tile = _Tiles[[index]];
    if !TileReductionAndExpansionDescriptorLegal(index) ||
       tile.storage_kind != TileStorage_Numeric ||
       !TileCarrierWidthCompatible(tile.data_type, operation_type) then
        return FALSE;
    end;
    if !_BundleExecutionMask.valid && !tile.contents_defined then
        return FALSE;
    end;
    if _BundleExecutionMask.valid &&
       tile.layout != _BundleExecutionMask.layout then
        return FALSE;
    end;
    if axis == TileAxis_Row then
        if !TileExpansionBroadcastSelectorLegal(
               index, axis, operation_type) then
            return FALSE;
        end;
        let broadcast_column = TileExpansionBroadcastSlot(
            axis, tile.layout, operation_type);
        if _BundleExecutionMask.valid &&
           tile.valid_rows != _BundleExecutionMask.valid_rows then
            return FALSE;
        end;
        for row = 0 to tile.valid_rows - 1 looplimit 65536 do
            var consumed = !_BundleExecutionMask.valid;
            if _BundleExecutionMask.valid then
                for column = 0 to _BundleExecutionMask.valid_columns - 1
                    looplimit 65536 do
                    if BundleExecutionMaskActiveAt(
                           tile.layout, row as integer {0..65535},
                           column as integer {0..65535}) then
                        consumed = TRUE;
                    end;
                end;
            end;
            if consumed then
                if !TileElementDefined(index,
                       row as integer {0..65535}, broadcast_column) then
                    return FALSE;
                end;
                let element = TileLogicalLinearIndex(
                    tile, row as integer {0..65535}, broadcast_column);
                if validate_encoding &&
                   !TileNumericEncodingValid(
                       operation_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    else
        if _BundleExecutionMask.valid &&
           tile.valid_columns != _BundleExecutionMask.valid_columns then
            return FALSE;
        end;
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            var consumed = !_BundleExecutionMask.valid;
            if _BundleExecutionMask.valid then
                for row = 0 to _BundleExecutionMask.valid_rows - 1
                    looplimit 65536 do
                    if BundleExecutionMaskActiveAt(
                           tile.layout, row as integer {0..65535},
                           column as integer {0..65535}) then
                        consumed = TRUE;
                    end;
                end;
            end;
            if consumed then
                if !TileElementDefined(index, 0,
                       column as integer {0..65535}) then
                    return FALSE;
                end;
                let element = TileLogicalLinearIndex(
                    tile, 0, column as integer {0..65535});
                if validate_encoding &&
                   !TileNumericEncodingValid(
                       operation_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileExpansionBroadcastLegalAs(
    index: TileIndex, axis: TileAxis,
    operation_type: TileDataType) => boolean
begin
    return TileExpansionBroadcastElementsLegalAs(
        index, axis, operation_type, TRUE);
end;

readonly func TileExpansionBroadcastByteOffset(axis: TileAxis)
    => integer {0..7}
begin
    if axis == TileAxis_Row && BundleTileOperationSelected() then
        return UInt(_BundleDataAttributes.rounding_mode)
            as integer {0..7};
    end;
    return 0;
end;

readonly func TileExpansionBroadcastSlot(
    axis: TileAxis, layout: TileLayout,
    operation_type: TileDataType) => integer {0..7}
begin
    if axis != TileAxis_Row || layout == TileLayout_RowMajor then
        return 0;
    end;
    let byte_offset = TileExpansionBroadcastByteOffset(axis);
    let element_bytes = TileElementBytes(operation_type);
    assert element_bytes == 1 || element_bytes == 2 ||
           element_bytes == 4 ||
           (layout == TileLayout_CUBE_M32 && element_bytes == 8);
    return (byte_offset DIV element_bytes) as integer {0..7};
end;

readonly func TileExpansionBroadcastSelectorLegal(
    index: TileIndex, axis: TileAxis,
    operation_type: TileDataType) => boolean
begin
    if axis != TileAxis_Row then return TRUE; end;
    let tile = _Tiles[[index]];
    let byte_offset = TileExpansionBroadcastByteOffset(axis);
    if tile.layout == TileLayout_RowMajor then
        return byte_offset == 0;
    end;
    if tile.layout != TileLayout_CUBE_M16 &&
       tile.layout != TileLayout_CUBE_M32 then
        return FALSE;
    end;
    let element_bytes = TileElementBytes(operation_type);
    if (element_bytes != 1 && element_bytes != 2 && element_bytes != 4 &&
        !(tile.layout == TileLayout_CUBE_M32 && element_bytes == 8)) ||
       byte_offset >= (if tile.layout == TileLayout_CUBE_M32 && element_bytes != 8 then 4 else 8) ||
       byte_offset MOD element_bytes != 0 then
        return FALSE;
    end;
    let slot = (byte_offset DIV element_bytes) as integer {0..7};
    return slot < TileCubeCellColumns(tile.layout, operation_type) &&
           slot < tile.valid_columns;
end;

readonly func TileExpansionBroadcastNonzero(
    axis: TileAxis, source: TileIndex, broadcast: TileIndex,
    operation_type: TileDataType) => boolean
begin
    let source_tile = _Tiles[[source]];
    let broadcast_tile = _Tiles[[broadcast]];
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   source_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let broadcast_row = if axis == TileAxis_Row then row else 0;
                let broadcast_column = if axis == TileAxis_Row then
                    TileExpansionBroadcastSlot(
                        axis, broadcast_tile.layout, operation_type)
                    else column;
                let element = TileLogicalLinearIndex(broadcast_tile,
                    broadcast_row as integer {0..65535},
                    broadcast_column as integer {0..65535});
                if !TileElementDefined(broadcast,
                       broadcast_row as integer {0..65535},
                       broadcast_column as integer {0..65535}) ||
                   IsZero(TileReadLogicalElement(broadcast_tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileReductionAndExpansionLogicalShapeMatch(
    left: TileIndex, right: TileIndex) => boolean
begin
    if !TileReductionAndExpansionDescriptorLegal(left) ||
       !TileReductionAndExpansionDescriptorLegal(right) then
        return FALSE;
    end;
    let left_tile = _Tiles[[left]];
    let right_tile = _Tiles[[right]];
    return left_tile.valid_rows == right_tile.valid_rows &&
           left_tile.valid_columns == right_tile.valid_columns &&
           left_tile.layout == right_tile.layout;
end;

readonly func TileOperandsLegal_ExecuteTileFillScalar(
    destination: TileIndex, scalar: Word) => boolean
begin
    return TileReductionAndExpansionDescriptorLegal(destination) &&
           _Tiles[[destination]].storage_kind == TileStorage_Numeric &&
           TileFillPadDataTypeSupported(
               _Tiles[[destination]].data_type);
end;

readonly func TileOperandsLegal_ExecuteTileReduction(
    operation: TileReductionOperation,
    axis: TileAxis,
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    if destination == source ||
       !TileReductionAndExpansionDescriptorLegal(destination) ||
       !TileReductionAndExpansionDescriptorLegal(source) then
        return FALSE;
    end;

    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let (operation_type_valid, operation_type) =
        ResolveTileSelectedOperationType(source_tile.data_type);
    if !operation_type_valid ||
       !TileReductionSourceLegalAs(source, operation_type) then
        return FALSE;
    end;
    let index_reduction =
        operation == TileReduction_ARGMIN ||
        operation == TileReduction_ARGMAX;
    let source_type_legal =
        if index_reduction then
            TileArgReductionSourceDataTypeSupported(operation_type)
        else
            TileVecArithmeticDataTypeSupported(operation_type);
    if destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.layout != source_tile.layout ||
       source_tile.valid_rows == 0 ||
       source_tile.valid_columns == 0 ||
           !source_type_legal then
        return FALSE;
    end;

    if index_reduction then
        if destination_tile.data_type != TileDataType_U32 then
            return FALSE;
        end;
    elsif destination_tile.data_type != operation_type then
        return FALSE;
    end;

    if axis == TileAxis_Row then
        if destination_tile.valid_rows != source_tile.valid_rows ||
           destination_tile.valid_columns != 1 then
            return FALSE;
        end;
        if source_tile.layout == TileLayout_RowMajor then
            return destination_tile.rows == DerivedTileRows(
                       destination_tile.capacity_bytes, 1,
                       destination_tile.data_type) &&
                   destination_tile.columns == 1;
        end;
        return destination_tile.rows == TileCubeStorageRows(
                   destination_tile.layout, source_tile.valid_rows,
                   destination_tile.data_type) &&
               destination_tile.columns == source_tile.columns;
    end;
    if destination_tile.valid_rows != 1 ||
       destination_tile.valid_columns != source_tile.valid_columns then
        return FALSE;
    end;
    if source_tile.layout == TileLayout_RowMajor then
        return destination_tile.rows == DerivedTileRows(
                   destination_tile.capacity_bytes, source_tile.columns,
                   destination_tile.data_type) &&
               destination_tile.columns == source_tile.columns;
    end;
    return destination_tile.rows == source_tile.rows &&
           destination_tile.columns == TileCubeStorageColumns(
               destination_tile.layout, source_tile.valid_columns,
               destination_tile.data_type);
end;

readonly func TileOperandsLegal_ExecuteTileExpandAs(
    operation: TileExpandOperation,
    axis: TileAxis,
    destination: TileIndex,
    source: TileIndex,
    broadcast_source: TileIndex,
    source_operation_type: TileDataType,
    destination_operation_type: TileDataType) => boolean
begin
    let copy = operation == TileExpand_COPY;
    let expdif = operation == TileExpand_EXPDIF;
    if !TileReductionAndExpansionDescriptorLegal(destination) ||
       !TileReductionAndExpansionDescriptorLegal(source) ||
       !TileReductionAndExpansionDescriptorLegal(broadcast_source) then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let broadcast_tile = _Tiles[[broadcast_source]];
    if destination_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.valid_rows == 0 ||
       destination_tile.valid_columns == 0 ||
       !TileVecArithmeticDataTypeSupported(destination_operation_type) ||
       destination_tile.data_type != destination_operation_type ||
       source_tile.storage_kind != TileStorage_Numeric ||
       broadcast_tile.storage_kind != TileStorage_Numeric ||
       broadcast_tile.layout != destination_tile.layout ||
       source_tile.layout != destination_tile.layout then
        return FALSE;
    end;

    if copy then
        if source != broadcast_source ||
           !TileExpansionBroadcastElementsLegalAs(
               broadcast_source, axis, destination_operation_type, FALSE) then
            return FALSE;
        end;
    else
        if !TileReductionAndExpansionSourceLegalAs(
               source, source_operation_type) ||
           !TileExpansionBroadcastLegalAs(
               broadcast_source, axis, source_operation_type) then
            return FALSE;
        end;
    end;

    if (expdif && !TileExpdifTypePairLegal(
                      source_operation_type, destination_operation_type)) ||
       (!expdif && source_operation_type != destination_operation_type) then
        return FALSE;
    end;

    let broadcast_shape_legal = if axis == TileAxis_Row then
        broadcast_tile.valid_rows == destination_tile.valid_rows &&
        broadcast_tile.valid_columns >= 1
    else
        broadcast_tile.valid_rows >= 1 &&
        broadcast_tile.valid_columns == destination_tile.valid_columns;
    if !broadcast_shape_legal then return FALSE; end;

    if !copy &&
       !TileReductionAndExpansionLogicalShapeMatch(destination, source) then
        return FALSE;
    end;

    if operation == TileExpand_DIV &&
       TileDataTypeIsInteger(destination_operation_type) then
        return TileExpansionBroadcastNonzero(
            axis, source, broadcast_source, source_operation_type);
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_ExecuteTileExpand(
    operation: TileExpandOperation,
    axis: TileAxis,
    destination: TileIndex,
    source: TileIndex,
    broadcast_source: TileIndex) => boolean
begin
    let expdif = operation == TileExpand_EXPDIF;
    let (operation_type_valid, selected_type) =
        ResolveTileSelectedOperationType(_Tiles[[destination]].data_type);
    if !operation_type_valid then return FALSE; end;
    let source_operation_type = if expdif && !BundleTileOperationSelected() then
        _Tiles[[source]].data_type else selected_type;
    let destination_operation_type = if expdif then
        _Tiles[[destination]].data_type else selected_type;
    return TileOperandsLegal_ExecuteTileExpandAs(
        operation, axis, destination, source, broadcast_source,
        source_operation_type, destination_operation_type);
end;
```
<!-- GENERATED-ASL-END: unit -->
