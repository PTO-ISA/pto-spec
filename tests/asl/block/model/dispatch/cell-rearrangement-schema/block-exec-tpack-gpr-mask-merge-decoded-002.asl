// PTO-TEST: {"id":"PTO-AVS-BLOCK-TPACK-GPR-MASK-MERGE-DECODED-002","source":"asl/block/model/dispatch/cell-rearrangement-schema.asl","requirements":["PTO-TPACK-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-DATR-FIELDS-001","PTO-TILE-MODEL-EXECUTION-MASK-REARRANGEMENT-001"],"kind":"execution","summary":"Decoded TPACK retains both mandatory data sources when a GPR ExecutionMask requests MERGE","pass_condition":"the active CUBE word packs both source prefixes while the inactive row preserves the prior hand output and never requires inactive source payload","related_sources":["asl/block/model/dispatch/execution-mask-schema.asl","asl/tile/model/execution/rearrangement.asl"]}
pure func MaskedTPACKStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    let selector = Zeros{10} + 0x077;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func MaskedTPACKAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 29;
    return instruction;
end;

pure func MaskedTPACKIOR(control: bits(5), mask: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = control;
    instruction[24:20] = mask;
    instruction[26] = '1';
    return instruction;
end;

pure func MaskedTPACKIOT(source0: bits(6), source1: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[25:20] = source0;
    instruction[31:26] = source1;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    instruction[8:7] = Zeros{2};
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let source0_ready = ConfigureCubeTile(
        10, 128, 2, 1, TileDataType_U8, TileLayout_CUBE_M32);
    let source1_ready = ConfigureCubeTile(
        11, 128, 2, 1, TileDataType_U8, TileLayout_CUBE_M32);
    let base_ready = ConfigureCubeTile(
        12, 128, 2, 4, TileDataType_U8, TileLayout_CUBE_M32);
    assert source0_ready && source1_ready && base_ready;
    InstallRelativeTileFixture(10, 10);
    InstallRelativeTileFixture(11, 11);
    InstallRelativeTileFixture(0, 12);
    // Only row zero is active and therefore only its source bytes are defined.
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 0x11);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 0x21);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 70);
    WriteTileElement(12, 0, 1, Zeros{PTO_XLEN} + 71);
    WriteTileElement(12, 0, 2, Zeros{PTO_XLEN} + 72);
    WriteTileElement(12, 0, 3, Zeros{PTO_XLEN} + 73);
    WriteTileElement(12, 1, 0, Zeros{PTO_XLEN} + 80);
    WriteTileElement(12, 1, 1, Zeros{PTO_XLEN} + 81);
    WriteTileElement(12, 1, 2, Zeros{PTO_XLEN} + 82);
    WriteTileElement(12, 1, 3, Zeros{PTO_XLEN} + 83);
    MarkTileValidRegionDefined(12);

    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x00000101);
    // CUBE_M32 cell-word coordinate row zero is bit zero; row one is inactive.
    WritePEGPR(0, 3, Zeros{PTO_XLEN} + 1);
    let started = ExecuteCommandInstruction(MaskedTPACKStart(), 32);
    let attributed = ExecuteCommandInstruction(MaskedTPACKAttributes(), 32);
    let scalar = ExecuteCommandInstruction(
        MaskedTPACKIOR(Zeros{5} + 2, Zeros{5} + 3), 32);
    let bound = ExecuteCommandInstruction(
        MaskedTPACKIOT(Zeros{6} + 10, Zeros{6} + 11), 32);
    assert started == CommandExecution_Executed &&
           attributed == CommandExecution_Executed &&
           scalar == CommandExecution_Executed &&
           bound == CommandExecution_Executed;

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert destination == 0;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x11;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0x21;
    assert ReadTileElement(destination, 0, 2) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 0, 3) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 80;
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 81;
    assert ReadTileElement(destination, 1, 2) == Zeros{PTO_XLEN} + 82;
    assert ReadTileElement(destination, 1, 3) == Zeros{PTO_XLEN} + 83;
    return 0;
end;
