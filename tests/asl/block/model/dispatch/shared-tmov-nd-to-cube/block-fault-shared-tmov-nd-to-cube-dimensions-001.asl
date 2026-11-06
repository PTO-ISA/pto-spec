// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-ND-TO-CUBE-DIMENSIONS-001","source":"asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","requirements":["PTO-TMOV-SHARED-ND-TO-CUBE-001","PTO-B-DIM-WRITE-001","PTO-BUNDLE-DIMENSION-DEFAULT-001"],"kind":"fault","summary":"reverse TMOV keeps LB0/LB1 exact and rejects LB2 zero or non-derived values before allocation","pass_condition":"decoded B.DIM LB0/LB1 mismatches, effective LB2=0, and positive LB2 other than 1 or capacity-derived CUBE columns fault with no CUBE allocation or Shared mutation; duplicate B.DIM/C.B.DIMI writes still raise Fault_BundleControl","related_sources":["asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","asl/block/model/schema/dimensions.asl","asl/block/attributes/B.DIM.asl","asl/block/attributes/C.B.DIMI.asl"]}

pure func SharedNDToCubeDimStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func SharedNDToCubeDimDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = Zeros{5} + 31;
    instruction[11:7] = Zeros{5} + 21;
    return instruction;
end;

pure func SharedNDToCubeDimFull(lb: integer {0..2},
    value: integer {0..4095}) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000043;
    if lb == 1 then instruction = Zeros{64} + 0x00001043;
    elsif lb == 2 then instruction = Zeros{64} + 0x00002043; end;
    instruction[31:20] = Zeros{12} + value;
    return instruction;
end;

pure func SharedNDToCubeDimCompressed(lb: bits(2),
    value: bits(8)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x003c;
    instruction[15:14] = lb;
    instruction[13:6] = value;
    return instruction;
end;

pure func SharedNDToCubeDimShared(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    return instruction;
end;

pure func SharedNDToCubeDimDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = Zeros{4} + 6;
    instruction[8:7] = '10';
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func SharedNDToCubeDimValue(row: integer {0..31},
    column: integer {0..127}) => Word
begin
    return Zeros{PTO_XLEN} + 1 + row * 43 + column * 23 +
        ((row * column) MOD 79);
end;

func RunSharedNDToCubeBadDimensions(lb0: integer {31,127,128},
    lb1: integer {31,32}, lb2: integer {0,64,128},
    lb2_form: integer {0..2}) => boolean
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0xa00);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0xa00);
    ConfigureTileForMask(10, 4096, 32, 128, 32, 128,
        TileDataType_U8, TileLayout_RowMajor, '1000');
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 127 looplimit 128 do
            WriteTileElement(10, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeDimValue(row as integer {0..31},
                    column as integer {0..127}));
        end;
    end;
    let shared_id = (Zeros{6} + 39) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[10]], '1000');
    let source_before = SharedTileRecord(shared_id);
    assert SharedTilePublished(shared_id);

    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeDimStart(), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeDimDATR(), 32);
    let lb0_status = ExecuteCommandInstruction(
        SharedNDToCubeDimFull(0, lb0), 32);
    let lb1_status = ExecuteCommandInstruction(
        SharedNDToCubeDimFull(1, lb1), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           lb0_status == CommandExecution_Executed &&
           lb1_status == CommandExecution_Executed;
    if lb2_form == 1 then
        let lb2_status = ExecuteCommandInstruction(
            SharedNDToCubeDimFull(2, lb2), 32);
        assert lb2_status == CommandExecution_Executed;
    elsif lb2_form == 2 then
        let lb2_status = ExecuteCommandInstruction(
            SharedNDToCubeDimCompressed('10',
                (Zeros{8} + lb2) as bits(8)), 16);
        assert lb2_status == CommandExecution_Executed;
    end;
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeDimShared(shared_id as bits(6)), 32);
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeDimDestination(), 32);
    assert shared_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed &&
           !BundleSharedTMOVSharedNDToCubeSchemaLegal();
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    let source_after = SharedTileRecord(shared_id);
    return stop_status == CommandExecution_Rejected &&
           _LastFault == Fault_TileLegality &&
           !_BundleTileBindings[[0]].destination_allocated_by_bundle &&
           source_after.payload_generation == source_before.payload_generation &&
           source_after.payload_live == source_before.payload_live &&
           source_after.published == source_before.published;
end;

func RunSharedNDToCubeDuplicateDimension() => boolean
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0xb00);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0xb00);
    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeDimStart(), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeDimDATR(), 32);
    let first_status = ExecuteCommandInstruction(
        SharedNDToCubeDimFull(2, 1), 32);
    let second_status = ExecuteCommandInstruction(
        SharedNDToCubeDimCompressed('10', '10000000'), 16);
    return start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           first_status == CommandExecution_Executed &&
           second_status == CommandExecution_Rejected &&
           _LastFault == Fault_BundleControl &&
           _BundleDimensions[[2]] == Zeros{PTO_XLEN} + 1;
end;

func main() => integer
begin
    let bad_lb0 = RunSharedNDToCubeBadDimensions(127, 32, 0, 0);
    assert bad_lb0;
    let bad_lb1 = RunSharedNDToCubeBadDimensions(128, 31, 0, 0);
    assert bad_lb1;
    let zero_lb2 = RunSharedNDToCubeBadDimensions(128, 32, 0, 1);
    assert zero_lb2;
    let wrong_lb2 = RunSharedNDToCubeBadDimensions(128, 32, 64, 2);
    assert wrong_lb2;
    let duplicate_dimension = RunSharedNDToCubeDuplicateDimension();
    assert duplicate_dimension;
    return 0;
end;
