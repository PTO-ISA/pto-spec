<!-- GENERATED FROM: asl/tile/model/state/types.asl -->
# Types

**Normative ASL source:** `asl/tile/model/state/types.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-STATE-TYPES}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-state-types-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the vocabulary types of the Tile model. It declares no state and no transitions.

It covers three groups:

- Operation selectors, such as `TileBinaryOperation`, `TileUnaryOperation`, `TileComparison`, `TileReductionOperation`, and `TileExpandOperation`.
- The decoded operand carrier `TileInstructionOperands` and its defaults.
- The storage records `TileInfo` and `SharedTileInfo`, with their payload and definedness carriers.

<!-- PTO-READER-BLOCK: tile-model-state-types-concepts role=concepts-state -->
## Concepts and visible state

`TileInfo` is the complete record of one Tile. Its fields fall into four groups:

- Lifecycle: `allocated` and `storage_kind` (Numeric, Predicate, or PredicateCell).
- Definedness: `contents_defined`, the per-element bitmap `defined_elements`, the count `defined_valid_elements`, and the packed bitmap `packed_defined_elements` of 524288 bits.
- Descriptor: `capacity_bytes`, `rows`, `columns`, `valid_rows`, `valid_columns`, `data_type`, `predicate_basis_type`, and `layout`.
- CUBE geometry: `cube_k_repeat`, `cube_n_repeat`, `cube_cell_count`, and `cube_storage_bytes`.

The `payload` is an array of `PTO_MODEL_TILE_ELEMENTS` 64-bit Words.

`SharedTileInfo` wraps one `TileInfo` with Shared-only metadata: `descriptor_valid`, `allocation_mask`, `initialized_mask`, `whole_parent_ready`, and `published`.

<!-- PTO-READER-BLOCK: tile-model-state-types-rules role=rules-interactions -->
## Rules and interactions

`TileInstructionOperands` is one uniform record for every direct Tile instruction. It holds up to three destinations, nine sources, an address, scalars, numeric fields, an axis, a comparison, a flag, and a numeric-control selection. Each catalog binding reads only the fields its operation names; unused fields have no architectural effect.

`DefaultTileInstructionOperands` sets register, scalar, natural, diagonal, byte-count, and selected-byte fields to 0, the `positive` fields to 1, `sort_width` to 32, `axis` to Row, and `comparison` to EQ; its numeric control sets `use_operation_default` to TRUE with a stored RNE rounding mode and saturation off.

Design point: `TileBinary_EXPDIF` is a selector, but the source comment states that TEXPDIF is a dedicated typed binary operation that must not enter the generic integer, Tile-binary, or Tile-scalar execution helpers. `TileExpand_EXPDIF` is a separate expand selector.

Design point: `SharedTileInfo` separates four facts. `allocation_mask` is which PEs participate in the parent, `initialized_mask` is which producers have written it, `whole_parent_ready` is hardware-maintained parent readiness, and `published` is visibility. The source comment states that readiness is independent of both the producer mask and the consumer participation mask.

<!-- PTO-READER-BLOCK: tile-model-state-types-boundaries role=boundaries -->
## Architectural boundaries

`TileLayout` and `TileDataType` are defined by the architecture data-type owner, not here.

Two capacities coexist in `TileInfo`. `PackedTileDefinedElements` has 524288 bits, one per logical element of a 256 KiB four-bit Tile. The Word payload has only `PTO_MODEL_TILE_ELEMENTS` slots, so large or four-bit Tiles pack several logical elements into each Word. `PTO_MODEL_TILE_ELEMENTS` is a model representation bound; 524288 covers the largest architectural logical element count.

`TileExecutionStatus` has only two values, `TileExecution_Executed` and `TileExecution_Rejected`; bundle Tile execution uses it as its step status.

<!-- PTO-READER-BLOCK: tile-model-state-types-example role=example-usage -->
## Non-normative reading example

A freshly allocated FP32 Tile of 4096 bytes and 16 columns reads as follows:

| Field | Value |
| --- | --- |
| `allocated` | TRUE |
| `storage_kind` | `TileStorage_Numeric` |
| `contents_defined` | FALSE |
| `defined_valid_elements` | 0 |
| `capacity_bytes` | 4096 |
| `rows` x `columns` | 64 x 16 |
| `cube_cell_count` | 0 |

The descriptor is complete, but no payload element is readable yet.

<!-- PTO-READER-BLOCK: tile-model-state-types-related role=related-owners-navigation -->
## Related owners

- [Local registers](local-registers.md) declares the arrays of these records.
- [Allocation](allocation.md) fills `TileInfo` descriptors.
- [Packed boundary](../definedness/packed-boundary.md) explains the carrier and packed definedness representation.
- [Tile data types](../../../arch/data-types/tile-data-types.md) defines `TileDataType` and `TileLayout`.
- [Tile instruction operands](../../../block/model/dispatch/tile-instruction-operands.md) fills the operand carrier from a bundle.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/state/types.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-STATE-TYPES","surface":"tile","classification":["model","state","types"],"depends_on":["PTO-SCALAR-MODEL-TYPES-OPERATIONS"]}
type TileBinaryOperation of enumeration {
    TileBinary_ADD,
    TileBinary_SUB,
    TileBinary_MUL,
    TileBinary_MAX,
    TileBinary_MIN,
    TileBinary_AND,
    TileBinary_OR,
    TileBinary_XOR,
    TileBinary_SHL,
    TileBinary_SHR,
    TileBinary_DIV,
    TileBinary_REM,
    // TEXPDIF is a dedicated typed binary operation. It must not enter the
    // generic integer, Tile-binary, or Tile-scalar execution helpers.
    TileBinary_EXPDIF
};

type TileUnaryOperation of enumeration {
    TileUnary_ABS,
    TileUnary_NOT,
    TileUnary_NEG,
    TileUnary_RELU,
    TileUnary_SQRT,
    TileUnary_LOG,
    TileUnary_RECIP,
    TileUnary_EXP,
    TileUnary_RSQRT
};

type TileComparison of enumeration {
    TileComparison_EQ,
    TileComparison_NE,
    TileComparison_LT,
    TileComparison_LE,
    TileComparison_GT,
    TileComparison_GE
};

type TileAxis of enumeration {
    TileAxis_Row,
    TileAxis_Column
};

type TileReductionOperation of enumeration {
    TileReduction_SUM,
    TileReduction_PRODUCT,
    TileReduction_MIN,
    TileReduction_MAX,
    TileReduction_ARGMIN,
    TileReduction_ARGMAX
};

type TileExpandOperation of enumeration {
    TileExpand_COPY,
    TileExpand_ADD,
    TileExpand_SUB,
    TileExpand_MUL,
    TileExpand_DIV,
    TileExpand_MAX,
    TileExpand_MIN,
    TileExpand_EXPDIF
};

type TileExecutionStatus of enumeration {
    TileExecution_Executed,
    TileExecution_Rejected
};

type TileStorageKind of enumeration {
    TileStorage_Numeric,
    TileStorage_Predicate,
    TileStorage_PredicateCell
};

// Uniform decoded operand carrier for direct tile instructions. Catalog
// bindings select only the fields named by each operation; unused fields have
// no architectural effect.
type TileInstructionOperands of record {
    destination0: TileIndex,
    destination1: TileIndex,
    destination2: TileIndex,
    source0: TileIndex,
    source1: TileIndex,
    source2: TileIndex,
    source3: TileIndex,
    source4: TileIndex,
    source5: TileIndex,
    source6: TileIndex,
    source7: TileIndex,
    source8: TileIndex,
    address: Word,
    scalar0: Word,
    scalar1: Word,
    post_quant_param: Word,
    post_lrelu_param: Word,
    natural0: integer {0..65535},
    natural1: integer {0..65535},
    positive0: integer {1..65535},
    positive1: integer {1..65535},
    positive2: integer {1..65535},
    positive3: integer {1..65535},
    diagonal: integer {-65535..65535},
    byte_count: integer {0..262144},
    selected_byte: integer {0..3},
    sort_width: integer {1..64},
    axis: TileAxis,
    comparison: TileComparison,
    flag0: boolean,
    numeric_control: TileNumericSelection
};

pure func DefaultTileInstructionOperands() => TileInstructionOperands
begin
    return TileInstructionOperands {
        destination0 = 0,
        destination1 = 0,
        destination2 = 0,
        source0 = 0,
        source1 = 0,
        source2 = 0,
        source3 = 0,
        source4 = 0,
        source5 = 0,
        source6 = 0,
        source7 = 0,
        source8 = 0,
        address = Zeros{PTO_XLEN},
        scalar0 = Zeros{PTO_XLEN},
        scalar1 = Zeros{PTO_XLEN},
        post_quant_param = Zeros{PTO_XLEN},
        post_lrelu_param = Zeros{PTO_XLEN},
        natural0 = 0,
        natural1 = 0,
        positive0 = 1,
        positive1 = 1,
        positive2 = 1,
        positive3 = 1,
        diagonal = 0,
        byte_count = 0,
        selected_byte = 0,
        sort_width = 32,
        axis = TileAxis_Row,
        comparison = TileComparison_EQ,
        flag0 = FALSE,
        numeric_control = TileNumericSelection {
            use_operation_default = TRUE,
            rounding_mode = NumericRound_RNE,
            saturating = FALSE
        }
    };
end;

type TilePayload of array [[PTO_MODEL_TILE_ELEMENTS]] of Word;
type PackedTileDefinedElements of bits(524288);
type RelativeTileHandSnapshot of array [[16]] of TileIndex;
type RelativeTileSnapshot of array [[4]] of RelativeTileHandSnapshot;
type RelativeTileValiditySnapshot of array [[4]] of bits(16);

type TileInfo of record {
    allocated: boolean,
    storage_kind: TileStorageKind,
    contents_defined: boolean,
    defined_elements: bits(PTO_MODEL_TILE_ELEMENTS),
    defined_valid_elements: integer {0..524288},
    packed_defined_elements: PackedTileDefinedElements,
    capacity_bytes: integer {0..262144},
    rows: integer {0..65535},
    columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType,
    predicate_basis_type: TileDataType,
    layout: TileLayout,
    cube_k_repeat: integer {0..65535},
    cube_n_repeat: integer {0..8192},
    cube_cell_count: integer {0..16384},
    cube_storage_bytes: integer {0..262144},
    payload: TilePayload
};

// Requirement reference PTO-REQ-SHARED-TILE-001: S0..S63 are absolute,
// core-private architectural
// Shared registers. Each record is persistent descriptor-plus-payload state;
// initialized_mask identifies producer-written coverage metadata.
// whole_parent_ready is hardware-maintained parent-level readiness; it is
// independent of the producer mask and consumer participation mask. All four
// PEs in one core address the same 64 records.
type SharedTileInfo of record {
    descriptor_valid: boolean,
    allocation_mask: bits(4),
    initialized_mask: bits(4),
    whole_parent_ready: boolean,
    published: boolean,
    tile: TileInfo
};

type SharedTileSnapshot of array [[PTO_SHARED_TILE_COUNT]]
    of SharedTileInfo;
```
<!-- GENERATED-ASL-END: unit -->
