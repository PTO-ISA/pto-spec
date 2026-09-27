// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLSU-INDEXED-PARTIAL-DEFINED-DECODED-002","source":"asl/block/model/dispatch/tlsu-mgather.asl","requirements":["PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-IOT-STREAM-001","PTO-MGATHER-CAS-ATOMIC-001"],"kind":"execution","summary":"Decoded predicated indexed memory operations require defined values only at active coordinates","pass_condition":"MGATHER, MSCATTER, and MGATHER.CAS accept partially defined CUBE sources when every active coordinate is defined and the undefined inactive coordinate causes no memory effect","related_sources":["asl/block/model/dispatch/tlsu-mscatter.asl","asl/block/model/dispatch/tlsu-mgather-cas.asl","asl/tile/model/legality/memory-schema.asl"]}
pure func PartialIndexedStart(function: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[24:20] = function;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func PartialIndexedAttributes(zero_inactive: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 31;
    instruction[13] = if zero_inactive then '1' else '0';
    return instruction;
end;

pure func PartialIndexedIOT(source0: bits(6), source1: bits(6),
    source1_valid: boolean, destination_valid: boolean, last: boolean)
    => bits(64)
begin
    var instruction = if source1_valid then
        Zeros{64} + 0x00004013 else Zeros{64} + 0x00005013;
    instruction[31:26] = source1;
    instruction[25:20] = source0;
    instruction[19] = if last then '1' else '0';
    instruction[18:15] = if destination_valid then '0001' else '0000';
    instruction[11:9] = '001';
    instruction[8:7] = Zeros{2};
    return instruction;
end;

pure func PartialIndexedIOR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    return instruction;
end;

func ConfigurePartialIndexedSources()
begin
    let indices_ready = ConfigureCubeTile(
        10, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let values_ready = ConfigureCubeTile(
        11, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let replacement_ready = ConfigureCubeTile(
        13, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let mask_ready = ConfigurePredicateCell(
        12, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert indices_ready && values_ready && replacement_ready && mask_ready;
    InstallRelativeTileFixture(10, 10);
    InstallRelativeTileFixture(11, 11);
    InstallRelativeTileFixture(12, 12);
    InstallRelativeTileFixture(13, 13);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(13, 0, 0, Zeros{PTO_XLEN} + 9);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(12, 0, 1, Zeros{PTO_XLEN});
    _Tiles[[12]].contents_defined = TRUE;
    assert !_Tiles[[10]].contents_defined;
    assert !_Tiles[[11]].contents_defined;
    assert !_Tiles[[13]].contents_defined;
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x300);
end;

func BeginPartialIndexed(function: bits(5), zero_inactive: boolean)
begin
    let started = ExecuteCommandInstruction(PartialIndexedStart(function), 32);
    let attributes = ExecuteCommandInstruction(
        PartialIndexedAttributes(zero_inactive), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, NaturalToWord(_Tiles[[10]].columns));
end;

func FinishPartialIndexed()
begin
    let base = ExecuteCommandInstruction(PartialIndexedIOR(), 32);
    assert base == CommandExecution_Executed;
end;

func TestPartialMGATHER()
begin
    ResetProfileState();
    ConfigurePartialIndexedSources();
    Store(Zeros{PTO_XLEN} + 0x300, 4, Zeros{PTO_XLEN} + 0x55);
    Store(Zeros{PTO_XLEN} + 0x304, 4, Zeros{PTO_XLEN} + 0x66);
    BeginPartialIndexed('00100', TRUE);
    let bound = ExecuteCommandInstruction(
        PartialIndexedIOT(Zeros{6} + 10, Zeros{6} + 12,
            TRUE, TRUE, TRUE), 32);
    assert bound == CommandExecution_Executed;
    FinishPartialIndexed();
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x55;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
end;

func TestPartialMSCATTER()
begin
    ResetProfileState();
    ConfigurePartialIndexedSources();
    Store(Zeros{PTO_XLEN} + 0x300, 4, Zeros{PTO_XLEN} + 0x11);
    Store(Zeros{PTO_XLEN} + 0x304, 4, Zeros{PTO_XLEN} + 0x22);
    BeginPartialIndexed('00101', FALSE);
    let operands = ExecuteCommandInstruction(
        PartialIndexedIOT(Zeros{6} + 11, Zeros{6} + 10,
            TRUE, FALSE, FALSE), 32);
    let mask = ExecuteCommandInstruction(
        PartialIndexedIOT(Zeros{6} + 12, Zeros{6},
            FALSE, FALSE, TRUE), 32);
    assert operands == CommandExecution_Executed;
    assert mask == CommandExecution_Executed;
    FinishPartialIndexed();
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let active_memory = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 4);
    let inactive_memory = LoadUnsigned(Zeros{PTO_XLEN} + 0x304, 4);
    assert active_memory == Zeros{PTO_XLEN} + 7;
    assert inactive_memory == Zeros{PTO_XLEN} + 0x22;
end;

func TestPartialMGATHERCAS()
begin
    ResetProfileState();
    ConfigurePartialIndexedSources();
    Store(Zeros{PTO_XLEN} + 0x300, 4, Zeros{PTO_XLEN} + 7);
    Store(Zeros{PTO_XLEN} + 0x304, 4, Zeros{PTO_XLEN} + 0x22);
    BeginPartialIndexed('01000', TRUE);
    let operands = ExecuteCommandInstruction(
        PartialIndexedIOT(Zeros{6} + 10, Zeros{6} + 11,
            TRUE, FALSE, FALSE), 32);
    let result = ExecuteCommandInstruction(
        PartialIndexedIOT(Zeros{6} + 13, Zeros{6} + 12,
            TRUE, TRUE, TRUE), 32);
    assert operands == CommandExecution_Executed;
    assert result == CommandExecution_Executed;
    FinishPartialIndexed();
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[1]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
    let active_memory = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 4);
    let inactive_memory = LoadUnsigned(Zeros{PTO_XLEN} + 0x304, 4);
    assert active_memory == Zeros{PTO_XLEN} + 9;
    assert inactive_memory == Zeros{PTO_XLEN} + 0x22;
end;

func main() => integer
begin
    TestPartialMGATHER();
    TestPartialMSCATTER();
    TestPartialMGATHERCAS();
    return 0;
end;
