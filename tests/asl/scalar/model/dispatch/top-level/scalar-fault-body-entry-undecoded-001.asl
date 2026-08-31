// PTO-TEST: {"id":"PTO-AVS-SCALAR-BODY-ENTRY-UNDECODED-001","source":"asl/scalar/model/dispatch/top-level.asl","requirements":["PTO-REQ-SCALAR-BODY-ENTRY-001"],"kind":"fault","summary":"An unmatched scalar carrier does not enter the active bundle body.","pass_condition":"The instruction rejects with IllegalInstruction while the header remains active and body-inactive.","related_sources":["asl/block/model/lifecycle/enter-stop.asl"]}
func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let body = entry + 2;
    WriteTPC(entry);
    // C.BSTART.STD COND, entry
    WriteMemoryByte(entry, Zeros{8} + 0x04);
    WriteMemoryByte(entry + 1, Zeros{8});
    // Unassigned 64-bit carrier.
    WriteMemoryByte(body, Zeros{8} + 0x0f);
    for offset = 1 to 7 do
        WriteMemoryByte(body + NaturalToWord(offset), Zeros{8});
    end;

    let start_status = ExecuteNextPTOInstruction();
    assert start_status == PTOInstruction_Executed;
    assert BundleIsActive();
    assert !BundleBodyIsActive();

    let status = ExecuteNextPTOInstruction();
    assert status == PTOInstruction_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert BundleIsActive();
    assert !BundleBodyIsActive();
    return 0;
end;
