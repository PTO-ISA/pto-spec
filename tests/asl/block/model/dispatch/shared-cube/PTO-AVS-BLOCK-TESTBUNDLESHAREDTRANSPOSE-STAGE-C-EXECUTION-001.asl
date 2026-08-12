// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTBUNDLESHAREDTRANSPOSE-STAGE-C-EXECUTION-001","source":"asl/block/model/dispatch/shared-cube.asl","requirements":["PTO-INST-BLOCK-B-FPATR"],"kind":"execution","summary":"decoded complete-bundle Shared transpose controls normalize logical matrices and reject Local-source transpose","pass_condition":"transpose result, reserved-bit rejection, and no-effect fault assertions hold","related_sources":[]}
pure func BundleTestFPATRTranspose(trans_a: boolean, trans_b: boolean)
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00002023;
    instruction[7] = if trans_a then '1' else '0';
    instruction[8] = if trans_b then '1' else '0';
    return instruction;
end;

pure func BundleTestDim(role: bits(2), value: integer {0..131071})
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64};
    case UInt(role) of
        when 0 => instruction = Zeros{64} + 0x00000043;
        when 1 => instruction = Zeros{64} + 0x00001043;
        when 2 => instruction = Zeros{64} + 0x00002043;
        otherwise => unreachable;
    end;
    let immediate = Zeros{64} + value;
    instruction[31:20] = immediate[11:0];
    instruction[11:7] = immediate[16:12];
    return instruction;
end;

pure func BundleTestStageCCUBEStart() => bits(64)
begin
    return Zeros{64} + 0x00031181 + LSL(Zeros{64} + 1, 27);
end;

