// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-PADDING-001","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-TSEL-CONTRACT-001"],"kind":"state-transition","summary":"TSEL applies numeric PadValue outside its valid destination rectangle","pass_condition":"Min defines integer padding as zero while omitted Null leaves the same physical coordinate undefined","related_sources":["asl/tile/model/definedness/elements.asl"]}
func ConfigurePaddedSelection()
begin
    ConfigurePredicateTile(0, 128, 8, 2, 1, 1);
    ConfigureTile(1, 128, 8, 2, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 8, 2, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(3, 128, 8, 2, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTilePredicateBit(0, 0, 0, TRUE);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 9);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigurePaddedSelection();
    SetBundleDataAttributeState(
        Zeros{5} + 24,
        Zeros{5},
        '10',
        Zeros{3},
        Zeros{3},
        FALSE,
        FALSE);
    _BundleDataAttributesPresent = TRUE;
    ExecuteTileSelect(3, 0, 1, 2);
    assert TileElementDefined(3, 0, 1);
    assert ReadTileElement(3, 0, 1) == Zeros{PTO_XLEN};

    ResetProfileState();
    ConfigurePaddedSelection();
    ExecuteTileSelect(3, 0, 1, 2);
    assert !TileElementDefined(3, 0, 1);
    return 0;
end;
