// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-ARCH-TESTTILEALLOCATIONSTATE-STATE-TRANSITION-001","source":"asl/arch/features/tile-allocation.asl","requirements":[],"kind":"state-transition","summary":"Covers Tile Allocation State.","pass_condition":"TestTileAllocationState completes without assertion failure","related_sources":[]}
func TestTileAllocationState()
begin
    ResetProfileState();
    assert PEMaskPopulation(Zeros{4}) == 0;
    assert PEMaskPopulation('1000') == 1;
    assert PEMaskPopulation('0011') == 2;
    assert PEMaskPopulation('0111') == 3;
    assert PEMaskPopulation('1111') == 4;
    assert TileCoreAllocationBytes('0001', 128) == 128;
    assert TileCoreAllocationBytes('0011', 128) == 256;
    assert TileCoreAllocationBytes('1111', 128) == 512;

    ConfigureTile(5, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_ImplementationDefined, TileLocation_Any);
    assert _Tiles[[5]].allocated;
    assert !_Tiles[[5]].contents_defined;
    assert TileDescriptorConfigured(5);
    assert !TileGenericIndexingPermitted(_Tiles[[5]]);
    assert !TileDescriptorLegal(5);

    ConfigureTile(5, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    assert !_Tiles[[5]].contents_defined;
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 9);
    assert _Tiles[[5]].contents_defined;
    assert ReadTileElement(5, 0, 0) == Zeros{PTO_XLEN} + 9;

    // The first allocating Shared write fixes the allocation mask. Later
    // writes may update a subset, but expansion requires a new Sx.
    let shared_tile_id = (Zeros{6} + 60) as SharedTileID;
    let shared_first = AtomicUpdateSharedTile(
        shared_tile_id, _Tiles[[5]], '0011');
    assert shared_first;
    assert SharedTileRecord(shared_tile_id).allocation_mask == '0011';
    assert SharedTileRecord(shared_tile_id).initialized_mask == '0011';
    let shared_subset = AtomicUpdateSharedTile(
        shared_tile_id, _Tiles[[5]], '0001');
    assert shared_subset;
    assert SharedTileRecord(shared_tile_id).allocation_mask == '0011';
    let shared_expansion = AtomicUpdateSharedTile(
        shared_tile_id, _Tiles[[5]], '0100');
    assert !shared_expansion;
    assert SharedTileRecord(shared_tile_id).allocation_mask == '0011';
    assert SharedTileRecord(shared_tile_id).initialized_mask == '0011';
    assert SharedTileCapacityInUse() == 256;
end;
func main() => integer
begin
    ResetProfileState();
    TestTileAllocationState();
    return 0;
end;
