// PTO-TEST: {"id":"PTO-AVS-TILE-INDEXED-MEMORY-LANE-CHOICE-REFERENCE-001","source":"asl/tile/model/memory/gather-scatter.asl","requirements":["PTO-REQ-INDEXED-MEMORY-LANE-CHOICE-001"],"kind":"boundary","summary":"The pto-v0 reference profile selects the current logical lane at every indexed-memory permutation position.","pass_condition":"Scatter and gather-CAS choices return position for first, middle, and last legal positions while the shared legality predicate rejects committed or out-of-range positions.","related_sources":["asl/arch/profile/reference-profile.asl","asl/tile/model/memory/atomics.asl"]}
func main() => integer
begin
    assert SelectIndexedMemoryLanePosition(
        IndexedMemoryLaneChoice_ScatterCommit,
        0 as ModelTileElementIndex,
        1 as integer {1..PTO_MODEL_TILE_ELEMENTS}) == 0;
    assert SelectIndexedMemoryLanePosition(
        IndexedMemoryLaneChoice_GatherCASAtomic,
        0 as ModelTileElementIndex,
        2 as integer {1..PTO_MODEL_TILE_ELEMENTS}) == 0;
    assert SelectIndexedMemoryLanePosition(
        IndexedMemoryLaneChoice_GatherCASAtomic,
        1 as ModelTileElementIndex,
        2 as integer {1..PTO_MODEL_TILE_ELEMENTS}) == 1;
    assert SelectIndexedMemoryLanePosition(
        IndexedMemoryLaneChoice_ScatterCommit,
        127 as ModelTileElementIndex,
        PTO_MODEL_TILE_ELEMENTS as
            integer {1..PTO_MODEL_TILE_ELEMENTS}) == 127;
    assert SelectIndexedMemoryLanePosition(
        IndexedMemoryLaneChoice_ScatterCommit,
        (PTO_MODEL_TILE_ELEMENTS - 1) as ModelTileElementIndex,
        PTO_MODEL_TILE_ELEMENTS as
            integer {1..PTO_MODEL_TILE_ELEMENTS}) ==
        PTO_MODEL_TILE_ELEMENTS - 1;

    assert IndexedMemoryLanePositionLegal(
        0 as ModelTileElementIndex,
        1 as integer {1..PTO_MODEL_TILE_ELEMENTS},
        0 as ModelTileElementIndex);
    assert IndexedMemoryLanePositionLegal(
        1 as ModelTileElementIndex,
        2 as integer {1..PTO_MODEL_TILE_ELEMENTS},
        1 as ModelTileElementIndex);
    assert !IndexedMemoryLanePositionLegal(
        1 as ModelTileElementIndex,
        2 as integer {1..PTO_MODEL_TILE_ELEMENTS},
        0 as ModelTileElementIndex);
    assert !IndexedMemoryLanePositionLegal(
        0 as ModelTileElementIndex,
        1 as integer {1..PTO_MODEL_TILE_ELEMENTS},
        1 as ModelTileElementIndex);
    return 0;
end;
