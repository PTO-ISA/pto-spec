// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","surface":"tile","classification":["model","legality","dtype-layout"],"depends_on":["PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE"]}
pure func TileTeplRawCarrierTypeSupported(data_type: TileDataType) => boolean
begin
    // PTO-v0 TEPL operates over the raw XLEN carrier for every architectural
    // tile type. Target numeric interpretation, rounding, saturation, and
    // exceptional values remain Stage 5 profile obligations.
    case data_type of
        when TileDataType_FP64, TileDataType_FP32, TileDataType_TF32,
             TileDataType_HF32, TileDataType_FP16, TileDataType_BF16,
             TileDataType_HiF8, TileDataType_E4M3, TileDataType_E5M2,
             TileDataType_E3M2, TileDataType_E2M3,
             TileDataType_E2M1X2, TileDataType_E1M2X2,
             TileDataType_E8M0, TileDataType_HiF4X2,
             TileDataType_S64, TileDataType_S32, TileDataType_S16,
             TileDataType_S8, TileDataType_S4X2,
             TileDataType_U64, TileDataType_U32, TileDataType_U16,
             TileDataType_U8, TileDataType_U4X2 => return TRUE;
        otherwise => return FALSE;
    end;
end;

readonly func TileLogicalShapeMatch(left: TileIndex, right: TileIndex) => boolean
begin
    return TileDescriptorLegal(left) && TileDescriptorLegal(right) &&
           _Tiles[[left]].rows == _Tiles[[right]].rows &&
           _Tiles[[left]].columns == _Tiles[[right]].columns &&
           _Tiles[[left]].valid_rows == _Tiles[[right]].valid_rows &&
           _Tiles[[left]].valid_columns == _Tiles[[right]].valid_columns &&
           _Tiles[[left]].layout == _Tiles[[right]].layout;
end;

readonly func TileShapeAndTypeMatch(left: TileIndex, right: TileIndex) => boolean
begin
    return TileLogicalShapeMatch(left, right) &&
           _Tiles[[left]].data_type == _Tiles[[right]].data_type;
end;
