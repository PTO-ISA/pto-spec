// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-INTEGER","surface":"arch","classification":["data-types","integer"],"depends_on":["PTO-ARCH-FEATURES-TILE-ALLOCATION"]}
// Requirement references: PTO-REQ-STATE-001, PTO-REQ-TILE-001,
// PTO-REQ-FAULT-001, PTO-REQ-MEMORY-TSO-001.

type Word of bits(PTO_XLEN);
type DoubleWord of bits(PTO_XLEN * 2);
type HalfWord of bits(32);
type Byte of bits(8);
type PredicateWord of bits(PTO_PREDICATE_WIDTH);
type GPRIndex of integer {0..PTO_ABSOLUTE_GPR_COUNT-1};
type PERegisterFile of array [[PTO_ABSOLUTE_GPR_COUNT]] of Word;
type CorePEWords of array [[PTO_MODEL_MEMORY_AGENTS]] of Word;
type Reg5Selector of integer {0..31};
type TileIndex of integer {0..PTO_TILE_REGISTER_COUNT-1};
type SharedTileIndex of integer {0..PTO_SHARED_TILE_COUNT-1};
type TemporaryQueueIndex of integer {0..PTO_TEMPORARY_QUEUE_DEPTH-1};
type PredicateIndex of integer {0..PTO_PREDICATE_REGISTER_COUNT-1};
type BundleDimensionIndex of integer {0..PTO_BUNDLE_DIMENSION_COUNT-1};
type BundleScalarBindingIndex of integer {0..PTO_BUNDLE_SCALAR_BINDING_COUNT-1};
type BundleTileBindingIndex of integer {0..PTO_BUNDLE_TILE_BINDING_COUNT-1};
type BundleSharedBindingIndex of integer {0..3};
type TileBaseIndex of integer {0..PTO_TILE_BASE_COUNT-1};
type ModelTileElementIndex of integer {0..PTO_MODEL_TILE_ELEMENTS-1};
type PackedTileElementIndex of integer {0..524287};
type PackedTileCarrierIndex of integer {0..PTO_MODEL_TILE_ELEMENTS-1};
type PackedTileNibbleIndex of integer {0..15};
type ModelAddress of integer {0..PTO_MODEL_MEMORY_BYTES-1};
type SystemRegisterAddress of bits(24);
type SystemRegisterFileIndex of integer {0..65535};
type TrapNumber of bits(6);
type InterruptID of integer {0..63};
