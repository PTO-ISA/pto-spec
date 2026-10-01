<!-- GENERATED FROM: asl/block/execution/BSTART.TSTORE.asl -->
# BSTART.TSTORE

**Normative ASL source:** `asl/block/execution/BSTART.TSTORE.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-TSTORE}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-tstore-purpose role=purpose -->
## BSTART.TSTORE 的作用

`BSTART.TSTORE` 打开一个 Tile 内存指令束，其操作为 `TSTORE`：把一个 Tile 的有效矩形按步长写入全局内存（GM）。它是一个 32 位字（匹配值 `0x00111181`，掩码 `0x07ffffff`），`DataType` 位于位 31 到 27。该形式携带固定的 TLSU 选择器 1，因此指令束总是运行 `TSTORE`。

源有三种：普通 Local Tile、已发布的 Shared Tile，或转换回普通 GM 布局的 Local CUBE Tile。源 Tile 只被读取，从不被修改或释放。

设计要点：起始命令不写内存。[指令束启动分派](../model/dispatch/start.md)先验证描述符并提交任何有效的前驱，存储在本指令束被提交时执行，例如在 `BSTOP`、下一条 `BSTART`、trace `B.HINT` 或架构进入请求处。保留的 `DataType` 编码在 `BSTART` 处、前驱提交之前引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: block-bstart-tstore-mechanism role=mechanism -->
## 放置与执行机制

提交时，[Tile 执行](../model/dispatch/tile-execution.md)按如下方式路由指令束：

- `B.DATR` 布局为 `M322ND`（24）、`M162ND`（25）或 `N82ND`（26）时，选择 [CUBE 传输](../model/dispatch/tlsu-layout-conversion.md) 的 function 1。
- `B.IOS` 源选择 [Shared TLSU](../model/dispatch/shared-tlsu.md) 的 function 1。
- 否则由通用路径对 `B.IOT` 源调用 Tile 层的 [TSTORE](../../tile/memory-and-data-movement/regular/TSTORE.md)。

每个被选中的 PE 把元素（row, column）写到 `base + row * row_stride_bytes + column * element_size`，其中 `B.IOR` 的 `RegSrc0` 是基址，`RegSrc1` 是字节行步长，二者都从该 PE 自己的 GPR 读取。打包四位列加上 `floor(column / 2)` 字节，并按列的奇偶写入低半字节或高半字节。

设计要点：`TSTORE` 逐个元素探测并写入，并在第一个故障处停止。故障之前完成的存储保留在 GM 中，源保持不变。NDF 条款 `PTO-BSTART-TSTORE-MEMORY-001` 规定了这一首故障规则。

设计要点：Shared 源受发布状态门控。若 Shared Tile 尚未发布，处理程序不引发故障地返回，不读取载荷、不消耗绑定，也不写 GM。指令束保持有效，因此生产者发布之后可以重试提交。

<!-- PTO-READER-BLOCK: block-bstart-tstore-inputs role=inputs-outputs -->
## 载体、绑定与输入

- `DataType` 是源元素类型；接受编码 0 到 14、16 到 20 以及 24 到 28。
- `B.DIM` 的 `LB0`、`LB1` 和 `LB2` 给出 ValidCol、ValidRow 和物理 Col。每个省略的维度有效值为一；省略不会复制源描述符的形状。
- 可选的 `B.IOR` 给出基址与字节行步长。省略时基址为零，步长为稠密行大小 `ceil(columns * element_bits / 8)`；显式 `zero` 选择器给出真实的零值。
- 源恰好是一条终止的仅源 `B.IOT`，或恰好一条源 `B.IOS`（`SizeCode` 0）。`B.IOS` 之后可选的 `B.SUBVIEW` 为每个 PE 选择显式范围。
- CUBE 形式要求 `B.DATR` 的 `DataType` 为 `DTYPE_NONE`，`LB0` 与 `LB1` 为有效列数与有效行数，没有 `LB2`，并使用一条 `B.IOT`。

设计要点：Shared 的 `PE_MASK` 只选择消费者 PE。对 function 1，任何非零掩码都合法，且掩码不隐含四分之一划分或范围；当每个 PE 要存储不同部分时，由 `B.SUBVIEW` 携带显式几何。

<!-- PTO-READER-BLOCK: block-bstart-tstore-effects role=effects -->
## 状态效果与顺序

成功时只有 GM 与内存事件状态发生变化，源绑定由正常的指令束完成过程消耗。Local 或 Shared 源保持其载荷、描述符、生产者掩码、就绪状态与生命周期。

被选中的 Shared 存储 PE 之间没有架构定义的相对发出或提交顺序。让两个 PE 存储重叠 GM 范围的程序必须另行建立顺序。

<!-- PTO-READER-BLOCK: block-bstart-tstore-constraints role=constraints -->
## 合法性、故障与原子性

`PE_MASK=0000` 是严格无操作，发生在 schema、描述符、GPR、内存或故障效果之前。否则 ValidCol 与 ValidRow 必须非零，ValidCol 不得超过物理 Col，且有效矩形必须位于源描述符之内。

schema、形状、类型与描述符错误在第一次 GM 写入之前引发 `Fault_TileLegality`。Shared 路径对非法的 `B.IOR` schema 引发 `Fault_BundleControl`。GM 转换、权限或对齐故障以其自身故障类型在该元素处停止存储。

设计要点：故障之后，[提交验证](../model/commit/validation.md)使指令束保持有效且 header 完整。重试从第一个元素重新运行存储处理程序，因此故障前已写的元素可能被第二次写入。

<!-- PTO-READER-BLOCK: block-bstart-tstore-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
BSTART.TSTORE U8
B.DIM zero, 64, ->LB0
B.DIM zero, 8, ->LB1
B.DIM zero, 64, ->LB2
B.IOR a0, a1
B.IOT T#1, mask=1111, last
BSTOP
```

