// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLSU-GM-ATOM-RED-MASKED-DECODED-002","source":"asl/block/model/dispatch/tlsu-gm-atom-red.asl","requirements":["PTO-ATOM-RED-BODY-SCHEMA-001","PTO-ATOM-RED-ORDERING-001","PTO-INST-TILE-MGATHER-ADD","PTO-INST-TILE-MSCATTER-ADD","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-IOT-STREAM-001"],"kind":"execution","summary":"Decoded masked GM atom and reduction bundles retain their second-record roles","pass_condition":"MGATHER_ADD publishes old active values to its resolved nonzero physical destination, MSCATTER_ADD updates only active addresses, and destination-role mismatches reject before memory or allocation effects","related_sources":["asl/block/model/dispatch/execution-mask-schema.asl","asl/tile/model/memory/gm-atom-red.asl","asl/tile/model/memory/gm-atom-red-execution.asl"]}
pure func MaskedAtomRedStart(function: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[24:20] = function;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func MaskedAtomRedAttributes(zero_inactive: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 31;
    instruction[13] = if zero_inactive then '1' else '0';
    return instruction;
end;

pure func MaskedAtomRedIOT(
    source0: bits(6), source1: bits(6), source1_valid: boolean,
    destination: bits(2), destination_valid: boolean,
    last: boolean) => bits(64)
begin
    var instruction = if source1_valid then
        Zeros{64} + 0x00004013 else Zeros{64} + 0x00005013;
    instruction[31:26] = source1;
    instruction[25:20] = source0;
    instruction[19] = if last then '1' else '0';
    instruction[18:15] = if destination_valid then '0001' else '0000';
    instruction[11:9] = '001';
    instruction[8:7] = if destination_valid then destination else Zeros{2};
    return instruction;
end;

pure func MaskedAtomRedIOR(source0: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = source0;
    return instruction;
end;

func ConfigureMaskedAtomRedSources()
begin
    // Occupy physical Tile 0 so the atom destination exposes binding-index
    // confusion instead of accidentally naming the same physical Tile.
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    let indices_ready = ConfigureCubeTile(
        10, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let values_ready = ConfigureCubeTile(
        11, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let mask_ready = ConfigurePredicateCell(
        12, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert indices_ready && values_ready && mask_ready;
    InstallRelativeTileFixture(12, 12);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(12, 0, 1, Zeros{PTO_XLEN});
    assert !_Tiles[[10]].contents_defined;
    assert !_Tiles[[11]].contents_defined;
    _Tiles[[12]].contents_defined = TRUE;
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x400);
end;

func BeginMaskedAtomRed(function: bits(5), zero_inactive: boolean)
begin
    let started = ExecuteCommandInstruction(MaskedAtomRedStart(function), 32);
    let attributes = ExecuteCommandInstruction(
        MaskedAtomRedAttributes(zero_inactive), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, NaturalToWord(_Tiles[[10]].columns));
end;

func BindMaskedAtomRed(destination_valid: boolean)
begin
    let operands = ExecuteCommandInstruction(
        MaskedAtomRedIOT(Zeros{6} + 10, Zeros{6} + 11,
            TRUE, Zeros{2}, FALSE, FALSE), 32);
    let mask = ExecuteCommandInstruction(
        MaskedAtomRedIOT(Zeros{6} + 12, Zeros{6},
            FALSE, Zeros{2} + 1, destination_valid, TRUE), 32);
    let base = ExecuteCommandInstruction(
        MaskedAtomRedIOR(Zeros{5} + 2), 32);
    assert operands == CommandExecution_Executed;
    assert mask == CommandExecution_Executed;
    assert base == CommandExecution_Executed;
end;

func RunMaskedMGATHERADD()
begin
    ResetProfileState();
    ConfigureMaskedAtomRedSources();
    Store(Zeros{PTO_XLEN} + 0x400, 4, Zeros{PTO_XLEN} + 10);
    Store(Zeros{PTO_XLEN} + 0x404, 4, Zeros{PTO_XLEN} + 20);
    BeginMaskedAtomRed('01100', TRUE);
    BindMaskedAtomRed(TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[1]].destination;
    assert destination != 0;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
    let active_memory = LoadUnsigned(Zeros{PTO_XLEN} + 0x400, 4);
    let inactive_memory = LoadUnsigned(Zeros{PTO_XLEN} + 0x404, 4);
    assert active_memory == Zeros{PTO_XLEN} + 13;
    assert inactive_memory == Zeros{PTO_XLEN} + 20;
end;

func RunMaskedMSCATTERADD()
begin
    ResetProfileState();
    ConfigureMaskedAtomRedSources();
    Store(Zeros{PTO_XLEN} + 0x400, 4, Zeros{PTO_XLEN} + 5);
    Store(Zeros{PTO_XLEN} + 0x404, 4, Zeros{PTO_XLEN} + 9);
    BeginMaskedAtomRed('10101', FALSE);
    BindMaskedAtomRed(FALSE);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let active_memory = LoadUnsigned(Zeros{PTO_XLEN} + 0x400, 4);
    let inactive_memory = LoadUnsigned(Zeros{PTO_XLEN} + 0x404, 4);
    assert active_memory == Zeros{PTO_XLEN} + 8;
    assert inactive_memory == Zeros{PTO_XLEN} + 9;
end;

func RunWrongFinalBinding(atom: boolean)
begin
    ResetProfileState();
    ConfigureMaskedAtomRedSources();
    Store(Zeros{PTO_XLEN} + 0x400, 4, Zeros{PTO_XLEN} + 5);
    BeginMaskedAtomRed(if atom then '01100' else '10101', atom);
    // Reduction destinations are forbidden; atom destinations are required.
    BindMaskedAtomRed(!atom);
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    let memory = LoadUnsigned(Zeros{PTO_XLEN} + 0x400, 4);
    assert memory == Zeros{PTO_XLEN} + 5;
end;

func main() => integer
begin
    RunMaskedMGATHERADD();
    RunMaskedMSCATTERADD();
    RunWrongFinalBinding(FALSE);
    RunWrongFinalBinding(TRUE);
    return 0;
end;
