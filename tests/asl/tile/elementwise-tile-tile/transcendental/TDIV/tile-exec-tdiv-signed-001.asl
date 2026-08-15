// PTO-TEST: {"id":"PTO-AVS-TILE-TDIV-SIGNED-001","source":"asl/tile/elementwise-tile-tile/transcendental/TDIV.asl","requirements":["PTO-INST-TILE-TDIV"],"kind":"execution","summary":"TDIV uses signed quotient semantics for signed integer Tiles","pass_condition":"signed negative seven divided by positive three produces signed negative two","related_sources":["asl/tile/model/execution/elementwise.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_S64, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} - 7);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    assert InstructionContractOperandsLegal_TDIV(2, 0, 1);
    InstructionContractExecute_TDIV(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} - 2;
    return 0;
end;
