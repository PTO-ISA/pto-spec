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

pure func BundleTestTLSUStart(function: bits(5), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
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

pure func BundleTestTileBinding(destination: bits(2), source0: bits(6),
                               source1: bits(6), last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[11:9] = '001';
    instruction[8:7] = destination;
    instruction[18:15] = Zeros{4} + 3;
    instruction[25:20] = source0;
    instruction[31:26] = source1;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

pure func BundleTestTileBindingV5(tile_size: bits(3), destination: bits(2),
                                 pe_mask: bits(4), source0: bits(6),
                                 last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = tile_size;
    instruction[8:7] = destination;
    instruction[18:15] = pe_mask;
    instruction[25:20] = source0;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

pure func BundleTestTwoSourceDestinationV5(
    tile_size: bits(3), destination: bits(2), pe_mask: bits(4),
    source0: bits(6), source1: bits(6), last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[11:9] = tile_size;
    instruction[8:7] = destination;
    instruction[18:15] = pe_mask;
    instruction[25:20] = source0;
    instruction[31:26] = source1;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

pure func BundleTestSharedBinding(shared_id: bits(8)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = '1111';
    instruction[11:9] = '000';
    return instruction;
end;

pure func BundleTestSharedDestination(shared_id: bits(8), pe_mask: bits(4),
                                      tile_size: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = pe_mask;
    instruction[11:9] = tile_size;
    return instruction;
end;

pure func BundleTestScalarBinding(destination: bits(5), source0: bits(5),
                                  source1: bits(5), source2: bits(5))
                                  => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[11:7] = destination;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    instruction[31:27] = source2;
    return instruction;
end;

pure func BundleTestTileDestinationV5(tile_size: bits(3),
                                      destination: bits(2),
                                      pe_mask: bits(4), last: boolean)
                                      => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[11:9] = tile_size;
    instruction[8:7] = destination;
    instruction[18:15] = pe_mask;
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
    let tepl_instruction =
        BundleTestTEPLStart(Zeros{10} + 0x2b, Zeros{5} + 24);
    let tepl_form = DecodeCommandForm(tepl_instruction, 32);
    assert tepl_form != PTO_COMMAND_FORM_COUNT;
    let tepl = ExecuteCommandInstruction(
        tepl_instruction, 32);
    assert tepl == CommandExecution_Executed;
    assert _BundleOperation.valid;
    assert _BundleOperation.form_identity == Zeros{7} +
        (tepl_form as integer {0..PTO_COMMAND_FORM_COUNT-1});
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
            '10', Zeros{6}, Zeros{6} + 1, TRUE), 32);
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
            BundleTestTileBinding('10', Zeros{6}, Zeros{6} + 1, TRUE), 32);
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
        '10', Zeros{6}, Zeros{6} + 1, TRUE), 32);
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
        '10', Zeros{6}, Zeros{6} + 1, TRUE), 32);
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
        '10', Zeros{6}, Zeros{6}, TRUE), 32);
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
        '10', Zeros{6}, Zeros{6} + 1, TRUE), 32);
    let invalid_next = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10} + 14, Zeros{5} + 24), 32);
    assert live_start == CommandExecution_Executed;
    assert live_binding == CommandExecution_Executed;
    assert invalid_next == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 99;
    assert _TrapContexts[[0]].bundle_active;
    assert _TrapContexts[[0]].bundle_operation.selector == Zeros{10};
end;

