// PTO-TEST: {"id":"PTO-AVS-ARCH-SCALAR-LOOP-ELF-SEQUENCE-003","source":"asl/arch/dispatch/top-level.asl","requirements":["PTO-REQ-INSTRUCTION-DISPATCH-001"],"kind":"execution","summary":"An ELF-shaped conditional scalar loop replays its decoded body and updates GPR and memory operands across iterations.","pass_condition":"Two executions of the compiler-emitted C.SEXT.W, SETC.LTUI, BIC, ADDI, LW, ADDW sequence select the loop target and accumulate the first two words.","related_sources":["asl/block/model/dispatch/start.asl","asl/scalar/model/dispatch/agu.asl","asl/scalar/model/dispatch/alu.asl","asl/scalar/model/dispatch/bru.asl"]}
func ExecuteScalarLoopBodyForDispatchTest()
begin
    let c_sext = ExecutePTOInstruction(Zeros{64} + 0x50dc, 16);
    let setc = ExecutePTOInstruction(Zeros{64} + 0x3ffc6075, 32);
    let bic = ExecutePTOInstruction(Zeros{64} + 0x13b1afe7, 32);
    let base = ExecutePTOInstruction(Zeros{64} + 0x0c008f95, 32);
    let load = ExecutePTOInstruction(Zeros{64} + 0x179c2f89, 32);
    let add = ExecutePTOInstruction(Zeros{64} + 0x062c0125, 32);
    let increment = ExecutePTOInstruction(Zeros{64} + 0x00118195, 32);
    assert c_sext == PTOInstruction_Executed;
    assert setc == PTOInstruction_Executed;
    assert bic == PTOInstruction_Executed;
    assert base == PTOInstruction_Executed;
    assert load == PTOInstruction_Executed;
    assert add == PTOInstruction_Executed;
    assert increment == PTOInstruction_Executed;
end;

func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x100);
    WriteGPR(2, Zeros{PTO_XLEN} + 1);
    WriteGPR(3, Zeros{PTO_XLEN});
    WritePhysicalMemoryByte(Zeros{PTO_XLEN} + 0x1c0, Zeros{8} + 2);
    WritePhysicalMemoryByte(Zeros{PTO_XLEN} + 0x1c4, Zeros{8} + 2);

    BeginBundleAt(
        Zeros{PTO_XLEN} + 0x100,
        BundleKind_Standard,
        BundleTransfer_Conditional,
        Zeros{PTO_XLEN} + 0x100,
        Zeros{PTO_XLEN} + 0x120,
        Zeros{PTO_XLEN},
        FALSE);
    ExecuteScalarLoopBodyForDispatchTest();
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 3;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 1;

    let next_boundary = ExecutePTOInstruction(Zeros{64} + 0x3800, 16);
    assert next_boundary == PTOInstruction_Executed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x100;
    let next_loop = ExecutePTOInstruction(Zeros{64} + 0x0004, 16);
    assert next_loop == PTOInstruction_Executed;
    ExecuteScalarLoopBodyForDispatchTest();
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 5;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 2;
    return 0;
end;
