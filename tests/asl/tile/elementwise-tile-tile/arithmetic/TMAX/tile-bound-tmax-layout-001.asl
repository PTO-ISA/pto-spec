// PTO-TEST: {"id":"PTO-AVS-TILE-TMAX-LAYOUT-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMAX.asl","requirements":["PTO-TMAX-CONTRACT-001"],"kind":"boundary","summary":"TMAX accepts only row-major Tile operands.","pass_condition":"Matching column-major descriptors reject before destination effects.","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 2, 8, 1, 1,
            TileDataType_U64, TileLayout_ColumnMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 5);

    assert !InstructionContractOperandsLegal_TMAX(2, 0, 1);
    assert !_Tiles[[2]].contents_defined;
    return 0;
end;
