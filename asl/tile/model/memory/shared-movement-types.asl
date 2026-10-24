// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT-TYPES","surface":"tile","classification":["model","memory","shared-movement-types"],"depends_on":["PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS","PTO-TILE-MODEL-STATE-TYPES"]}
type ScatterLaneOrder of array [[PTO_MODEL_TILE_ELEMENTS]] of Word;
type CorePETileInfos of array [[PTO_MODEL_MEMORY_AGENTS]] of TileInfo;
