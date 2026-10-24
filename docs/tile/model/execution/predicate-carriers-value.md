<!-- GENERATED FROM: asl/tile/model/execution/predicate-carriers-value.asl -->
# Predicate Carriers Value

**Normative ASL source:** `asl/tile/model/execution/predicate-carriers-value.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS-VALUE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/predicate-carriers-value.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS-VALUE","surface":"tile","classification":["model","execution","predicate-carriers-value"],"depends_on":["PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS","PTO-TILE-MODEL-STATE-TYPES"]}

readonly func TileOperandsLegal_TGPR2TToValue(
    destination: TileOutputValueTarget,
    source0: TileIndex, source1: TileIndex,
    source2: TileIndex, source3: TileIndex) => boolean
begin
    let tile = destination.value;
    if source0 >= PTO_ABSOLUTE_GPR_COUNT ||
       source1 >= PTO_ABSOLUTE_GPR_COUNT ||
       source2 >= PTO_ABSOLUTE_GPR_COUNT ||
       source3 >= PTO_ABSOLUTE_GPR_COUNT ||
       !TileCubeDescriptorLegal(tile) ||
       tile.storage_kind != TileStorage_Numeric ||
       tile.data_type != TileDataType_U8 ||
       !TileLayoutIsCube(tile.layout) ||
       !TileTGPR2TRModeLegal(_BundleDataAttributes.rounding_mode) ||
       !TileTGPR2TPadLegal() then
        return FALSE;
    end;
    return (tile.layout == TileLayout_CUBE_M32 &&
            tile.valid_rows == 32 && tile.valid_columns == 4) ||
           (tile.layout == TileLayout_CUBE_M16 &&
            tile.valid_rows == 16 && tile.valid_columns == 8);
end;

func TGPR2TToValue(destination: TileOutputValueTarget,
                   source0: TileIndex, source1: TileIndex,
                   source2: TileIndex, source3: TileIndex) => TileInfo
begin
    let gpr0 = ReadGPR(source0 as GPRIndex);
    let gpr1 = ReadGPR(source1 as GPRIndex);
    let gpr2 = ReadGPR(source2 as GPRIndex);
    let gpr3 = ReadGPR(source3 as GPRIndex);
    let selected_pad = TileTGPR2TEffectivePadValue();
    var result = TileWithPadding(destination.value, selected_pad);
    let pad = TilePadValueForDataType(selected_pad,
        result.data_type);
    for row = 0 to result.valid_rows - 1 looplimit 32 do
        for column = 0 to result.valid_columns - 1 looplimit 8 do
            let index = TileLogicalLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            let value = if BundleExecutionMaskActiveAt(
                result.layout, row as integer {0..65535},
                column as integer {0..65535}) then pad else
                BundleExecutionMaskDestinationValue(
                    result.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
            result = TileInfoWithLogicalElementAndDefined(
                result, index, value, TRUE);
        end;
    end;
    let offset = TileTGPR2TByteOffset(
        _BundleDataAttributes.rounding_mode);
    if result.layout == TileLayout_CUBE_M32 then
        for row = 0 to 31 looplimit 32 do
            let index = TileLogicalLinearIndex(result,
                row as integer {0..65535}, offset);
            var value = Zeros{PTO_XLEN};
            value[7:0] = TileTGPR2TPackedRowByte(
                gpr0, gpr1, gpr2, gpr3, row as integer {0..31});
            if BundleExecutionMaskActiveAt(
                   result.layout, row as integer {0..65535}, offset) then
                result = TileInfoWithLogicalElementAndDefined(
                    result, index, value, TRUE);
            end;
        end;
    else
        for row = 0 to 15 looplimit 16 do
            let pair_start = (offset * 2) as integer {0..6};
            let low = TileLogicalLinearIndex(result,
                row as integer {0..65535}, pair_start);
            let high = TileLogicalLinearIndex(result,
                row as integer {0..65535}, pair_start + 1);
            var low_value = Zeros{PTO_XLEN};
            low_value[7:0] = TileTGPR2TPackedRowHalf(
                gpr0, gpr1, gpr2, gpr3, row as integer {0..15}, FALSE);
            if BundleExecutionMaskActiveAt(
                   result.layout, row as integer {0..65535},
                   pair_start) then
                result = TileInfoWithLogicalElementAndDefined(
                    result, low, low_value, TRUE);
            end;
            var high_value = Zeros{PTO_XLEN};
            high_value[7:0] = TileTGPR2TPackedRowHalf(
                gpr0, gpr1, gpr2, gpr3, row as integer {0..15}, TRUE);
            if BundleExecutionMaskActiveAt(
                   result.layout, row as integer {0..65535},
                   pair_start + 1) then
                result = TileInfoWithLogicalElementAndDefined(
                    result, high, high_value, TRUE);
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    return result;
end;



readonly func TileOperandsLegal_ExecuteTileSelectCUBEGPRAsToValue(
    destination: TileOutputValueTarget,
    source_true: TileIndex, source_false: TileIndex,
    operation_type: TileDataType) => boolean
begin
    let output = destination.value;
    let true_tile = _Tiles[[source_true]];
    let false_tile = _Tiles[[source_false]];
    return TileSelectDataTypeSupported(operation_type) &&
           TileCubePredicateGPRShapeLegalAs(source_true, operation_type) &&
           TileCubeNumericShapeMatch(source_true, source_false) &&
           TileCubeNumericContentsDefined(source_true) &&
           TileCubeNumericContentsDefined(source_false) &&
           TileCarrierWidthCompatible(true_tile.data_type, operation_type) &&
           TileCarrierWidthCompatible(false_tile.data_type, operation_type) &&
           TileCubeDescriptorLegal(output) &&
           output.storage_kind == TileStorage_Numeric &&
           output.data_type == operation_type &&
           TileCubeDescriptorLegal(true_tile) &&
           output.rows == true_tile.rows &&
           output.valid_rows == true_tile.valid_rows &&
           output.valid_columns == true_tile.valid_columns &&
           output.layout == true_tile.layout;
end;

func ExecuteTileSelectCUBEGPRAsToValue(
    destination: TileOutputValueTarget,
    mask_low: Word, mask_high: Word,
    source_true: TileIndex, source_false: TileIndex,
    operation_type: TileDataType) => TileInfo
begin
    assert TileOperandsLegal_ExecuteTileSelectCUBEGPRAsToValue(
        destination, source_true, source_false, operation_type);
    return TileSelectCUBEGPRAsValue(destination.value, mask_low, mask_high,
        source_true, source_false, operation_type);
end;

readonly func TileOperandsLegal_ExecuteTileSelectScalarCUBEGPRAsToValue(
    destination: TileOutputValueTarget,
    source_true: TileIndex, scalar_false: Word,
    operation_type: TileDataType) => boolean
begin
    let output = destination.value;
    let true_tile = _Tiles[[source_true]];
    return TileSelectDataTypeSupported(operation_type) &&
           TileCubePredicateGPRShapeLegalAs(source_true, operation_type) &&
           TileCubeNumericContentsDefined(source_true) &&
           TileCarrierWidthCompatible(true_tile.data_type, operation_type) &&
           TileCubeDescriptorLegal(output) &&
           output.storage_kind == TileStorage_Numeric &&
           output.data_type == operation_type &&
           TileCubeDescriptorLegal(true_tile) &&
           output.rows == true_tile.rows &&
           output.valid_rows == true_tile.valid_rows &&
           output.valid_columns == true_tile.valid_columns &&
           output.layout == true_tile.layout;
end;

func ExecuteTileSelectScalarCUBEGPRAsToValue(
    destination: TileOutputValueTarget,
    mask_low: Word, mask_high: Word,
    source_true: TileIndex, scalar_false: Word,
    operation_type: TileDataType) => TileInfo
begin
    assert TileOperandsLegal_ExecuteTileSelectScalarCUBEGPRAsToValue(
        destination, source_true, scalar_false, operation_type);
    return TileSelectScalarCUBEGPRAsValue(destination.value, mask_low,
        mask_high, source_true, scalar_false, operation_type);
end;
```
<!-- GENERATED-ASL-END: unit -->
