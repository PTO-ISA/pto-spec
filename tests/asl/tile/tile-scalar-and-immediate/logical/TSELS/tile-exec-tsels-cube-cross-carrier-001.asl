// PTO-TEST: {"id":"PTO-AVS-TILE-TSELS-CUBE-CROSS-CARRIER-001","source":"asl/tile/tile-scalar-and-immediate/logical/TSELS.asl","requirements":["PTO-TSELS-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"CUBE_M32 TSELS derives its complete two-word mask from U8 despite E4M3 backing","pass_condition":"the U8 operation consumes low/high mask words and copies an independent raw scalar into the U8 destination","related_sources":["asl/block/model/dispatch/tile-scalar-schema.asl","asl/block/model/dispatch/tile-execution.asl","asl/tile/model/execution/predicate-carriers.asl"]}
func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(10, 128, 1, 4, TileDataType_E4M3,
        TileLayout_CUBE_M32);
    assert source_ready;
    for column = 0 to 3 looplimit 4 do
        WriteTileElement(10, 0, column,
            Zeros{PTO_XLEN} + 10 + column);
    end;
    MarkTileValidRegionDefined(10);
    WriteGPR(2, Zeros{PTO_XLEN} + 1);
    WriteGPR(3, Zeros{PTO_XLEN});
    WriteGPR(4, Zeros{PTO_XLEN} + 0xf1);
    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xdba19181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 10, 0, TRUE);
    SetBundleScalarBinding(0, 0, 2, 3, 4, 3);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_U8;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0xf1;
    assert ReadTileElement(destination, 0, 2) == Zeros{PTO_XLEN} + 0xf1;
    assert ReadTileElement(destination, 0, 3) == Zeros{PTO_XLEN} + 0xf1;
    return 0;
end;
