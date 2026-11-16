// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-ND-TO-CUBE-BINDING-ROLES-001","source":"asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","requirements":["PTO-TMOV-SHARED-ND-TO-CUBE-001","PTO-BSTART-TMOV-SHARED-001","PTO-B-IOS-SHARED-STATE-001"],"kind":"fault","summary":"reverse TMOV requires one Shared source and one new Local destination with no Local source","pass_condition":"decoded Layout-21 requests reject both the inverted Shared-destination/Local-source roles and a bundle with two Shared sources before Local allocation or Shared generation mutation","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","asl/block/model/operands/shared-bindings.asl","asl/block/model/operands/tile-bindings.asl"]}

pure func SharedNDToCubeRoleStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func SharedNDToCubeRoleDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = Zeros{5} + 31;
    instruction[11:7] = Zeros{5} + 21;
    return instruction;
end;

pure func SharedNDToCubeRoleShared(shared_id: bits(6),
    size_code: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = size_code;
    instruction[11:9] = '001';
    return instruction;
end;

pure func SharedNDToCubeRoleLocalSource(tile: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = tile;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func SharedNDToCubeRoleLocalDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = Zeros{4} + 6;
    instruction[8:7] = '10';
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func SharedNDToCubeRoleValue(row: integer {0..31},
    column: integer {0..127}) => Word
begin
    return Zeros{PTO_XLEN} + 1 + row * 73 + column * 29 +
        ((row * column) MOD 101);
end;

func SetupSharedNDToCubeRoleSource(shared_id: SharedTileID)
begin
    ConfigureTileForMask(10, 4096, 32, 128, 32, 128,
        TileDataType_U8, TileLayout_RowMajor, '1000');
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 127 looplimit 128 do
            WriteTileElement(10, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeRoleValue(row as integer {0..31},
                    column as integer {0..127}));
        end;
    end;
    InstallSharedTile(shared_id, _Tiles[[10]], '1000');
    assert SharedTilePublished(shared_id);
end;

func RunSharedDestinationAndLocalSourceRole() => boolean
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x800);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0x800);
    let configured = ConfigureCubeTileForMask(10, 4096, 32, 128,
        TileDataType_U8, TileLayout_CUBE_M32, '1000');
    assert configured;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 127 looplimit 128 do
            WriteTileElement(10, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeRoleValue(row as integer {0..31},
                    column as integer {0..127}));
        end;
    end;
    let shared_id = (Zeros{6} + 36) as SharedTileID;
    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeRoleStart(), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeRoleDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    // This is the forward-direction role pair, deliberately used with 21.
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeRoleShared(shared_id as bits(6), Zeros{4} + 6), 32);
    let local_status = ExecuteCommandInstruction(
        SharedNDToCubeRoleLocalSource(Zeros{6} + 10), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           local_status == CommandExecution_Executed;
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    return stop_status == CommandExecution_Rejected &&
           _LastFault != Fault_None &&
           !_BundleTileBindings[[0]].destination_allocated_by_bundle &&
           !SharedTileRecord(shared_id).descriptor_valid;
end;

func RunMultipleSharedSources() => boolean
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x900);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0x900);
    let first_id = (Zeros{6} + 37) as SharedTileID;
    let second_id = (Zeros{6} + 38) as SharedTileID;
    SetupSharedNDToCubeRoleSource(first_id);
    SetupSharedNDToCubeRoleSource(second_id);
    let first_before = SharedTileRecord(first_id);
    let second_before = SharedTileRecord(second_id);
    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeRoleStart(), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeRoleDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    let first_status = ExecuteCommandInstruction(
        SharedNDToCubeRoleShared(first_id as bits(6), Zeros{4}), 32);
    let second_status = ExecuteCommandInstruction(
        SharedNDToCubeRoleShared(second_id as bits(6), Zeros{4}), 32);
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeRoleLocalDestination(), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           first_status == CommandExecution_Executed &&
           second_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed &&
           !BundleSharedTMOVSharedNDToCubeSchemaLegal();
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    let first_after = SharedTileRecord(first_id);
    let second_after = SharedTileRecord(second_id);
    return stop_status == CommandExecution_Rejected &&
           _LastFault != Fault_None &&
           !_BundleTileBindings[[0]].destination_allocated_by_bundle &&
           first_after.payload_generation == first_before.payload_generation &&
           first_after.payload_live == first_before.payload_live &&
           second_after.payload_generation == second_before.payload_generation &&
           second_after.payload_live == second_before.payload_live;
end;

func main() => integer
begin
    let reversed_roles = RunSharedDestinationAndLocalSourceRole();
    assert reversed_roles;
    let multiple_sources = RunMultipleSharedSources();
    assert multiple_sources;
    return 0;
end;
