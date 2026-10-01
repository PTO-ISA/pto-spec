<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MSCATTER_MASK.asl -->
# MSCATTER_MASK

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MSCATTER_MASK.asl`

Masked scatter using explicit byte displacements.

## Normative identity {#PTO-INST-TILE-MSCATTER-MASK}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mscatter-mask-purpose role=purpose -->
## MSCATTER_MASK 的作用

`MSCATTER_MASK` 是 TLSU Function 7，写作 `BSTART.MSCATTER.MASK DataType`。它的寻址沿用 `MSCATTER` 的字节位移规则：`B.IOR.RegSrc0` 指定的每 PE 基地址加上索引值，存储的值是源元素的原始位。区别在于一个 Local `U8` 谓词 Tile 决定哪些索引事务执行存储。NDF `PTO-MSCATTER-MASK-PREDICATE-001` 规定每个事务只能取 `0x00` 与 `0x01`，并规定零值会抑制地址生成、转换、权限检查、存储与事件。

拥有者声明 `InstructionContractUsesMaskTile_MSCATTER_MASK` 为 TRUE、`InstructionContractWritesMemory_MSCATTER_MASK` 为 TRUE。分派器 `ExecuteBundleMSCATTERMASKOperation` 解码 Function 7，检查两条 `B.IOT` 绑定与描述符，然后调用 `TileOperandsLegal_MSCATTER_MASK` 与执行体 `MSCATTER_MASK`。

设计要点：通道判定为 `BundleExecutionMaskActiveAt(...) && ReadIndexedTLSUPredicate(mask, ...)`，地址计算与探测都在该判定之内。因此谓词元素为零的通道不会被转换，也不会发生故障，所以超出范围或未对齐的位移在其谓词元素为零时是无害的。

<!-- PTO-READER-BLOCK: tile-mscatter-mask-mechanism role=mechanism -->
## 两种掩码：ExecutionMask 与谓词 Tile

有两种不同的掩码可以门控一个通道，它们不可互换。

ExecutionMask 是指令束级状态。它既可以由 GPR 对承载（`BundleExecutionMaskGPRCarrierShapeLegal` 只对 `CUBE_M16` 与 `CUBE_M32` 坐标布局接受这种承载），也可以由存储类型为 `TileStorage_PredicateCell` 的谓词 Tile 承载。它在这里的坐标来源是索引 Tile，因此其布局与有效形状跟随该 Tile。`CaptureBundleExecutionMaskPredicateTile` 把每个元素的第 0 位复制到快照中，此后只查阅该快照。

`MaskTile` 操作数只属于本指令。它是一个 Local `U8` Tile，每个索引事务对应一个元素，其有效行数与有效列数必须等于索引 Tile 的对应值，其布局必须等于指令束布局。`IndexedTLSUPredicateValuesLegal` 扫描 ExecutionMask 留为活动的每个元素，只要有一个未定义或不等于 `0x00` 或 `0x01`，就拒绝整个指令束。

设计要点：该谓词扫描属于合法性检查，因此在任何地址存在之前运行。只要有一个元素取 `0x02`，整个指令束就会以 `Fault_TileLegality` 被拒绝，任何通道都不存储，而不仅仅是违规通道。

设计要点：对打包四位传输，索引 Tile 的列数是数据 Tile 的一半，因此一个谓词元素覆盖一个字节的两个半字节，它们一起启用或一起被抑制（NDF `PTO-MSCATTER-MASK-TYPE-002`）。

<!-- PTO-READER-BLOCK: tile-mscatter-mask-inputs role=inputs-outputs -->
## 操作数角色与绑定

- `address` 是基地址，从执行 PE 自己的寄存器文件中由 `B.IOR.RegSrc0` 指定的 GPR 读取；`RegSrc1`、`RegSrc2` 与 `RegDst` 必须编码为零。
- `source0` 是数据 Tile：指令束 `DataType`、`LB1` 有效行数、`LB0` 有效列数、`LB2` 物理列数，以及指令束布局。
- `source1` 是索引 Tile：元素为 `S32`、`U32`、`S64` 或 `U64`，采用指令束布局，有效形状与数据 Tile 匹配。
- `source2` 是掩码 Tile：一个 Local `U8` Tile，其有效形状等于索引 Tile 的有效形状，其布局等于指令束布局。

本形式始终绑定恰好两条 `B.IOT` 命令。第一条携带数据 Tile 与索引 Tile，没有目标，也不是 `last`。第二条携带掩码 Tile 作为其源且为 `last`；当谓词 Tile ExecutionMask 生效时，同一条第二条 `B.IOT` 还把该掩码的谓词 Tile 作为其第二个源。所有绑定必须携带相同的 `PE_MASK`。

每个绑定上的 `PE_MASK=0000` 在分派器开头即严格无操作，早于解码、schema、GPR、维度、描述符与内存检查。

<!-- PTO-READER-BLOCK: tile-mscatter-mask-effects role=effects -->
## 内存效果、已定义性与填充

每个启用的索引事务在 `base + displacement` 处存储一个传输元素；对四位传输则存储一个打包字节，低半字节在前、高半字节在后。被禁用的事务不生成地址、不做转换、不做权限检查、不做探测、不访问、不产生事件，因此它也不可能引发数据访问故障。

与未掩码形式一样，没有 ExecutionMask 时两个源 Tile 必须在整个有效区域上处于已定义状态；有该掩码时只在掩码的活动坐标处要求已定义。掩码 Tile 只被读取，从不被修改，并且不分配目标 Tile。

此处 `B.DATR` 只能设置 `Layout`：显式的非零 `PadValue` 字段会被拒绝，因为该形式的 pad union 是 `must-zero`。合并模式的 ExecutionMask 也没有可填充的目标，`PrepareSelectedBundleExecutionMaskMerge` 在本指令束中找不到目标绑定。

<!-- PTO-READER-BLOCK: tile-mscatter-mask-constraints role=constraints -->
## 类型、布局与故障边界

指令束 `DataType` 必须等于数据 Tile 的类型，索引 Tile 为 `S32`、`U32`、`S64` 或 `U64`。NDF `PTO-MSCATTER-MASK-TYPE-002` 要求打包四位传输数据每个索引字节使用相邻的两个逻辑半字节，且每对共用一个谓词；NDF `PTO-MSCATTER-MASK-DUPLICATE-001` 让重复的已启用地址具有实现定义的胜者，且不施加内部启用通道顺序。

布局为 `RowMajor`、`CUBE_M16` 与 `CUBE_M32`，`CUBE_N8` 会被拒绝，`RowMajor` 要求 `ValidCol <= Col` 且 `Col` 为非零的 2 的幂。数据、索引与掩码 Tile 都必须采用指令束布局。

`Fault_IllegalInstruction` 覆盖未知的 TLSU 编码。`Fault_TileLegality` 覆盖缺少 `B.IOR`、`B.IOT` 绑定形状错误、维度超范围、布局、类型或形状不匹配、谓词元素缺失或未定义，以及谓词值不是 `0x00` 或 `0x01`。探测失败引发 `Fault_DataAlignment` 或 `Fault_DataPage`，且发生在首次存储之前。

<!-- PTO-READER-BLOCK: tile-mscatter-mask-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `U32`、`ValidRow=1`、`ValidCol=2`、`Col=4`，`a0` 中的基地址为 `0x1000`，数据 Tile 保存 `7, 9`，索引 Tile 保存 `4, 0`，掩码 Tile 保存 `0, 1`。

- 坐标 (0, 0) 被禁用，因此位移 `4` 不生成地址，`0x1004` 保持其原有内容。
- 坐标 (0, 1) 被启用，因此位移 `0` 把 `9` 存到 `0x1000`。
- 若掩码 Tile 改为保存 `2, 1`，`IndexedTLSUPredicateValuesLegal` 会失败，因此两次存储都不会发生。

宏写法为 `MSCATTER_MASK <Col=4, ValidCol=2, U32>, [base=a0], T#1, T#2, PredicateTile2`，其中 `T#1` 是数据 Tile，`T#2` 是索引 Tile，`PredicateTile2` 是掩码 Tile。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MSCATTER_MASK <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MSCATTER_MASK | TLSU |  | 7 |  | MSCATTER_MASK |

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
| source1 | byte-displacement indices |
| source2 | U8 PredicateTile |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MSCATTER_MASK.asl -->
```asl
readonly func InstructionContractOperation_MSCATTER_MASK() => TileOperation
begin
    return TileOperation_MSCATTER_MASK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.MASK DataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT DataTile, IndexTile, mask=PE_MASK
B.IOT MaskTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MSCATTER_MASK.asl -->
```asl
readonly func InstructionContractHandler_MSCATTER_MASK() => TileSemanticHandler
begin
    return TileHandler_MSCATTER_MASK;
end;

pure func InstructionContractUsesByteDisplacements_MSCATTER_MASK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MSCATTER_MASK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MSCATTER_MASK()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractWritesMemory_MSCATTER_MASK()
    => boolean
begin
    return TRUE;
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

- All three source descriptors and payloads persist unchanged after success or rejection.
- On success only enabled-lane memory and event state changes; MSCATTER_MASK allocates no destination Tile.

## Memory effects and ordering

### Memory effects

- Each enabled indexed transaction stores one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the byte displacement.
- A false predicate performs no address generation, translation, permission check, memory probe, event, access, or data-access fault.

### Ordering

- Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.

## Exceptions

- Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects.

## Examples

- BSTART.MSCATTER.MASK DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK; B.IOT MaskTile, mask=PE_MASK, <last>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
