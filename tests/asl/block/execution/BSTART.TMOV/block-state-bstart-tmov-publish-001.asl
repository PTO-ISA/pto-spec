// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMOV-PUBLISH-001","source":"asl/block/execution/BSTART.TMOV.asl","requirements":["PTO-INST-BLOCK-BSTART-TMOV","PTO-INST-BLOCK-B-ASSEMBLE","PTO-B-ASSEMBLE-SHARED-STANDALONE-001"],"kind":"state-transition","summary":"INSERT and PUBLISH keep publication distinct and gate BROADCAST","pass_condition":"single-PE INSERT remains unpublished, BROADCAST rejects, collective PUBLISH uses INIT_LAST assembly, and BROADCAST then copies the payload","related_sources":["asl/block/operands/B.ASSEMBLE.asl","asl/block/model/operands/shared-generation.asl","asl/tile/model/state/shared-registers.asl","asl/tile/model/memory/shared-movement.asl"]}
pure func TMOVPublishStart(function: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = function;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func TMOVPublishLocalSource(source: bits(6), pe_mode: bits(3))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = source;
    instruction[19] = '1';
    instruction[18:15] = '0000';
    instruction[11:9] = pe_mode;
    return instruction;
end;

pure func TMOVPublishLocalDestination(hand: bits(2), pe_mode: bits(3))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = '0001';
    instruction[8:7] = hand;
    instruction[19] = '1';
    instruction[11:9] = pe_mode;
    return instruction;
end;

pure func TMOVPublishShared(shared_tile_id: bits(6), size_code: bits(4),
                            pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    return instruction;
end;

pure func TMOVPublishAssemble(parent_size_code: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[11] = '1';
    instruction[10:7] = parent_size_code;
    return instruction;
end;

func TMOVPublishExecute(instruction: bits(64))
begin
    let status = ExecuteCommandInstruction(instruction, 32);
    assert status == CommandExecution_Executed;
end;

func main() => integer
begin
    ResetProfileState();
    let shared_tile_id = (Zeros{6} + 7) as SharedTileID;
    ConfigureTileForMask(0, 128, 128, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any, '1000');
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x5a);

    TMOVPublishExecute(TMOVPublishStart('01001'));
    TMOVPublishExecute(TMOVPublishLocalSource(Zeros{6}, '001'));
    TMOVPublishExecute(TMOVPublishShared(shared_tile_id, '0001', '001'));
    let insert_completed = ExecuteBundleTileOperation();
    assert insert_completed;
    assert SharedTileFullyInitialized(shared_tile_id);
    assert !SharedTilePublished(shared_tile_id);
    assert ReadSharedTileWord(shared_tile_id, 0) == Zeros{PTO_XLEN} + 0x5a;

    ResetBundleControlState();
    ClearFault();
    TMOVPublishExecute(TMOVPublishStart('01011'));
    TMOVPublishExecute(TMOVPublishShared(shared_tile_id, '0000', '111'));
    TMOVPublishExecute(TMOVPublishLocalDestination('01', '111'));
    let rejected_broadcast = ExecuteBundleTileOperation();
    assert !rejected_broadcast;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[16]].allocated;

    ResetProfileState();
    ConfigureTileForMask(0, 128, 128, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any, '1111');
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x5a);
    TMOVPublishExecute(TMOVPublishStart('01010'));
    TMOVPublishExecute(TMOVPublishLocalSource(Zeros{6}, '111'));
    TMOVPublishExecute(TMOVPublishShared(shared_tile_id, '0001', '111'));
    TMOVPublishExecute(TMOVPublishAssemble('0001'));
    let publish_completed = ExecuteBundleTileOperation();
    assert publish_completed;
    assert SharedTilePublished(shared_tile_id);

    ResetBundleControlState();
    ClearFault();
    TMOVPublishExecute(TMOVPublishStart('01011'));
    TMOVPublishExecute(TMOVPublishShared(shared_tile_id, '0000', '111'));
    TMOVPublishExecute(TMOVPublishLocalDestination('01', '111'));
    let broadcast_completed = ExecuteBundleTileOperation();
    assert broadcast_completed;
    assert _Tiles[[16]].allocated;
    assert _Tiles[[16]].payload[[0]] == Zeros{PTO_XLEN} + 0x5a;
    assert SharedTilePublished(shared_tile_id);
    return 0;
end;
