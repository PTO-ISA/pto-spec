// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-ALIAS-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-INST-TILE-TCVT"],"kind":"execution","summary":"TCVT snapshots an aliased source and publishes padding with the converted payload","pass_condition":"an in-place conversion retains both valid elements and atomically defines zero padding outside the valid rectangle","related_sources":["asl/tile/model/numeric/formats.asl","asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        128,
        16,
        8,
        1,
        2,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 9);
    SetBundleDataAttributeState(
        Zeros{5} + 27,
        Zeros{5},
        '00',
        Zeros{3},
        Zeros{3},
        FALSE,
        FALSE);
    _BundleDataAttributesPresent = TRUE;

    assert TileOperandsLegal_TCVT(
        0,
        0,
        DefaultNumericExecutionControl());
    InstructionContractExecute_TCVT(
        0,
        0,
        DefaultNumericExecutionControl());
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 9;
    assert TileElementDefined(0, 0, 2);
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN};
    assert TileElementDefined(0, 15, 7);
    return 0;
end;
