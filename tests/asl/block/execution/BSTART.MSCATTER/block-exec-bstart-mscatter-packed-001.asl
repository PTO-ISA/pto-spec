// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSCATTER-PACKED-001","source":"asl/block/execution/BSTART.MSCATTER.asl","requirements":["PTO-MSCATTER-BYTE-DISPLACEMENT-001","PTO-BSTART-MSCATTER-SCHEMA-001","PTO-INST-TILE-MSCATTER"],"kind":"execution","summary":"MSCATTER maps one byte displacement to one complete packed byte.","pass_condition":"A U4X2 source with two logical nibbles stores both nibbles from one byte at BaseGPR plus the signed byte displacement.","related_sources":["asl/block/model/dispatch/tlsu-mscatter.asl","asl/tile/model/memory/gather-scatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_U4X2,
        TileLayout_RowMajor);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_S32,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 10);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 4);
    Store(Zeros{PTO_XLEN} + 0x204, 1, Zeros{PTO_XLEN});
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x200);
    var start: bits(64) = Zeros{64} + 0x00511181;
    start[31:27] = Zeros{5} + 28;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(FALSE, 0, 0, '0001', TRUE, TRUE, 1, 2, TRUE);
    SetBundleScalarBinding(0, 0, 2, 0, 0, 2);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x204;
    let stored = LoadUnsigned(Zeros{PTO_XLEN} + 0x204, 1);
    assert stored == Zeros{PTO_XLEN} + 0xa5;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 10;
    StopMemoryEventCapture();
    return 0;
end;
