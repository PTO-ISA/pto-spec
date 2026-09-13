// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-MULTI-OPEN-INTERLEAVED-003","source":"asl/block/model/operands/local-generation.asl","requirements":["PTO-B-ASSEMBLE-LOCAL-GENERATION-001","PTO-B-ASSEMBLE-CONSUMER-READINESS-001","PTO-INST-BLOCK-B-ASSEMBLE","PTO-INST-BLOCK-B-IOT"],"kind":"execution","summary":"Two same-hand Local generations resolve #1/#2 independently through interleaved subset writers and reversed LAST.","pass_condition":"A then B INIT create stable T#2/T#1 parents; interleaved PE0/PE1 writers select each exact ParentRef, B closes before A without reordering, no continuation allocates, PE0 whole-parent consumption precedes PE1 readiness, and both generations eventually publish in creation order.","related_sources":["asl/block/model/operands/portable-carriers.asl","asl/tile/model/state/descriptors.asl","asl/block/model/dispatch/tile-execution.asl"]}
pure func Start() => bits(64)
begin
    return Zeros{64} + 0x20419181;
end;

pure func DestinationBinding(source0: integer, source1: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + source1;
    instruction[25:20] = Zeros{6} + source0;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 3;
    instruction[11:9] = Zeros{3} + 5;
    return instruction;
end;

pure func SourceBinding(mode: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 4;
    instruction[25:20] = Zeros{6} + 3;
    instruction[11:9] = Zeros{3} + mode;
    return instruction;
end;

pure func ParentBinding(parent: integer, mode: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + parent;
    instruction[19] = '1';
    instruction[11:9] = Zeros{3} + mode;
    return instruction;
end;

pure func Assemble(init: boolean, last: boolean,
                   writer_size: integer, offset: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + writer_size;
    instruction[30:20] = Zeros{11} + offset;
    return instruction;
end;

func BeginWriter()
begin
    let started = ExecuteCommandInstruction(Start(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
end;

func RunInit(source0: integer, source1: integer) => boolean
begin
    BeginWriter();
    let bound = ExecuteCommandInstruction(
        DestinationBinding(source0, source1), 32);
    let assembled = ExecuteCommandInstruction(
        Assemble(TRUE, FALSE, 1, 0), 32);
    assert bound == CommandExecution_Executed &&
           assembled == CommandExecution_Executed;
    return CompleteBundleAt(ReadTPC() + 4);
end;

func RunContinuation(parent: integer, mode: integer, offset: integer,
                     writer_size: integer, last: boolean) => boolean
begin
    BeginWriter();
    let sources = ExecuteCommandInstruction(SourceBinding(mode), 32);
    let parent_ref = ExecuteCommandInstruction(
        ParentBinding(parent, mode), 32);
    let assembled = ExecuteCommandInstruction(
        Assemble(FALSE, last, writer_size, offset), 32);
    assert sources == CommandExecution_Executed &&
           parent_ref == CommandExecution_Executed &&
           assembled == CommandExecution_Executed;
    return CompleteBundleAt(ReadTPC() + 4);
end;

func CompleteWriter(slot: integer {0..63}, domain: integer,
                    offset: integer {0..2047}, count: integer {1..2048})
begin
    let completed = CompleteBundleLocalGenerationWriterEvent(
        slot, domain, offset, count);
    assert completed;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(1, 512, 64, 4, 1, 4,
        TileDataType_FP16, TileLayout_RowMajor, '1100');
    ConfigureTileForMask(2, 512, 64, 4, 1, 4,
        TileDataType_FP16, TileLayout_RowMajor, '1100');
    InstallRelativeTileFixture(1, 1);
    InstallRelativeTileFixture(2, 2);
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x3c00);

    let a_init = RunInit(1, 2);
    let a_init_domain = _BundleExecutionDomainToken;
    assert a_init && _LastFault == Fault_None;
    let a_destination = ResolveRelativeTileSource(0);
    let a_slot = BundleLocalGenerationSlotForDestination(a_destination)
        as integer {0..63};

    let b_init = RunInit(2, 3);
    let b_init_domain = _BundleExecutionDomainToken;
    assert b_init && _LastFault == Fault_None;
    let b_destination = ResolveRelativeTileSource(0);
    let b_slot = BundleLocalGenerationSlotForDestination(b_destination)
        as integer {0..63};
    assert a_destination != b_destination &&
           ResolveRelativeTileSource(0) == b_destination &&
           ResolveRelativeTileSource(1) == a_destination &&
           _LocalGenerations[[a_slot]].open &&
           _LocalGenerations[[b_slot]].open;

    let a_all = RunContinuation(1, 5, 1, 1, FALSE);
    let a_all_domain = _BundleExecutionDomainToken;
    let b_all = RunContinuation(0, 5, 1, 1, FALSE);
    let b_all_domain = _BundleExecutionDomainToken;
    let a_pe1 = RunContinuation(1, 2, 2, 2, FALSE);
    let a_pe1_domain = _BundleExecutionDomainToken;
    let b_pe1 = RunContinuation(0, 2, 2, 2, FALSE);
    let b_pe1_domain = _BundleExecutionDomainToken;
    let a_pe0 = RunContinuation(1, 1, 2, 1, FALSE);
    let a_pe0_domain = _BundleExecutionDomainToken;
    let b_pe0 = RunContinuation(0, 1, 2, 1, FALSE);
    let b_pe0_domain = _BundleExecutionDomainToken;
    assert a_all && b_all && a_pe1 && b_pe1 && a_pe0 && b_pe0;
    assert _LocalGenerations[[b_slot]].participant_mask == '1100';
    assert _LocalGenerations[[b_slot]].per_pe_covered_cells[[0]][0] == '1';
    assert _LocalGenerations[[b_slot]].per_pe_covered_cells[[0]][1] == '1';
    assert _LocalGenerations[[b_slot]].per_pe_covered_cells[[0]][2] == '1';
    assert _LocalGenerations[[b_slot]].per_pe_covered_cells[[1]][0] == '1';
    assert _LocalGenerations[[b_slot]].per_pe_covered_cells[[1]][1] == '1';
    assert _LocalGenerations[[b_slot]].per_pe_covered_cells[[1]][2] == '1';
    assert _LocalGenerations[[b_slot]].per_pe_covered_cells[[1]][3] == '1';
    assert BundleLocalGenerationCoverageComplete(
        b_slot, Zeros{PTO_XLEN} + 3, 1, '1000', FALSE, 0);

    let b_last = RunContinuation(0, 1, 3, 1, TRUE);
    let b_last_domain = _BundleExecutionDomainToken;
    assert b_last;
    assert _LocalGenerations[[b_slot]].closed;
    assert _LocalGenerations[[a_slot]].open;
    let a_last = RunContinuation(1, 1, 3, 1, TRUE);
    let a_last_domain = _BundleExecutionDomainToken;
    assert a_last && _LocalGenerations[[a_slot]].closed;
    assert ResolveRelativeTileSource(0) == b_destination &&
           ResolveRelativeTileSource(1) == a_destination;

    var allocated: integer {0..64} = 0;
    for tile = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if _Tiles[[tile]].allocated then
            allocated = (allocated + 1) as integer {0..64};
        end;
    end;
    assert allocated == 4;

    CompleteWriter(b_slot, b_init_domain, 0, 1);
    CompleteWriter(b_slot, b_all_domain, 1, 1);
    CompleteWriter(b_slot, b_pe0_domain, 2, 1);
    CompleteWriter(b_slot, b_last_domain, 3, 1);
    assert _LocalGenerations[[b_slot]].per_pe_published[[0]] &&
           !_LocalGenerations[[b_slot]].per_pe_published[[1]] &&
           !_LocalGenerations[[b_slot]].published;
    let pe0_ready = BundleConsumerDependencyRequiredRange(
        b_slot, b_destination, Zeros{PTO_XLEN}, 0, TRUE, '1000',
        Zeros{PTO_XLEN} + 0x900);
    let pe1_waiting = BundleConsumerDependencyRequiredRange(
        b_slot, b_destination, Zeros{PTO_XLEN}, 0, TRUE, '0100',
        Zeros{PTO_XLEN} + 0x904);
    assert pe0_ready && !pe1_waiting;
    CompleteWriter(b_slot, b_pe1_domain, 2, 2);
    assert _LocalGenerations[[b_slot]].published &&
           _LocalGenerations[[b_slot]].per_pe_published[[1]];

    CompleteWriter(a_slot, a_init_domain, 0, 1);
    CompleteWriter(a_slot, a_all_domain, 1, 1);
    CompleteWriter(a_slot, a_pe0_domain, 2, 1);
    CompleteWriter(a_slot, a_last_domain, 3, 1);
    CompleteWriter(a_slot, a_pe1_domain, 2, 2);
    assert _LocalGenerations[[a_slot]].published;
    assert ResolveRelativeTileSource(0) == b_destination &&
           ResolveRelativeTileSource(1) == a_destination;
    return 0;
end;