func TestBundleTileBindingV5Schemas()
begin
    // TMOV Local-to-Shared uses Function 8/9, requires a nonzero TSize,
    // carries no Local destination, and reserves DstTile as zero.
    ResetProfileState();
    let insert_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01000', Zeros{5} + 24), 32);
    let size_one = ExecuteCommandInstruction(
        BundleTestTileBindingV5('001', '00', '0011', Zeros{6}, TRUE), 32);
    assert insert_start == CommandExecution_Executed;
    assert size_one == CommandExecution_Executed;
    assert _BundleOperation.selector == Zeros{10} + 8;
    assert _BundleTileBindings[[0]].valid;
    assert !_BundleTileBindings[[0]].destination_valid;
    assert _BundleTileBindings[[0]].destination_size == 1;
    assert _BundleTileBindings[[0]].pe_mask == '0011';

    ResetProfileState();
    let publish_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01001', Zeros{5} + 24), 32);
    let size_seven = ExecuteCommandInstruction(
        BundleTestTileBindingV5('111', '00', '1100', Zeros{6}, TRUE), 32);
    assert publish_start == CommandExecution_Executed;
    assert size_seven == CommandExecution_Executed;
    assert !_BundleTileBindings[[0]].destination_valid;
    assert _BundleTileBindings[[0]].destination_size == 7;

    ResetProfileState();
    let zero_size_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01000', Zeros{5} + 24), 32);
    let zero_size = ExecuteCommandInstruction(
        BundleTestTileBindingV5('000', '00', '1111', Zeros{6}, TRUE), 32);
    assert zero_size_start == CommandExecution_Executed;
    assert zero_size == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].valid;

    ResetProfileState();
    let nonzero_destination_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01001', Zeros{5} + 24), 32);
    let nonzero_destination = ExecuteCommandInstruction(
        BundleTestTileBindingV5('001', '01', '1111', Zeros{6}, TRUE), 32);
    assert nonzero_destination_start == CommandExecution_Executed;
    assert nonzero_destination == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].valid;

    // Every B.IOT in one operation uses the same nonzero participant mask.
    ResetProfileState();
    let tepl_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10}, Zeros{5} + 24), 32);
    let first_mask = ExecuteCommandInstruction(
        BundleTestTileBindingV5('000', '00', '0011', Zeros{6}, FALSE), 32);
    let mismatched_mask = ExecuteCommandInstruction(
        BundleTestTileBindingV5('000', '00', '0101', Zeros{6} + 1, TRUE), 32);
    assert tepl_start == CommandExecution_Executed;
    assert first_mask == CommandExecution_Executed;
    assert mismatched_mask == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert _BundleTileBindings[[0]].valid;
    assert !_BundleTileBindings[[1]].valid;

    // GMOV is a fixed Core4 collective and rejects any mask other than 1111.
    ResetProfileState();
    let gmov_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01101', Zeros{5} + 24), 32);
    let partial_gmov = ExecuteCommandInstruction(
        BundleTestTileBindingV5('000', '00', '0111', Zeros{6}, TRUE), 32);
    assert gmov_start == CommandExecution_Executed;
    assert partial_gmov == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].valid;
end;

func TestBundleSharedBindingV5()
begin
    ResetProfileState();
    let first = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 0x12), 32);
    assert first == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].valid;
    assert _BundleSharedBindings[[0]].shared_id == Zeros{8} + 0x12;
    assert _BundleSharedBindings[[0]].pe_mask == '1111';
    assert _BundleSharedBindings[[0]].tile_size == 0;
    assert !_BundleSharedBindings[[0]].consumed;

    let duplicate = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 0x12), 32);
    assert duplicate == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleSharedBindings[[1]].valid;

    ResetProfileState();
    for shared_id = 0 to 3 do
        let accepted = ExecuteCommandInstruction(
            BundleTestSharedBinding(Zeros{8} + shared_id), 32);
        assert accepted == CommandExecution_Executed;
        assert _BundleSharedBindings[[shared_id]].valid;
        assert _BundleSharedBindings[[shared_id]].shared_id ==
            Zeros{8} + shared_id;
    end;
    let overflow = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 4), 32);
    assert overflow == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
end;

