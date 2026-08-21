// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSCATTER-MASK-SCATTER-001","source":"asl/block/execution/BSTART.MSCATTER.MASK.asl","requirements":["PTO-BSTART-MSCATTER-MASK-SCHEMA-001","PTO-MSCATTER-MASK-PREDICATE-001","PTO-INST-TILE-MSCATTER-MASK","PTO-INST-BLOCK-BSTART-MSCATTER-MASK"],"kind":"execution","summary":"MSCATTER.MASK writes exact-one lanes at byte displacements and ignores disabled addresses.","pass_condition":"Two enabled lanes write signed byte displacements, one disabled invalid displacement creates no check or event, and all sources persist.","related_sources":["asl/block/model/dispatch/tlsu-mscatter-mask.asl","asl/tile/model/memory/gather-scatter.asl"]}
pure func MaskScatterStart(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00711181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func MaskScatterFirst(source: bits(6), indices: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = indices;
    instruction[25:20] = source;
    instruction[18:15] = '0000';
    instruction[11:9] = '001';
    return instruction;
end;

pure func MaskScatterLast(mask: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = mask;
    instruction[19] = '1';
    instruction[18:15] = '0000';
    instruction[11:9] = '001';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 4, 1, 3, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 8, 1, 3, TileDataType_S32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigurePredicateTile(3, 128, 1, 4, 1, 3);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x11);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x22);
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN} + 0x33);
    WriteTileElement(2, 0, 0, Ones{PTO_XLEN} - 1);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 5000);
    WriteTileElement(2, 0, 2, Zeros{PTO_XLEN} + 4);
    WriteTilePredicateBit(3, 0, 0, TRUE);
    WriteTilePredicateBit(3, 0, 1, FALSE);
    WriteTilePredicateBit(3, 0, 2, TRUE);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x202);
    let started = ExecuteCommandInstruction(
        MaskScatterStart(Zeros{5} + 27), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let first = ExecuteCommandInstruction(
        MaskScatterFirst(Zeros{6} + 1, Zeros{6} + 2), 32);
    assert first == CommandExecution_Executed;
    let last = ExecuteCommandInstruction(MaskScatterLast(Zeros{6} + 3), 32);
    assert last == CommandExecution_Executed;
    SetBundleScalarBinding(0, 0, 2, 0, 0, 1);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _MemoryEventCount == 2;
    StopMemoryEventCapture();
    let first_value = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 1);
    let last_value = LoadUnsigned(Zeros{PTO_XLEN} + 0x206, 1);
    assert first_value == Zeros{PTO_XLEN} + 0x11;
    assert last_value == Zeros{PTO_XLEN} + 0x33;
    assert _Tiles[[1]].allocated && _Tiles[[2]].allocated &&
           _Tiles[[3]].allocated;
    return 0;
end;
