// PTO-TEST: {"id":"PTO-AVS-TILE-TMAX-FLOAT-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMAX.asl","requirements":["PTO-INST-TILE-TMAX"],"kind":"execution","summary":"TMAX orders ordinary floating carriers by numeric value","pass_condition":"the FP32 destination selects negative one over negative two through the mnemonic execution path","related_sources":["asl/arch/features/minmax-profile.asl","asl/tile/model/execution/minmax.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_FP32, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xc0000000);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0xbf800000);

    assert InstructionContractOperandsLegal_TMAX(2, 0, 1);
    InstructionContractExecute_TMAX(2, 0, 1);
    assert ReadTileElement(2, 0, 0) ==
        Zeros{PTO_XLEN} + 0xbf800000;
    return 0;
end;