// PTO-REQ-SHARED-TILE-001: decoded Shared TLSU companions create, consume,
// move, and store persistent Shared-register state without adding tile identities.
func TestBundleSharedTLSUExecution()
begin
    // The complete Local schema consumes B.IOR in address/stride order.
    ResetProfileState();
    WriteGPR(2, Zeros{PTO_XLEN} + 0x500);
    WriteGPR(3, Zeros{PTO_XLEN} + 64);
    SetBundleScalarBinding(0, 0, 2, 3, 0, 2);
    let load_operation = DecodeTileOperation(TileDecode_TLSU, Zeros{12});
    assert load_operation != PTO_TILE_OPERATION_COUNT;
    let local_operands = BundleTileInstructionOperands(
        load_operation as integer {0..PTO_TILE_OPERATION_COUNT-1});
    assert local_operands.address == Zeros{PTO_XLEN} + 0x500;
    assert local_operands.scalar0 == Zeros{PTO_XLEN} + 64;

    // Omitted B.IOR derives a dense byte stride from LB2 and the transfer type.
    ResetProfileState();
    let omitted_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00000', Zeros{5} + 25), 32);
    assert omitted_start == CommandExecution_Executed;
    SetBundleDimension(2, Zeros{PTO_XLEN} + 16);
    let omitted_operands = BundleTileInstructionOperands(
        load_operation as integer {0..PTO_TILE_OPERATION_COUNT-1});
    assert omitted_operands.address == Zeros{PTO_XLEN};
    assert omitted_operands.scalar0 == Zeros{PTO_XLEN} + 64;

    // GM-to-Shared uses destination B.IOS+B.IOR. TSize is per PE and B.IOR
    // carries only canonical GPR selectors.
    ResetProfileState();
    _Memory[[0]] = Zeros{8} + 0x2a;
    _Memory[[64]] = Zeros{8} + 0x3b;
    WriteGPR(2, Zeros{PTO_XLEN});
    WriteGPR(3, Zeros{PTO_XLEN} + 64);
    let load_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00000', Zeros{5} + 24), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let load_shared = ExecuteCommandInstruction(
        BundleTestSharedDestination(Zeros{8} + 17, '1111', '001'), 32);
    let load_address = ExecuteCommandInstruction(
        BundleTestScalarBinding('00000', '00010', '00011', '00000'), 32);
    assert load_start == CommandExecution_Executed;
    assert load_shared == CommandExecution_Executed;
    assert load_address == CommandExecution_Executed;
    let load_completed = ExecuteBundleTileOperation();
    assert load_completed;
    assert _BundleSharedBindings[[0]].consumed;
    assert SharedTileFullyInitialized(Zeros{8} + 17);
    assert SharedTileRecord(Zeros{8} + 17).tile.capacity_bytes == 128;
    assert SharedTileRecord(Zeros{8} + 17).tile.payload[[0]] ==
        Zeros{PTO_XLEN} + 0x2a;
    assert SharedTileRecord(Zeros{8} + 17).tile.payload[[1]] ==
        Zeros{PTO_XLEN} + 0x3b;

    // B.IOS owns the Shared mask. PE_MASK=0000 is a strict no-op that performs
    // no memory access and does not initialize the Shared destination.
    ResetBundleControlState();
    ClearFault();
    WriteGPR(2, Zeros{PTO_XLEN} + 4096);
    let zero_load_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00000', Zeros{5} + 24), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let zero_load_shared = ExecuteCommandInstruction(
        BundleTestSharedDestination(Zeros{8} + 255, Zeros{4}, '001'), 32);
    let zero_load_address = ExecuteCommandInstruction(
        BundleTestScalarBinding('00000', '00010', '00000', '00000'), 32);
    assert zero_load_start == CommandExecution_Executed;
    assert zero_load_shared == CommandExecution_Executed;
    assert zero_load_address == CommandExecution_Executed;
    let zero_load_completed = ExecuteBundleTileOperation();
    assert zero_load_completed;
    assert _LastFault == Fault_None;
    assert !SharedTileRecord(Zeros{8} + 255).descriptor_valid;

    // An unmasked Shared store reads all four quarters.
    ResetBundleControlState();
    WriteGPR(2, Zeros{PTO_XLEN} + 8);
    WriteGPR(3, Zeros{PTO_XLEN} + 64);
    let store_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00001', Zeros{5} + 24), 32);
    let store_shared = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 17), 32);
    let store_address = ExecuteCommandInstruction(
        BundleTestScalarBinding('00000', '00010', '00011', '00000'), 32);
    assert store_start == CommandExecution_Executed;
    assert store_shared == CommandExecution_Executed;
    assert store_address == CommandExecution_Executed;
    let store_completed = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert store_completed;
    assert _Memory[[8]] == Zeros{8} + 0x2a;
    assert _Memory[[72]] == Zeros{8} + 0x3b;

    // TLSU Function 8 is MGATHER.CAS. Functions 9 through 12 and 14 through
    // 31 are Linx-only or reserved in PTO and must never re-enter through the
    // former Shared-TMOV execution path.
    for function = 9 to 12 do
        ResetBundleControlState();
        ClearFault();
        let reserved_start = ExecuteCommandInstruction(
            BundleTestTLSUStart((Zeros{5} + function)[4:0],
                Zeros{5} + 24), 32);
        assert reserved_start == CommandExecution_Rejected;
        assert _LastFault == Fault_IllegalInstruction;
    end;
    ResetBundleControlState();
    ClearFault();
    let linx_partition_store = ExecuteCommandInstruction(
        BundleTestTLSUStart('01110', Zeros{5} + 24), 32);
    assert linx_partition_store == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
