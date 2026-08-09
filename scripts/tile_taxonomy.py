"""Canonical Tile instruction-class and execution-engine taxonomy."""

from __future__ import annotations

from collections.abc import Mapping


TILE_CLASS_ENUM = {
    "elementwise-tile-tile": "TileClass_ElementwiseTileTile",
    "tile-scalar-and-immediate": "TileClass_TileScalarAndImmediate",
    "reduce-and-expand": "TileClass_ReduceAndExpand",
    "memory-and-data-movement": "TileClass_MemoryAndDataMovement",
    "matrix-and-matrix-vector": "TileClass_MatrixAndMatrixVector",
    "layout-and-rearrangement": "TileClass_LayoutAndRearrangement",
    "irregular-and-complex": "TileClass_IrregularAndComplex",
}
TILE_CLASSIFICATIONS = frozenset(TILE_CLASS_ENUM)

TILE_ENGINES = frozenset({"VEC", "TLSU", "CUBE", "SFU"})
TILE_ENGINE_ENUM = {
    engine: f"TileEngine_{engine}" for engine in sorted(TILE_ENGINES)
}

VEC_ALLOWED_CLASSIFICATIONS = frozenset(
    {"elementwise-tile-tile", "tile-scalar-and-immediate"}
)
TEPL_CARRIER_ENGINES = frozenset({"VEC", "SFU"})


def derive_tile_catalog_record(
    record: Mapping[str, object], *, classification: str, engine: object
) -> dict[str, object]:
    """Project class and engine into a Tile catalog record from its ASL unit."""

    duplicate_fields = {"classification", "engine"} & record.keys()
    if duplicate_fields:
        raise ValueError(
            "Tile catalog record duplicates unit metadata fields: "
            f"{', '.join(sorted(duplicate_fields))}"
        )
    if classification not in TILE_CLASSIFICATIONS:
        raise ValueError(f"unknown Tile classification {classification!r}")
    if engine not in TILE_ENGINES:
        raise ValueError(f"unknown or missing Tile engine {engine!r}")
    projected = dict(record)
    projected["classification"] = classification
    projected["engine"] = engine
    return projected
