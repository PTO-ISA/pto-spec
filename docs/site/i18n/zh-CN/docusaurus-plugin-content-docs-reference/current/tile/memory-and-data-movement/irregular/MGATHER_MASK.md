<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MGATHER_MASK.asl -->
# MGATHER_MASK

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MGATHER_MASK.asl`

Masked gather using explicit byte displacements.

## Normative identity {#PTO-INST-TILE-MGATHER-MASK}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mgather-mask-purpose role=purpose -->
## MGATHER_MASK 的作用

`MGATHER_MASK` 是一条带掩码的汇聚指令。它按启用通道从全局内存 (GM) 读取数据，并把结果写入新分配的 Local 目标 Tile；谓词为 `0` 的通道完全不会被读取。它是由 `TLSU` 执行、通过选择器编码的 Tile 操作，由 TLSU Function 6 选中，写作 `BSTART.MGATHER.MASK DataType`。块派发器 `ExecuteBundleMGATHERMASKOperation` 检查指令束，然后调用共享 Tile 模型 `MGATHER_MASK`。

一个通道就是索引 Tile 有效区域中的一个坐标，它的谓词是第二个源在同一坐标处的 `U8` 元素。`MGATHER_MASK` 没有独立操作码。

设计要点：逐通道谓词是数据，而不是编码。它存放在一个普通 Local `U8` Tile 中，其值在操作执行期间被读取，因此同一份指令编码在每次执行时可以汇聚不同的通道子集。

<!-- PTO-READER-BLOCK: tile-mgather-mask-mechanism role=mechanism -->
## 谓词机制与两阶段执行

模型断言索引元素已定义、谓词取值通过 `IndexedTLSUPredicateValuesLegal` 合法，并且掩码 Tile 的有效行数与有效列数等于索引 Tile 的相应值。随后它对索引 Tile 做两轮遍历。

预检轮访问有效区域的每个坐标。当该坐标在 ExecutionMask 中处于启用状态、且 `ReadIndexedTLSUPredicate` 对它报告 `1` 时，该轮用 `TileMemoryByteDisplacementAddress` 构造地址，用 `ProbeTileMemoryAccess` 探测，探测失败时通过 `RaiseDataAccessFault` 抛出该探测的故障，并记录翻译后的地址与一个启用通道。

发布轮先填充每个物理目标元素，然后只为每个启用通道读取并记录一个读取事件。

设计要点：每个启用地址都在首次读取之前完成翻译与检查，因此 `MGATHER_MASK` 中来自地址的故障在任何数据移动之前就已知晓。发生故障的请求没有执行过任何读取，这正是带掩码的汇聚可以整体重启的原因。

<!-- PTO-READER-BLOCK: tile-mgather-mask-inputs role=inputs-outputs -->
## 操作数角色与两个谓词来源

- `destination0` 是新的 Local Tile，使用指令束 `DataType` 和 `B.DIM` 形状。它接收已启用通道读到的元素。
- `address` 是基址，从当前内存代理寄存器文件中由 `B.IOR.RegSrc0` 指定的 GPR 读出。
- `source0` 是索引 Tile：`S32`、`U32`、`S64` 或 `U64` 字节位移。
- `source1` 是谓词 Tile：普通的 Local `U8` 载体，每个索引事务对应一个元素。

`B.IOR` 是必需的，且 `RegSrc1`、`RegSrc2` 与 `RegDst` 必须编码为零。`ExecuteBundleMGATHERMASKOperation` 在没有 ExecutionMask 时要求恰好一个 Tile 绑定，此时该形式以一条 `B.IOT` 终结，其中携带索引 Tile、谓词 Tile 与目标。带谓词 Tile 载体的 ExecutionMask 则要求两个绑定：第一个携带两个源、没有目标也不是 `last`，第二个只携带谓词 Tile 作为其唯一源，并携带目标与 `last`；与 `TGATHER`、`MSCATTER` 系列由源序号 `1` 提供掩码域不同，`BundleExecutionMaskCoordinateSourceOrdinal` 对 `MGATHER_MASK` 取序号 `0`，因此由索引 Tile 提供掩码的坐标域。

<!-- PTO-READER-BLOCK: tile-mgather-mask-effects role=effects -->
## 发布、已定义性与填充

每个物理目标元素都在首次读取之前完成初始化。有效区域之外的元素通过 `TilePadValueForDataType` 接收指令束 `PadValue`，该函数把默认的 `TilePad_Null` 映射为零位。存在 ExecutionMask 时，有效区域内未被掩码启用的坐标改为接收 `IndexedGatherInactiveDestinationValue`。谓词为 `0` 的通道保留其初始化时的填充值，因此禁用通道与非有效元素最终内容相同。

设计要点：谓词 `0` 抑制的是该通道的整条内存路径，而不只是存储。对它根本不会调用 `ProbeTileMemoryAccess`，因此不会产生翻译后地址、权限或对齐检查、事件，也不会产生数据访问故障。程序因而可以用谓词 Tile 把尚未建立映射的地址排除在事务集合之外。

区域由 `MarkTilePhysicalRegionDefined` 标记为已定义，该函数同时设置 `contents_defined`。若某个启用通道的探测发生故障，模型在首次读取之前返回，派发器调用 `RollBackBundleTileDestinations`，因此不会发布任何目标。

<!-- PTO-READER-BLOCK: tile-mgather-mask-constraints role=constraints -->
## 类型、形状与故障边界

谓词 Tile 必须是 Local `U8` 载体，其元素各自为 `0x00` 或 `0x01`。`IndexedTLSUPredicateValuesLegal` 要求 `U8` 描述符处于受支持的布局，要求该 Tile 在检查适用处已定义，并对任何其他元素取值在效果之前拒绝整个请求。它的有效行数与有效列数必须等于索引 Tile 的相应值。

索引 Tile 必须是 `S32`、`U32`、`S64` 或 `U64`。传输 `DataType` 必须通过 `IndexedTLSUOrdinaryTransferDataTypeLegal`，该判定接受所有被 `TileDataTypeIsFourBit` 拒绝的类型，并加上五种四位类型 `E2M1X2`、`E1M2X2`、`HiF4X2`、`S4X2` 与 `U4X2`。对于紧凑传输，有效列数必须为偶数且等于索引有效列数的两倍，此时一个谓词值控制完整的字节对。

布局为 `ROWMAJOR`、`CUBE_M16` 与 `CUBE_M32`；`IndexedTLSULayoutSupported` 拒绝 `CUBE_N8`。解码不出任何操作的选择器编码会引发 `Fault_IllegalInstruction`，绑定、类型、形状或布局违规会引发 `Fault_TileLegality`。`PE_MASK=0000` 在派发器顶部即结束，位于以上所有检查之前。

<!-- PTO-READER-BLOCK: tile-mgather-mask-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取一个 1 乘 4 的 `U32` 索引 Tile，其值为 `8, 0, 8, 4`；一个 1 乘 4 的谓词 Tile，其值为 `1, 0, 1, 0`；基址 `0x1000` 放在 `a0`；GM 在 `0x1000`、`0x1004`、`0x1008` 与 `0x100c` 处分别存放 `U32` 值 `1, 2, 3, 4`。

- 通道 `0` 的谓词为 `1`，因此读取 `0x1008`，目标元素变为 `3`。
- 通道 `1` 的谓词为 `0`，因此从不读取 `0x1000`，目标元素保留填充值，默认情况下为零位。
- 通道 `2` 的谓词为 `1`，因此同样读取 `0x1008`，目标元素变为 `3`。
- 通道 `3` 的谓词为 `0`，因此从不读取 `0x1004`，目标元素保留填充值。

用宏形式写作 `MGATHER_MASK <Col=4, U32>, [base=a0], T#1, T#2, ->T<128B>`，其中 `T#1` 是索引 Tile，`T#2` 是在谓词 Tile 源角色中绑定的谓词 Tile。目标的有效区域得到 `3, 0, 3, 0`：两个启用通道携带读到的值，两个禁用通道携带填充值；由于省略了 `B.DATR`，该填充值为零位。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MGATHER_MASK <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MGATHER_MASK | TLSU |  | 6 |  | MGATHER_MASK |

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
| source0 | byte-displacement indices |
| source1 | U8 PredicateTile |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MGATHER_MASK.asl -->
```asl
readonly func InstructionContractOperation_MGATHER_MASK() => TileOperation
begin
    return TileOperation_MGATHER_MASK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.MASK DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MGATHER_MASK.asl -->
```asl
readonly func InstructionContractHandler_MGATHER_MASK() => TileSemanticHandler
begin
    return TileHandler_MGATHER_MASK;
end;

pure func InstructionContractUsesByteDisplacements_MGATHER_MASK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MGATHER_MASK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MGATHER_MASK()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractWritesMemory_MGATHER_MASK()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.
- LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.
- IndexTile entries are S32, U32, S64, or U64 byte displacements and are not scaled or decomposed.

## Legality

- PredicateTile is an ordinary Local U8 predicate carrier with one 0x00 or 0x01 element per indexed transaction; every other value rejects before effects.
- PredicateTile valid shape equals IndexTile valid shape and its producer DataType does not constrain the transfer DataType.
- Packed four-bit uses Data.ValidCol == 2 * Index.ValidCol and one predicate controls the complete byte pair.
- ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.
- Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.
- B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.

## State effects

- The complete physical destination region is initialized to PadValue before active valid results are published.
- On success the full physical destination region is defined; a failing attempt publishes no destination.

## Memory effects and ordering

### Memory effects

- Each enabled indexed transaction loads one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the byte displacement.
- A false predicate performs no address generation, translation, permission check, memory probe, event, access, or data-access fault and leaves the corresponding destination value(s) at PadValue.

### Ordering

- Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.

## Exceptions

- Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects.

## Examples

- BSTART.MGATHER.MASK DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
