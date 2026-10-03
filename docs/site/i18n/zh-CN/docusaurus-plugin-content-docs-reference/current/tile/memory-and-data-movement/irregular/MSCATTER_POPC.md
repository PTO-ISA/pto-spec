<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MSCATTER_POPC.asl -->
# MSCATTER_POPC

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MSCATTER_POPC.asl`

GM indexed mscatter.popc operation.

## Normative identity {#PTO-INST-TILE-MSCATTER-POPC}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mscatter-popc-purpose role=purpose -->
## MSCATTER_POPC 的作用

`MSCATTER_POPC` 是 TLSU Function 27，写作 `BSTART.MSCATTER.POPC DataType`。它是一种按索引的 GM 归约：每个活动有效索引在 `B.IOR.RegSrc0` 指定的每 PE 基地址加上该索引字节位移所得的地址处贡献一次 `U32` 增量。它不读取值 Tile，也不发布目标。

执行体 `GM_RED_POPC` 把传输类型固定为 `TileDataType_U32`，`ExecuteBundleGMAtomRedOperation` 通过 `popc` 分支以 `TileOperandsLegal_GM_RED_POPC` 到达它。NDF `PTO-ATOM-RED-POPC-SEMANTICS-001` 给出同一契约：每个有效生效的 GM 地址一次 `U32` 增量，没有 ValueTile 也没有目标；NDF `PTO-ATOM-RED-BODY-SCHEMA-001` 补充说明 `mscatter.popc` 只有索引。

设计要点：没有 ValueTile，增量大小就无法编程；没有目标，就不返回任何观察到的值。可观察的效果是按地址统计命名该地址的活动索引数量。

<!-- PTO-READER-BLOCK: tile-mscatter-popc-mechanism role=mechanism -->
## 预检与增量提交

执行体先探测后写入。对每个活动坐标，它先以读、再以写探测该 `U32` 访问，立即引发探测故障；当读转换与写转换不一致时以 `Fault_DataPage` 拒绝。只有在该遍完成后，提交循环才会运行。

提交循环按 `ARBITRARY` 选择决定的顺序访问通道。每个通道加载旧的 `U32` 字，计算 `old + Zeros{PTO_XLEN} + 1`，按四字节元素位宽存储，并记录一个携带 `CurrentBundleMemoryOrder()` 的原子事件。

设计要点：增量是在 `U32` 位宽上的普通 `old + 1`，没有 limit 操作数，因此保存 `0xFFFFFFFF` 的字会变成 `0x00000000`。INC 形式不同：`GMIncValue` 与取自其值 Tile 的 limit 比较，并在大于等于该 limit 时返回零（NDF `PTO-ATOM-RED-INC-DEC-SEMANTICS-001`）。

设计要点：NDF `PTO-ATOM-RED-ORDERING-001` 让每个有效请求都是一个内在原子事件，并要求重复的有效地址以实现定义的顺序串行化且全部生效。因此命名同一地址的两个通道无论选择何种顺序都会加 2，这与 `MSCATTER` 不同，后者的重复存储只留下一个胜者。

<!-- PTO-READER-BLOCK: tile-mscatter-popc-inputs role=inputs-outputs -->
## 操作数角色与绑定

- `address` 是基地址，从执行 PE 自己的寄存器文件中由 `B.IOR.RegSrc0` 指定的 GPR 读取；`B.IOR` 是必需的，`RegSrc1`、`RegSrc2` 与 `RegDst` 必须编码为零。
- `source0` 是索引 Tile：元素为 `S32`、`U32`、`S64` 或 `U64`，具有 `LB1` 有效行数、`LB0` 有效列数与指令束布局。

执行体绑定一条终止 Local `B.IOT`，只携带索引 Tile；目标字段与 ValueTile 都被禁止（NDF `PTO-ATOM-RED-BODY-SCHEMA-001`）。`ExecuteBundleGMAtomRedOperation` 对 Function 27 期望恰好一个绑定，其他数量都会引发 `Fault_BundleControl`。

这里没有逐通道谓词操作数，因此唯一的通道过滤器是指令束 ExecutionMask，也没有目标可供合并模式的 ExecutionMask 填充。

<!-- PTO-READER-BLOCK: tile-mscatter-popc-effects role=effects -->
## 效果、顺序与故障可见性

成功时每个活动通道都对一个 `U32` 字完成一次读-改-写，并记录一个原子事件。索引 Tile 保持其描述符与载荷，不分配也不发布任何 Tile 目标。

GM 写入保持可见；通道的增量一旦存储，内存不会被回滚。当一个通道的读探测与写探测转换到不同地址时也会引发 `Fault_DataPage`，且发生在该通道的增量之前。

每个活动通道的每次读探测与写探测都在第一个事件之前完成（NDF `PTO-ATOM-RED-ORDERING-001`），因此因对齐或页故障被拒绝的指令束不改变任何 GM 位置。

由于增量按四字节元素位宽存储，计算结果只有低 32 位进入内存。

<!-- PTO-READER-BLOCK: tile-mscatter-popc-constraints role=constraints -->
## 类型、布局与故障边界

指令束 `DataType` 必须是 `U32`：`GMReductionOperationDataTypeLegal(GMReduction_POPC, data_type)` 不接受 `BSTART.MSCATTER.POPC` 的 `DataType` 字段域中的任何其他成员，执行体也不从任何 Tile 读取传输类型。

索引 Tile 为 `S32`、`U32`、`S64` 或 `U64`，必须采用指令束布局并具有 `LB1` 与 `LB0` 的有效形状。每个 `B.DIM` 值必须在 `1..65535` 内；对 `RowMajor`，形状要求 `ValidCol <= Col` 且 `Col` 为非零的 2 的幂。

由于该操作仅限 GM，本页生成的合法性排除 Shared、向量、打包与 U128 形式。`Fault_IllegalInstruction` 覆盖未知的 TLSU 编码，`Fault_BundleControl` 覆盖 `B.IOT` 数量错误，`Fault_TileLegality` 覆盖缺少 `B.IOR`、Shared 绑定、维度、类型或布局不匹配，或活动的索引元素未定义。访问故障在预检遍中引发。

本形式还允许 `B.DATR` 设置 `PadValueOrByteId`，其 pad union 为 `pad-value`；没有目标会使用它。

绑定上的 `PE_MASK=0000` 在分派器开头退出，早于解码、schema、GPR、维度、描述符、类型与内存检查。

<!-- PTO-READER-BLOCK: tile-mscatter-popc-example role=example -->
## 非规范演算示例

取 `U32`、`ValidRow=1`、`ValidCol=2`、`Col=4`，`a0` 中的基地址为 `0x1000`，一个 1 x 2 的 `U32` 索引 Tile 保存 `0, 0`。GM 在 `0x1000` 处保存 `U32` 字 `5`。

- 两个坐标的位移都是 `0`，因此都指向 `0x1000`。
- 两次增量都生效，因此无论提交循环选择何种顺序，`0x1000` 最终为 5 + 1 + 1 = 7。
- 若 `0x1000` 处的字原本是 `0xFFFFFFFF`，则最终为 `0x00000001`，因为每次增量都按 32 位存储。

宏写法为 `MSCATTER_POPC <Col=4, ValidCol=2, U32>, [base=a0], T#1`，其中 `T#1` 是索引 Tile；本形式没有目标操作数，因此不出现 `->T<Size>` 项。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MSCATTER_POPC <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MSCATTER_POPC | TLSU |  | 27 |  | GM_RED_POPC |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| address | base-address |
| source0 | indices |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MSCATTER_POPC.asl -->
```asl
readonly func InstructionContractMatches_MSCATTER_POPC(operation: TileOperation) => boolean
begin
    return operation == TileOperation_MSCATTER_POPC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.POPC DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col
B.IOT IndexTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MSCATTER_POPC.asl -->
```asl
readonly func InstructionContractHandler_MSCATTER_POPC() => TileSemanticHandler
begin
    return TileHandler_GM_RED_POPC;
end;
readonly func InstructionContractOperation_MSCATTER_POPC() => TileOperation
begin
    return TileOperation_MSCATTER_POPC;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.
- GM indexed operation uses byte-displacement addresses and complete preflight.

## Legality

- GM-only; Shared, vector, packed, and U128 forms are rejected.
- The body binds one terminating Local B.IOT carrying only IndexTile; ValueTile and destination fields are forbidden.
- ValidRow and ValidCol are nonzero and match every Tile source and any published destination; selected-layout legality requires ValidCol <= Col, with CUBE descriptor rules applied separately.

## State effects

- Every valid index contributes one U32 increment; no ValueTile or destination is read or published.

## Memory effects and ordering

### Memory effects

- One intrinsic atomic RMW per valid request.

### Ordering

- Duplicate-address events serialize in implementation-defined order.

## Exceptions

- Legality and access faults occur before effects.

## Examples

- BSTART.MSCATTER.POPC DataType
