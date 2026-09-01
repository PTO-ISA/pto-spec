// PTO-TEST: {"id":"PTO-AVS-TILE-TSELS-OMITTED-SCALAR-003","source":"asl/tile/tile-scalar-and-immediate/logical/TSELS.asl","requirements":["PTO-TSELS-CONTRACT-001"],"kind":"execution","summary":"Omitted TSELS B.IOR supplies an all-zero false scalar to Tile mask carriers","pass_condition":"legacy RowMajor and CUBE PredicateCell forms both select zero for false mask elements without recording a scalar binding","related_sources":["asl/block/model/dispatch/tile-scalar-schema.asl","asl/tile/model/execution/comparison.asl"]}
pure func TSELSCubeStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = '01';
    instruction[24:20] = Zeros{5} + 26;
    instruction[31:27] = Zeros{5} + 1;
    return instruction;
end;

pure func TSELSCubeBinding(mask: bits(6), source_true: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = source_true;
    instruction[25:20] = mask;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 2;
    instruction[11:9] = '001';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigurePredicateTile(1, 128, 16, 2, 1, 2);
    ConfigureTile(2, 128, 8, 2, 1, 2, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTilePredicateBit(1, 0, 0, FALSE);
    WriteTilePredicateBit(1, 0, 1, TRUE);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 11);
    let legacy_started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x0ba19181, 32);
    assert legacy_started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE, 0, 1, '0001', TRUE, TRUE, 1, 2, TRUE);
    let legacy_completed = ExecuteBundleTileOperation();
    assert legacy_completed && _LastFault == Fault_None;
    assert !_BundleScalarBindings[[0]].valid;
    let legacy_destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(legacy_destination, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(legacy_destination, 0, 1) == Zeros{PTO_XLEN} + 11;

    ResetProfileState();
    let mask_ready = ConfigurePredicateCell(
        8, 128, 1, 2, TileDataType_FP32, TileLayout_CUBE_M32);
    let source_ready = ConfigureCubeTile(
        10, 256, 1, 2, TileDataType_FP32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    assert mask_ready && source_ready;
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(8, 0, 1, Zeros{PTO_XLEN} + 1);
    _Tiles[[8]].contents_defined = TRUE;
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 20);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 21);
    MarkTileValidRegionDefined(10);
    let cube_started = ExecuteCommandInstruction(TSELSCubeStart(), 32);
    assert cube_started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    let cube_bound = ExecuteCommandInstruction(
        TSELSCubeBinding(Zeros{6} + 8, Zeros{6} + 10), 32);
    assert cube_bound == CommandExecution_Executed;
    let cube_completed = ExecuteBundleTileOperation();
    assert cube_completed && _LastFault == Fault_None;
    assert !_BundleScalarBindings[[0]].valid;
    let cube_destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(cube_destination, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(cube_destination, 0, 1) == Zeros{PTO_XLEN} + 21;
    return 0;
end;
