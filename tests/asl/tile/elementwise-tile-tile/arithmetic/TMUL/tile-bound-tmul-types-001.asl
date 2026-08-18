// PTO-TEST: {"id":"PTO-AVS-TILE-TMUL-TYPES-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMUL.asl","requirements":["PTO-INST-TILE-TMUL"],"kind":"boundary","summary":"TMUL accepts the closed arithmetic type set and rejects unassigned carriers","pass_condition":"FP16 and S8 pass mnemonic legality while U4X2 rejects before destination effects","related_sources":["asl/tile/model/legality/dtype-layout.asl","asl/tile/model/legality/operand-schema.asl"]}
func ConfigureTMULType(data_type: TileDataType)
begin
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1, data_type,
            TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
end;

func main() => integer
begin
    assert InstructionContractDataTypeLegal_TMUL(TileDataType_FP16);
    assert InstructionContractDataTypeLegal_TMUL(TileDataType_S16);
    assert !InstructionContractDataTypeLegal_TMUL(TileDataType_S8);
    assert !InstructionContractDataTypeLegal_TMUL(TileDataType_U4X2);

    ResetProfileState();
    ConfigureTMULType(TileDataType_S16);
    assert InstructionContractOperandsLegal_TMUL(2, 0, 1);

    ResetProfileState();
    ConfigureTMULType(TileDataType_S8);
    assert !InstructionContractOperandsLegal_TMUL(2, 0, 1);
    assert !_Tiles[[2]].contents_defined;
    return 0;
end;
