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

`MSCATTER_MASK` 是一条由 `TLSU` 执行、通过选择器编码的 Tile 操作。它只把谓词恰好为一的通道存储到索引指定的 GM 字节位移；当前指令契约拥有精确的指令束形式和发布边界。

<!-- PTO-READER-BLOCK: tile-mscatter-mask-mechanism role=mechanism -->
## 元素与 Tile 机制

所有描述符与操作数检查成功后，所属 ASL 处理函数只把谓词恰好为一的通道存储到索引指定的 GM 字节位移。当前契约允许别名时，源载荷会在目标写入前完成快照。

处理函数使用解析后的有效区域，不把物理填充区当作输入数据。操作专属的数据类型、布局、舍入、饱和与配置档钩子仍由可执行定义拥有。

<!-- PTO-READER-BLOCK: tile-mscatter-mask-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `address` 的精确契约角色是“基址”。
- `source0` 的精确契约角色是“源数据”。
- `source1` 的精确契约角色是“字节位移索引”。
- `source2` 的精确契约角色是“取值严格为零或一的谓词掩码”。

操作读取的每个源坐标都必须在目标发布前处于已定义状态。
`PE_MASK=0000` 是严格无操作，在描述符、分配、载荷、数值状态或内存效果之前即结束。

<!-- PTO-READER-BLOCK: tile-mscatter-mask-effects role=effects -->
## 发布、已定义性与填充

只有源、谓词、地址与权限完成完整预检后，GM 写入和内存事件才开始；该操作没有 Tile 目标。

本页不暗示当前处理函数契约之外的填充行为。

操作在首次存储或内存事件前预检每个启用的 GM 地址，并且不分配目标 Tile。

<!-- PTO-READER-BLOCK: tile-mscatter-mask-constraints role=constraints -->
## 类型、布局与故障边界

索引 Tile 使用 `S32`、`U32`、`S64` 或 `U64`。紧凑四位传输类型 `E2M1X2`、`E1M2X2`、`HiF4X2`、`S4X2` 与 `U4X2` 会被拒绝，因为该索引传输没有半字节选择器。

下方生成的合法性与异常章节是数据类型组合、布局、维度、容量、已定义性、填充控制、配置档行为和故障类别的权威说明。合法性或分配失败发生在任何部分架构效果之前。

<!-- PTO-READER-BLOCK: tile-mscatter-mask-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `MSCATTER_MASK` 示例说明：源值 `7` 在掩码为 `1` 时被存储，而掩码为 `0` 时不生成地址。
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
