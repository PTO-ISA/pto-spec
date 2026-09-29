<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-prefetch.asl -->
# TLSU Prefetch

**Normative ASL source:** `asl/block/model/dispatch/tlsu-prefetch.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-PREFETCH}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-prefetch-purpose role=purpose-scope -->
## 用途与范围

本单元是 `TPREFETCH` 的指令束级处理程序。预取在四个 PE 的每一个上读取全局内存中的一个矩形区域并记录加载事件，但不写任何 Tile 或寄存器。

`BundleTPREFETCHSelected` 识别该指令束：有效的 `TileMemory` 操作描述符，其选择器功能号（位 `4:0`）为 `3`。`ExecuteBundleTPREFETCHOperation` 校验完整指令束，然后调用 `TPREFETCHCore`。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-prefetch-concepts role=concepts-state -->
## 概念与可见状态

预取指令束完全没有 Tile 操作数。

- 不允许 `B.IOT` Local 绑定，也不允许 `B.IOS` Shared 绑定。ASL 注释指出 `TPREFETCH` 隐含 PE 参与 `1111`。
- `B.DIM` 提供有效列数（`LB0`）、有效行数（`LB1`）和物理列数（`LB2`）。
- 可选的 `B.IOR` 在 `source0` 中提供基地址，在 `source1` 中提供行步长。每个 PE 用 `ReadPEAbsoluteGPROperand` 从自己的 GPR 堆读取这些选择器。
- 没有 `B.IOR` 时，基地址为零，行步长为物理列数。`TPREFETCHCore` 把该步长视为元素个数而不是字节数。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-prefetch-rules role=rules-interactions -->
## 规则与交互

未知的 TLSU 操作码引发 `Fault_IllegalInstruction`。其余检查引发 `Fault_TileLegality`，顺序为：操作数据类型通过 `TileCarrierOrPackedBaselineDataTypeSupported`；不存在 Tile 或 Shared 绑定；`B.IOR` 绑定完整且取值合法；维度通过 `BundleTPREFETCHDimensionsLegal`。数据属性最后由 `SelectedBundleTileDataAttributesLegal` 检查，它自行引发故障。

`BundleTPREFETCHDimensionsLegal` 要求每个维度在 `1..65535` 内，有效列数不超过物理列数，物理列数是非零的 2 的幂，且有效行数乘有效列数不超过 `PTO_MODEL_TILE_ELEMENTS`。

设计要点：省略的 `B.DIM` 有效值为一，但显式编码的零仍是一个值，因而非法。ASL 注释陈述了这一区别。因此，用 `B.DIM` 把 `LB0` 设为零的程序会故障，而不是预取一列。

设计要点：`TPREFETCHCore` 在记录第一个加载事件之前，先探测每个 PE 的每个类型化元素。其注释给出原因：故障不能暴露部分请求或来自较早 PE 的事件前缀。因此 PE 3 上的转换故障不会留下来自 PE 0 的加载事件。

成功时处理程序调用 `FinalizeBundleTileAttempt`。由于没有 Tile 绑定，该调用不发布任何内容。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-prefetch-boundaries role=boundaries -->
## 架构边界

本单元并不在提交时判定指令束是否为预取。`ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` 按固定顺序测试各专用选择器，只有在直到 `MSCATTER.MASK` 为止的所有更早选择器都未匹配之后才到达 `BundleTPREFETCHSelected`；只有 Shared TLSU 选择器在它之后测试。

地址计算、探测和加载事件记录属于 Tile gather 与 scatter 所有者中的 `TPREFETCHCore`。生成的直接操作分派器所用的包装 `TPREFETCHAllPEs` 把同一个基址和步长用于全部四个 PE；完整指令束使用本单元，使每个 PE 读取自己的 GPR。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-prefetch-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

假设一个 FP32 预取指令束把 `LB0` 设为 48、`LB1` 设为 8、`LB2` 设为 64，并绑定 `B.IOR` 源 `a0` 和 `a1`。有效列数 48 不超过 64，64 是 2 的幂，8 乘 48 为 384 个元素，因此维度合法。若 PE 1 的 `a0` 为 `0x10000`、`a1` 为 64，则其第 2 行第 5 列元素位于从基址 `0x10000` 起的元素索引 2 乘 64 加 5，即 133。

如果 `LB2` 改为 48，指令束引发 `Fault_TileLegality`，因为 48 不是 2 的幂。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-prefetch-related role=related-owners-navigation -->
## 相关所有者

- [Tile 执行分派](tile-execution.md) 排定各专用选择器的顺序。
- [Gather 与 scatter 内存](../../../tile/model/memory/gather-scatter.md) 定义 `TPREFETCHCore`。
- [步长辅助函数](../../../tile/model/memory/stride.md) 定义按元素步进的索引。
- [BSTART.TPREFETCH](../../execution/BSTART.TPREFETCH.md) 是该起始形式的指令页。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-prefetch.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-PREFETCH","surface":"block","classification":["model","dispatch","tlsu-prefetch"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU","PTO-TILE-MODEL-MEMORY-GATHER-SCATTER"]}

readonly func BundleTPREFETCHSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           UInt(_BundleOperation.selector[4:0]) == 3;
end;

readonly func BundleTPREFETCHDimensionsLegal() => boolean
begin
    // Omitted dimensions have effective value one. An explicitly encoded
    // zero or out-of-range value remains a value and is therefore illegal.
    for dimension = 0 to PTO_BUNDLE_DIMENSION_COUNT - 1 do
        if UInt(_BundleDimensions[[dimension]]) == 0 ||
           UInt(_BundleDimensions[[dimension]]) > 65535 then
            return FALSE;
        end;
    end;
    let valid_columns = BundleDestinationValidColumns(FALSE, 0);
    let valid_rows = BundleDestinationValidRows(FALSE, 0);
    let columns = BundleDestinationPhysicalColumns(FALSE, 0);
    return valid_columns <= columns && IsNonzeroPowerOfTwo(columns) &&
           valid_rows * valid_columns <= PTO_MODEL_TILE_ELEMENTS;
end;

func ExecuteBundleTPREFETCHOperation() => boolean
begin
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !TileCarrierOrPackedBaselineDataTypeSupported(data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    // TPREFETCH has implicit PE participation 1111 and no Local or Shared Tile
    // operand.  Any B.IOT or B.IOS is a malformed complete-bundle schema.
    if BundleTileBindingCount() != 0 || BundleSharedBindingCount() != 0 ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !BundleTPREFETCHDimensionsLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return FALSE; end;

    let valid_columns = BundleDestinationValidColumns(FALSE, 0);
    let valid_rows = BundleDestinationValidRows(FALSE, 0);
    let columns = BundleDestinationPhysicalColumns(FALSE, 0);
    var base_addresses: CorePEWords;
    var row_strides: CorePEWords;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        base_addresses[[agent]] =
            if _BundleScalarBindings[[0]].valid then
                ReadPEAbsoluteGPROperand(agent,
                    _BundleScalarBindings[[0]].source0)
            else Zeros{PTO_XLEN};
        row_strides[[agent]] =
            if _BundleScalarBindings[[0]].valid then
                ReadPEAbsoluteGPROperand(agent,
                    _BundleScalarBindings[[0]].source1)
            else NaturalToWord(columns);
    end;
    TPREFETCHCore(base_addresses, row_strides,
        valid_columns as integer {1..65535},
        valid_rows as integer {1..65535},
        columns as integer {1..65535},
        data_type);
    if _LastFault != Fault_None then return FALSE; end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