end;

// PTO-REQ-SHARED-TILE-001: cooperative TMATMUL consumes fixed-order Shared
// binders, while TGEMV and unrelated operations reject an unconsumed binder.
func TestBundleSharedCubeExecution()
begin
    // A zero Shared mask is a strict CUBE no-op. It neither reads an
    // uninitialized Shared descriptor nor allocates the Local destination.
    ResetProfileState();
    let zero_start = ExecuteCommandInstruction(
        BundleTestCUBEStart('00000', Zeros{5} + 24), 32);
    let zero_shared = ExecuteCommandInstruction(
        BundleTestSharedDestination(Zeros{8} + 255, Zeros{4}, Zeros{3}), 32);
    let zero_destination = ExecuteCommandInstruction(
        BundleTestTileDestinationV5('001', '00', Zeros{4}, TRUE), 32);
    assert zero_start == CommandExecution_Executed;
    assert zero_shared == CommandExecution_Executed;
    assert zero_destination == CommandExecution_Executed;
    let zero_completed = ExecuteBundleTileOperation();
    assert zero_completed;
    assert _LastFault == Fault_None;
    assert _BundleSharedBindings[[0]].consumed;
    assert !_Tiles[[0]].allocated;
    assert !SharedTileRecord(Zeros{8} + 255).descriptor_valid;

    ResetProfileState();
    ConfigureTile(0, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 6);
    var right = _Tiles[[0]];
    right.payload[[0]] = Zeros{PTO_XLEN} + 7;
    InstallSharedTile(Zeros{8} + 31, right, '1111');
    let start = ExecuteCommandInstruction(
        BundleTestCUBEStart('00000', Zeros{5} + 24), 32);
    let bind_right = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 31), 32);
    let local_a_and_d = ExecuteCommandInstruction(
        BundleTestTileBindingV5('001', '00', '1111', Zeros{6}, TRUE), 32);
    assert start == CommandExecution_Executed;
    assert bind_right == CommandExecution_Executed;
    assert local_a_and_d == CommandExecution_Executed;
    let cooperative_completed = ExecuteBundleTileOperation();
    assert cooperative_completed;
    assert _BundleSharedBindings[[0]].consumed;
    assert _Tiles[[1]].allocated;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 42;

    // Two non-MX binders mean Left,Right and remove both from Local B.IOT.
    ResetProfileState();
    ConfigureTile(10, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 3);
    var shared_left = _Tiles[[10]];
    var shared_right = _Tiles[[10]];
    shared_left.payload[[0]] = Zeros{PTO_XLEN} + 4;
    shared_right.payload[[0]] = Zeros{PTO_XLEN} + 5;
    InstallSharedTile(Zeros{8} + 40, shared_left, '1111');
    InstallSharedTile(Zeros{8} + 41, shared_right, '1111');
    let both_start = ExecuteCommandInstruction(
        BundleTestCUBEStart('00000', Zeros{5} + 24), 32);
    let bind_left = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 40), 32);
    let bind_second_right = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 41), 32);
    let only_destination = ExecuteCommandInstruction(
        BundleTestTileDestinationV5('001', '00', '1111', TRUE), 32);
    assert both_start == CommandExecution_Executed;
    assert bind_left == CommandExecution_Executed;
    assert bind_second_right == CommandExecution_Executed;
    assert only_destination == CommandExecution_Executed;
    let shared_pair_completed = ExecuteBundleTileOperation();
    assert shared_pair_completed;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 20;

    // MX with two binders maps Shared Right,ScaleRight after Local
    // Left,ScaleLeft.
    ResetProfileState();
    ConfigureTile(0, 512, 1, 1, 1, 1, TileDataType_E4M3,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 512, 1, 1, 1, 1, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(10, 512, 1, 1, 1, 1, TileDataType_E5M2,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(11, 512, 1, 1, 1, 1, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    InstallSharedTile(Zeros{8} + 42, _Tiles[[10]], '1111');
    InstallSharedTile(Zeros{8} + 43, _Tiles[[11]], '1111');
    let mx_two_start = ExecuteCommandInstruction(
        BundleTestNamedMxStart(4, Zeros{5} + 1), 32);
    let mx_bind_right = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 42), 32);
    let mx_bind_right_scale = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 43), 32);
    let mx_local_pair = ExecuteCommandInstruction(
        BundleTestTwoSourceDestinationV5('001', '10', '1111',
            Zeros{6}, Zeros{6} + 1, TRUE), 32);
    assert mx_two_start == CommandExecution_Executed;
    assert mx_bind_right == CommandExecution_Executed;
    assert mx_bind_right_scale == CommandExecution_Executed;
    assert mx_local_pair == CommandExecution_Executed;
    let mx_two_completed = ExecuteBundleTileOperation();
    assert mx_two_completed;
    let mx_two_destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(mx_two_destination, 0, 0) ==
        Zeros{PTO_XLEN} + 6;

    // MX with four binders uses Left,ScaleLeft,Right,ScaleRight and only a
    // Local destination.
    ResetProfileState();
    ConfigureTile(10, 512, 1, 1, 1, 1, TileDataType_E4M3,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(11, 512, 1, 1, 1, 1, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(12, 512, 1, 1, 1, 1, TileDataType_E5M2,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(13, 512, 1, 1, 1, 1, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(13, 0, 0, Zeros{PTO_XLEN} + 1);
    InstallSharedTile(Zeros{8} + 44, _Tiles[[10]], '1111');
    InstallSharedTile(Zeros{8} + 45, _Tiles[[11]], '1111');
    InstallSharedTile(Zeros{8} + 46, _Tiles[[12]], '1111');
    InstallSharedTile(Zeros{8} + 47, _Tiles[[13]], '1111');
    let mx_four_start = ExecuteCommandInstruction(
        BundleTestNamedMxStart(4, Zeros{5} + 1), 32);
    let mx_bind_left = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 44), 32);
    let mx_bind_left_scale = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 45), 32);
    let mx_bind_second_right = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 46), 32);
    let mx_bind_second_right_scale = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 47), 32);
    let mx_only_destination = ExecuteCommandInstruction(
        BundleTestTileDestinationV5('001', '00', '1111', TRUE), 32);
    assert mx_four_start == CommandExecution_Executed;
    assert mx_bind_left == CommandExecution_Executed;
    assert mx_bind_left_scale == CommandExecution_Executed;
    assert mx_bind_second_right == CommandExecution_Executed;
    assert mx_bind_second_right_scale == CommandExecution_Executed;
    assert mx_only_destination == CommandExecution_Executed;
    let mx_four_completed = ExecuteBundleTileOperation();
    assert mx_four_completed;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 6;

    // TGEMV functions reject every B.IOS binder.
    ResetProfileState();
    let gemv_start = ExecuteCommandInstruction(
        BundleTestCUBEStart('10000', Zeros{5} + 24), 32);
    let gemv_shared = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 50), 32);
    assert gemv_start == CommandExecution_Executed;
    assert gemv_shared == CommandExecution_Executed;
    let gemv_completed = ExecuteBundleTileOperation();
    assert !gemv_completed;
    assert _LastFault == Fault_TileLegality;

    // MX requires exactly Right,ScaleRight or the complete four-binder order.
    ResetProfileState();
    let mx_start = ExecuteCommandInstruction(
        BundleTestNamedMxStart(4, Zeros{5} + 1), 32);
    let mx_one_binder = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 60), 32);
    assert mx_start == CommandExecution_Executed;
    assert mx_one_binder == CommandExecution_Executed;
    let mx_completed = ExecuteBundleTileOperation();
    assert !mx_completed;
    assert _LastFault == Fault_TileLegality;

    // A binder on an unrelated operation is never silently discarded.
    ResetProfileState();
    let tepl_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10}, Zeros{5} + 24), 32);
    let tepl_shared = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 70), 32);
    assert tepl_start == CommandExecution_Executed;
    assert tepl_shared == CommandExecution_Executed;
    let tepl_completed = ExecuteBundleTileOperation();
    assert !tepl_completed;
    assert _LastFault == Fault_TileLegality;
