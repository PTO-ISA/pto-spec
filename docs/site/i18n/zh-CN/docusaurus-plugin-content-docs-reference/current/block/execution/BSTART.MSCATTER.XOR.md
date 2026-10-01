<!-- GENERATED FROM: asl/block/execution/BSTART.MSCATTER.XOR.asl -->
# BSTART.MSCATTER.XOR

**Normative ASL source:** `asl/block/execution/BSTART.MSCATTER.XOR.asl`

Starts GM indexed mscatter.xor operation.

## Normative identity {#PTO-INST-BLOCK-BSTART-MSCATTER-XOR}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mscatter-xor-purpose role=purpose -->
## 目的与范围

`BSTART.MSCATTER.XOR` 打开一个 Tile 内存指令束，其操作为 `MSCATTER_XOR`：一种索引归约。对每个通道，它读取位于基址加字节位移处的 GM 元素，与 Local 值 Tile 中的一个值做 XOR，并把结果写回。它不返回 Tile。

该命令是一个 32 位字（匹配值 `0x01a11181`，掩码 `0x07ffffff`），`DataType` 位于位 31 到 27。它携带固定的 TLSU 选择器 26，归约表把它映射为 `GMReduction_XOR`。保留的 `DataType` 编码在 `BSTART` 处引发 `Fault_IllegalInstruction`，发生在[指令束启动分派](../model/dispatch/start.md)提交任何前驱之前。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-xor-mechanism role=mechanism -->
## 如何阅读操作

提交时，[Tile 执行](../model/dispatch/tile-execution.md)把没有被更早选择器认领的 function 8 到 12 与 14 到 27 都交给 [GM 原子与归约处理程序](../model/dispatch/tlsu-gm-atom-red.md)。Function 26 是归约，因此处理程序不解析目标，而是调用 `GM_RED_VALUE`。

`GM_RED_VALUE` 先访问每个有效通道。它对地址分别做读探测与写探测，两次转换结果不同时引发 `Fault_DataPage`。只有全部通道通过之后，它才以任意顺序逐个通道应用更新：加载旧值，计算 `old XOR value`，存回，并记录一个原子内存事件。

设计要点：所有探测都在第一次更新之前运行。因此任何通道上的转换或权限故障都会使内存保持不变。契约把这一点表述为原子效果之前的完整预检。

设计要点：每次更新都重新加载当前内存值。地址相同的两个通道都会产生作用，并且由于 XOR 满足交换律与结合律，最终值不依赖于由实现定义的通道顺序。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-xor-inputs role=inputs-outputs -->
## 输入与输出

- `DataType` 必须是 `U32` 或 `U64`；其他已分配编码在提交时引发故障。
- `B.DIM` 的 `LB0` 是 ValidCol，`LB1` 是 ValidRow（默认 1），`LB2` 是物理 Col。
- 一条没有目标的 `B.IOT` 在 `source0` 中携带索引 Tile，在 `source1` 中携带值 Tile；没有谓词 Tile ExecutionMask 时它携带 `last`。
- 需要一条 `B.IOR BaseGPR, zero, zero, ->zero`；`RegSrc0` 是每个 PE 的基址。
- 索引 Tile 为 S32、U32、S64 或 U64。值 Tile 的类型为操作 `DataType`。二者都具有 `B.DIM` 的有效形状和指令束布局。

设计要点：操作数顺序与普通 `MSCATTER` 相反，后者的 `B.IOT` 先携带数据 Tile。这里索引在前，与所有索引归约共用的 `GM_RED_VALUE` 参数顺序一致。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-xor-effects role=effects -->
## 效果与状态

成功时，每个有效通道已把一个 GM 元素更新为 `old XOR value`，并按指令束内存顺序为每个通道记录一个原子事件。不写入任何 Tile、Shared Tile 或寄存器，两个源 Tile 保持其内容。

重复地址之间的顺序由实现定义，但对 XOR 而言它不会改变最终的内存值。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-xor-constraints role=constraints -->
## 边界与故障

`PE_MASK=0000` 是严格无操作，发生在任何 schema、描述符、类型或内存检查之前。

该操作仅作用于 GM。存在 `B.IOS` 绑定、缺少 `B.IOR`、PE 掩码不一致、维度非法、类型错误、源未定义，或形状、布局不匹配，都会引发 `Fault_TileLegality`。被处理程序自身的数量检查拒绝的绑定数量引发 `Fault_BundleControl`。内存故障保持其自身类型，且因为没有目标，不需要回滚。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-xor-example role=example -->
## 非规范用法示例

生成的 `BSTART.MSCATTER.XOR` 示例仅用于拼写与导航。替换操作数时必须遵守下方 owner 定义的 legality 和状态合同。

```asm
BSTART.MSCATTER.XOR U32
B.DIM zero, 8, ->LB0
B.DIM zero, 8, ->LB2
B.IOT T#1, T#2, mask=1111, last
B.IOR a0, zero, zero, ->zero
BSTOP
```

省略了 `LB1`，因此 ValidRow 为 1。索引 Tile `T#1` 与值 Tile `T#2` 都是 1 x 8 的 `U32` Tile。在每个 PE 上，8 个通道在任何更新之前都完成读探测与写探测。若两个通道的索引都是 `0x10`，值分别为 `0x0F` 和 `0xF0`，且 `a0 + 0x10` 处的字原为 `0x01`，则无论通道顺序如何，结果都是 `0x01 XOR 0x0F XOR 0xF0`，即 `0xFE`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MSCATTER.XOR DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_xor_32_gm26 | L32 | 32 | 0x01a11181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_xor_32_gm26 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_mscatter_xor_32_gm26 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | GM operation type | Encoded zero is interpreted by the selected operation. |

- `bstart_mscatter_xor_32_gm26.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | GM operation type |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MSCATTER.XOR.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MSCATTER_XOR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mscatter_xor_32_gm26);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.XOR DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col
B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MSCATTER.XOR.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MSCATTER_XOR() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MSCATTER_XOR()
    => TileOperation
begin
    return TileOperation_MSCATTER_XOR;
end;

pure func InstructionContractStartsTileBundle_BSTART_MSCATTER_XOR()
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

- BSTART.MSCATTER.XOR DataType
