// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-LAST-USE-DECODE-003","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-B-IOS-SHARED-STATE-001","PTO-ARCH-SHARED-VTAG-LIFETIME-001"],"kind":"execution","summary":"B.IOS bit 26 distinguishes retained and last-use Shared sources without changing destination or zero-mask legality.","pass_condition":"An old source retains, a new bit-26 source records last-use, a zero-mask source is a no-op, and bit-26 destinations plus bit 27 reject before effects.","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/operands/shared-bindings.asl"]}
pure func SharedLastUseTestWord(size_code: bits(4),
                                pe_mode: bits(3),
                                last_use: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 7;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    instruction[26] = if last_use then '1' else '0';
    return instruction;
end;

func TestSharedLastUseDecode()
begin
    let old_source = SharedLastUseTestWord(Zeros{4}, '111', FALSE);
    let last_source = SharedLastUseTestWord(Zeros{4}, '111', TRUE);
    assert DecodeCommandForm(old_source, 32) != PTO_COMMAND_FORM_COUNT;
    assert DecodeCommandForm(last_source, 32) != PTO_COMMAND_FORM_COUNT;

    ResetProfileState();
    let old_start = ExecuteCommandInstruction(
        Zeros{64} + 0x00019181, 32);
    assert old_start == CommandExecution_Executed;
    let retained = ExecuteCommandInstruction(old_source, 32);
    assert retained == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].valid;
    assert _BundleSharedBindings[[0]].source_reuse;

    ResetProfileState();
    let last_start = ExecuteCommandInstruction(
        Zeros{64} + 0x00019181, 32);
    assert last_start == CommandExecution_Executed;
    let consumed = ExecuteCommandInstruction(last_source, 32);
    assert consumed == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].valid;
    assert !_BundleSharedBindings[[0]].source_reuse;

    ResetProfileState();
    let zero_start = ExecuteCommandInstruction(
        Zeros{64} + 0x00019181, 32);
    assert zero_start == CommandExecution_Executed;
    let zero_binding = ExecuteCommandInstruction(
        SharedLastUseTestWord(Zeros{4}, '000', TRUE), 32);
    assert zero_binding == CommandExecution_Executed;
    assert !_BundleSharedBindings[[0]].valid;

    assert DecodeCommandForm(
        SharedLastUseTestWord('0001', '111', TRUE), 32) ==
        PTO_COMMAND_FORM_COUNT;
    var reserved27 = last_source;
    reserved27[27] = '1';
    assert DecodeCommandForm(reserved27, 32) == PTO_COMMAND_FORM_COUNT;
end;

func main() => integer
begin
    TestSharedLastUseDecode();
    return 0;
end;
