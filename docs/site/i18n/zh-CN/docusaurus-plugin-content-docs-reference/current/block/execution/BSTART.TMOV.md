<!-- GENERATED FROM: asl/block/execution/BSTART.TMOV.asl -->
# BSTART.TMOV

**Normative ASL source:** `asl/block/execution/BSTART.TMOV.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-TMOV}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-tmov-purpose role=purpose -->
## BSTART.TMOV 的作用

`BSTART.TMOV` 打开一个活动 Block 描述符；Block 体在完成前提供所需属性与绑定。

<!-- PTO-READER-BLOCK: block-bstart-tmov-mechanism role=mechanism -->
## 放置与执行机制

`BSTART.TMOV` 必须位于所属 Block 的起始位置。后续属性、维度与绑定会累积到活动描述符中，直到 `BSTOP` 或下一条已接受的 `BSTART` 完成边界。

已接受载体使用 `L32` 编码类别；命令在读取绑定或改变状态前，会先解析所有显示字段。

完成时，只有全部模式与状态预检成功，描述符才会执行所选 Block 操作。

<!-- PTO-READER-BLOCK: block-bstart-tmov-inputs role=inputs-outputs -->
## 载体、绑定与输入

- 编码操作数：`DataType` — 具体源/目的 Tile 类型，或由 DTYPE_NONE 触发源描述符推断; `B.DATR.Layout` — Local 或 Shared Tile 布局选择; `B.DIM.LB0/LB1/LB2` — ValidCol, ValidRow, and physical Col; `B.IOT` — Local 源及/或重命名后的 Local 目的端; `B.IOS` — 绝对 Shared 源或原子 Shared 目的端。
- Function 2 用一条终止 `B.IOT` 绑定 Local 源和重命名后的 Local 目的端；L2S 使用源 `B.IOT` 与目的 `B.IOS`；S2L 使用源 `B.IOS` 与目的 `B.IOT`，并要求掩码一致。
- 编码零仍是已分配值或明确规定的拒绝值；它不会静默表示省略操作数。

<!-- PTO-READER-BLOCK: block-bstart-tmov-effects role=effects -->
## 状态效果与顺序

启动 Block 会记录所选载体，并把操作执行推迟到完成边界。

完成全部预检与计算后，所有启用输出按归属单元规定的原子组发布；除非契约明确消费，成功执行后的数学源仍保持可用。

<!-- PTO-READER-BLOCK: block-bstart-tmov-constraints role=constraints -->
## 合法性、故障与原子性

固定比特、保留值、选择器取值域与必需的 Block 放置关系都在架构效果之前检查。

无效模式、状态、地址或后继条件通过当前归属单元定义的故障行为报告；本页不添加故障规则。

完整模式、绑定、就绪状态、别名、容量与分配预检发生在源快照和所有目的端发布之前。

<!-- PTO-READER-BLOCK: block-bstart-tmov-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
BSTART.TMOV U8; B.IOT T#1, mask=1111, ->U<1>, last; BSTOP
```

起始指令先建立描述符；后续载体按声明模式补充内容，最终完成边界触发验证与操作执行。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TMOV DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tmov_32_211446509efb | L32 | 32 | 0x00211181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28,31]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tmov_32_211446509efb | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_tmov_32_211446509efb | DataType | 5 | 0–14, 16–20, 24–28, 31 | none | 15, 21–23, 29–30 | concrete transfer carrier interpretation or DTYPE_NONE source-descriptor inference | Encoded zero selects FP64. |

