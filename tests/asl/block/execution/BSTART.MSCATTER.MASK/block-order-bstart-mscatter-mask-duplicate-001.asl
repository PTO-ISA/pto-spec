// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSCATTER-MASK-DUP-001","source":"asl/block/execution/BSTART.MSCATTER.MASK.asl","requirements":["PTO-MSCATTER-MASK-DUPLICATE-001"],"kind":"ordering","summary":"MSCATTER.MASK retains an implementation-defined enabled-lane winner with atomic clear or set.","pass_condition":"Two enabled duplicate lanes may leave either value in both modes and always emit two stores.","related_sources":["asl/tile/model/memory/gather-scatter.asl"]}
func RunMaskedDuplicate(atomic: boolean, base: Word)
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigurePredicateTile(3, 128, 1, 2, 1, 2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x31);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x72);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    WriteTilePredicateBit(3, 0, 0, TRUE);
    WriteTilePredicateBit(3, 0, 1, TRUE);
    WritePEGPR(0, 2, base);
    var start: bits(64) = Zeros{64} + 0x00711181;
    start[31:27] = Zeros{5} + 27;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleControlAttributeState(FALSE, atomic, FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(FALSE, 0, 0, '0001', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(FALSE, 0, 0, '0001', TRUE, FALSE, 3, 0, TRUE);
    SetBundleScalarBinding(0, 0, 2, 4, 0, 2);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _MemoryEventCount == 2;
    StopMemoryEventCapture();
    let observed = LoadUnsigned(base, 1);
    assert observed == Zeros{PTO_XLEN} + 0x31 ||
           observed == Zeros{PTO_XLEN} + 0x72;
end;

func main() => integer
begin
    RunMaskedDuplicate(FALSE, Zeros{PTO_XLEN} + 0x240);
    RunMaskedDuplicate(TRUE, Zeros{PTO_XLEN} + 0x260);
    return 0;
end;
