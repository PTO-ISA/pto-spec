// PTO-TEST: {"id":"PTO-AVS-BLOCK-PREDICATECELL-LOGICAL-MERGE-GENERATION-ID-001","source":"asl/block/model/operands/local-generation-cube.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-B-ASSEMBLE-SPECULATION-001","PTO-B-ASSEMBLE-CONSUMER-READINESS-001","PTO-TAND-CONTRACT-001"],"kind":"execution","summary":"A pinned implicit PredicateCell base cannot be replaced by a new dynamic generation at the same static INIT address and slot","pass_condition":"after a decoded consumer waits on Q, aborting it and decoding a replacement at the same INIT BPC, destination tile, and Local slot with a new execution-domain token and distinct payload makes retry fault before registering against or reading the replacement; an unchanged Q generation remains resumable","related_sources":["asl/block/model/dispatch/execution-mask-schema.asl","asl/block/model/operands/local-generation.asl","asl/block/model/operands/portable-carriers.asl","asl/arch/state/pe-execution-context.asl"]}
pure func LogicalAssemblyStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[24:20] = Zeros{5} + 6;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;
pure func LogicalAssemblyInputs(init: boolean,
    source0: integer {0..63}, source1: integer {0..63}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[25:20] = Zeros{6} + source0;
    instruction[31:26] = Zeros{6} + source1;
    instruction[19] = if init then '1' else '0';
    instruction[18:15] = if init then Zeros{4} + 2 else Zeros{4};
    instruction[11:9] = '111'; instruction[8:7] = if init then '01' else '00';
    return instruction;
end;
pure func LogicalAssemblyModifier(init: boolean, last: boolean,
    offset: integer {0,1}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = '0001';
    instruction[30:20] = Zeros{11} + offset;
    return instruction;
end;
func LogicalAssemblyWriter(init: boolean, last: boolean,
    offset: integer {0,1}, columns: integer {1..8},
    source0: integer {0..63}, source1: integer {0..63},
    complete_ready: boolean, expect_wait: boolean)
begin
    let started = ExecuteCommandInstruction(LogicalAssemblyStart(), 32);
    let attributes = ExecuteCommandInstruction(Zeros{64} + 0x01f01fa3, 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 8);
    var mask = CommandExecution_Executed;
    if !init then
        var ior = Zeros{64} + 0x00000013;
        ior[19:15] = Zeros{5} + 2;
        ior[26] = '1';
        mask = ExecuteCommandInstruction(ior, 32);
    end;
    let bound = ExecuteCommandInstruction(
        LogicalAssemblyInputs(init, source0, source1), 32);
    var parent = CommandExecution_Executed;
    if !init then
        parent = ExecuteCommandInstruction(Zeros{64} + 0x01185e13, 32);
    end;
    let assembled = ExecuteCommandInstruction(
        LogicalAssemblyModifier(init,last,offset), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    assert mask == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    assert parent == CommandExecution_Executed;
    assert assembled == CommandExecution_Executed;
    let completed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x100 + offset * 16);
    if expect_wait then
        assert !completed && _BundleExecutionMask.merge_base_waiting &&
               _LastFault == Fault_None;
        return;
    end;
    assert completed;
    if complete_ready then
        let slot = BundleLocalGenerationSlot(1, '1111');
        let ready = CompleteBundleLocalGenerationWriterEvent(
            slot, _BundleExecutionDomainToken, offset, 1);
        assert ready;
    end;
end;
func ConfigurePredicateSource(index: TileIndex,
    columns: integer {1..8}, all_one: boolean)
begin
    let configured = ConfigurePredicateCellForMask(index,128,2,columns,
        TileDataType_U32,TileLayout_CUBE_M16,'1111');
    assert configured;
    for row = 0 to 1 do
        for column = 0 to columns - 1 looplimit 8 do
            WriteTileElement(index,row as integer {0..65535},
                column as integer {0..65535},
                if all_one then Zeros{PTO_XLEN} + 1
                else Zeros{PTO_XLEN});
        end;
    end;
    MarkTileValidRegionDefined(index);
    InstallRelativeTileFixture(index,index);
end;
func main() => integer
begin
    ResetProfileState();
    SelectExecutionContext(0,0);
    ConfigurePredicateSource(1,8,TRUE);
    ConfigurePredicateSource(2,8,TRUE);
    ConfigurePredicateSource(3,3,TRUE);
    ConfigurePredicateSource(4,3,TRUE);

    // P has its own open destination. Q is a decoded INIT at tile/slot 17
    // whose physical tile is already a defined, compatible 2x3 value.
    LogicalAssemblyWriter(TRUE,FALSE,0,8,1,2,TRUE,FALSE);
    let parent = _LocalGenerations[[BundleLocalGenerationSlot(1,'1111')]]
        .working_destination;
    LogicalAssemblyWriter(TRUE,FALSE,0,3,3,4,FALSE,FALSE);
    let q = _TileRelativeOrder[[1]][[0]];
    let q_slot = BundleLocalGenerationSlotForDestination(q)
        as integer {0..63};
    assert q == 17 && q_slot == 17 && q != parent &&
           _LocalGenerations[[q_slot]].open &&
           _LocalGenerations[[q_slot]].writer_count == 1 &&
           !_LocalGenerations[[q_slot]].writers[[0]].ready &&
           _Tiles[[q]].valid_rows == 2 && _Tiles[[q]].valid_columns == 3 &&
           _Tiles[[q]].contents_defined;
    let original_instance = _LocalGenerations[[q_slot]].generation_instance;
    let original_domain = _LocalGenerations[[q_slot]].writers[[0]]
        .identity.execution_domain_token;
    let original_payload = ReadTileElement(q,0,0);

    for pe = 0 to 3 do
        WritePEGPR(pe as MemoryAgentId,2,Zeros{PTO_XLEN} + 1);
    end;
    LogicalAssemblyWriter(FALSE,TRUE,1,3,3,4,FALSE,TRUE);
    assert _BundleExecutionMask.merge_base_generation_valid &&
           _BundleExecutionMask.merge_base == q &&
           _BundleExecutionMask.merge_base_generation_slot == q_slot &&
           _LocalGenerations[[q_slot]].consumers[[0]].state ==
               BundleConsumerDependency_Waiting;

    // The next PE is a separate dynamic execution context on this Core. It
    // aborts Q, then recreates the same physical destination and slot using
    // the same static INIT address but a fresh existing domain token.
    SelectExecutionContext(0,1);
    assert !_BundleActive;
    AbortBundleLocalGeneration(q_slot);
    ConfigurePredicateSource(3,3,FALSE);
    ConfigurePredicateSource(4,3,FALSE);
    let dummy_configured = ConfigurePredicateCellForMask(16,128,2,3,
        TileDataType_U32,TileLayout_CUBE_M16,'1111');
    assert dummy_configured;
    MarkTileValidRegionDefined(16);
    assert !_BundleActive;
    WriteTPC(original_instance);
    LogicalAssemblyWriter(TRUE,FALSE,0,3,3,4,FALSE,FALSE);
    let replacement = _TileRelativeOrder[[1]][[0]];
    let replacement_slot = BundleLocalGenerationSlotForDestination(replacement)
        as integer {0..63};
    assert replacement == q;
    assert replacement_slot == q_slot;
    assert _LocalGenerations[[replacement_slot]].generation_identity_valid;
    assert _LocalGenerations[[replacement_slot]].generation_instance ==
           original_instance;
    assert _LocalGenerations[[replacement_slot]].writers[[0]]
               .identity.instruction_instance == original_instance;
    assert _LocalGenerations[[replacement_slot]].writers[[0]]
               .identity.execution_domain_token != original_domain;
    assert ReadTileElement(replacement,0,0) != original_payload;

    SelectExecutionContext(0,0);
    let resumed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x110);
    assert !resumed;
    assert !_BundleExecutionMask.merge_base_waiting;
    assert _LastFault == Fault_TileLegality;
    assert _LocalGenerations[[replacement_slot]].consumer_count == 0 &&
           _LocalGenerations[[replacement_slot]].open &&
           _LocalGenerations[[replacement_slot]].writers[[0]]
               .identity.execution_domain_token != original_domain;
    return 0;
end;
