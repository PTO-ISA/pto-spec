// PTO-TEST: {"id":"PTO-AVS-TILE-TSHR-SIGNED-001","source":"asl/tile/elementwise-tile-tile/logical/TSHR.asl","requirements":["PTO-INST-TILE-TSHR"],"kind":"execution","summary":"TSHR uses arithmetic shift for signed elements and logical shift for unsigned elements","pass_condition":"S8 0x80 shifted by one yields low byte 0xC0 while U8 yields 0x40","related_sources":["asl/tile/model/execution/elementwise.asl"]}
func ConfigureTSHR(data_type: TileDataType)
begin
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1, data_type,
            TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 128);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTSHR(TileDataType_S8);
    assert InstructionContractOperandsLegal_TSHR(2, 0, 1);
    InstructionContractExecute_TSHR(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 192;

    ResetProfileState();
    ConfigureTSHR(TileDataType_U8);
    assert InstructionContractOperandsLegal_TSHR(2, 0, 1);
    InstructionContractExecute_TSHR(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 64;
    return 0;
end;
