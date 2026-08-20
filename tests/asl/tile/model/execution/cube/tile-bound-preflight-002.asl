// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-PREFLIGHT-BOUND-002","source":"asl/tile/model/execution/cube.asl","requirements":[],"kind":"boundary","summary":"CUBE aliases, composite preflight, and MX rejection are effect safe","pass_condition":"alias, preflight, and applicability rejection assertions hold","related_sources":[]}
func ConfigureCubeUnitTile(index: TileIndex, data_type: TileDataType,
                           layout: TileLayout, location: TileLocation,
                           value: Word)
begin
    if TileLayoutIsCube(layout) then
        let configured = ConfigureCubeTile(
            index, 512, 1, 1, data_type, layout, location);
        assert configured;
    else
        ConfigureTile(index, 512, 1, 1, 1, 1,
            data_type, layout, location);
    end;
    WriteTileElement(index, 0, 0, value);
end;

func SelectCubeTotalityDataType(data_type: bits(5))
begin
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7},
        operation_class = BundleOperation_TileMatrix,
        selector_valid = TRUE,
        selector = Zeros{10},
        data_type_valid = TRUE,
        data_type = data_type,
        mode_valid = FALSE,
        mode = Zeros{2},
        branch_type_valid = FALSE,
        branch_type = Zeros{3}
    });
end;

func ResetCubeOrdinaryOperandsForDataType(data_type: TileDataType,
                                          encoding: bits(5))
begin
    ResetProfileState();
    SelectCubeTotalityDataType(encoding);
    let accumulator_type = TileOrdinaryMatrixAccumulatorType(
        data_type,
        data_type);
    ConfigureCubeUnitTile(0, accumulator_type, TileLayout_CUBE_M16,
        TileLocation_Matrix, Zeros{PTO_XLEN});       // D
    ConfigureCubeUnitTile(1, accumulator_type, TileLayout_CUBE_M16,
        TileLocation_Matrix, Zeros{PTO_XLEN} + 5);  // C
    ConfigureCubeUnitTile(2, data_type, TileLayout_CUBE_M16,
        TileLocation_Matrix, Zeros{PTO_XLEN} + 2);  // A
    ConfigureCubeUnitTile(3, data_type, TileLayout_CUBE_N8,
        TileLocation_Matrix, Zeros{PTO_XLEN} + 3);  // B
    ConfigureCubeUnitTile(4, accumulator_type, TileLayout_RowMajor,
        TileLocation_Any, Zeros{PTO_XLEN} + 7);     // Bias
end;

func ResetCubeOrdinaryOperands()
begin
    ResetCubeOrdinaryOperandsForDataType(TileDataType_U16, '11010');
end;

func ResetCubeMXOperands()
begin
    ResetProfileState();
    SelectCubeTotalityDataType('00111');
    ConfigureCubeUnitTile(0, TileDataType_FP32, TileLayout_CUBE_M16,
        TileLocation_Matrix, Zeros{PTO_XLEN});       // D
    ConfigureCubeUnitTile(1, TileDataType_FP32, TileLayout_CUBE_M16,
        TileLocation_Matrix, Zeros{PTO_XLEN} + 5);  // C
    ConfigureCubeUnitTile(2, TileDataType_E4M3, TileLayout_CUBE_M16,
        TileLocation_Matrix, Zeros{PTO_XLEN} + 2);  // A
    ConfigureCubeUnitTile(3, TileDataType_E8M0, TileLayout_RowMajor,
        TileLocation_Any, Zeros{PTO_XLEN} + 1);     // ScaleA
    ConfigureCubeUnitTile(4, TileDataType_E4M3, TileLayout_CUBE_N8,
        TileLocation_Matrix, Zeros{PTO_XLEN} + 3);  // B
    ConfigureCubeUnitTile(5, TileDataType_E8M0, TileLayout_RowMajor,
        TileLocation_Any, Zeros{PTO_XLEN} + 1);     // ScaleB
    ConfigureCubeUnitTile(6, TileDataType_FP32, TileLayout_RowMajor,
        TileLocation_Any, Zeros{PTO_XLEN} + 7);     // Bias
end;

func ExecuteTileInstructionWithAcceptedApplicabilityRulesForTest(
    rules: NumericApplicabilityRuleSet,
    family: TileDecodeFamily,
    code: bits(12),
    operands: TileInstructionOperands) => (TileExecutionStatus, Word)
