// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-ND-TO-CUBE-PARTIAL-PRODUCER-WAIT-001","source":"asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-B-SHARED-WHOLE-PARENT-READY-001","PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001","PTO-TMOV-SHARED-ND-TO-CUBE-001"],"kind":"state-transition","summary":"reverse TMOV waits without effects on a decoded partially open Shared generation","pass_condition":"an encoded two-PE forward producer leaves the Shared generation open after PE0; a distinct PE's decoded reverse request waits without binding consumption, allocation, fault, or lifetime capture, then retries after publication and converts once; replay against the resulting consumed last-use payload faults before Local effects","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/dispatch/shared-tmov-cube-to-nd.asl","asl/block/model/operands/shared-generation.asl","asl/block/model/operands/shared-generation-pe-requests.asl","asl/block/model/state/source-lifetime.asl","asl/tile/model/state/shared-registers.asl"]}
pure func SharedNDToCubeCohortGolden(row: integer {0..127},
    column: integer {0..127}) => Word
begin
    return Zeros{PTO_XLEN} + 1 + row * 71 + column * 29 +
        ((row * column) MOD 113);
end;

pure func SharedNDToCubeCohortStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = DTYPE_NONE;
    return instruction;
end;

pure func SharedNDToCubeCohortDATR(selector: integer {21,24})
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + selector;
    return instruction;
end;

pure func SharedNDToCubeCohortSharedSource(shared_id: bits(6),
    pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[11:9] = pe_mode;
    instruction[26] = '1';
    return instruction;
end;

pure func SharedNDToCubeCohortSharedDestination(shared_id: bits(6),
    parent_size: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = parent_size;
    instruction[11:9] = '101';
    return instruction;
end;

pure func SharedNDToCubeCohortAssemble(writer_size: bits(4))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[19:15] = Zeros{5} + 1;
    instruction[11] = '1';
    instruction[10:7] = writer_size;
    return instruction;
end;

pure func SharedNDToCubeCohortLocalSource(pe_mode: bits(3))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[11:9] = pe_mode;
    instruction[19] = '1';
    return instruction;
end;

pure func SharedNDToCubeCohortSubview() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000053;
    instruction[19:15] = Zeros{5} + 2;
    instruction[10:7] = Zeros{4} + 5;
    return instruction;
end;

pure func SharedNDToCubeCohortLocalDestination(size_code: bits(4),
    pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[8:7] = '10';
    instruction[11:9] = pe_mode;
    instruction[19] = '1';
    return instruction;
end;

func SharedNDToCubeCohortProducerValue(pe: integer {0,1},
    row: integer {0..31}, column: integer {0..63}) => Word
begin
    return Zeros{PTO_XLEN} + 3 + pe * 0x4000 + row * 193 +
        column * 47 + ((row * column) MOD 251);
end;

func ConfigureSharedNDToCubeCohortProducerSource(pe: integer {0,1})
begin
    let configured = ConfigureCubeTileForMask(0, 2048, 32, 64,
        TileDataType_U8, TileLayout_CUBE_M32, '1111');
    assert configured;
    InstallRelativeTileFixture(0, 0);
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 63 looplimit 64 do
            WriteTileElement(0, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeCohortProducerValue(pe,
                    row as integer {0..31},
                    column as integer {0..63}));
        end;
    end;
end;

func SubmitSharedNDToCubeCohortProducerPE(pe: integer {0,1})
begin
    let agent = pe as MemoryAgentId;
    SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    WriteGPR(1, Zeros{PTO_XLEN} + pe * 16);
    ConfigureSharedNDToCubeCohortProducerSource(pe);
    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeCohortStart(), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeCohortDATR(24), 32);
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeCohortSharedDestination(Zeros{6} + 54,
            Zeros{4} + 6), 32);
    let assemble_status = ExecuteCommandInstruction(
        SharedNDToCubeCohortAssemble(Zeros{4} + 5), 32);
    let source_status = ExecuteCommandInstruction(
        SharedNDToCubeCohortLocalSource('101'), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           assemble_status == CommandExecution_Executed &&
           source_status == CommandExecution_Executed;
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop_status == CommandExecution_Executed &&
           _LastFault == Fault_None;
end;

readonly func SharedNDToCubeCohortHasLifetime(shared_id: SharedTileID)
    => boolean
begin
    for slot = 0 to 63 do
        if _BundleSourceLifetimes[[slot]].valid &&
           _BundleSourceLifetimes[[slot]].shared &&
           _BundleSourceLifetimes[[slot]].resource ==
               (UInt(shared_id) as TileIndex) then
            return TRUE;
        end;
    end;
    return FALSE;
end;

func SubmitSharedNDToCubeCohortPartialConsumer()
    => (Word, integer)
begin
    let agent = 2 as MemoryAgentId;
    SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    WriteGPR(2, Zeros{PTO_XLEN});
    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeCohortStart(), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeCohortDATR(21), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 64);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeCohortSharedSource(Zeros{6} + 54, '011'), 32);
    let subview_status = ExecuteCommandInstruction(
        SharedNDToCubeCohortSubview(), 32);
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeCohortLocalDestination(Zeros{4} + 5, '011'), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           subview_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed;
    let parked_tpc = ReadTPC();
    let capacity_before = TileCapacityInUseForPE(2);
    let waiting = ExecuteCommandInstruction(Zeros{64}, 16);
    assert waiting == CommandExecution_Executed &&
           _LastFault == Fault_None && _BundleActive &&
           ReadTPC() == parked_tpc &&
           _BundleSharedBindings[[0]].valid &&
           !_BundleSharedBindings[[0]].consumed &&
           !_BundleTileBindings[[0]].destination_allocated_by_bundle &&
           TileCapacityInUseForPE(2) == capacity_before &&
           !SharedNDToCubeCohortHasLifetime(
               (Zeros{6} + 54) as SharedTileID);
    return (parked_tpc, capacity_before);
