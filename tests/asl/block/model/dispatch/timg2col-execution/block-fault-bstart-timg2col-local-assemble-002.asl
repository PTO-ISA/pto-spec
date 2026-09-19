// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-TIMG2COL-LOCAL-ASSEMBLE-002","source":"asl/block/model/dispatch/timg2col-execution.asl","requirements":["PTO-INST-BLOCK-BSTART-TIMG2COL","PTO-B-ASSEMBLE-RANGE-001","PTO-BSTART-TIMG2COL-CONTRACT-001","PTO-BSTART-TIMG2COL-DEFINEDNESS-001"],"kind":"fault","summary":"Decoded Local TIMG2COL rejects B.ASSEMBLE because the canonical Local form is one direct B.IOT destination.","pass_condition":"Well-formed, malformed-WriterSize, nonzero-offset, and cooperative zero-row Local B.ASSEMBLE forms all raise TileLegality before GM events, allocation, payload, writer, coverage, finalization, or publication effects; Shared TIMG2COL assembly remains separately accepted.","related_sources":["asl/block/execution/BSTART.TIMG2COL.asl","asl/block/model/dispatch/tile-execution.asl","asl/block/model/operands/shared-generation.asl"]}
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

pure func TIMG2COLAssembleDestination(size_code: integer {1..10}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[18:15] = Zeros{4} + size_code;
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
        TIMG2COLAssembleDestination(3), 32);
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
    let rejected = RunTIMG2COLAssemble(3, 0);
    assert !rejected && _LastFault == Fault_TileLegality;
    AssertNoTIMG2COLLocalGenerationEffects();

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

    ResetProfileState();
    PrepareTIMG2COLAssembleFixture();
    _CurrentMemoryAgent = 1;
    let zero_row = RunTIMG2COLAssemble(3, 0);
    assert !zero_row && _LastFault == Fault_TileLegality;
    AssertNoTIMG2COLLocalGenerationEffects();
    return 0;
end;
