// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TLSU-GM-EXEC-001","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":[],"kind":"execution","summary":"Shared TLSU loads and stores use per-PE size and LB stride defaults","pass_condition":"GM-to-Shared, Shared-to-GM, and LB2 stride assertions hold","related_sources":[]}
pure func BundleTestTLSUStart(function: bits(5), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = function;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BundleTestTileBindingV5(size_code: bits(4), destination: bits(2),
                                 pe_mode: bits(3), source0: bits(6),
                                 last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[18:15] = size_code;
    instruction[8:7] = destination;
    instruction[11:9] = pe_mode;
    instruction[25:20] = source0;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

pure func BundleTestSharedBinding(shared_id: bits(8)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = '0000';
    instruction[11:9] = '111';
    return instruction;
end;

pure func BundleTestSharedBindingV6(shared_id: bits(8),
                                   size_code: bits(4),
                                   pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    return instruction;
end;

pure func BundleTestScalarBinding(destination: bits(5), source0: bits(5),
                                  source1: bits(5), source2: bits(5))
                                  => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[11:7] = destination;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    instruction[31:27] = source2;
    return instruction;
end;

pure func BundleTestTileDestinationV5(size_code: bits(4),
                                      destination: bits(2),
                                      pe_mode: bits(3), last: boolean)
                                      => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[8:7] = destination;
    instruction[11:9] = pe_mode;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

func TestBundleSharedTLSUGlobalMemory()
begin
    // GM-to-Shared takes its per-PE size and mask from destination B.IOS.
    ResetProfileState();
    _Memory[[0]] = Zeros{8} + 0x2a;
    WriteGPR(2, Zeros{PTO_XLEN});
    let load_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00000', Zeros{5} + 24), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let load_shared = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{8} + 17, '0001', '111'), 32);
    let load_address = ExecuteCommandInstruction(
        BundleTestScalarBinding('00000', '00010', '00000', '00000'), 32);
    assert load_start == CommandExecution_Executed;
    assert load_shared == CommandExecution_Executed;
    assert load_address == CommandExecution_Executed;
    let load_completed = ExecuteBundleTileOperation();
    assert load_completed;
    assert _BundleSharedBindings[[0]].consumed;
    assert SharedTileFullyInitialized(Zeros{8} + 17);
    assert SharedTileRecord(Zeros{8} + 17).tile.capacity_bytes == 128;
    assert SharedTileRecord(Zeros{8} + 17).tile.payload[[0]] ==
        Zeros{PTO_XLEN} + 0x2a;

    // An unmasked Shared store reads all four quarters.
    ResetBundleControlState();
    WriteGPR(2, Zeros{PTO_XLEN} + 8);
    let store_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00001', Zeros{5} + 24), 32);
    let store_shared = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 17), 32);
    let store_address = ExecuteCommandInstruction(
        BundleTestScalarBinding('00000', '00010', '00000', '00000'), 32);
    assert store_start == CommandExecution_Executed;
    assert store_shared == CommandExecution_Executed;
    assert store_address == CommandExecution_Executed;
    let store_completed = ExecuteBundleTileOperation();
    assert store_completed;
    assert _Memory[[8]] == Zeros{8} + 0x2a;

    // Shared TSTORE takes an explicit byte stride from B.IOR.  The Shared
    // descriptor still supplies the physical column count independently.
    ResetProfileState();
    ConfigureTile(0, 128, 2, 2, 2, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 4);
    InstallSharedTile(Zeros{8} + 18, _Tiles[[0]], '1111');
    let lb2_store_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00001', Zeros{5} + 24), 32);
    WriteGPR(2, Zeros{PTO_XLEN});
    WriteGPR(3, Zeros{PTO_XLEN} + 24);
    let lb2_store_shared = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 18), 32);
    let lb2_store_address = ExecuteCommandInstruction(
        BundleTestScalarBinding(
            Zeros{5},
            Zeros{5} + 2,
            Zeros{5} + 3,
            Zeros{5}), 32);
    assert lb2_store_start == CommandExecution_Executed;
    assert lb2_store_shared == CommandExecution_Executed;
    assert lb2_store_address == CommandExecution_Executed;
    let lb2_store_completed = ExecuteBundleTileOperation();
    assert lb2_store_completed;
    assert _Memory[[0]] == Zeros{8} + 1;
    assert _Memory[[8]] == Zeros{8} + 2;
    assert _Memory[[24]] == Zeros{8} + 3;
    assert _Memory[[32]] == Zeros{8} + 4;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleSharedTLSUGlobalMemory();
    return 0;
end;
