// PTO-TEST: {"id":"PTO-AVS-TILE-STAGE4-CARRIER-TYPES-001","source":"asl/tile/model/legality/dtype-layout.asl","requirements":[],"kind":"boundary","summary":"shared dtype helpers preserve each accepted instruction-family domain","pass_condition":"arithmetic, integer logical, select, generation, Move24, IMG2COL, GMOV, prefetch, and regular TLSU representatives match their closed sets","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TAND(TileDataType_U64);
    assert !InstructionContractDataTypeLegal_TAND(TileDataType_E3M2);
    assert !InstructionContractDataTypeLegal_TOR(TileDataType_HF32);
    assert InstructionContractDataTypeLegal_TXOR(TileDataType_U16);
    assert InstructionContractDataTypeLegal_TSEL(TileDataType_FP64);
    assert InstructionContractDataTypeLegal_TSEL(TileDataType_U64);
    assert InstructionContractDataTypeLegal_TSEL(TileDataType_BF16);
    assert !InstructionContractDataTypeLegal_TSEL(TileDataType_HiF8);
    assert !InstructionContractDataTypeLegal_TANDS(TileDataType_E2M3);
    assert !InstructionContractDataTypeLegal_TORS(TileDataType_TF32);
    assert InstructionContractDataTypeLegal_TXORS(TileDataType_S8);
    assert InstructionContractDataTypeLegal_TSELS(TileDataType_FP32);
    assert !InstructionContractDataTypeLegal_TROWEXPAND(TileDataType_HiF8);
    assert InstructionContractDataTypeLegal_TROWEXPAND(TileDataType_U64);
    assert InstructionContractDataTypeLegal_TCOLEXPAND(TileDataType_U32);
    assert !InstructionContractDataTypeLegal_TEXPANDS(TileDataType_E3M2);
    assert InstructionContractDataTypeLegal_TEXPANDS(TileDataType_S64);
    assert InstructionContractDataTypeLegal_TFILLPAD(TileDataType_HF32);
    assert InstructionContractDataTypeLegal_TEXTRACT(TileDataType_BF16);
    assert InstructionContractDataTypeLegal_TINSERT(TileDataType_E2M3);
    assert InstructionContractDataTypeLegal_TINSERT(TileDataType_FP64);
    assert InstructionContractDataTypeLegal_TTRANS(TileDataType_S32);
    assert !InstructionContractDataTypeLegal_TIMG2COL(TileDataType_E3M2);
    assert InstructionContractDataTypeLegal_TIMG2COL(TileDataType_U8);
    assert InstructionContractDataTypeLegal_GMOV(TileDataType_TF32);
    assert InstructionContractDataTypeLegal_TPREFETCH(
        TileDataTypeToEncoding(TileDataType_FP32));
    assert InstructionContractDataTypeLegal_TLOAD(
        TileDataTypeToEncoding(TileDataType_FP32));
    assert InstructionContractDataTypeLegal_TSTORE(
        TileDataTypeToEncoding(TileDataType_BF16));

    assert !InstructionContractDataTypeLegal_TAND(TileDataType_FP64);
    assert !InstructionContractDataTypeLegal_TIMG2COL(TileDataType_FP64);
    assert !InstructionContractDataTypeLegal_GMOV(TileDataType_FP64);
    assert !InstructionContractDataTypeLegal_TPREFETCH(
        TileDataTypeToEncoding(TileDataType_FP64));
    assert InstructionContractDataTypeLegal_TLOAD(
        TileDataTypeToEncoding(TileDataType_FP64));
    assert InstructionContractDataTypeLegal_TSTORE(
        TileDataTypeToEncoding(TileDataType_FP64));
    assert !InstructionContractDataTypeLegal_TAND(TileDataType_U4X2);
    assert !InstructionContractDataTypeLegal_TIMG2COL(TileDataType_U4X2);
    assert InstructionContractDataTypeLegal_TINSERT(TileDataType_U4X2);
    assert InstructionContractDataTypeLegal_TLOAD(
        TileDataTypeToEncoding(TileDataType_U4X2));
    assert InstructionContractDataTypeLegal_TSTORE(
        TileDataTypeToEncoding(TileDataType_U4X2));
    return 0;
end;
