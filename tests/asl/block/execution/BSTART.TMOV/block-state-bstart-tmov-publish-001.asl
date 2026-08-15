// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMOV-PUBLISH-001","source":"asl/block/execution/BSTART.TMOV.asl","requirements":["PTO-INST-BLOCK-BSTART-TMOV"],"kind":"state-transition","summary":"INSERT and PUBLISH keep publication distinct and gate BROADCAST","pass_condition":"INSERT remains unpublished, BROADCAST rejects, PUBLISH establishes publication, and BROADCAST then copies the payload","related_sources":["asl/tile/model/state/shared-registers.asl","asl/tile/model/memory/shared-movement.asl"]}
pure func TMOVPublishStart(function: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = function;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func TMOVPublishLocalSource(source: bits(6), pe_mask: bits(4))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = source;
    instruction[19] = '1';
    instruction[18:15] = pe_mask;
    return instruction;
end;

pure func TMOVPublishLocalDestination(hand: bits(2), pe_mask: bits(4))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[11:9] = '001';
    instruction[8:7] = hand;
    instruction[19] = '1';
    instruction[18:15] = pe_mask;
    return instruction;
end;

pure func TMOVPublishShared(shared_id: bits(8), size: bits(3),
                            pe_mask: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = pe_mask;
    instruction[11:9] = size;
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
    let shared_id = Zeros{8} + 7;
    ConfigureTileForMask(0, 128, 128, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any, '1111');
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x5a);

    TMOVPublishExecute(TMOVPublishStart('01001'));
    TMOVPublishExecute(TMOVPublishLocalSource(Zeros{6}, '1111'));
    TMOVPublishExecute(TMOVPublishShared(shared_id, '001', '1111'));
    let insert_completed = ExecuteBundleTileOperation();
    assert insert_completed;
    assert SharedTileFullyInitialized(shared_id);
    assert !SharedTilePublished(shared_id);
    assert ReadSharedTileWord(shared_id, 0) == Zeros{PTO_XLEN} + 0x5a;

    ResetBundleControlState();
    ClearFault();
    TMOVPublishExecute(TMOVPublishStart('01011'));
    TMOVPublishExecute(TMOVPublishShared(shared_id, '000', '1111'));
    TMOVPublishExecute(TMOVPublishLocalDestination('01', '1111'));
    let rejected_broadcast = ExecuteBundleTileOperation();
    assert !rejected_broadcast;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[16]].allocated;

    ResetBundleControlState();
    ClearFault();
    TMOVPublishExecute(TMOVPublishStart('01010'));
    TMOVPublishExecute(TMOVPublishLocalSource(Zeros{6}, '1111'));
    TMOVPublishExecute(TMOVPublishShared(shared_id, '001', '1111'));
    let publish_completed = ExecuteBundleTileOperation();
    assert publish_completed;
    assert SharedTilePublished(shared_id);

    ResetBundleControlState();
    ClearFault();
    TMOVPublishExecute(TMOVPublishStart('01011'));
    TMOVPublishExecute(TMOVPublishShared(shared_id, '000', '1111'));
    TMOVPublishExecute(TMOVPublishLocalDestination('01', '1111'));
    let broadcast_completed = ExecuteBundleTileOperation();
    assert broadcast_completed;
    assert _Tiles[[16]].allocated;
    assert _Tiles[[16]].payload[[0]] == Zeros{PTO_XLEN} + 0x5a;
    assert SharedTilePublished(shared_id);
    return 0;
end;
