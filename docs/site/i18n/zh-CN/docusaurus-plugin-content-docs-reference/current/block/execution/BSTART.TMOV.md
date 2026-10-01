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

`BSTART.TMOV` 打开一个 Tile 内存指令束，其操作为 `TMOV`：一种从不访问全局内存的 Tile 间拷贝。它是一个 32 位字（匹配值 `0x00211181`，掩码 `0x07ffffff`），`DataType` 位于位 31 到 27。该形式携带固定的 TLSU 选择器 2（Function 2）。

接受三个方向：Local 到 Local、Local 到 Shared，以及 Shared 到 Local。Function 13（`GMOV`，对等 Local 移动）是另一个具有自己起始命令的操作。其他以前的 Shared 移动 function 编码被保留，引发 `Fault_IllegalInstruction`。

设计要点：`TMOV` 是唯一一个起始命令可以编码 `DataType` 31（`DTYPE_NONE`）的 Tile 操作。[描述符合法性](../model/dispatch/descriptor-legality.md)只在描述符选择 `TMOV` 时接受该编码。提交时，具体的 `B.DATR` 类型优先，其次是具体的起始类型，否则从所绑定的源描述符推断类型。`DTYPE_NONE` 本身从不写入 Tile 描述符。

<!-- PTO-READER-BLOCK: block-bstart-tmov-mechanism role=mechanism -->
## 放置与执行机制

[指令束启动分派](../model/dispatch/start.md)在提交任何前驱之前检查描述符，因此保留的 `DataType`（15、21 到 23、29 或 30）会让前驱保持原位。拷贝本身在该指令束被提交时执行，例如在 `BSTOP`、下一条 `BSTART`、trace `B.HINT` 或架构进入请求处。

提交时，[Tile 执行](../model/dispatch/tile-execution.md)把任何带有 `B.IOS` 绑定的指令束交给 [Shared TLSU](../model/dispatch/shared-tlsu.md) 的 function 2。只有 `B.IOT` 绑定的指令束走通用路径，由 Tile 层的 [TMOV](../../tile/layout-and-rearrangement/layout/TMOV.md) 处理程序执行。

设计要点：Shared 源在分配任何 Local 目标之前受发布状态门控。若 Shared Tile 尚未发布，处理程序不引发故障地返回，也不消耗绑定。指令束保持有效，因此生产者发布之后可以重试提交。未定义的 Shared 载荷永远不会被拷贝。

<!-- PTO-READER-BLOCK: block-bstart-tmov-inputs role=inputs-outputs -->
## 载体、绑定与输入

- `DataType` 是具体的传输解释，或用于源描述符推断的 `DTYPE_NONE`。
- `B.DIM` 的 `LB0`、`LB1` 和 `LB2` 给出 ValidCol、ValidRow 和物理 Col。每个省略的维度有效值为一；省略不会复制源的形状。
- Local 到 Local：一条终止的 `B.IOT` 在同一个 `PE_MASK` 下绑定一个 Local 源和一个新分配的 Local 目标。
- Local 到 Shared：一条仅源 `B.IOT` 指定 Local 源，一条目标 `B.IOS` 指定 Shared 父对象。两条绑定使用相同的掩码，且源容量必须等于 Shared `SizeCode` 的容量。
- Shared 到 Local：一条源 `B.IOS` 指定 Shared 父对象，一条仅目标 `B.IOT` 分配 Local 结果。可选的 `B.SUBVIEW` 选择部分源范围。

设计要点：对 Local 到 Local，源与目标必须在容量、布局、物理 Col 和有效形状上一致。具体的非打包 `DataType` 只能在元素位宽相同时与源后备类型不同，且目标保留源的后备类型，因此拷贝可以重解释位而不做转换。

<!-- PTO-READER-BLOCK: block-bstart-tmov-effects role=effects -->
## 状态效果与顺序

Local 到 Local 把载荷与已定义性拷贝到一个重命名的 Local 目标，并保留 Local 源。

只有一个参与 PE 的 Local 到 Shared 发布整个父对象。有多于一个 PE 时需要 `B.ASSEMBLE`，每个写者把自己的范围提交到一个打开的代（generation）中，父对象在完整的 LAST 处原子发布。

Shared 到 Local 读取 Shared 源，不改变其描述符、载荷、就绪状态或生命周期。Local 目标必须在行数、列数、有效形状、数据类型和布局上与 Shared 视图一致；不一致时释放该目标并引发 `Fault_TileLegality`。

`TMOV` 没有全局内存效果。

<!-- PTO-READER-BLOCK: block-bstart-tmov-constraints role=constraints -->
## 合法性、故障与原子性

`PE_MASK=0000` 是严格无操作，发生在源读取、分配、发布检查、故障或绑定消耗之前。

角色、掩码、大小、描述符、形状、类型、布局、就绪与分配检查都在拷贝或发布任何载荷之前运行。失败时引发 `Fault_TileLegality`，在通用 Local 路径上对不完整的绑定流则引发 `Fault_BundleControl`，并释放本指令束分配的任何目标。

设计要点：如[提交验证](../model/commit/validation.md)所述，失败的提交使指令束保持有效且 header 完整，因此不会发布部分拷贝，重试会重新执行整个移动。

<!-- PTO-READER-BLOCK: block-bstart-tmov-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
BSTART.TMOV U8
B.DIM zero, 16, ->LB0
B.DIM zero, 8, ->LB1
B.DIM zero, 16, ->LB2
B.IOT T#1, mask=1111, last, ->U<1>
BSTOP
```

`T#1` 是一个占 128 字节的 8 x 16 `U8` Local Tile。`SizeCode` 1 同样是 128 字节，因此新的 `U#1` 有 128 / 16 = 8 行，每个 PE 拷贝全部 8 * 16 = 128 字节。该指令束没有 `B.IOS`，因此走通用 Local 路径。
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
- Omitted LB0, LB1, and LB2 each have effective value one; omission does not inherit the source descriptor shape. An unallocated, pending, or incomplete Shared source remains waiting and produces no destination effect.
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
