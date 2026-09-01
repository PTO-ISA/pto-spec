// PTO-TEST: {"id":"PTO-AVS-BLOCK-PREDICATE-DESTINATION-REUSE-002","source":"asl/block/model/dispatch/predicate-destination.asl","requirements":["PTO-B-ASSEMBLE-LOCAL-GENERATION-001","PTO-TCMP-CONTRACT-001","PTO-TSEL-CONTRACT-001"],"kind":"execution","summary":"Special predicate and CUBE select allocators reuse a validated Local generation destination","pass_condition":"a destination already resolved by B.ASSEMBLE remains selected without allocating or reconfiguring a second Tile","related_sources":["asl/block/model/operands/local-generation.asl","asl/tile/model/state/allocation.asl"]}
readonly func AllocatedTileCountForPredicateReuse() => integer
begin
    var count: integer = 0;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if _Tiles[[index]].allocated then count = count + 1; end;
    end;
    return count;
end;

func main() => integer
begin
    ResetProfileState();
    let compare_source = ConfigureCubeTile(
        10, 128, 1, 1, TileDataType_FP32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let predicate_destination = ConfigurePredicateCell(
        0, 128, 1, 1, TileDataType_FP32, TileLayout_CUBE_M32);
    assert compare_source && predicate_destination;
    SetBundleTileBinding(
        0, TRUE, 0, 1, '0001', TRUE, FALSE, 10, 0, TRUE);
    _BundleTileBindings[[0]].destination_allocated_by_bundle = TRUE;
    _BundleTileBindings[[0]].destination_reused_by_generation = TRUE;
    _BundleTileBindings[[0]].destination_assemble.valid = TRUE;
    let predicate_count = AllocatedTileCountForPredicateReuse();
    let predicate_resolved = ResolveBundlePredicateDestination();
    assert predicate_resolved && _LastFault == Fault_None;
    assert _BundleTileBindings[[0]].destination == 0;
    assert AllocatedTileCountForPredicateReuse() == predicate_count;

    ResetProfileState();
    let select_destination = ConfigureCubeTile(
        0, 128, 1, 1, TileDataType_FP32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let source_true = ConfigureCubeTile(
        10, 128, 1, 1, TileDataType_FP32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let source_false = ConfigureCubeTile(
        11, 128, 1, 1, TileDataType_FP32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    assert select_destination && source_true && source_false;
    SetBundleTileBinding(
        0, TRUE, 0, 1, '0001', TRUE, TRUE, 10, 11, TRUE);
    _BundleTileBindings[[0]].destination_allocated_by_bundle = TRUE;
    _BundleTileBindings[[0]].destination_reused_by_generation = TRUE;
    _BundleTileBindings[[0]].destination_assemble.valid = TRUE;
    let select_count = AllocatedTileCountForPredicateReuse();
    let select_resolved = ResolveBundleCUBESelectDestination(22);
    assert select_resolved && _LastFault == Fault_None;
    assert _BundleTileBindings[[0]].destination == 0;
    assert AllocatedTileCountForPredicateReuse() == select_count;
    return 0;
end;
