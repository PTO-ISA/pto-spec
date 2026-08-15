// PTO-TEST: {"id":"PTO-AVS-TILE-TRELU-LAYOUT-001","source":"asl/tile/elementwise-tile-tile/logical/TRELU.asl","requirements":["PTO-TRELU-CONTRACT-001"],"kind":"boundary","summary":"TRELU accepts only row-major Tile operands.","pass_condition":"A column-major source and destination make TRELU operand legality false.","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 1 looplimit 2 do
        ConfigureTile(index as TileIndex, 128, 2, 8, 1, 1,
            TileDataType_S8, TileLayout_ColumnMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xff);

    assert !InstructionContractOperandsLegal_TRELU(1, 0);
    assert !_Tiles[[1]].contents_defined;
    return 0;
end;
