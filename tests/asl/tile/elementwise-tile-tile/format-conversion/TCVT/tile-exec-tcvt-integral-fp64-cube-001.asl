// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-INTEGRAL-FP64-CUBE-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"execution","summary":"FP64 CUBE_M32 TCVT applies explicit integral rounding across two logical rows","pass_condition":"a two-CELL FP64 CUBE_M32 source rounds two nonintegral logical values under explicit RTZ to literal FP64 results with NX only, while preserving the source descriptor, payload, and null padding","related_sources":["asl/tile/model/shape/cube-double-cell.asl","asl/tile/model/numeric/tcvt-conversion.asl","asl/tile/model/numeric/formats.asl"]}
func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        0, 256, 2, 1, TileDataType_FP64, TileLayout_CUBE_M32);
    let destination_ready = ConfigureCubeTile(
        1, 256, 2, 1, TileDataType_FP64, TileLayout_CUBE_M32);
    assert source_ready && destination_ready;

    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3ffc000000000000);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 0xc002000000000000);
    MarkTileValidRegionDefined(0);
    let source_before = _Tiles[[0]];

    SetBundleDataAttributeState(
        TileDataTypeToEncoding(TileDataType_FP64), Zeros{5}, '11',
        Zeros{3}, '010', FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    let control = NumericExecutionControl {
        rounding_mode = NumericRound_RTZ,
        saturating = FALSE
    };

    assert _Tiles[[0]].rows == 32;
    assert _Tiles[[0]].columns == 1;
    assert _Tiles[[0]].capacity_bytes == 256;
    assert _Tiles[[0]].cube_cell_count == 2;
    assert TileOperandsLegal_TCVT(1, 0, control);
    InstructionContractExecute_TCVT(1, 0, control);

    assert _LastFault == Fault_None;
    assert _Tiles[[1]].data_type == TileDataType_FP64;
    assert _Tiles[[1]].layout == TileLayout_CUBE_M32;
    assert _Tiles[[1]].capacity_bytes == 256;
    assert _Tiles[[1]].rows == 32 && _Tiles[[1]].columns == 1;
    assert _Tiles[[1]].valid_rows == 2 && _Tiles[[1]].valid_columns == 1;
    assert _Tiles[[1]].cube_cell_count == 2;
    assert TileElementDefined(1, 0, 0);
    assert TileElementDefined(1, 1, 0);
    assert ReadTileElement(1, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3ff0000000000000;
    assert ReadTileElement(1, 1, 0) ==
        Zeros{PTO_XLEN} + 0xc000000000000000;
    assert !TileElementDefined(1, 2, 0);
    assert !TileElementDefined(1, 31, 0);
    assert NumericStatusFlags() == Zeros{5} + 0x10;

    assert _Tiles[[0]].data_type == source_before.data_type;
    assert _Tiles[[0]].layout == source_before.layout;
    assert _Tiles[[0]].capacity_bytes == source_before.capacity_bytes;
    assert _Tiles[[0]].rows == source_before.rows;
    assert _Tiles[[0]].columns == source_before.columns;
    assert _Tiles[[0]].valid_rows == source_before.valid_rows;
    assert _Tiles[[0]].valid_columns == source_before.valid_columns;
    assert _Tiles[[0]].cube_cell_count == source_before.cube_cell_count;
    assert ReadTileElement(0, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3ffc000000000000;
    assert ReadTileElement(0, 1, 0) ==
        Zeros{PTO_XLEN} + 0xc002000000000000;
    assert !TileElementDefined(0, 2, 0);
    assert !TileElementDefined(0, 31, 0);
    return 0;
end;
