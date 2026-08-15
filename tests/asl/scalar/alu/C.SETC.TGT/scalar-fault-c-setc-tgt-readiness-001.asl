// PTO-TEST: {"id":"PTO-AVS-SCALAR-C-SETC-TGT-READY-001","source":"asl/scalar/alu/C.SETC.TGT.asl","requirements":["PTO-INST-SCALAR-C-SETC-TGT"],"kind":"fault","summary":"An unavailable first C.SETC.TGT source does not consume uniqueness","pass_condition":"after precise recovery the same block accepts one successful C.SETC.TGT and snapshots the now-ready relative source","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/sys/semantics.asl","asl/arch/state/trap-context.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    BeginBundleAt(
        ReadTPC(),
        BundleKind_Standard,
        BundleTransfer_Conditional,
        Zeros{PTO_XLEN} + 0x700,
        Zeros{PTO_XLEN} + 0x402,
        Zeros{PTO_XLEN} + 0x402,
        FALSE);

    var instruction: bits(48) = Zeros{48} + 0x001c;
    instruction[10:6] = Zeros{5} + 27;

    let status = ExecuteScalarInstruction(instruction, 16);
    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert _TrapContexts[[0]].barg.bpcn == Zeros{PTO_XLEN} + 0x700;
    assert !_TrapContexts[[0]].bundle_commit_target_set;

    let recovered = RecoverTrapContext(0);
    assert recovered;
    ClearFault();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x810);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x820);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x830);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x840);
    let retry_status = ExecuteScalarInstruction(instruction, 16);
    assert retry_status == ScalarExecution_Executed;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x810;
    assert _BundleCommitTargetSet;
    return 0;
end;
