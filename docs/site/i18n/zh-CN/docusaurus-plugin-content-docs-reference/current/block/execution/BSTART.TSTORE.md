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

`BSTART.TSTORE` 打开一个活动 Block 描述符；Block 体在完成前提供所需属性与绑定。

<!-- PTO-READER-BLOCK: block-bstart-tstore-mechanism role=mechanism -->
## 放置与执行机制

`BSTART.TSTORE` 必须位于所属 Block 的起始位置。后续属性、维度与绑定会累积到活动描述符中，直到 `BSTOP` 或下一条已接受的 `BSTART` 完成边界。

已接受载体使用 `L32` 编码类别；命令在读取绑定或改变状态前，会先解析所有显示字段。

完成时，只有全部模式与状态预检成功，描述符才会执行所选 Block 操作。

<!-- PTO-READER-BLOCK: block-bstart-tstore-inputs role=inputs-outputs -->
## 载体、绑定与输入

- 编码操作数：`DataType` — 源元素数据类型; `B.IOR.RegSrc0` — 每个 PE 的私有 GPR GM 基址; `B.IOR.RegSrc1` — 每个 PE 的私有 GPR 字节行步长; `B.DIM.LB0` — 普通 ValidCol 或 CUBE 有效列数; `B.DIM.LB1` — 普通 ValidRow 或 CUBE 有效行数; `B.DIM.LB2` — 普通物理 Col；CUBE 转换禁止使用; `B.IOT/B.IOS` — Local 或 Shared 源及参与掩码。
- Local 与 CUBE 存储使用终止源 `B.IOT`；完整或部分 Shared 存储改用源 `B.IOS`；可选 `B.DATR`、`B.DIM` 和 `B.IOR` 补全布局、形状、基址与行步长。
- 编码零仍是已分配值或明确规定的拒绝值；它不会静默表示省略操作数。

<!-- PTO-READER-BLOCK: block-bstart-tstore-effects role=effects -->
## 状态效果与顺序

启动 Block 会记录所选载体，并把操作执行推迟到完成边界。

完成全部预检与计算后，所有启用输出按归属单元规定的原子组发布；除非契约明确消费，成功执行后的数学源仍保持可用。

<!-- PTO-READER-BLOCK: block-bstart-tstore-constraints role=constraints -->
## 合法性、故障与原子性

固定比特、保留值、选择器取值域与必需的 Block 放置关系都在架构效果之前检查。

无效模式、状态、地址或后继条件通过当前归属单元定义的故障行为报告；本页不添加故障规则。

完整模式、绑定、就绪状态、别名、容量与分配预检发生在源快照和所有目的端发布之前。

<!-- PTO-READER-BLOCK: block-bstart-tstore-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
BSTART.TSTORE U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR a0, a1; B.IOT T#1, mask=1111, last; BSTOP
```

起始指令先建立描述符；后续载体按声明模式补充内容，最终完成边界触发验证与操作执行。
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
| 15 | reserved | future extension |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | reserved | future extension |
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
- For an allocated source, omitted LB0, LB1, and LB2 inherit ValidCol, ValidRow, and physical Col from its descriptor. For a pending Shared source they default to 1, 1, and ValidCol.
- An unallocated Shared source derives the smallest legal 128 B through 8 KiB per-PE capacity that contains the completed shape; Rows are then derived from capacity, Col, and DataType. Every selected source element is an undefined-register value and the temporary descriptor is never written back.
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
- The complete selected-PE footprint is preflighted before the first GM write, so a fault produces no partial store. After successful preflight individual store beats need not be atomic or ordered to observers.

### Ordering

- Resolve and validate the complete schema, source descriptor or temporary descriptor, dimensions, masks, per-PE GPR inputs, and every memory access before the first architectural store effect.
- Selected Shared-store PEs have no architecture-defined relative issue or commit order; software avoids overlapping GM regions or establishes ordering separately.

## Exceptions

- Reserved DataType, unsupported Layout, invalid dimensions, source descriptor mismatch, malformed bindings, illegal PE mask, unpublished or not-whole-parent-ready Shared source, or GM translation, permission, or alignment fault raises the applicable fault before the first GM write.
- A Shared source is hardware-waiting/no-effect until whole-parent readiness and publication are true; undefined Shared payload is not a legal source path.

## Examples

- BSTART.TSTORE U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR a0, a1; B.IOT T1, mask=1111, last; BSTOP
- BSTART.TSTORE FP16; B.IOS S7, mask=0011; B.SUBVIEW 0, a0, 0, 7; BSTOP
- BSTART.TSTORE FP16; B.IOS S7, mask=1111; BSTOP
