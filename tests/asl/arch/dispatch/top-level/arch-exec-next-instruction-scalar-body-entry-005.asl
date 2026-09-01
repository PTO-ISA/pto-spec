// PTO-TEST: {"id":"PTO-AVS-ARCH-NEXT-INSTRUCTION-SCALAR-BODY-ENTRY-005","source":"asl/arch/dispatch/top-level.asl","requirements":["PTO-REQ-INSTRUCTION-DISPATCH-001","PTO-REQ-SCALAR-BODY-ENTRY-001","PTO-INST-SCALAR-C-SEXT-W","PTO-INST-SCALAR-SETC-LTUI"],"kind":"execution","summary":"A fetched compiler-shaped C.SEXT.W followed by SETC.LTUI enters the bundle body before conditional applicability is checked.","pass_condition":"The BSTART header remains body-inactive, C.SEXT.W is the first decoded body scalar, and the following SETC.LTUI executes without a bundle-control fault.","related_sources":["asl/block/model/lifecycle/enter-stop.asl","asl/scalar/alu/C.SEXT.W.asl","asl/scalar/bru/SETC.LTUI.asl"]}
func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    WriteTPC(entry);

    // C.BSTART.STD COND, entry
    WriteMemoryByte(entry, Zeros{8} + 0x04);
    WriteMemoryByte(entry + 1, Zeros{8});
    // C.SEXT.W a1, ->t (the compiler-shaped first scalar body instruction)
    WriteMemoryByte(entry + 2, Zeros{8} + 0xdc);
    WriteMemoryByte(entry + 3, Zeros{8} + 0x50);
    // SETC.LTUI t#1, 1023
    WriteMemoryByte(entry + 4, Zeros{8} + 0x75);
    WriteMemoryByte(entry + 5, Zeros{8} + 0x60);
    WriteMemoryByte(entry + 6, Zeros{8} + 0xfc);
    WriteMemoryByte(entry + 7, Zeros{8} + 0x3f);

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
    return 0;
end;
