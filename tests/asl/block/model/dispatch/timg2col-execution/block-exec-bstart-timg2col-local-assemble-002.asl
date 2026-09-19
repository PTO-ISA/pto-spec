// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-TIMG2COL-LOCAL-ASSEMBLE-002","source":"asl/block/model/dispatch/timg2col-execution.asl","requirements":["PTO-INST-BLOCK-BSTART-TIMG2COL","PTO-B-ASSEMBLE-LOCAL-GENERATION-001","PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-BSTART-TIMG2COL-DEFINEDNESS-001"],"kind":"execution","summary":"Decoded Local TIMG2COL validates B.ASSEMBLE structure and the materialized CUBE writer before GM or generation effects.","pass_condition":"A 512-byte INIT_LAST writer closes and publishes only after its completion event; a mismatched WriterSize and a nonzero INIT_LAST offset each fault atomically before GM events, payload writes, coverage, finalization, or publication.","related_sources":["asl/block/model/operands/local-generation.asl","asl/block/model/operands/local-generation-cube.asl","asl/block/model/dispatch/tile-execution.asl"]}
pure func TIMG2COLAssembleStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x01c11181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func TIMG2COLAssembleDATR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 22;
    return instruction;
end;

pure func TIMG2COLAssembleIOR(
    source0: integer, source1: integer, source2: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + source0;
    instruction[24:20] = Zeros{5} + source1;
    instruction[31:27] = Zeros{5} + source2;
    return instruction;
end;

pure func TIMG2COLAssembleDestination() => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[18:15] = '0011';
    instruction[11:9] = '111';
    instruction[19] = '1';
    instruction[8:7] = '10';
    return instruction;
end;

pure func TIMG2COLAssembleModifier(
    writer_size: integer {1..12}, offset: integer {0..2047}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[11] = '1';
    instruction[10:7] = Zeros{4} + writer_size;
    instruction[30:20] = Zeros{11} + offset;
    return instruction;
end;

func PrepareTIMG2COLAssembleFixture()
begin
    for element = 0 to 31 do
        Store(Zeros{PTO_XLEN} + 32 + element, 1,
            Zeros{PTO_XLEN} + element + 1);
    end;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        WritePEGPR(agent, 2, Zeros{PTO_XLEN});
        WritePEGPR(agent, 3, Zeros{64} + 1 + (1 << 16) + (64 << 32) +
            (1 << 48) + (1 << 56));
        WritePEGPR(agent, 4, Zeros{64} + (1 << 32) + (1 << 37) +
            (1 << 42) + (1 << 48));
        WritePEGPR(agent, 5, Zeros{PTO_XLEN} + (32 << 32));
    end;
end;

func RunTIMG2COLAssemble(
    writer_size: integer {1..12}, offset: integer {0..2047}) => boolean
begin
    let start = ExecuteCommandInstruction(TIMG2COLAssembleStart(), 32);
    let datr = ExecuteCommandInstruction(TIMG2COLAssembleDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 32);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 64);
    let gm = ExecuteCommandInstruction(TIMG2COLAssembleIOR(2, 0, 0), 32);
    let parameters = ExecuteCommandInstruction(
        TIMG2COLAssembleIOR(3, 4, 5), 32);
    let destination = ExecuteCommandInstruction(
        TIMG2COLAssembleDestination(), 32);
    let assemble = ExecuteCommandInstruction(
        TIMG2COLAssembleModifier(writer_size, offset), 32);
    assert start == CommandExecution_Executed &&
           datr == CommandExecution_Executed &&
           gm == CommandExecution_Executed &&
           parameters == CommandExecution_Executed &&
           destination == CommandExecution_Executed &&
           assemble == CommandExecution_Executed;
    return ExecuteBundleTileOperation();
end;

func AssertNoTIMG2COLLocalGenerationEffects()
begin
    assert _MemoryEventCount == 0;
    for tile = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        assert !_Tiles[[tile]].allocated;
    end;
    for slot = 0 to 63 do
        assert !_LocalGenerations[[slot]].generation_identity_valid &&
               !_LocalGenerations[[slot]].open &&
               !_LocalGenerations[[slot]].descriptor_finalized &&
               !_LocalGenerations[[slot]].published &&
               _LocalGenerations[[slot]].writer_count == 0;
    end;
end;

func main() => integer
begin
    ResetProfileState();
    PrepareTIMG2COLAssembleFixture();
    let accepted = RunTIMG2COLAssemble(3, 0);
    assert accepted && _LastFault == Fault_None;
    let slot = BundleLocalGenerationSlot(2, '1111');
    let parent = _LocalGenerations[[slot]].working_destination;
    assert _LocalGenerations[[slot]].closed &&
           _LocalGenerations[[slot]].descriptor_finalized &&
           !_LocalGenerations[[slot]].published &&
           _LocalGenerations[[slot]].writer_count == 1;
    assert TileCubeDescriptorLegal(_Tiles[[parent]]) &&
           _Tiles[[parent]].layout == TileLayout_CUBE_M16 &&
           _Tiles[[parent]].capacity_bytes == 512 &&
           _Tiles[[parent]].valid_rows == 1 &&
           _Tiles[[parent]].valid_columns == 32;
    let completed = CompleteBundleLocalGenerationWriterEvent(
        slot, _BundleExecutionDomainToken, 0, 4);
    assert completed && _LocalGenerations[[slot]].published;

    ResetProfileState();
    PrepareTIMG2COLAssembleFixture();
    let bad_size = RunTIMG2COLAssemble(2, 0);
    assert !bad_size && _LastFault == Fault_TileLegality;
    AssertNoTIMG2COLLocalGenerationEffects();

    ResetProfileState();
    PrepareTIMG2COLAssembleFixture();
    let bad_init_last = RunTIMG2COLAssemble(3, 1);
    assert !bad_init_last && _LastFault == Fault_TileLegality;
    AssertNoTIMG2COLLocalGenerationEffects();
    return 0;
end;
