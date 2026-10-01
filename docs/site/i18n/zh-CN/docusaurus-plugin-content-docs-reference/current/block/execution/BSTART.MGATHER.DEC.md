<!-- GENERATED FROM: asl/block/execution/BSTART.MGATHER.DEC.asl -->
# BSTART.MGATHER.DEC

**Normative ASL source:** `asl/block/execution/BSTART.MGATHER.DEC.asl`

Starts GM indexed mgather.dec operation.

## Normative identity {#PTO-INST-BLOCK-BSTART-MGATHER-DEC}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mgather-dec-purpose role=purpose -->
## 目的与范围

`BSTART.MGATHER.DEC` 打开一个 Tile memory 指令束，其操作为 `MGATHER_DEC`：每个通道一次原子读-改-写，在每通道上限之下递减全局内存（GM）中的计数器，并把观察到的旧值返回到一个新的 Local 目标 Tile 中。

该命令是一个 32 位字，在掩码 `0x07ffffff` 下匹配 `0x00f11181`，因此 `DataType` 占据第 31 至 27 位，固定的低位携带 TLSU 选择子 15。`ExecuteBundleGMAtomRedOperation` 通过 `GMAtomicOperationFromFunction` 把选择子 15 映射为 `GMAtomic_DEC` 并调用 `GM_ATOM_VALUE(...)`。保留的 `DataType` 编码在 `BSTART` 处引发 `Fault_IllegalInstruction`。

设计要点：上限是该通道的值 Tile 元素，因此一个指令束可以服务上限各不相同的通道。`GMDecValue` 中的规则是：零元素或高于上限的元素接收上限，而不是接收递减后的值。

<!-- PTO-READER-BLOCK: block-bstart-mgather-dec-mechanism role=mechanism -->
## 如何阅读操作

提交时，指令束通过 `GM_ATOM_VALUE` 运行 Tile 级执行体，后者调用共享的 atom 执行体 `GMRunAtomic`。该执行体访问每个活动通道，用 `BaseGPR` 加上该通道的字节位移计算地址，并先以读、再以写探测该地址；两次转换结果不同会引发 `Fault_DataPage`。只有全部通道通过之后，它才按 `ARBITRARY` 顺序逐个更新：装载旧元素、计算新元素、存储它、把旧值发布到目标，并记录一个原子事件。

`GMAtomicResult` 用 `GMDecValue(old, value)` 计算新元素：零的旧元素与高于上限的旧元素都返回上限，其他任何旧元素返回 `old - 1`。

设计要点：由于零元素会重新装载上限而不是向下回绕到零以下，该计数器是循环的，`0` 就是表示计数已耗尽的状态。读到 `0` 的消费者知道该元素的下一次递减会从上限重新开始，因此上限同时充当计数器的周期。

设计要点：高于上限的元素会被压回上限而不是被递减，因此降低活动计数器的上限会在下一次递减时把它修复。这正是上限可以在指令束之间安全改动而无需单独归一化步骤的原因。

<!-- PTO-READER-BLOCK: block-bstart-mgather-dec-inputs role=inputs-outputs -->
## 输入与输出

- `DataType` 必须是 `U32`；其他所有编码（包括 `S32` 与浮点类型）对该操作都被拒绝。
- 通道的值 Tile 元素就是该通道的上限，它与旧元素比较时不进行数值转换。
- `B.DIM` 的 `LB0` 是 ValidCol，`LB1` 是 ValidRow（默认 1），`LB2` 是物理 Col。三者都必须等于索引 Tile 与值 Tile 的有效列数、有效行数，以及目标的物理列数。
- `B.IOR BaseGPR, zero, zero, ->zero` 是必需的：`RegSrc0` 选择每个 PE 的基地址 GPR，另外三个选择子编码为零，而 `RegSrc0` 为 `zero` 时提供基地址零。
- 没有谓词 Tile ExecutionMask 时，一条终止 `B.IOT` 携带索引 Tile、上限 Tile 与目标。有该掩码时，第一条 `B.IOT` 携带两个源，没有目标也没有 `last`；第二条 `B.IOT` 携带掩码 Tile、目标与 `last`。

<!-- PTO-READER-BLOCK: block-bstart-mgather-dec-effects role=effects -->
## 效果与状态

每个活动通道把一个新计数写入其 GM 元素，并把旧计数发布到同一行同一列的目标元素。整个物理目标区域在这些结果之前就已定义：被 ExecutionMask 停用的坐标取该掩码的零值或合并值，活动通道之外的其他每个元素取指令束 `PadValue`。

