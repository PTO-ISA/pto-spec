<!-- GENERATED FROM: asl/block/model/memory/timg2col-gm.asl -->
# Timg2col Gm

**Normative ASL source:** `asl/block/model/memory/timg2col-gm.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-MEMORY-TIMG2COL-GM}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-memory-timg2col-gm-purpose role=purpose-scope -->
## 用途与范围

本单元拥有 `BSTART.TIMG2COL` 在全局内存（GM）一侧的定义。TIMG2COL 构建一个图像到列的矩阵：每个目标单元是某个通道的一个输入像素，由一个输出位置和一个卷积核偏移选出。

本单元定义源坐标如何变成 GM 元素索引、哪些坐标属于填充，以及在任何分配、载荷、已定义性或 Shared 代次效果之前证明每次 GM 读取都合法的预检。产生 `hin`、`win` 和通道的坐标运算位于 TIMG2COL schema 单元；本单元只使用这些结果。

<!-- PTO-READER-BLOCK: block-model-memory-timg2col-gm-concepts role=concepts-state -->
## 概念与可见状态

本单元不持有状态。它是一组辅助函数：

- 当 `0 <= hin < input_h` 且 `0 <= win < input_w` 时，`BundleTIMG2COLSpatialInBounds` 为 TRUE。
- 当通道小于逻辑 `cin` 时，`BundleTIMG2COLCinLaneDefined` 为 TRUE。从 `cin` 到填充后通道块末尾的通道是 Cin 填充 lane。
- `BundleTIMG2COLGMIndexDN` 计算 `channel * input_h * input_w + hin * input_w + win`，即 NCHW（DN）元素索引。
- `BundleTIMG2COLGMIndexND` 计算 `(hin * input_w + win) * input_cin + channel`，即 NHWC（ND）元素索引。
- `BundleTIMG2COLPreflightGM` 遍历整个请求的矩形，并探测每个 GM 地址。

schema 单元对 `DN2ND`、`CUBE_M16` 和 `CUBE_M32` 数据布局选择 DN 公式，其余情况选择 ND 公式。

<!-- PTO-READER-BLOCK: block-model-memory-timg2col-gm-rules role=rules-interactions -->
## 规则与交互

只有当空间坐标在范围内且通道 lane 是真实通道时，单元才读取 GM。空间越界坐标或 Cin 填充 lane 产生一个原始零单元，不访问 GM。`BundleTIMG2COLCell` 把这两类单元以及每个由 GM 支撑的单元都标记为 `defined`，`BundleTIMG2COLCellIsDefined` 无条件返回 TRUE，因此有效矩形内的每个单元都是已定义的。

预检访问 `valid_row` 以下的每一行和 `valid_col` 以下的每一列。对每个需要 GM 的单元，它构造 `gm_base + gm_index * element_bytes`。如果无符号结果小于 `gm_base`，说明求和发生了回绕，预检在该地址引发 `Fault_DataPage`。否则它以读方式调用 `ProbeTileMemoryAccess`，并在 `RaiseDataAccessFault` 报告第一个故障时停止。

设计要点：预检在分配、载荷写入、已定义性更新和 Shared 代次效果之前运行。执行单元在选择或分配目标之前调用它。因此，一个地址转换或权限故障不会留下部分构建的目标。

设计要点：执行单元把编码的参数和完整的 `valid_row` 传给预检，而不是每个 PE 的行切片。每个至少有一行要写的 PE 都检查完整矩形，因此不会出现这样的 PE 已开始读取 GM、而另一个 PE 负责的那部分足迹会发生故障的情况。行数为零的协作 PE 跳过预检，也不读取任何内容。

设计要点：填充以已定义的零产生，而不是通过内存读取。构建完成后目标的有效区域是完全已定义的，并且不会在输入图像之外或真实通道之外发出读取。

<!-- PTO-READER-BLOCK: block-model-memory-timg2col-gm-boundaries role=boundaries -->
## 架构边界

`BundleTIMG2COLPhysicalTailDefined` 规定了有效矩形之外存储的边界：只有 `row < valid_row` 且 `col < valid_col` 是已定义的。契约 `PTO-BSTART-TIMG2COL-DEFINEDNESS-001` 规定物理尾部永远不会被读取或写入，执行单元中的构建循环也只访问有效矩形。

本单元不加载载荷。执行单元对每次真实访问重复相同的回绕检查和探测，然后执行加载并记录加载事件。

<!-- PTO-READER-BLOCK: block-model-memory-timg2col-gm-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 FP16 输入，`input_h` 为 4，`input_w` 为 5，`cin` 为 3。对 FP16，通道块有 16 个 lane，因此 lane 3 到 15 是填充 lane。

- 位于 `hin` 1、`win` 3 的通道 2 在 DN 顺序下的索引为 2 x 4 x 5 + 1 x 5 + 3 = 48，即距 `gm_base` 的字节偏移 96。
- 同一单元在 ND 顺序下的索引为 (1 x 5 + 3) x 3 + 2 = 26，即字节偏移 52。
- `hin` 等于 -1（顶部填充）的单元或通道 7 的单元是原始零，不发出 GM 访问。

<!-- PTO-READER-BLOCK: block-model-memory-timg2col-gm-related role=related-owners-navigation -->
## 相关所有者

- [TIMG2COL schema](../dispatch/timg2col-schema.md) 计算 `hin`、`win`、通道以及布局选择。
- [TIMG2COL 执行](../dispatch/timg2col-execution.md) 调用预检并执行加载。
- [TIMG2COL 参数](../operands/timg2col-parameters.md) 拥有打包的参数载体。
- [BSTART.TIMG2COL](../../execution/BSTART.TIMG2COL.md) 是指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/memory/timg2col-gm.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-MEMORY-TIMG2COL-GM","surface":"block","classification":["model","memory","timg2col-gm"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TIMG2COL-SCHEMA"]}
// PTO-BSTART-TIMG2COL-DEFINEDNESS-001 owns dense address generation and the
// distinction between defined raw zeros and untouched physical tails.
pure func BundleTIMG2COLSpatialInBounds(hin: integer,
                                        win: integer,
                                        input_h: integer {1..65535},
                                        input_w: integer {1..65535}) => boolean
begin
    return hin >= 0 && hin < input_h && win >= 0 && win < input_w;
end;

pure func BundleTIMG2COLCinLaneDefined(channel: integer {0..65535},
                                       logical_cin: integer {1..65535})
    => boolean
begin
    return channel < logical_cin;
end;

pure func BundleTIMG2COLGMIndexDN(channel: integer {0..65535},
                                  input_h: integer {1..65535},
                                  input_w: integer {1..65535},
                                  hin: integer {0..65534},
                                  win: integer {0..65534})
    => integer
begin
    let channel_base: integer = channel * input_h * input_w;
    let spatial_base: integer = hin * input_w + win;
    return channel_base + spatial_base;
end;

pure func BundleTIMG2COLGMIndexND(channel: integer {0..65535},
                                  input_cin: integer {1..65535},
                                  input_h: integer {1..65535},
                                  input_w: integer {1..65535},
                                  hin: integer {0..65534},
                                  win: integer {0..65534})
    => integer
begin
    let spatial: integer = hin * input_w + win;
    let pixel_base: integer = spatial * input_cin;
    return pixel_base + channel;
end;

pure func BundleTIMG2COLCellIsDefined(
    spatial_in_bounds: boolean, cin_lane_defined: boolean) => boolean
begin
    // Both out-of-bounds spatial coordinates and Cin padding lanes are raw
    // zero cells, hence defined. Only a valid source lane requires a GM read.
    return TRUE;
end;

pure func BundleTIMG2COLPhysicalTailDefined(
    row: integer {0..65535}, col: integer {0..65535},
    valid_row: integer {1..65535}, valid_col: integer {1..65535}) => boolean
begin
    return row < valid_row && col < valid_col;
end;

func BundleTIMG2COLPreflightGM(
    layout: TileDataLayout, data_type: TileDataType,
    parameters: BundleTIMG2COLParameters,
    valid_row: integer {0..128}, valid_col: integer {1..65535},
    gm_base: Word, element_bytes: integer {1,2,4,8}) => boolean
begin
    if valid_row == 0 then return TRUE; end;
    // Complete translation and permission checks before allocation, payload,
    // definedness, or Shared-generation effects.
    for row = 0 to valid_row - 1 looplimit 128 do
        for col = 0 to valid_col - 1 looplimit 65535 do
            let cell = BundleTIMG2COLCell(layout, data_type, parameters,
                row as integer {0..127}, col as integer {0..65534});
            if cell.gm_access then
                let byte_offset: integer = cell.gm_index * element_bytes;
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

// NDF-BEGIN: PTO-BSTART-TIMG2COL-DEFINEDNESS-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// Dense NCHW/DN and NHWC/ND source indices use wide unsigned arithmetic.
// Spatial out-of-bounds and Cin-to-C0 padding lanes produce defined raw zero
// without a GM access. Physical storage tails remain undefined and are never
// read or written.
// NDF-END: PTO-BSTART-TIMG2COL-DEFINEDNESS-001
```
<!-- GENERATED-ASL-END: unit -->
