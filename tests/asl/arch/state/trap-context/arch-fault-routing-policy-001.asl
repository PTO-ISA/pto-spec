// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-ARCH-TESTTRAPROUTINGPOLICY-FAULT-001","source":"asl/arch/state/trap-context.asl","requirements":[],"kind":"fault","summary":"Covers Trap Routing Policy.","pass_condition":"TestTrapRoutingPolicy completes without assertion failure","related_sources":[]}
func TestTrapRoutingPolicy()
begin
    assert TrapTargetForFault(0) == 0;
    assert TrapTargetForFault(1) == 1;
    assert TrapTargetForFault(2) == 1;
    assert TrapTargetForFault(15) == 1;
    assert TrapTargetForInterrupt(0) == 0;
    assert TrapTargetForInterrupt(1) == 1;
    assert TrapTargetForInterrupt(2) == 1;
    assert TrapTargetForInterrupt(15) == 1;

    ResetProfileState();
    SetCurrentACR(1);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    SetFault(Fault_IllegalInstruction, Zeros{PTO_XLEN} + 0x100);
    assert CurrentACR() == 1;
    assert _TrapContexts[[1]].source_acr == 1;
    assert _ACRTrapNumber[[1]] == Zeros{6} + 4;

    ResetProfileState();
    SetCurrentACR(15);
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    SetFault(Fault_DataPage, Zeros{PTO_XLEN} + 0x300);
    assert CurrentACR() == 1;
    assert _TrapContexts[[1]].source_acr == 15;
    assert _ACRTrapNumber[[1]] == Zeros{6} + 35;
    assert _ACRTrapArgument0[[1]] == Zeros{PTO_XLEN} + 0x300;

    ResetProfileState();
end;
func main() => integer
begin
    ResetProfileState();
    TestTrapRoutingPolicy();
    return 0;
end;
