// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TSTORE-MASK-LEGALITY-001","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":["PTO-ARCH-GM-ACCESS-001","PTO-INST-TILE-TSTORE"],"kind":"fault","summary":"Canonical Function 1 accepts partial Shared consumers and reserved Function 31 rejects.","pass_condition":"A one-PE Function 1 store writes the complete parent through that PE while Function 31 rejects at decode before memory effects.","related_sources":["asl/tile/model/memory/shared-movement.asl"]}
pure func StoreMaskTestTLSUStart(function: bits(5), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = function;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func StoreMaskTestSharedBinding(shared_tile_id: bits(6), pe_mode: bits(3))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = pe_mode;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 16, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x5a);
    InstallSharedTile((Zeros{6} + 9) as SharedTileID, _Tiles[[0]], '1000');

    let full_start = ExecuteCommandInstruction(
        StoreMaskTestTLSUStart('00001', Zeros{5} + 24), 32);
    let full_shared = ExecuteCommandInstruction(
        StoreMaskTestSharedBinding(Zeros{6} + 9, '001'), 32);
    assert full_start == CommandExecution_Executed;
    assert full_shared == CommandExecution_Executed;
    let full_completed = ExecuteBundleTileOperation();
    assert full_completed;
    assert _LastFault == Fault_None;
    assert _Memory[[0]] == Zeros{8} + 0x5a;

    ResetBundleControlState();
    ClearFault();
    _Memory[[0]] = Zeros{8};
    let retired_start = ExecuteCommandInstruction(
        StoreMaskTestTLSUStart('11111', Zeros{5} + 24), 32);
    assert retired_start == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert !_BundleActive;
    assert _Memory[[0]] == Zeros{8};
    return 0;
end;
