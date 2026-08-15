// PTO-TEST: {"id":"PTO-AVS-TILE-TEXPANDS-PADDING-001","source":"asl/tile/tile-scalar-and-immediate/initialization/TEXPANDS.asl","requirements":["PTO-INST-TILE-TEXPANDS"],"kind":"state-transition","summary":"TEXPANDS fills the valid rectangle and applies the selected padding policy","pass_condition":"Zero defines physical padding while omitted Null leaves the same coordinates undefined","related_sources":["asl/tile/model/execution/elementwise.asl","asl/tile/model/definedness/elements.asl"]}
func ConfigureTEXPANDSDestination()
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
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTEXPANDSDestination();
    SetBundleDataAttributeState(
        Zeros{5} + 24,
        Zeros{5},
        '00',
        Zeros{3},
        Zeros{3},
        FALSE,
        FALSE);
    _BundleDataAttributesPresent = TRUE;
    ExecuteTileFillScalar(0, Zeros{PTO_XLEN} + 7);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 7;
    assert TileElementDefined(0, 0, 1);
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN};

    ResetProfileState();
    ConfigureTEXPANDSDestination();
    ExecuteTileFillScalar(0, Zeros{PTO_XLEN} + 7);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 7;
    assert !TileElementDefined(0, 0, 1);
    return 0;
end;
