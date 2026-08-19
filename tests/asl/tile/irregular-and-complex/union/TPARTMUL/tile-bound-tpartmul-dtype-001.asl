// PTO-TEST: {"id":"PTO-AVS-TILE-TPARTMUL-DTYPE-001","source":"asl/tile/irregular-and-complex/union/TPARTMUL.asl","requirements":["PTO-INST-TILE-TPARTMUL"],"kind":"boundary","summary":"partial multiplication uses the complete nine-type partial arithmetic set","pass_condition":"S8 and U8 pass TPARTMUL together with the other partial arithmetic families","related_sources":["asl/tile/model/legality/indexed-layout.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TPARTADD(TileDataType_S8);
    assert InstructionContractDataTypeLegal_TPARTADD(TileDataType_U8);
    assert InstructionContractDataTypeLegal_TPARTMAX(TileDataType_S8);
    assert InstructionContractDataTypeLegal_TPARTMAX(TileDataType_U8);
    assert InstructionContractDataTypeLegal_TPARTMIN(TileDataType_S8);
    assert InstructionContractDataTypeLegal_TPARTMIN(TileDataType_U8);
    assert InstructionContractDataTypeLegal_TPARTMUL(TileDataType_S8);
    assert InstructionContractDataTypeLegal_TPARTMUL(TileDataType_U8);
    assert InstructionContractDataTypeLegal_TPARTMUL(TileDataType_S16);
    assert InstructionContractDataTypeLegal_TPARTMUL(TileDataType_U16);
    return 0;
end;
