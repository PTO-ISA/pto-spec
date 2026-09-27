// PTO-TEST: {"id":"PTO-AVS-BLOCK-EXECUTION-MASK-CUBE-TRANSPORT-DECODED-006","source":"asl/block/model/dispatch/execution-mask-schema.asl","requirements":["PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-CUBE-CELL-TRANSPORT-001","PTO-B-DATR-FIELDS-001","PTO-B-IOR-BINDING-001"],"kind":"execution","summary":"Decoded CUBE transport accepts ExecutionMask carriers for both M layouts and both transfer directions.","pass_condition":"GPR-predicated ND2M16 and ND2M32 TLOAD plus PredicateCell-predicated M162ND and M322ND TSTORE complete without direct-layout assertions; inactive undefined TSTORE elements cause no source-read rejection.","related_sources":["asl/block/model/dispatch/tlsu-layout-conversion.asl","asl/block/model/dispatch/command-data-attributes.asl"]}
pure func MaskedTransportStart(store: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} +
        (if store then 0x00111181 else 0x00011181);
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U16);
    return instruction;
end;

pure func MaskedTransportAttributes(layout: bits(5), zero: boolean)
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = layout;
    instruction[13] = if zero then '1' else '0';
    return instruction;
end;

pure func MaskedTransportIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[31:27] = Zeros{5} + 2;
    instruction[26] = '1';
    return instruction;
end;

pure func MaskedTransportTLOADDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = '0001';
    instruction[11:9] = '111';
    instruction[19] = '1';
    instruction[8:7] = Zeros{2};
    return instruction;
end;

pure func MaskedTransportTSTORESource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 12;
    instruction[25:20] = Zeros{6} + 10;
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

func BeginMaskedTransport(store: boolean, layout: bits(5), zero: boolean,
    gpr_mask: boolean, valid_columns: integer {1..65535})
begin
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 1);
    let started = ExecuteCommandInstruction(MaskedTransportStart(store), 32);
    let attributed = ExecuteCommandInstruction(
        MaskedTransportAttributes(layout, zero), 32);
    assert started == CommandExecution_Executed;
    assert attributed == CommandExecution_Executed;
    if gpr_mask then
        let masked = ExecuteCommandInstruction(MaskedTransportIOR(), 32);
        assert masked == CommandExecution_Executed;
    end;
    SetBundleDimension(0, NaturalToWord(valid_columns));
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
end;

func TestMaskedTLOAD(layout_code: bits(5), expected_layout: TileLayout)
begin
    ResetProfileState();
    Store(Zeros{PTO_XLEN}, 2, Zeros{PTO_XLEN} + 0x1234);
    BeginMaskedTransport(FALSE, layout_code, TRUE, TRUE, 1);
    let bound = ExecuteCommandInstruction(
        MaskedTransportTLOADDestination(), 32);
    assert bound == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].layout == expected_layout;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x1234;
end;

func TestMaskedTSTORE(layout_code: bits(5), source_layout: TileLayout)
begin
    ResetProfileState();
    let configured = ConfigureCubeTileForMask(
        10, 128, 1, 2, TileDataType_U16, source_layout, '1111');
    let mask_ready = ConfigurePredicateCell(
        12, 128, 1, 2, TileDataType_U32, source_layout);
    assert configured && mask_ready;
    InstallRelativeTileFixture(10, 10);
    InstallRelativeTileFixture(12, 12);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 0x4321);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(12, 0, 1, Zeros{PTO_XLEN});
    _Tiles[[12]].contents_defined = TRUE;
    assert !_Tiles[[10]].contents_defined;
    BeginMaskedTransport(TRUE, layout_code, FALSE, FALSE, 2);
    let bound = ExecuteCommandInstruction(MaskedTransportTSTORESource(), 32);
    assert bound == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let stored = LoadUnsigned(Zeros{PTO_XLEN}, 2);
    assert stored == Zeros{PTO_XLEN} + 0x4321;
end;

func main() => integer
begin
    TestMaskedTLOAD(Zeros{5} + 22, TileLayout_CUBE_M16);
    TestMaskedTLOAD(Zeros{5} + 21, TileLayout_CUBE_M32);
    TestMaskedTSTORE(Zeros{5} + 25, TileLayout_CUBE_M16);
    TestMaskedTSTORE(Zeros{5} + 24, TileLayout_CUBE_M32);
    return 0;
end;
