// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTBUNDLEOPERATIONDESCRIPTORFIELDS-EXECUTION-001","source":"asl/block/model/state/descriptor-state.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for TestBundleOperationDescriptorFields","pass_condition":"TestBundleOperationDescriptorFields completes without assertion failure","related_sources":[]}
pure func BundleTestTEPLStart(selector: bits(10), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BundleTestCUBEStart(function: bits(5), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[24:20] = function;
    instruction[31:27] = data_type;
    return instruction;
end;

func TestBundleOperationDescriptorFields()
begin
    // Generic selector and DataType fields are preserved exactly.
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let tepl_instruction =
        BundleTestTEPLStart(Zeros{10} + 0x2b, Zeros{5} + 24);
    let tepl_decoded = DecodeCommandForm(tepl_instruction, 32);
    assert tepl_decoded != PTO_COMMAND_FORM_COUNT;
    let tepl_form = tepl_decoded as integer {0..PTO_COMMAND_FORM_COUNT-1};
    let tepl = ExecuteCommandInstruction(tepl_instruction, 32);
    assert tepl == CommandExecution_Executed;
    assert _BundleOperation.valid;
    assert _BundleOperation.form_identity == Zeros{7} + tepl_form;
    assert _BundleOperation.operation_class == BundleOperation_TileElement;
    assert _BundleOperation.selector == Zeros{10} + 0x2b;
    assert _BundleOperation.data_type == Zeros{5} + 24;

    for data_type_code = 0 to 31 do
        let data_type = Zeros{5} + data_type_code;
        let expected = data_type_code <= 14 ||
                       (16 <= data_type_code && data_type_code <= 20) ||
                       (24 <= data_type_code && data_type_code <= 28);
        assert BundleDataTypeSupported(data_type) == expected;
    end;
    assert BundleTileDataType(Zeros{5}) == TileDataType_FP64;
    assert BundleTileDataType(Zeros{5} + 1) == TileDataType_FP32;
    assert BundleTileDataType(Zeros{5} + 2) == TileDataType_TF32;
    assert BundleTileDataType(Zeros{5} + 3) == TileDataType_HF32;
    assert BundleTileDataType(Zeros{5} + 4) == TileDataType_FP16;
    assert BundleTileDataType(Zeros{5} + 5) == TileDataType_BF16;
    assert BundleTileDataType(Zeros{5} + 6) == TileDataType_HiF8;
    assert BundleTileDataType(Zeros{5} + 7) == TileDataType_E4M3;
    assert BundleTileDataType(Zeros{5} + 8) == TileDataType_E5M2;
    assert BundleTileDataType(Zeros{5} + 9) == TileDataType_E3M2;
    assert BundleTileDataType(Zeros{5} + 10) == TileDataType_E2M3;
    assert BundleTileDataType(Zeros{5} + 11) == TileDataType_E2M1X2;
    assert BundleTileDataType(Zeros{5} + 12) == TileDataType_E1M2X2;
    assert BundleTileDataType(Zeros{5} + 13) == TileDataType_E8M0;
    assert BundleTileDataType(Zeros{5} + 14) == TileDataType_HiF4X2;
    assert BundleTileDataType(Zeros{5} + 16) == TileDataType_S64;
    assert BundleTileDataType(Zeros{5} + 17) == TileDataType_S32;
    assert BundleTileDataType(Zeros{5} + 18) == TileDataType_S16;
    assert BundleTileDataType(Zeros{5} + 19) == TileDataType_S8;
    assert BundleTileDataType(Zeros{5} + 20) == TileDataType_S4X2;
    assert BundleTileDataType(Zeros{5} + 24) == TileDataType_U64;
    assert BundleTileDataType(Zeros{5} + 25) == TileDataType_U32;
    assert BundleTileDataType(Zeros{5} + 26) == TileDataType_U16;
    assert BundleTileDataType(Zeros{5} + 27) == TileDataType_U8;
    assert BundleTileDataType(Zeros{5} + 28) == TileDataType_U4X2;
    // MPAR Mode is architectural descriptor state, including all encodings.
    for mode = 0 to 3 do
        ResetBundleControlState();
        SetCurrentACR(0);
        ClearFault();
        WriteTPC(Zeros{PTO_XLEN} + 0x200);
        var mpar: bits(64) = Zeros{64} + 0x00001181;
        mpar[26:25] = Zeros{2} + mode;
        let status = ExecuteCommandInstruction(mpar, 32);
        assert status == CommandExecution_Executed;
        assert _BundleOperation.operation_class == BundleOperation_Machine;
        assert _BundleOperation.mode_valid;
        assert _BundleOperation.mode == Zeros{2} + mode;
    end;

    // The compressed BrType domain is {FALL, IND, ICALL, RET}.
    for branch_type = 1 to 7 do
        ResetBundleControlState();
        SetCurrentACR(0);
        ClearFault();
        WriteTPC(Zeros{PTO_XLEN} + 0x300);
        var compressed: bits(64) = Zeros{64};
        compressed[13:11] = Zeros{3} + branch_type;
        let status = ExecuteCommandInstruction(compressed, 16);
        if branch_type == 1 || branch_type >= 5 then
            assert status == CommandExecution_Executed;
            assert _BundleOperation.branch_type_valid;
            assert _BundleOperation.branch_type == Zeros{3} + branch_type;
            if branch_type == 1 then
                assert _BundleTransfer == BundleTransfer_Fallthrough;
            elsif branch_type == 5 then
                assert _BundleTransfer == BundleTransfer_Indirect;
            elsif branch_type == 6 then
                assert _BundleTransfer == BundleTransfer_IndirectCall;
            else
                assert _BundleTransfer == BundleTransfer_Return;
            end;
        else
            assert status == CommandExecution_Rejected;
            assert _LastFault == Fault_IllegalInstruction;
            assert !_TrapContexts[[0]].bundle_operation.valid;
        end;
    end;

    // Reserved selectors, unsupported DataTypes, generic CUBE holes, and the
    // unprofiled FIXP family fault before installing a bundle descriptor.
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    let reserved_selector = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10} + 14, Zeros{5} + 24), 32);
    assert reserved_selector == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert !_TrapContexts[[0]].bundle_operation.valid;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x500);
    let unsupported_type = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10}, Ones{5}), 32);
    assert unsupported_type == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert !_TrapContexts[[0]].bundle_operation.valid;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x600);
    let cube_hole = ExecuteCommandInstruction(
        BundleTestCUBEStart(Zeros{5} + 3, Zeros{5} + 24), 32);
    assert cube_hole == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert !_TrapContexts[[0]].bundle_operation.valid;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x700);
    var fixp: bits(64) = Zeros{64} + 0x00039181;
    fixp[31:27] = Zeros{5} + 24;
    let fixed_point = ExecuteCommandInstruction(fixp, 32);
    assert fixed_point == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert !_TrapContexts[[0]].bundle_operation.valid;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleOperationDescriptorFields();
    return 0;
end;
