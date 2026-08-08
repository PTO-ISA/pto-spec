// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTBUNDLESHAREDBINDINGV6-EXECUTION-001","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-INST-BLOCK-B-IOS"],"kind":"execution","summary":"migrated independent behavior point for TestBundleSharedBindingV6","pass_condition":"TestBundleSharedBindingV6 completes without assertion failure","related_sources":[]}
pure func BundleTestRetiredCompressedSharedBinding(shared_id: bits(8))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0xc03c;
    instruction[12:5] = shared_id;
    return instruction;
end;

pure func BundleTestSharedBindingV6(shared_id: bits(8),
                                   tile_size: bits(3),
                                   pe_mask: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = pe_mask;
    instruction[11:9] = tile_size;
    return instruction;
end;

func TestBundleSharedBindingV6()
begin
    ResetProfileState();
    let source = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{8}, '000', '1111'), 32);
    assert source == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].valid;
    assert _BundleSharedBindings[[0]].shared_id == Zeros{8};
    assert _BundleSharedBindings[[0]].size_code == 0;
    assert _BundleSharedBindings[[0]].pe_mask == '1111';
    assert !_BundleSharedBindings[[0]].consumed;

    let duplicate = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{8}, '000', '1111'), 32);
    assert duplicate == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;

    ResetProfileState();
    let destination = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{8} + 255, '111', '0011'), 32);
    assert destination == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].shared_id == Zeros{8} + 255;
    assert _BundleSharedBindings[[0]].size_code == 7;
    assert _BundleSharedBindings[[0]].pe_mask == '0011';

    var reserved19 = BundleTestSharedBindingV6(
        Zeros{8} + 1, '001', '0001');
    reserved19[19] = '1';
    assert DecodeCommandForm(reserved19, 32) == PTO_COMMAND_FORM_COUNT;

    var reserved31 = BundleTestSharedBindingV6(
        Zeros{8} + 1, '001', '0001');
    reserved31[31] = '1';
    assert DecodeCommandForm(reserved31, 32) == PTO_COMMAND_FORM_COUNT;

    var reserved8 = BundleTestSharedBindingV6(
        Zeros{8} + 1, '001', '0001');
    reserved8[8] = '1';
    assert DecodeCommandForm(reserved8, 32) == PTO_COMMAND_FORM_COUNT;

    var wrong_func3 = BundleTestSharedBindingV6(
        Zeros{8} + 1, '001', '0001');
    wrong_func3[14:12] = '010';
    assert DecodeCommandForm(wrong_func3, 32) == PTO_COMMAND_FORM_COUNT;

    // The retired C.B.IOS bit pattern overlaps the still-active C.B.DIMI form.
    // Raw instruction bits carry no mnemonic provenance, so the decoder must
    // identify this word only as C.B.DIMI and never as a Shared binder.
    assert DecodeCommandForm(
        BundleTestRetiredCompressedSharedBinding(Zeros{8} + 1), 16) == 59;
    assert CommandOperationOfForm(59) ==
        CommandOperation_c_b_dimi_16_3f1b113c76ce;
    assert CommandHandlerOfForm(59) == CommandHandler_SetBundleDimension;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleSharedBindingV6();
    return 0;
end;