成功时每个活动通道执行了一次原子更新并记录一个原子事件，目标也完全已定义。GM 结果保持可见；atom 形式不回滚内存。

<!-- PTO-READER-BLOCK: block-bstart-mgather-dec-constraints role=constraints -->
## 边界与故障

`PE_MASK=0000` 在 atom/red 分派器开头退出，早于其 schema、GPR、描述符、类型与内存检查。

未知的 TLSU 编码引发 `Fault_IllegalInstruction`。绑定条数不是上述的一条或两条记录会引发 `Fault_BundleControl`。缺少 `B.IOR`、Shared 绑定、非零的未使用 `B.IOR` 选择子、超出 `1..65535` 的维度、非 `U32` 的 `DataType`、错误的布局或形状，或活动的索引或上限元素未定义，都会在第一次探测之前引发 `Fault_TileLegality`。目标分配失败引发 `Fault_TileAllocation`，内存故障保留其自身种类。

<!-- PTO-READER-BLOCK: block-bstart-mgather-dec-example role=example -->
## 非规范用法示例

生成的 `BSTART.MGATHER.DEC` 示例仅用于拼写与导航。替换操作数时必须遵守下方 owner 定义的 legality 和状态合同。

```asm
BSTART.MGATHER.DEC U32
B.DIM zero, 2, ->LB0
B.DIM zero, 1, ->LB1
B.DIM zero, 2, ->LB2
B.IOT T#1, T#2, mask=1111, last, ->T<8B>
B.IOR a0, zero, zero, ->zero
BSTOP
```

`T#1` 是 1 x 2 的 `S32` 索引 Tile，保存 `0` 与 `4`，`T#2` 是 1 x 2 的 `U32` 上限 Tile，保存 `5` 与 `5`，`a0` 保存 `0x1000`。若 GM 在 `0x1000` 处保存 `3`、在 `0x1004` 处保存 `0`，通道 0 把计数器递减为 `2`，通道 1 重新装载上限 `5`，因为其计数器已达到 `0`。目标接收旧计数 `3` 与 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MGATHER.DEC DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mgather_dec_32_gm15 | L32 | 32 | 0x00f11181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mgather_dec_32_gm15 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Field value dispositions

### DataType (`PTO-FIELD-BLOCK-DATATYPE`)

Selects the Tile element data type carried by Block data attributes and typed Block starts.

**Encoded zero:** Code zero selects FP64; zero never means absent, inherited, NONE, or NULL.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | FP64 |
| 1 | assigned | FP32 |
| 2 | assigned | TF32 |
| 3 | assigned | HF32 |
| 4 | assigned | FP16 |
| 5 | assigned | BF16 |
| 6 | assigned | HiF8 |
| 7 | assigned | E4M3 |
| 8 | assigned | E5M2 |
| 9 | assigned | E3M2 |
| 10 | assigned | E2M3 |
| 11 | assigned | E2M1X2 |
| 12 | assigned | E1M2X2 |
| 13 | assigned | E8M0 |
| 14 | assigned | HiF4X2 |
| 15 | assigned | E6M2 |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | assigned | RCPE6M2 |
| 22 | reserved | future extension |
| 23 | reserved | future extension |
| 24 | assigned | U64 |
| 25 | assigned | U32 |
| 26 | assigned | U16 |
| 27 | assigned | U8 |
| 28 | assigned | U4X2 |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Reserved values are held for future extension and reject before architectural effects.

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_mgather_dec_32_gm15 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | GM operation type | Encoded zero is interpreted by the selected operation. |

- `bstart_mgather_dec_32_gm15.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | GM operation type |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MGATHER.DEC.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MGATHER_DEC(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mgather_dec_32_gm15);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.DEC DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col
B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MGATHER.DEC.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MGATHER_DEC() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MGATHER_DEC()
    => TileOperation
begin
    return TileOperation_MGATHER_DEC;
end;

pure func InstructionContractStartsTileBundle_BSTART_MGATHER_DEC()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- PE_MASK=0000 is a strict no-effect case; B.IOR and valid dimensions are required otherwise.
- LB0 supplies ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.

## Legality

- GM-only operation; Shared and vector forms are excluded.

## State effects

- Opens a complete GM indexed block.

## Memory effects and ordering

### Memory effects

- Complete preflight precedes atomic effects.

### Ordering

- Duplicate effective addresses serialize in implementation-defined order.

## Exceptions

- Reserved DataTypes fault IllegalInstruction; unsupported operation/type tuples fault TileLegality; access faults are preflighted.

## Examples

- BSTART.MGATHER.DEC DataType
