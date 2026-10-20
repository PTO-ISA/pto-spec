// PTO-TEST: {"id":"PTO-AVS-TILE-GM-ADD-GRADUAL-001","source":"asl/tile/model/memory/gm-atom-red-execution.asl","requirements":["PTO-GM-FLOATING-ADD-NUMERIC-001","PTO-ATOM-RED-ORDERING-001"],"kind":"execution","summary":"Indexed red.add gradual FP32, Atomic events and readonly status","pass_condition":"Two gradual boundaries produce exact bits without numeric status mutation","related_sources":["asl/tile/model/memory/gm-atom-red.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U32, TileLayout_RowMajor);
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_FP32, TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x807fffff);
    MarkTileValidRegionDefined(0);
    MarkTileValidRegionDefined(1);
    Store(Zeros{PTO_XLEN} + 0x400, 4, Zeros{PTO_XLEN} + 1);
    Store(Zeros{PTO_XLEN} + 0x404, 4, Zeros{PTO_XLEN} + 0x00800000);
    let flags_before = NumericStatusFlags();
    StartMemoryEventCapture(0);
    GM_RED_VALUE(GMReduction_ADD, Zeros{PTO_XLEN} + 0x400, 0, 1, TilePad_Null);
    StopMemoryEventCapture();
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Atomic;
    let result0 = LoadUnsigned(Zeros{PTO_XLEN} + 0x400, 4);
    let result1 = LoadUnsigned(Zeros{PTO_XLEN} + 0x404, 4);
    assert result0 == Zeros{PTO_XLEN} + 2;
    assert result1 == Zeros{PTO_XLEN} + 1;
    assert NumericStatusFlags() == flags_before;
    return 0;
end;
