// PTO-TEST: {"id":"PTO-AVS-TILE-TLEA-LEGALITY-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TLEA.asl","requirements":["PTO-TLEA-CONTRACT-001"],"kind":"boundary","summary":"TLEA accepts only its closed index, destination, width, layout, and logical-shape domain.","pass_condition":"Boundary widths 7 and 65, unsupported source/destination pairs, mismatched logical shapes, and an in-place 32-to-64 descriptor pairing are illegal before execution.","related_sources":["asl/tile/model/legality/lea-operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 32, 2, 1, 1,
        TileDataType_U32, TileLayout_RowMajor);
    ConfigureTile(1, 128, 64, 1, 1, 1,
        TileDataType_U64, TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    assert TileOperandsLegal_TLEA(1, 0, Zeros{PTO_XLEN} + 8);
    assert !TileOperandsLegal_TLEA(1, 0, Zeros{PTO_XLEN} + 7);
    assert !TileOperandsLegal_TLEA(1, 0, Zeros{PTO_XLEN} + 65);
    assert !TileOperandsLegal_TLEA(0, 0, Zeros{PTO_XLEN} + 8);

    ConfigureTile(2, 128, 64, 1, 1, 1,
        TileDataType_S64, TileLayout_RowMajor);
    assert !TileOperandsLegal_TLEA(2, 0, Zeros{PTO_XLEN} + 8);

    ConfigureTile(3, 128, 16, 2, 1, 1,
        TileDataType_U16, TileLayout_RowMajor);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 1);
    assert !TileOperandsLegal_TLEA(1, 3, Zeros{PTO_XLEN} + 8);

    ConfigureTile(4, 128, 64, 2, 1, 2,
        TileDataType_U64, TileLayout_RowMajor);
    assert !TileOperandsLegal_TLEA(4, 0, Zeros{PTO_XLEN} + 8);
    return 0;
end;
