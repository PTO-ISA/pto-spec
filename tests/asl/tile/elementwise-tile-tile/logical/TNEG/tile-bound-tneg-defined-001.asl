// PTO-TEST: {"id":"PTO-AVS-TILE-TNEG-DEFINED-001","source":"asl/tile/elementwise-tile-tile/logical/TNEG.asl","requirements":["PTO-TNEG-CONTRACT-001"],"kind":"boundary","summary":"TNEG requires a fully defined source Tile.","pass_condition":"An undefined source makes TNEG operand legality false before destination effects.","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);

    assert !InstructionContractOperandsLegal_TNEG(1, 0);
    assert !_Tiles[[1]].contents_defined;
    return 0;
end;
