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

pure func BundleTestNamedMxStart(function: integer {4..22},
                                 data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64};
    case function of
        when 4 => instruction = Zeros{64} + 0x00431181;
        when 5 => instruction = Zeros{64} + 0x00531181;
        when 6 => instruction = Zeros{64} + 0x00631181;
        when 20 => instruction = Zeros{64} + 0x01431181;
        when 21 => instruction = Zeros{64} + 0x01531181;
        when 22 => instruction = Zeros{64} + 0x01631181;
        otherwise => unreachable;
    end;
    instruction[31:27] = data_type;
    return instruction;
end;

func ExecuteBundleStartWithAcceptedApplicabilityRules(
    rules: NumericApplicabilityRuleSet,
    instruction: bits(64)) => CommandExecutionStatus
begin
    BeginArchitecturalInstructionAttempt();
    let decoded = DecodeCommandForm(instruction, 32);
    if decoded == PTO_COMMAND_FORM_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return CommandExecution_Rejected;
    end;
    let form = decoded as integer {0..PTO_COMMAND_FORM_COUNT-1};
    if !CommandFormOperandsLegal(instruction, form) ||
       CommandHandlerOfForm(form) != CommandHandler_ExecuteBundleStart then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return CommandExecution_Rejected;
    end;
    ExecuteDecodedBundleStartWithAcceptedApplicabilityRules(
        rules, instruction, form, 32);
    if _LastFault != Fault_None then return CommandExecution_Rejected; end;
    return CommandExecution_Executed;
end;

pure func BundleTestMxFunction(index: integer {0..5}) => integer {4..22}
begin
    case index of
        when 0 => return 4;
        when 1 => return 5;
        when 2 => return 6;
        when 3 => return 20;
        when 4 => return 21;
        when 5 => return 22;
        otherwise => unreachable;
    end;
end;

pure func BundleTestTileBinding(destination: bits(3), source0: bits(6),
                               source1: bits(6), last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[9:7] = destination;
    instruction[18:15] = Zeros{4} + 3;
    instruction[25:20] = source0;
    instruction[31:26] = source1;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

func BundleTestConfigureTile(index: TileIndex, data_type: TileDataType)
begin
    ConfigureTile(index, 256, 1, 1, 1, 1, data_type,
        TileLayout_RowMajor, TileLocation_Any);
end;

func TestBundleStateLifecycle()
begin
    ResetBundleControlState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    ClearFault();
    BeginBundle(BundleKind_Standard, BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x200, Zeros{PTO_XLEN} + 0x104,
        Zeros{PTO_XLEN} + 0x104, TRUE);
    assert _LastFault == Fault_None;
    assert BundleIsActive();
    assert !BundleBodyIsActive();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x200;

    EnterBundleBody();
    assert _LastFault == Fault_None;
    assert BundleBodyIsActive();

    StopBundle();
    assert _LastFault == Fault_None;
    assert !BundleIsActive();
    assert !BundleBodyIsActive();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;
end;

// PTO-REQ-BUNDLE-OPERATION-001: field sensitivity, lifecycle, and rollback.
func TestBundleOperationDescriptorFields()
begin
    // Generic selector and DataType fields are preserved exactly.
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let tepl = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10} + 0x2b, Zeros{5} + 24), 32);
    assert tepl == CommandExecution_Executed;
    assert _BundleOperation.valid;
    assert _BundleOperation.form_identity == Zeros{7} + 40;
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
        BundleTestTEPLStart(Zeros{10} + 105, Zeros{5} + 24), 32);
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

