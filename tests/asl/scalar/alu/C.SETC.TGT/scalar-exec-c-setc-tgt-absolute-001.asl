// PTO-TEST: {"id":"PTO-AVS-SCALAR-C-SETC-TGT-ABS-001","source":"asl/scalar/alu/C.SETC.TGT.asl","requirements":["PTO-INST-SCALAR-C-SETC-TGT"],"kind":"execution","summary":"C.SETC.TGT snapshots an absolute GPR value into active BARG.BPCN","pass_condition":"later GPR mutation cannot change the snapshotted target and block commit selects that exact value","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/sys/semantics.asl","asl/block/model/state/barg.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundleAt(
        ReadTPC(),
        BundleKind_Standard,
        BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x300,
        Zeros{PTO_XLEN} + 0x102,
        Zeros{PTO_XLEN} + 0x102,
        FALSE);
    WriteGPR(1, Zeros{PTO_XLEN} + 0x600);

    var instruction: bits(48) = Zeros{48} + 0x001c;
    instruction[10:6] = Zeros{5} + 1;

    let status = ExecuteScalarInstruction(instruction, 16);
    assert status == ScalarExecution_Executed;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x600;
    assert _BundleCommitTargetSet;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;

    WriteGPR(1, Zeros{PTO_XLEN} + 0x700);
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x600;
    StopBundleAt(Zeros{PTO_XLEN} + 0x104);
    assert _LastFault == Fault_None;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x600;
    assert !_BundleCommitTargetSet;
    return 0;
end;