end;

func TestBundleDataAttributes0580()
begin
    ResetProfileState();
    assert TileDataLayoutCodeAccepted(Zeros{5});
    assert TileDataLayoutCodeAccepted(Zeros{5} + 1);
    assert TileDataLayoutCodeAccepted(Zeros{5} + 30);
    assert !TileDataLayoutCodeAccepted(Zeros{5} + 2);
    assert TileDataLayoutCodeSupported(Zeros{5});
    assert !TileDataLayoutCodeSupported(Zeros{5} + 1);

    ClearFault();
    SetBundleDataAttributeState0580(Zeros{5} + 24, Zeros{5}, '11',
        Zeros{3} + 1, Zeros{3} + 2, TRUE, TRUE);
    assert _LastFault == Fault_None;
    assert CurrentBundleDataTypeCode() == Zeros{5} + 24;
    assert CurrentBundlePadValue() == TilePad_Null;
    assert CurrentBundleCanonicalize();
    let conversion_operation = DecodeTileOperation(TileDecode_TEPL, '000000011011')
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let conversion_operands = BundleTileInstructionOperands(conversion_operation);
    assert !conversion_operands.numeric_control.use_operation_default;
    assert conversion_operands.numeric_control.rounding_mode == NumericRound_RTZ;
    assert conversion_operands.numeric_control.saturating;

    // Accepted implementation-defined layouts are rejected by generic
    // indexing until the implementation advertises support.
    ClearFault();
    SetBundleDataAttributeState0580(Zeros{5} + 24, Zeros{5} + 1, '00',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    assert _LastFault == Fault_TileLegality;
    assert CurrentBundleDataTypeCode() == Zeros{5} + 24;
    AdvertiseTileDataLayout(Zeros{5} + 1);
    ClearFault();
    SetBundleDataAttributeState0580(Zeros{5} + 24, Zeros{5} + 1, '00',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    assert _LastFault == Fault_None;
    assert TileDataLayoutCodeSupported(Zeros{5} + 1);

    ClearFault();
    SetBundleDataAttributeState0580(Zeros{5} + 15, Zeros{5}, '00',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    assert _LastFault == Fault_TileLegality;
end;

func TestBundleDataTypeNoneResolution()
begin
    assert BundleDataTypeFieldValid(Ones{5});
    assert !BundleDataTypeConcrete(Ones{5});
    assert !BundleDataTypeFieldValid(Zeros{5} + 15);

    // A non-concrete B.DATR is explicitly present but does not replace a
    // concrete BSTART DataType.
    ResetProfileState();
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
    SetBundleDataAttributeState0580(Ones{5}, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    assert _LastFault == Fault_None;
    assert _BundleDataAttributes.data_type_present;
    let (start_valid, start_type) = ResolveBundleEffectiveDataType();
    assert start_valid;
    assert start_type == TileDataType_U64;

    // A concrete B.DATR has precedence over the concrete BSTART field.
    SetBundleDataAttributeState0580(Zeros{5} + 8, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    let (datr_valid, datr_type) = ResolveBundleEffectiveDataType();
    assert datr_valid;
    assert datr_type == TileDataType_E5M2;

    // TMOV may inherit a Local source descriptor when both encoded fields
    // carry DTYPE_NONE.
    ResetProfileState();
    BundleTestConfigureTile(0, TileDataType_U16);
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7},
        operation_class = BundleOperation_TileMemory,
        selector_valid = TRUE,
        selector = Zeros{10} + 2,
        data_type_valid = TRUE,
        data_type = Ones{5},
        mode_valid = FALSE,
        mode = Zeros{2},
        branch_type_valid = FALSE,
        branch_type = Zeros{3}
    });
    SetBundleDataAttributeState0580(Ones{5}, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    AddBundleTileBinding(TRUE, 2, 1, '1111', TRUE, FALSE, 0, 0, TRUE);
    let (local_valid, local_type) = ResolveBundleEffectiveDataType();
    assert local_valid;
    assert local_type == TileDataType_U16;
    let local_resolved = ResolveBundleTileDestinations();
    assert local_resolved;
    assert _Tiles[[32]].allocated;
    assert _Tiles[[32]].data_type == TileDataType_U16;

    // The same resolver accepts a Shared TMOV source descriptor without
    // assigning DTYPE_NONE a concrete type identity.
    ResetProfileState();
    BundleTestConfigureTile(10, TileDataType_E4M3);
    InstallSharedTile(Zeros{8} + 31, _Tiles[[10]], '1111');
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7},
        operation_class = BundleOperation_TileMemory,
        selector_valid = TRUE,
        selector = Zeros{10} + 2,
        data_type_valid = TRUE,
        data_type = Ones{5},
        mode_valid = FALSE,
        mode = Zeros{2},
        branch_type_valid = FALSE,
        branch_type = Zeros{3}
    });
    SetBundleDataAttributeState0580(Ones{5}, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    BindBundleSharedIO(Zeros{8} + 31, '1111', 0);
    let (shared_valid, shared_type) = ResolveBundleEffectiveDataType();
    assert shared_valid;
    assert shared_type == TileDataType_E4M3;

    // An operation that needs a concrete type faults before destination
    // allocation or source consumption when no resolver input is concrete.
    ResetProfileState();
    BundleTestConfigureTile(0, TileDataType_U64);
    BundleTestConfigureTile(1, TileDataType_U64);
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7},
        operation_class = BundleOperation_TileElement,
        selector_valid = TRUE,
        selector = Zeros{10},
        data_type_valid = TRUE,
        data_type = Ones{5},
        mode_valid = FALSE,
        mode = Zeros{2},
        branch_type_valid = FALSE,
        branch_type = Zeros{3}
    });
    SetBundleDataAttributeState0580(Ones{5}, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    AddBundleTileBinding(TRUE, 2, 1, '1111', TRUE, TRUE, 0, 1, TRUE);
    let unresolved = ExecuteBundleTileOperation();
    assert !unresolved;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[32]].allocated;
    assert _Tiles[[0]].allocated;
    assert _Tiles[[1]].allocated;
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
    AddBundleTileBinding(TRUE, 0, 3, '1111', TRUE, TRUE, 0, 1, TRUE);
    assert _LastFault == Fault_None;
    assert BundleTileDestinationSizeLegal(0);
    assert BundleTileDestinationSizeBytes(0) == 2048;

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

    // A successful attempt retains the destination and consumes its sources.
    let committed_resolved = ResolveBundleTileDestinations();
    assert committed_resolved;
    let committed_destination = _BundleTileBindings[[0]].destination;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    assert _Tiles[[committed_destination]].allocated;
    assert !_Tiles[[0]].allocated;
    assert !_Tiles[[1]].allocated;

    ResetBundleControlState();
    ClearFault();
    AddBundleTileBinding(TRUE, 0, 0, '1111', FALSE, FALSE, 0, 0, TRUE);
    assert _LastFault == Fault_TileLegality;
