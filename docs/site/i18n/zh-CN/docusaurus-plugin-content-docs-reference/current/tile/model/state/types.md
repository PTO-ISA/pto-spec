<!-- GENERATED FROM: asl/tile/model/state/types.asl -->
# Types

**Normative ASL source:** `asl/tile/model/state/types.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-STATE-TYPES}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-state-types-purpose role=purpose-scope -->
## 用途与范围

本单元定义 Tile 模型的词汇类型。它不声明任何状态，也不声明任何转换。

它涵盖三组内容：

- 操作选择子，例如 `TileBinaryOperation`、`TileUnaryOperation`、`TileComparison`、`TileReductionOperation` 和 `TileExpandOperation`。
- 已译码操作数载体 `TileInstructionOperands` 及其默认值。
- 存储记录 `TileInfo` 和 `SharedTileInfo`，以及它们的载荷与已定义性载体。

<!-- PTO-READER-BLOCK: tile-model-state-types-concepts role=concepts-state -->
## 概念与可见状态

`TileInfo` 是一个 Tile 的完整记录。其字段分为四组：

- 生命周期：`allocated` 和 `storage_kind`（Numeric、Predicate 或 PredicateCell）。
- 已定义性：`contents_defined`、逐元素位图 `defined_elements`、计数 `defined_valid_elements`，以及 524288 位的打包位图 `packed_defined_elements`。
- 描述符：`capacity_bytes`、`rows`、`columns`、`valid_rows`、`valid_columns`、`data_type`、`predicate_basis_type` 和 `layout`。
- CUBE 几何：`cube_k_repeat`、`cube_n_repeat`、`cube_cell_count` 和 `cube_storage_bytes`。

`payload` 是由 `PTO_MODEL_TILE_ELEMENTS` 个 64 位 Word 组成的数组。

`SharedTileInfo` 用仅 Shared 使用的元数据包装一个 `TileInfo`：`descriptor_valid`、`allocation_mask`、`initialized_mask`、`whole_parent_ready` 和 `published`。

<!-- PTO-READER-BLOCK: tile-model-state-types-rules role=rules-interactions -->
## 规则与交互

`TileInstructionOperands` 是所有直接 Tile 指令共用的统一记录。它最多保存三个目标、九个源，以及一个地址、若干标量、数值字段、一个轴、一个比较、一个标志和一个数值控制选择。每个目录绑定只读取其操作所指明的字段；未使用的字段没有架构效果。

`DefaultTileInstructionOperands` 把寄存器、标量、natural、diagonal、字节计数和所选字节字段设为 0，把 `positive` 字段设为 1，`sort_width` 设为 32，`axis` 设为 Row，`comparison` 设为 EQ；其数值控制把 `use_operation_default` 设为 TRUE，保存的舍入模式为 RNE，饱和关闭。

设计要点：`TileBinary_EXPDIF` 是一个选择子，但源注释说明 TEXPDIF 是专用的类型化二元操作，不得进入通用整数、Tile 二元或 Tile 标量执行辅助函数。`TileExpand_EXPDIF` 是一个独立的扩展选择子。

设计要点：`SharedTileInfo` 区分四个事实。`allocation_mask` 表示哪些 PE 参与父级，`initialized_mask` 表示哪些生产者已写入它，`whole_parent_ready` 是由硬件维护的父级就绪状态，`published` 表示可见性。源注释说明就绪既独立于生产者掩码，也独立于消费者参与掩码。

<!-- PTO-READER-BLOCK: tile-model-state-types-boundaries role=boundaries -->
## 架构边界

`TileLayout` 和 `TileDataType` 由架构数据类型所有者定义，而不是在这里定义。

`TileInfo` 中并存两种容量。`PackedTileDefinedElements` 有 524288 位，对应 256 KiB 四位 Tile 的每个逻辑元素各一位。Word 载荷只有 `PTO_MODEL_TILE_ELEMENTS` 个槽位，因此大型 Tile 或四位 Tile 会在每个 Word 中打包多个逻辑元素。`PTO_MODEL_TILE_ELEMENTS` 是模型表示界限；524288 覆盖最大的架构逻辑元素数。

`TileExecutionStatus` 只有两个值，`TileExecution_Executed` 和 `TileExecution_Rejected`；指令束 Tile 执行把它用作步骤状态。

<!-- PTO-READER-BLOCK: tile-model-state-types-example role=example-usage -->
## 非规范阅读示例

一个新分配的 4096 字节、16 列 FP32 Tile 的记录如下：

| 字段 | 值 |
| --- | --- |
| `allocated` | TRUE |
| `storage_kind` | `TileStorage_Numeric` |
| `contents_defined` | FALSE |
| `defined_valid_elements` | 0 |
| `capacity_bytes` | 4096 |
| `rows` x `columns` | 64 x 16 |
| `cube_cell_count` | 0 |

描述符已完整，但目前还没有任何载荷元素可读。

<!-- PTO-READER-BLOCK: tile-model-state-types-related role=related-owners-navigation -->
## 相关所有者

- [Local 寄存器](local-registers.md)声明这些记录的数组。
- [分配](allocation.md)填写 `TileInfo` 描述符。
- [打包边界](../definedness/packed-boundary.md)解释载体与打包已定义性表示。
- [Tile 数据类型](../../../arch/data-types/tile-data-types.md)定义 `TileDataType` 和 `TileLayout`。
- [Tile 指令操作数](../../../block/model/dispatch/tile-instruction-operands.md)从指令束填写操作数载体。
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
