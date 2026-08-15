// PTO-TEST: {"id":"PTO-AVS-TILE-TMIN-DEFINED-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMIN.asl","requirements":["PTO-TMIN-CONTRACT-001"],"kind":"boundary","summary":"TMIN requires both source Tiles to be defined.","pass_condition":"An undefined right source rejects before destination effects.","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_U64, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 3);

    assert !InstructionContractOperandsLegal_TMIN(2, 0, 1);
    assert !_Tiles[[2]].contents_defined;
    return 0;
end;
