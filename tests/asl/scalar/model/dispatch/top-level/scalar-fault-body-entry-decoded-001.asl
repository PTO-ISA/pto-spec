// PTO-TEST: {"id":"PTO-AVS-SCALAR-BODY-ENTRY-DECODED-FAULT-001","source":"asl/scalar/model/dispatch/top-level.asl","requirements":["PTO-REQ-SCALAR-BODY-ENTRY-001"],"kind":"fault","summary":"A decoded scalar form enters the body before operation-applicability rejection.","pass_condition":"ACRC rejects in a Standard block while body-active state remains visible.","related_sources":["asl/block/model/lifecycle/enter-stop.asl","asl/scalar/sys/ACRC.asl"]}
func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let body = entry + 2;
    WriteTPC(entry);
    // C.BSTART.STD COND, entry
    WriteMemoryByte(entry, Zeros{8} + 0x04);
    WriteMemoryByte(entry + 1, Zeros{8});
    // ACRC 1 is decoded but requires a System block.
    WriteMemoryByte(body, Zeros{8} + 0x2b);
    WriteMemoryByte(body + 1, Zeros{8} + 0x30);
    WriteMemoryByte(body + 2, Zeros{8} + 0x10);
    WriteMemoryByte(body + 3, Zeros{8});

    let start_status = ExecuteNextPTOInstruction();
    assert start_status == PTOInstruction_Executed;
    assert !BundleBodyIsActive();

    let status = ExecuteNextPTOInstruction();
    assert status == PTOInstruction_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert BundleIsActive();
    assert BundleBodyIsActive();
    return 0;
end;
