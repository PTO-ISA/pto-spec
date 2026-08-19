// PTO-TEST: {"id":"PTO-AVS-TILE-TSUB-TYPES-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl","requirements":["PTO-INST-TILE-TSUB"],"kind":"boundary","summary":"TSUB accepts the closed arithmetic type set and rejects unassigned carriers","pass_condition":"FP32 and U8 pass mnemonic legality while HiF8 rejects before destination effects","related_sources":["asl/tile/model/legality/dtype-layout.asl","asl/tile/model/legality/operand-schema.asl"]}
func ConfigureTSUBType(data_type: TileDataType)
begin
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1, data_type,
            TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
end;

func main() => integer
begin
    assert InstructionContractDataTypeLegal_TSUB(TileDataType_FP32);
    assert InstructionContractDataTypeLegal_TSUB(TileDataType_U8);
    assert InstructionContractDataTypeLegal_TSUB(TileDataType_FP64);
    assert !InstructionContractDataTypeLegal_TSUB(TileDataType_HiF8);

    ResetProfileState();
    ConfigureTSUBType(TileDataType_FP32);
    assert InstructionContractOperandsLegal_TSUB(2, 0, 1);

    ResetProfileState();
    ConfigureTSUBType(TileDataType_HiF8);
    assert !InstructionContractOperandsLegal_TSUB(2, 0, 1);
    assert !_Tiles[[2]].contents_defined;
    return 0;
end;