// PTO-REQ-PROFILE-001: the accepted A2A3 applicability rule rejects every
// named and generic MX start before descriptor installation or live-bundle
// completion. The portable PTO-v0 path remains covered by the positive tests.
func TestA2A3CubeMxBundleRejectionMatrix()
begin
    for function_index = 0 to 5 do
        let function = BundleTestMxFunction(function_index);
        for data_type_code = 0 to 31 do
            let data_type = Zeros{5} + data_type_code;
            if BundleDataTypeSupported(data_type) then
                ResetProfileState();
                WriteTPC(Zeros{PTO_XLEN} + 0x100);
                let named_status =
                    ExecuteBundleStartWithAcceptedApplicabilityRules(
                    NumericApplicabilityRules_A2A3MxRejection,
                    BundleTestNamedMxStart(function, data_type));
                assert named_status == CommandExecution_Rejected;
                assert _LastFault == Fault_IllegalInstruction;
                assert ReadTPC() == Zeros{PTO_XLEN} + 0x100;
                assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 1;
                assert _MemoryEventCount == 0;
                assert !_BundleOperation.valid;

                ResetProfileState();
                WriteTPC(Zeros{PTO_XLEN} + 0x200);
                let generic_status =
                    ExecuteBundleStartWithAcceptedApplicabilityRules(
                    NumericApplicabilityRules_A2A3MxRejection,
                    BundleTestCUBEStart(
                        Zeros{5} + function, data_type));
                assert generic_status == CommandExecution_Rejected;
                assert _LastFault == Fault_IllegalInstruction;
                assert ReadTPC() == Zeros{PTO_XLEN} + 0x200;
                assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 1;
                assert _MemoryEventCount == 0;
                assert !_BundleOperation.valid;
            end;
        end;

        // A rejected next start must not commit or replace the live bundle.
        ResetProfileState();
        BundleTestConfigureTile(0, TileDataType_U64);
        BundleTestConfigureTile(1, TileDataType_U64);
        BundleTestConfigureTile(2, TileDataType_U64);
        WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
        WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
        WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 99);
        WriteTPC(Zeros{PTO_XLEN} + 0x300);
        let live_start = ExecuteCommandInstruction(
            BundleTestTEPLStart(Zeros{10}, Zeros{5} + 24), 32);
        let live_binding = ExecuteCommandInstruction(BundleTestTileBinding(
            '010', Zeros{6}, Zeros{6} + 1, TRUE), 32);
        let rejected_named =
            ExecuteBundleStartWithAcceptedApplicabilityRules(
            NumericApplicabilityRules_A2A3MxRejection,
            BundleTestNamedMxStart(function, Zeros{5} + 24));
        assert live_start == CommandExecution_Executed;
        assert live_binding == CommandExecution_Executed;
        assert rejected_named == CommandExecution_Rejected;
        assert _LastFault == Fault_IllegalInstruction;
        assert _FaultAddress == Zeros{PTO_XLEN} + 0x308;
        assert ReadTPC() == Zeros{PTO_XLEN} + 0x308;
        assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 3;
        assert _MemoryEventCount == 0;
        assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 99;
        assert _TrapContexts[[0]].bundle_active;
        assert _TrapContexts[[0]].tpc == Zeros{PTO_XLEN} + 0x308;
        assert _TrapContexts[[0]].bundle_operation.selector == Zeros{10};

        ResetProfileState();
        BundleTestConfigureTile(0, TileDataType_U64);
        BundleTestConfigureTile(1, TileDataType_U64);
        BundleTestConfigureTile(2, TileDataType_U64);
        WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
        WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
        WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 99);
        WriteTPC(Zeros{PTO_XLEN} + 0x400);
        let generic_live_start = ExecuteCommandInstruction(
            BundleTestTEPLStart(Zeros{10}, Zeros{5} + 24), 32);
        let generic_live_binding = ExecuteCommandInstruction(
            BundleTestTileBinding('010', Zeros{6}, Zeros{6} + 1, TRUE), 32);
        let rejected_generic =
            ExecuteBundleStartWithAcceptedApplicabilityRules(
            NumericApplicabilityRules_A2A3MxRejection,
            BundleTestCUBEStart(
                Zeros{5} + function, Zeros{5} + 24));
        assert generic_live_start == CommandExecution_Executed;
        assert generic_live_binding == CommandExecution_Executed;
        assert rejected_generic == CommandExecution_Rejected;
        assert _LastFault == Fault_IllegalInstruction;
        assert _FaultAddress == Zeros{PTO_XLEN} + 0x408;
        assert ReadTPC() == Zeros{PTO_XLEN} + 0x408;
        assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 3;
        assert _MemoryEventCount == 0;
        assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 99;
        assert _TrapContexts[[0]].bundle_active;
        assert _TrapContexts[[0]].tpc == Zeros{PTO_XLEN} + 0x408;
        assert _TrapContexts[[0]].bundle_operation.selector == Zeros{10};
    end;

    // Structural invalidity remains fail-closed and precedes profile lookup.
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x500);
    let reserved_type = ExecuteBundleStartWithAcceptedApplicabilityRules(
        NumericApplicabilityRules_A2A3MxRejection,
        BundleTestNamedMxStart(4, Ones{5}));
    assert reserved_type == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert !_BundleOperation.valid;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x600);
    let unknown_function = ExecuteBundleStartWithAcceptedApplicabilityRules(
        NumericApplicabilityRules_A2A3MxRejection,
        BundleTestCUBEStart(Zeros{5} + 3, Zeros{5} + 24));
    assert unknown_function == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert !_BundleOperation.valid;
