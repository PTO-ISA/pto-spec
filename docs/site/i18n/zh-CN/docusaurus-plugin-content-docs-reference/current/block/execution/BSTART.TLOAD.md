<!-- GENERATED FROM: asl/block/execution/BSTART.TLOAD.asl -->
# BSTART.TLOAD

**Normative ASL source:** `asl/block/execution/BSTART.TLOAD.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-TLOAD}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-tload-purpose role=purpose -->
## BSTART.TLOAD 的作用

`BSTART.TLOAD` 打开一个 Tile 内存指令束，其操作为 `TLOAD`：从全局内存（GM）按步长读入一个 Tile。它是一个 32 位字（匹配值 `0x00011181`，掩码 `0x07ffffff`），唯一的字段是位 31 到 27 的 `DataType`。该形式携带固定的 TLSU 选择器 0，因此指令束总是运行 `TLOAD`。

四种目标共用这个起始命令：普通 Local Tile、Shared Tile、从普通 GM 布局转换而来的 Local CUBE Tile，以及权重模式 Shared Tile。`B.DATR` 的 `Layout` 与绑定种类（`B.IOT` 或 `B.IOS`）在它们之间选择。

设计要点：起始命令不读取内存。[指令束启动分派](../model/dispatch/start.md)检查描述符，提交任何有效的前驱，并以顺延（fallthrough）续址打开指令束。加载在该指令束被提交时执行，例如在 `BSTOP`、下一条 `BSTART`、trace `B.HINT` 或架构进入请求处。保留的 `DataType` 编码（15、21 到 23，或 29 到 31）在 `BSTART` 处、前驱提交之前引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: block-bstart-tload-mechanism role=mechanism -->
## 位置与机制

提交时，[Tile 执行](../model/dispatch/tile-execution.md)按固定顺序测试各专用选择器。对 `TLOAD` 指令束，结果如下：

- `B.DATR` 布局为 `OHWI2NK`（编码 10）或 `OIHW2NK`（编码 11）时，选择[权重到 Shared 执行](../model/dispatch/weight-to-shared-execution.md)。
- 布局编码在 21 到 26 之间时，选择 [CUBE 传输](../model/dispatch/tlsu-layout-conversion.md)。加载只接受 `ND2M32`（21）、`ND2M16`（22）和 `ND2N8`（23）。
- 存在任何 `B.IOS` 绑定时，选择 [Shared TLSU](../model/dispatch/shared-tlsu.md) 的 function 0。
- 否则由通用路径分配 `B.IOT` 指定的 Local 目标，并调用 Tile 层的 [TLOAD](../../tile/memory-and-data-movement/regular/TLOAD.md)。

每个被选中的 PE 读取自己的 `B.IOR` GPR：`RegSrc0` 是 GM 基址，`RegSrc1` 是以字节计的行步长。元素（row, column）从 `base + row * row_stride_bytes + column * element_size` 读取。打包四位列则在行基址上加 `floor(column / 2)` 字节，并按列的奇偶选择低半字节或高半字节。

设计要点：`TLOAD` 在第一个内存故障处停止。Tile 层例程逐个元素探测并读取，因此故障之前已读元素的加载事件仍保留记录。随后通用提交路径调用 `RollBackBundleTileDestinations`，释放本指令束分配的目标，因此不会发布新的 Local Tile。对 Shared 目标，契约允许已完成的读取保留在一个既不完整、也不是 whole-parent-ready 的记录中。

<!-- PTO-READER-BLOCK: block-bstart-tload-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `DataType` 是目标元素类型；接受编码 0 到 14、16 到 20 以及 24 到 28。在 CUBE 与权重形式中它是传输类型，且 `B.DATR` 的 `DataType` 字段必须为 `DTYPE_NONE`。
- 对普通形式，`B.DIM` 的 `LB0`、`LB1` 和 `LB2` 给出 ValidCol、ValidRow 和物理 Col。在 CUBE 形式中 `LB0` 和 `LB1` 是有效列数与有效行数，不使用 `LB2`。在权重模式中它们是 ValidK、ValidN 和 TotalK。
- 可选的 `B.IOR` 提供基址与字节行步长。权重模式则需要恰好一条三源 `B.IOR GMBase, ShapeGPR, StartGPR, ->zero`。
- 目标是一条终止的仅目标 `B.IOT`，或一条目标 `B.IOS`，二者不可兼有。源 Tile 绑定非法。

设计要点：省略 `B.IOR` 与编码 `zero` 不同。省略时基址为零，行步长为稠密值 `ceil(columns * element_bits / 8)`，使用解析后的 Col（CUBE 形式中为 `LB0`）。显式 `zero` 选择器读取零 GPR，因此提供真实的零基址或零步长；步长为零时每一行都读取相同的 GM 字节。

<!-- PTO-READER-BLOCK: block-bstart-tload-effects role=effects -->
## 待处理状态与完成

Local 形式分配一个目标，其 Rows 由 `B.IOT` 的 `SizeCode`、Col 与 `DataType` 推导，填充有效区域，并在提交成功时发布。

只有一个参与 PE 的 Shared 形式加载并发布完整的父对象。掩码中有多于一个 PE 时，`B.ASSEMBLE` 是必需的：Tile 执行在处理程序运行之前，以 `Fault_TileLegality` 拒绝没有它的多 PE Shared 目标。此时父对象在无空隙的 LAST 写者处原子发布。

CUBE 形式安装一个持久 CUBE 描述符，其几何由布局、`DataType`、`LB1` 和 `LB0` 决定；`TSize` 只表示容量。权重形式写入行主序的 Shared `[N][K]` 窗口，Cin 填充通道成为原始零值，不访问 GM。

<!-- PTO-READER-BLOCK: block-bstart-tload-constraints role=constraints -->
## 合法性与故障边界

`PE_MASK=0000` 是严格无操作，发生在 GPR 读取、分配、内存访问或故障之前。否则 ValidCol 和 ValidRow 必须非零，且不大于推导出的 Col 与 Rows，二者均为 2 的幂。

提交时，schema、形状与类型错误引发 `Fault_TileLegality`。Shared 路径对非法的 `B.IOR` schema 引发 `Fault_BundleControl`，CUBE 传输在没有可容纳的目标时引发 `Fault_TileAllocation`。GM 转换或权限故障保持其自身类型，并停止该请求。

设计要点：如[提交验证](../model/commit/validation.md)所述，失败的提交在指令束停止之前返回。指令束保持有效且 header 完整，因此陷阱处理程序看到的是整个指令束，重试会重新执行完整的加载。

<!-- PTO-READER-BLOCK: block-bstart-tload-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

一个物理形状为 8 x 64、有效区域为 7 x 60 的部分 `FP32` Tile，用宏形式写作 `TLOAD <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32>, [base=a0, stride=a1], ->T<2KB>`。它展开为如下指令束：

```asm
BSTART.TLOAD FP32
B.DIM zero, 60, ->LB0
B.DIM zero, 7, ->LB1
B.DIM zero, 64, ->LB2
B.IOR a0, a1
B.IOT mask=1111, last, ->T<5>
BSTOP
```

`SizeCode` 5 表示 2048 字节，因此 Rows 为 2048 / (64 * 4) = 8，覆盖 ValidRow 7。每个 PE 读取 7 * 60 = 420 个元素。若某 PE 的 `a1` 为 256，则元素（6, 59）从 `a0 + 6 * 256 + 59 * 4` 读取，即 `a0 + 1772`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TLOAD DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tload_32_d0c18bb0ab15 | L32 | 32 | 0x00011181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tload_32_d0c18bb0ab15 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_tload_32_d0c18bb0ab15 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | destination element data type | Encoded zero selects FP64. |

- `bstart_tload_32_d0c18bb0ab15.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | destination element data type |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |
| B.IOR.RegSrc1 | ordinary per-PE private-GPR byte row stride; weight-mode ShapeGPR packing Cin, Cout, KernelH, and KernelW |
| B.DIM.LB0 | ordinary ValidCol or CUBE valid columns |
| B.DIM.LB1 | ordinary ValidRow or CUBE valid rows |
| B.DIM.LB2 | ordinary physical Col; forbidden for CUBE conversion |
| B.IOT/B.IOS | Local or Shared destination, per-PE TSize, and participation mask |
| B.IOR.RegSrc2 | weight-mode StartGPR packing NStart and KStart |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TLOAD.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TLOAD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tload_32_d0c18bb0ab15);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Local destination: BSTART.TLOAD DataType; optional B.DATR Layout; B.DIM supplies ValidCol, ValidRow, and physical Col; optional B.IOR supplies per-PE base and byte row stride; exactly one terminating destination B.IOT allocates the Local result; BSTOP commits.
Shared destination: replace destination B.IOT with one destination B.IOS naming S0..S63, SizeCode, and PE_MASK. One participating issuer loads the complete parent; multiple issuers require B.ASSEMBLE with explicit writer ranges.
Local CUBE destination: encode B.DATR Layout ND2M32, ND2M16, or ND2N8 with DataType=DTYPE_NONE; require LB0=valid columns and LB1=valid rows, omit LB2, and use one terminating destination B.IOT.
Weight-mode Shared destination: explicit B.DATR OHWI2NK or OIHW2NK; LB0=ValidK, LB1=ValidN, LB2=TotalK; exactly one three-source B.IOR binds GMBase, ShapeGPR, StartGPR -> zero; singleton publication omits B.ASSEMBLE and multi-participant publication uses contiguous N-row B.ASSEMBLE ranges.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TLOAD.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TLOAD() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_TLOAD()
    => TileOperation