`T#1` 是一个 8 x 64 的 `U8` Local 源。四个 PE 各存储 8 * 64 = 512 字节。在 `a1` 为 128 的 PE 上，元素（7, 63）写到 `a0 + 7 * 128 + 63`，即 `a0 + 959`，每行末尾未使用的 64 字节不会被写入。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TSTORE DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tstore_32_4048b6e8b0f4 | L32 | 32 | 0x00111181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tstore_32_4048b6e8b0f4 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_tstore_32_4048b6e8b0f4 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | source element data type | Encoded zero selects FP64. |

- `bstart_tstore_32_4048b6e8b0f4.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | source element data type |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |
| B.IOR.RegSrc1 | per-PE private-GPR byte row stride |
| B.DIM.LB0 | ordinary ValidCol or CUBE valid columns |
| B.DIM.LB1 | ordinary ValidRow or CUBE valid rows |
| B.DIM.LB2 | ordinary physical Col; forbidden for CUBE conversion |
| B.IOT/B.IOS | Local or Shared source and participation mask |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TSTORE.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TSTORE(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tstore_32_4048b6e8b0f4);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Local source: BSTART.TSTORE DataType; optional B.DATR Layout; optional B.DIM; optional B.IOR; exactly one terminating source B.IOT; BSTOP commits.
Shared source: BSTART.TSTORE DataType; optional B.DATR/B.DIM/B.IOR; exactly one source B.IOS with any nonzero consumer PE_MASK; optional B.SUBVIEW selects an explicit per-PE source range; BSTOP commits.
Local CUBE source: Function 1 encodes B.DATR Layout M322ND, M162ND, or N82ND with DataType=DTYPE_NONE; requires LB0=valid columns and LB1=valid rows, omits LB2, and uses one terminating source B.IOT.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TSTORE.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TSTORE() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_TSTORE()
    => TileOperation
begin
    return TileOperation_TSTORE;
end;

pure func InstructionContractStartsTileBundle_BSTART_TSTORE()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractCubeLayoutLegal_BSTART_TSTORE(
    data_layout: bits(5)) => boolean
begin
    return TileDataLayoutConversionIsStore(data_layout);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is explicit. Optional B.DATR omission retains the default NORM layout.
- Omitted LB0, LB1, and LB2 each have effective value one. The resolved dimensions are checked against the source descriptor; omission does not inherit its shape.
- An unallocated, pending, or incomplete Shared source remains waiting and produces no GM, binding-consumption, or descriptor effect.
- Omitted B.IOR supplies base zero. Ordinary forms use resolved Col and CUBE forms use LB0 valid columns to derive dense byte row stride as ceil(columns * element_bits / 8). An explicitly encoded zero selector reads the zero GPR value and therefore supplies a real zero base or zero stride.

## Legality

- TSTORE is selected only by TLSU Function 1 and has no standalone opcode. Former independent Shared movement encodings are reserved.
- DataType accepts 0..14, 16..20, and 24..28; codes 15, 21..23, and 29..31 are reserved and reject before effects.
- The completed block has exactly one source domain. Function 1 accepts one Local B.IOT or one Shared B.IOS. Shared PE_MASK selects participating consumer PEs and does not infer quarters or ranges; B.SUBVIEW carries explicit source geometry.
- PE_MASK=0000 is a strict no-op before schema, descriptor, GPR, memory, fault, or source-consumption effects.
- ValidCol and ValidRow are nonzero, ValidCol does not exceed physical Col, and the valid rectangle fits the persistent source descriptor.

## State effects

- Reads one Local or published, whole-parent-ready Shared source without modifying its payload, descriptor, producer mask, readiness, or lifetime.
- On success only GM and memory-event state change; the source binding is consumed by normal block completion.
- A Shared source that is pending or incomplete causes no payload read and no GM effect.

## Memory effects and ordering

### Memory effects

- For every selected PE and every selected element in ValidRow x ValidCol, write GM at base + row * row_stride_bytes + column * element_size, with packed four-bit columns adding floor(column / 2) to the byte-strided row base and selecting low/high by column parity.
- The selected-PE footprint is accessed element by element until the first fault; prior GM writes and memory events may remain visible. Individual store beats need not be atomic or ordered to observers.

### Ordering

- Resolve and validate the complete schema, source descriptor or temporary descriptor, dimensions, masks, and per-PE GPR inputs before accessing each element until the first fault.
- Selected Shared-store PEs have no architecture-defined relative issue or commit order; software avoids overlapping GM regions or establishes ordering separately.

## Exceptions

- Reserved DataType, unsupported Layout, invalid dimensions, source descriptor mismatch, malformed bindings, illegal PE mask, or GM translation, permission, or alignment fault raises the applicable fault before the first GM write.
- A Shared source is hardware-waiting/no-effect until whole-parent readiness and publication are true; undefined Shared payload is not a legal source path.

## Examples

- BSTART.TSTORE U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR a0, a1; B.IOT T1, mask=1111, last; BSTOP
- BSTART.TSTORE FP16; B.IOS S7, mask=0011; B.SUBVIEW 0, a0, 0, 7; BSTOP
- BSTART.TSTORE FP16; B.IOS S7, mask=1111; BSTOP
