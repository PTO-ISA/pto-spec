// PTO-TEST: {"id":"PTO-AVS-TILE-TFMA-OPERANDS-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl","requirements":["PTO-TFMA-CONTRACT-001"],"kind":"boundary","summary":"TFMA requires four matching row-major descriptors and three defined sources.","pass_condition":"A complete matching tuple is legal and a layout mismatch is rejected.","related_sources":["asl/tile/model/legality/indexed-layout.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 3 looplimit 4 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_U64, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 4);
    assert InstructionContractOperandsLegal_TFMA(0, 1, 2, 3);

    _Tiles[[3]].layout = TileLayout_ColumnMajor;
    assert !InstructionContractOperandsLegal_TFMA(0, 1, 2, 3);
    return 0;
end;