begin
    return TileOperation_TLOAD;
end;

pure func InstructionContractStartsTileBundle_BSTART_TLOAD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractCubeLayoutLegal_BSTART_TLOAD(
    data_layout: bits(5)) => boolean
begin
    return TileDataLayoutConversionIsLoad(data_layout);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is explicit. Optional B.DATR omission retains the default NORM layout.
- LB0/ValidCol and LB1/ValidRow default through the common destination-shape contract; omitted LB2/Col defaults to ValidCol. Rows are derived from TSize, Col, and DataType and must be at least ValidRow.
- Omitted B.IOR supplies base zero. Ordinary forms use resolved Col and CUBE forms use LB0 valid columns to derive dense byte row stride as ceil(columns * element_bits / 8). An explicitly encoded zero selector reads the zero GPR value and therefore supplies a real zero base or zero stride.
- Weight mode uses DTYPE_NONE and zero B.DATR controls; ShapeGPR packs Cin/Cout/KernelH/KernelW, StartGPR packs NStart/KStart, and the physical Shared descriptor is row-major [N][K] with K contiguous.

## Legality

- DataType accepts 0..14, 16..20, and 24..28; all other codes are reserved before effects.
- Exactly one destination domain is used: a terminating destination B.IOT for Local or one destination B.IOS for Shared. Source Tile bindings and mixed Local/Shared destinations are illegal.
- ValidCol and ValidRow must be nonzero and no greater than derived physical Col and Rows; Col and Rows are powers of two under the common Tile descriptor contract.
- PE_MASK=0000 is a strict no-op before GPR reads, allocation, memory access, faults, or descriptor changes.
- CUBE conversion accepts only Layout codes 21 through 23, requires explicit DTYPE_NONE, explicit nonzero LB0/LB1, absent LB2, one Local destination B.IOT, a supported non-64-bit non-HiF4X2 dtype, and no B.IOS.
- Weight mode accepts only OHWI2NK code 10 and OIHW2NK code 11, requires the exact fixed B.DATR fields, exactly one three-source B.IOR, equal participating-PE GMBase/ShapeGPR/StartGPR values, wide-checked Cin/Cout/kernel bounds, and aligned ValidK/KStart windows; codes 12 and 13 remain reserved for future KN forms.

