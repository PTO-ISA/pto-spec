// PTO-REQ-CUBE-001, PTO-REQ-TILE-LEGALITY-001: S4-T10 CUBE totality.

func ConfigureCubeUnitTile(index: TileIndex, data_type: TileDataType,
                           layout: TileLayout, location: TileLocation)
begin
    ConfigureTile(index, 256, 1, 1, 1, 1, data_type, layout, location);
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

readonly func ReadCubeAccumulatorElement() => Word
begin
    assert _Accumulator.live && _Accumulator.info.contents_defined;
    return _Accumulator.info.payload[[0]];
end;

func ResetCubeOrdinaryOperandsForDataType(data_type: TileDataType,
                                          encoding: bits(5))
begin
    ResetProfileState();
    SelectCubeTotalityDataType(encoding);
    for index = 0 to 5 do
        ConfigureCubeUnitTile(index as TileIndex, data_type,
            TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 5);
end;

func ResetCubeOrdinaryOperands()
begin
    ResetCubeOrdinaryOperandsForDataType(TileDataType_U64, '11000');
end;

func ResetCubeMXOperands()
begin
    ResetProfileState();
    SelectCubeTotalityDataType('00001');
    ConfigureCubeUnitTile(0, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureCubeUnitTile(1, TileDataType_E4M3,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureCubeUnitTile(2, TileDataType_E5M2,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureCubeUnitTile(3, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureCubeUnitTile(4, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureCubeUnitTile(5, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 5);
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

pure func CubeTestTileDataType(index: integer {0..24}) => TileDataType
begin
    case index of
        when 0 => return TileDataType_FP64;
        when 1 => return TileDataType_FP32;
        when 2 => return TileDataType_TF32;
        when 3 => return TileDataType_HF32;
        when 4 => return TileDataType_FP16;
        when 5 => return TileDataType_BF16;
        when 6 => return TileDataType_HiF8;
        when 7 => return TileDataType_E4M3;
        when 8 => return TileDataType_E5M2;
        when 9 => return TileDataType_E3M2;
        when 10 => return TileDataType_E2M3;
        when 11 => return TileDataType_E2M1X2;
        when 12 => return TileDataType_E1M2X2;
        when 13 => return TileDataType_E8M0;
        when 14 => return TileDataType_HiF4X2;
        when 15 => return TileDataType_S64;
        when 16 => return TileDataType_S32;
        when 17 => return TileDataType_S16;
        when 18 => return TileDataType_S8;
        when 19 => return TileDataType_S4X2;
        when 20 => return TileDataType_U64;
        when 21 => return TileDataType_U32;
        when 22 => return TileDataType_U16;
        when 23 => return TileDataType_U8;
        when 24 => return TileDataType_U4X2;
        otherwise => unreachable;
    end;
end;

pure func CubeTestTileDataTypeEncoding(index: integer {0..24}) => bits(5)
begin
    if index <= 14 then return Zeros{5} + index; end;
    if index <= 19 then return Zeros{5} + index + 1; end;
    return Zeros{5} + index + 4;
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

pure func CubeFunctionAccepted(function: integer {0..22}) => boolean
begin
    return function == 0 || function == 1 || function == 2 ||
           function == 4 || function == 5 || function == 6 ||
           function == 8 || function == 16 || function == 17 ||
           function == 18 || function == 20 || function == 21 ||
           function == 22;
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

pure func CubeUnitExpected(function: integer {0..22}) => Word
begin
    case function of
        when 0, 16 => return Zeros{PTO_XLEN} + 6;
        when 1, 17 => return Zeros{PTO_XLEN} + 11;
        when 2, 18 => return Zeros{PTO_XLEN} + 12;
        when 4, 20 => return Zeros{PTO_XLEN} + 90;
        when 5, 21 => return Zeros{PTO_XLEN} + 95;
        when 6, 22 => return Zeros{PTO_XLEN} + 180;
        when 8 => return Zeros{PTO_XLEN} + 6;
        otherwise => unreachable;
    end;
end;

func CubeTotalityOperands() => TileInstructionOperands
begin
    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    operands.source0 = 1;
    operands.source1 = 2;
    operands.source2 = 3;
    operands.source3 = 4;
    operands.source4 = 5;
    return operands;
end;

func TestCubeDecodedSelectorMatrix()
begin
    for function = 0 to 22 do
        if CubeFunctionAccepted(function) then
            if CubeFunctionUsesMX(function) then
                ResetCubeMXOperands();
            else
                ResetCubeOrdinaryOperands();
            end;
            let operands = CubeTotalityOperands();
            if CubeFunctionAccumulates(function) then
                let seed_function = if CubeFunctionUsesMX(function) then
                    4 else 0;
                let (seed_status, -) = ExecuteTileInstruction(
                    TileDecode_CUBE, Zeros{12} + seed_function, operands);
                assert seed_status == TileExecution_Executed;
            elsif function == 8 then
                let (seed_status, -) = ExecuteTileInstruction(
                    TileDecode_CUBE, Zeros{12}, operands);
                assert seed_status == TileExecution_Executed;
            end;
            let (status, -) = ExecuteTileInstruction(
                TileDecode_CUBE, Zeros{12} + function, operands);
            assert status == TileExecution_Executed;
            assert _LastFault == Fault_None;
            if function == 8 then
                assert !_Accumulator.live;
                assert ReadTileElement(0, 0, 0) ==
                    CubeUnitExpected(function);
            else
                assert ReadCubeAccumulatorElement() ==
                    CubeUnitExpected(function);
            end;
        end;
    end;
end;

func TestCubeRawCarrierTypeAndPlacementMatrix()
begin
    for index = 0 to 24 do
        let data_type = CubeTestTileDataType(index);
        let encoding = CubeTestTileDataTypeEncoding(index);
        assert TileDataTypeEncodingValid(ZeroExtend{PTO_XLEN}(encoding));
        assert TileDataTypeFromEncoding(ZeroExtend{PTO_XLEN}(encoding)) ==
            data_type;
    end;

    ResetCubeOrdinaryOperands();
    _Tiles[[1]].layout = TileLayout_ImplementationDefined;
    let (layout_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12}, CubeTotalityOperands());
    assert layout_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_Accumulator.live;
end;

func TestCubeAliasMatrix()
begin
    ResetCubeOrdinaryOperands();
    var operands = CubeTotalityOperands();
    operands.source1 = operands.source0;
    let (source_alias_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12}, operands);
    assert source_alias_status == TileExecution_Executed;
    assert ReadCubeAccumulatorElement() == Zeros{PTO_XLEN} + 4;

    // ACCCVT may publish back to an ordinary source tile after the source
    // snapshot has already initialized ACC.
    operands.destination0 = operands.source0;
    let (convert_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 8, operands);
    assert convert_status == TileExecution_Executed;
    assert !_Accumulator.live;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 4;
end;

func TestCubeCompositePreflight()
begin
    ResetCubeOrdinaryOperands();
    let operands = CubeTotalityOperands();
    let (seed_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12}, operands);
    assert seed_status == TileExecution_Executed;
    let preserved_accumulator = ReadCubeAccumulatorElement();

    ConfigureCubeUnitTile(3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    let (bias_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 1, operands);
    assert bias_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadCubeAccumulatorElement() == preserved_accumulator;

    ResetCubeOrdinaryOperands();
    let (accumulate_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 2, CubeTotalityOperands());
    assert accumulate_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_Accumulator.live;

    ResetCubeOrdinaryOperands();
    ConfigureTile(2, 256, 2, 1, 2, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 3);
    let (shape_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12}, CubeTotalityOperands());
    assert shape_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_Accumulator.live;

    ResetCubeMXOperands();
    let mx_operands = CubeTotalityOperands();
    let (mx_seed_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 4, mx_operands);
    assert mx_seed_status == TileExecution_Executed;
    let preserved_mx_accumulator = ReadCubeAccumulatorElement();
    ConfigureTile(3, 256, 1, 2, 1, 2, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Any);
    ExecuteTileFillScalar(3, Zeros{PTO_XLEN} + 5);
    ClearFault();
    let (mx_scale_shape_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 4, mx_operands);
    assert mx_scale_shape_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert _Accumulator.live;
    assert ReadCubeAccumulatorElement() == preserved_mx_accumulator;

    ResetCubeOrdinaryOperands();
    let accumulator_operands = CubeTotalityOperands();
    let (logical_seed_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12}, accumulator_operands);
    assert logical_seed_status == TileExecution_Executed;
    let preserved_logical_accumulator = ReadCubeAccumulatorElement();
    assert _Accumulator.logical_data_type == TileDataType_U64;
    assert _Accumulator.info.data_type == TileDataType_U64;
    SelectCubeTotalityDataType('11001');
    ConfigureCubeUnitTile(1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureCubeUnitTile(2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    ClearFault();
    let (accumulator_logical_type_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 2, accumulator_operands);
    assert accumulator_logical_type_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert _Accumulator.live;
    assert ReadCubeAccumulatorElement() == preserved_logical_accumulator;

    ResetCubeOrdinaryOperands();
    let physical_operands = CubeTotalityOperands();
    let (physical_seed_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12}, physical_operands);
    assert physical_seed_status == TileExecution_Executed;
    let preserved_physical_accumulator = ReadCubeAccumulatorElement();
    // Physical-only mismatch is not constructible by decoded instructions:
    // every legal producer commits a coherent logical/physical type pair.
    // Corrupt the internal invariant solely to prove decoded preflight rejects
    // before changing the accumulator.
    _Accumulator.info.data_type = TileDataType_U32;
    ClearFault();
    let (accumulator_physical_type_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 2, physical_operands);
    assert accumulator_physical_type_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert _Accumulator.live;
    assert _Accumulator.info.data_type == TileDataType_U32;
    assert ReadCubeAccumulatorElement() == preserved_physical_accumulator;
end;

// PTO-REQ-PROFILE-001: A2/A3 rejects all six MX selectors for every exact
// 0.57.1 TileDataType identity before operand legality or architectural effects.
func TestA2A3CubeMxDirectRejectionMatrix()
begin
    for function_index = 0 to 5 do
        let function = CubeMxFunction(function_index);
        let decoded = DecodeTileOperation(
            TileDecode_CUBE, Zeros{12} + function);
        assert decoded != PTO_TILE_OPERATION_COUNT;
        let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
        assert TileOperationRejectedByAcceptedApplicabilityRules(
            NumericApplicabilityRules_A2A3MxRejection, operation);
        assert !TileOperationRejectedByAcceptedApplicabilityRules(
            NumericApplicabilityRules_None, operation);

        for data_type_index = 0 to 24 do
            let data_type = CubeTestTileDataType(data_type_index);
            let encoding = CubeTestTileDataTypeEncoding(data_type_index);
            ResetCubeOrdinaryOperandsForDataType(data_type, encoding);
            WritePC(Zeros{PTO_XLEN} + 0x100);
            let (status, result) =
                ExecuteTileInstructionWithAcceptedApplicabilityRulesForTest(
                    NumericApplicabilityRules_A2A3MxRejection,
                    TileDecode_CUBE, Zeros{12} + function,
                    CubeTotalityOperands());
            assert status == TileExecution_Rejected;
            assert result == Zeros{PTO_XLEN};
            assert _LastFault == Fault_IllegalInstruction;
            assert _FaultAddress == Zeros{PTO_XLEN} + 0x100;
            assert ReadPC() == Zeros{PTO_XLEN} + 0x100;
            assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 1;
            assert _MemoryEventCount == 0;
            assert !_Accumulator.live;
            assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 2;
        end;

        ResetProfileState();
        WritePC(Zeros{PTO_XLEN} + 0x200);
        let (malformed_status, malformed_result) =
            ExecuteTileInstructionWithAcceptedApplicabilityRulesForTest(
                NumericApplicabilityRules_A2A3MxRejection,
                TileDecode_CUBE, Zeros{12} + function,
                DefaultTileInstructionOperands());
        assert malformed_status == TileExecution_Rejected;
        assert malformed_result == Zeros{PTO_XLEN};
        assert _LastFault == Fault_IllegalInstruction;
        assert _FaultAddress == Zeros{PTO_XLEN} + 0x200;
        assert !_Accumulator.live;
    end;
end;

func TestCubeTotality()
begin
    TestCubeDecodedSelectorMatrix();
    TestCubeRawCarrierTypeAndPlacementMatrix();
    TestCubeAliasMatrix();
    TestCubeCompositePreflight();
    TestA2A3CubeMxDirectRejectionMatrix();
end;