- `bstart_tmov_32_211446509efb.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | concrete transfer carrier interpretation or DTYPE_NONE source-descriptor inference |
| B.DATR.Layout | Local or Shared Tile layout selection |
| B.DIM.LB0/LB1/LB2 | ValidCol, ValidRow, and physical Col |
| B.IOT | Local source and/or renamed Local destination |
| B.IOS | absolute Shared source or atomic Shared destination |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TMOV.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TMOV(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tmov_32_211446509efb);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Local copy: BSTART.TMOV DataType; optional B.DATR Layout; optional B.DIM shape; one terminating B.IOT binds one Local source and one newly allocated Local destination with one common PE_MASK; BSTOP commits.
Canonical Shared TMOV: Function 2 uses one Local source B.IOT and one Shared destination B.IOS, or one Shared source B.IOS and one Local destination B.IOT; B.SUBVIEW and B.ASSEMBLE provide the explicit source/destination ranges.
Function 13 GMOV remains the distinct peer-Local operation.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TMOV.asl -->
```asl
// BSTART.TMOV accepts DTYPE_NONE (encoded 31). When neither B.DATR nor BSTART
// contributes a concrete type, Local/Shared TMOV inherits the bound source
// descriptor type. DTYPE_NONE is never installed in a tile descriptor.
readonly func InstructionContractHandler_BSTART_TMOV() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_TMOV()
    => TileOperation
begin
    return TileOperation_TMOV;
end;

pure func InstructionContractStartsTileBundle_BSTART_TMOV()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Concrete DataType codes explicitly select the transfer carrier interpretation. DTYPE_NONE infers the type from the bound source descriptor; failure to resolve a concrete source type rejects before destination effects. Optional B.DATR omission retains NORM layout.
- Omitted LB0, LB1, and LB2 inherit ValidCol, ValidRow, and physical Col from an allocated source descriptor. An unallocated, pending, or incomplete Shared source remains waiting and produces no destination effect.
- PE_MASK=0000 is a strict no-op before source reads, destination allocation, publication checks, faults, or binding consumption.

## Legality

- DataType accepts the 25 concrete TileDataType codes and code 31 DTYPE_NONE for source-descriptor inference; codes 15, 21..23, and 29..30 are reserved.
- Function 2 accepts Local-to-Local and canonical Local/Shared or Shared/Local TMOV schemas. A Shared destination with multiple participating PEs requires B.ASSEMBLE; a single-PE no-assemble writer publishes the whole parent.
- B.SUBVIEW is the source-range modifier and B.ASSEMBLE is the destination-generation modifier. Shared source legality requires hardware-maintained whole-parent readiness and publication.
- Function 13 GMOV remains accepted and unchanged. Other Shared movement function encodings are reserved and raise Fault_IllegalInstruction.
- For Local-to-Local TMOV, source and destination descriptors agree on capacity, Layout, physical Col, and completed valid shape. A concrete non-packed DataType may differ from the source backing type only at the same element width, and the destination preserves the source backing DataType.

## State effects

- Function 2 Local-to-Local copies Local payload and definedness into one renamed Local destination while preserving the Local source.
- A canonical Shared destination performs one whole-parent publication for a single-PE writer or an atomic B.ASSEMBLE generation at LAST. Shared source operations never modify Shared state.
- Shared source operations wait/no-op before payload access when whole-parent readiness or publication is absent.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete role, mask, size, descriptor, shape, data-type, layout, readiness, and allocation preflight precedes every payload, publication, or destination effect.
- A singleton Local-to-Shared writer publishes the complete parent atomically. A multi-PE writer publishes only through complete B.ASSEMBLE.LAST; a Shared source read is read-only.

## Exceptions

- Reserved DataType, unsupported Layout, malformed or unterminated binding schema, role/size/mask mismatch, incompatible descriptor, incomplete B.ASSEMBLE.LAST, unpublished Shared source, allocation failure, or shape mismatch rejects before destination effects.
- A Shared source is hardware-waiting/no-effect until the complete parent is ready and published; no undefined Shared payload is consumed.

## Examples

- BSTART.TMOV U8; B.IOT T#1, mask=1111, ->U<1>, last; BSTOP
- BSTART.TMOV U8; B.IOT T#1, mask=0001, last; B.IOS mask=0001, ->S7<9>; BSTOP
- BSTART.TMOV U8; B.IOS S7, mask=0011; B.SUBVIEW 0, a0, 0, 7; B.IOT mask=0011, ->T<7>, last; BSTOP
