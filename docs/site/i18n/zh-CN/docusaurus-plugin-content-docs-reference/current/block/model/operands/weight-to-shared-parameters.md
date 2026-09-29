<!-- GENERATED FROM: asl/block/model/operands/weight-to-shared-parameters.asl -->
# Weight To Shared Parameters

**Normative ASL source:** `asl/block/model/operands/weight-to-shared-parameters.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-WEIGHT-PARAMETERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-operands-weight-to-shared-parameters-purpose role=purpose-scope -->
## 用途与范围

本单元拥有权重模式 `TLOAD` 的参数载体。权重模式把卷积权重张量从全局内存（GM）加载到 Shared Tile 中。其几何通过由一条 `B.IOR` 记录指名的三个通用寄存器（GPR）传递。本单元定义这些 GPR 值如何解包、哪些位必须为零、如何跨 PE 比较这些值，以及协作构建所用的元数据字。

<!-- PTO-READER-BLOCK: block-model-operands-weight-to-shared-parameters-concepts role=concepts-state -->
## 概念与可见状态

本单元声明一个记录，不声明状态变量。`BundleWeightTLOADParameters` 保存 `cin`、`cout`、`kernel_h`、`kernel_w`、`n_start` 和 `k_start`。

这一条 `B.IOR` 记录指名三个源和一个零目标：

| 源 | 内容 |
| --- | --- |
| `GMBase` | 权重张量的 GM 字节地址 |
| `ShapeGPR` | `cin` 15:0，`cout` 31:16，`kernel_h` 39:32，`kernel_w` 47:40；位 48..63 必须为零 |
| `StartGPR` | `n_start` 31:0，`k_start` 63:32 |

`BundleWeightTLOADParametersFromWords` 执行这一解包。`n_start` 选择请求窗口的第一个输出通道行，`k_start` 选择第一个 K 列。

<!-- PTO-READER-BLOCK: block-model-operands-weight-to-shared-parameters-rules role=rules-interactions -->
## 规则与交互

只有当 `ShapeGPR` 的位 48..63 为零时，`BundleWeightTLOADShapeReservedBitsLegal` 才为 TRUE。

`BundleWeightTLOADParticipantValuesEqual(mask)` 从 Shared 目标掩码选中的每个 PE 读取 `GMBase`、`ShapeGPR` 和 `StartGPR`。只有当至少选中一个 PE 且所有选中的 PE 持有相同值时，它才为 TRUE。

权重执行单元在 `BundleWeightTLOADStateLegal` 中按以下顺序应用这些检查：数据类型和 `B.DATR` 字段检查；恰好一个物理 Shared 绑定且没有 Tile 绑定；一个有效的第一标量绑定，含三个源和零目标，且没有第二个绑定；然后是掩码包含当前 PE 的检查以及参与者相等检查；然后是维度；然后是保留位检查；然后是非零的 `cin`、`cout`、`kernel_h` 和 `kernel_w`；然后是形状合法性，全部在 GM 预检之前。

设计要点：参与者的值必须相等。协作加载把 N 行拆分到各个 PE，每个 PE 从自己的 GPR 副本计算自己的切片。相等的值保证这些切片来自同一个张量和同一个窗口。不匹配会在 GM 访问之前被拒绝。

设计要点：保留的 `ShapeGPR` 位必须为零，而不是被忽略。`BundleWeightTLOADStateLegal` 在解包字段之前检查它们，因此非零值会在 GM 预检之前拒绝该操作，并且不会从位 48..63 读取任何字段。

`BundleWeightTLOADGenerationMetadata` 把源布局、数据类型、`valid_col`、16 位的 `valid_row`、`total_col` 和父级大小码打包到一个字中。执行单元把它与三个源字一起传给 Shared 代次检查，因此所有协作写者都必须在它上面达成一致。

<!-- PTO-READER-BLOCK: block-model-operands-weight-to-shared-parameters-boundaries role=boundaries -->
## 架构边界

`BundleWeightTLOADStateLegal` 对零掩码提前返回 TRUE，随后构建也不产生效果就返回。实际上，已记录的 Shared 绑定的掩码永远不为零：命令处理程序把零掩码的 `B.IOS` 视为不记录绑定的严格空操作，并且 `BundleSharedMaskCanAppend` 也会拒绝零掩码，因此相等检查在非零掩码上运行。状态检查还会拒绝不包含当前 PE 的掩码。

本单元不定义 K 顺序、索引公式或行拆分。这些由 GM 单元和执行单元拥有。

<!-- PTO-READER-BLOCK: block-model-operands-weight-to-shared-parameters-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

对 `cin` 64、`cout` 128 和 3 乘 3 卷积核，`ShapeGPR` 为 `0x0000_0303_0080_0040`。位 48..63 为零，因此保留位检查通过。若要从输出通道 32 和 K 列 0 开始，`StartGPR` 为 `0x0000_0000_0000_0020`。使用掩码 `1111` 时，四个 PE 都必须持有这两个相同的字和相同的 `GMBase`。

<!-- PTO-READER-BLOCK: block-model-operands-weight-to-shared-parameters-related role=related-owners-navigation -->
## 相关所有者

- [权重 schema](../dispatch/weight-to-shared-schema.md) 选择权重模式并检查形状。
- [权重执行](../dispatch/weight-to-shared-execution.md)应用这些检查并构建 Tile。
- [权重 GM 访问](../memory/weight-to-shared-gm.md)把单元映射到 GM 索引。
- [B.IOR](../../operands/B.IOR.md) 是命令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/weight-to-shared-parameters.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-WEIGHT-PARAMETERS","surface":"block","classification":["model","operands","weight-to-shared-parameters"],"depends_on":["PTO-BLOCK-B-IOR","PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES"]}
// NDF-BEGIN: PTO-BSTART-TLOAD-WEIGHT-SOURCE-001
// ndf: kind=contract level=L1 layer=block status=accepted
// Weight-mode TLOAD has exactly one three-source B.IOR record: GMBase,
// ShapeGPR, StartGPR, with a zero destination selector. ShapeGPR packs Cin,
// Cout, KernelH, and KernelW in bits 0..47 and requires bits 48..63 zero;
// StartGPR packs NStart in bits 0..31 and KStart in bits 32..63. Every
// participating PE must resolve equal values for all three sources.
// NDF-END: PTO-BSTART-TLOAD-WEIGHT-SOURCE-001
// PTO-BSTART-TLOAD-WEIGHT-SOURCE-001 owns the one-record B.IOR carrier and
// packed ShapeGPR/StartGPR fields.
type BundleWeightTLOADParameters of record {
    cin: integer {0..65535},
    cout: integer {0..65535},
    kernel_h: integer {0..255},
    kernel_w: integer {0..255},
    n_start: integer {0..4294967295},
    k_start: integer {0..4294967295}
};

pure func BundleWeightTLOADParametersFromWords(
    shape_word: Word, start_word: Word) => BundleWeightTLOADParameters
begin
    return BundleWeightTLOADParameters {
        cin = UInt(shape_word[15:0]),
        cout = UInt(shape_word[31:16]),
        kernel_h = UInt(shape_word[39:32]),
        kernel_w = UInt(shape_word[47:40]),
        n_start = UInt(start_word[31:0]),
        k_start = UInt(start_word[63:32])
    };
end;

pure func BundleWeightTLOADShapeReservedBitsLegal(shape_word: Word) => boolean
begin
    return shape_word[63:48] == Zeros{16};
end;

readonly func BundleWeightTLOADParticipantValuesEqual(mask: bits(4)) => boolean
begin
    var reference_valid = FALSE;
    var reference_gm_base: Word = Zeros{PTO_XLEN};
    var reference_shape: Word = Zeros{PTO_XLEN};
    var reference_start: Word = Zeros{PTO_XLEN};
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        if mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' then
            let gm_base = ReadPEAbsoluteGPROperand(
                agent, _BundleScalarBindings[[0]].source0);
            let shape_word = ReadPEAbsoluteGPROperand(
                agent, _BundleScalarBindings[[0]].source1);
            let start_word = ReadPEAbsoluteGPROperand(
                agent, _BundleScalarBindings[[0]].source2);
            if !reference_valid then
                reference_valid = TRUE;
                reference_gm_base = gm_base;
                reference_shape = shape_word;
                reference_start = start_word;
            elsif gm_base != reference_gm_base ||
                  shape_word != reference_shape ||
                  start_word != reference_start then
                return FALSE;
            end;
        end;
    end;
    return reference_valid;
end;

pure func BundleWeightTLOADGenerationMetadata(
    source_layout: bits(5), data_type: bits(5), valid_col: bits(16),
    valid_row: bits(16), total_col: bits(16), size_code: bits(4)) => Word
begin
    var metadata = Zeros{PTO_XLEN};
    metadata[4:0] = source_layout;
    metadata[9:5] = data_type;
    metadata[25:10] = valid_col;
    metadata[41:26] = valid_row;
    metadata[57:42] = total_col;
    metadata[61:58] = size_code;
    return metadata;
end;
```
<!-- GENERATED-ASL-END: unit -->
