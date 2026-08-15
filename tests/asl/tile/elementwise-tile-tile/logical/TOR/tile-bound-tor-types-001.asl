// PTO-TEST: {"id":"PTO-AVS-TILE-TOR-TYPES-001","source":"asl/tile/elementwise-tile-tile/logical/TOR.asl","requirements":["PTO-INST-TILE-TOR"],"kind":"boundary","summary":"TOR accepts only the eight scalar integer Tile types","pass_condition":"S8 and U64 pass while BF16 and S4X2 reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TOR(TileDataType_S8);
    assert InstructionContractDataTypeLegal_TOR(TileDataType_U64);
    assert !InstructionContractDataTypeLegal_TOR(TileDataType_BF16);
    assert !InstructionContractDataTypeLegal_TOR(TileDataType_S4X2);
    return 0;
end;
