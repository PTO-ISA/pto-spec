pure func BundleTestTEPLStart(selector: bits(10), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x02001181;
    instruction[24:15] = selector;
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

pure func BundleTestTileBinding(destination: bits(3), source0: bits(6),
                               source1: bits(6), last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[24:22] = destination;
    instruction[11:7] = source0[4:0];
    instruction[15] = source0[5];
    instruction[21:16] = source1;
    instruction[29] = if last then '1' else '0';
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
    assert _BundleOperation.form_identity == Zeros{7} + 48;
    assert _BundleOperation.operation_class == BundleOperation_TileElement;
    assert _BundleOperation.selector == Zeros{10} + 0x2b;
    assert _BundleOperation.data_type == Zeros{5} + 24;

    for data_type_code = 0 to 31 do
        let data_type = Zeros{5} + data_type_code;
        let expected = data_type_code == 0 || data_type_code == 1 ||
                       data_type_code == 4 || data_type_code == 5 ||
                       data_type_code == 7 || data_type_code == 8 ||
                       data_type_code == 13 || data_type_code == 14 ||
                       (16 <= data_type_code && data_type_code <= 20) ||
                       (24 <= data_type_code && data_type_code <= 28);
        assert BundleDataTypeSupported(data_type) == expected;
    end;
    assert BundleTileDataType(Zeros{5}) == TileDataType_F64;
    assert BundleTileDataType(Zeros{5} + 1) == TileDataType_F32;
    assert BundleTileDataType(Zeros{5} + 4) == TileDataType_F16;
    assert BundleTileDataType(Zeros{5} + 5) == TileDataType_BF16;
    assert BundleTileDataType(Zeros{5} + 7) == TileDataType_FP8;
    assert BundleTileDataType(Zeros{5} + 8) == TileDataType_FPL8;
    assert BundleTileDataType(Zeros{5} + 13) == TileDataType_E8M0;
    assert BundleTileDataType(Zeros{5} + 14) == TileDataType_FPL4;
    assert BundleTileDataType(Zeros{5} + 16) == TileDataType_S64;
    assert BundleTileDataType(Zeros{5} + 17) == TileDataType_S32;
    assert BundleTileDataType(Zeros{5} + 18) == TileDataType_S16;
    assert BundleTileDataType(Zeros{5} + 19) == TileDataType_S8;
    assert BundleTileDataType(Zeros{5} + 20) == TileDataType_S4;
    assert BundleTileDataType(Zeros{5} + 24) == TileDataType_U64;
    assert BundleTileDataType(Zeros{5} + 25) == TileDataType_U32;
    assert BundleTileDataType(Zeros{5} + 26) == TileDataType_U16;
    assert BundleTileDataType(Zeros{5} + 27) == TileDataType_U8;
    assert BundleTileDataType(Zeros{5} + 28) == TileDataType_U4;
    assert !BundleDataTypeSupported(Zeros{5} + 11);
    assert !BundleDataTypeSupported(Zeros{5} + 12);

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
        BundleTestTEPLStart(Zeros{10} + 73, Zeros{5} + 24), 32);
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
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 16;
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
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 5;
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

    // DataType mismatch is rejected before the direct tile operation mutates.
    ResetProfileState();
    BundleTestConfigureTile(0, TileDataType_U64);
    BundleTestConfigureTile(1, TileDataType_U64);
    BundleTestConfigureTile(2, TileDataType_U32);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 99);
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    let mismatch_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10}, Zeros{5} + 24), 32);
    let mismatch_binding = ExecuteCommandInstruction(BundleTestTileBinding(
        '010', Zeros{6}, Zeros{6} + 1, TRUE), 32);
    let mismatch_stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert mismatch_start == CommandExecution_Executed;
    assert mismatch_binding == CommandExecution_Executed;
    assert mismatch_stop == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 99;

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
        BundleTestTEPLStart(Zeros{10} + 73, Zeros{5} + 24), 32);
    assert live_start == CommandExecution_Executed;
    assert live_binding == CommandExecution_Executed;
    assert invalid_next == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 99;
    assert _TrapContexts[[0]].bundle_active;
    assert _TrapContexts[[0]].bundle_operation.selector == Zeros{10};
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
    SetBundleTileBinding(15, TRUE, 6, 8, TRUE, TRUE, 10, 11,
        TRUE, FALSE, TRUE);
    SetBundleControlAttributeState(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE);
    SetBundleDataAttributeState(Zeros{5} + 1, Zeros{5} + 2,
        Zeros{5} + 3, Zeros{3} + 1, Zeros{3} + 2, TRUE);

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
    assert _TrapContexts[[1]].bundle_tile_bindings[[15]].destination == 6;
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
    SetBundleDataAttributeState(Zeros{5}, Zeros{5}, Zeros{5},
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
    assert _BundleTileBindings[[15]].destination == 6;
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

    SetBundleTileBinding(0, TRUE, 6, 8, TRUE, TRUE, 10, 11,
        TRUE, FALSE, TRUE);
    assert _BundleTileBindings[[0]].valid;
    assert _BundleTileBindings[[0]].destination_valid;
    assert _BundleTileBindings[[0]].destination == 6;
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

func TestBundleCommandTotalityBoundaries()
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let unsupported_status = ExecuteDecodedBundleCommand(
        Zeros{64}, 76, 32);
    assert unsupported_status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x100;
    assert _LastMemoryCommandAddress == Zeros{PTO_XLEN};

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    let memory_command_status = ExecuteDecodedBundleCommand(
        Zeros{64}, 104, 32);
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
    let argument_zero_status = ExecuteDecodedBundleCommand(Zeros{64}, 0, 32);
    assert argument_zero_status == CommandExecution_Executed;
    assert _BundleArgumentKind == '000';
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x304;
    let argument_two_status = ExecuteDecodedBundleCommand(Zeros{64}, 2, 32);
    assert argument_two_status == CommandExecution_Executed;
    assert _BundleArgumentKind == '010';
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x308;

    let hint_instruction = Ones{64};
    let hint_status = ExecuteDecodedBundleCommand(hint_instruction, 11, 32);
    assert hint_status == CommandExecution_Executed;
    assert _LastBundleHintPayload == hint_instruction;
    assert _BundleHintEpoch == 1;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x30C;
end;
