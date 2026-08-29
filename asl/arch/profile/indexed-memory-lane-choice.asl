// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-INDEXED-MEMORY-LANE-CHOICE","surface":"arch","classification":["profile","indexed-memory-lane-choice"],"depends_on":["PTO-ARCH-DATA-TYPES-INDEXED-MEMORY-LANE-CHOICE"]}

readonly implementation func SelectIndexedMemoryLanePosition(
    kind: IndexedMemoryLaneChoiceKind,
    position: ModelTileElementIndex,
    lane_count: integer {1..PTO_MODEL_TILE_ELEMENTS})
    => ModelTileElementIndex
begin
    assert position < lane_count;
    return position;
end;
