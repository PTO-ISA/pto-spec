// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-ND-TO-CUBE-SINGLETON-001","source":"asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","requirements":["PTO-TMOV-SHARED-ND-TO-CUBE-001","PTO-BSTART-TMOV-SHARED-001","PTO-CUBE-CELL-TRANSPORT-001"],"kind":"execution","summary":"an encoded Shared ND M32 TMOV produces a Local CUBE with identical logical values","pass_condition":"a published 32x128 U8 RowMajor Shared parent is consumed through decoded Function-2 TMOV Layout 21 into an exact 4 KiB CUBE_M32 Local destination, all nonuniform logical values match, the Shared source is unchanged, and no GM event occurs","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","asl/tile/model/memory/shared-nd-to-cube.asl"]}

pure func SharedNDToCubeStart(carrier: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = carrier;
    return instruction;
end;

pure func SharedNDToCubeDATR(layout: integer {21,22}) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = Zeros{5} + 31;
    instruction[11:7] = Zeros{5} + layout;
    return instruction;
end;

pure func SharedNDToCubeSharedSource(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    return instruction;
end;

pure func SharedNDToCubeLocalDestination(size_code: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[8:7] = '10';
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func SharedNDToCubeGolden(row: integer {0..31},
    column: integer {0..127}) => Word
begin
    return Zeros{PTO_XLEN} + 1 + row * 131 + column * 17 +
        ((row * column) MOD 97);
end;

func main() => integer
begin
    ResetProfileState();
    let shared_id = (Zeros{6} + 38) as SharedTileID;
    ConfigureTileForMask(10, 4096, 32, 128, 32, 128,
        TileDataType_U8, TileLayout_RowMajor, '1000');
    assert _Tiles[[10]].allocated;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 127 looplimit 128 do
            WriteTileElement(10, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeGolden(row as integer {0..31},
                    column as integer {0..127}));
        end;
    end;
    InstallSharedTile(shared_id, _Tiles[[10]], '1000');
    let source_before = SharedTileRecord(shared_id);
    assert SharedTilePublished(shared_id);

    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x100);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    StartMemoryEventCapture(0);

    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeStart(TileDataTypeToEncoding(TileDataType_U8)), 32);
    assert start_status == CommandExecution_Executed &&
           BundleTMOVSelected();
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeDATR(21), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    // Omitted/effective LB2=1 derives the exact physical column count.
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeSharedSource(shared_id as bits(6)), 32);
    assert shared_status == CommandExecution_Executed &&
           BundleSharedTMOVSharedNDToCubeSelected();
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeLocalDestination(Zeros{4} + 6), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed;
    assert BundleSharedBindingMask(0) ==
               _BundleTileBindings[[0]].pe_mask &&
           BundleSharedBindingMask(0)[PTOPEMaskBitOfPEIdentity(
               _CurrentMemoryAgent)] == '1';
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    StopMemoryEventCapture();
    assert stop_status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 0;

    var destination = 0 as TileIndex;
    var destination_count: integer {0..64} = 0;
    for tile = 0 to 63 do
        if _Tiles[[tile]].allocated &&
           _Tiles[[tile]].layout == TileLayout_CUBE_M32 &&
           _Tiles[[tile]].capacity_bytes == 4096 then
            destination = tile as TileIndex;
            destination_count = (destination_count + 1) as integer {0..64};
        end;
    end;
    assert destination_count == 1;
    let result = _Tiles[[destination]];
    assert result.capacity_bytes == 4096;
    assert result.rows == 32;
    assert result.columns == 128;
    assert result.valid_rows == 32;
    assert result.valid_columns == 128;
    assert result.data_type == TileDataType_U8;
    assert result.layout == TileLayout_CUBE_M32;
    assert result.contents_defined;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 127 looplimit 128 do
            assert ReadTileElement(destination,
                row as integer {0..65535},
                column as integer {0..65535}) ==
                SharedNDToCubeGolden(row as integer {0..31},
                    column as integer {0..127});
        end;
    end;
    let source_after = SharedTileRecord(shared_id);
    assert source_after.payload_generation == source_before.payload_generation &&
           source_after.payload_live == source_before.payload_live &&
           source_after.published == source_before.published;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 127 looplimit 128 do
            let source_element = TileLogicalLinearIndex(source_after.tile,
                row as integer {0..65535},
                column as integer {0..65535});
            assert TileLogicalElementDefined(source_after.tile,
                       source_element) &&
                   TileReadLogicalElement(source_after.tile,
                       source_element) ==
                       SharedNDToCubeGolden(row as integer {0..31},
                           column as integer {0..127});
        end;
    end;
    return 0;
end;
