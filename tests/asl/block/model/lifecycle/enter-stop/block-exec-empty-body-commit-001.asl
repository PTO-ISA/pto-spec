// PTO-TEST: {"id":"PTO-AVS-BLOCK-BODY-ENTRY-EMPTY-COMMIT-001","source":"asl/block/model/lifecycle/enter-stop.asl","requirements":["PTO-REQ-SCALAR-BODY-ENTRY-001"],"kind":"execution","summary":"A block with no decoded scalar body instruction commits without synthesizing body entry.","pass_condition":"C.BSTOP commits the active body-inactive block and publishes its fallthrough PC.","related_sources":["asl/scalar/model/dispatch/top-level.asl","asl/block/lifecycle/C.BSTOP.asl"]}
func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    WriteTPC(entry);
    // C.BSTART.STD FALL
    WriteMemoryByte(entry, Zeros{8});
    WriteMemoryByte(entry + 1, Zeros{8} + 0x08);
    // C.BSTOP
    WriteMemoryByte(entry + 2, Zeros{8});
    WriteMemoryByte(entry + 3, Zeros{8});

    let start_status = ExecuteNextPTOInstruction();
    assert start_status == PTOInstruction_Executed;
    assert BundleIsActive();
    assert !BundleBodyIsActive();

    let stop_status = ExecuteNextPTOInstruction();
    assert stop_status == PTOInstruction_Executed;
    assert _LastFault == Fault_None;
    assert !BundleIsActive();
    assert !BundleBodyIsActive();
    assert ReadTPC() == entry + 4;
    return 0;
end;
