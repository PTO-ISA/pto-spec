// PTO-TEST: {"id":"PTO-AVS-BLOCK-SUBVIEW-SHARED-001","source":"asl/block/model/operands/shared-generation.asl","requirements":["PTO-B-SUBVIEW-RANGE-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001"],"kind":"execution","summary":"Decoded Shared B.SUBVIEW selects an exact CELL range for TSTORE.","pass_condition":"A one-CELL view at offset one stores the second 128 B row's value while preserving the complete published Shared descriptor and payload.","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/operands/B.SUBVIEW.asl"]}
pure func SharedSubviewStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func SharedSubviewBIOS() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 9;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    return instruction;
end;

pure func SharedSubviewModifier() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000053;
    instruction[30:20] = Zeros{11} + 1;
    instruction[10:7] = '0001';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 256, 2, 128, 2, 128, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    for column = 0 to 127 do
        WriteTileElement(0, 0, column, Zeros{PTO_XLEN} + 0x11);
        WriteTileElement(0, 1, column, Zeros{PTO_XLEN} + 0x22);
    end;
    let shared_tile_id = (Zeros{6} + 9) as SharedTileID;
    InstallSharedTile(shared_tile_id, _Tiles[[0]], '1111');
    let before = SharedTileRecord(shared_tile_id);

    let started = ExecuteCommandInstruction(SharedSubviewStart(), 32);
    let binder = ExecuteCommandInstruction(SharedSubviewBIOS(), 32);
    let modifier = ExecuteCommandInstruction(SharedSubviewModifier(), 32);
    assert started == CommandExecution_Executed;
    assert binder == CommandExecution_Executed;
    assert modifier == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    assert _Memory[[0]] == Zeros{8} + 0x22;
    let after = SharedTileRecord(shared_tile_id);
    assert after.tile.capacity_bytes == before.tile.capacity_bytes;
    assert after.tile.payload[[0]] == before.tile.payload[[0]];
    assert after.tile.payload[[128]] == before.tile.payload[[128]];
    return 0;
end;
