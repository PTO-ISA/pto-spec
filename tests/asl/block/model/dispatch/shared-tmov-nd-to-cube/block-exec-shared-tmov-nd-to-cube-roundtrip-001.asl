// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-ND-TO-CUBE-ROUNDTRIP-001","source":"asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","requirements":["PTO-TMOV-SHARED-ND-TO-CUBE-001","PTO-TMOV-CUBE-TO-SHARED-ND-001","PTO-CUBE-CELL-TRANSPORT-001"],"kind":"execution","summary":"forward CUBE-to-Shared and reverse Shared-to-CUBE TMOV preserve every valid raw coordinate","pass_condition":"a decoded singleton Layout-24 forward bundle publishes a nonuniform U8 CUBE_M32 payload as Shared RowMajor ND; a decoded Layout-21 reverse bundle creates an independent CUBE_M32 destination whose every valid raw element and backing descriptor match the original, while Shared publication remains unchanged and no GM event occurs","related_sources":["asl/block/model/dispatch/shared-tmov-cube-to-nd.asl","asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","asl/block/model/dispatch/shared-tlsu.asl","asl/tile/model/memory/shared-cube-to-nd.asl","asl/tile/model/memory/shared-nd-to-cube.asl"]}

pure func SharedNDToCubeRoundtripStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func SharedNDToCubeRoundtripDATR(layout: integer {21,24})
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = Zeros{5} + 31;
    instruction[11:7] = Zeros{5} + layout;
    return instruction;
end;

pure func SharedNDToCubeRoundtripDimension(lb: integer {0,1},
    value: integer {32,128}) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000043;
    if lb == 1 then instruction = Zeros{64} + 0x00001043; end;
    instruction[31:20] = Zeros{12} + value;
    return instruction;
end;

