<!-- GENERATED FROM: asl/block/execution/BSTART.TPREFETCH.asl -->
# BSTART.TPREFETCH

**Normative ASL source:** `asl/block/execution/BSTART.TPREFETCH.asl`

Prefetches one typed, strided GM rectangle for each of the four PEs without a Tile destination.

## Normative identity {#PTO-INST-BLOCK-BSTART-TPREFETCH}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-tprefetch-purpose role=purpose -->
## BSTART.TPREFETCH 的作用

`BSTART.TPREFETCH` 打开一个活动 Block 描述符；Block 体在完成前提供所需属性与绑定。

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-mechanism role=mechanism -->
## 放置与执行机制

`BSTART.TPREFETCH` 必须位于所属 Block 的起始位置。后续属性、维度与绑定会累积到活动描述符中，直到 `BSTOP` 或下一条已接受的 `BSTART` 完成边界。

已接受载体使用 `L32` 编码类别；命令在读取绑定或改变状态前，会先解析所有显示字段。

完成时，只有全部模式与状态预检成功，描述符才会执行所选 Block 操作。

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-inputs role=inputs-outputs -->
## 载体、绑定与输入

- 编码操作数：`DataType` — 预取元素数据类型; `B.IOR.RegSrc0` — 每个 PE 的私有 GPR GM 基址; `B.IOR.RegSrc1` — 每个 PE 的私有 GPR 逻辑行步长（按元素计）; `B.DIM.LB0` — ValidCol; `B.DIM.LB1` — ValidRow; `B.DIM.LB2` — physical Col。
- 头部可包含 `B.DATR`、`B.DIM` 和 `B.IOR`；TPREFETCH 没有 Tile/Shared 绑定或目的端，因此明确禁止 `B.IOT` 与 `B.IOS`。
- 编码零仍是已分配值或明确规定的拒绝值；它不会静默表示省略操作数。

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-effects role=effects -->
## 状态效果与顺序

启动 Block 会记录所选载体，并把操作执行推迟到完成边界。

完成全部预检与计算后，所有启用输出按归属单元规定的原子组发布；除非契约明确消费，成功执行后的数学源仍保持可用。

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-constraints role=constraints -->
## 合法性、故障与原子性

固定比特、保留值、选择器取值域与必需的 Block 放置关系都在架构效果之前检查。

无效模式、状态、地址或后继条件通过当前归属单元定义的故障行为报告；本页不添加故障规则。

完整模式、绑定、就绪状态、别名、容量与分配预检发生在源快照和所有目的端发布之前。

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
BSTART.TPREFETCH FP16; B.DIM zero, 64, ->LB0; B.DIM zero, 4, ->LB1; B.DIM zero, 64, ->LB2; B.IOR zero, a0; BSTOP
```

起始指令先建立描述符；后续载体按声明模式补充内容，最终完成边界触发验证与操作执行。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TPREFETCH DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tprefetch_32_d5f83e5aadf6 | L32 | 32 | 0x00311181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tprefetch_32_d5f83e5aadf6 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_tprefetch_32_d5f83e5aadf6 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | prefetched element data type | Encoded zero selects FP64. |

- `bstart_tprefetch_32_d5f83e5aadf6.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | prefetched element data type |
| B.IOR.RegSrc0 | each PE's private-GPR GM base |
| B.IOR.RegSrc1 | each PE's private-GPR logical row stride in elements |
| B.DIM.LB0 | ValidCol |
| B.DIM.LB1 | ValidRow |
| B.DIM.LB2 | physical Col |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TPREFETCH.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TPREFETCH(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tprefetch_32_d5f83e5aadf6);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TPREFETCH DataType; optional B.DATR Layout; optional B.DIM LB0/ValidCol, LB1/ValidRow, LB2/Col; optional B.IOR base,row_stride; BSTOP
B.IOT and B.IOS are not members of a TPREFETCH block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TPREFETCH.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TPREFETCH() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_TPREFETCH()
    => TileOperation
begin
    return TileOperation_TPREFETCH;
end;

pure func InstructionContractStartsTileBundle_BSTART_TPREFETCH()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is explicit and B.DATR omission selects NORM layout.
- Omitted LB0 and LB1 each default to one; omitted LB2 defaults to resolved ValidCol.
- Omitted B.IOR supplies base zero and row stride equal to resolved Col independently for every PE. Explicit zero selectors read the architectural zero GPR and therefore supply actual zero values.

## Legality

- bstart_tprefetch_32_d5f83e5aadf6.DataType accepts only 0..14, 16..20, 24..28; all other encodings are reserved.
- TPREFETCH has implicit PE participation 1111 and no Local or Shared Tile binding.
- ValidCol and ValidRow are positive, Col is a nonzero power of two, and ValidCol does not exceed Col.

## State effects

- Starts a destination-free TLSU block whose successful architectural effects are limited to its defined typed memory accesses and ordering events.
- No Tile or Shared descriptor, allocation, payload, definedness, publication, or lifetime state changes.

## Memory effects and ordering

### Memory effects

- For every PE and every element in ValidRow x ValidCol, access GM at base + ((row * row_stride_elements + column) * element_size), with packed four-bit types using the same logical-element byte addressing as TLOAD.
- The operation produces the same typed-element load-event decomposition as TLOAD but allocates and writes no destination Tile. Cache level, placement, and retention are not architectural results.

### Ordering

- The four PE footprints are one combined preflighted block attempt; no request or event becomes effective until every address, translation, permission, and access check succeeds.
- All successful accesses participate in PTO-TSO using the block aq/rl attributes exactly as TLOAD.

## Exceptions

- Reserved DataType, unsupported Layout, explicit zero or out-of-range dimensions, non-power-of-two Col, malformed B.IOR, any B.IOT/B.IOS, or any participating-PE memory fault rejects before the first request or memory event.
- A memory fault is precise for the complete four-PE block and recovery reissues the complete combined footprint.

## Examples

- BSTART.TPREFETCH FP16; B.DIM zero, 64, ->LB0; B.DIM zero, 4, ->LB1; B.DIM zero, 64, ->LB2; B.IOR zero, a0; BSTOP