## State effects

- Allocates/renames one Local destination or reallocates the named Shared destination with Rows derived from SizeCode, Col, and DataType, then fills the valid region.
- A singleton Shared issuer loads and publishes the complete logical parent. Multiple Shared issuers require B.ASSEMBLE with explicit ranges and atomic LAST publication.
- A successful CUBE form installs a persistent Matrix-location descriptor with CELL geometry derived from Layout, BSTART DataType, LB1 valid rows, and LB0 valid columns; TSize remains capacity only.
- A successful weight-mode Shared form atomically publishes the existing row-major NK descriptor; ordinary TLOAD and all non-weight layouts retain their existing behavior.

## Memory effects and ordering

### Memory effects

- For every selected PE and every element in ValidRow x ValidCol, read GM at base + row * row_stride_bytes + column * element_size, with packed four-bit columns adding floor(column / 2) to the byte-strided row base and selecting low/high by column parity.
- All accesses participate in PTO-RC with the block's aq/rl attributes and report the first fault while retaining prior completed reads.
- Weight mode maps OHWI/OIHW GM weights into canonical [kh][kw][c1][c0] order, defines Cin padding lanes as raw zero without GM access, and writes a row-major Shared [N][K] window without touching physical tails.

### Ordering

- Resolve and validate the full schema, dimensions, masks, per-PE GPR inputs, and destination allocation before accessing each element until the first fault.
- On success publish the complete destination atomically at block commit; on a fault retain only completed effects and do not advertise a partial destination as complete.

## Exceptions

- Reserved DataType, unsupported Layout, invalid dimensions, capacity/shape overflow, inconsistent or illegal PE masks, malformed binding schema, allocation failure, or memory translation/permission/alignment fault rejects before destination publication.
- The request stops at the first memory fault; completed reads may remain in a partially defined Local destination or Shared generation, which is not complete or whole-parent-ready.

## Examples

- BSTART.TLOAD U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR zero, a0; B.IOT mask=1111, ->T<1>; BSTOP
- BSTART.TLOAD FP16; B.DIM LB0, 32; B.DIM LB1, 4; B.IOS mask=0001, ->S7<1>; BSTOP
- BSTART.TLOAD FP16; B.DATR {ND2M16, DTYPE_NONE, Null, EQ, Default, 0, 0}; B.DIM LB0=K; B.DIM LB1=M; B.IOT mask=1111, <last>, ->M<1>; BSTOP
- BSTART.TLOAD FP16; B.DATR {OHWI2NK, DTYPE_NONE, Zero, EQ, Default, 0, 0}; B.DIM LB0=ValidK; B.DIM LB1=ValidN; B.DIM LB2=TotalK; B.IOR GMBase, ShapeGPR, StartGPR, ->zero; B.IOS mask, ->S0<SizeCode>; BSTOP