pure func SharedNDToCubeRoundtripShared(shared_id: bits(6),
    size_code: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = size_code;
    instruction[11:9] = '001';
    return instruction;
end;

pure func SharedNDToCubeRoundtripLocalSource(tile: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = tile;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func SharedNDToCubeRoundtripLocalDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = Zeros{4} + 6;
    instruction[8:7] = '10';
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func SharedNDToCubeRoundtripValue(row: integer {0..31},
    column: integer {0..127}) => Word
begin
    return Zeros{PTO_XLEN} +
        ((17 + row * 47 + column * 29 + ((row * column) MOD 113)) MOD 256);
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0xc00);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0xc00);
    let configured = ConfigureCubeTileForMask(10, 4096, 32, 128,
        TileDataType_U8, TileLayout_CUBE_M32, '1000');
    assert configured;
    InstallRelativeTileFixture(10, 10);
    let shared_id = (Zeros{6} + 40) as SharedTileID;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 127 looplimit 128 do
            WriteTileElement(10, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeRoundtripValue(row as integer {0..31},
                    column as integer {0..127}));
        end;
    end;
    let source_before = _Tiles[[10]];
    assert TileCubeDescriptorLegal(source_before) &&
           source_before.contents_defined;

    let forward_start = ExecuteCommandInstruction(
        SharedNDToCubeRoundtripStart(), 32);
    let forward_datr = ExecuteCommandInstruction(
        SharedNDToCubeRoundtripDATR(24), 32);
    let shared_destination = ExecuteCommandInstruction(
        SharedNDToCubeRoundtripShared(Zeros{6} + 40,
            Zeros{4} + 6), 32);
    let forward_source = ExecuteCommandInstruction(
        SharedNDToCubeRoundtripLocalSource(Zeros{6} + 10), 32);
    assert forward_start == CommandExecution_Executed &&
           forward_datr == CommandExecution_Executed &&
           shared_destination == CommandExecution_Executed &&
           forward_source == CommandExecution_Executed &&
           BundleSharedTMOVCubeToNDSelected() &&
           BundleSharedTMOVCubeToNDSchemaLegal();
    assert BundleSharedBindingMask(0)[PTOPEMaskBitOfPEIdentity(
               _CurrentMemoryAgent)] == '1' &&
           PEMaskPopulation(BundleSharedBindingMask(0)) == 1;
    StartMemoryEventCapture(0);
    let forward_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    StopMemoryEventCapture();
    let shared_forward = SharedTileRecord(shared_id);
    assert forward_stop == CommandExecution_Executed;
    assert _LastFault == Fault_None && _MemoryEventCount == 0;
    assert shared_forward.descriptor_valid;
    assert SharedTilePublished(shared_id);
    assert shared_forward.tile.layout == TileLayout_RowMajor &&
           shared_forward.tile.capacity_bytes == 4096 &&
           shared_forward.tile.rows == 32 &&
           shared_forward.tile.columns == 128 &&
           shared_forward.tile.data_type == TileDataType_U8;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 127 looplimit 128 do
            let shared_element = TileLogicalLinearIndex(
                shared_forward.tile, row as integer {0..65535},
                column as integer {0..65535});
            assert TileLogicalElementDefined(
                       shared_forward.tile, shared_element) &&
                   TileReadLogicalElement(shared_forward.tile,
                       shared_element) ==
                       SharedNDToCubeRoundtripValue(
                           row as integer {0..31},
                           column as integer {0..127});
        end;
    end;

    let reverse_start = ExecuteCommandInstruction(
        SharedNDToCubeRoundtripStart(), 32);
    let reverse_datr = ExecuteCommandInstruction(
        SharedNDToCubeRoundtripDATR(21), 32);
    let lb0 = ExecuteCommandInstruction(
        SharedNDToCubeRoundtripDimension(0, 128), 32);
    let lb1 = ExecuteCommandInstruction(
        SharedNDToCubeRoundtripDimension(1, 32), 32);
    let shared_source = ExecuteCommandInstruction(
        SharedNDToCubeRoundtripShared(shared_id as bits(6), Zeros{4}), 32);
    let local_destination = ExecuteCommandInstruction(
        SharedNDToCubeRoundtripLocalDestination(), 32);
    assert reverse_start == CommandExecution_Executed &&
           reverse_datr == CommandExecution_Executed &&
           lb0 == CommandExecution_Executed &&
           lb1 == CommandExecution_Executed &&
           shared_source == CommandExecution_Executed &&
           local_destination == CommandExecution_Executed &&
           BundleSharedTMOVSharedNDToCubeSchemaLegal();
    StartMemoryEventCapture(0);
    let reverse_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    StopMemoryEventCapture();
    assert reverse_stop == CommandExecution_Executed &&
           _LastFault == Fault_None && _MemoryEventCount == 0;

    var destination = 0 as TileIndex;
    var found = FALSE;
    for tile = 0 to 63 do
        if !found && tile != 10 && _Tiles[[tile]].allocated &&
           _Tiles[[tile]].layout == TileLayout_CUBE_M32 &&
           _Tiles[[tile]].capacity_bytes == 4096 then
            destination = tile as TileIndex;
            found = TRUE;
        end;
    end;
    assert found;
    let result = _Tiles[[destination]];
    assert result.rows == 32 && result.columns == 128 &&
           result.valid_rows == 32 && result.valid_columns == 128 &&
           result.layout == TileLayout_CUBE_M32 &&
           result.data_type == TileDataType_U8 && result.contents_defined;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 127 looplimit 128 do
            assert ReadTileElement(destination,
                       row as integer {0..65535},
                       column as integer {0..65535}) ==
                   SharedNDToCubeRoundtripValue(
                       row as integer {0..31},
                       column as integer {0..127});
        end;
    end;
    let shared_after = SharedTileRecord(shared_id);
    assert shared_after.payload_generation ==
               shared_forward.payload_generation &&
           shared_after.payload_live == shared_forward.payload_live &&
           shared_after.published == shared_forward.published;
    assert source_before.layout == TileLayout_CUBE_M32 &&
           source_before.data_type == TileDataType_U8 &&
           source_before.capacity_bytes == result.capacity_bytes;
    return 0;
end;
