// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-SELECTORS-BOUND-001","source":"asl/tile/model/execution/cube.asl","requirements":[],"kind":"boundary","summary":"CUBE selectors and raw carrier types enforce assigned legality","pass_condition":"selector, type, and placement assertions hold","related_sources":[]}
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

pure func CubeFunctionAccepted(function: integer {0..22}) => boolean
begin
    return function == 0 || function == 1 || function == 2 ||
           function == 4 || function == 5 || function == 6 ||
           function == 16 || function == 17 || function == 18 ||
           function == 20 || function == 21 || function == 22;
end;

pure func CubeFunctionUsesMX(function: integer {0..22}) => boolean
begin
    return function == 4 || function == 5 || function == 6 ||
           function == 20 || function == 21 || function == 22;
end;

pure func CubeFunctionUsesBias(function: integer {0..22}) => boolean
begin
    return function == 1 || function == 5 ||
           function == 17 || function == 21;
end;

pure func CubeFunctionAccumulates(function: integer {0..22}) => boolean
begin
    return function == 2 || function == 6 ||
           function == 18 || function == 22;
end;

pure func CubeUnitExpected(function: integer {0..22}) => Word
begin
    if CubeFunctionUsesBias(function) then return Zeros{PTO_XLEN} + 13; end;
    if CubeFunctionAccumulates(function) then return Zeros{PTO_XLEN} + 11; end;
    return Zeros{PTO_XLEN} + 6;
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

func TestCubeDecodedSelectorMatrix()
begin
    for function = 0 to 22 do
        if CubeFunctionAccepted(function) then
            if CubeFunctionUsesMX(function) then ResetCubeMXOperands();
            else ResetCubeOrdinaryOperands(); end;
            let (status, -) = ExecuteTileInstruction(TileDecode_CUBE,
                Zeros{12} + function, CubeTotalityOperands(function));
            assert status == TileExecution_Executed;
            assert _LastFault == Fault_None;
            assert ReadTileElement(0, 0, 0) == CubeUnitExpected(function);
        end;
    end;

    ResetCubeOrdinaryOperands();
    let (removed_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 8, DefaultTileInstructionOperands());
    assert removed_status == TileExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
end;

func TestCubeRawCarrierTypeAndPlacementMatrix()
begin
    for index = 0 to 24 do
        let data_type = CubeTestTileDataType(index);
        let encoding = CubeTestTileDataTypeEncoding(index);
        assert TileDataTypeEncodingValid(encoding as TileDataTypeEncoding);
        assert TileDataTypeFromEncoding(encoding as TileDataTypeEncoding) ==
            data_type;
    end;

    ResetCubeOrdinaryOperands();
    _Tiles[[2]].layout = TileLayout_ImplementationDefined;
    let (layout_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12}, CubeTotalityOperands(0));
    assert layout_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN};
end;

func main() => integer
begin
    ResetProfileState();
    TestCubeDecodedSelectorMatrix();
    TestCubeRawCarrierTypeAndPlacementMatrix();
    return 0;
end;
