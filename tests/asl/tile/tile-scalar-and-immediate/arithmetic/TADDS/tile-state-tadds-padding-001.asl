// PTO-TEST: {"id":"PTO-AVS-TILE-TADDS-PADDING-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TADDS.asl","requirements":["PTO-INST-TILE-TADDS"],"kind":"state-transition","summary":"TADDS applies PadValue outside the valid destination rectangle","pass_condition":"Zero defines physical padding as zero while omitted Null leaves the same coordinates undefined","related_sources":["asl/tile/model/execution/elementwise.asl","asl/tile/model/definedness/elements.asl"]}
func ConfigurePaddedTADDS()
begin
    ConfigureTile(
        0,
        128,
        8,
        2,
        1,
        1,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        8,
        2,
        1,
        1,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigurePaddedTADDS();
    SetBundleDataAttributeState(
        Zeros{5} + 24,
        Zeros{5},
        '00',
        Zeros{3},
        Zeros{3},
        FALSE,
        FALSE);
    _BundleDataAttributesPresent = TRUE;
    ExecuteTileScalar(
        TileBinary_ADD,
        1,
        0,
        Zeros{PTO_XLEN} + 5);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 12;
    assert TileElementDefined(1, 0, 1);
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN};

    ResetProfileState();
    ConfigurePaddedTADDS();
    ExecuteTileScalar(
        TileBinary_ADD,
        1,
        0,
        Zeros{PTO_XLEN} + 5);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 12;
    assert !TileElementDefined(1, 0, 1);
    return 0;
end;
