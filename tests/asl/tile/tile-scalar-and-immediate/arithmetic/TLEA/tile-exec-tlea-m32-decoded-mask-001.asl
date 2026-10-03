// PTO-TEST: {"id":"PTO-AVS-TILE-TLEA-M32-DECODED-MASK-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TLEA.asl","requirements":["PTO-TLEA-CONTRACT-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001"],"kind":"execution","summary":"Decoded M32 TLEA binds the width scalar before its GPR predicate and merges the complete inactive 64-bit element.","pass_condition":"An undefined inactive S32 index is not read; the active byte offset and both halves of the inactive S64 merge value publish into a four-CELL destination without memory events.","related_sources":["asl/block/model/dispatch/lea-schema.asl","asl/block/model/dispatch/execution-mask-schema.asl","asl/block/model/dispatch/destination-operation.asl"]}
func main() => integer
begin
    ResetProfileState();
    let base_ready = ConfigureCubeTile(0, 512, 1, 2,
        TileDataType_S64, TileLayout_CUBE_M32);
    let source_ready = ConfigureCubeTile(1, 256, 1, 2,
        TileDataType_S32, TileLayout_CUBE_M32);
    assert base_ready && source_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xaaaaaaaa55555555);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0xdeadbeef00000002);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteGPR(2, Zeros{PTO_XLEN} + 32);
    WriteGPR(3, Zeros{PTO_XLEN} + 1);
    var start: bits(64) = Zeros{64} + 0x02e19181;
    start[31:27] = TileDataTypeToEncoding(TileDataType_S32);
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(DTYPE_NONE, Zeros{5} + 29,
        '11', Zeros{3}, Zeros{3}, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(TRUE, 0, 3, '0001', TRUE, FALSE, 1, 0, TRUE);
    SetBundleScalarBindingWithExecutionMask(0, 0, 2, 3, 0, 3, TRUE);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_S64;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M32;
    assert _Tiles[[destination]].cube_cell_count == 4;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0xdeadbeef00000002;
    assert !TileElementDefined(1, 0, 1);
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    return 0;
end;
