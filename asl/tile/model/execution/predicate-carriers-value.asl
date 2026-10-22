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

