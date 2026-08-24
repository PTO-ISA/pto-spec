// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-RANGE-FAULTS-001","source":"asl/block/model/operands/shared-generation.asl","requirements":["PTO-B-ASSEMBLE-SHARED-GENERATION-001"],"kind":"fault","summary":"Shared generation overlap and incomplete LAST reject before publication.","pass_condition":"A second writer overlapping INIT and a LAST missing required coverage each raise TileLegality, clear the pending generation, and preserve the prior published Sx value.","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/dispatch/tile-execution.asl"]}
pure func SharedFaultStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func SharedFaultBIOS() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 8;
    instruction[18:15] = '0001';
    instruction[11:9] = '111';
    return instruction;
end;

pure func SharedFaultAssemble(init: boolean, last: boolean,
                              offset: integer,
                              parent_size: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[30:20] = Zeros{11} + offset;
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + parent_size;
    return instruction;
end;

func ExecuteSharedFaultWriter(init: boolean, last: boolean,
                              offset: integer, parent_size: integer,
                              value: integer) => boolean
begin
    _Memory[[0]] = Zeros{8} + value;
    let started = ExecuteCommandInstruction(SharedFaultStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 128);
    let binder = ExecuteCommandInstruction(SharedFaultBIOS(), 32);
    let modifier = ExecuteCommandInstruction(
        SharedFaultAssemble(init, last, offset, parent_size), 32);
    assert binder == CommandExecution_Executed;
    assert modifier == CommandExecution_Executed;
    return ExecuteBundleTileOperation();
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 128, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x55);
    InstallSharedTile((Zeros{6} + 8) as SharedTileID,
        _Tiles[[0]], '1111');

    let first = ExecuteSharedFaultWriter(TRUE, FALSE, 0, 2, 0x11);
    assert first && _LastFault == Fault_None;
    ClearBundleHeaderState();
    let overlap = ExecuteSharedFaultWriter(FALSE, TRUE, 0, 0, 0x22);
    assert !overlap && _LastFault == Fault_TileLegality;
    let shared_tile_id = (Zeros{6} + 8) as SharedTileID;
    assert !BundleSharedGenerationOpen(shared_tile_id);
    assert ReadSharedTileWord(shared_tile_id, 0) ==
        Zeros{PTO_XLEN} + 0x55;

    ResetProfileState();
    ConfigureTile(0, 128, 128, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x55);
    InstallSharedTile(shared_tile_id, _Tiles[[0]], '1111');
    let incomplete = ExecuteSharedFaultWriter(TRUE, TRUE, 0, 2, 0x33);
    assert !incomplete && _LastFault == Fault_TileLegality;
    assert ReadSharedTileWord(shared_tile_id, 0) ==
        Zeros{PTO_XLEN} + 0x55;
    return 0;
end;
