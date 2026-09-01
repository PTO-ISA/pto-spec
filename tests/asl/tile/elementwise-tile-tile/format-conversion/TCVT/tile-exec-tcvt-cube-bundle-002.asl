// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-CUBE-BUNDLE-002","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"execution","summary":"TCVT allocates a CUBE destination using the destination type's minimum TSize","pass_condition":"a CUBE_M16 FP16 source with TSize 512 converts to a CUBE_M16 FP32 destination with TSize 1024 while preserving the valid region","related_sources":["asl/block/model/dispatch/tcvt-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/state/allocation.asl"]}
func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        1, 512, 16, 9, TileDataType_FP16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert source_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 15, 8, Zeros{PTO_XLEN} + 9);
    MarkTileValidRegionDefined(1);
    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x21b19181,
        32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 1,
        Zeros{5},
        '11',
        Zeros{3},
        Zeros{3},
        FALSE,
        FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 9);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 16);
    AddBundleTileBinding(
        TRUE,
        0,
        4,
        '1111',
        TRUE,
        FALSE,
        1,
        0,
        TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_FP32;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
    assert _Tiles[[destination]].location == TileLocation_Matrix;
    assert _Tiles[[destination]].capacity_bytes == 1024;
    assert _Tiles[[destination]].rows == 16;
    assert _Tiles[[destination]].columns == 10;
    assert _Tiles[[destination]].valid_rows == 16;
    assert _Tiles[[destination]].valid_columns == 9;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x34e00000;
    assert ReadTileElement(destination, 15, 8) ==
        Zeros{PTO_XLEN} + 0x35100000;
    return 0;
end;
