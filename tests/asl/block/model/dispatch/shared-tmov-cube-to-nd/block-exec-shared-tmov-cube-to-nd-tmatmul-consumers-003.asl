// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-CUBE-TO-ND-TMATMUL-CONSUMERS-003","source":"asl/block/model/dispatch/shared-tmov-cube-to-nd.asl","requirements":["PTO-TMOV-CUBE-TO-SHARED-ND-001","PTO-TMATMUL-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"execution","summary":"real TMATMUL consumes a published CUBE-to-ND Shared parent as left, transposed-left, and right input","pass_condition":"A singleton encoded CUBE_M32/U16-to-ND TMOV publishes a non-symmetric 2x2 matrix; ordinary Shared TMATMUL then produces independent integer dot-product goldens for converted-left, converted-transposed-left, and converted-right inputs","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/block/model/dispatch/shared-tlsu.asl","asl/tile/model/memory/shared-cube-to-nd.asl"]}

pure func ConsumerCubeToNDStart(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func ConsumerCubeToNDShared(shared_id: bits(6),
    size_code: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = size_code;
    instruction[11:9] = '100';
    return instruction;
end;

pure func ConsumerCubeToNDLocalSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[11:9] = '100';
    instruction[19] = '1';
    return instruction;
end;

func PublishConsumerCubeToNDSource()
begin
    let configured = ConfigureCubeTileForMask(0, 256, 32, 4,
        TileDataType_U16, TileLayout_CUBE_M32, '1111');
    assert configured;
    InstallRelativeTileFixture(0, 0);
    var source = _Tiles[[0]];
    source.valid_rows = 2;
    source.valid_columns = 2;
    for row = 0 to 1 do
        for column = 0 to 1 do
            let element = TileStorageIndex(source,
                row as integer {0..65535}, column as integer {0..65535});
            source.payload[[element]] = Zeros{PTO_XLEN} +
                (1 + row * 2 + column);
            source.defined_elements[element] = '1';
        end;
    end;
    source.defined_valid_elements = 4 as integer {0..524288};
    source.contents_defined = TRUE;
    _Tiles[[0]] = source;
    assert TileCubeDescriptorLegal(source);

    let start_status = ExecuteCommandInstruction(
        ConsumerCubeToNDStart(Zeros{5} + 26), 32);
    let datr_status = ExecuteCommandInstruction(
        Zeros{64} + 0x01f01c23, 32);
    let shared_status = ExecuteCommandInstruction(ConsumerCubeToNDShared(
        Zeros{6} + 40, Zeros{4} + 2), 32);
    let source_status = ExecuteCommandInstruction(
        ConsumerCubeToNDLocalSource(), 32);
    assert start_status == CommandExecution_Executed;
    assert datr_status == CommandExecution_Executed;
    assert shared_status == CommandExecution_Executed;
    assert source_status == CommandExecution_Executed;
    assert BundleSharedTMOVCubeToNDSchemaLegal();
    let candidate = BundleSharedTMOVCubeToNDCandidate(0);
    assert SharedTileProspectiveFullyInitialized(
        (Zeros{6} + 40) as SharedTileID,
        candidate.tile, BundleSharedBindingMask(0));
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop_status == CommandExecution_Executed;
    assert _LastFault == Fault_None && SharedTilePublished(
        (Zeros{6} + 40) as SharedTileID);
    let converted = SharedTileRecord((Zeros{6} + 40) as SharedTileID).tile;
    assert converted.layout == TileLayout_RowMajor &&
           converted.data_type == TileDataType_U16 &&
           converted.capacity_bytes == 256 && converted.rows == 32 &&
           converted.columns == 4 && converted.valid_rows == 2 &&
           converted.valid_columns == 2;
    assert TileReadLogicalElement(converted,
        TileLogicalLinearIndex(converted, 0, 0)) == Zeros{PTO_XLEN} + 1 &&
           TileReadLogicalElement(converted,
        TileLogicalLinearIndex(converted, 0, 1)) == Zeros{PTO_XLEN} + 2 &&
           TileReadLogicalElement(converted,
        TileLogicalLinearIndex(converted, 1, 0)) == Zeros{PTO_XLEN} + 3 &&
           TileReadLogicalElement(converted,
        TileLogicalLinearIndex(converted, 1, 1)) == Zeros{PTO_XLEN} + 4;
end;

func InstallConsumerTMATMULRightOperand()
begin
    ConfigureTileForMask(10, 256, 32, 4, 2, 2,
        TileDataType_U16, TileLayout_RowMajor, '1111');
    for row = 0 to 1 do
        for column = 0 to 1 do
            WriteTileElement(10, row, column,
                Zeros{PTO_XLEN} + (5 + row * 2 + column));
        end;
    end;
    InstallSharedTile((Zeros{6} + 41) as SharedTileID,
        _Tiles[[10]], '1111');
end;

func ExecuteConsumerTMATMULCase(converted_left: boolean,
    transpose_left: boolean,
    expected00: integer {0..65535}, expected01: integer {0..65535},
    expected10: integer {0..65535}, expected11: integer {0..65535})
begin
    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 26;
    let start_status = ExecuteCommandInstruction(start, 32);
    assert start_status == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
        transpose_left, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    if converted_left then
        BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
    else
        BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
    end;
    AddBundleTileBinding(
        TRUE, 0, 6, '1111', FALSE, FALSE, 0, 0, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    assert _Tiles[[destination]].contents_defined &&
           _Tiles[[destination]].data_type == TileDataType_U32 &&
           _Tiles[[destination]].valid_rows == 2 &&
           _Tiles[[destination]].valid_columns == 2;
    assert ReadTileElement(destination, 0, 0) ==
               Zeros{PTO_XLEN} + expected00 &&
           ReadTileElement(destination, 0, 1) ==
               Zeros{PTO_XLEN} + expected01 &&
           ReadTileElement(destination, 1, 0) ==
               Zeros{PTO_XLEN} + expected10 &&
           ReadTileElement(destination, 1, 1) ==
               Zeros{PTO_XLEN} + expected11;
end;

func main() => integer
begin
    ResetProfileState();
    PublishConsumerCubeToNDSource();
    InstallConsumerTMATMULRightOperand();
    ExecuteConsumerTMATMULCase(TRUE, FALSE, 17, 23, 39, 53);
    ResetProfileState();
    PublishConsumerCubeToNDSource();
    InstallConsumerTMATMULRightOperand();
    ExecuteConsumerTMATMULCase(TRUE, TRUE, 23, 31, 34, 46);
    ResetProfileState();
    PublishConsumerCubeToNDSource();
    InstallConsumerTMATMULRightOperand();
    ExecuteConsumerTMATMULCase(FALSE, FALSE, 17, 39, 23, 53);
    return 0;
end;
