// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TSTORE-MASK-LEGALITY-001","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":["PTO-ARCH-GM-ACCESS-001","PTO-INST-TILE-TSTORE"],"kind":"fault","summary":"Shared TSTORE Function 1 is full-PE only while Function 14 accepts a nonzero subset.","pass_condition":"A nonzero partial mask rejects Function 1 before memory effects and executes only under Function 14.","related_sources":["asl/tile/model/memory/shared-movement.asl"]}
pure func StoreMaskTestTLSUStart(function: bits(5), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = function;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func StoreMaskTestSharedBinding(shared_id: bits(8), pe_mode: bits(3))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = pe_mode;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 16, 1, 16, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x5a);
    InstallSharedTile(Zeros{8} + 9, _Tiles[[0]], '1000');

    let full_start = ExecuteCommandInstruction(
        StoreMaskTestTLSUStart('00001', Zeros{5} + 24), 32);
    let full_shared = ExecuteCommandInstruction(
        StoreMaskTestSharedBinding(Zeros{8} + 9, '001'), 32);
    assert full_start == CommandExecution_Executed;
    assert full_shared == CommandExecution_Executed;
    let full_completed = ExecuteBundleTileOperation();
    assert !full_completed;
    assert _LastFault == Fault_TileLegality;
    assert _Memory[[0]] == Zeros{8};

    ResetBundleControlState();
    ClearFault();
    let partial_start = ExecuteCommandInstruction(
        StoreMaskTestTLSUStart('01110', Zeros{5} + 24), 32);
    let partial_shared = ExecuteCommandInstruction(
        StoreMaskTestSharedBinding(Zeros{8} + 9, '001'), 32);
    assert partial_start == CommandExecution_Executed;
    assert partial_shared == CommandExecution_Executed;
    let partial_completed = ExecuteBundleTileOperation();
    assert partial_completed;
    assert _LastFault == Fault_None;
    assert _Memory[[0]] == Zeros{8} + 0x5a;
    return 0;
end;
