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

pure func CompareContextStart(selector: bits(10)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

func TestComparisonCMode(selector: bits(10), mode: bits(3), legal: boolean)
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(
        CompareContextStart(selector), 32);
    assert started == CommandExecution_Executed;
    assert _BundleOperation.valid && _BundleOperation.selector_valid &&
           _BundleOperation.operation_class == BundleOperation_TileElement &&
           _BundleOperation.selector == selector &&
           _BundleOperation.data_type_valid &&
           _BundleOperation.data_type ==
               TileDataTypeToEncoding(TileDataType_U32);
    let datr = ExecuteCommandInstruction(
        AtomicContextDATR(mode, TRUE), 32);
    if legal then
        assert datr == CommandExecution_Executed &&
               _LastFault == Fault_None && _BundleDataAttributesPresent &&
               _BundleDataAttributes.comparison_mode == mode &&
               _BundleDataAttributes.canonicalize;
    else
        assert datr == CommandExecution_Rejected &&
               _LastFault == Fault_IllegalInstruction &&
               !_BundleDataAttributesPresent &&
               !_BundleDataAttributes.data_type_present &&
               _BundleDataAttributes.comparison_mode == Zeros{3};
    end;
end;

func TestComparisonCModeMatrix(selector: bits(10))
begin
    TestComparisonCMode(selector, '000', TRUE);
    TestComparisonCMode(selector, '001', TRUE);
    TestComparisonCMode(selector, '010', TRUE);
    TestComparisonCMode(selector, '011', TRUE);
    TestComparisonCMode(selector, '100', TRUE);
    TestComparisonCMode(selector, '101', TRUE);
    TestComparisonCMode(selector, '110', FALSE);
    TestComparisonCMode(selector, '111', FALSE);
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
    // The two extended CMode values are reserved for atomic TSTORE, not
    // comparison commands. Each comparison form also retains modes 0..5.
    TestComparisonCModeMatrix(Zeros{10} + 0x00d);
    TestComparisonCModeMatrix(Zeros{10} + 0x02d);
    return 0;
end;
