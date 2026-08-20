// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-STRIDE-001","source":"asl/block/execution/BSTART.TLOAD.asl","requirements":["PTO-INST-BLOCK-BSTART-TLOAD","PTO-INST-TILE-TLOAD"],"kind":"execution","summary":"TLOAD distinguishes explicit, omitted, and encoded-zero byte row strides.","pass_condition":"Explicit B.IOR addresses use RegSrc0/RegSrc1, omission converts LB2 to a dense byte width, and encoded zero aliases rows.","related_sources":["asl/block/model/dispatch/tile-schema.asl","asl/tile/model/memory/load-store.asl"]}
pure func TLoadStrideStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func TLoadStrideDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[11:9] = '001';
    instruction[18:15] = '1111';
    instruction[19] = '1';
    return instruction;
end;

pure func TLoadStrideIOR(source0: bits(5), source1: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    return instruction;
end;

func StartTwoByTwoTLoad(columns: integer {1..65535})
begin
    let start_status = ExecuteCommandInstruction(TLoadStrideStart(), 32);
    assert start_status == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + columns);
    let destination_status = ExecuteCommandInstruction(
        TLoadStrideDestination(), 32);
    assert destination_status == CommandExecution_Executed;
end;

func StartTwoByTwoTLoadWithoutLB2()
begin
    let start_status = ExecuteCommandInstruction(TLoadStrideStart(), 32);
    assert start_status == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let destination_status = ExecuteCommandInstruction(
        TLoadStrideDestination(), 32);
    assert destination_status == CommandExecution_Executed;
end;

func main() => integer
begin
    ResetProfileState();
    _Memory[[0x100]] = Zeros{8} + 1;
    _Memory[[0x104]] = Zeros{8} + 2;
    _Memory[[0x10c]] = Zeros{8} + 3;
    _Memory[[0x110]] = Zeros{8} + 4;
    WriteGPR(2, Zeros{PTO_XLEN} + 0x100);
    WriteGPR(3, Zeros{PTO_XLEN} + 12);
    StartTwoByTwoTLoad(2);
    let explicit_ior_status = ExecuteCommandInstruction(
        TLoadStrideIOR(Zeros{5} + 2, Zeros{5} + 3), 32);
    assert explicit_ior_status == CommandExecution_Executed;
    let explicit_completed = ExecuteBundleTileOperation();
    assert explicit_completed;
    let explicit_tile = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(explicit_tile, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(explicit_tile, 0, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(explicit_tile, 1, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(explicit_tile, 1, 1) == Zeros{PTO_XLEN} + 4;

    ResetProfileState();
    _Memory[[0]] = Zeros{8} + 5;
    _Memory[[4]] = Zeros{8} + 6;
    _Memory[[8]] = Zeros{8} + 7;
    _Memory[[12]] = Zeros{8} + 8;
    StartTwoByTwoTLoadWithoutLB2();
    let omitted_completed = ExecuteBundleTileOperation();
    assert omitted_completed;
    let omitted_tile = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(omitted_tile, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(omitted_tile, 0, 1) == Zeros{PTO_XLEN} + 6;
    assert ReadTileElement(omitted_tile, 1, 0) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(omitted_tile, 1, 1) == Zeros{PTO_XLEN} + 8;

    ResetProfileState();
    _Memory[[0]] = Zeros{8} + 9;
    _Memory[[4]] = Zeros{8} + 10;
    StartTwoByTwoTLoad(4);
    let zero_ior_status = ExecuteCommandInstruction(
        TLoadStrideIOR(Zeros{5}, Zeros{5}), 32);
    assert zero_ior_status == CommandExecution_Executed;
    let zero_completed = ExecuteBundleTileOperation();
    assert zero_completed;
    let zero_tile = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(zero_tile, 0, 0) == Zeros{PTO_XLEN} + 9;
    assert ReadTileElement(zero_tile, 0, 1) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(zero_tile, 1, 0) == Zeros{PTO_XLEN} + 9;
    assert ReadTileElement(zero_tile, 1, 1) == Zeros{PTO_XLEN} + 10;
    return 0;
end;