begin
    BeginArchitecturalInstructionAttempt();
    return ExecuteTileInstructionWithoutTimeWithAcceptedApplicabilityRules(
        rules, family, code, operands);
end;

pure func CubeMxFunction(index: integer {0..5}) => integer {4..22}
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

pure func CubeFunctionUsesMX(function: integer {0..22}) => boolean
begin
    return function == 4 || function == 5 || function == 6 ||
           function == 20 || function == 21 || function == 22;
end;

pure func CubeFunctionAccumulates(function: integer {0..22}) => boolean
begin
    return function == 2 || function == 6 ||
           function == 18 || function == 22;
end;

pure func CubeFunctionUsesBias(function: integer {0..22}) => boolean
begin
    return function == 1 || function == 5 ||
           function == 17 || function == 21;
end;

func CubeTotalityOperands(function: integer {0..22}) => TileInstructionOperands
begin
    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    if CubeFunctionUsesMX(function) then
        if CubeFunctionAccumulates(function) then
            operands.source0 = 1;
            operands.source1 = 2;
            operands.source2 = 3;
            operands.source3 = 4;
            operands.source4 = 5;
        else
            operands.source0 = 2;
            operands.source1 = 3;
            operands.source2 = 4;
            operands.source3 = 5;
            if CubeFunctionUsesBias(function) then
                operands.source4 = 6;
            end;
        end;
    else
        if CubeFunctionAccumulates(function) then
            operands.source0 = 1;
            operands.source1 = 2;
            operands.source2 = 3;
        elsif CubeFunctionUsesBias(function) then
            operands.source0 = 2;
            operands.source1 = 3;
            operands.source2 = 4;
        else
            operands.source0 = 2;
            operands.source1 = 3;
        end;
    end;
    return operands;
end;

func TestCubeAliasMatrix()
begin
    ResetCubeOrdinaryOperands();
    var source_alias = CubeTotalityOperands(0);
    source_alias.source1 = source_alias.source0;
    let (source_alias_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12}, source_alias);
    assert source_alias_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN};

    ResetCubeOrdinaryOperands();
    var destination_alias = CubeTotalityOperands(2);
    destination_alias.destination0 = destination_alias.source0;
    let (destination_alias_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 2, destination_alias);
    assert destination_alias_status == TileExecution_Executed;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 11;
end;

func TestCubeCompositePreflight()
begin
    ResetCubeOrdinaryOperands();
    ConfigureTile(1, 1024, 2, 1, 2, 1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 5);
    let (shape_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 2, CubeTotalityOperands(2));
    assert shape_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN};

    ResetCubeOrdinaryOperands();
    _Tiles[[0]].data_type = TileDataType_S32;
    let (destination_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12}, CubeTotalityOperands(0));
    assert destination_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN};
end;

func TestA2A3CubeMxDirectRejectionMatrix()
begin
    for function_index = 0 to 5 do
        let function = CubeMxFunction(function_index);
        let decoded = DecodeTileOperation(TileDecode_CUBE,
            Zeros{12} + function);
        assert decoded != PTO_TILE_OPERATION_COUNT;
        let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
        assert TileOperationRejectedByAcceptedApplicabilityRules(
            NumericApplicabilityRules_A2A3MxRejection, operation);
        assert !TileOperationRejectedByAcceptedApplicabilityRules(
            NumericApplicabilityRules_None, operation);

        // The A2/A3 rule rejects the decoded MX operation before DataType or
        // operand inspection. One legal E4M3 operand set per selector proves
        // that the rejection is operation-wide without a redundant 25-type
        // Cartesian product in the strict ASL type checker.
        ResetCubeMXOperands();
        WritePC(Zeros{PTO_XLEN} + 0x100);
        let (status, result) =
            ExecuteTileInstructionWithAcceptedApplicabilityRulesForTest(
                NumericApplicabilityRules_A2A3MxRejection,
                TileDecode_CUBE, Zeros{12} + function,
                CubeTotalityOperands(function));
        assert status == TileExecution_Rejected;
        assert result == Zeros{PTO_XLEN};
        assert _LastFault == Fault_IllegalInstruction;
        assert _FaultAddress == Zeros{PTO_XLEN} + 0x100;
        assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN};
    end;
end;

func main() => integer
begin
    ResetProfileState();
    TestCubeAliasMatrix();
    TestCubeCompositePreflight();
    TestA2A3CubeMxDirectRejectionMatrix();
    return 0;
end;
