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

// Operation types describe the interpretation and execution carrier for the
// selected operation.  A stored Tile descriptor may use a different dtype only
// when the physical element width is unchanged.
// NDF-BEGIN: PTO-TILE-CARRIER-REINTERPRETATION-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Cross-type source interpretation MUST require equal element width and MUST
// exclude packed types. Exact backing/operation type identity MUST remain legal.
// An active bundle with no resolvable operation type MUST reject rather than
// substituting the source backing type. A direct semantic call with no active
// bundle MAY use the source backing type as its explicit interpretation.
// NDF-END: PTO-TILE-CARRIER-REINTERPRETATION-001
pure func TileCarrierWidthCompatible(
    stored_type: TileDataType, operation_type: TileDataType) => boolean
begin
    if stored_type == operation_type then return TRUE; end;
    return !TileDataTypeIsFourBit(stored_type) &&
           !TileDataTypeIsFourBit(operation_type) &&
           TileElementBits(stored_type) == TileElementBits(operation_type);
end;

readonly func ResolveTileCarrierOperationType(
    source_backing_type: TileDataType) => (boolean, TileDataType)
begin
    let (operation_type_valid, operation_type) =
        ResolveBundleEffectiveDataType();
    if operation_type_valid then return (TRUE, operation_type); end;
    if !_BundleOperation.valid &&
       !_BundleDataAttributes.data_type_present then
        return (TRUE, source_backing_type);
    end;
    return (FALSE, source_backing_type);
end;

pure func TileOperationUsesSourceBackingDestination(
    operation: TileOperation) => boolean
begin
    return operation == TileOperation_TMOV;
end;

// Stage 4 carrier-only operations use the concrete dtype's physical byte
// width.  Packed X2 formats have a one-byte storage class but retain their
// baseline nibble semantics and are deliberately excluded here.
pure func TileCarrierOnlyDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return !TileDataTypeIsFourBit(data_type) &&
           TileElementBytes(data_type) <= 4;
end;

// These operations already have a packed-X2 baseline.  Preserve that
// baseline while admitting only the new non-packed B8/B16/B32 carrier set;
// B64 remains outside the Stage 4 extension.
pure func TileCarrierOrPackedBaselineDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return TileCarrierOnlyDataTypeSupported(data_type) ||
           TileDataTypeIsFourBit(data_type);
end;

// Move24 operations accept every assigned Tile DataType except HiF4X2.
// Keep that exact architectural exclusion independent of the narrower
// Stage-4 carrier helper used by other raw-carrier operations.
pure func TileCarrierOrMove24BaselineDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return TileMove24DataTypeSupported(data_type);
end;

pure func TileRegularTLSUDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return TileTeplRawCarrierTypeSupported(data_type);
end;

pure func TileVecArithmeticDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    case data_type of
        when TileDataType_FP64, TileDataType_FP32, TileDataType_TF32,
             TileDataType_HF32, TileDataType_FP16, TileDataType_BF16,
             TileDataType_E4M3, TileDataType_E5M2,
             TileDataType_S64, TileDataType_S32, TileDataType_S16,
             TileDataType_S8, TileDataType_U64, TileDataType_U32,
             TileDataType_U16, TileDataType_U8 => return TRUE;
        otherwise => return FALSE;
    end;
end;

pure func TileA9DataTypeSupported(
    data_type: TileDataType) => boolean
begin
    case data_type of
        when TileDataType_S32, TileDataType_U32,
             TileDataType_FP32, TileDataType_S16,
             TileDataType_U16, TileDataType_FP16,
             TileDataType_BF16, TileDataType_S8,
             TileDataType_U8 => return TRUE;
        otherwise => return FALSE;
    end;
end;

pure func TileA7DataTypeSupported(
    data_type: TileDataType) => boolean
begin
    case data_type of
        when TileDataType_S32, TileDataType_U32,
             TileDataType_FP32, TileDataType_S16,
             TileDataType_U16, TileDataType_FP16,
             TileDataType_BF16 => return TRUE;
        otherwise => return FALSE;
    end;
end;

pure func TileF3DataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP16 ||
           data_type == TileDataType_FP32 ||
           data_type == TileDataType_BF16;
end;

pure func TileFloatingElementwiseDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP64 ||
           data_type == TileDataType_FP32 ||
           data_type == TileDataType_TF32 ||
           data_type == TileDataType_HF32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16 ||
           data_type == TileDataType_E4M3 ||
           data_type == TileDataType_E5M2;
end;

pure func TileI6DataTypeSupported(
    data_type: TileDataType) => boolean
begin
    case data_type of
        when TileDataType_S32, TileDataType_U32,
             TileDataType_S16, TileDataType_U16,
             TileDataType_S8, TileDataType_U8 => return TRUE;
        otherwise => return FALSE;
    end;
end;

pure func TileTNegDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

pure func TileTReluDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

pure func TileArgReductionSourceDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return TileA9DataTypeSupported(data_type);
end;

pure func TileFusedMultiplyAddDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

pure func TileMove24DataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return data_type != TileDataType_HiF4X2;
end;

pure func TileFillPadDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

pure func TileImg2ColDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    case data_type of
        when TileDataType_FP32, TileDataType_FP16,
             TileDataType_BF16, TileDataType_S32,
             TileDataType_S16, TileDataType_S8,
             TileDataType_U32, TileDataType_U16,
             TileDataType_U8 => return TRUE;
        otherwise => return FALSE;
    end;
end;

pure func TileBinaryUsesClosedElementwiseContract(
    operation: TileBinaryOperation) => boolean
begin
    return operation == TileBinary_ADD ||
           operation == TileBinary_SUB ||
           operation == TileBinary_MUL ||
           operation == TileBinary_DIV ||
           operation == TileBinary_REM ||
           operation == TileBinary_MAX ||
           operation == TileBinary_MIN ||
           operation == TileBinary_AND ||
           operation == TileBinary_OR ||
           operation == TileBinary_XOR ||
           operation == TileBinary_SHL ||
           operation == TileBinary_SHR;
end;

// The closed elementwise family is also defined for Local CUBE M16/M32.
// CUBE_N8 remains a matrix/transport layout and is not an elementwise class.
pure func TileElementwiseLayoutSupported(layout: TileLayout) => boolean
begin
    return layout == TileLayout_RowMajor ||
           layout == TileLayout_CUBE_M16 ||
           layout == TileLayout_CUBE_M32;
end;

pure func TileVecScalarIntegerDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    case data_type of
        when TileDataType_S64, TileDataType_S32, TileDataType_S16,
             TileDataType_S8, TileDataType_U64, TileDataType_U32,
             TileDataType_U16, TileDataType_U8 => return TRUE;
        otherwise => return FALSE;
    end;
end;

pure func TileBinaryDataTypeSupported(
    operation: TileBinaryOperation,
    data_type: TileDataType) => boolean
begin
    if operation == TileBinary_AND ||
       operation == TileBinary_OR ||
       operation == TileBinary_XOR then
        return TileVecScalarIntegerDataTypeSupported(data_type);
    end;
    if operation == TileBinary_SHL || operation == TileBinary_SHR then
        return TileVecScalarIntegerDataTypeSupported(data_type);
    end;
    return TileVecArithmeticDataTypeSupported(data_type);
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
           _Tiles[[left]].storage_kind == _Tiles[[right]].storage_kind &&
           _Tiles[[left]].data_type == _Tiles[[right]].data_type;
end;
