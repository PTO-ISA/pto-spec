<!-- GENERATED FROM: asl/block/model/dispatch/weight-to-shared-schema.asl -->
# Weight To Shared Schema

**Normative ASL source:** `asl/block/model/dispatch/weight-to-shared-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-WEIGHT-TO-SHARED-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-schema-purpose role=purpose-scope -->
## 用途与范围

本单元定义模型如何识别权重模式的 `TLOAD`，以及该模式使用的纯几何规则。权重模式的 `TLOAD` 把卷积权重张量的一个裁剪区域从全局内存（GM）复制到一个 Shared Tile 中，排布为 N 乘 K 的矩阵。N 是输出通道，K 是展平后的卷积核位置与输入通道。

本单元不读取寄存器，也不改变状态。[权重到 Shared 执行](weight-to-shared-execution.md)使用这些辅助函数来校验并构建结果。

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-schema-concepts role=concepts-state -->
## 选择与派生量

当指令束是译码代码为零（即 `TLOAD` 功能）的 Tile 内存操作，且 `B.DATR` 存在并使用布局 `OHWI2NK`（代码 10）或 `OIHW2NK`（代码 11）时，`BundleWeightTLOADSelected` 为真。没有这样的 `B.DATR` 布局时，由普通 `TLOAD` 路径处理该指令束。

- `C0` 是 32 字节中的元素数：32 除以元素字节数。FP16 得到 16，FP32 得到 8。
- `C1` 是 `Cin` 除以 `C0` 并向上取整。
- 完整 K 范围是 `KernelH * KernelW * C1 * C0`，因此每个卷积核位置拥有一段按 `C0` 填充的通道区间。
- `BundleWeightTLOADShape` 保存来自 `B.DIM` 的 ValidCol、ValidRow 和 TotalCol、数据类型，以及译码后的 `Cin`、`Cout`、`KernelH`、`KernelW`、NStart 和 KStart。

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-schema-rules role=rules-interactions -->
## 形状与行划分规则

`BundleWeightTLOADDataTypeSupported` 接受 FP32、TF32、HF32、FP16、BF16、HiF8、E4M3、E5M2、E8M0、S32、S16、S8、U32、U16 和 U8。

`BundleWeightTLOADShapeLegal` 要求：类型受支持；ValidCol 不大于 TotalCol；`NStart + ValidRow <= Cout`；`KStart + ValidCol` 不超过完整 K 范围；KStart 和 ValidCol 是 `C0` 的倍数；TotalCol 是非零的 2 的幂。

设计要点：KStart 和 ValidCol 按 `C0` 对齐，因此裁剪永远不会拆开一个 32 字节通道组。每个 K 窗口因此都从填充通道区间中的一个完整组开始。

行划分服务于协作情形，即多个 PE 各写 N 行中的一部分。`BundleWeightTLOADRowsForRank` 给每个被选 PE 分配 `ValidRow DIVRM count` 行，排名低于余数的每个 PE 再多分一行。`BundleWeightTLOADRowStartForRank` 把更低排名的行数相加。`BundleWeightTLOADCurrentPERank` 统计 PE 编号低于当前 PE 的被选 PE 数量，并断言当前 PE 已被选中。`BundleWeightTLOADFirstPE` 和 `BundleWeightTLOADLastPE` 返回编号最低和最高的被选 PE。

设计要点：行区间是连续的，并遵循 PE 顺序。NDF 条款 `PTO-BSTART-TLOAD-WEIGHT-COOPERATIVE-001` 要求这一点，这也让第一个 PE 打开汇编、最后一个 PE 关闭汇编。

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-schema-boundaries role=boundaries -->
## 架构边界

本单元不读取 `B.IOR` 寄存器，不检查 `B.DATR` 字段，也不探测内存。它不定义单元的 GM 索引；那由 [权重到 Shared 的 GM 访问](../memory/weight-to-shared-gm.md)定义。它也不决定发布；那由执行单元决定。

`BundleWeightTLOADSelected` 也在本单元之外被读取。例如，[Tile schema](tile-schema.md) 在其他任何操作上拒绝权重布局，[Tile 执行](tile-execution.md)在通用第 2 阶段准备之前用它来路由指令束。

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-schema-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 FP16 权重，`Cin` 为 20，`Cout` 为 64，卷积核为 3 乘 3。`C0` 为 16，`C1` 为 2，完整 K 范围为 9 * 2 * 16 = 288。KStart 为 32、ValidCol 为 64 是合法的，因为两者都是 16 的倍数且 96 <= 288。KStart 为 40 不合法，因为它不是 16 的倍数。

有四个被选 PE 且 ValidRow 为 10 时，基数为 2，余数为 2。排名 0 和 1 各得 3 行，排名 2 和 3 各得 2 行。它们的行起点为 0、3、6 和 8。

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-schema-related role=related-owners-navigation -->
## 相关所有者

- [权重到 Shared 执行](weight-to-shared-execution.md)校验指令束并发布 Shared Tile。
- [权重到 Shared 参数](../operands/weight-to-shared-parameters.md)解包形状字和起点字。
- [权重到 Shared 的 GM 访问](../memory/weight-to-shared-gm.md)把每个单元映射到 OHWI 或 OIHW 的 GM 索引。
- [BSTART.TLOAD](../../execution/BSTART.TLOAD.md) 是加载指令束的指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/weight-to-shared-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-WEIGHT-TO-SHARED-SCHEMA","surface":"block","classification":["model","dispatch","weight-to-shared-schema"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-WEIGHT-PARAMETERS","PTO-BLOCK-B-DATR","PTO-BLOCK-B-DIM","PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}
// PTO-BSTART-TLOAD-WEIGHT-NK-CONTRACT-001 owns the specialized carrier
// selection and the NK physical descriptor shape.  The generic TLOAD carrier
// remains the fallback whenever this explicit B.DATR layout is absent.
type BundleWeightTLOADShape of record {
    valid_col: integer {1..65535},
    valid_row: integer {1..65535},
    total_col: integer {1..65535},
    data_type: TileDataType,
    cin: integer {1..65535},
    cout: integer {1..65535},
    kernel_h: integer {1..255},
    kernel_w: integer {1..255},
    n_start: integer {0..4294967295},
    k_start: integer {0..4294967295}
};

readonly func BundleWeightTLOADSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           BundleOperationDecodeCode(_BundleOperation) == Zeros{12} &&
           _BundleDataAttributesPresent &&
           TileDataLayoutIsWeightTLOAD(TileDataLayoutOfCode(
               _BundleDataAttributes.data_layout));
end;

pure func BundleWeightTLOADDataTypeSupported(data_type: TileDataType)
    => boolean
begin
    case data_type of
        when TileDataType_FP32, TileDataType_TF32, TileDataType_HF32,
             TileDataType_FP16, TileDataType_BF16, TileDataType_HiF8,
             TileDataType_E4M3, TileDataType_E5M2, TileDataType_E8M0,
             TileDataType_S32, TileDataType_S16, TileDataType_S8,
             TileDataType_U32, TileDataType_U16, TileDataType_U8 =>
            return TRUE;
        otherwise => return FALSE;
    end;
end;

pure func BundleWeightTLOADC0Elements(data_type: TileDataType) => integer
begin
    return (32 DIVRM TileElementBytes(data_type)) as integer {4,8,16,32};
end;

pure func BundleWeightTLOADC1(cin: integer {1..65535},
                              data_type: TileDataType) => integer
begin
    let c0 = BundleWeightTLOADC0Elements(data_type);
    return ((cin + (c0 - 1)) DIVRM c0) as integer {1..16384};
end;

pure func BundleWeightTLOADKFull(cin: integer {1..65535},
                                 kernel_h: integer {1..255},
                                 kernel_w: integer {1..255},
                                 data_type: TileDataType) => integer
begin
    let c0 = BundleWeightTLOADC0Elements(data_type);
    let c1 = BundleWeightTLOADC1(cin, data_type);
    return (kernel_h * kernel_w * c1 * c0) as integer {1..18446744073709551615};
end;

pure func BundleWeightTLOADShapeLegal(shape: BundleWeightTLOADShape) => boolean
begin
    let c0 = BundleWeightTLOADC0Elements(shape.data_type);
    let k_full = BundleWeightTLOADKFull(shape.cin, shape.kernel_h,
        shape.kernel_w, shape.data_type);
    return BundleWeightTLOADDataTypeSupported(shape.data_type) &&
           shape.valid_col <= shape.total_col &&
           shape.n_start + shape.valid_row <= shape.cout &&
           shape.k_start + shape.valid_col <= k_full &&
           (shape.k_start MOD c0) == 0 &&
           (shape.valid_col MOD c0) == 0 &&
           IsNonzeroPowerOfTwo(shape.total_col);
end;

readonly func BundleWeightTLOADPEBit() => bits(4)
begin
    var result = Zeros{4};
    result[PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent)] = '1';
    return result;
end;

pure func BundleWeightTLOADSelectedPECount(mask: bits(4)) => integer {1..4}
begin
    return PEMaskPopulation(mask) as integer {1..4};
end;

readonly func BundleWeightTLOADCurrentPERank(mask: bits(4)) => integer {0..3}
begin
    var rank: integer {0..3} = 0;
    let current = PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent);
    for pe = 0 to 3 looplimit 4 do
        if pe < (_CurrentMemoryAgent as integer {0..3}) &&
           mask[PTOPEMaskBitOfPEIdentity(pe as MemoryAgentId)] == '1' then
            rank = (rank + 1) as integer {0..3};
        end;
    end;
    assert mask[current] == '1';
    return rank;
end;

pure func BundleWeightTLOADRowsForRank(valid_row: integer {1..65535},
                                       mask: bits(4), rank: integer {0..3})
                                       => integer {0..65535}
begin
    let count = BundleWeightTLOADSelectedPECount(mask);
    let base = (valid_row DIVRM count) as integer {0..65535};
    let remainder = (valid_row MOD count) as integer {0..3};
    return (base + (if rank < remainder then 1 else 0))
        as integer {0..65535};
end;

pure func BundleWeightTLOADRowStartForRank(
    n_start: integer {0..4294967295}, valid_row: integer {1..65535},
    mask: bits(4), rank: integer {0..3}) => integer
begin
    var result: integer = n_start;
    for previous = 0 to 2 looplimit 3 do
        if previous < rank then
            result = result + BundleWeightTLOADRowsForRank(
                valid_row, mask, previous);
        end;
    end;
    return result;
end;

pure func BundleWeightTLOADFirstPE(mask: bits(4)) => integer {0..3}
begin
    for pe = 0 to 3 looplimit 4 do
        if mask[PTOPEMaskBitOfPEIdentity(pe as MemoryAgentId)] == '1' then
            return pe as integer {0..3};
        end;
    end;
    return 0;
end;

pure func BundleWeightTLOADLastPE(mask: bits(4)) => integer {0..3}
begin
    var result: integer {0..3} = 0;
    for pe = 0 to 3 looplimit 4 do
        if mask[PTOPEMaskBitOfPEIdentity(pe as MemoryAgentId)] == '1' then
            result = pe as integer {0..3};
        end;
    end;
    return result;
end;
```
<!-- GENERATED-ASL-END: unit -->
