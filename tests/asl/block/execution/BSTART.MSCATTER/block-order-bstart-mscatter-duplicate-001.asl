// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSCATTER-DUP-001","source":"asl/block/execution/BSTART.MSCATTER.asl","requirements":["PTO-MSCATTER-DUPLICATE-ORDER-001"],"kind":"ordering","summary":"Atomic and non-atomic MSCATTER retain an implementation-defined duplicate-address winner.","pass_condition":"Two lanes targeting one byte may leave either complete-lane value with atomic clear or set; both runs emit two stores and preserve their sources.","related_sources":["asl/tile/model/memory/gather-scatter.asl"]}
pure func DuplicateScatterStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00511181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func DuplicateScatterBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 2;
    instruction[25:20] = Zeros{6} + 1;
    instruction[19] = '1';
    instruction[18:15] = '0000';
    instruction[11:9] = '001';
    return instruction;
end;

func RunDuplicateScatter(atomic: boolean, base: Word)
begin
    ResetProfileState();
    ConfigureTile(1, 128, 2, 1, 2, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x31);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x72);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    WritePEGPR(0, 2, base);
    let started = ExecuteCommandInstruction(DuplicateScatterStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleControlAttributeState(FALSE, atomic, FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 1);
    let tiles = ExecuteCommandInstruction(DuplicateScatterBinding(), 32);
    assert tiles == CommandExecution_Executed;
    SetBundleScalarBinding(0, 0, 2, 4, 0, 2);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _MemoryEventCount == 2;
    StopMemoryEventCapture();
    let observed = LoadUnsigned(base, 1);
    assert observed == Zeros{PTO_XLEN} + 0x31 ||
           observed == Zeros{PTO_XLEN} + 0x72;
    assert _Tiles[[1]].allocated && _Tiles[[2]].allocated;
end;

func main() => integer
begin
    RunDuplicateScatter(FALSE, Zeros{PTO_XLEN} + 0x180);
    RunDuplicateScatter(TRUE, Zeros{PTO_XLEN} + 0x1a0);
    return 0;
end;
