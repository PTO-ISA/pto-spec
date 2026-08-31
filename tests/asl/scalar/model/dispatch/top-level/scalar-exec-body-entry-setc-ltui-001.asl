// PTO-TEST: {"id":"PTO-AVS-SCALAR-BODY-ENTRY-SETC-LTUI-001","source":"asl/scalar/model/dispatch/top-level.asl","requirements":["PTO-REQ-SCALAR-BODY-ENTRY-001","PTO-INST-SCALAR-SETC-LTUI"],"kind":"execution","summary":"The first decoded scalar instruction enters an active bundle body before a later conditional SETC executes.","pass_condition":"C.MOVR makes the body active and SETC.LTUI executes without a bundle-control fault.","related_sources":["asl/block/model/lifecycle/enter-stop.asl","asl/scalar/bru/SETC.LTUI.asl"]}
func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    WriteTPC(entry);
    // C.BSTART.STD COND, entry
    WriteMemoryByte(entry, Zeros{8} + 0x04);
    WriteMemoryByte(entry + 1, Zeros{8});
    // C.MOVR zero, ->a1
    WriteMemoryByte(entry + 2, Zeros{8} + 0x06);
    WriteMemoryByte(entry + 3, Zeros{8} + 0x18);
    // SETC.LTUI zero, 0
    WriteMemoryByte(entry + 4, Zeros{8} + 0x75);
    WriteMemoryByte(entry + 5, Zeros{8} + 0x60);
    WriteMemoryByte(entry + 6, Zeros{8});
    WriteMemoryByte(entry + 7, Zeros{8});

    let start_status = ExecuteNextPTOInstruction();
    assert start_status == PTOInstruction_Executed;
    assert BundleIsActive();
    assert !BundleBodyIsActive();

    let first_body_status = ExecuteNextPTOInstruction();
    assert first_body_status == PTOInstruction_Executed;
    assert BundleBodyIsActive();

    let condition_status = ExecuteNextPTOInstruction();
    assert condition_status == PTOInstruction_Executed;
    assert _LastFault == Fault_None;
    assert _BundleConditionSet;
    assert _CommitArgument == Zeros{PTO_XLEN};
    return 0;
end;
