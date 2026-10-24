// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-ATOMIC-VIRTUAL-ALIAS-001","source":"asl/tile/model/memory/atomic-tstore.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001"],"kind":"execution","summary":"distinct virtual source coordinates atomically contribute to one translated physical range","pass_condition":"two distinct virtual U32 targets translated to the same exact physical range both contribute exactly once, without assuming their traversal order, and original virtual sentinels stay unchanged","related_sources":["asl/scalar/model/agu/memory.asl","asl/block/model/dispatch/tlsu-atomic-tstore.asl"]}

pure func VirtualAliasStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func VirtualAliasDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = '000';
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func VirtualAliasSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func VirtualAliasIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func PrepareVirtualAliasRequest()
begin
    ConfigureTile(0, 128, 2, 1, 2, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 3);
    MarkTileValidRegionDefined(0);
    Store(Zeros{PTO_XLEN} + 0x300, 4, Zeros{PTO_XLEN} + 91);
    Store(Zeros{PTO_XLEN} + 0x304, 4, Zeros{PTO_XLEN} + 92);
    Store(Zeros{PTO_XLEN} + 0x500, 4, Zeros{PTO_XLEN});
    WriteGPR(2, Zeros{PTO_XLEN} + 0x300);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    let start = ExecuteCommandInstruction(VirtualAliasStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let attributes = ExecuteCommandInstruction(VirtualAliasDATR(), 32);
    let source = ExecuteCommandInstruction(VirtualAliasSource(), 32);
    let address = ExecuteCommandInstruction(VirtualAliasIOR(), 32);
    assert start == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           BundleAtomicTStoreSelected();
end;

func main() => integer
begin
    // Known-good identity mapping proves descriptor, source, command, and
    // access setup before the environment introduces the virtual alias.
    ResetProfileState();
    _Issue397TranslationMode = 0;
    Store(Zeros{PTO_XLEN} + 0x300, 4, Zeros{PTO_XLEN} + 91);
    Store(Zeros{PTO_XLEN} + 0x304, 4, Zeros{PTO_XLEN} + 92);
    Store(Zeros{PTO_XLEN} + 0x500, 4, Zeros{PTO_XLEN});
    WriteGPR(2, Zeros{PTO_XLEN} + 0x300);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    PrepareVirtualAliasRequest();
    StartMemoryEventCapture(0);
    let identity_complete = ExecuteBundleTileOperation();
    assert identity_complete && _LastFault == Fault_None &&
           _MemoryEventCount == 2;
    StopMemoryEventCapture();

    ResetProfileState();
    _Issue397TranslationMode = 0;
    PrepareVirtualAliasRequest();
    _Issue397TranslationMode = 1;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert completed;
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 2;
    let first = _MemoryEvents[[0 as MemoryEventIndex]];
    let second = _MemoryEvents[[1 as MemoryEventIndex]];
    assert first.kind == MemoryEvent_Atomic && first.committed &&
           first.address == Zeros{PTO_XLEN} + 0x500 &&
           first.read_value == Zeros{PTO_XLEN} &&
           (first.write_value == Zeros{PTO_XLEN} + 2 ||
            first.write_value == Zeros{PTO_XLEN} + 3);
    assert second.kind == MemoryEvent_Atomic && second.committed &&
           second.address == Zeros{PTO_XLEN} + 0x500 &&
           second.read_value == first.write_value &&
           second.write_value == Zeros{PTO_XLEN} + 5;
    StopMemoryEventCapture();
    _Issue397TranslationMode = 0;
    let physical_after = LoadUnsigned(Zeros{PTO_XLEN} + 0x500, 4);
    let first_virtual_after = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 4);
    let second_virtual_after = LoadUnsigned(Zeros{PTO_XLEN} + 0x304, 4);
    assert physical_after == Zeros{PTO_XLEN} + 5 &&
           first_virtual_after == Zeros{PTO_XLEN} + 91 &&
           second_virtual_after == Zeros{PTO_XLEN} + 92;
    return 0;
end;
