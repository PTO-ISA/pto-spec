<!-- GENERATED FROM: asl/block/execution/BSTART.MSCATTER.asl -->
# BSTART.MSCATTER

**Normative ASL source:** `asl/block/execution/BSTART.MSCATTER.asl`

scatter using explicit logical element indices.

## Normative identity {#PTO-INST-BLOCK-BSTART-MSCATTER}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mscatter-purpose role=purpose -->
## BSTART.MSCATTER 的作用

`BSTART.MSCATTER` 打开一个 Tile 内存指令束，其操作为 `MSCATTER`：一种索引存储。Local 数据 Tile 的每个元素写入全局内存（GM）中基址加字节位移的位置，位移取自 Local 索引 Tile。该命令是一个 32 位字（匹配值 `0x00511181`，掩码 `0x07ffffff`），`DataType` 位于位 31 到 27。它携带固定的 TLSU 选择器 5。

散射不产生 Tile。两个源都不会被消耗或修改。

设计要点：起始命令不写内存。[指令束启动分派](../model/dispatch/start.md)先验证描述符并提交任何有效的前驱；散射在指令束被提交时执行，例如在 `BSTOP`、下一条 `BSTART`、trace `B.HINT` 或架构进入请求处。保留的 `DataType` 编码在 `BSTART` 处、前驱提交之前引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-mechanism role=mechanism -->
## 位置与机制

提交时，[Tile 执行](../model/dispatch/tile-execution.md)在包括普通 `MGATHER` 在内的较早专用选择器都不匹配之后，到达 [MSCATTER 处理程序](../model/dispatch/tlsu-mscatter.md)。处理程序验证完整的指令束，并调用 Tile 层的 [MSCATTER](../../tile/memory-and-data-movement/irregular/MSCATTER.md)。

对每个有效通道，地址为 `BaseGPR` 加上索引值。索引是字节位移：一个 S32、U32、S64 或 U64 值，不按元素大小缩放，也不做分解。

设计要点：Tile 层的 `MSCATTER` 在提交任何存储之前，探测每个有效通道的写权限。因此探测中发现的转换或权限故障不会在 GM 中留下本次散射的任何存储。只有所有探测都成功之后，存储才被提交并记录其存储事件。

设计要点：当两个通道指向同一地址时，胜出的通道由实现定义。ASL 中通道的提交顺序是任意选择的，`B.CATR` 的 atomic 属性也不会选定其中之一。需要确定结果的程序必须避免重复索引。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `DataType` 是传输元素类型。数据 Tile 的类型必须恰好为该类型。
- `B.DIM` 的 `LB0`、`LB1` 和 `LB2` 必须等于数据 Tile 的 ValidCol、ValidRow 和物理 Col。
- 第一条 `B.IOT` 没有目标，`SizeCode` 为零。它在 `source0` 中携带数据 Tile，在 `source1` 中携带索引 Tile。没有谓词 Tile ExecutionMask 时，它是唯一的绑定并携带 `last`。
- `B.IOR` 是必需的。`RegSrc0` 选择每个 PE 的 `BaseGPR`；`RegSrc1`、`RegSrc2` 与 `RegDst` 必须编码为零。`RegSrc0` 为 `zero` 时提供基址零。
- 可选的 `B.DATR` 选择布局：`ROWMAJOR`、`CUBE_M16` 或 `CUBE_M32`；`CUBE_N8` 被拒绝。两个 Tile 都必须使用指令束布局。

设计要点：`B.DIM` 重述一个已有 Tile 的形状，而不是描述新的目标。处理程序把数据 Tile 的有效行数、有效列数与物理列数和维度值比较，因此指令束必须精确描述该 Tile。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-effects role=effects -->
## 待处理状态与完成

每个有效通道存储一个传输元素。对打包四位 `DataType`，每个索引指定一个字节，其低半字节来自数据列 `2 * c`，高半字节来自列 `2 * c + 1`。此时数据的 ValidCol 必须恰好是索引 ValidCol 的两倍，因此不存在不完整的配对。

成功时处理程序结束本次尝试；不发布任何 Tile。PTO 内存顺序不变，只有重复地址之间的顺序由实现定义。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-constraints role=constraints -->
## 合法性与故障边界

`PE_MASK=0000` 是严格无操作，发生在 schema、源、GPR、维度、地址或内存检查之前。否则所有绑定必须使用同一个 `PE_MASK`。

未知的 TLSU 操作编码引发 `Fault_IllegalInstruction`。存在 `B.IOS` 绑定、缺少 `B.IOR` 或其字段非零、绑定 schema 格式错误、源元素未定义、类型或布局错误、形状不匹配，或维度不满足 `BundleMGATHERDimensionsLegal`，都在第一次探测之前引发 `Fault_TileLegality`。对 `ROWMAJOR`，该检查要求 ValidCol 不大于 Col，且 Col 是非零的 2 的幂。

内存故障保持其自身类型。没有需要回滚的目标，并且如[提交验证](../model/commit/validation.md)所述，指令束保持有效以便重试。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
BSTART.MSCATTER FP32
B.DIM zero, 16, ->LB0
B.DIM zero, 2, ->LB1
B.DIM zero, 16, ->LB2
B.IOT T#2, T#1, mask=1111, last
B.IOR a0, zero, zero, ->zero
BSTOP
```

数据 Tile `T#2` 是一个具有 16 个物理列的 2 x 16 `FP32` 行主序 Tile，索引 Tile `T#1` 是一个 2 x 16 的 `S32` Tile。在每个 PE 上，先探测 32 个通道，再提交 32 次存储。索引为 40 的通道在 `a0 + 40` 处写入 4 字节；索引不会乘以 4。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MSCATTER DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_32_0f0ba08bd798 | L32 | 32 | 0x00511181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_32_0f0ba08bd798 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Field value dispositions

### B.IOR.RegSrc0 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_mscatter_32_0f0ba08bd798 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | memory transfer element type selector | Encoded zero supplies numeric zero for the memory transfer element type selector. |

- `bstart_mscatter_32_0f0ba08bd798.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | memory transfer element type selector |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |
| B.IOR.RegSrc1 | per-PE private-GPR zero selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MSCATTER.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MSCATTER(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mscatter_32_0f0ba08bd798);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER DataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT DataTile, IndexTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MSCATTER.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MSCATTER() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MSCATTER()
    => TileOperation
begin
    return TileOperation_MSCATTER;
end;

pure func InstructionContractStartsTileBundle_BSTART_MSCATTER()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.
- LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies DataTile or destination physical Col; omitted LB1 and LB2 default to one and LB0 respectively.
- IndexTile entries are S32, U32, S64, or U64 logical element indices; each index is scaled by the transfer element width and is not decomposed.

## Legality

- Non-packed transfer shapes match IndexTile; packed four-bit uses Data.ValidCol == 2 * Index.ValidCol and rejects incomplete pairs.
- ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.
- Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.
- B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.

## State effects

- Closes any preceding block, initializes a new TileMemory descriptor, and selects TLSU function 5 with the encoded transfer DataType.
- No Tile is allocated and no source is consumed by the start instruction.

## Memory effects and ordering

### Memory effects

- Each indexed transaction stores one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the logical element index scaled by the transfer element width.
- All valid addresses are preflighted before the first architectural effect.

### Ordering

- Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.

## Exceptions

- Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects.

## Examples

- BSTART.MSCATTER DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK, <last>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
