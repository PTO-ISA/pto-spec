// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-ENCODING-002","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-INST-BLOCK-B-IOS"],"kind":"execution","summary":"Decoded B.IOS accepts the six-bit absolute SharedTileID namespace while preserving reserved-bit ownership.","pass_condition":"S0 and S63 bind with decoded SizeCode and PEMode fields, bits 27:26 reject, and the retired compressed word remains owned only by C.B.DIMI.","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/schema/profile-encoding.asl"]}
pure func BundleTestRetiredCompressedSharedBinding(shared_tile_id: bits(8))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0xc03c;
    instruction[12:5] = shared_tile_id;
    return instruction;
end;

pure func BundleTestSharedBindingEncoding(shared_tile_id: bits(6),
                                         size_code: bits(4),
                                         pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    return instruction;
end;

func TestBundleSharedBindingEncoding()
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    assert started == CommandExecution_Executed;
    let source = ExecuteCommandInstruction(
        BundleTestSharedBindingEncoding(Zeros{6}, '0000', '111'), 32);
    assert source == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].valid;
    let s0 = Zeros{6} as SharedTileID;
    assert _BundleSharedBindings[[0]].shared_tile_id == s0;
    assert _BundleSharedBindings[[0]].size_code == 0;
    assert _BundleSharedBindings[[0]].pe_mask == '1111';
    assert !_BundleSharedBindings[[0]].consumed;

    let duplicate = ExecuteCommandInstruction(
        BundleTestSharedBindingEncoding(Zeros{6}, '0000', '111'), 32);
    assert duplicate == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;

    ResetProfileState();
    let restarted = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    assert restarted == CommandExecution_Executed;
    let destination = ExecuteCommandInstruction(
        BundleTestSharedBindingEncoding(Zeros{6} + 63, '0111', '101'), 32);
    assert destination == CommandExecution_Executed;
    let s63 = (Zeros{6} + 63) as SharedTileID;
    assert _BundleSharedBindings[[0]].shared_tile_id == s63;
    assert _BundleSharedBindings[[0]].size_code == 7;
    assert _BundleSharedBindings[[0]].pe_mask == '1100';

    var reserved19 = BundleTestSharedBindingEncoding(
        Zeros{6} + 1, '0001', '001');
    reserved19[19] = '1';
    assert DecodeCommandForm(reserved19, 32) == PTO_COMMAND_FORM_COUNT;

    var reserved31 = BundleTestSharedBindingEncoding(
        Zeros{6} + 1, '0001', '001');
    reserved31[31] = '1';
    assert DecodeCommandForm(reserved31, 32) == PTO_COMMAND_FORM_COUNT;

    var reserved27 = BundleTestSharedBindingEncoding(
        Zeros{6} + 1, '0001', '001');
    reserved27[27] = '1';
    assert DecodeCommandForm(reserved27, 32) == PTO_COMMAND_FORM_COUNT;

    var reserved26 = BundleTestSharedBindingEncoding(
        Zeros{6} + 1, '0001', '001');
    reserved26[26] = '1';
    assert DecodeCommandForm(reserved26, 32) == PTO_COMMAND_FORM_COUNT;

    var reserved8 = BundleTestSharedBindingEncoding(
        Zeros{6} + 1, '0001', '001');
    reserved8[8] = '1';
    assert DecodeCommandForm(reserved8, 32) == PTO_COMMAND_FORM_COUNT;

    var wrong_func3 = BundleTestSharedBindingEncoding(
        Zeros{6} + 1, '0001', '001');
    wrong_func3[14:12] = '010';
    assert DecodeCommandForm(wrong_func3, 32) == PTO_COMMAND_FORM_COUNT;

    // The retired C.B.IOS bit pattern overlaps the still-active C.B.DIMI form.
    // Raw instruction bits carry no mnemonic provenance, so the decoder must
    // identify this word only as C.B.DIMI and never as a Shared binder.
    assert DecodeCommandForm(
        BundleTestRetiredCompressedSharedBinding(Zeros{8} + 1), 16) == 53;
    assert CommandOperationOfForm(53) ==
        CommandOperation_c_b_dimi_16_3f1b113c76ce;
    assert CommandHandlerOfForm(53) == CommandHandler_SetBundleDimension;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleSharedBindingEncoding();
    return 0;
end;
