// PTO-REQ-CUBE-001, PTO-REQ-TILE-LEGALITY-001: S4-T10 CUBE totality.

func ConfigureCubeUnitTile(index: TileIndex, data_type: TileDataType,
                           layout: TileLayout, location: TileLocation)
begin
    ConfigureTile(index, 256, 1, 1, 1, 1, data_type, layout, location);
end;

func ResetCubeUnitOperandsForDataType(data_type: TileDataType)
begin
    ConfigureCubeUnitTile(0, data_type,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureCubeUnitTile(1, data_type,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureCubeUnitTile(2, data_type,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureCubeUnitTile(3, data_type,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureCubeUnitTile(4, data_type,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureCubeUnitTile(5, data_type,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 5);
end;

func ResetCubeUnitOperands()
begin
    ResetCubeUnitOperandsForDataType(TileDataType_U64);
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

pure func CubeTestTileDataType(index: integer {0..18}) => TileDataType
begin
    case index of
        when 0 => return TileDataType_F64;
        when 1 => return TileDataType_S8;
        when 2 => return TileDataType_U8;
        when 3 => return TileDataType_S16;
        when 4 => return TileDataType_U16;
        when 5 => return TileDataType_S32;
        when 6 => return TileDataType_U32;
        when 7 => return TileDataType_S64;
        when 8 => return TileDataType_U64;
        when 9 => return TileDataType_F16;
        when 10 => return TileDataType_BF16;
        when 11 => return TileDataType_F32;
        when 12 => return TileDataType_FP8;
        when 13 => return TileDataType_FPL8;
        when 14 => return TileDataType_FP4;
        when 15 => return TileDataType_FPL4;
        when 16 => return TileDataType_S4;
        when 17 => return TileDataType_U4;
        when 18 => return TileDataType_E8M0;
        otherwise => unreachable;
    end;
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

pure func CubeUnitExpected(function: integer {0..22}) => Word
begin
    case function of
        when 0, 16 => return Zeros{PTO_XLEN} + 6;
        when 1, 17 => return Zeros{PTO_XLEN} + 11;
        when 2, 18 => return Zeros{PTO_XLEN} + 16;
        when 4, 20 => return Zeros{PTO_XLEN} + 90;
        when 5, 21 => return Zeros{PTO_XLEN} + 95;
        when 6, 22 => return Zeros{PTO_XLEN} + 240;
        when 8 => return Zeros{PTO_XLEN} + 2;
        otherwise => unreachable;
    end;
end;

func TestCubeDecodedSelectorMatrix()
begin
    for function = 0 to 22 do
        if CubeFunctionAccepted(function) then
            ResetCubeUnitOperands();
            var operands = DefaultTileInstructionOperands();
            operands.destination0 = 0;
            operands.source0 = 1;
            operands.source1 = 2;
            operands.source2 = 3;
            operands.source3 = 4;
            operands.destination1 = 5;
            let (status, -) = ExecuteTileInstruction(
                TileDecode_CUBE, Zeros{12} + function, operands);
            assert status == TileExecution_Executed;
            assert _LastFault == Fault_None;
            assert ReadTileElement(0, 0, 0) == CubeUnitExpected(function);
        end;
    end;
end;

func TestCubeRawCarrierTypeAndPlacementMatrix()
begin
    assert TileMatrixRawCarrierTypeSupported(TileDataType_F64);
    assert TileMatrixRawCarrierTypeSupported(TileDataType_S8);
    assert TileMatrixRawCarrierTypeSupported(TileDataType_U8);
    assert TileMatrixRawCarrierTypeSupported(TileDataType_S16);
    assert TileMatrixRawCarrierTypeSupported(TileDataType_U16);
    assert TileMatrixRawCarrierTypeSupported(TileDataType_S32);
    assert TileMatrixRawCarrierTypeSupported(TileDataType_U32);
    assert TileMatrixRawCarrierTypeSupported(TileDataType_S64);
    assert TileMatrixRawCarrierTypeSupported(TileDataType_U64);
    assert TileMatrixRawCarrierTypeSupported(TileDataType_F16);
    assert TileMatrixRawCarrierTypeSupported(TileDataType_BF16);
    assert TileMatrixRawCarrierTypeSupported(TileDataType_F32);
    assert TileMatrixRawCarrierTypeSupported(TileDataType_FP8);
    assert TileMatrixRawCarrierTypeSupported(TileDataType_FPL8);
    assert TileMatrixRawCarrierTypeSupported(TileDataType_FP4);
    assert TileMatrixRawCarrierTypeSupported(TileDataType_FPL4);
    assert TileMatrixRawCarrierTypeSupported(TileDataType_S4);
    assert TileMatrixRawCarrierTypeSupported(TileDataType_U4);
    assert TileMatrixRawCarrierTypeSupported(TileDataType_E8M0);

    ConfigureCubeUnitTile(0, TileDataType_U32,
        TileLayout_ColumnMajor, TileLocation_Vector);
    ConfigureCubeUnitTile(1, TileDataType_F16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureCubeUnitTile(2, TileDataType_S8,
        TileLayout_ColumnMajor, TileLocation_Memory);
    ConfigureCubeUnitTile(3, TileDataType_FP4,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureCubeUnitTile(4, TileDataType_E8M0,
        TileLayout_ColumnMajor, TileLocation_Vector);
    ConfigureCubeUnitTile(5, TileDataType_U4,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 5);
    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    operands.source0 = 1;
    operands.source1 = 2;
    operands.source2 = 3;
    operands.source3 = 4;
    operands.destination1 = 5;
    let (mixed_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 5, operands);
    assert mixed_status == TileExecution_Executed;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 95;

    ConfigureCubeUnitTile(1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    _Tiles[[1]].layout = TileLayout_ImplementationDefined;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 99);
    let (layout_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12}, operands);
    assert layout_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 99;
end;

func TestCubeAliasMatrix()
begin
    ResetCubeUnitOperands();
    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 1;
    operands.source0 = 1;
    operands.source1 = 2;
    let (left_alias_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12}, operands);
    assert left_alias_status == TileExecution_Executed;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 6;

    ResetCubeUnitOperands();
    operands = DefaultTileInstructionOperands();
    operands.destination0 = 3;
    operands.source0 = 1;
    operands.source1 = 2;
    operands.source2 = 3;
    let (bias_alias_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 1, operands);
    assert bias_alias_status == TileExecution_Executed;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 11;

    ResetCubeUnitOperands();
    operands = DefaultTileInstructionOperands();
    operands.destination0 = 3;
    operands.source0 = 1;
    operands.source1 = 2;
    operands.source2 = 3;
    operands.source3 = 4;
    let (scale_alias_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 4, operands);
    assert scale_alias_status == TileExecution_Executed;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 90;

    ResetCubeUnitOperands();
    operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    operands.source0 = 1;
    operands.source1 = 2;
    operands.source2 = 3;
    operands.source3 = 3;
    operands.destination1 = 3;
    let (extras_alias_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 5, operands);
    assert extras_alias_status == TileExecution_Executed;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 155;

    ResetCubeUnitOperands();
    operands = DefaultTileInstructionOperands();
    operands.destination0 = 1;
    operands.source0 = 1;
    operands.source1 = 2;
    let (accumulate_alias_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 2, operands);
    assert accumulate_alias_status == TileExecution_Executed;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 8;

    ResetCubeUnitOperands();
    operands = DefaultTileInstructionOperands();
    operands.destination0 = 2;
    operands.source0 = 1;
    operands.source1 = 2;
    let (right_alias_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12}, operands);
    assert right_alias_status == TileExecution_Executed;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 6;

    ResetCubeUnitOperands();
    operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    operands.source0 = 1;
    operands.source1 = 1;
    let (source_alias_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12}, operands);
    assert source_alias_status == TileExecution_Executed;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 4;

    ResetCubeUnitOperands();
    operands = DefaultTileInstructionOperands();
    operands.destination0 = 1;
    operands.source0 = 1;
    let (convert_alias_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 8, operands);
    assert convert_alias_status == TileExecution_Executed;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 2;

    ResetCubeUnitOperands();
    operands = DefaultTileInstructionOperands();
    operands.destination0 = 4;
    operands.source0 = 1;
    operands.source1 = 2;
    operands.source2 = 3;
    operands.source3 = 4;
    let (column_scale_alias_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 4, operands);
    assert column_scale_alias_status == TileExecution_Executed;
    assert ReadTileElement(4, 0, 0) == Zeros{PTO_XLEN} + 90;

    ResetCubeUnitOperands();
    operands = DefaultTileInstructionOperands();
    operands.destination0 = 1;
    operands.source0 = 1;
    operands.source1 = 2;
    let (gemv_matrix_alias_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 16, operands);
    assert gemv_matrix_alias_status == TileExecution_Executed;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 6;
end;

func TestCubeCompositePreflight()
begin
    ResetCubeUnitOperands();
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 99);
    ConfigureCubeUnitTile(3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    operands.source0 = 1;
    operands.source1 = 2;
    operands.source2 = 3;
    let (bias_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 1, operands);
    assert bias_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 99;

    ResetCubeUnitOperands();
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 99);
    ConfigureCubeUnitTile(4, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    operands.source0 = 1;
    operands.source1 = 2;
    operands.source2 = 3;
    operands.source3 = 4;
    let (scale_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 4, operands);
    assert scale_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 99;

    ResetCubeUnitOperands();
    ConfigureCubeUnitTile(0, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    operands.source0 = 1;
    operands.source1 = 2;
    let (accumulate_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 2, operands);
    assert accumulate_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[0]].contents_defined;

    ResetCubeUnitOperands();
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 99);
    ConfigureTile(2, 256, 2, 1, 2, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 3);
    operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    operands.source0 = 1;
    operands.source1 = 2;
    let (shape_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12}, operands);
    assert shape_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 99;

    ResetCubeUnitOperands();
    TFREE(0);
    operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    operands.source0 = 1;
    operands.source1 = 2;
    let (destination_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12}, operands);
    assert destination_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[0]].allocated;

    ResetCubeUnitOperands();
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 99);
    ConfigureCubeUnitTile(1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    operands.source0 = 1;
    operands.source1 = 2;
    let (left_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12}, operands);
    assert left_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 99;

    ResetCubeUnitOperands();
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 99);
    ConfigureCubeUnitTile(2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    operands.source0 = 1;
    operands.source1 = 2;
    let (right_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12}, operands);
    assert right_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 99;

    ResetCubeUnitOperands();
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 99);
    ConfigureCubeUnitTile(3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    operands.source0 = 1;
    operands.source1 = 2;
    operands.source2 = 3;
    operands.source3 = 4;
    let (row_scale_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 4, operands);
    assert row_scale_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 99;

    ResetCubeUnitOperands();
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 99);
    _Tiles[[1]].layout = TileLayout_ImplementationDefined;
    operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    operands.source0 = 1;
    operands.source1 = 2;
    let (implementation_layout_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12}, operands);
    assert implementation_layout_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 99;
