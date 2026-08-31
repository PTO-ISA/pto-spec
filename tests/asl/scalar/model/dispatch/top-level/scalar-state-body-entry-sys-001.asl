// PTO-TEST: {"id":"PTO-AVS-SCALAR-BODY-ENTRY-SYS-001","source":"asl/scalar/model/dispatch/top-level.asl","requirements":["PTO-REQ-SCALAR-BODY-ENTRY-001","PTO-INST-SCALAR-ACRC"],"kind":"state-transition","summary":"The first decoded SYS scalar enters the system-block body before its service request.","pass_condition":"ACRC preserves body-active state in the precise service-request trap context.","related_sources":["asl/block/model/lifecycle/enter-stop.asl","asl/scalar/sys/ACRC.asl"]}
func main() => integer
begin
    ResetProfileState();
    SetCurrentACR(2);
    let entry = Zeros{PTO_XLEN} + 0x100;
    WriteTPC(entry);
    // C.BSTART.SYS FALL
    WriteMemoryByte(entry, Zeros{8} + 0x40);
    WriteMemoryByte(entry + 1, Zeros{8} + 0x08);
    // ACRC 1
    WriteMemoryByte(entry + 2, Zeros{8} + 0x2b);
    WriteMemoryByte(entry + 3, Zeros{8} + 0x30);
    WriteMemoryByte(entry + 4, Zeros{8} + 0x10);
    WriteMemoryByte(entry + 5, Zeros{8});

    let start_status = ExecuteNextPTOInstruction();
    assert start_status == PTOInstruction_Executed;
    assert _BARG.block_type == BundleKind_System;
    assert !BundleBodyIsActive();

    let status = ExecuteNextPTOInstruction();
    assert status == PTOInstruction_Rejected;
    assert _LastFault == Fault_ServiceRequest;
    assert _TrapContexts[[1]].valid;
    assert _TrapContexts[[1]].bundle_active;
    assert _TrapContexts[[1]].bundle_body_active;
    return 0;
end;
