<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MGATHER_MASK.asl -->
# MGATHER_MASK

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MGATHER_MASK.asl`

Gather GM data through explicit Row or Elem relative-index mode.

## Normative identity {#PTO-INST-TILE-MGATHER-MASK}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mgather-mask-purpose role=purpose -->
## MGATHER_MASK 的作用

`MGATHER_MASK` 是一条由 `TLSU` 执行、通过选择器编码的 Tile 操作。它只汇聚谓词恰好为一的通道，并用所选填充值填充禁用通道；当前指令契约拥有精确的指令束形式和发布边界。

<!-- PTO-READER-BLOCK: tile-mgather-mask-mechanism role=mechanism -->
## 元素与 Tile 机制

所有描述符与操作数检查成功后，所属 ASL 处理函数只汇聚谓词恰好为一的通道，并用所选填充值填充禁用通道。当前契约允许别名时，源载荷会在目标写入前完成快照。

处理函数使用解析后的有效区域，不把物理填充区当作输入数据。操作专属的数据类型、布局、舍入、饱和与配置档钩子仍由可执行定义拥有。

<!-- PTO-READER-BLOCK: tile-mgather-mask-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `destination0` 的精确契约角色是“目标”。
- `address` 的精确契约角色是“基址”。
- `source0` 的精确契约角色是“字节位移索引”。
- `source1` 的精确契约角色是“取值严格为零或一的谓词掩码”。

操作读取的每个源坐标都必须在目标发布前处于已定义状态。
`PE_MASK=0000` 是严格无操作，在描述符、分配、载荷、数值状态或内存效果之前即结束。

<!-- PTO-READER-BLOCK: tile-mgather-mask-effects role=effects -->
## 发布、已定义性与填充

启用通道完成预检后，所选 PadValue 载体先初始化每个物理目标坐标；随后启用通道的读取值覆盖相应有效坐标。

成功时，完整物理目标被标记为已定义，并设置 `contents_defined=TRUE`；载荷、已定义性与描述符同时发布。

操作在首次读取、原子事件或目标更新前预检每个启用的 GM 地址；访问失败不会留下部分目标或事件。

<!-- PTO-READER-BLOCK: tile-mgather-mask-constraints role=constraints -->
## 类型、布局与故障边界

索引 Tile 使用 `S32`、`U32`、`S64` 或 `U64`。紧凑四位传输类型 `E2M1X2`、`E1M2X2`、`HiF4X2`、`S4X2` 与 `U4X2` 会被拒绝，因为该索引传输没有半字节选择器。

下方生成的合法性与异常章节是数据类型组合、布局、维度、容量、已定义性、填充控制、配置档行为和故障类别的权威说明。合法性或分配失败发生在任何部分架构效果之前。

<!-- PTO-READER-BLOCK: tile-mgather-mask-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `MGATHER_MASK` 示例说明：掩码通道为 `0` 时不读取 GM 而接收填充值；通道为 `1` 时汇聚索引元素。
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

### B.DATR.CMode (`PTO-FIELD-BLOCK-CMODE`)

Selects the operation-defined comparison or indexed-memory mode.

**Encoded zero:** Equality for comparisons; Row mode for indexed TLSU.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | EQ-or-Row |
| 1 | assigned | NE-or-Elem |
| 2 | assigned | LT |
| 3 | assigned | GT |
| 4 | assigned | LE |
| 5 | assigned | GE |
| 6 | reserved | future extension |
| 7 | reserved | future extension |

**Reserved-value behavior:** Codes 6 and 7 are reserved and reject before architectural effects.

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

### B.IOR.RegSrc1 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

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
| scalar0 | per-PE private-GPR GM row stride in elements |
| source0 | relative row indices |
| source1 | exact zero-or-one predicate mask |

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
B.IOR BaseGPR, StrideGPR, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MGATHER_MASK.asl -->
```asl
readonly func InstructionContractHandler_MGATHER_MASK() => TileSemanticHandler
begin
    return TileHandler_MGATHER_MASK;
end;

pure func InstructionContractSupportsRowAndElemIndices_MGATHER_MASK()
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

