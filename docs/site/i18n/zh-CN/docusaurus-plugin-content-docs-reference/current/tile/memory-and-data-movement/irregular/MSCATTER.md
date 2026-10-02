<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MSCATTER.asl -->
# MSCATTER

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MSCATTER.asl`

scatter using explicit logical element indices.

## Normative identity {#PTO-INST-TILE-MSCATTER}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mscatter-purpose role=purpose -->
## MSCATTER 的作用

`MSCATTER` 是 TLSU Function 5，写作 `BSTART.MSCATTER DataType`。它读取一个 Local 数据 Tile 与一个 Local 索引 Tile，并针对索引 Tile 的每个活动有效坐标存储一个传输元素或一个打包字节，地址为 `B.IOR.RegSrc0` 指定的每 PE 基地址加上该索引值（按字节位移读取）。当没有 ExecutionMask 生效，或 `BundleExecutionMaskActiveAt` 选中该坐标时，该坐标即为活动坐标。

拥有者声明 `InstructionContractUsesByteDisplacements_MSCATTER` 为 TRUE、`InstructionContractUsesMaskTile_MSCATTER` 为 FALSE、`InstructionContractWritesMemory_MSCATTER` 为 TRUE、`InstructionContractIsAtomicMemoryOperation_MSCATTER` 为 FALSE。分派器 `ExecuteBundleMSCATTEROperation` 解码 Function 5，检查绑定形状、维度与描述符，然后调用 `TileOperandsLegal_MSCATTER` 与执行体 `MSCATTER`。

设计要点：`InstructionContractUsesMaskTile_MSCATTER` 为 FALSE，且没有逐通道谓词操作数，因此索引 Tile 的每个活动有效坐标都会存储。该形式接受的唯一逐坐标过滤器是指令束 ExecutionMask，它在这里的坐标来源是索引 Tile。

<!-- PTO-READER-BLOCK: tile-mscatter-mechanism role=mechanism -->
## 寻址、预检与存储提交

每个地址为 `base + displacement`，其中位移是以字节计的完整索引值。`S32` 符号扩展，`U32` 零扩展，`S64` 与 `U64` 按原样使用。它从不乘以元素大小，也从不除以 `ValidCol`（NDF `PTO-INDEXED-TLSU-STRIDE-001`），因此需要按元素缩放的寻址必须由程序自行缩放索引。

执行体分两遍进行。预检遍历活动坐标，用 `TileMemoryByteDisplacementAddress` 构造每个地址，用 `ProbeTileMemoryAccess` 按元素位宽对齐对该地址做写探测，并记录原始地址、转换后地址与源元素位；`RaiseDataAccessFault` 在首个失败的探测处结束执行体。随后提交遍 `CommitIndexedScatterTransactions` 存储这些已记录的值，并为每个通道记录一个存储事件。`StoreTileMemoryElement` 把值归一化到元素位宽；打包四位通道则用 `StoreTranslated` 直接写入一个组装好的字节，低半字节取自第一个逻辑元素，高半字节取自第二个逻辑元素。

设计要点：只有在预检完成后才会进入提交遍，因此任何存储与存储事件都不会先于失败的探测发生。只要有一个活动地址出错，整个 scatter 就不改变 GM，修复故障后重试也不会施加部分更新。

设计要点：提交遍按 `ARBITRARY` 选择决定的顺序访问通道，因此重复或重叠的目标地址具有实现定义的胜者。NDF `PTO-MSCATTER-DUPLICATE-ORDER-001` 规定 `B.CATR.atomic` 不施加内部通道顺序，它只使整个指令束效果不可交错。因此，两个向同一地址存储不同值的通道会留下取决于所选顺序的结果。

<!-- PTO-READER-BLOCK: tile-mscatter-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `address` 是基地址，从执行 PE 自己的寄存器文件中由 `B.IOR.RegSrc0` 指定的 GPR 读取；`B.IOR` 是必需的，`RegSrc1`、`RegSrc2` 与 `RegDst` 必须编码为零。
- `source0` 是数据 Tile：指令束 `DataType`、`LB1` 有效行数、`LB0` 有效列数、`LB2` 物理列数，以及指令束布局。
- `source1` 是索引 Tile：元素为 `S32`、`U32`、`S64` 或 `U64`，有效形状与数据 Tile 匹配，采用指令束布局，其物理列数不与 `LB2` 比较。

没有谓词 Tile ExecutionMask 时，一条终止 `B.IOT` 携带数据 Tile 与索引 Tile，且没有目标。有该掩码时，第一条 `B.IOT` 携带两个源且不是 `last`，第二条 `B.IOT` 只携带掩码 Tile 作为其源且为 `last`。所有绑定必须携带相同的 `PE_MASK`，并且每个绑定上的 `PE_MASK=0000` 在分派器开头即严格无操作，早于解码、schema、GPR、维度、描述符与内存检查。

基址寄存器从执行 PE 自己的寄存器文件读取（`ReadPEAbsoluteGPROperand`），因此同一 `PE_MASK` 选中的各 PE 可以用同一个索引 Tile 访问不同的 GM 区域。

<!-- PTO-READER-BLOCK: tile-mscatter-effects role=effects -->
## 效果、已定义性与填充

成功时只有 GM 与内存事件状态改变。不分配目标 Tile，并且数据 Tile 与索引 Tile 在成功或拒绝后都保持其描述符与载荷不变。

没有 ExecutionMask 时，`IndexedTLSUExecutionMaskContentsDefined` 要求两个 Tile 的整个有效区域都处于已定义状态。有该掩码时，它要求与掩码相同的布局与有效形状，并且只在掩码的活动坐标处检查已定义性，因此被掩码排除的未定义元素可以容忍。

此处 `B.DATR` 只能设置 `Layout`：显式的非零 `PadValue` 字段会被拒绝，因为该形式的 pad union 是 `must-zero`，而且没有目标的物理填充区可以接收填充值。同理，合并模式的 ExecutionMask 也没有可写入的位置，`PrepareSelectedBundleExecutionMaskMerge` 在本指令束中找不到目标绑定。

<!-- PTO-READER-BLOCK: tile-mscatter-constraints role=constraints -->
## 类型、布局与故障边界

指令束 `DataType` 由 `BSTART.MSCATTER` 携带，且必须等于数据 Tile 的类型。NDF `PTO-MSCATTER-BYTE-DISPLACEMENT-001` 要求支持 `B8-NP`、`B16`、`B32`、`B64` 以及打包四位传输数据，索引元素为 `S32`、`U32`、`S64` 或 `U64`，并要求原始载体位直接搬移而不做数值有效性拒绝。索引 Tile 本身从不是四位载体。

打包四位传输要求数据 Tile 的有效列数恰好是索引 Tile 的两倍，即 `Data.ValidCol == 2 * Index.ValidCol`，不完整的半字节对会被拒绝。布局为 `RowMajor`、`CUBE_M16` 与 `CUBE_M32`；`CUBE_N8` 会被拒绝，`RowMajor` 还要求 `ValidCol <= Col` 且 `Col` 为非零的 2 的幂。每个 `B.DIM` 值必须在 `1..65535` 内。

未知的 TLSU 编码引发 `Fault_IllegalInstruction`。缺少 `B.IOR`、`B.IOT` 绑定形状错误、维度超范围、类型、布局或形状不匹配，或活动的源元素未定义，都会引发 `Fault_TileLegality`，这也是 `ExecuteBundleMSCATTEROperation` 用于其全部 schema 检查的故障。探测失败引发 `Fault_DataAlignment` 或 `Fault_DataPage`，且发生在首次存储之前。

<!-- PTO-READER-BLOCK: tile-mscatter-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `U32`、`ValidRow=1`、`ValidCol=2`、`Col=4`，`a0` 中的基地址为 `0x1000`，一个 1 x 2 的数据 Tile 保存 `7, 9`，一个 1 x 2 的 `U32` 索引 Tile 保存 `4, 0`。

- 坐标 (0, 0) 的位移为 `4`，因此 `0x1004` 收到 `7`。
- 坐标 (0, 1) 的位移为 `0`，因此 `0x1000` 收到 `9`。
- 两次探测必须都先成功：本例中 `0x1000` 与 `0x1004` 都是 4 字节对齐且可写，任一探测失败都会抑制两次存储。
- 若两个坐标的位移都是 `0`，两者都会存储到 `0x1000`，该处最终内容将是 `7` 或 `9`，取决于实现定义的提交顺序。

宏写法为 `MSCATTER <Col=4, ValidCol=2, U32>, [base=a0], T#1, T#2`，其中 `T#1` 是数据 Tile，`T#2` 是索引 Tile。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MSCATTER <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MSCATTER | TLSU |  | 5 |  | MSCATTER |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

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

## Operands and results

| Field | Architectural role |
| --- | --- |
| address | base-address |
| source0 | source data |
| source1 | logical element indices |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MSCATTER.asl -->
```asl
readonly func InstructionContractOperation_MSCATTER() => TileOperation
begin
    return TileOperation_MSCATTER;
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

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MSCATTER.asl -->
```asl
readonly func InstructionContractHandler_MSCATTER() => TileSemanticHandler
begin
    return TileHandler_MSCATTER;
end;

pure func InstructionContractUsesLogicalElementIndices_MSCATTER()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MSCATTER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MSCATTER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractWritesMemory_MSCATTER()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.
- LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.
- IndexTile entries are S32, U32, S64, or U64 logical element indices; each index is scaled by the transfer element width and is not decomposed.

## Legality

- Non-packed transfer shapes match IndexTile; packed four-bit uses Data.ValidCol == 2 * Index.ValidCol and rejects incomplete pairs.
- ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.
- Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.
- B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.

## State effects

- Source Tile descriptors and payloads persist unchanged after success or rejection.
- On success only memory and memory-event state change; MSCATTER allocates no destination Tile.

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
