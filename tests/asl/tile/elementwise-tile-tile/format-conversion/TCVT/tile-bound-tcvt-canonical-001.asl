// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-CANONICAL-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-INST-TILE-TCVT"],"kind":"boundary","summary":"TCVT canonicalization is required exactly for private CUBE sources","pass_condition":"private CUBE source accepts Canonicalize with NORM while missing canonicalization, transformed layouts, and ordinary-source canonicalization reject","related_sources":["asl/tile/model/legality/operand-schema.asl","asl/block/model/state/control-state.asl"]}
func ConfigureTCVTCanonicalTiles(source_location: TileLocation)
begin
    ConfigureTile(
        0,
        256,
        8,
        8,
        2,
        2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        source_location);
    ConfigureTile(
        1,
        128,
        8,
        8,
        2,
        2,
        TileDataType_FP16,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN});
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTCVTCanonicalTiles(TileLocation_Matrix);
    SetBundleDataAttributeState(
        Zeros{5} + 4,
        Zeros{5},
        '11',
        Zeros{3},
        Zeros{3},
        FALSE,
        TRUE);
    _BundleDataAttributesPresent = TRUE;
    assert TileOperandsLegal_TCVT(
        1,
        0,
        DefaultNumericExecutionControl());

    _BundleDataAttributes.canonicalize = FALSE;
    assert !TileOperandsLegal_TCVT(
        1,
        0,
        DefaultNumericExecutionControl());

    _BundleDataAttributes.canonicalize = TRUE;
    _BundleDataAttributes.data_layout = Zeros{5} + 1;
    assert !TileOperandsLegal_TCVT(
        1,
        0,
        DefaultNumericExecutionControl());

    ResetProfileState();
    ConfigureTCVTCanonicalTiles(TileLocation_Any);
    SetBundleDataAttributeState(
        Zeros{5} + 4,
        Zeros{5},
        '11',
        Zeros{3},
        Zeros{3},
        FALSE,
        TRUE);
    _BundleDataAttributesPresent = TRUE;
    assert !TileOperandsLegal_TCVT(
        1,
        0,
        DefaultNumericExecutionControl());
    return 0;
end;
