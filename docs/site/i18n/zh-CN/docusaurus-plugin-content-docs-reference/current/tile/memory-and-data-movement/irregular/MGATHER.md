<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MGATHER.asl -->
# MGATHER

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MGATHER.asl`

gather using explicit logical element indices.

## Normative identity {#PTO-INST-TILE-MGATHER}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mgather-purpose role=purpose -->
## MGATHER 的作用

`MGATHER` 按通道从全局内存 (GM) 读取数据，并把读到的元素写入新分配的 Local 目标 Tile。它是由 `TLSU` 执行、通过选择器编码的 Tile 操作，由 TLSU Function 4 选中，写作 `BSTART.MGATHER DataType`。块派发器 `ExecuteBundleMGATHEROperation` 检查指令束，然后调用共享 Tile 模型 `MGATHER`。

一个通道就是索引 Tile 有效区域中的一个坐标。它的地址是 `BaseGPR` 加上该通道索引值所解释的字节位移。`MGATHER` 没有独立操作码。

设计要点：通道数量取决于索引 Tile 的有效矩形，而不是内存布局，因此即使地址不确定，结果形状也是静态已知的。四个索引总是产生一个四元素的有效区域，无论这四个地址多么分散。

<!-- PTO-READER-BLOCK: tile-mgather-mechanism role=mechanism -->
## 寻址与两阶段机制

模型对索引 Tile 做两轮遍历。预检轮访问有效区域的每个启用坐标，用 `TileMemoryByteDisplacementAddress` 按“基址加 `TileIndexByteDisplacement`”构造地址，并用 `ProbeTileMemoryAccess` 探测。探测失败时通过 `RaiseDataAccessFault` 抛出该探测自身的故障。位移是索引值的完整字节值：`S32` 符号扩展，`U32` 零扩展，且从不乘以元素宽度。

发布轮先填充每个物理目标元素，然后只读取已预检的通道，使用 `LoadTranslatedUnsigned`，通过 `RecordLoadEvent` 为每次读取记录一个读取事件，用 `MarkTilePhysicalRegionDefined` 标记区域，最后用一次赋值安装完成后的 Tile。

设计要点：探测只是读探测，既不访问内存也不访问目标。因此每个通道地址都在首次读取事件之前、在任何目标元素改变之前完成解析、翻译和对齐检查。发生故障的请求不会留下部分目标，所以重试不会重复施加任何效果。

<!-- PTO-READER-BLOCK: tile-mgather-inputs role=inputs-outputs -->
## 操作数角色与绑定

- `destination0` 是新的 Local Tile，使用指令束 `DataType` 和 `B.DIM` 形状。它接收读到的元素。
- `address` 是基址，从当前内存代理寄存器文件中由 `B.IOR.RegSrc0` 指定的 GPR 读出。
- `source0` 是索引 Tile：`S32`、`U32`、`S64` 或 `U64`，与指令束布局以及 `B.DIM` 的有效行数和有效列数一致。

`B.IOR` 是必需的，且 `RegSrc1`、`RegSrc2` 与 `RegDst` 必须编码为零。在没有谓词 Tile ExecutionMask 时，一条终结性 `B.IOT` 携带索引 Tile 和目标。存在谓词 Tile ExecutionMask 时，同一条命令把该谓词 Tile 作为额外的 Local 源携带，因此 `ExecuteBundleMGATHEROperation` 仍然只看到一个 Tile 绑定。索引 Tile 是 Local 操作数，永远不会被写入。

<!-- PTO-READER-BLOCK: tile-mgather-effects role=effects -->
## 发布、已定义性与填充

在首次读取之前，模型先初始化每个物理目标元素。有效区域之外的元素通过 `TilePadValueForDataType` 接收指令束 `PadValue`。存在 ExecutionMask 时，有效区域内未被掩码启用的坐标改为接收 `IndexedGatherInactiveDestinationValue`：掩码选择归零时为零位，否则为同一坐标处的合并基准元素。随后已预检的通道用读到的值覆盖自己的元素。

设计要点：对 `TilePad_Null`，`TilePadValueForDataType` 返回零位；省略 `B.DATR` 会使 `CurrentBundlePadValue` 返回 `TilePad_Null`。因此在此处省略该命令与编码填充码 `00` 都写入零位，且两种情况下每个物理元素都被标记为已定义。之后读取非有效元素返回零而不是未定义值，所以使用方无需为填充区域做有效性判断。

成功时完整物理目标区域已定义且 `contents_defined` 为真。若某次探测发生故障，模型在首次读取之前返回，派发器调用 `RollBackBundleTileDestinations`，因此不会发布任何目标。

<!-- PTO-READER-BLOCK: tile-mgather-constraints role=constraints -->
## 类型、形状与故障边界

索引 Tile 必须通过 `IndexedTLSUMemoryIndexDataTypeLegal`，即为 `S32`、`U32`、`S64` 或 `U64`。传输 `DataType` 必须通过 `IndexedTLSUOrdinaryTransferDataTypeLegal`，该判定接受所有被 `TileDataTypeIsFourBit` 拒绝的类型，并加上五种四位类型 `E2M1X2`、`E1M2X2`、`HiF4X2`、`S4X2` 与 `U4X2`。对于这五种之一，有效列数必须为偶数且等于索引有效列数的两倍，且所索引的那一个字节同时携带两个逻辑半字节。

布局为 `ROWMAJOR`、`CUBE_M16` 与 `CUBE_M32`；`IndexedTLSULayoutSupported` 拒绝 `CUBE_N8`。每个 `B.DIM` 值必须落在 `1..65535` 内，有效行数乘以有效列数不得超过 `PTO_MODEL_TILE_ELEMENTS`，且 `ROWMAJOR` 要求有效列数不超过物理列数，物理列数必须是非零的 2 的幂。

解码不出任何操作的选择器编码会引发 `Fault_IllegalInstruction`。Tile 绑定数量错误、出现 Shared 绑定、缺少 `B.IOR`，或维度、布局、索引类型、传输类型不合法，都会引发 `Fault_TileLegality`。`PE_MASK=0000` 在派发器顶部即结束，位于以上所有检查之前。

<!-- PTO-READER-BLOCK: tile-mgather-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取一个 1 乘 4 的 `U32` 索引 Tile，其值为 `8, 0, 8, 4`；基址 `0x1000` 放在 `a0`；GM 在 `0x1000`、`0x1004`、`0x1008` 与 `0x100c` 处分别存放 `U32` 值 `1, 2, 3, 4`。每个索引都是字节位移，因此通道 `0` 与通道 `2` 都从 `0x1008` 读取，通道 `1` 从 `0x1000` 读取，通道 `3` 从 `0x1004` 读取。目标的有效区域得到 `3, 1, 3, 2`。

用宏形式写作 `MGATHER <Col=4, U32>, [base=a0], T#1, ->T<128B>`，其中 `T#1` 是索引 Tile。128 字节的目标容纳 32 个 `U32` 物理元素：其中 4 个有效元素得到读到的值，另外 28 个从默认填充值得到零位。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MGATHER <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MGATHER | TLSU |  | 4 |  | MGATHER |

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
| destination0 | destination |
| address | base-address |
| source0 | logical element indices |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MGATHER.asl -->
```asl
readonly func InstructionContractOperation_MGATHER() => TileOperation
begin
    return TileOperation_MGATHER;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MGATHER.asl -->
```asl
readonly func InstructionContractHandler_MGATHER() => TileSemanticHandler
begin
    return TileHandler_MGATHER;
end;

pure func InstructionContractUsesLogicalElementIndices_MGATHER()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MGATHER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MGATHER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractWritesMemory_MGATHER()
    => boolean
begin
    return FALSE;
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

- The complete physical destination region is initialized to PadValue before active valid results are published.
- On success the full physical destination region is defined; a failing attempt publishes no destination.

## Memory effects and ordering

### Memory effects

- Each indexed transaction loads one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the logical element index scaled by the transfer element width.
- All valid addresses are preflighted before the first architectural effect.

### Ordering

- Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.

## Exceptions

- Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects.

## Examples

- BSTART.MGATHER DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
