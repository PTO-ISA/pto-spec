// PTO-TEST: {"id":"PTO-AVS-TILE-UNARY-SFU-OWNER-DOMAIN-002","source":"asl/tile/model/execution/unary.asl","requirements":["PTO-TLOG-CONTRACT-001","PTO-TRECIP-CONTRACT-001","PTO-TSQRT-CONTRACT-001","PTO-TRSQRT-CONTRACT-001","PTO-TEXP-CONTRACT-001"],"kind":"boundary","summary":"SFU unary legality preserves each mnemonic's exact dtype domain when adding FP64.","pass_condition":"LOG, RECIP, SQRT and RSQRT admit the four owner types and reject other floats; EXP retains eight types; decoded TF32 LOG rejects without changing the destination.","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func CheckNarrowSFUOwner(operation: TileUnaryOperation)
begin
    assert TileUnaryDataTypeSupported(operation, TileDataType_FP64);
    assert TileUnaryDataTypeSupported(operation, TileDataType_FP32);
    assert TileUnaryDataTypeSupported(operation, TileDataType_FP16);
    assert TileUnaryDataTypeSupported(operation, TileDataType_BF16);
    assert !TileUnaryDataTypeSupported(operation, TileDataType_TF32);
    assert !TileUnaryDataTypeSupported(operation, TileDataType_HF32);
    assert !TileUnaryDataTypeSupported(operation, TileDataType_E4M3);
    assert !TileUnaryDataTypeSupported(operation, TileDataType_E5M2);
    assert !TileUnaryDataTypeSupported(operation, TileDataType_S64);
    assert !TileUnaryDataTypeSupported(operation, TileDataType_U64);
end;

func main() => integer
begin
    CheckNarrowSFUOwner(TileUnary_LOG);
    CheckNarrowSFUOwner(TileUnary_RECIP);
    CheckNarrowSFUOwner(TileUnary_SQRT);
    CheckNarrowSFUOwner(TileUnary_RSQRT);
    assert TileUnaryDataTypeSupported(TileUnary_EXP, TileDataType_FP64);
    assert TileUnaryDataTypeSupported(TileUnary_EXP, TileDataType_FP32);
    assert TileUnaryDataTypeSupported(TileUnary_EXP, TileDataType_FP16);
    assert TileUnaryDataTypeSupported(TileUnary_EXP, TileDataType_BF16);
    assert TileUnaryDataTypeSupported(TileUnary_EXP, TileDataType_TF32);
    assert TileUnaryDataTypeSupported(TileUnary_EXP, TileDataType_HF32);
    assert TileUnaryDataTypeSupported(TileUnary_EXP, TileDataType_E4M3);
    assert TileUnaryDataTypeSupported(TileUnary_EXP, TileDataType_E5M2);
    assert !TileUnaryDataTypeSupported(TileUnary_EXP, TileDataType_S64);
    assert !TileUnaryDataTypeSupported(TileUnary_EXP, TileDataType_U64);
    ResetProfileState();
    for index = 0 to 1 looplimit 2 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_TF32, TileLayout_RowMajor);
    end;
    let old_value = Zeros{PTO_XLEN} + 0x3f800000;
    WriteTileElement(0, 0, 0, old_value);
    WriteTileElement(1, 0, 0, old_value);
    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 1;
    operands.source0 = 0;
    let (status, -) = ExecuteTileInstruction(TileDecode_TEPL,
        Zeros{12} + 0x013, operands);
    assert status == TileExecution_Rejected;
    assert ReadTileElement(1, 0, 0) == old_value;
    assert ReadTileElement(0, 0, 0) == old_value;
    return 0;
end;