end;

// PTO-REQ-PROFILE-001, PTO-REQ-CUBE-001: the accepted A2/A3 applicability
// rule rejects all six MX selectors for all 19 architectural tile data types.
// Rejection precedes source-definedness, tile legality, handler dispatch, and
// every architectural effect. The portable PTO-v0 positive paths remain in
// TestCubeDecodedSelectorMatrix.
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

        for data_type_index = 0 to 18 do
            ResetProfileState();
            let data_type = CubeTestTileDataType(data_type_index);
            ResetCubeUnitOperandsForDataType(data_type);
            WritePC(Zeros{PTO_XLEN} + 0x100);
            var operands = DefaultTileInstructionOperands();
            operands.destination0 = 0;
            operands.source0 = 1;
            operands.source1 = 2;
            operands.source2 = 3;
            operands.source3 = 4;
            operands.destination1 = 5;
            let (status, result) =
                ExecuteTileInstructionWithAcceptedApplicabilityRulesForTest(
                    NumericApplicabilityRules_A2A3MxRejection,
                    TileDecode_CUBE,
                    Zeros{12} + function, operands);
            assert status == TileExecution_Rejected;
            assert result == Zeros{PTO_XLEN};
            assert _LastFault == Fault_IllegalInstruction;
            assert _FaultAddress == Zeros{PTO_XLEN} + 0x100;
            assert ReadPC() == Zeros{PTO_XLEN} + 0x100;
            assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 1;
            assert _MemoryEventCount == 0;
            assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 10;
            assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 2;
            assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 3;
            assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 5;
            assert ReadTileElement(4, 0, 0) == Zeros{PTO_XLEN} + 3;
            assert ReadTileElement(5, 0, 0) == Zeros{PTO_XLEN} + 5;
        end;

        // With no tile allocated and all operands at their defaults, the same
        // profile rejection must win over ordinary source/operand legality.
        ResetProfileState();
        WritePC(Zeros{PTO_XLEN} + 0x200);
        let malformed_operands = DefaultTileInstructionOperands();
        let (malformed_status, malformed_result) =
            ExecuteTileInstructionWithAcceptedApplicabilityRulesForTest(
                NumericApplicabilityRules_A2A3MxRejection,
                TileDecode_CUBE,
                Zeros{12} + function, malformed_operands);
        assert malformed_status == TileExecution_Rejected;
        assert malformed_result == Zeros{PTO_XLEN};
        assert _LastFault == Fault_IllegalInstruction;
        assert _FaultAddress == Zeros{PTO_XLEN} + 0x200;
        assert ReadPC() == Zeros{PTO_XLEN} + 0x200;
        assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 1;
        assert _MemoryEventCount == 0;
        assert !_Tiles[[0]].allocated;
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
