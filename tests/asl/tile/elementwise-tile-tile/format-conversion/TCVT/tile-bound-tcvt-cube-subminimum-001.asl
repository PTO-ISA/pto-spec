// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-CUBE-SUBMINIMUM-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"boundary","summary":"CUBE_M16 TCVT accepts valid payloads below the 128-byte minimum TSize","pass_condition":"an FP32 16x1 source at 128 B converts to BF16 16x1 at 128 B with independently derived physical columns and Null destination padding","related_sources":["asl/block/model/dispatch/tcvt-schema.asl","asl/block/model/dispatch/tcvt-destination.asl","asl/tile/model/numeric/formats.asl"]}
func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        1, 128, 16, 1, TileDataType_FP32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert source_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 15, 0, Zeros{PTO_XLEN});
    MarkTileValidRegionDefined(1);

    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x09b19181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 5, Zeros{5}, '11', Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 16);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_BF16;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
    assert _Tiles[[destination]].capacity_bytes == 128;
    assert _Tiles[[1]].columns == 2;
    assert _Tiles[[destination]].columns == 4;
    assert _Tiles[[destination]].valid_rows == 16;
    assert _Tiles[[destination]].valid_columns == 1;
    assert TileElementDefined(destination, 0, 0);
    assert !TileElementDefined(destination, 0, 1);
    assert !TileElementDefined(destination, 15, 3);
    return 0;
end;
