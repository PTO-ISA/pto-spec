// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTSHAREDREGISTERATOMICUPDATES-ATOMICITY-001","source":"asl/tile/model/memory/atomics.asl","requirements":[],"kind":"atomicity","summary":"Covers Shared Register Atomic Updates.","pass_condition":"TestSharedRegisterAtomicUpdates completes without assertion failure","related_sources":[]}
func TestSharedRegisterAtomicUpdates()
begin
    ResetProfileState();
    let primary = (Zeros{6} + 63) as SharedTileID;
    let full = (Zeros{6} + 61) as SharedTileID;
    let partial = (Zeros{6} + 62) as SharedTileID;
    let undefined = Zeros{6} as SharedTileID;
    ConfigureTile(0, 512, 1, 64, 1, 64, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    for element = 0 to 63 do
        _Tiles[[0]].payload[[element]] = Zeros{PTO_XLEN} + element + 1;
        _Tiles[[0]].defined_elements[element] = '1';
    end;
    _Tiles[[0]].defined_valid_elements = 64;
    _Tiles[[0]].contents_defined = TRUE;

    // Empty predicates are true no-ops, including on an uninitialized Sx.
    let empty_update = AtomicUpdateSharedTile(primary, _Tiles[[0]], Zeros{4});
    assert empty_update;
    assert !SharedTileRecord(primary).descriptor_valid;
    assert SharedTileRecord(primary).initialized_mask == Zeros{4};

    // A direct multi-PE fragment candidate may establish internal producer
    // metadata, but it is not whole-parent-ready or consumer-visible without
    // B.ASSEMBLE.LAST.
    let first_update = AtomicUpdateSharedTile(primary, _Tiles[[0]], '1010');
    assert first_update;
    assert SharedTileRecord(primary).descriptor_valid;
    assert SharedTileRecord(primary).initialized_mask == '1010';
    assert SharedTileRecord(primary).tile.payload[[0]] ==
        Zeros{PTO_XLEN} + 1;
    assert SharedTileRecord(primary).tile.payload[[32]] ==
        Zeros{PTO_XLEN} + 33;

    // Compatible internal fragment updates preserve the candidate record but
    // still cannot publish a partial parent.
    var replacement = _Tiles[[0]];
    replacement.payload[[0]] = Zeros{PTO_XLEN} + 0xaa;
    replacement.payload[[16]] = Zeros{PTO_XLEN} + 0xbb;
    replacement.payload[[32]] = Zeros{PTO_XLEN} + 0xcc;
    replacement.payload[[48]] = Zeros{PTO_XLEN} + 0xdd;
    let compatible_update = AtomicUpdateSharedTile(primary, replacement, '1010');
    assert compatible_update;
    assert SharedTileRecord(primary).tile.payload[[0]] ==
        Zeros{PTO_XLEN} + 0xaa;
    assert SharedTileRecord(primary).tile.payload[[32]] ==
        Zeros{PTO_XLEN} + 0xcc;

    assert !SharedTilePublished(primary);
    assert ReadSharedTileWord(primary, 0) ==
        UndefinedSharedTileWord(primary, 0);
    assert ReadSharedTileWord(primary, 16 as PackedTileElementIndex) ==
        UndefinedSharedTileWord(primary, 16 as PackedTileElementIndex);

    // Descriptor mismatch rejects before any selected payload is committed.
    var incompatible = replacement;
    incompatible.columns = 63;
    incompatible.valid_columns = 63;
    let rejected_update = AtomicUpdateSharedTile(primary, incompatible, '0001');
    assert !rejected_update;
    assert SharedTileRecord(primary).tile.columns == 64;
    assert SharedTileRecord(primary).tile.payload[[0]] ==
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
    TLOADShared(primary, shared_bases, shared_strides, 3,
        1, 63, 1, 63, TileDataType_U64, TileLayout_RowMajor, '0001');
    assert _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    assert SharedTileRecord(primary).tile.columns == 64;
    assert SharedTileRecord(primary).tile.payload[[0]] ==
        Zeros{PTO_XLEN} + 0xaa;

    // The first nonzero write fixes the allocation mask. Even a full-mask
    // write cannot expand an existing S register; it must allocate a new Sx.
    ClearFault();
    let expanded_update = AtomicUpdateSharedTile(primary, incompatible, '1111');
    assert !expanded_update;
    assert SharedTileRecord(primary).tile.columns == 64;
    assert SharedTileRecord(primary).allocation_mask == '1010';

    let full_update = AtomicUpdateSharedTile(full, replacement, '1111');
    assert full_update;
    assert SharedTileRecord(full).tile.columns == 64;
    assert SharedTileRecord(full).allocation_mask == '1111';
    assert SharedTileRecord(full).initialized_mask == '1111';

    // Undefined reads do not allocate, initialize, or raise a fault.
    ClearFault();
    let undefined_word = ReadSharedTileWord(undefined, 0);
    assert _LastFault == Fault_None;
    assert !SharedTileRecord(undefined).descriptor_valid;

    // The first publication fixes both the allocation mask and the initialized
    // subset. A complementary mask is expansion, not completion, and rejects.
    var partial_snapshot = _Tiles[[0]];
    partial_snapshot.contents_defined = FALSE;
    partial_snapshot.defined_valid_elements = 0;
    let first_partial = AtomicUpdateSharedTile(partial, partial_snapshot, '1010');
    assert first_partial;
    assert SharedTileRecord(partial).allocation_mask == '1010';
    assert SharedTileRecord(partial).initialized_mask == '1010';
    assert !SharedTileFullyInitialized(partial);
    assert !SharedTilePublished(partial);
    let second_partial = AtomicUpdateSharedTile(partial, partial_snapshot, '0101');
    assert !second_partial;
    assert SharedTileRecord(partial).allocation_mask == '1010';
    assert SharedTileRecord(partial).initialized_mask == '1010';
    assert !SharedTileFullyInitialized(partial);
end;
func main() => integer
begin
    ResetProfileState();
    TestSharedRegisterAtomicUpdates();
    return 0;
end;
