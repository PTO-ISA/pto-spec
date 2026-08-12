// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTBUNDLESHAREDTRANSPOSE-STAGE-C-EXECUTION-001","source":"asl/block/model/dispatch/shared-cube.asl","requirements":["PTO-INST-BLOCK-B-FPATR"],"kind":"execution","summary":"decoded complete-bundle Shared transpose controls normalize logical matrices and reject Local-source transpose","pass_condition":"transpose result, reserved-bit rejection, and no-effect fault assertions hold","related_sources":[]}
pure func BundleTestFPATRTranspose(trans_a: boolean, trans_b: boolean)
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00002023;
    instruction[7] = if trans_a then '1' else '0';
    instruction[8] = if trans_b then '1' else '0';
    return instruction;
end;

pure func BundleTestStageCCUBEStart() => bits(64)
begin
    return Zeros{64} + 0x00031181 + LSL(Zeros{64} + 24, 27);
end;

pure func BundleTestStageCSharedBinding(shared_id: bits(8)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = '1111';
    instruction[11:9] = '000';
    return instruction;
end;

pure func BundleTestFPATRReserved() => bits(64)
begin
    return (Zeros{64} + 0x00002023) OR (Zeros{64} + 0x00000200);
end;

pure func BundleTestStageCTileDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[11:9] = '001';
    instruction[8:7] = '00';
    instruction[18:15] = '1111';
    instruction[19] = '1';
    return instruction;
end;

func TestDecodedSharedTranspose()
begin
    ResetProfileState();
    ConfigureTile(10, 512, 2, 2, 2, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(10, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(10, 1, 1, Zeros{PTO_XLEN} + 4);
    var left = _Tiles[[10]];
    ConfigureTile(11, 512, 2, 2, 2, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 6);
    WriteTileElement(11, 1, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(11, 1, 1, Zeros{PTO_XLEN} + 8);
    InstallSharedTile(Zeros{8} + 60, left, '1111');
    InstallSharedTile(Zeros{8} + 61, _Tiles[[11]], '1111');
    assert ExecuteCommandInstruction(
        BundleTestStageCCUBEStart(), 32) ==
        CommandExecution_Executed;
    assert ExecuteCommandInstruction(BundleTestFPATRTranspose(TRUE, FALSE), 32) ==
        CommandExecution_Executed;
    assert ExecuteCommandInstruction(BundleTestStageCSharedBinding(Zeros{8} + 60), 32) ==
        CommandExecution_Executed;
    assert ExecuteCommandInstruction(BundleTestStageCSharedBinding(Zeros{8} + 61), 32) ==
        CommandExecution_Executed;
    assert ExecuteCommandInstruction(BundleTestStageCTileDestination(), 32) ==
        CommandExecution_Executed;
    assert ExecuteBundleTileOperation();
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 26;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 30;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 38;
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 44;

    // A transpose bit on Local A is rejected before allocation or consume.
    ResetProfileState();
    ConfigureTile(10, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 2);
    InstallSharedTile(Zeros{8} + 62, _Tiles[[10]], '1111');
    assert ExecuteCommandInstruction(
        BundleTestStageCCUBEStart(), 32) ==
        CommandExecution_Executed;
    assert ExecuteCommandInstruction(BundleTestFPATRTranspose(TRUE, FALSE), 32) ==
        CommandExecution_Executed;
    assert ExecuteCommandInstruction(BundleTestStageCSharedBinding(Zeros{8} + 62), 32) ==
        CommandExecution_Executed;
    assert ExecuteCommandInstruction(BundleTestStageCTileDestination(), 32) ==
        CommandExecution_Executed;
    assert !ExecuteBundleTileOperation();
    assert _LastFault == Fault_TileLegality;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;

    // Bits 10:9 remain reserved and are rejected by decoded command matching.
    ResetProfileState();
    assert ExecuteCommandInstruction(BundleTestFPATRReserved(), 32) ==
        CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
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
    return 0;
end;
