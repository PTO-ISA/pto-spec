// PTO-TEST: {"id":"PTO-AVS-TILE-GM-ADD-GRADUAL-002","source":"asl/tile/model/memory/gm-atom-red-execution.asl","requirements":["PTO-GM-FLOATING-ADD-NUMERIC-001","PTO-ATOM-RED-ORDERING-001"],"kind":"execution","summary":"Indexed atom.add returns pre-RMW values with gradual FP32 updates","pass_condition":"Old-value destination, Atomic events, GM results and numeric status match","related_sources":["asl/tile/model/memory/gm-atom-red.asl"]}
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
    ConfigureTile(2, 128, 1, 2, 1, 2, TileDataType_FP32, TileLayout_RowMajor);
    let flags_before = NumericStatusFlags();
    StartMemoryEventCapture(0);
    GM_ATOM_VALUE(GMAtomic_ADD, 2, Zeros{PTO_XLEN} + 0x400, 0, 1, TilePad_Null);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 0x00800000;
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