end;

func TestBundleTileUndersizedAllocation()
begin
    ResetProfileState();
    ConfigureTile(16, 1024, 128, 1, 128, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 127 do
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
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 16, 0, TRUE);
    ClearFault();
    let undersized_resolved = ResolveBundleTileDestinations();
    assert !undersized_resolved;
    assert _LastFault == Fault_TileAllocation;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert _Tiles[[16]].allocated;
    assert ReadTileElement(16, 127, 0) == Zeros{PTO_XLEN} + 127;
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
    let trap_tepl_instruction =
        BundleTestTEPLStart(Zeros{10}, Zeros{5} + 24);
    let trap_tepl_form = DecodeCommandForm(trap_tepl_instruction, 32);
    assert trap_tepl_form != PTO_COMMAND_FORM_COUNT;
    InstallBundleOperationDescriptor(DecodeBundleOperationDescriptor(
        trap_tepl_instruction,
        trap_tepl_form as integer {0..PTO_COMMAND_FORM_COUNT-1}));
    EnterBundleBody();
    SetBundleDimension(2, Zeros{PTO_XLEN} + 0x33);
    SetBundleScalarBinding(31, 5, 2, 3, 4, 3);
    SetBundleTileBinding(15, TRUE, 2, 7, '1111', TRUE, TRUE, 10, 11,
        TRUE);
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
    assert _TrapContexts[[1]].bundle_operation.form_identity ==
        Zeros{7} +
        (trap_tepl_form as integer {0..PTO_COMMAND_FORM_COUNT-1});
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
    SetBundleTileBinding(15, FALSE, 1, 0, '0011', FALSE, FALSE, 1, 1,
        FALSE);
    SetBundleControlAttributeState(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE);
    SetBundleDataAttributeState(Zeros{5}, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE);
    ArchitectureEnterRequest('0001');
    assert CurrentACR() == 2;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x500;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x500;
    assert _BundleArgument == Zeros{PTO_XLEN} + 0x55;
    assert _BundleOperation.valid;
    assert _BundleOperation.form_identity == Zeros{7} +
        (trap_tepl_form as integer {0..PTO_COMMAND_FORM_COUNT-1});
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
    assert _BundleTileBindings[[15]].pe_mask == '1111';
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

    SetBundleTileBinding(0, TRUE, 2, 7, '1111', TRUE, TRUE, 10, 11,
        TRUE);
    assert _BundleTileBindings[[0]].valid;
    assert _BundleTileBindings[[0]].destination_valid;
    assert _BundleTileBindings[[0]].destination == 2;
    assert _BundleTileBindings[[0]].source0 == 10;
    assert _BundleTileBindings[[0]].pe_mask == '1111';
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