pure func BundleTestStageCSharedBinding(shared_id: bits(8)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = '1111';
    instruction[11:9] = '000';
    return instruction;
end;

pure func BundleTestStageCLocalSource(source0: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[18:15] = '1111';
    instruction[25:20] = source0;
    instruction[19] = '1';
    return instruction;
end;

pure func BundleTestFPATRReserved() => bits(64)
begin
    return (Zeros{64} + 0x00002023) OR (Zeros{64} + 0x00000200);
end;

pure func BundleTestStageCTileDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[11:9] = '010';
    instruction[8:7] = '00';
    instruction[18:15] = '1111';
    instruction[19] = '1';
    return instruction;
end;

func TestDecodedSharedTranspose()
begin
    ResetProfileState();
    ConfigureTile(10, 512, 2, 2, 2, 2, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(10, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(10, 1, 1, Zeros{PTO_XLEN} + 4);
    var left = _Tiles[[10]];
    ConfigureTile(11, 512, 2, 2, 2, 2, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 6);
    WriteTileElement(11, 1, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(11, 1, 1, Zeros{PTO_XLEN} + 8);
    InstallSharedTile(Zeros{8} + 60, left, '1111');
    InstallSharedTile(Zeros{8} + 61, _Tiles[[11]], '1111');
    let transpose_command_status_1 = ExecuteCommandInstruction(
        BundleTestStageCCUBEStart(), 32);
    assert transpose_command_status_1 == CommandExecution_Executed;
    let transpose_command_status_2 = ExecuteCommandInstruction(
        BundleTestFPATRTranspose(TRUE, FALSE), 32);
    assert transpose_command_status_2 == CommandExecution_Executed;
    let transpose_command_status_2a = ExecuteCommandInstruction(
        BundleTestDim('00', 2), 32);
    assert transpose_command_status_2a == CommandExecution_Executed;
    let transpose_command_status_2b = ExecuteCommandInstruction(
        BundleTestDim('01', 2), 32);
    assert transpose_command_status_2b == CommandExecution_Executed;
    let transpose_command_status_2c = ExecuteCommandInstruction(
        BundleTestDim('10', 2), 32);
    assert transpose_command_status_2c == CommandExecution_Executed;
    let transpose_command_status_3 = ExecuteCommandInstruction(
        BundleTestStageCSharedBinding(Zeros{8} + 60), 32);
    assert transpose_command_status_3 == CommandExecution_Executed;
    let transpose_command_status_4 = ExecuteCommandInstruction(
        BundleTestStageCSharedBinding(Zeros{8} + 61), 32);
    assert transpose_command_status_4 == CommandExecution_Executed;
    let transpose_command_status_5 = ExecuteCommandInstruction(
        BundleTestStageCTileDestination(), 32);
    assert transpose_command_status_5 == CommandExecution_Executed;
    let transpose_operation_status_1 = ExecuteBundleTileOperation();
    assert transpose_operation_status_1;
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 26;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 30;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 38;
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 44;

    // A transpose bit on Local A is rejected before allocation or consume.
    ResetProfileState();
    ConfigureTile(10, 512, 1, 1, 1, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 2);
    InstallSharedTile(Zeros{8} + 62, _Tiles[[10]], '1111');
    let transpose_command_status_6 = ExecuteCommandInstruction(
        BundleTestStageCCUBEStart(), 32);
    assert transpose_command_status_6 == CommandExecution_Executed;
    let transpose_command_status_7 = ExecuteCommandInstruction(
        BundleTestFPATRTranspose(TRUE, FALSE), 32);
    assert transpose_command_status_7 == CommandExecution_Executed;
    let transpose_command_status_7a = ExecuteCommandInstruction(
        BundleTestDim('00', 1), 32);
    assert transpose_command_status_7a == CommandExecution_Executed;
    let transpose_command_status_7b = ExecuteCommandInstruction(
        BundleTestDim('01', 1), 32);
    assert transpose_command_status_7b == CommandExecution_Executed;
    let transpose_command_status_7c = ExecuteCommandInstruction(
        BundleTestDim('10', 1), 32);
    assert transpose_command_status_7c == CommandExecution_Executed;
    let transpose_command_status_7d = ExecuteCommandInstruction(
        BundleTestStageCLocalSource(Zeros{6} + 10), 32);
    assert transpose_command_status_7d == CommandExecution_Executed;
    let transpose_command_status_8 = ExecuteCommandInstruction(
        BundleTestStageCSharedBinding(Zeros{8} + 62), 32);
    assert transpose_command_status_8 == CommandExecution_Executed;
    let transpose_command_status_9 = ExecuteCommandInstruction(
        BundleTestStageCTileDestination(), 32);
    assert transpose_command_status_9 == CommandExecution_Executed;
    let transpose_operation_status_2 = ExecuteBundleTileOperation();
    assert !transpose_operation_status_2;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;

    // Bits 10:9 remain reserved and are rejected by decoded command matching.
    ResetProfileState();
    let transpose_command_status_10 = ExecuteCommandInstruction(
        BundleTestFPATRReserved(), 32);
    assert transpose_command_status_10 == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
end;

func TestDecodedSharedTransposeCase(trans_a: boolean, trans_b: boolean,
                                    expected00: Word, expected01: Word,
                                    expected10: Word, expected11: Word)
begin
    ResetProfileState();
    ConfigureTile(10, 512, 2, 2, 2, 2, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(10, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(10, 1, 1, Zeros{PTO_XLEN} + 4);
    InstallSharedTile(Zeros{8} + 64, _Tiles[[10]], '1111');
    ConfigureTile(11, 512, 2, 2, 2, 2, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 6);
    WriteTileElement(11, 1, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(11, 1, 1, Zeros{PTO_XLEN} + 8);
    InstallSharedTile(Zeros{8} + 65, _Tiles[[11]], '1111');
    let transpose_command_status_11 = ExecuteCommandInstruction(
        BundleTestStageCCUBEStart(), 32);
    assert transpose_command_status_11 == CommandExecution_Executed;
    let transpose_command_status_12 = ExecuteCommandInstruction(
        BundleTestFPATRTranspose(trans_a, trans_b), 32);
    assert transpose_command_status_12 == CommandExecution_Executed;
    let transpose_command_status_12a = ExecuteCommandInstruction(
        BundleTestDim('00', 2), 32);
    assert transpose_command_status_12a == CommandExecution_Executed;
    let transpose_command_status_12b = ExecuteCommandInstruction(
        BundleTestDim('01', 2), 32);
    assert transpose_command_status_12b == CommandExecution_Executed;
    let transpose_command_status_12c = ExecuteCommandInstruction(
        BundleTestDim('10', 2), 32);
    assert transpose_command_status_12c == CommandExecution_Executed;
    let transpose_command_status_13 = ExecuteCommandInstruction(
        BundleTestStageCSharedBinding(Zeros{8} + 64), 32);
    assert transpose_command_status_13 == CommandExecution_Executed;
    let transpose_command_status_14 = ExecuteCommandInstruction(
        BundleTestStageCSharedBinding(Zeros{8} + 65), 32);
    assert transpose_command_status_14 == CommandExecution_Executed;
    let transpose_command_status_15 = ExecuteCommandInstruction(
        BundleTestStageCTileDestination(), 32);
    assert transpose_command_status_15 == CommandExecution_Executed;
    let transpose_operation_status_3 = ExecuteBundleTileOperation();
    assert transpose_operation_status_3;
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) == expected00;
    assert ReadTileElement(destination, 0, 1) == expected01;
    assert ReadTileElement(destination, 1, 0) == expected10;
    assert ReadTileElement(destination, 1, 1) == expected11;
end;

func main() => integer
begin
    assert TileCubeGroupLayoutForM(1) == TileLayout_CUBE_M16;
    assert TileCubeGroupLayoutForM(64) == TileLayout_CUBE_M16;
    assert TileCubeGroupLayoutForM(65) == TileLayout_CUBE_M32;
    assert TileCubeGroupLayoutForM(128) == TileLayout_CUBE_M32;
    assert TileCubeGroupLayoutForM(0) == TileLayout_ImplementationDefined;
    assert TileCubeGroupLayoutForM(129) == TileLayout_ImplementationDefined;
    assert TileCubeGroupPEValidM(1, 0) == 1;
    assert TileCubeGroupPEValidM(1, 1) == 0;
    assert TileCubeGroupPEValidM(64, 0) == 16;
    assert TileCubeGroupPEValidM(64, 3) == 16;
    assert TileCubeGroupPEValidM(65, 0) == 32;
    assert TileCubeGroupPEValidM(65, 2) == 1;
    assert TileCubeGroupPEValidM(65, 3) == 0;
    assert TileCubeGroupPEValidM(128, 3) == 32;
    TestDecodedSharedTranspose();
    // Decode each independent transpose control, including canonical 0,0
    // and both controls, with asymmetric matrices and exact outputs.
    TestDecodedSharedTransposeCase(FALSE, FALSE,
        Zeros{PTO_XLEN} + 19, Zeros{PTO_XLEN} + 22,
        Zeros{PTO_XLEN} + 43, Zeros{PTO_XLEN} + 50);
    TestDecodedSharedTransposeCase(TRUE, FALSE,
        Zeros{PTO_XLEN} + 26, Zeros{PTO_XLEN} + 30,
        Zeros{PTO_XLEN} + 38, Zeros{PTO_XLEN} + 44);
    TestDecodedSharedTransposeCase(FALSE, TRUE,
        Zeros{PTO_XLEN} + 17, Zeros{PTO_XLEN} + 23,
        Zeros{PTO_XLEN} + 39, Zeros{PTO_XLEN} + 53);
    TestDecodedSharedTransposeCase(TRUE, TRUE,
        Zeros{PTO_XLEN} + 23, Zeros{PTO_XLEN} + 31,
        Zeros{PTO_XLEN} + 34, Zeros{PTO_XLEN} + 46);
    return 0;
end;
