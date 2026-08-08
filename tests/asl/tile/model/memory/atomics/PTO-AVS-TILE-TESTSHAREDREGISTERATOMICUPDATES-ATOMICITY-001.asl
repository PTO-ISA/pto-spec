// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTSHAREDREGISTERATOMICUPDATES-ATOMICITY-001","source":"asl/tile/model/memory/atomics.asl","requirements":[],"kind":"atomicity","summary":"migrated independent behavior point for TestSharedRegisterAtomicUpdates","pass_condition":"TestSharedRegisterAtomicUpdates completes without assertion failure","related_sources":[]}
func TestSharedRegisterAtomicUpdates()
begin
    ResetProfileState();
    ConfigureTile(0, 512, 1, 64, 1, 64, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    for element = 0 to 63 do
        _Tiles[[0]].payload[[element]] = Zeros{PTO_XLEN} + element + 1;
        _Tiles[[0]].defined_elements[element] = '1';
    end;
    _Tiles[[0]].defined_valid_elements = 64;
    _Tiles[[0]].contents_defined = TRUE;

    // Empty predicates are true no-ops, including on an uninitialized Sx.
    let empty_update = AtomicUpdateSharedTile(
        Zeros{8} + 255, _Tiles[[0]], Zeros{4});
    assert empty_update;
    assert !SharedTileRecord(Zeros{8} + 255).descriptor_valid;
    assert SharedTileRecord(Zeros{8} + 255).initialized_mask == Zeros{4};

    // A partial first write establishes the descriptor and only its selected
    // fixed-offset quarters.
    let first_update = AtomicUpdateSharedTile(
        Zeros{8} + 255, _Tiles[[0]], '0101');
    assert first_update;
    assert SharedTileRecord(Zeros{8} + 255).descriptor_valid;
    assert SharedTileRecord(Zeros{8} + 255).initialized_mask == '0101';
    assert SharedTileRecord(Zeros{8} + 255).tile.payload[[0]] ==
        Zeros{PTO_XLEN} + 1;
    assert SharedTileRecord(Zeros{8} + 255).tile.payload[[32]] ==
        Zeros{PTO_XLEN} + 33;

    // Compatible partial updates preserve unselected quarters.
    var replacement = _Tiles[[0]];
    replacement.payload[[0]] = Zeros{PTO_XLEN} + 0xaa;
    replacement.payload[[16]] = Zeros{PTO_XLEN} + 0xbb;
    replacement.payload[[32]] = Zeros{PTO_XLEN} + 0xcc;
    replacement.payload[[48]] = Zeros{PTO_XLEN} + 0xdd;
    let compatible_update = AtomicUpdateSharedTile(
        Zeros{8} + 255, replacement, '0101');
    assert compatible_update;
    assert SharedTileRecord(Zeros{8} + 255).tile.payload[[0]] ==
        Zeros{PTO_XLEN} + 0xaa;
    assert SharedTileRecord(Zeros{8} + 255).tile.payload[[32]] ==
        Zeros{PTO_XLEN} + 0xcc;

    let materialized = MaterializeSharedTile(Zeros{8} + 255, '1111');
    assert materialized.payload[[0]] == Zeros{PTO_XLEN} + 0xaa;
    assert materialized.payload[[16]] ==
        UndefinedSharedTileWord(Zeros{8} + 255, 16 as ModelTileElementIndex);

    // Descriptor mismatch rejects before any selected payload is committed.
    var incompatible = replacement;
    incompatible.columns = 63;
    incompatible.valid_columns = 63;
    let rejected_update = AtomicUpdateSharedTile(
        Zeros{8} + 255, incompatible, '0001');
    assert !rejected_update;
    assert SharedTileRecord(Zeros{8} + 255).tile.columns == 64;
    assert SharedTileRecord(Zeros{8} + 255).tile.payload[[0]] ==
        Zeros{PTO_XLEN} + 0xaa;

    // A partial TLOAD descriptor mismatch is rejected before probing memory
    // or changing any Shared descriptor or payload state.
    ResetMemoryExecution();
    ClearFault();
    var shared_bases: CorePEWords;
    var shared_strides: CorePEWords;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        shared_bases[[pe]] = Zeros{PTO_XLEN};
        shared_strides[[pe]] = Zeros{PTO_XLEN} + 63;
    end;
    TLOADShared(Zeros{8} + 255, shared_bases, shared_strides, 3,
        1, 63, 1, 63, TileDataType_U64, TileLayout_RowMajor, '0001');
    assert _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    assert SharedTileRecord(Zeros{8} + 255).tile.columns == 64;
    assert SharedTileRecord(Zeros{8} + 255).tile.payload[[0]] ==
        Zeros{PTO_XLEN} + 0xaa;

    // The first nonzero write fixes the allocation mask. Even a full-mask
    // write cannot expand an existing S register; it must allocate a new Sx.
    ClearFault();
    let expanded_update = AtomicUpdateSharedTile(
        Zeros{8} + 255, incompatible, '1111');
    assert !expanded_update;
    assert SharedTileRecord(Zeros{8} + 255).tile.columns == 64;
    assert SharedTileRecord(Zeros{8} + 255).allocation_mask == '0101';

    let full_update = AtomicUpdateSharedTile(
        Zeros{8} + 253, replacement, '1111');
    assert full_update;
    assert SharedTileRecord(Zeros{8} + 253).tile.columns == 64;
    assert SharedTileRecord(Zeros{8} + 253).allocation_mask == '1111';
    assert SharedTileRecord(Zeros{8} + 253).initialized_mask == '1111';

    // Undefined reads do not allocate, initialize, or raise a fault.
    ClearFault();
    let undefined_word = ReadSharedTileWord(Zeros{8}, 0);
    assert _LastFault == Fault_None;
    assert !SharedTileRecord(Zeros{8}).descriptor_valid;

    // The first publication fixes both the allocation mask and the initialized
    // subset. A complementary mask is expansion, not completion, and rejects.
    var partial_snapshot = _Tiles[[0]];
    partial_snapshot.contents_defined = FALSE;
    partial_snapshot.defined_valid_elements = 0;
    let first_partial = AtomicUpdateSharedTile(
        Zeros{8} + 254, partial_snapshot, '0101');
    assert first_partial;
    assert SharedTileRecord(Zeros{8} + 254).allocation_mask == '0101';
    assert SharedTileRecord(Zeros{8} + 254).initialized_mask == '0101';
    assert SharedTileFullyInitialized(Zeros{8} + 254);
    let second_partial = AtomicUpdateSharedTile(
        Zeros{8} + 254, partial_snapshot, '1010');
    assert !second_partial;
    assert SharedTileRecord(Zeros{8} + 254).allocation_mask == '0101';
    assert SharedTileRecord(Zeros{8} + 254).initialized_mask == '0101';
    assert SharedTileFullyInitialized(Zeros{8} + 254);
end;
func main() => integer
begin
    ResetProfileState();
    TestSharedRegisterAtomicUpdates();
    return 0;
end;