- B.IOR is required. RegSrc0 names the PE-private absolute GPR containing the GM base address, RegSrc1 names the nonzero GM row stride in elements, and RegSrc2 plus RegDst must encode zero.
- LB0 is required and supplies ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol. Explicit zero is illegal for every present dimension.
- Omitted B.DATR selects PadValue=Null and Layout=NORM. PadValue is written to disabled valid lanes and every physical destination element outside ValidRow x ValidCol.
- B.DATR CMode=0 selects Row mode and CMode=1 selects Elem mode; codes 2..5 are inapplicable. Row mode uses a canonical row-major 1 x ValidRow S32/U32 IndexTile and consumes RegSrc1 as a GM row stride in elements. Elem mode uses a row-major S32/U32 IndexTile matching the data valid shape, requires RegSrc1 to encode zero, and treats each index as a relative element displacement from BaseGPR.

## Legality

- MGATHER_MASK is selected only by BSTART.MGATHER.MASK function 6 in the TLSU selector space; it has no standalone opcode.
- Exactly one terminating Local B.IOT supplies IndexTile, MaskTile, destination, TSize, and PE_MASK. B.IOS and additional Tile bindings are not accepted.
- Packed four-bit transfer DataTypes E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 are rejected because the block carries no nibble selector.
- Destination physical Rows are derived from TSize, physical Col, and transfer DataType. Rows and Col are powers of two and the physical region contains ValidRow x ValidCol.
- B.IOT PE_MASK=0000 is a strict no-op before schema, GPR, source, predicate, dimension, allocation, address, or fault checks.
- B.DATR applicability allows only PadValueOrByteId as PadValue and Layout.
- MaskTile must match the destination valid shape and layout and contain only exact zero-or-one predicates.
- For indexed TLSU, B.DATR CMode accepts only Row=0 and Elem=1; CMode 2..5 raises Fault_TileLegality before address generation or effects.
- Row mode requires a canonical row-major 1 x ValidRow S32/U32 IndexTile and a RegSrc1 row-stride value no smaller than ValidCol.
- Elem mode requires a row-major S32/U32 IndexTile matching the data valid shape and requires B.IOR RegSrc1, RegSrc2, and RegDst to encode zero.

## State effects

- Allocate a new Local destination descriptor using B.IOT TSize, resolved dimensions, selected transfer DataType, selected Layout, and PE_MASK.
- Initialize every physical destination coordinate from the selected PadValue carrier before enabled valid-lane writes.
- On success overwrite enabled valid coordinates with loaded or observed values, mark the full physical destination defined, set contents_defined=TRUE, and publish atomically.

## Memory effects and ordering

### Memory effects

- Row mode accesses data coordinate (r,c) at BaseGPR + (IndexTile[0,r] * row_stride_elements + c) * sizeof(DataType).
- Elem mode accesses data coordinate (r,c) at BaseGPR + IndexTile[r,c] * sizeof(DataType).
- A valid coordinate whose mask is zero performs no address generation, translation, permission check, memory access, or memory event and receives PadValue.
- After complete enabled-lane preflight, publish enabled loads, disabled-lane padding, and all non-valid physical padding atomically.

### Ordering

- Enabled-lane loads participate in the PTO memory-order domain through the block aq/rl attributes.
- No additional lane or inter-PE issue order is guaranteed.
- Base, stride, dimensions, and all enabled indices are snapshotted before complete address preflight.

## Exceptions

- A missing B.IOR, missing LB0, malformed B.IOT, non-integer IndexTile, mask value other than zero or one, shape or layout mismatch, packed four-bit transfer DataType, or invalid dimensions, zero row stride, or row stride smaller than ValidCol raises Fault_TileLegality before destination allocation, memory events, or memory reads.
- Only enabled-lane addresses are generated and probed. Every enabled lane is preflighted before the first load; any enabled-lane fault leaves the destination unallocated and produces no partial event or payload effect. Disabled lanes cannot fault from their ignored IndexTile value.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.MGATHER.MASK DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, StrideGPR, zero, ->zero; BSTOP
