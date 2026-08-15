// PTO-TEST: {"id":"PTO-AVS-TILE-TADD-PADDING-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TADD.asl","requirements":["PTO-INST-TILE-TADD"],"kind":"state-transition","summary":"TADD applies the selected pad value outside the valid destination rectangle","pass_condition":"Zero defines physical padding as zero while Null leaves the same coordinates undefined","related_sources":["asl/tile/model/execution/elementwise.asl","asl/tile/model/definedness/elements.asl"]}
func ConfigurePaddedBinaryTiles()
begin
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 8, 2, 1, 1,
            TileDataType_U64, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 5);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigurePaddedBinaryTiles();
    SetBundleDataAttributeState(Zeros{5} + 24, Zeros{5}, '00',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    ExecuteTileBinary(TileBinary_ADD, 2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 12;
    assert TileElementDefined(2, 0, 1);
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN};
    assert TileElementDefined(2, 7, 1);

    ResetProfileState();
    ConfigurePaddedBinaryTiles();
    ExecuteTileBinary(TileBinary_ADD, 2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 12;
    assert !TileElementDefined(2, 0, 1);
    assert !TileElementDefined(2, 7, 1);
    return 0;
end;
