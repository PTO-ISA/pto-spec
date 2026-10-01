<!-- GENERATED FROM: asl/block/model/memory/weight-to-shared-gm.asl -->
# Weight To Shared Gm

**Normative ASL source:** `asl/block/model/memory/weight-to-shared-gm.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-MEMORY-WEIGHT-TO-SHARED-GM}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-memory-weight-to-shared-gm-purpose role=purpose-scope -->
## 用途与范围

本单元拥有权重模式 `TLOAD` 在全局内存（GM）一侧的定义。当 `BSTART.TLOAD` 带有布局为 `OHWI2NK` 或 `OIHW2NK` 的 `B.DATR` 时选择权重模式。它把卷积权重张量作为一个 N 乘 K 的矩阵加载到 Shared Tile 中，其中 N 是输出通道，K 遍历卷积核窗口和输入通道。

本单元定义一个目标单元如何映射到 GM 元素索引，以及在任何效果之前证明每次 GM 读取都合法的预检。

<!-- PTO-READER-BLOCK: block-model-memory-weight-to-shared-gm-concepts role=concepts-state -->
## 概念与可见状态

本单元不持有状态。`BundleWeightTLOADCell` 返回一个 `BundleWeightTLOADCellResult`，包含四个字段：`defined`、`raw_zero`、`gm_access` 和 `gm_index`。

对目标行 `local_row` 和列 `local_col`，该单元使用：

- `global_n = n_start + local_row` 和 `global_k = k_start + local_col`；
- `c0`，即通道块宽度，等于 32 字节除以元素大小；
- `c1`，即通道块数量，等于把 `cin` 向上取整到 `c0` 的倍数后再除以 `c0`。

`global_k` 按 `[kh][kw][c1][c0]` 顺序拆分，`c0` 变化最快。该 lane 的输入通道为 `ci = c1_index * c0 + c0_lane`。

<!-- PTO-READER-BLOCK: block-model-memory-weight-to-shared-gm-rules role=rules-interactions -->
## 规则与交互

如果 `ci >= cin`，该单元是 Cin 填充 lane。它是已定义的，是原始零，并且不访问 GM。

否则该单元读取 GM。对 `OHWI2NK`，索引为 `((global_n * kernel_h + kh) * kernel_w + kw) * cin + ci`。对另一种权重布局 `OIHW2NK`，索引为 `((global_n * cin + ci) * kernel_h + kh) * kernel_w + kw`。

`BundleWeightTLOADPreflightGM` 访问 `row_count` 以下的每一行和 `col_count` 以下的每一列。对每个 GM 单元，它构造 `gm_base + gm_index * element_bytes`。如果无符号和小于 `gm_base`，它在该地址引发 `Fault_DataPage`。否则它用 `ProbeTileMemoryAccess` 以读方式探测该地址，并在第一个故障处停止。

设计要点：两种布局产生相同的 K 顺序。源布局只改变索引公式。因此，无论权重以 OHWI 还是 OIHW 存储，已加载 Shared Tile 的使用者看到的 K 顺序都相同。

设计要点：执行单元在构建候选 Tile 之前，用编码的 `n_start` 和完整的 `valid_row` 调用预检。其注释说明了该规则：每个参与者在任何参与者发出第一次 GM 读取之前，都要证明完整的选中 PE 足迹。足迹中任何位置的故障都会在任何 PE 加载载荷之前停止操作。

设计要点：`gm_index` 的类型是宽无符号整数，并且对求和做回绕检查。会溢出地址空间的索引会引发故障，而不是静默地读取一个低地址。

<!-- PTO-READER-BLOCK: block-model-memory-weight-to-shared-gm-boundaries role=boundaries -->
## 架构边界

契约 `PTO-BSTART-TLOAD-WEIGHT-DEFINEDNESS-001` 规定有效矩形之外的物理行和列保持不被触及且未定义。构建循环只访问 `valid_row` 乘 `valid_col` 个单元。

本单元不检查形状合法性、不在 PE 之间拆分行，也不发布 Shared Tile。这些步骤由权重 schema 和执行单元拥有。

<!-- PTO-READER-BLOCK: block-model-memory-weight-to-shared-gm-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 FP16 权重，`cin` 为 3，卷积核为 3 乘 3。对 FP16，`c0` 为 16，`c1` 为 1，因此每个卷积核位置跨越 16 个 K 列。

- `global_k` 34 给出卷积核偏移 2，因此 `kh` 为 0、`kw` 为 2，lane 2 给出 `ci` 2。对 `global_n` 1，`OHWI2NK` 索引为 ((1 x 3 + 0) x 3 + 2) x 3 + 2 = 35，字节偏移 70。`OIHW2NK` 索引为 ((1 x 3 + 2) x 3 + 0) x 3 + 2 = 47，字节偏移 94。
- `global_k` 37 给出 lane 5，因此 `ci` 为 5。它不小于 `cin`，所以该单元是原始零，不访问 GM。

<!-- PTO-READER-BLOCK: block-model-memory-weight-to-shared-gm-related role=related-owners-navigation -->
## 相关所有者

- [权重参数](../operands/weight-to-shared-parameters.md)拥有打包的 `ShapeGPR` 和 `StartGPR` 字段。
- [权重 schema](../dispatch/weight-to-shared-schema.md) 拥有 `c0`、`c1` 以及形状合法性。
- [权重执行](../dispatch/weight-to-shared-execution.md)调用预检、加载载荷并发布。
- [TLOAD](../../../tile/memory-and-data-movement/regular/TLOAD.md) 是指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/memory/weight-to-shared-gm.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-MEMORY-WEIGHT-TO-SHARED-GM","surface":"block","classification":["model","memory","weight-to-shared-gm"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-WEIGHT-TO-SHARED-SCHEMA","PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS","PTO-TILE-MODEL-MEMORY-ADDRESSING"]}
// NDF-BEGIN: PTO-BSTART-TLOAD-WEIGHT-KORDER-001
// ndf: kind=contract level=L1 layer=block status=accepted
// Weight-mode TLOAD maps each destination K coordinate to [kh][kw][c1][c0]
// order, with c0 fastest, spatial coordinates before channel blocks, and
// reads OHWI or OIHW using the selected source-layout index formula.
// NDF-END: PTO-BSTART-TLOAD-WEIGHT-KORDER-001
// NDF-BEGIN: PTO-BSTART-TLOAD-WEIGHT-DEFINEDNESS-001
// ndf: kind=contract level=L1 layer=block status=accepted
// Cin padding lanes inside the valid canonical K rectangle are defined raw
// zero and do not access GM. All valid source lanes use wide unsigned address
// arithmetic and complete preflight; physical rows and columns outside the
// valid rectangle remain untouched and undefined.
// NDF-END: PTO-BSTART-TLOAD-WEIGHT-DEFINEDNESS-001
// PTO-BSTART-TLOAD-WEIGHT-KORDER-001 owns the canonical [kh][kw][c1][c0]
// reduction order and source-layout address projection.
type BundleWeightTLOADCellResult of record {
    defined: boolean,
    raw_zero: boolean,
    gm_access: boolean,
    gm_index: integer {0..18446744073709551615}
};

pure func BundleWeightTLOADCell(
    layout: TileDataLayout, data_type: TileDataType,
    parameters: BundleWeightTLOADParameters,
    local_row: integer {0..65534}, local_col: integer {0..65534})
    => BundleWeightTLOADCellResult
begin
    let c0 = BundleWeightTLOADC0Elements(data_type);
    let c1 = BundleWeightTLOADC1(
        parameters.cin as integer {1..65535}, data_type);
    let channel_span = (c1 * c0) as integer {4..65536};
    let global_k: integer = parameters.k_start + local_col;
    let global_n: integer = parameters.n_start + local_row;
    let kernel_offset: integer = global_k DIVRM channel_span;
    let channel_block_offset: integer = global_k MOD channel_span;
    let kh: integer = kernel_offset DIVRM parameters.kernel_w;
    let kw: integer = kernel_offset MOD parameters.kernel_w;
    let c1_index: integer = channel_block_offset DIVRM c0;
    let c0_lane: integer = channel_block_offset MOD c0;
    let ci: integer = c1_index * c0 + c0_lane;
    if ci >= parameters.cin then
        return BundleWeightTLOADCellResult {
            defined = TRUE, raw_zero = TRUE, gm_access = FALSE, gm_index = 0
        };
    end;
    var index: integer {0..18446744073709551615} = 0;
    if layout == TileDataLayout_OHWI2NK then
        index = (((global_n * parameters.kernel_h + kh) *
            parameters.kernel_w + kw) * parameters.cin + ci)
            as integer {0..18446744073709551615};
    else
        index = (((global_n * parameters.cin + ci) *
            parameters.kernel_h + kh) * parameters.kernel_w + kw)
            as integer {0..18446744073709551615};
    end;
    return BundleWeightTLOADCellResult {
        defined = TRUE, raw_zero = FALSE, gm_access = TRUE, gm_index = index
    };
end;

func BundleWeightTLOADPreflightGM(
    layout: TileDataLayout, data_type: TileDataType,
    parameters: BundleWeightTLOADParameters,
    row_count: integer {0..65535}, col_count: integer {1..65535},
    gm_base: Word, element_bytes: integer {1,2,4,8}) => boolean
begin
    if row_count == 0 then return TRUE; end;
    for row = 0 to row_count - 1 looplimit 65535 do
        for col = 0 to col_count - 1 looplimit 65535 do
            let cell = BundleWeightTLOADCell(layout, data_type, parameters,
                row as integer {0..65534}, col as integer {0..65534});
            if cell.gm_access then
                let byte_offset = (cell.gm_index * element_bytes)
                    as integer {0..18446744073709551615};
                let address = gm_base + byte_offset;
                if UInt(address) < UInt(gm_base) then
                    SetFault(Fault_DataPage, address);
                    return FALSE;
                end;
                let probe = ProbeTileMemoryAccess(address, data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then return FALSE; end;
            end;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
