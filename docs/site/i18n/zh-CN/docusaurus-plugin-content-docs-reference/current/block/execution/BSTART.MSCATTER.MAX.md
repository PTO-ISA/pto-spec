<!-- GENERATED FROM: asl/block/execution/BSTART.MSCATTER.MAX.asl -->
# BSTART.MSCATTER.MAX

**Normative ASL source:** `asl/block/execution/BSTART.MSCATTER.MAX.asl`

Starts GM indexed mscatter.max operation.

## Normative identity {#PTO-INST-BLOCK-BSTART-MSCATTER-MAX}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mscatter-max-purpose role=purpose -->
## 目的与范围

`BSTART.MSCATTER.MAX` 打开一个 Tile memory 指令束，其操作为 `MSCATTER_MAX`：每个通道一次索引原子归约，保留全局内存（GM）元素与值 Tile 元素中较大的那个，并把它留在内存中。该指令束不发布 Tile，也不消耗任何源 Tile。

该命令是一个 32 位字，在掩码 `0x07ffffff` 下匹配 `0x01311181`，因此 `DataType` 占据第 31 至 27 位，固定的低位携带 TLSU 选择子 19。`ExecuteBundleGMAtomRedOperation` 把选择子 19 译码为归约操作 `GMReduction_MAX` 并调用 `GM_RED_VALUE(...)`。保留的 `DataType` 编码在 `BSTART` 处、指令束提交之前引发 `Fault_IllegalInstruction`。

设计要点：atom 同族形式 `BSTART.MGATHER.MAX` 执行同样的比较并额外报告旧值。对只想要当前最大值的程序来说，归约就是合适的形式，因为它不需要目标操作数，因此也不需要 Local 分配。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-max-mechanism role=mechanism -->
## 如何阅读操作

提交时，指令束运行 Tile 级执行体 `GM_RED_VALUE`，它先访问每个活动通道地址，并先以读、再以写探测该地址。两次转换结果不同会引发 `Fault_DataPage`。只有全部通道通过之后，它才按 `ARBITRARY` 顺序逐个更新：装载旧元素、计算新元素、存储它，并记录一个原子事件。

`GMReductionResult` 依据值 Tile 的元素类型选择比较方式：当 `TileDataTypeIsSigned` 成立时比较 `SInt` 值，否则比较 `UInt` 值。当旧元素更大时它返回旧元素，否则返回值 Tile 元素，因此已经持有最大值的元素仍会被写回，也仍会记录一个事件。

设计要点：所有探测都在第一次更新之前运行，因此发生故障的地址不改变 GM，也不记录事件，重试既不会把同一个最大值施加两次，也不会跳过某个通道。

设计要点：没有任何通道收到先前的元素，因此本形式无法告诉调用方最大值是否发生了变化。需要该答案的程序使用 atom 形式，其目标会发布观察到的旧值。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-max-inputs role=inputs-outputs -->
## 输入与输出

- `DataType` 必须是 `S32`、`S64`、`U32` 或 `U64`；其他所有编码（包括浮点与打包四位类型）对该操作都被拒绝。
- `B.DIM` 的 `LB0` 是 ValidCol，`LB1` 是 ValidRow（默认 1），`LB2` 是物理 Col。三者都必须等于索引 Tile 与值 Tile 的有效列数与有效行数，而 `LB2` 是布局规则所使用的物理列数。
- 一条终止 `B.IOT` 在 `source0` 中携带索引 Tile，在 `source1` 中携带值 Tile，没有目标并带有 `last`。使用谓词 Tile ExecutionMask 时，第一条 `B.IOT` 携带两个源但没有 `last`，第二条 `B.IOT` 携带掩码 Tile 与 `last`。
- `B.IOR BaseGPR, zero, zero, ->zero` 是必需的：`RegSrc0` 选择每个 PE 的基地址 GPR，另外三个选择子编码为零，而 `RegSrc0` 为 `zero` 时提供基地址零。
- 索引 Tile 是 `S32`、`U32`、`S64` 或 `U64` 并保存字节位移。值 Tile 使用操作 `DataType`，并与索引 Tile 具有相同的有效形状。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-max-effects role=effects -->
## 效果与状态

每个活动通道把一个 GM 元素保留为两个值中较大的那个，并记录一个原子事件。不发布任何 Tile，不创建任何 Local 分配，两个源 Tile 也保持其内容。GM 结果保持可见：归约不回滚内存。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-max-constraints role=constraints -->
## 边界与故障

`PE_MASK=0000` 在 atom/red 分派器开头退出，早于其 schema、GPR、描述符、类型与内存检查。

未知的 TLSU 编码引发 `Fault_IllegalInstruction`。绑定条数不是上述的一条或两条记录会引发 `Fault_BundleControl`。缺少 `B.IOR`、Shared 绑定、非零的未使用 `B.IOR` 选择子、超出 `1..65535` 的维度、不支持的类型、布局或形状，或活动的索引或值元素未定义，都会在第一次探测之前引发 `Fault_TileLegality`。内存故障保留其自身种类。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-max-example role=example -->
## 非规范用法示例

生成的 `BSTART.MSCATTER.MAX` 示例仅用于拼写与导航。替换操作数时必须遵守下方 owner 定义的 legality 和状态合同。

```asm
BSTART.MSCATTER.MAX S32
B.DIM zero, 2, ->LB0
B.DIM zero, 1, ->LB1
B.DIM zero, 2, ->LB2
B.IOT T#1, T#2, mask=1111, last
B.IOR a0, zero, zero, ->zero
BSTOP
```

`T#1` 是 1 x 2 的 `S32` 索引 Tile，保存 `0` 与 `4`，`T#2` 是 1 x 2 的 `S32` 值 Tile，保存 `3` 与 `-9`，`a0` 保存 `0x1000`。若 GM 在 `0x1000` 处保存 `-5`、在 `0x1004` 处保存 `2`，通道 0 把其元素抬高到 `3`，通道 1 保留 `2`，因为 `2` 大于 `-9`。内存最终为 `3` 与 `2`，并且不返回任何 Tile。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MSCATTER.MAX DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_max_32_gm19 | L32 | 32 | 0x01311181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_max_32_gm19 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_mscatter_max_32_gm19 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | GM operation type | Encoded zero is interpreted by the selected operation. |

- `bstart_mscatter_max_32_gm19.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | GM operation type |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MSCATTER.MAX.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MSCATTER_MAX(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mscatter_max_32_gm19);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.MAX DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col
B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MSCATTER.MAX.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MSCATTER_MAX() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MSCATTER_MAX()
    => TileOperation
begin
    return TileOperation_MSCATTER_MAX;
end;

pure func InstructionContractStartsTileBundle_BSTART_MSCATTER_MAX()
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

- BSTART.MSCATTER.MAX DataType
