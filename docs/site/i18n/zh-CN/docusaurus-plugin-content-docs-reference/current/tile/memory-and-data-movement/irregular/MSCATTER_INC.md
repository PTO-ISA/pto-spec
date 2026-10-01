<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MSCATTER_INC.asl -->
# MSCATTER_INC

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MSCATTER_INC.asl`

GM indexed mscatter.inc operation.

## Normative identity {#PTO-INST-TILE-MSCATTER-INC}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mscatter-inc-purpose role=purpose -->
## `MSCATTER_INC` 的作用

`MSCATTER_INC` 对全局内存（GM）的每个通道执行一次原子读-改-写，不返回任何结果。通道是索引 Tile 的一个活动有效坐标。其地址为基地址加上该通道的索引值，后者按字节位移使用。

它是 TLSU Function 22，写作 `BSTART.MSCATTER.INC DataType`。块分派器 `ExecuteBundleGMAtomRedOperation` 把 Function 22 映射为归约操作 INC，并调用 `GM_RED_VALUE`。本页所述操作没有独立 opcode。

设计要点：归约形式不绑定目标 Tile，因此不分配任何东西，也不发布任何 Tile。atom 形式 `MGATHER_INC` 计算出相同的新值，并且还在目标 Tile 中返回旧值。

<!-- PTO-READER-BLOCK: tile-mscatter-inc-mechanism role=mechanism -->
## 寻址、上限规则与更新机制

每个通道地址为 `base + displacement`，其中位移是按字节计数，而不是按元素计数。它由索引 Tile 元素提供：`S32` 符号扩展，`U32` 零扩展，`S64` 与 `U64` 按原样使用（`TileIndexByteDisplacement`）。软件需自行把索引缩放到字节。该地址处的原子元素具有指令束 `DataType` 的宽度。

预检最先进行。对每个活动通道，按索引 Tile 的行列顺序，执行体先以读、再以写探测该地址，以元素宽度作为对齐要求，任一探测失败即引发该探测的故障。若读探测与写探测转换到不同地址，则引发 `Fault_DataPage`。在同一遍中，它快照每个通道的地址以及该坐标对应的值 Tile 元素。

随后提交阶段按 `ARBITRARY` 选择决定的顺序访问各通道。每个通道加载旧元素，计算新值，按元素宽度存储，并记录一个原子事件，其 `write_performed` 为 TRUE，其顺序为 `CurrentBundleMemoryOrder()`。

新值为 `GMIncValue(old, limit)`：当旧值大于或等于该通道的上限时，存入的值为零；否则存入的值为旧值加 1。因此计数器递增到上限后从零重新开始。

设计要点：INC 把通道值用作上界，而不是加上任意数值，因此无论有多少次更新到达某个 GM 位置，它都保持在 `0..limit` 内。上界在递增之前与旧值比较，因此该位置在 `limit + 1` 次更新之后回到零。

设计要点：所有探测都在第一个原子事件之前完成（NDF `PTO-ATOM-RED-ORDERING-001`）。因此探测阶段发生故障的请求不存储任何内容，也不记录事件，重复执行它不会把更新施加两次。

设计要点：解析到同一地址的通道以实现定义的顺序串行化，因此其中最后执行的通道决定最终值，而每个通道仍然生效。一个通道是一个原子事件；整个请求不是一个原子事务。

<!-- PTO-READER-BLOCK: tile-mscatter-inc-inputs role=inputs-outputs -->
## 操作数角色、绑定与掩码

- `address` 是基地址。它来自 `B.IOR.RegSrc0` 指定的 GPR，在当前内存代理的寄存器文件中读取，并且必须完整：`RegSrc1`、`RegSrc2` 与 `RegDst` 均为零。
- `source0` 是索引 Tile。其类型必须是 `S32`、`U32`、`S64` 或 `U64`，并且必须具有指令束布局。
- `source1` 是上限 Tile。其类型必须是指令束 `DataType`，必须具有指令束布局，并且其有效行数与有效列数必须等于索引 Tile 的。

当 ExecutionMask 不由谓词 Tile 承载时，一条终止 `B.IOT` 携带两个源，且该绑定没有目标。当由谓词 Tile 承载时，第一条 `B.IOT` 携带两个源且不是 `last`，第二条 `B.IOT` 以该谓词 Tile 作为唯一源且为 `last`。

设计要点：该指令组需要两个 Tile 源，而谓词 Tile 仍然需要一个载体，归约又没有目标槽位可以放入它。因此掩码占用唯一空闲的位置，作为第二条只有源的绑定。

设计要点：基址寄存器在每个 PE 自己的寄存器文件中读取，因此同一 `PE_MASK` 选中的各 PE 可以用同一个索引 Tile 访问不同的 GM 区域。`PE_MASK` 选择参与的 PE；ExecutionMask 谓词 Tile 选择活动坐标，非活动坐标根本不形成地址。

<!-- PTO-READER-BLOCK: tile-mscatter-inc-effects role=effects -->
## 内存、Tile 与故障效果

不写入也不发布任何 Tile。索引 Tile 与上限 Tile 只被读取。

成功时，每个活动通道在 GM 中存储一次并记录恰好一个原子事件。这些存储保持可见：GM 没有回滚。

当某个探测发生故障时，执行体在第一个事件之前返回，因此 GM、事件流与每个 Tile 均保持不变。

<!-- PTO-READER-BLOCK: tile-mscatter-inc-constraints role=constraints -->
## 类型、形状与故障边界

指令束 `DataType` 必须是 `U32`，上限 Tile 也必须携带同一类型。`GMReductionOperationDataTypeLegal` 对 INC 只接受该类型，NDF `PTO-ATOM-RED-TYPE-LEGALITY-001` 还排除 Shared 操作数、向量、打包的 FP16x2 与 BF16x2 以及 U128。

每个 `B.DIM` 值必须在 `1..65535` 内，有效行数乘以有效列数不得超过 `PTO_MODEL_TILE_ELEMENTS`。对 RowMajor，有效列数不得超过物理列数，且物理列数必须是非零的 2 的幂。接受的布局为 RowMajor、CUBE_M16 与 CUBE_M32。

未知的 TLSU 编码引发 `Fault_IllegalInstruction`。分派器的绑定计数检查引发 `Fault_BundleControl`。操作数数量与合同不符的绑定组、缺少 `B.IOR`、存在 Shared 绑定、维度错误、上限 Tile 缺失或不匹配、布局不匹配，或活动坐标处元素未定义，都会引发 `Fault_TileLegality`。上述检查都在第一次 GM 探测之前完成；对齐与页故障只在探测阶段出现。

`PE_MASK=0000` 在 GM atom/red 分派器开头返回，属于严格无效果的情形；除此以外 `B.IOR` 与有效维度都是必需的。

<!-- PTO-READER-BLOCK: tile-mscatter-inc-example role=example -->
## 非规范演算示例

生成的 `MSCATTER_INC` 示例仅用于拼写与导航。替换操作数时必须遵守下方 owner 定义的 legality 和状态合同。

取 `U32`，`a0` 中的基地址为 `0x4000`，1 x 4 的 `U32` 索引 Tile 保存 `0, 4, 8, 12`，上限 Tile 保存 `3, 3, 3, 3`。GM 在这四个地址处保存 `0, 2, 3, 7`。

- 旧值 0 存入 1，旧值 2 存入 3。
- 旧值 3 与旧值 7 大于或等于上限 3，因此都存入 0。
- 记录 4 个原子事件，每个的 `write_performed` 均为 TRUE；不写任何 Tile。

规范宏写法为 `MSCATTER_INC <Col=4, U32>, [base=a0], SrcTile0, SrcTile1`，其中 `SrcTile0` 是索引 Tile，`SrcTile1` 是上限 Tile。该宏没有目标操作数。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MSCATTER_INC <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MSCATTER_INC | TLSU |  | 22 |  | GM_RED_VALUE |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| address | base-address |
| source0 | indices |
| source1 | limit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MSCATTER_INC.asl -->
```asl
readonly func InstructionContractMatches_MSCATTER_INC(operation: TileOperation) => boolean
begin
    return operation == TileOperation_MSCATTER_INC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.INC DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col
B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MSCATTER_INC.asl -->
```asl
readonly func InstructionContractHandler_MSCATTER_INC() => TileSemanticHandler
begin
    return TileHandler_GM_RED_VALUE;
end;
readonly func InstructionContractOperation_MSCATTER_INC() => TileOperation
begin
    return TileOperation_MSCATTER_INC;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.
- GM indexed operation uses byte-displacement addresses and complete preflight.

## Legality

- GM-only; Shared, vector, packed, and U128 forms are rejected.
- ValidRow and ValidCol are nonzero and match every Tile source and any published destination; selected-layout legality requires ValidCol <= Col, with CUBE descriptor rules applied separately.

## State effects

- All valid requests take effect; atom forms publish observed old values.

## Memory effects and ordering

### Memory effects

- One intrinsic atomic RMW per valid request.

### Ordering

- Duplicate-address events serialize in implementation-defined order.

## Exceptions

- Legality and access faults occur before effects.

## Examples

- BSTART.MSCATTER.INC DataType