end;

func TestBundleTileCommitLifecycle()
begin
    ResetProfileState();
    BundleTestConfigureTile(0, TileDataType_U64);
    BundleTestConfigureTile(1, TileDataType_U64);
    BundleTestConfigureTile(2, TileDataType_U64);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 9);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 99);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);

    let start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10}, Zeros{5} + 24), 32);
    assert start == CommandExecution_Executed;
    assert BundleIsActive();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;
    let binding = ExecuteCommandInstruction(BundleTestTileBinding(
        '010', Zeros{6}, Zeros{6} + 1, TRUE), 32);
    assert binding == CommandExecution_Executed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x108;
    let stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert stop == CommandExecution_Executed;
    assert !BundleIsActive();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x10c;
    // DstTile selects hand 2, not physical tile 2. The first free tile in
    // hand 2 is tile 32; the pre-existing physical tile 2 is preserved.
    assert _Tiles[[32]].allocated;
    assert ReadTileElement(32, 0, 0) == Zeros{PTO_XLEN} + 16;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 99;
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 3;

    // A following BSTART is also a commit boundary and installs only the next
    // descriptor after the previous tile effect succeeds.
    ResetProfileState();
    BundleTestConfigureTile(0, TileDataType_U64);
    BundleTestConfigureTile(1, TileDataType_U64);
    BundleTestConfigureTile(2, TileDataType_U64);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 99);
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    let first_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10}, Zeros{5} + 24), 32);
    let first_binding = ExecuteCommandInstruction(BundleTestTileBinding(
        '010', Zeros{6}, Zeros{6} + 1, TRUE), 32);
    var next_start: bits(64) = Zeros{64} + 0x00000011;
    next_start[31:7] = Zeros{25} + 4;
    let next_status = ExecuteCommandInstruction(next_start, 32);
    assert first_start == CommandExecution_Executed;
    assert first_binding == CommandExecution_Executed;
    assert next_status == CommandExecution_Executed;
    assert _Tiles[[32]].allocated;
    assert ReadTileElement(32, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 99;
    assert _BundleOperation.operation_class == BundleOperation_Control;
    assert !_BundleOperation.selector_valid;
    assert BundleIsActive();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x20c;
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 3;
end;

func TestBundleTileCommitRollback()
begin
    // Missing B.IOT is a bundle-control fault with no destination update.
    ResetProfileState();
    BundleTestConfigureTile(2, TileDataType_U64);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 99);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let missing_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10}, Zeros{5} + 24), 32);
    let missing_stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert missing_start == CommandExecution_Executed;
    assert missing_stop == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 99;

    // A complete B.IOT cannot silently default an operand that the selected
    // direct tile operation requires but the PTO-v0 bundle bridge cannot bind.
    ResetProfileState();
    BundleTestConfigureTile(2, TileDataType_U64);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 99);
    StartMemoryEventCapture(0);
    WriteTPC(Zeros{PTO_XLEN} + 0x280);
    var tload_start_instruction: bits(64) = Zeros{64} + 0x00011181;
    tload_start_instruction[31:27] = Zeros{5} + 24;
    let tload_start = ExecuteCommandInstruction(tload_start_instruction, 32);
    let tload_binding = ExecuteCommandInstruction(BundleTestTileBinding(
        '010', Zeros{6}, Zeros{6}, TRUE), 32);
    let tload_stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert tload_start == CommandExecution_Executed;
    assert tload_binding == CommandExecution_Executed;
    assert tload_stop == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 99;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    assert _TrapContexts[[0]].bundle_operation.valid;

    // A faulting next start is validated before it can commit the live bundle.
    ResetProfileState();
    BundleTestConfigureTile(0, TileDataType_U64);
    BundleTestConfigureTile(1, TileDataType_U64);
    BundleTestConfigureTile(2, TileDataType_U64);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 99);
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    let live_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10}, Zeros{5} + 24), 32);
    let live_binding = ExecuteCommandInstruction(BundleTestTileBinding(
        '010', Zeros{6}, Zeros{6} + 1, TRUE), 32);
    let invalid_next = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10} + 105, Zeros{5} + 24), 32);
    assert live_start == CommandExecution_Executed;
    assert live_binding == CommandExecution_Executed;
    assert invalid_next == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 99;
    assert _TrapContexts[[0]].bundle_active;
    assert _TrapContexts[[0]].bundle_operation.selector == Zeros{10};