end;

func RunOpenPartialProducerWaitAndRetry()
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x300);
    assert launched == KernelLifecycle_Started;
    SubmitSharedNDToCubeCohortProducerPE(0);
    let shared_id = (Zeros{6} + 54) as SharedTileID;
    let index = SharedTileArrayIndex(shared_id);
    assert BundleSharedGenerationOpen(shared_id) &&
           _SharedGenerations[[index]].arrived_participants == '1000' &&
           !SharedTileRecord(shared_id).descriptor_valid &&
           !SharedTilePublished(shared_id) &&
           BundleSharedGenerationRequestWaiting(0);
    let (consumer_tpc, consumer_capacity) =
        SubmitSharedNDToCubeCohortPartialConsumer();

    SubmitSharedNDToCubeCohortProducerPE(1);
    let generation = SharedTileRecord(shared_id).payload_generation;
    assert SharedTilePublished(shared_id) && generation != 0 &&
           _SharedGenerations[[index]].arrived_participants == '1100' &&
           !_SharedGenerations[[index]].open &&
           _SharedGenerations[[index]].closed;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    assert _BundleActive && BundleSharedGenerationRequestWaiting(0);
    let producer_drain = ExecuteCommandInstruction(Zeros{64}, 16);
    assert producer_drain == CommandExecution_Executed &&
           _LastFault == Fault_None && !_BundleActive &&
           _SharedGenerations[[index]].released_participants == '1100';

    SelectExecutionContext(0 as PTOModelCoreIdentity, 2 as MemoryAgentId);
    assert _BundleActive && ReadTPC() == consumer_tpc &&
           TileCapacityInUseForPE(2) == consumer_capacity &&
           !_BundleSharedBindings[[0]].consumed;
    let consumer_retry = ExecuteCommandInstruction(Zeros{64}, 16);
    assert consumer_retry == CommandExecution_Executed &&
           _LastFault == Fault_None && !_BundleActive &&
           SharedTileRecord(shared_id).payload_generation == generation &&
           SharedTileRecord(shared_id).published &&
           !SharedTileRecord(shared_id).payload_live &&
           TileCapacityInUseForPE(2) == consumer_capacity + 2048;
    var destination_found = FALSE;
    var destination = 0 as TileIndex;
    for tile = 32 to 47 do
        if !destination_found && _Tiles[[tile]].allocated &&
           _Tiles[[tile]].layout == TileLayout_CUBE_M32 &&
           _Tiles[[tile]].capacity_bytes == 2048 &&
           _Tiles[[tile]].contents_defined then
            destination_found = TRUE;
            destination = tile as TileIndex;
        end;
    end;
    assert destination_found;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 63 looplimit 64 do
            let expected_value = SharedNDToCubeCohortProducerValue(0,
                row as integer {0..31},
                column as integer {0..63});
            assert ReadTileElement(destination,
                       row as integer {0..65535},
                       column as integer {0..65535}) ==
                   expected_value;
        end;
    end;
    RunSharedNDToCubeCohortConsumedSourceFault(shared_id,
        generation, consumer_capacity + 2048);
end;

func RunSharedNDToCubeCohortConsumedSourceFault(shared_id: SharedTileID,
    generation: integer, expected_capacity: integer)
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, 2 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0x500);
    let next_lifetime = _NextBundleSourceLifetimeOrdinal;
    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeCohortStart(), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeCohortDATR(21), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 64);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeCohortSharedSource(shared_id as bits(6), '011'), 32);
    let subview_status = ExecuteCommandInstruction(
        SharedNDToCubeCohortSubview(), 32);
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeCohortLocalDestination(Zeros{4} + 5, '011'), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           subview_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed;
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop_status == CommandExecution_Rejected &&
           _LastFault == Fault_TileLegality && _BundleActive &&
           !_BundleTileBindings[[0]].destination_allocated_by_bundle &&
           !_BundleSharedBindings[[0]].consumed &&
           !_BundleSharedBindings[[0]].source_lifetime_captured &&
           _NextBundleSourceLifetimeOrdinal == next_lifetime &&
           TileCapacityInUseForPE(2) == expected_capacity &&
           SharedTileRecord(shared_id).payload_generation == generation &&
           SharedTileRecord(shared_id).published &&
           !SharedTileRecord(shared_id).payload_live &&
           !SharedNDToCubeCohortHasLifetime(shared_id);
end;

func main() => integer
begin
    RunOpenPartialProducerWaitAndRetry();
    return 0;
end;
