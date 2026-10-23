// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-CUBE-WRITER-PREFLIGHT-010","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-TCVT-CONTRACT-001"],"kind":"fault","summary":"TCVT preflights Local CUBE writer shape and range legality before destination allocation","pass_condition":"a 128-byte CUBE_M16 FP32 writer that cannot hold the requested 16x9 valid shape raises TileLegality while leaving Tile 0 unallocated and its destination binding unresolved","related_sources":["asl/block/model/dispatch/tcvt-destination.asl","asl/block/model/operands/local-generation-cube-writer-effects.asl","asl/tile/model/state/allocation.asl"]}
func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        1, 512, 16, 9, TileDataType_FP16,
        TileLayout_CUBE_M16);
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
    _BundleTileBindings[[0]].destination_assemble.valid = TRUE;
    _BundleTileBindings[[0]].destination_assemble.init = TRUE;
    _BundleTileBindings[[0]].destination_assemble.last = TRUE;
    _BundleTileBindings[[0]].destination_assemble.size_code = 1;
    _BundleTileBindings[[0]].destination_assemble.offset =
        Zeros{PTO_XLEN};

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[0]].allocated;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    return 0;
end;