end;

func TestBundleDataAttributes0571()
begin
    ResetProfileState();
    assert TileDataLayoutCodeAccepted(Zeros{5});
    assert TileDataLayoutCodeAccepted(Zeros{5} + 1);
    assert TileDataLayoutCodeAccepted(Zeros{5} + 30);
    assert !TileDataLayoutCodeAccepted(Zeros{5} + 2);
    assert TileDataLayoutCodeSupported(Zeros{5});
    assert !TileDataLayoutCodeSupported(Zeros{5} + 1);

    ClearFault();
    SetBundleDataAttributeState0571(Zeros{5} + 24, Zeros{5}, '11',
        Zeros{3} + 1, Zeros{3} + 2, TRUE, TRUE);
    assert _LastFault == Fault_None;
    assert CurrentBundleDataTypeCode() == Zeros{5} + 24;
    assert CurrentBundlePadValue() == TilePad_Null;
    assert CurrentBundleCanonicalize();

    // Accepted implementation-defined layouts are rejected by generic
    // indexing until the implementation advertises support.
    ClearFault();
    SetBundleDataAttributeState0571(Zeros{5} + 24, Zeros{5} + 1, '00',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    assert _LastFault == Fault_TileLegality;
    assert CurrentBundleDataTypeCode() == Zeros{5} + 24;
    AdvertiseTileDataLayout(Zeros{5} + 1);
    ClearFault();
    SetBundleDataAttributeState0571(Zeros{5} + 24, Zeros{5} + 1, '00',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    assert _LastFault == Fault_None;
    assert TileDataLayoutCodeSupported(Zeros{5} + 1);

    ClearFault();
    SetBundleDataAttributeState0571(Zeros{5} + 15, Zeros{5}, '00',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    assert _LastFault == Fault_TileLegality;
end;

func TestBundleTileAllocationAndLifetime()
begin
    ResetProfileState();
    BundleTestConfigureTile(0, TileDataType_U64);
    BundleTestConfigureTile(1, TileDataType_U64);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 9);
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7},
        operation_class = BundleOperation_TileElement,
        selector_valid = TRUE,
        selector = Zeros{10},
        data_type_valid = TRUE,
        data_type = Zeros{5} + 24,
        mode_valid = FALSE,
        mode = Zeros{2},
        branch_type_valid = FALSE,
        branch_type = Zeros{3}
    });
    AddBundleTileBinding(TRUE, 0, 3, TRUE, TRUE, 0, 1,
        FALSE, TRUE, TRUE);
    assert _LastFault == Fault_None;
    assert BundleTileDestinationSizeLegal(0);
    assert BundleTileDestinationSizeBytes(0) == 128;

    // Allocation makes the selected destination undefined. Rejection rolls
    // back both the allocation and the pending source lifetime transition.
    let rejected_resolved = ResolveBundleTileDestinations();
    assert rejected_resolved;
    let rejected_destination = _BundleTileBindings[[0]].destination;
    assert rejected_destination == 2;
    assert _Tiles[[rejected_destination]].allocated;
    assert !_Tiles[[rejected_destination]].contents_defined;
    FinalizeBundleTileAttempt(TileExecution_Rejected);
    RollBackBundleTileDestinations();
    assert !_Tiles[[rejected_destination]].allocated;
    assert _Tiles[[0]].allocated;
    assert _Tiles[[1]].allocated;

    // A successful attempt retains the destination, consumes a non-reused
    // source, and preserves a source explicitly marked for reuse.
    let committed_resolved = ResolveBundleTileDestinations();
    assert committed_resolved;
    let committed_destination = _BundleTileBindings[[0]].destination;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    assert _Tiles[[committed_destination]].allocated;
    assert !_Tiles[[0]].allocated;
    assert _Tiles[[1]].allocated;

    ResetBundleControlState();
    ClearFault();
    AddBundleTileBinding(TRUE, 0, 2, FALSE, FALSE, 0, 0,
        FALSE, FALSE, TRUE);
    assert _LastFault == Fault_TileLegality;
