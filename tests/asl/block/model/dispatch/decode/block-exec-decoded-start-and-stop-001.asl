// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTDECODEDBUNDLESTARTANDSTOP-EXECUTION-001","source":"asl/block/model/dispatch/decode.asl","requirements":[],"kind":"execution","summary":"Covers Decoded Bundle Start And Stop.","pass_condition":"TestDecodedBundleStartAndStop completes without assertion failure","related_sources":[]}
func TestDecodedBundleStartAndStop()
begin
    ResetBundleControlState();
    ClearFault();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    var direct: bits(64) = Zeros{64} + 0x00000011;
    direct[31:7] = Zeros{25} + 4;
    let direct_status = ExecuteCommandInstruction(direct, 32);
    assert direct_status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert BundleIsActive();
    assert _BARG.transfer_type == BundleTransfer_Direct;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;

    var stop: bits(64) = Zeros{64} + 0x00000001;
    let stop_status = ExecuteCommandInstruction(stop, 32);
    assert stop_status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert !BundleIsActive();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x108;

    ResetBundleControlState();
    ClearFault();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    ExecuteSetCommit(ScalarCondition_EQ, Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 1);
    var conditional: bits(64) = Zeros{64} + 0x00000021;
    conditional[31:7] = Zeros{25} + 4;
    let conditional_status = ExecuteCommandInstruction(conditional, 32);
    assert conditional_status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert BundleIsActive();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x204;

    ResetBundleControlState();
    ClearFault();
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    var call: bits(64) = Zeros{64} + 0x50160002;
    call[15:4] = Zeros{12} + 4;
    call[26:22] = Zeros{5} + 3;
    let call_status = ExecuteCommandInstruction(call, 32);
    assert call_status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert _BARG.transfer_type == BundleTransfer_Call;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x304;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0x308;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x308;
end;
func main() => integer
begin
    ResetProfileState();
    TestDecodedBundleStartAndStop();
    return 0;
end;
