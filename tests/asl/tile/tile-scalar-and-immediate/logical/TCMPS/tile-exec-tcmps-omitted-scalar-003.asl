// PTO-TEST: {"id":"PTO-AVS-TILE-TCMPS-OMITTED-SCALAR-003","source":"asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl","requirements":["PTO-TCMPS-CONTRACT-001"],"kind":"execution","summary":"Omitted TCMPS B.IOR supplies an all-zero scalar to Tile predicate carriers","pass_condition":"legacy RowMajor and CUBE PredicateCell forms both compare against zero without recording a scalar binding","related_sources":["asl/block/model/dispatch/tile-scalar-schema.asl","asl/tile/model/execution/comparison.asl"]}
pure func TCMPSCubeStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = '01';
    instruction[24:20] = Zeros{5} + 13;
    instruction[31:27] = Zeros{5} + 1;
    return instruction;
end;

pure func TCMPSCubeBinding(source: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = source;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 1;
    instruction[11:9] = '001';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 8, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 7);
    let legacy_started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xdad19181, 32);
    assert legacy_started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE, 0, 1, '0001', TRUE, FALSE, 1, 0, TRUE);
    let legacy_completed = ExecuteBundleTileOperation();
    assert legacy_completed && _LastFault == Fault_None;
    assert !_BundleScalarBindings[[0]].valid;
    let legacy_destination = _BundleTileBindings[[0]].destination;
    assert ReadTilePredicateBit(legacy_destination, 0, 0);
    assert !ReadTilePredicateBit(legacy_destination, 0, 1);

    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        10, 128, 1, 1, TileDataType_FP32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    assert source_ready;
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN});
    MarkTileValidRegionDefined(10);
    let cube_started = ExecuteCommandInstruction(TCMPSCubeStart(), 32);
    assert cube_started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    let cube_bound = ExecuteCommandInstruction(
        TCMPSCubeBinding(Zeros{6} + 10), 32);
    assert cube_bound == CommandExecution_Executed;
    let cube_completed = ExecuteBundleTileOperation();
    assert cube_completed && _LastFault == Fault_None;
    assert !_BundleScalarBindings[[0]].valid;
    let cube_destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[cube_destination]].storage_kind == TileStorage_PredicateCell;
    assert ReadTileElement(cube_destination, 0, 0) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