end;

func TestBundleTileUndersizedAllocation()
begin
    ResetProfileState();
    ConfigureTile(16, 256, 32, 1, 32, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 31 do
        WriteTileElement(16, row as integer {0..65535}, 0,
            Zeros{PTO_XLEN} + row);
    end;
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7},
        operation_class = BundleOperation_TileElement,
        selector_valid = TRUE,
        selector = Zeros{10},
        data_type_valid = TRUE,
        data_type = Zeros{5} + 24,
        mode_valid = FALSE,
        mode = Zeros{2},
        branch_type_valid = FALSE,
        branch_type = Zeros{3}
    });
    AddBundleTileBinding(TRUE, 0, 3, TRUE, FALSE, 16, 0,
        FALSE, FALSE, TRUE);
    ClearFault();
    let undersized_resolved = ResolveBundleTileDestinations();
    assert !undersized_resolved;
    assert _LastFault == Fault_TileAllocation;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert _Tiles[[16]].allocated;
    assert ReadTileElement(16, 31, 0) == Zeros{PTO_XLEN} + 31;
    for candidate = 0 to 15 do
        assert !_Tiles[[candidate]].allocated;
    end;
end;

func TestBundleFaults()
begin
    ResetBundleControlState();
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    ClearFault();
    StopBundle();
    assert _LastFault == Fault_BundleControl;
    assert _ACRTrapNumber[[CurrentACR()]] == Zeros{6} + 5;

    ResetBundleControlState();
    ClearFault();
    BeginBundle(BundleKind_Standard, BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x401, Zeros{PTO_XLEN} + 0x304,
        Zeros{PTO_XLEN} + 0x304, TRUE);
    assert _LastFault == Fault_InstructionPC;
    assert !BundleIsActive();
end;

