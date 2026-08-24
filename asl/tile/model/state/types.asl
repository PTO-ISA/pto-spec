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
    TileBinary_REM
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

type TilePartialOperation of enumeration {
    TilePartial_ADD,
    TilePartial_MUL,
    TilePartial_MAX,
    TilePartial_MIN,
    TilePartial_ARGMAX,
    TilePartial_ARGMIN
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
    TileStorage_Predicate
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
    layout: TileLayout,
    location: TileLocation,
    cube_k_repeat: integer {0..65535},
    cube_n_repeat: integer {0..8192},
    cube_cell_count: integer {0..16384},
    cube_storage_bytes: integer {0..262144},
    payload: TilePayload
};

// Requirement reference PTO-REQ-SHARED-TILE-001: S0..S63 are absolute,
// core-private architectural
// Shared registers. Each record is persistent descriptor-plus-payload state;
// initialized_mask identifies the fixed-offset quarters whose payload has
// been written. All four PEs in one core address the same 64 records.
type SharedTileInfo of record {
    descriptor_valid: boolean,
    allocation_mask: bits(4),
    initialized_mask: bits(4),
    published: boolean,
    tile: TileInfo
};

type SharedTileSnapshot of array [[PTO_SHARED_TILE_COUNT]]
    of SharedTileInfo;
