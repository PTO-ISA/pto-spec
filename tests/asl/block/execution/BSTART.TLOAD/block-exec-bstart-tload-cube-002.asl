// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-CUBE-002","source":"asl/block/execution/BSTART.TLOAD.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001","PTO-INST-BLOCK-BSTART-TLOAD","PTO-INST-TILE-TLOAD"],"kind":"execution","summary":"A decoded TLOAD block allocates and fills one persistent Local CUBE_M16 destination","pass_condition":"ND2M16 with explicit valid dimensions publishes the renamed Matrix descriptor and raw FP16 payload only after complete success","related_sources":["asl/block/model/dispatch/tlsu-layout-conversion.asl","asl/tile/model/memory/load-store.asl"]}
pure func CubeTLoadStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func CubeTLoadDataAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 22;
    instruction[28:27] = '01';
    return instruction;
end;

pure func CubeTLoadDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[11:9] = '001';
    instruction[18:15] = '0001';
    instruction[19] = '1';
    instruction[8:7] = '10';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    for element = 0 to 5 do
        Store(Zeros{PTO_XLEN} + element * 2,
            2, Zeros{PTO_XLEN} + element + 1);
    end;
    let start_status = ExecuteCommandInstruction(CubeTLoadStart(), 32);
    assert start_status == CommandExecution_Executed;
    let datr_status = ExecuteCommandInstruction(
        CubeTLoadDataAttributes(), 32);
    assert datr_status == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let destination_status = ExecuteCommandInstruction(
        CubeTLoadDestination(), 32);
    assert destination_status == CommandExecution_Executed;

    let completed = ExecuteBundleTileOperation();

    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    let tile = _Tiles[[destination]];
    assert _BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert tile.layout == TileLayout_CUBE_M16;
    assert tile.location == TileLocation_Matrix;
    assert tile.rows == 16 && tile.columns == 4;
    assert tile.valid_rows == 2 && tile.valid_columns == 3;
    assert tile.payload[[TileStorageIndex(tile, 0, 0)]] ==
        Zeros{PTO_XLEN} + 1;
    assert tile.payload[[TileStorageIndex(tile, 1, 2)]] ==
        Zeros{PTO_XLEN} + 6;
    let tail = TileStorageIndex(tile, 2, 0);
    assert tile.payload[[tail]] == Zeros{PTO_XLEN} + 0x7bff;
    assert tile.defined_elements[tail] == '1';
    return 0;
end;