func TestTrapContextRouteAndRecover()
begin
    ResetBundleControlState();
    ClearFault();
    SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f01, Zeros{PTO_XLEN} + 0x900);

    SetCurrentACR(2);
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    WriteBPC(Zeros{PTO_XLEN} + 0x340);
    SetBundleArgument(Zeros{PTO_XLEN} + 0x55);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x11);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0x22);
    BeginBundle(BundleKind_Standard, BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x500, Zeros{PTO_XLEN} + 0x304,
        Zeros{PTO_XLEN} + 0x304, TRUE);
    InstallBundleOperationDescriptor(DecodeBundleOperationDescriptor(
        BundleTestTEPLStart(Zeros{10}, Zeros{5} + 24), 48));
    EnterBundleBody();
    SetBundleDimension(2, Zeros{PTO_XLEN} + 0x33);
    SetBundleScalarBinding(31, 5, 2, 3, 4, 3);
    SetBundleTileBinding(15, TRUE, 2, 8, TRUE, TRUE, 10, 11,
        TRUE, FALSE, TRUE);
    SetBundleControlAttributeState(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE);
    SetBundleDataAttributeState(Zeros{5} + 1, Zeros{5} + 2,
        Zeros{2} + 3, Zeros{3} + 1, Zeros{3} + 2, TRUE);

    SetFault(Fault_DataPage, Zeros{PTO_XLEN} + 0x2222);
    assert CurrentACR() == 1;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x900;
    assert _ACRTrapNumber[[1]] == Zeros{6} + 35;
    assert _ACRTrapArgument0[[1]] == Zeros{PTO_XLEN} + 0x2222;
    assert _TrapContexts[[1]].valid;
    assert _TrapContexts[[1]].source_acr == 2;
    assert _TrapContexts[[1]].tpc == Zeros{PTO_XLEN} + 0x500;
    assert _TrapContexts[[1]].bpc == Zeros{PTO_XLEN} + 0x500;
    assert _TrapContexts[[1]].bundle_argument == Zeros{PTO_XLEN} + 0x55;
    assert _TrapContexts[[1]].bundle_operation.valid;
    assert _TrapContexts[[1]].bundle_operation.form_identity == Zeros{7} + 48;
    assert _TrapContexts[[1]].bundle_operation.selector == Zeros{10};
    assert _TrapContexts[[1]].bundle_operation.data_type == Zeros{5} + 24;
    assert _TrapContexts[[1]].bundle_body_active;
    assert _TrapContexts[[1]].bundle_dimensions[[2]] ==
        Zeros{PTO_XLEN} + 0x33;
    assert _TrapContexts[[1]].bundle_scalar_bindings[[31]].destination == 5;
    assert _TrapContexts[[1]].bundle_tile_bindings[[15]].destination == 2;
    assert _TrapContexts[[1]].bundle_control_attributes.atomic;
    assert _TrapContexts[[1]].bundle_data_attributes.saturating;
    assert _TrapContexts[[1]].t_queue[[0]] == Zeros{PTO_XLEN} + 0x11;
    assert _TrapContexts[[1]].u_queue[[0]] == Zeros{PTO_XLEN} + 0x22;

    WriteTPC(Zeros{PTO_XLEN} + 0xabc);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x99);
    SetBundleDimension(2, Ones{PTO_XLEN});
    SetBundleScalarBinding(31, 1, 1, 1, 1, 1);
    SetBundleTileBinding(15, FALSE, 1, 1, FALSE, FALSE, 1, 1,
        FALSE, FALSE, FALSE);
    SetBundleControlAttributeState(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE);
    SetBundleDataAttributeState(Zeros{5}, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE);
    ArchitectureEnterRequest('0001');
    assert CurrentACR() == 2;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x500;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x500;
    assert _BundleArgument == Zeros{PTO_XLEN} + 0x55;
    assert _BundleOperation.valid;
    assert _BundleOperation.form_identity == Zeros{7} + 48;
    assert _BundleOperation.selector == Zeros{10};
    assert _BundleOperation.data_type == Zeros{5} + 24;
    assert _CommitArgument == Zeros{PTO_XLEN} + 0x55;
    assert BundleBodyIsActive();
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x11;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x22;
    assert _BundleDimensions[[2]] == Zeros{PTO_XLEN} + 0x33;
    assert _BundleScalarBindings[[31]].destination == 5;
    assert _BundleScalarBindings[[31]].source_count == 3;
    assert _BundleTileBindings[[15]].destination == 2;
    assert _BundleTileBindings[[15]].source0_reuse;
    assert _BundleControlAttributes.atomic;
    assert _BundleControlAttributes.release;
    assert _BundleDataAttributes.data_type == Zeros{5} + 1;
    assert _BundleDataAttributes.saturating;
    assert !_TrapContexts[[1]].valid;
end;

func TestBundleConfigurationState()
begin
    ResetBundleControlState();
    WriteGPR(2, Zeros{PTO_XLEN} + 33);
    SetBundleDimension(1, ReadScalarRegisterOperand(2) + (Zeros{PTO_XLEN} + 7));
    assert _BundleDimensions[[1]] == Zeros{PTO_XLEN} + 40;

    SetBundleScalarBinding(0, 5, 2, 3, 4, 3);
    assert _BundleScalarBindings[[0]].valid;
    assert _BundleScalarBindings[[0]].destination == 5;
    assert _BundleScalarBindings[[0]].source2 == 4;

    SetBundleTileBinding(0, TRUE, 2, 8, TRUE, TRUE, 10, 11,
        TRUE, FALSE, TRUE);
    assert _BundleTileBindings[[0]].valid;
    assert _BundleTileBindings[[0]].destination_valid;
    assert _BundleTileBindings[[0]].destination == 2;
    assert _BundleTileBindings[[0]].source0 == 10;
    assert _BundleTileBindings[[0]].source0_reuse;
    assert _BundleTileBindings[[0]].last;
