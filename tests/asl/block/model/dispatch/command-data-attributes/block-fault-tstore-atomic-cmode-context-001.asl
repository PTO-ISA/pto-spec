// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-ATOMIC-CMODE-CONTEXT-001","source":"asl/block/model/dispatch/command-data-attributes.asl","requirements":["PTO-B-DATR-FIELDS-001","PTO-TSTORE-STRIDED-ATOMIC-RED-001"],"kind":"fault","summary":"CMode 6 and 7 pass B.DATR execution only for canonicalized TLSU Function 1 TSTORE","pass_condition":"both codes latch for atomic TSTORE, while TLOAD and Canonicalize=0 reject at B.DATR with Fault_IllegalInstruction and preserve the prior unlatch state","related_sources":["asl/block/attributes/B.DATR.asl","asl/tile/memory-and-data-movement/regular/TSTORE.asl"]}
pure func AtomicContextStart(function: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[24:20] = function;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func AtomicContextDATR(mode: bits(3), canonicalize: boolean)
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = mode;
    instruction[25] = if canonicalize then '1' else '0';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

func TestAtomicTStoreCModeContext(mode: bits(3))
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(
        AtomicContextStart('00001'), 32);
    assert started == CommandExecution_Executed;
    let accepted = ExecuteCommandInstruction(
        AtomicContextDATR(mode, TRUE), 32);
    assert accepted == CommandExecution_Executed && _LastFault == Fault_None;
    assert _BundleDataAttributesPresent &&
           _BundleDataAttributes.comparison_mode == mode &&
           _BundleDataAttributes.canonicalize;

    ResetProfileState();
    let non_tstore = ExecuteCommandInstruction(
        AtomicContextStart('00000'), 32);
    assert non_tstore == CommandExecution_Executed;
    let rejected_load = ExecuteCommandInstruction(
        AtomicContextDATR(mode, TRUE), 32);
    assert rejected_load == CommandExecution_Rejected &&
           _LastFault == Fault_IllegalInstruction;
    assert !_BundleDataAttributesPresent;

    ResetProfileState();
    let normal_tstore = ExecuteCommandInstruction(
        AtomicContextStart('00001'), 32);
    assert normal_tstore == CommandExecution_Executed;
    let rejected_normal = ExecuteCommandInstruction(
        AtomicContextDATR(mode, FALSE), 32);
    assert rejected_normal == CommandExecution_Rejected &&
           _LastFault == Fault_IllegalInstruction;
    assert !_BundleDataAttributesPresent;
end;

func main() => integer
begin
    TestAtomicTStoreCModeContext('110');
    TestAtomicTStoreCModeContext('111');
    return 0;
end;
