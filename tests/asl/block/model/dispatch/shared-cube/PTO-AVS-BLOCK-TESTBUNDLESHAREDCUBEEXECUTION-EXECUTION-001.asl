// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTBUNDLESHAREDCUBEEXECUTION-EXECUTION-001","source":"asl/block/model/dispatch/shared-cube.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for TestBundleSharedCubeExecution","pass_condition":"TestBundleSharedCubeExecution completes without assertion failure","related_sources":[]}
pure func BundleTestTEPLStart(selector: bits(10), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BundleTestCUBEStart(function: bits(5), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[24:20] = function;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BundleTestNamedMxStart(function: integer {4..22},
                                 data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64};
    case function of
        when 4 => instruction = Zeros{64} + 0x00431181;
        when 5 => instruction = Zeros{64} + 0x00531181;
        when 6 => instruction = Zeros{64} + 0x00631181;
        when 20 => instruction = Zeros{64} + 0x01431181;
        when 21 => instruction = Zeros{64} + 0x01531181;
        when 22 => instruction = Zeros{64} + 0x01631181;
        otherwise => unreachable;
    end;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BundleTestTileBindingV5(tile_size: bits(3), destination: bits(2),
                                 pe_mask: bits(4), source0: bits(6),
                                 last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = tile_size;
    instruction[8:7] = destination;
    instruction[18:15] = pe_mask;
    instruction[25:20] = source0;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

pure func BundleTestTwoSourceDestinationV5(
    tile_size: bits(3), destination: bits(2), pe_mask: bits(4),
    source0: bits(6), source1: bits(6), last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[11:9] = tile_size;
    instruction[8:7] = destination;
    instruction[18:15] = pe_mask;
    instruction[25:20] = source0;
    instruction[31:26] = source1;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

pure func BundleTestSharedBinding(shared_id: bits(8)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = '1111';
    instruction[11:9] = '000';
    return instruction;
end;

pure func BundleTestSharedBindingV6(shared_id: bits(8),
                                   tile_size: bits(3),
                                   pe_mask: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = pe_mask;
    instruction[11:9] = tile_size;
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

pure func BundleTestTileDestinationV5(tile_size: bits(3),
                                      destination: bits(2),
                                      pe_mask: bits(4), last: boolean)
                                      => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[11:9] = tile_size;
    instruction[8:7] = destination;
    instruction[18:15] = pe_mask;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

func TestBundleSharedCubeExecution()
begin
    // All-zero Shared and Local predicates are a strict no-op. They do not
    // require source descriptors, allocate the destination, or consume either
    // binding stream.
    ResetProfileState();
    let zero_start = ExecuteCommandInstruction(
        BundleTestCUBEStart('00000', Zeros{5} + 24), 32);
    let zero_shared = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{8} + 31, '000', Zeros{4}), 32);
    let zero_local = ExecuteCommandInstruction(
        BundleTestTileBindingV5('001', '00', Zeros{4}, Zeros{6}, TRUE), 32);
    let zero_unused_ior = ExecuteCommandInstruction(
        BundleTestScalarBinding(Zeros{5}, Zeros{5} + 2, Zeros{5}, Zeros{5}), 32);
    assert zero_start == CommandExecution_Executed;
    assert zero_shared == CommandExecution_Executed;
    assert zero_local == CommandExecution_Executed;
    assert zero_unused_ior == CommandExecution_Executed;
    let zero_completed = ExecuteBundleTileOperation();
    assert zero_completed;
    assert _LastFault == Fault_None;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;

    // A participating Shared CUBE operation rejects a nonzero unused B.IOR
    // before consuming the Shared source or allocating the destination.
    ResetProfileState();
    ConfigureTile(0, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 6);
    var invalid_right = _Tiles[[0]];
    invalid_right.payload[[0]] = Zeros{PTO_XLEN} + 7;
    InstallSharedTile(Zeros{8} + 30, invalid_right, '1111');
    let invalid_start = ExecuteCommandInstruction(
        BundleTestCUBEStart('00000', Zeros{5} + 24), 32);
    let invalid_bind_right = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 30), 32);
    let invalid_local_a_and_d = ExecuteCommandInstruction(
        BundleTestTileBindingV5('001', '00', '1111', Zeros{6}, TRUE), 32);
    let invalid_ior = ExecuteCommandInstruction(
        BundleTestScalarBinding(Zeros{5}, Zeros{5} + 2, Zeros{5}, Zeros{5}), 32);
    assert invalid_start == CommandExecution_Executed;
    assert invalid_bind_right == CommandExecution_Executed;
    assert invalid_local_a_and_d == CommandExecution_Executed;
    assert invalid_ior == CommandExecution_Executed;
    let invalid_completed = ExecuteBundleTileOperation();
    assert !invalid_completed;
    assert _LastFault == Fault_BundleControl;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;

    ResetProfileState();
    ConfigureTile(0, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 6);
    var right = _Tiles[[0]];
    right.payload[[0]] = Zeros{PTO_XLEN} + 7;
    InstallSharedTile(Zeros{8} + 31, right, '1111');
    let start = ExecuteCommandInstruction(
        BundleTestCUBEStart('00000', Zeros{5} + 24), 32);
    let bind_right = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 31), 32);
    let local_a_and_d = ExecuteCommandInstruction(
        BundleTestTileBindingV5('001', '00', '1111', Zeros{6}, TRUE), 32);
    let zero_ior = ExecuteCommandInstruction(
        BundleTestScalarBinding(Zeros{5}, Zeros{5}, Zeros{5}, Zeros{5}), 32);
    assert start == CommandExecution_Executed;
    assert bind_right == CommandExecution_Executed;
    assert local_a_and_d == CommandExecution_Executed;
    assert zero_ior == CommandExecution_Executed;
    let cooperative_completed = ExecuteBundleTileOperation();
    assert cooperative_completed;
    assert _BundleSharedBindings[[0]].consumed;
    assert _Tiles[[1]].allocated;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 42;

    // Two non-MX binders mean Left,Right and remove both from Local B.IOT.
    ResetProfileState();
    ConfigureTile(10, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 3);
    var shared_left = _Tiles[[10]];
    var shared_right = _Tiles[[10]];
    shared_left.payload[[0]] = Zeros{PTO_XLEN} + 4;
    shared_right.payload[[0]] = Zeros{PTO_XLEN} + 5;
    InstallSharedTile(Zeros{8} + 40, shared_left, '1111');
    InstallSharedTile(Zeros{8} + 41, shared_right, '1111');
    let both_start = ExecuteCommandInstruction(
        BundleTestCUBEStart('00000', Zeros{5} + 24), 32);
    let bind_left = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 40), 32);
    let bind_second_right = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 41), 32);
    let only_destination = ExecuteCommandInstruction(
        BundleTestTileDestinationV5('001', '00', '1111', TRUE), 32);
    assert both_start == CommandExecution_Executed;
    assert bind_left == CommandExecution_Executed;
    assert bind_second_right == CommandExecution_Executed;
    assert only_destination == CommandExecution_Executed;
    let shared_pair_completed = ExecuteBundleTileOperation();
    assert shared_pair_completed;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 20;

    // MX with two binders maps Shared Right,ScaleRight after Local
    // Left,ScaleLeft.
    ResetProfileState();
    ConfigureTile(0, 512, 1, 1, 1, 1, TileDataType_E4M3,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 512, 1, 1, 1, 1, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(10, 512, 1, 1, 1, 1, TileDataType_E5M2,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(11, 512, 1, 1, 1, 1, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    InstallSharedTile(Zeros{8} + 42, _Tiles[[10]], '1111');
    InstallSharedTile(Zeros{8} + 43, _Tiles[[11]], '1111');
    let mx_two_start = ExecuteCommandInstruction(
        BundleTestNamedMxStart(4, Zeros{5} + 1), 32);
    let mx_bind_right = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 42), 32);
    let mx_bind_right_scale = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 43), 32);
    let mx_local_pair = ExecuteCommandInstruction(
        BundleTestTwoSourceDestinationV5('001', '10', '1111',
            Zeros{6}, Zeros{6} + 1, TRUE), 32);
    assert mx_two_start == CommandExecution_Executed;
    assert mx_bind_right == CommandExecution_Executed;
    assert mx_bind_right_scale == CommandExecution_Executed;
    assert mx_local_pair == CommandExecution_Executed;
    let mx_two_completed = ExecuteBundleTileOperation();
    assert mx_two_completed;
    let mx_two_destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(mx_two_destination, 0, 0) ==
        Zeros{PTO_XLEN} + 6;

    // MX with four binders uses Left,ScaleLeft,Right,ScaleRight and only a
    // Local destination.
    ResetProfileState();
    ConfigureTile(10, 512, 1, 1, 1, 1, TileDataType_E4M3,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(11, 512, 1, 1, 1, 1, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(12, 512, 1, 1, 1, 1, TileDataType_E5M2,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(13, 512, 1, 1, 1, 1, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(13, 0, 0, Zeros{PTO_XLEN} + 1);
    InstallSharedTile(Zeros{8} + 44, _Tiles[[10]], '1111');
    InstallSharedTile(Zeros{8} + 45, _Tiles[[11]], '1111');
    InstallSharedTile(Zeros{8} + 46, _Tiles[[12]], '1111');
    InstallSharedTile(Zeros{8} + 47, _Tiles[[13]], '1111');
    let mx_four_start = ExecuteCommandInstruction(
        BundleTestNamedMxStart(4, Zeros{5} + 1), 32);
    let mx_bind_left = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 44), 32);
    let mx_bind_left_scale = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 45), 32);
    let mx_bind_second_right = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 46), 32);
    let mx_bind_second_right_scale = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 47), 32);
    let mx_only_destination = ExecuteCommandInstruction(
        BundleTestTileDestinationV5('001', '00', '1111', TRUE), 32);
    assert mx_four_start == CommandExecution_Executed;
    assert mx_bind_left == CommandExecution_Executed;
    assert mx_bind_left_scale == CommandExecution_Executed;
    assert mx_bind_second_right == CommandExecution_Executed;
    assert mx_bind_second_right_scale == CommandExecution_Executed;
    assert mx_only_destination == CommandExecution_Executed;
    let mx_four_completed = ExecuteBundleTileOperation();
    assert mx_four_completed;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 6;

    // TGEMV functions reject every B.IOS binder.
    ResetProfileState();
    let gemv_start = ExecuteCommandInstruction(
        BundleTestCUBEStart('10000', Zeros{5} + 24), 32);
    let gemv_shared = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 50), 32);
    assert gemv_start == CommandExecution_Executed;
    assert gemv_shared == CommandExecution_Executed;
    let gemv_completed = ExecuteBundleTileOperation();
    assert !gemv_completed;
    assert _LastFault == Fault_TileLegality;

    // MX requires exactly Right,ScaleRight or the complete four-binder order.
    ResetProfileState();
    let mx_start = ExecuteCommandInstruction(
        BundleTestNamedMxStart(4, Zeros{5} + 1), 32);
    let mx_one_binder = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 60), 32);
    assert mx_start == CommandExecution_Executed;
    assert mx_one_binder == CommandExecution_Executed;
    let mx_completed = ExecuteBundleTileOperation();
    assert !mx_completed;
    assert _LastFault == Fault_TileLegality;

    // A binder on an unrelated operation is never silently discarded.
    ResetProfileState();
    let tepl_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10}, Zeros{5} + 24), 32);
    let tepl_shared = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 70), 32);
    assert tepl_start == CommandExecution_Executed;
    assert tepl_shared == CommandExecution_Executed;
    let tepl_completed = ExecuteBundleTileOperation();
    assert !tepl_completed;
    assert _LastFault == Fault_TileLegality;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleSharedCubeExecution();
    return 0;
end;
