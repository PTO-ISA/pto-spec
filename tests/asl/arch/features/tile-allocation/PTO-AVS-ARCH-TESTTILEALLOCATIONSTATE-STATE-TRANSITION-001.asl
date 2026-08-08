// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-ARCH-TESTTILEALLOCATIONSTATE-STATE-TRANSITION-001","source":"asl/arch/features/tile-allocation.asl","requirements":[],"kind":"state-transition","summary":"migrated independent behavior point for TestTileAllocationState","pass_condition":"TestTileAllocationState completes without assertion failure","related_sources":[]}
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
    let shared_first = AtomicUpdateSharedTile(
        Zeros{8} + 60, _Tiles[[5]], '0011');
    assert shared_first;
    assert SharedTileRecord(Zeros{8} + 60).allocation_mask == '0011';
    assert SharedTileRecord(Zeros{8} + 60).initialized_mask == '0011';
    let shared_subset = AtomicUpdateSharedTile(
        Zeros{8} + 60, _Tiles[[5]], '0001');
    assert shared_subset;
    assert SharedTileRecord(Zeros{8} + 60).allocation_mask == '0011';
    let shared_expansion = AtomicUpdateSharedTile(
        Zeros{8} + 60, _Tiles[[5]], '0100');
    assert !shared_expansion;
    assert SharedTileRecord(Zeros{8} + 60).allocation_mask == '0011';
    assert SharedTileRecord(Zeros{8} + 60).initialized_mask == '0011';
    assert SharedTileCapacityInUse() == 512;
end;
func main() => integer
begin
    ResetProfileState();
    TestTileAllocationState();
    return 0;
end;
