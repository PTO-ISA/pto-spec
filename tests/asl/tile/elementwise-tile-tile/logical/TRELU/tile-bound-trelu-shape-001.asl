// PTO-TEST: {"id":"PTO-AVS-TILE-TRELU-SHAPE-001","source":"asl/tile/elementwise-tile-tile/logical/TRELU.asl","requirements":["PTO-TRELU-CONTRACT-001"],"kind":"boundary","summary":"TRELU requires matching physical and valid Tile shapes.","pass_condition":"A destination with a different physical column count makes TRELU operand legality false.","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 2, 8, 1, 1, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 2, 4, 1, 1, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xff);

    assert !InstructionContractOperandsLegal_TRELU(1, 0);
    assert !_Tiles[[1]].contents_defined;
    return 0;
end;
