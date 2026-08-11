// PTO-TEST: {"id":"PTO-AVS-TILE-MODEL-EXECUTION-POSTPROCESS-AUX-EXECUTION-001","source":"asl/tile/model/execution/postprocess.asl","requirements":[],"kind":"execution","summary":"matrix postprocess publishes D, RowMaxOut, and GroupMaxOut as one complete-bundle result","pass_condition":"enabled auxiliary outputs are allocated and observe the same full-K result as D","related_sources":[]}

pure func PostProcessTestCUBEStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func PostProcessTestFPATR() => bits(64)
begin
    return Zeros{64} + 0x00002023;
end;

pure func PostProcessTestFPATRWithReductionFlags(group_n: bits(4)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00002023;
    // GroupNCode carries the accepted RowMaxEn/GroupMaxEn/RowMaxInit bits
    // in the complete-bundle descriptor encoding.
    instruction[22:19] = group_n;
    instruction[18] = '1';
    instruction[17] = '1';
    instruction[16] = '1';
    return instruction;
end;

pure func PostProcessTestFPATRWithModes(pre_quant: bits(6), relu: bits(3),
                                       group_n: bits(4)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00002023;
    instruction[31:26] = pre_quant;
    instruction[25:23] = relu;
    instruction[22:19] = group_n;
    instruction[18] = '1';
    instruction[17] = '1';
    instruction[16] = '1';
    return instruction;
end;

pure func PostProcessTestScalarBinding(source0: bits(5), source1: bits(5))
                                     => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[11:7] = Zeros{5};
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    instruction[31:27] = Zeros{5};
    return instruction;
end;

pure func PostProcessTestDATR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[31:29] = Zeros{3};
    instruction[28:27] = Zeros{2};
    instruction[26] = '0';
    instruction[25] = '0';
    instruction[24:20] = Zeros{5} + 24;
    instruction[17:15] = Zeros{3};
    instruction[11:7] = Zeros{5};
    return instruction;
end;

pure func PostProcessTestSharedBinding(shared_id: bits(8)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = '1111';
    instruction[11:9] = '000';
    return instruction;
end;

pure func PostProcessTestTwoSourceDestination(source0: bits(6), source1: bits(6),
                                              destination: bits(2), last: boolean)
                                              => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[11:9] = '001';
    instruction[8:7] = destination;
    instruction[18:15] = '1111';
    instruction[25:20] = source0;
    instruction[31:26] = source1;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

pure func PostProcessTestDestination(destination: bits(2), last: boolean)
                                     => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[11:9] = '001';
    instruction[8:7] = destination;
    instruction[18:15] = '1111';
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

pure func PostProcessTestOneSourceDestination(source0: bits(6),
                                              destination: bits(2),
                                              last: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[11:9] = '001';
    instruction[8:7] = destination;
    instruction[18:15] = '1111';
    instruction[25:20] = source0;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

pure func PostProcessTestSource(source0: bits(6), last: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[11:9] = '000';
    instruction[18:15] = '1111';
    instruction[25:20] = source0;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

func main() => integer
begin
    // Full decoded Local CUBE path: BSTART -> B.FPATR -> three B.IOT
    // bindings -> preflight/allocation -> matrix execution -> atomic commit.
    // The row-max input is the old value in tile 4; D, RowMaxOut, and
    // GroupMaxOut are allocated as one output group and observe the same
    // full-K result.
    ResetProfileState();
    ConfigureTile(0, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(4, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 36);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 9);
    let decoded_start = ExecuteCommandInstruction(PostProcessTestCUBEStart(), 32);
    assert decoded_start == CommandExecution_Executed;
    assert _BundleOperation.valid;
    assert _BundleOperation.operation_class == BundleOperation_TileMatrix;
    assert !_BundleFixedPointAttributes.valid;
    assert DecodeCommandForm(PostProcessTestFPATRWithReductionFlags('0010'), 32) == 99;
    assert PostProcessTestFPATRWithReductionFlags('0010')[17] == '1';
    assert CommandFormOperandsLegal(
        PostProcessTestFPATRWithReductionFlags('0010'), 99);
    assert DecodeCommandOperandRaw(
        PostProcessTestFPATRWithReductionFlags('0010'), 99,
        CommandField_PreQuantMode)[5:0] == Zeros{6};
    assert DecodeCommandOperandRaw(
        PostProcessTestFPATRWithReductionFlags('0010'), 99,
        CommandField_GroupNCode)[3:0] == '0010';
    assert CommandDecodedBool(PostProcessTestFPATRWithReductionFlags('0010'),
        99, CommandField_RowMaxEn);
    assert CommandDecodedBool(PostProcessTestFPATRWithReductionFlags('0010'),
        99, CommandField_GroupMaxEn);
    assert CommandDecodedBool(PostProcessTestFPATRWithReductionFlags('0010'),
        99, CommandField_RowMaxInit);
    assert !CommandDecodedBool(PostProcessTestFPATRWithReductionFlags('0010'),
        99, CommandField_MaxAbsEn);
    assert BundleFPATRFieldsLegal(
        DecodeCommandOperandRaw(PostProcessTestFPATRWithReductionFlags('0010'),
            99, CommandField_PreQuantMode)[5:0],
        DecodeCommandOperandRaw(PostProcessTestFPATRWithReductionFlags('0010'),
            99, CommandField_ReluMode)[2:0],
        DecodeCommandOperandRaw(PostProcessTestFPATRWithReductionFlags('0010'),
            99, CommandField_GroupNCode)[3:0],
        CommandDecodedBool(PostProcessTestFPATRWithReductionFlags('0010'), 99,
            CommandField_RowMaxEn),
        CommandDecodedBool(PostProcessTestFPATRWithReductionFlags('0010'), 99,
            CommandField_GroupMaxEn),
        CommandDecodedBool(PostProcessTestFPATRWithReductionFlags('0010'), 99,
            CommandField_RowMaxInit),
        CommandDecodedBool(PostProcessTestFPATRWithReductionFlags('0010'), 99,
            CommandField_MaxAbsEn));
    assert BundleFPATRFieldsLegal(Zeros{6}, Zeros{3}, '0010', FALSE, TRUE, FALSE, FALSE);
    let decoded_fpatr = ExecuteCommandInstruction(
        PostProcessTestFPATRWithReductionFlags('0010'), 32);
    assert _BundleFixedPointAttributes.valid;
    let decoded_math = ExecuteCommandInstruction(
        PostProcessTestTwoSourceDestination(Zeros{6}, Zeros{6} + 4, '00', FALSE), 32);
    let decoded_row = ExecuteCommandInstruction(
        PostProcessTestOneSourceDestination(Zeros{6} + 4, '01', FALSE), 32);
    let decoded_group = ExecuteCommandInstruction(
        PostProcessTestDestination('10', TRUE), 32);
    assert decoded_start == CommandExecution_Executed;
    assert decoded_fpatr == CommandExecution_Executed;
    assert decoded_math == CommandExecution_Executed;
    assert decoded_row == CommandExecution_Executed;
    assert decoded_group == CommandExecution_Executed;
    let decoded_completed = ExecuteBundleTileOperation();
    assert decoded_completed;
    let decoded_d = _BundleTileBindings[[0]].destination;
    let decoded_row_out = _BundleTileBindings[[1]].destination;
    let decoded_group_out = _BundleTileBindings[[2]].destination;
    assert ReadTileElement(decoded_d, 0, 0) == Zeros{PTO_XLEN} + 324;
    assert ReadTileElement(decoded_row_out, 0, 0) == Zeros{PTO_XLEN} + 324;
    assert ReadTileElement(decoded_group_out, 0, 0) == Zeros{PTO_XLEN} + 324;

    // The same decoded complete-bundle path exercises dense scalar
    // QuantParam/LReLUParam routing before the auxiliary output bindings.
    ResetProfileState();
    ConfigureTile(0, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(4, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 36);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 9);
    let scalar_start = ExecuteCommandInstruction(PostProcessTestCUBEStart(), 32);
    let scalar_datr = ExecuteCommandInstruction(PostProcessTestDATR(), 32);
    let scalar_fpatr = ExecuteCommandInstruction(
        PostProcessTestFPATRWithModes('000011', '010', '0010'), 32);
    WriteGPR(2, Zeros{PTO_XLEN} + 17);
    WriteGPR(3, Zeros{PTO_XLEN} + 19);
    let scalar_ior = ExecuteCommandInstruction(
        PostProcessTestScalarBinding(Zeros{5} + 2, Zeros{5} + 3), 32);
    let scalar_math = ExecuteCommandInstruction(
        PostProcessTestTwoSourceDestination(Zeros{6}, Zeros{6} + 4, '00', FALSE), 32);
    let scalar_row = ExecuteCommandInstruction(
        PostProcessTestOneSourceDestination(Zeros{6} + 4, '01', FALSE), 32);
    let scalar_group = ExecuteCommandInstruction(
        PostProcessTestDestination('10', TRUE), 32);
    let scalar_operation = DecodeTileOperation(TileDecode_CUBE, Zeros{12})
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(scalar_operation);
    assert BundleOperationGPRBindingValuesLegal(scalar_operation);
    let scalar_operands = BundleTileInstructionOperands(scalar_operation);
    assert scalar_operands.post_quant_param == Zeros{PTO_XLEN} + 17;
    assert scalar_operands.post_lrelu_param == Zeros{PTO_XLEN} + 19;
    let scalar_attrs_legal = SelectedBundleTileDataAttributesLegal(scalar_operation);
    assert scalar_attrs_legal;
    let scalar_destinations = ResolveBundleTileDestinations();
    assert scalar_destinations;
    assert scalar_start == CommandExecution_Executed;
    assert scalar_datr == CommandExecution_Executed;
    assert scalar_fpatr == CommandExecution_Executed;
    assert scalar_ior == CommandExecution_Executed;
    assert scalar_math == CommandExecution_Executed;
    assert scalar_row == CommandExecution_Executed;
    assert scalar_group == CommandExecution_Executed;
    let scalar_completed = ExecuteBundleTileOperation();
    assert scalar_completed;

    // Vector QuantParam/PReLUParam use the same decoded Local stream after
    // the mathematical and RowMaxIn sources and still commit all outputs.
    ResetProfileState();
    ConfigureTile(0, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(4, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(5, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(6, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 36);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 9);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} + 3);
    let vector_start = ExecuteCommandInstruction(PostProcessTestCUBEStart(), 32);
    let vector_datr = ExecuteCommandInstruction(PostProcessTestDATR(), 32);
    let vector_fpatr = ExecuteCommandInstruction(
        PostProcessTestFPATRWithModes('000010', '011', '0010'), 32);
    let vector_math = ExecuteCommandInstruction(
        PostProcessTestTwoSourceDestination(Zeros{6}, Zeros{6} + 4, '00', FALSE), 32);
    let vector_row = ExecuteCommandInstruction(
        PostProcessTestOneSourceDestination(Zeros{6} + 4, '01', FALSE), 32);
    let vector_quant = ExecuteCommandInstruction(
        PostProcessTestSource(Zeros{6} + 5, FALSE), 32);
    let vector_prelu = ExecuteCommandInstruction(
        PostProcessTestSource(Zeros{6} + 6, FALSE), 32);
    let vector_group = ExecuteCommandInstruction(
        PostProcessTestDestination('10', TRUE), 32);
    assert vector_start == CommandExecution_Executed;
    assert vector_datr == CommandExecution_Executed;
    assert vector_fpatr == CommandExecution_Executed;
    assert vector_math == CommandExecution_Executed;
    assert vector_row == CommandExecution_Executed;
    assert vector_quant == CommandExecution_Executed;
    assert vector_prelu == CommandExecution_Executed;
    assert vector_group == CommandExecution_Executed;
    let vector_completed = ExecuteBundleTileOperation();
    assert vector_completed;

    ResetProfileState();
    ConfigureTile(0, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(3, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(4, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 36);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 9);

    // Install a decoded CUBE operation and a present B.FPATR, then bind
    // D, RowMaxOut==RowMaxIn, and GroupMaxOut before invoking the owner.
    let start = ExecuteCommandInstruction(PostProcessTestCUBEStart(), 32);
    let fpatr = ExecuteCommandInstruction(PostProcessTestFPATR(), 32);
    assert start == CommandExecution_Executed;
    assert fpatr == CommandExecution_Executed;
    _BundleFixedPointAttributes.group_n_code = '0111';
    _BundleFixedPointAttributes.row_max_en = TRUE;
    _BundleFixedPointAttributes.group_max_en = TRUE;
    _BundleFixedPointAttributes.row_max_init = TRUE;

    _BundleTileBindings[[0]].valid = TRUE;
    _BundleTileBindings[[0]].destination_valid = TRUE;
    _BundleTileBindings[[0]].destination = 1;
    _BundleTileBindings[[0]].source0_valid = TRUE;
    _BundleTileBindings[[0]].source0 = 0;
    _BundleTileBindings[[0]].source1_valid = TRUE;
    _BundleTileBindings[[0]].source1 = 0;
    _BundleTileBindings[[1]].valid = TRUE;
    _BundleTileBindings[[1]].destination_valid = TRUE;
    _BundleTileBindings[[1]].destination = 4;
    _BundleTileBindings[[1]].source0_valid = TRUE;
    _BundleTileBindings[[1]].source0 = 4;
    _BundleTileBindings[[2]].valid = TRUE;
    _BundleTileBindings[[2]].destination_valid = TRUE;
    _BundleTileBindings[[2]].destination = 3;

    CommitMatrixResult(1, _Tiles[[0]]);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 36;
    assert ReadTileElement(4, 0, 0) == Zeros{PTO_XLEN} + 36;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 36;
    // Profile ownership is executable and deterministic: the PTO-v0
    // post-process hook preserves raw carriers, while MaxAbs reuses the
    // registered ABS and MAX hooks for multi-element folding.
    let raw = Zeros{PTO_XLEN} + 0x1234;
    var processed = TileProfileMatrixPostProcess(raw, Zeros{6}, Zeros{3}, Zeros{4},
        TileDataType_U64, Zeros{PTO_XLEN}, Zeros{PTO_XLEN},
        DefaultNumericExecutionControl());
    assert processed == raw;
    var reduced = TileProfileMatrixReductionStep(Zeros{PTO_XLEN} + 3,
        Zeros{PTO_XLEN} + 7, FALSE, TileDataType_U64);
    assert reduced == Zeros{PTO_XLEN} + 7;
    var reduced_abs = TileProfileMatrixReductionStep(Zeros{PTO_XLEN} + 3,
        Zeros{PTO_XLEN} + 7, TRUE, TileDataType_U64);
    assert reduced_abs == Zeros{PTO_XLEN} + 7;
    return 0;
end;
