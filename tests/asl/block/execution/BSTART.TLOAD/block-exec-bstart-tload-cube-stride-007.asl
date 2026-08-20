// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-CUBE-STRIDE-007","source":"asl/block/execution/BSTART.TLOAD.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001"],"kind":"execution","summary":"CUBE TLOAD distinguishes explicit omitted and encoded-zero byte row stride","pass_condition":"explicit byte stride addresses row gaps omission derives the dense byte width from LB0 and encoded zero aliases logical rows","related_sources":["asl/block/operands/B.IOR.asl","asl/block/model/dispatch/tlsu-layout-conversion.asl"]}
pure func CubeStrideStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func CubeStrideAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 22;
    return instruction;
end;

pure func CubeStrideDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[11:9] = '001';
    instruction[18:15] = '0001';
    instruction[19] = '1';
    return instruction;
end;

pure func CubeStrideIOR(source0: bits(5), source1: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    return instruction;
end;

func StartCubeStrideBlock()
begin
    let start_status = ExecuteCommandInstruction(CubeStrideStart(), 32);
    let datr_status = ExecuteCommandInstruction(CubeStrideAttributes(), 32);
    assert start_status == CommandExecution_Executed;
    assert datr_status == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let destination_status = ExecuteCommandInstruction(
        CubeStrideDestination(), 32);
    assert destination_status == CommandExecution_Executed;
end;

func main() => integer
begin
    ResetProfileState();
    Store(Zeros{PTO_XLEN} + 0x100, 2, Zeros{PTO_XLEN} + 1);
    Store(Zeros{PTO_XLEN} + 0x102, 2, Zeros{PTO_XLEN} + 2);
    Store(Zeros{PTO_XLEN} + 0x106, 2, Zeros{PTO_XLEN} + 3);
    Store(Zeros{PTO_XLEN} + 0x108, 2, Zeros{PTO_XLEN} + 4);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x100);
    WriteGPR(3, Zeros{PTO_XLEN} + 6);
    StartCubeStrideBlock();
    let explicit_ior = ExecuteCommandInstruction(
        CubeStrideIOR(Zeros{5} + 2, Zeros{5} + 3), 32);
    assert explicit_ior == CommandExecution_Executed;
    let explicit_completed = ExecuteBundleTileOperation();
    assert explicit_completed;
    let explicit_tile = _Tiles[[_BundleTileBindings[[0]].destination]];
    assert explicit_tile.payload[[TileStorageIndex(explicit_tile, 1, 0)]] ==
        Zeros{PTO_XLEN} + 3;

    ResetProfileState();
    Store(Zeros{PTO_XLEN}, 2, Zeros{PTO_XLEN} + 5);
    Store(Zeros{PTO_XLEN} + 2, 2, Zeros{PTO_XLEN} + 6);
    Store(Zeros{PTO_XLEN} + 4, 2, Zeros{PTO_XLEN} + 7);
    Store(Zeros{PTO_XLEN} + 6, 2, Zeros{PTO_XLEN} + 8);
    StartCubeStrideBlock();
    let omitted_completed = ExecuteBundleTileOperation();
    assert omitted_completed;
    let omitted_tile = _Tiles[[_BundleTileBindings[[0]].destination]];
    assert omitted_tile.payload[[TileStorageIndex(omitted_tile, 1, 0)]] ==
        Zeros{PTO_XLEN} + 7;

    ResetProfileState();
    Store(Zeros{PTO_XLEN}, 2, Zeros{PTO_XLEN} + 9);
    Store(Zeros{PTO_XLEN} + 2, 2, Zeros{PTO_XLEN} + 10);
    StartCubeStrideBlock();
    let zero_ior = ExecuteCommandInstruction(
        CubeStrideIOR(Zeros{5}, Zeros{5}), 32);
    assert zero_ior == CommandExecution_Executed;
    let zero_completed = ExecuteBundleTileOperation();
    assert zero_completed;
    let zero_tile = _Tiles[[_BundleTileBindings[[0]].destination]];
    assert zero_tile.payload[[TileStorageIndex(zero_tile, 0, 0)]] ==
        zero_tile.payload[[TileStorageIndex(zero_tile, 1, 0)]];
    assert zero_tile.payload[[TileStorageIndex(zero_tile, 0, 1)]] ==
        zero_tile.payload[[TileStorageIndex(zero_tile, 1, 1)]];
    return 0;
end;
