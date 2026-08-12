// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-STATE-TYPES","surface":"block","classification":["model","state","types"],"depends_on":["PTO-ARCH-DATA-TYPES-FAULT"]}
type BundleKind of enumeration {
    BundleKind_Standard,
    BundleKind_Floating,
    BundleKind_System,
    BundleKind_MachineParallel,
    BundleKind_MachineSequential,
    BundleKind_TileElement,
    BundleKind_TileMemory,
    BundleKind_TileMatrix,
    BundleKind_FrameTemplate
};

type BundleTransfer of enumeration {
    BundleTransfer_Fallthrough,
    BundleTransfer_Direct,
    BundleTransfer_Conditional,
    BundleTransfer_Call,
    BundleTransfer_Return,
    BundleTransfer_Indirect,
    BundleTransfer_IndirectCall
};

// A bundle start always installs one descriptor. Control-only starts retain
// their exact form and modifiers, while operation-bearing starts additionally
// carry the selector consumed when the bundle is committed.
// PTO-REQ-BUNDLE-OPERATION-001: exact start fields survive decode and commit.
type BundleOperationClass of enumeration {
    BundleOperation_Control,
    BundleOperation_Machine,
    BundleOperation_TileElement,
    BundleOperation_TileMemory,
    BundleOperation_TileMatrix,
    BundleOperation_FixedPoint
};

type BundleOperationDescriptor of record {
    valid: boolean,
    form_identity: bits(7),
    operation_class: BundleOperationClass,
    selector_valid: boolean,
    selector: bits(10),
    data_type_valid: boolean,
    data_type: bits(5),
    mode_valid: boolean,
    mode: bits(2),
    branch_type_valid: boolean,
    branch_type: bits(3)
};

type BundleScalarBinding of record {
    valid: boolean,
    destination: Reg5Selector,
    source0: Reg5Selector,
    source1: Reg5Selector,
    source2: Reg5Selector,
    source_count: integer {0..3}
};

type BundleTileBinding of record {
    valid: boolean,
    destination_valid: boolean,
    destination: TileIndex,
    destination_hand: bits(2),
    destination_allocated_by_bundle: boolean,
    destination_size: integer {0..15},
    pe_mask: bits(4),
    source0_valid: boolean,
    source1_valid: boolean,
    source0: TileIndex,
    source1: TileIndex,
    last: boolean
};

type BundleSharedBinding of record {
    valid: boolean,
    shared_id: bits(8),
    size_code: integer {0..7},
    pe_mask: bits(4),
    consumed: boolean
};

type BundleControlAttributes of record {
    trap_enabled: boolean,
    atomic: boolean,
    acquire: boolean,
    release: boolean,
    far: boolean,
    direct_register: boolean
};

type BundleDataAttributes of record {
    data_type: bits(5),
    data_layout: bits(5),
    pad_value: bits(2),
    conversion_mode: bits(3),
    rounding_mode: bits(3),
    saturating: boolean,
    canonicalize: boolean
};

// B.FPATR is a complete-bundle post-processing descriptor.  `valid` tracks
// encoded presence separately from the field values so omission, duplicate
// headers, and encoded zero remain distinct at bundle commit.
type BundleFixedPointAttributes of record {
    valid: boolean,
    pre_quant_mode: bits(6),
    relu_mode: bits(3),
    group_n_code: bits(4),
    row_max_en: boolean,
    group_max_en: boolean,
    row_max_init: boolean,
    max_abs_en: boolean,
    // Shared-input logical transpose controls.  They are latched with the
    // complete-bundle B.FPATR descriptor and validated against resolved
    // operand bindings at matrix dispatch time.
    trans_a: boolean,
    trans_b: boolean
};

// ACR0 is the root ring. The active profile defines permissions and the
// implemented Access Control Ring subtree.
type AccessControlRing of integer {0..15};
type TemporaryQueueSnapshot of array [[PTO_TEMPORARY_QUEUE_DEPTH]] of Word;
type PredicateSnapshot of array [[PTO_PREDICATE_REGISTER_COUNT]]
    of PredicateWord;
type BundleDimensionSnapshot of array [[PTO_BUNDLE_DIMENSION_COUNT]] of Word;
type BundleScalarBindingSnapshot of array [[PTO_BUNDLE_SCALAR_BINDING_COUNT]]
    of BundleScalarBinding;
type BundleTileBindingSnapshot of array [[PTO_BUNDLE_TILE_BINDING_COUNT]]
    of BundleTileBinding;
type BundleSharedBindingSnapshot of array [[4]] of BundleSharedBinding;
