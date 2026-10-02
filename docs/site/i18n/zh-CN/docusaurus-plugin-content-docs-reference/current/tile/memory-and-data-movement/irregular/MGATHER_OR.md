<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MGATHER_OR.asl -->
# MGATHER_OR

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MGATHER_OR.asl`

GM indexed mgather.or operation.

## Normative identity {#PTO-INST-TILE-MGATHER-OR}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mgather-or-purpose role=purpose -->
## MGATHER_OR 的作用

`MGATHER_OR` 对全局内存（GM）的每个通道执行一次原子读-改-写，并把每个观察到的旧值返回到一个 Local Tile 中。通道是索引 Tile 的一个活动有效坐标；其地址为基地址加上该通道的索引值。

它是 TLSU Function 17，写作 `BSTART.MGATHER.OR DataType`。块分派器 `ExecuteBundleGMAtomRedOperation` 把 Function 17 映射为 atom 操作 OR，并调用 `GM_ATOM_VALUE`，后者运行共享的 atom 执行体 `GMRunAtomic`。本操作没有独立 opcode。

设计要点：归约形式 `MSCATTER_OR` 执行相同的更新，但没有目标。程序需要每个通道观察到的值时使用 `MGATHER_OR`；该旧值是 atom 形式唯一额外提供的结果。

<!-- PTO-READER-BLOCK: tile-mgather-or-mechanism role=mechanism -->
## 寻址与更新机制

每个通道地址为 `base + displacement`。位移是以字节计的完整索引值：`S32` 符号扩展，`U32` 零扩展，`S64` 与 `U64` 按原样使用。它不乘以元素大小，因此由软件自行缩放索引。

预检最先进行。对每个活动通道，执行体先以读、再以写探测地址，按元素位宽要求自然对齐；若两次转换结果不同则引发 `Fault_DataPage`。同一遍中它对每个通道的操作数值做快照。

随后提交阶段按 `ARBITRARY` 选择决定的顺序访问各通道。每个通道加载旧值，计算新值，按元素位宽存储，把旧值写入其目标元素，并记录一个原子事件。

新值为 `old OR value`，在整个元素位宽上按位计算。操作数没有符号解释。

设计要点：所有探测都在第一个原子事件之前完成（NDF `PTO-ATOM-RED-ORDERING-001`）。因此发生故障的请求不改变任何 GM 位置，也不记录事件，修复故障后重试不会把任何更新施加两次。

设计要点：地址相同的通道以实现定义的顺序串行化，并且全部生效。每个通道自身是原子的；整个请求不是一个原子事务，其事件携带由指令束 acquire 与 release 属性得到的 `CurrentBundleMemoryOrder()`。

<!-- PTO-READER-BLOCK: tile-mgather-or-inputs role=inputs-outputs -->
## 操作数角色与绑定

- `destination0` 是本指令束分配的结果 Local Tile，具有指令束 `DataType` 与 `B.DIM` 形状。它接收旧值。
- `address` 是基地址，从当前内存代理寄存器文件中由 `B.IOR.RegSrc0` 指定的 GPR 读取。`B.IOR` 是必需的，且按块组成要求，`RegSrc1`、`RegSrc2` 与 `RegDst` 必须编码为零。该分派器通过 `BundleOperationBindingsComplete` 到达 `BundleOperationScalarBindingSchemaLegal`，因此 `RegSrc1`、`RegSrc2` 或 `RegDst` 非零时该检查返回假，指令束在任何探测之前引发 `Fault_TileLegality`。
- `source0` 是索引 Tile：`S32`、`U32`、`S64` 或 `U64`，具有指令束布局以及 `B.DIM` 的有效行数与有效列数。
- `source1` 是值 Tile。它必须具有指令束 `DataType`、指令束布局，以及与索引 Tile 相同的有效形状。

没有谓词 Tile ExecutionMask 时，一条终止 `B.IOT` 携带索引 Tile、第二个源与目标。有该掩码时，第一条 `B.IOT` 携带两个源，没有目标且没有 `last`；第二条 `B.IOT` 携带一个源、目标与 `last`。

设计要点：基址寄存器从每个 PE 自己的 GPR 文件读取，因此同一 `PE_MASK` 选中的各 PE 可以用同一个索引 Tile 访问不同的 GM 区域。

<!-- PTO-READER-BLOCK: tile-mgather-or-effects role=effects -->
## GM、目标与故障效果

在提交阶段之前，目标的每个物理元素都被初始化。ExecutionMask 下的非活动有效坐标接收该掩码的零值或合并值；其他每个元素接收指令束 `PadValue`，省略 `B.DATR` 时为 `Null`，而 `Null` 写入零位。随后活动通道用旧值覆盖各自的元素，整个物理区域被标记为已定义。

成功时，每个活动通道恰好写入 GM 一次，且按 NDF `PTO-ATOM-RED-ORDERING-001`，这些写入各自算作一个原子事件。这些 GM 写入保持可见；执行体不对内存做回滚。

若任一探测发生故障，执行体在第一个事件之前返回，分派器调用 `RollBackBundleTileDestinations`，释放本指令束分配的目标。不发布任何旧值。

<!-- PTO-READER-BLOCK: tile-mgather-or-constraints role=constraints -->
## 类型、形状与故障边界

指令束 `DataType` 必须是 `U32`、`U64` 之一。操作/类型矩阵中没有打包四位类型，NDF `PTO-ATOM-RED-TYPE-LEGALITY-001` 还排除 Shared 操作数、向量、打包的 FP16x2 与 BF16x2 以及 U128。

每个 `B.DIM` 值必须在 `1..65535` 内，有效行数乘以有效列数不得超过 `PTO_MODEL_TILE_ELEMENTS`。对 RowMajor，有效列数不得超过物理列数，且物理列数必须是非零的 2 的幂。布局为 RowMajor、CUBE_M16 或 CUBE_M32。

未知的 TLSU 编码引发 `Fault_IllegalInstruction`。`B.IOT` 命令数量错误引发 `Fault_BundleControl`。缺少 `B.IOR`、存在 Shared 绑定、维度、类型、形状或布局错误，或活动的索引或值元素未定义，引发 `Fault_TileLegality`。这些都发生在任何探测之前；目标分配失败引发 `Fault_TileAllocation`。

`PE_MASK=0000` 在 GM atom/red 分派器开头退出，早于其 schema、GPR、描述符、类型与内存检查。

<!-- PTO-READER-BLOCK: tile-mgather-or-example role=example -->
## 非规范演算示例

生成的 `MGATHER_OR` 示例仅用于拼写与导航。替换操作数时必须遵守下方 owner 定义的 legality 和状态合同。

取 `U32`，`a0` 中的基地址为 `0x2000`，1 x 2 的 `S32` 索引 Tile 保存 `0, 4`，值 Tile 保存 `0x00F0, 0x00F0`。GM 在 `0x2000` 处保存 `0x000F`，在 `0x2004` 处保存 `0x0000`。

- 通道 0 计算 `0x000F` OR `0x00F0` = `0x00FF`，并在 `0x2000` 处存入 `0x00FF`。
- 通道 1 计算 `0x0000` OR `0x00F0` = `0x00F0`，并在 `0x2004` 处存入 `0x00F0`。
- 目标接收旧值 `0x000F, 0x0000`。

宏形式写作 `MGATHER_OR <Col=2, U32>, [base=a0], T#1, T#2, ->T<128B>`，其中 `T#1` 是索引 Tile，`T#2` 是值 Tile。128 字节的目标容纳 32 个物理元素：2 个接收旧值，其余 30 个接收填充值；默认 `Null` 时为零位。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MGATHER_OR <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MGATHER_OR | TLSU |  | 17 |  | GM_ATOM_VALUE |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| address | base-address |
| source0 | indices |
| source1 | value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MGATHER_OR.asl -->
```asl
readonly func InstructionContractMatches_MGATHER_OR(operation: TileOperation) => boolean
begin
    return operation == TileOperation_MGATHER_OR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.OR DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col
B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MGATHER_OR.asl -->
```asl
readonly func InstructionContractHandler_MGATHER_OR() => TileSemanticHandler
begin
    return TileHandler_GM_ATOM_VALUE;
end;
readonly func InstructionContractOperation_MGATHER_OR() => TileOperation
begin
    return TileOperation_MGATHER_OR;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.
- GM indexed operation uses logical-element-index addresses and complete preflight.

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

- BSTART.MGATHER.OR DataType