end;

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
    assert _BundleTransfer == BundleTransfer_Direct;
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
    assert _BundleTransfer == BundleTransfer_Call;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x304;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0x308;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x308;
end;

readonly func FirstCommandFormWithHandler(handler: CommandSemanticHandler)
    => integer {0..PTO_COMMAND_FORM_COUNT-1}
begin
    var selected: integer {0..PTO_COMMAND_FORM_COUNT-1} = 0;
    var found = FALSE;
    for form = 0 to PTO_COMMAND_FORM_COUNT - 1 do
        if !found &&
           CommandHandlerOfForm(
               form as integer {0..PTO_COMMAND_FORM_COUNT-1}) == handler then
            selected = form as integer {0..PTO_COMMAND_FORM_COUNT-1};
            found = TRUE;
        end;
    end;
    assert found;
    return selected;
end;

func TestBundleCommandTotalityBoundaries()
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    let memory_copy_form =
        FirstCommandFormWithHandler(CommandHandler_ExecuteMemoryCopy);
    let memory_command_status = ExecuteDecodedBundleCommand(
        Zeros{64}, memory_copy_form, 32);
    assert memory_command_status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x204;

    ResetProfileState();
    WriteMemoryByte(Zeros{PTO_XLEN} + 8, Zeros{8} + 0x11);
    WriteMemoryByte(Zeros{PTO_XLEN} + 9, Zeros{8} + 0x22);
    WriteMemoryByte(Zeros{PTO_XLEN} + 10, Zeros{8} + 0x33);
    ExecuteBoundedMemoryCopy(Zeros{PTO_XLEN} + 16,
        Zeros{PTO_XLEN} + 8, Zeros{PTO_XLEN} + 3);
    assert _LastFault == Fault_None;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 16) == Zeros{8} + 0x11;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 17) == Zeros{8} + 0x22;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 18) == Zeros{8} + 0x33;
    let last_address = _LastMemoryCommandAddress;
    let last_size = _LastMemoryCommandSize;
    ExecuteBoundedMemoryCopy(Zeros{PTO_XLEN} + 32,
        Zeros{PTO_XLEN} + 8, Zeros{PTO_XLEN} + 64);
    assert _LastFault == Fault_IllegalInstruction;
    assert _LastMemoryCommandAddress == last_address;
    assert _LastMemoryCommandSize == last_size;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 32) == Zeros{8};

    // The decoded MSET path applies the same full-XLEN bound and does not
    // reduce 64 to zero through a low-bit surrogate.
    ResetProfileState();
    WriteGPR(2, Zeros{PTO_XLEN} + 0x80);
    WriteGPR(3, Zeros{PTO_XLEN} + 0xa5);
    WriteGPR(4, Zeros{PTO_XLEN} + 64);
    WriteTPC(Zeros{PTO_XLEN} + 0x280);
    var oversized_mset: bits(64) = Zeros{64} + 0x00002031;
    oversized_mset[19:15] = Zeros{5} + 2;
    oversized_mset[24:20] = Zeros{5} + 3;
    oversized_mset[31:27] = Zeros{5} + 4;
    let oversized_mset_status = ExecuteCommandInstruction(oversized_mset, 32);
    assert oversized_mset_status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x280;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 0x80) == Zeros{8};

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    let hint_instruction = Ones{64};
    let hint_form =
        FirstCommandFormWithHandler(CommandHandler_SetBundleHint);
    let hint_status =
        ExecuteDecodedBundleCommand(hint_instruction, hint_form, 32);
    assert hint_status == CommandExecution_Executed;
    assert _LastBundleHintPayload == hint_instruction;
    assert _BundleHintEpoch == 1;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x304;
end;
