// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-INDEXED-MEMORY-LANE-CHOICE","surface":"arch","classification":["data-types","indexed-memory-lane-choice"],"depends_on":["PTO-ARCH-DATA-TYPES-INTEGER"]}

type IndexedMemoryLaneChoiceKind of enumeration {
    IndexedMemoryLaneChoice_ScatterCommit,
    IndexedMemoryLaneChoice_GatherCASAtomic
};

readonly func IndexedMemoryLanePositionLegal(
    position: ModelTileElementIndex,
    lane_count: integer {1..PTO_MODEL_TILE_ELEMENTS},
    selected: ModelTileElementIndex) => boolean
begin
    return selected >= position && selected < lane_count;
end;

readonly impdef func SelectIndexedMemoryLanePosition(
    kind: IndexedMemoryLaneChoiceKind,
    position: ModelTileElementIndex,
    lane_count: integer {1..PTO_MODEL_TILE_ELEMENTS})
    => ModelTileElementIndex
begin
    return position;
end;
