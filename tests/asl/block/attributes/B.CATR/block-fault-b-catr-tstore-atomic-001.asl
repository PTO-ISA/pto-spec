// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-ATOMIC-CATR-001","source":"asl/block/attributes/B.CATR.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-B-CATR-CONTROL-001"],"kind":"fault","summary":"B.CATR atom is rejected for participating Atomic TSTORE while zero masks retain no-effect precedence","pass_condition":"atom=1 faults selected Atomic TSTORE before GM effects or source last-use completion; omitted and atom=0 controls execute one Atomic update, and a zero PE mask with atom=1 has no fault or effect","related_sources":["asl/block/attributes/B.DATR.asl","asl/block/model/dispatch/tlsu-atomic-tstore.asl","asl/tile/model/memory/atomic-tstore.asl"]}
pure func AtomicCATRStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func AtomicCATRDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func AtomicCATRControl(atom: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000023;
    instruction[17] = if atom then '1' else '0';
    return instruction;
end;

pure func AtomicCATRSource(pe_mask: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = pe_mask;
    instruction[19] = '1';
    return instruction;
end;

pure func AtomicCATRIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

pure func AtomicCATRSharedLastUse() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x04001013;
    instruction[25:20] = Zeros{6} + 42;
    instruction[11:9] = '111';
    return instruction;
end;

func RunAtomicCATRCase(control: integer {0..3})
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    MarkTileValidRegionDefined(0);
    Store(Zeros{PTO_XLEN} + 0x200, 4, Zeros{PTO_XLEN} + 5);
    let initial = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 4);
    assert initial == Zeros{PTO_XLEN} + 5;
    let started = ExecuteCommandInstruction(AtomicCATRStart(), 32);
    let attributes = ExecuteCommandInstruction(AtomicCATRDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    var control_result = CommandExecution_Executed;
    if control != 0 then
        control_result = ExecuteCommandInstruction(
            AtomicCATRControl(control == 1 || control == 3), 32);
    end;
    let pe_mask = if control == 3 then Zeros{3} else '111';
    let source = ExecuteCommandInstruction(AtomicCATRSource(pe_mask), 32);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x200);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    let address = ExecuteCommandInstruction(AtomicCATRIOR(), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           control_result == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed;
    assert BundleAtomicTStoreSelected();
    if control == 3 then
        assert BundleTileBindingCount() == 0;
    else
        assert BundleTileBindingCount() == 1 &&
               _BundleTileBindings[[0]].source0_valid &&
               _BundleTileBindings[[0]].last;
    end;
    if control == 1 || control == 3 then
        assert _BundleControlAttributes.present &&
               _BundleControlAttributes.atomic;
    elsif control == 2 then
        assert _BundleControlAttributes.present &&
               !_BundleControlAttributes.atomic;
    else
        assert !_BundleControlAttributes.present;
    end;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    if control == 1 then
        assert !completed && _LastFault == Fault_TileLegality &&
               _MemoryEventCount == 0 &&
               !_BundleTileBindings[[0]].source0_lifetime_captured;
    elsif control == 3 then
        assert completed && _LastFault == Fault_None &&
               _MemoryEventCount == 0 && BundleTileBindingCount() == 0;
    else
        assert completed && _LastFault == Fault_None &&
               _MemoryEventCount == 1;
        let event = _MemoryEvents[[0]];
        assert event.active && event.kind == MemoryEvent_Atomic &&
               event.address == Zeros{PTO_XLEN} + 0x200 &&
               event.read_value == initial &&
               event.write_value == Zeros{PTO_XLEN} + 7 && event.committed;
    end;
    StopMemoryEventCapture();
    let actual = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 4);
    if control == 1 || control == 3 then
        assert actual == initial;
    else
        assert actual == Zeros{PTO_XLEN} + 7;
    end;
end;

func TestAtomicCATRSharedLastUseFault()
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    MarkTileValidRegionDefined(0);
    let shared_id = (Zeros{6} + 42) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[0]], '1111');
    let source_before = SharedTileRecord(shared_id);
    Store(Zeros{PTO_XLEN} + 0x200, 4, Zeros{PTO_XLEN} + 5);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x200);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    let started = ExecuteCommandInstruction(AtomicCATRStart(), 32);
    let attributes = ExecuteCommandInstruction(AtomicCATRDATR(), 32);
    let control = ExecuteCommandInstruction(AtomicCATRControl(TRUE), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(AtomicCATRSharedLastUse(), 32);
    let address = ExecuteCommandInstruction(AtomicCATRIOR(), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           control == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed;
    assert BundleAtomicTStoreSelected() &&
           BundleSharedBindingCount() == 1 &&
           !_BundleSharedBindings[[0]].source_reuse &&
           _BundleSharedBindings[[0]].pe_mask == '1111';
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality &&
           _MemoryEventCount == 0;
    StopMemoryEventCapture();
    let target_after = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 4);
    let source_after = SharedTileRecord(shared_id);
    assert target_after == Zeros{PTO_XLEN} + 5 &&
           SharedTilePublished(shared_id) &&
           SharedTilePayloadIntact(shared_id) &&
           ReadSharedTileWord(shared_id, 0) == Zeros{PTO_XLEN} + 2 &&
           source_after.payload_generation == source_before.payload_generation &&
           source_after.tile.payload[[0]] == source_before.tile.payload[[0]];
end;

func main() => integer
begin
    RunAtomicCATRCase(1);
    RunAtomicCATRCase(0);
    RunAtomicCATRCase(2);
    RunAtomicCATRCase(3);
    TestAtomicCATRSharedLastUseFault();
    return 0;
end;
