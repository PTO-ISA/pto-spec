// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTCUBEMATRIX-STAGE-C-EXECUTION-001","source":"asl/block/model/dispatch/tile-execution.asl","requirements":["PTO-INST-BLOCK-BSTART-TMATMUL","PTO-INST-BLOCK-B-DATR","PTO-INST-BLOCK-B-FPATR","PTO-INST-BLOCK-B-IOT"],"kind":"execution","summary":"decoded normal CUBE PE matrix bundles cover M16/M32 valid tails and transactional faults","pass_condition":"decoded CUBE matrix outputs and rejection observables match the complete matrix-family contract","related_sources":[]}

pure func StageCCUBEStart(data_type: bits(5), accumulator: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    if accumulator then instruction = Zeros{64} + 0x00231181; end;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func StageCDATR(layout: bits(5), data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[11:7] = layout;
    instruction[24:20] = data_type;
    return instruction;
end;

pure func StageCFPATR(pre_quant: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00002023;
    instruction[31:26] = pre_quant;
    return instruction;
end;

pure func StageCDim(role: bits(2), value: integer {0..131071}) => bits(64)
begin
    var instruction: bits(64) = Zeros{64};
    case UInt(role) of
        when 0 => instruction = Zeros{64} + 0x00000043;
        when 1 => instruction = Zeros{64} + 0x00001043;
        when 2 => instruction = Zeros{64} + 0x00002043;
        otherwise => unreachable;
    end;
    let immediate = Zeros{64} + value;
    instruction[31:20] = immediate[11:0];
    instruction[11:7] = immediate[16:12];
    return instruction;
end;

pure func StageCTwoSourceDestination(tile_size: bits(3), destination: bits(2),
                                     pe_mask: bits(4), source0: bits(6),
                                     source1: bits(6), last: boolean) => bits(64)
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

pure func StageCOneSource(source0: bits(6), pe_mask: bits(4),
                          last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = Zeros{3};
    instruction[18:15] = pe_mask;
    instruction[25:20] = source0;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

pure func StageCSharedBinding(shared_id: bits(8), tile_size: bits(3),
                              pe_mask: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = pe_mask;
    instruction[11:9] = tile_size;
    return instruction;
end;

pure func StageCDestination(tile_size: bits(3), destination: bits(2),
                            pe_mask: bits(4), last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[11:9] = tile_size;
    instruction[8:7] = destination;
    instruction[18:15] = pe_mask;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

func StageCDecodedPE(layout: TileLayout, layout_code: bits(5),
                     output_capacity_code: bits(3))
begin
    ResetProfileState();
    let data_type = TileDataType_FP32;
    let m_layout_capacity = if layout == TileLayout_CUBE_M16 then 256 else 512;
    ConfigureCubeTile(10, m_layout_capacity, 2, 3, data_type, layout,
        TileLocation_Matrix);
    ConfigureCubeTile(11, 256, 3, 9, data_type, TileLayout_CUBE_N8,
        TileLocation_Matrix);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 2 looplimit 3 do
            WriteTileElement(10, row, column, Zeros{PTO_XLEN} + 1);
        end;
    end;
    for row = 0 to 2 looplimit 3 do
        for column = 0 to 8 looplimit 9 do
            WriteTileElement(11, row, column, Zeros{PTO_XLEN} + 1);
        end;
    end;
    let stage_c_command_status_1 = ExecuteCommandInstruction(StageCCUBEStart('00001', FALSE), 32);
    assert stage_c_command_status_1 == CommandExecution_Executed;
    let stage_c_command_status_2 = ExecuteCommandInstruction(StageCDATR(layout_code, '00001'), 32);
    assert stage_c_command_status_2 == CommandExecution_Executed;
    let stage_c_command_status_3 = ExecuteCommandInstruction(StageCFPATR(Zeros{6}), 32);
    assert stage_c_command_status_3 == CommandExecution_Executed;
    let stage_c_command_status_4 = ExecuteCommandInstruction(StageCDim('00', 9), 32);
    assert stage_c_command_status_4 == CommandExecution_Executed;
    let stage_c_command_status_5 = ExecuteCommandInstruction(StageCDim('01', 2), 32);
    assert stage_c_command_status_5 == CommandExecution_Executed;
    let stage_c_command_status_6 = ExecuteCommandInstruction(StageCDim('10', 9), 32);
    assert stage_c_command_status_6 == CommandExecution_Executed;
    let stage_c_command_status_7 = ExecuteCommandInstruction(StageCTwoSourceDestination(
        output_capacity_code, '00', '1111', Zeros{6} + 10,
        Zeros{6} + 11, TRUE), 32);
    assert stage_c_command_status_7 == CommandExecution_Executed;
    assert BundleMatrixDestinationLayout() == layout;
    assert BundleDestinationValidRows(FALSE, 0) == 2;
    assert BundleDestinationValidColumns(FALSE, 0) == 9;
    assert TileCubeDescriptorShapeLegal(
        BundleTileDestinationSizeBytes(0), 2, 9, TileDataType_FP32,
        layout);
    let stage_c_operation_status_1 = ExecuteBundleTileOperation();
    assert stage_c_operation_status_1;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].layout == layout;
    assert _Tiles[[destination]].valid_rows == 2;
    assert _Tiles[[destination]].valid_columns == 9;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(destination, 1, 8) == Zeros{PTO_XLEN} + 3;
    if layout == TileLayout_CUBE_M16 then
        // M16 FP32 stores a physical tenth column for the 9-column tail;
        // the padded element remains undefined.
        assert !TileElementDefined(destination, 0, 9);
    else
        // M32 FP32 has one element per CELL column, so the 9-column logical
        // tail occupies exactly nine physical columns and has no column 9
        // to probe.
        assert _Tiles[[destination]].columns == 9;
    end;
end;

func StageCDecodedGroup(group_m: integer {0..131})
begin
    ResetProfileState();
    ConfigureTile(10, 256, 128, 1, 128, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(11, 256, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 127 looplimit 128 do
        WriteTileElement(10, row, 0, Zeros{PTO_XLEN} + 1);
    end;
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    InstallSharedTile(Zeros{8} + 70, _Tiles[[10]], '1111');
    InstallSharedTile(Zeros{8} + 71, _Tiles[[11]], '1111');
    let stage_c_command_status_8 = ExecuteCommandInstruction(StageCCUBEStart('00100', FALSE), 32);
    assert stage_c_command_status_8 == CommandExecution_Executed;
    let stage_c_command_status_9 = ExecuteCommandInstruction(StageCDATR('00000', '00100'), 32);
    assert stage_c_command_status_9 == CommandExecution_Executed;
    let stage_c_command_status_10 = ExecuteCommandInstruction(StageCFPATR(Zeros{6}), 32);
    assert stage_c_command_status_10 == CommandExecution_Executed;
    let stage_c_command_status_11 = ExecuteCommandInstruction(StageCDim('00', 1), 32);
    assert stage_c_command_status_11 == CommandExecution_Executed;
    let stage_c_command_status_12 = ExecuteCommandInstruction(StageCDim('01', group_m), 32);
    assert stage_c_command_status_12 == CommandExecution_Executed;
    let stage_c_command_status_13 = ExecuteCommandInstruction(StageCDim('10', 1), 32);
    assert stage_c_command_status_13 == CommandExecution_Executed;
    let stage_c_command_status_14 = ExecuteCommandInstruction(StageCSharedBinding(
        Zeros{8} + 70, '000', '1111'), 32);
    assert stage_c_command_status_14 == CommandExecution_Executed;
    let stage_c_command_status_15 = ExecuteCommandInstruction(StageCSharedBinding(
        Zeros{8} + 71, '000', '1111'), 32);
    assert stage_c_command_status_15 == CommandExecution_Executed;
    let stage_c_command_status_16 = ExecuteCommandInstruction(StageCDestination(
        '001', '00', '1111', TRUE), 32);
    assert stage_c_command_status_16 == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    if group_m >= 1 && group_m <= 128 then
        assert completed;
        let destination = _BundleTileBindings[[0]].destination;
        let expected_layout = TileCubeGroupLayoutForM(group_m);
        let expected_rows = TileCubeGroupPEValidM(group_m, 0);
        assert _Tiles[[destination]].layout == expected_layout;
        assert _Tiles[[destination]].valid_rows == expected_rows;
        assert TilePEValidRows(destination, 0) ==
            TileCubeGroupPEValidM(group_m, 0);
        assert TilePEValidRows(destination, 1) ==
            TileCubeGroupPEValidM(group_m, 1);
        assert TilePEValidRows(destination, 2) ==
            TileCubeGroupPEValidM(group_m, 2);
        assert TilePEValidRows(destination, 3) ==
            TileCubeGroupPEValidM(group_m, 3);
        assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 1;
        if expected_rows < _Tiles[[destination]].rows then
            assert !TileElementDefined(destination, expected_rows, 0);
        end;
    else
        assert !completed;
        assert _LastFault == Fault_TileLegality ||
            _LastFault == Fault_TileAllocation;
        assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
        assert !_BundleSharedBindings[[0]].consumed;
        assert !_BundleSharedBindings[[1]].consumed;
    end;
end;

func StageCDecodedGroupZeroMask()
begin
    ResetProfileState();
    let stage_c_command_status_17 = ExecuteCommandInstruction(StageCCUBEStart('11011', FALSE), 32);
    assert stage_c_command_status_17 == CommandExecution_Executed;
    let stage_c_command_status_18 = ExecuteCommandInstruction(StageCDATR('00000', '11011'), 32);
    assert stage_c_command_status_18 == CommandExecution_Executed;
    let stage_c_command_status_19 = ExecuteCommandInstruction(StageCFPATR(Zeros{6}), 32);
    assert stage_c_command_status_19 == CommandExecution_Executed;
    let stage_c_command_status_20 = ExecuteCommandInstruction(StageCDim('01', 0), 32);
    assert stage_c_command_status_20 == CommandExecution_Executed;
    let stage_c_command_status_21 = ExecuteCommandInstruction(StageCSharedBinding(
        Zeros{8} + 72, '000', Zeros{4}), 32);
    assert stage_c_command_status_21 == CommandExecution_Executed;
    let stage_c_command_status_22 = ExecuteCommandInstruction(StageCSharedBinding(
        Zeros{8} + 73, '000', Zeros{4}), 32);
    assert stage_c_command_status_22 == CommandExecution_Executed;
    let stage_c_command_status_23 = ExecuteCommandInstruction(StageCDestination(
        '001', '00', Zeros{4}, TRUE), 32);
    assert stage_c_command_status_23 == CommandExecution_Executed;
    let stage_c_operation_status_2 = ExecuteBundleTileOperation();
    assert stage_c_operation_status_2;
    assert _LastFault == Fault_None;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !_BundleSharedBindings[[1]].consumed;
end;

func StageCDecodedACCQuantized()
begin
    ResetProfileState();
    ConfigureCubeTile(0, 256, 2, 2, TileDataType_FP32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    ConfigureCubeTile(10, 256, 2, 2, TileDataType_FP32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    ConfigureCubeTile(11, 256, 2, 2, TileDataType_FP32,
        TileLayout_CUBE_N8, TileLocation_Matrix);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 1 looplimit 2 do
            WriteTileElement(0, row, column, Zeros{PTO_XLEN} + 5);
            WriteTileElement(10, row, column, Zeros{PTO_XLEN} + 1);
            WriteTileElement(11, row, column, Zeros{PTO_XLEN} + 1);
        end;
    end;
    let stage_c_command_status_24 = ExecuteCommandInstruction(StageCCUBEStart('00001', TRUE), 32);
    assert stage_c_command_status_24 == CommandExecution_Executed;
    let stage_c_command_status_25 = ExecuteCommandInstruction(StageCDATR('00000', '00001'), 32);
    assert stage_c_command_status_25 == CommandExecution_Executed;
    // PreQuantMode=2 selects S8 final D while C remains FP32.
    let stage_c_command_status_26 = ExecuteCommandInstruction(StageCFPATR('000010'), 32);
    assert stage_c_command_status_26 == CommandExecution_Executed;
    let stage_c_command_status_27 = ExecuteCommandInstruction(StageCDim('00', 2), 32);
    assert stage_c_command_status_27 == CommandExecution_Executed;
    let stage_c_command_status_28 = ExecuteCommandInstruction(StageCDim('01', 2), 32);
    assert stage_c_command_status_28 == CommandExecution_Executed;
    let stage_c_command_status_29 = ExecuteCommandInstruction(StageCDim('10', 2), 32);
    assert stage_c_command_status_29 == CommandExecution_Executed;
    let stage_c_command_status_30 = ExecuteCommandInstruction(StageCTwoSourceDestination(
        '001', '00', '1111', Zeros{6}, Zeros{6} + 10, FALSE), 32);
    assert stage_c_command_status_30 == CommandExecution_Executed;
    let stage_c_command_status_31 = ExecuteCommandInstruction(StageCOneSource(
        Zeros{6} + 11, '1111', TRUE), 32);
    assert stage_c_command_status_31 == CommandExecution_Executed;
    let stage_c_operation_status_3 = ExecuteBundleTileOperation();
    assert stage_c_operation_status_3;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[0]].data_type == TileDataType_FP32;
    assert _Tiles[[destination]].data_type == TileDataType_S8;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 7;
end;

func StageCDecodedACCPreserving()
begin
    ResetProfileState();
    ConfigureCubeTile(0, 256, 2, 2, TileDataType_FP32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    ConfigureCubeTile(10, 256, 2, 2, TileDataType_FP32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    ConfigureCubeTile(11, 256, 2, 2, TileDataType_FP32,
        TileLayout_CUBE_N8, TileLocation_Matrix);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 1 looplimit 2 do
            WriteTileElement(0, row, column, Zeros{PTO_XLEN} + 5);
            WriteTileElement(10, row, column, Zeros{PTO_XLEN} + 1);
            WriteTileElement(11, row, column, Zeros{PTO_XLEN} + 1);
        end;
    end;
    let stage_c_command_status_32 = ExecuteCommandInstruction(StageCCUBEStart('00001', TRUE), 32);
    assert stage_c_command_status_32 == CommandExecution_Executed;
    let stage_c_command_status_33 = ExecuteCommandInstruction(StageCDATR('00000', '00001'), 32);
    assert stage_c_command_status_33 == CommandExecution_Executed;
    let stage_c_command_status_34 = ExecuteCommandInstruction(StageCFPATR(Zeros{6}), 32);
    assert stage_c_command_status_34 == CommandExecution_Executed;
    let stage_c_command_status_35 = ExecuteCommandInstruction(StageCDim('00', 2), 32);
    assert stage_c_command_status_35 == CommandExecution_Executed;
    let stage_c_command_status_36 = ExecuteCommandInstruction(StageCDim('01', 2), 32);
    assert stage_c_command_status_36 == CommandExecution_Executed;
    let stage_c_command_status_37 = ExecuteCommandInstruction(StageCDim('10', 2), 32);
    assert stage_c_command_status_37 == CommandExecution_Executed;
    let stage_c_command_status_38 = ExecuteCommandInstruction(StageCTwoSourceDestination(
        '001', '00', '1111', Zeros{6}, Zeros{6} + 10, FALSE), 32);
    assert stage_c_command_status_38 == CommandExecution_Executed;
    let stage_c_command_status_39 = ExecuteCommandInstruction(StageCOneSource(
        Zeros{6} + 11, '1111', TRUE), 32);
    assert stage_c_command_status_39 == CommandExecution_Executed;
    let stage_c_operation_status_4 = ExecuteBundleTileOperation();
    assert stage_c_operation_status_4;
    let destination = _BundleTileBindings[[0]].destination;
    assert destination != 0;
    assert _Tiles[[0]].data_type == TileDataType_FP32;
    assert _Tiles[[destination]].data_type == TileDataType_FP32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 5;
end;

func StageCDecodedACCQuantizedFault()
begin
    ResetProfileState();
    ConfigureCubeTile(0, 1024, 2, 9, TileDataType_FP32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    ConfigureCubeTile(10, 256, 2, 2, TileDataType_FP32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    ConfigureCubeTile(11, 256, 2, 9, TileDataType_FP32,
        TileLayout_CUBE_N8, TileLocation_Matrix);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    let stage_c_command_status_40 = ExecuteCommandInstruction(StageCCUBEStart('00001', TRUE), 32);
    assert stage_c_command_status_40 == CommandExecution_Executed;
    let stage_c_command_status_41 = ExecuteCommandInstruction(StageCDATR('00000', '00001'), 32);
    assert stage_c_command_status_41 == CommandExecution_Executed;
    let stage_c_command_status_42 = ExecuteCommandInstruction(StageCFPATR('000010'), 32);
    assert stage_c_command_status_42 == CommandExecution_Executed;
    let stage_c_command_status_43 = ExecuteCommandInstruction(StageCDim('00', 9), 32);
    assert stage_c_command_status_43 == CommandExecution_Executed;
    let stage_c_command_status_44 = ExecuteCommandInstruction(StageCDim('01', 2), 32);
    assert stage_c_command_status_44 == CommandExecution_Executed;
    let stage_c_command_status_45 = ExecuteCommandInstruction(StageCDim('10', 9), 32);
    assert stage_c_command_status_45 == CommandExecution_Executed;
    // S8 M16 N=9 needs two cells (256 bytes), while TSize=1 is 128 bytes.
    let stage_c_command_status_46 = ExecuteCommandInstruction(StageCTwoSourceDestination(
        '001', '00', '1111', Zeros{6}, Zeros{6} + 10, FALSE), 32);
    assert stage_c_command_status_46 == CommandExecution_Executed;
    let stage_c_command_status_47 = ExecuteCommandInstruction(StageCOneSource(
        Zeros{6} + 11, '1111', TRUE), 32);
    assert stage_c_command_status_47 == CommandExecution_Executed;
    let stage_c_operation_status_5 = ExecuteBundleTileOperation();
    assert !stage_c_operation_status_5;
    assert _LastFault == Fault_TileAllocation;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert TileSourceContentsDefined(0);
    assert TileSourceContentsDefined(10);
    assert TileSourceContentsDefined(11);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 5;
end;

func StageCDecodedACCAliasRules()
begin
    ResetProfileState();
    ConfigureCubeTile(0, 256, 2, 2, TileDataType_FP32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    ConfigureCubeTile(10, 256, 2, 2, TileDataType_FP32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    ConfigureCubeTile(11, 256, 2, 2, TileDataType_FP32,
        TileLayout_CUBE_N8, TileLocation_Matrix);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 1 looplimit 2 do
            WriteTileElement(0, row, column, Zeros{PTO_XLEN} + 5);
            WriteTileElement(10, row, column, Zeros{PTO_XLEN} + 1);
            WriteTileElement(11, row, column, Zeros{PTO_XLEN} + 1);
        end;
    end;
    // Decode the ACC controls, then prove the direct owner rejects D==C.
    let stage_c_command_status_48 = ExecuteCommandInstruction(StageCCUBEStart('00001', TRUE), 32);
    assert stage_c_command_status_48 == CommandExecution_Executed;
    let stage_c_command_status_49 = ExecuteCommandInstruction(StageCDATR('00000', '00001'), 32);
    assert stage_c_command_status_49 == CommandExecution_Executed;
    let stage_c_command_status_50 = ExecuteCommandInstruction(StageCFPATR(Zeros{6}), 32);
    assert stage_c_command_status_50 == CommandExecution_Executed;
    assert !TileOperandsLegal_TMATMUL_ACC(0, 0, 10, 11);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 5;

    // The same alias is rejected when final D is quantized as well.
    ResetProfileState();
    ConfigureCubeTile(0, 256, 2, 2, TileDataType_FP32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    ConfigureCubeTile(10, 256, 2, 2, TileDataType_FP32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    ConfigureCubeTile(11, 256, 2, 2, TileDataType_FP32,
        TileLayout_CUBE_N8, TileLocation_Matrix);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    let stage_c_command_status_51 = ExecuteCommandInstruction(StageCCUBEStart('00001', TRUE), 32);
    assert stage_c_command_status_51 == CommandExecution_Executed;
    let stage_c_command_status_52 = ExecuteCommandInstruction(StageCDATR('00000', '00001'), 32);
    assert stage_c_command_status_52 == CommandExecution_Executed;
    let stage_c_command_status_53 = ExecuteCommandInstruction(StageCFPATR('000010'), 32);
    assert stage_c_command_status_53 == CommandExecution_Executed;
    assert !TileOperandsLegal_TMATMUL_ACC(0, 0, 10, 11);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 5;
end;

func main() => integer
begin
    StageCDecodedPE(TileLayout_CUBE_M16, '00000', '100');
    StageCDecodedPE(TileLayout_CUBE_M32, '00000', '101');
    StageCDecodedGroup(1);
    StageCDecodedGroup(64);
    StageCDecodedGroup(65);
    StageCDecodedGroup(128);
    StageCDecodedGroup(0);
    StageCDecodedGroup(129);
    StageCDecodedGroupZeroMask();
    StageCDecodedACCQuantized();
    StageCDecodedACCPreserving();
    StageCDecodedACCQuantizedFault();
    StageCDecodedACCAliasRules();
    return 0;
end;
