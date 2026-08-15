// PTO-TEST: {"id":"PTO-AVS-TILE-TNOT-LAYOUT-001","source":"asl/tile/elementwise-tile-tile/logical/TNOT.asl","requirements":["PTO-TNOT-CONTRACT-001"],"kind":"boundary","summary":"TNOT accepts only row-major Tile operands.","pass_condition":"A column-major source and destination make TNOT operand legality false.","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 1 looplimit 2 do
        ConfigureTile(index as TileIndex, 128, 2, 8, 1, 1,
            TileDataType_U8, TileLayout_ColumnMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x0f);

    assert !InstructionContractOperandsLegal_TNOT(1, 0);
    assert !_Tiles[[1]].contents_defined;
    return 0;
end;
