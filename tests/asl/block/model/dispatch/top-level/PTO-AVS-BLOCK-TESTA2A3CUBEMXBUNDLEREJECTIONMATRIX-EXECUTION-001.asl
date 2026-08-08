// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTA2A3CUBEMXBUNDLEREJECTIONMATRIX-EXECUTION-001","source":"asl/block/model/dispatch/top-level.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for TestA2A3CubeMxBundleRejectionMatrix","pass_condition":"TestA2A3CubeMxBundleRejectionMatrix completes without assertion failure","related_sources":[]}
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

pure func BundleTestTileBinding(destination: bits(2), source0: bits(6),
                               source1: bits(6), last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    // Generic bundle fixtures use 256-byte source descriptors, so the
    // destination B.IOT must select the matching per-PE capacity.
    instruction[11:9] = '010';
    instruction[8:7] = destination;
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
func main() => integer
begin
    ResetProfileState();
    TestA2A3CubeMxBundleRejectionMatrix();
    return 0;
end;
