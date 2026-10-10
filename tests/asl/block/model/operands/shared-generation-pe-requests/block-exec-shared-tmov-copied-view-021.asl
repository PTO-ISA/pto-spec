// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-COPIED-VIEW-021","source":"asl/block/model/operands/shared-generation-pe-requests.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001","PTO-B-ASSEMBLE-SHARED-STANDALONE-001","PTO-TMOV-CONTRACT-001"],"kind":"execution","summary":"Encoded Shared TMOV derives fragment validity from the copied source view.","pass_condition":"Four actual PE stops copy a bounded 128-byte view from legal 4x16 physical, 4x8 valid Local sources into distinct destination rows; publication has exactly four physical and valid rows, preserving the copied row payload without using uncopied source rows to enlarge the descriptor.","related_sources":["asl/block/model/operands/shared-generation.asl","asl/block/model/operands/shared-generation-pe-requests.asl","asl/block/model/dispatch/shared-tlsu.asl"]}
pure func SharedTLSUAssemblePEStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00010';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func SharedTLSUAssemblePESharedBinding(
    shared_tile_id: bits(6), size_code: bits(4), pe_mode: bits(3))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    return instruction;
end;

pure func SharedTLSUAssemblePETileBinding(
    source: bits(6), pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = pe_mode;
    instruction[25:20] = source;
    instruction[19] = '1';
    return instruction;
end;

pure func SharedTLSUAssemblePEBAssemble(offset: integer) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[30:20] = Zeros{11} + offset;
    instruction[11] = '1';
    instruction[10:7] = Zeros{4} + 1;
    return instruction;
end;

func PrepareSharedTLSUAssemblePE(pe: MemoryAgentId, epoch: integer)
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    if ReadTPC() == Zeros{PTO_XLEN} then
        WriteTPC(Zeros{PTO_XLEN} + 0x100);
    end;
    ConfigureTile(0, 512, 4, 16, 4, 8, TileDataType_U64,
        TileLayout_RowMajor);
    for row = 0 to 3 do
        for column = 0 to 7 do
            WriteTileElement(0, row, column as integer {0..65535},
                Zeros{PTO_XLEN} + 0x1000 + epoch * 0x10000 +
                    (pe as integer {0..3}) * 0x100 + row * 16 + column);
        end;
    end;
    let started = ExecuteCommandInstruction(
        SharedTLSUAssemblePEStart(), 32);
    let shared_binding = ExecuteCommandInstruction(
        SharedTLSUAssemblePESharedBinding(Zeros{6} + 19, '0011', '111'),
        32);
    let assemble = ExecuteCommandInstruction(
        SharedTLSUAssemblePEBAssemble(pe as integer {0..3}), 32);
    let tile_binding = ExecuteCommandInstruction(
        SharedTLSUAssemblePETileBinding(Zeros{6}, '111'), 32);
    assert started == CommandExecution_Executed;
    assert shared_binding == CommandExecution_Executed;
    assert tile_binding == CommandExecution_Executed;
    assert assemble == CommandExecution_Executed;
    assert _BundleActive && _BundleSharedBindings[[0]].valid &&
           _BundleSharedBindings[[0]].destination_assemble.valid &&
           _BundleSharedBindings[[0]].pe_mask == '1111';
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN});
    assert launched == KernelLifecycle_Started;

    var parked_tpcs: array [[PTO_MODEL_MEMORY_AGENTS]] of Word;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        PrepareSharedTLSUAssemblePE(agent, 0);
        SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
        parked_tpcs[[agent]] = ReadTPC();
        let stop = ExecuteCommandInstruction(Zeros{64}, 16);
        assert stop == CommandExecution_Executed && _LastFault == Fault_None;
        if pe < PTO_MODEL_MEMORY_AGENTS - 1 then
            let shared_id = (Zeros{6} + 19) as SharedTileID;
            assert !SharedTilePublished(shared_id);
            assert BundleSharedGenerationOpen(shared_id);
            assert ReadTPC() == parked_tpcs[[agent]];
            assert _BundleActive &&
                   BundleSharedGenerationRequestWaiting(0);
        end;
    end;

    let shared_id = (Zeros{6} + 19) as SharedTileID;
    assert SharedTilePublished(shared_id);
    let published = SharedTileRecord(shared_id);
    assert published.tile.capacity_bytes == 512 &&
           published.tile.rows == 4 && published.tile.columns == 16;
    assert published.tile.valid_rows == 4;
    assert published.tile.valid_columns == 8 &&
           published.initialized_mask == '1111';
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        for column = 0 to 7 do
            let index = TileLogicalLinearIndex(published.tile,
                pe as integer {0..3}, column as integer {0..15});
            assert TileLogicalElementDefined(published.tile, index) &&
                TileReadLogicalElement(published.tile, index) ==
                Zeros{PTO_XLEN} +
                    0x1000 + pe * 0x100 + column;
        end;
        for column = 8 to 15 do
            let index = TileLogicalLinearIndex(published.tile,
                pe as integer {0..3}, column as integer {0..15});
            assert !TileLogicalElementDefined(published.tile, index);
        end;
    end;
    assert _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
        .released_participants == '0001';

    // The first three encoded request instances were retained at their real
    // STOP boundary. Re-entry consumes each matching completion once without
    // replaying the already-captured Local fragment.
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 2 do
        let agent = pe as MemoryAgentId;
        SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
        assert ReadTPC() == parked_tpcs[[agent]] &&
               _BundleActive &&
               BundleSharedGenerationRequestWaiting(0);
        if pe == 0 then
            let generation = _SharedGenerations[[
                SharedTileArrayIndex(shared_id)]];
            assert _BundleOperation.valid;
            assert generation.actual_pe_owned && generation.published &&
                   !generation.open;
            assert generation.arrival_request_tokens[[0]] ==
                _BundleExecutionDomainToken;
            assert _BundleSharedBindings[[0]].destination_assemble
                .shared_request_execution_domain ==
                    _BundleExecutionDomainToken;
            assert _BundleSharedBindings[[0]].destination_assemble
                .shared_request_operation_ordinal ==
                    generation.operation_ordinal;
        end;
        let released = ExecuteCommandInstruction(Zeros{64}, 16);
        assert _LastFault == Fault_None;
        assert released == CommandExecution_Executed;
        assert !BundleSharedGenerationRequestWaiting(0);
        if pe == 0 then
            assert _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
                .released_participants == '1001';
            assert ReadTPC() != parked_tpcs[[agent]];
            assert !_BundleActive;
        end;
        if pe == 1 then assert !_BundleActive; end;
        if pe == 2 then assert !_BundleActive; end;
    end;
    assert _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
        .released_participants == '1111';
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
        assert !_BundleActive;
    end;

    // Reuse the same static operation after every old request consumed its
    // completion. The next ordinal gets four fresh private source snapshots;
    // the previously published parent remains readable until the new LAST
    // participant closes the replacement candidate.
    let first_ordinal = _SharedGenerations[[
        SharedTileArrayIndex(shared_id)]].operation_ordinal;
    var order: array [[PTO_MODEL_MEMORY_AGENTS]] of integer;
    order[[0]] = 3;
    order[[1]] = 1;
    order[[2]] = 0;
    order[[3]] = 2;
    for arrival = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe_number = order[[arrival]];
        let agent = pe_number as MemoryAgentId;
        PrepareSharedTLSUAssemblePE(agent, 1);
        SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
        let request_tpc = ReadTPC();
        let stopped = ExecuteCommandInstruction(Zeros{64}, 16);
        assert _LastFault == Fault_None;
        if arrival < PTO_MODEL_MEMORY_AGENTS - 1 then
            assert stopped == CommandExecution_Executed;
            assert BundleSharedGenerationRequestWaiting(0);
            assert ReadTPC() == request_tpc;
            assert SharedTilePublished(shared_id);
            assert _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
                .operation_ordinal == first_ordinal + 1;
            for cell = 0 to 63 do
                let row = cell DIVRM 16;
                let column = cell MOD 16;
                if column < 8 then
                    assert ReadSharedTileWord(shared_id,
                        cell as PackedTileElementIndex) ==
                        Zeros{PTO_XLEN} + 0x1000 + row * 0x100 + column;
                else
                    assert !TileLogicalElementDefined(
                        SharedTileRecord(shared_id).tile,
                        cell as PackedTileElementIndex);
                end;
            end;
        else
            assert stopped == CommandExecution_Executed;
        end;
    end;
    assert _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
        .operation_ordinal == first_ordinal + 1;
    assert _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
        .released_participants == '0010';
    let replacement = SharedTileRecord(shared_id);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        for column = 0 to 7 do
            let index = TileLogicalLinearIndex(replacement.tile,
                pe as integer {0..3}, column as integer {0..15});
            assert TileLogicalElementDefined(replacement.tile, index) &&
                TileReadLogicalElement(replacement.tile, index) ==
                Zeros{PTO_XLEN} + 0x11000 + pe * 0x100 + column;
        end;
        for column = 8 to 15 do
            let index = TileLogicalLinearIndex(replacement.tile,
                pe as integer {0..3}, column as integer {0..15});
            assert !TileLogicalElementDefined(replacement.tile, index);
        end;
    end;
    for arrival = 0 to PTO_MODEL_MEMORY_AGENTS - 2 do
        let agent = order[[arrival]] as MemoryAgentId;
        SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
        assert BundleSharedGenerationRequestWaiting(0);
        let released = ExecuteCommandInstruction(Zeros{64}, 16);
        assert released == CommandExecution_Executed;
        assert !_BundleActive;
    end;
    assert _SharedGenerations[[SharedTileArrayIndex(shared_id)]]
        .released_participants == '1111';
    return 0;
end;
