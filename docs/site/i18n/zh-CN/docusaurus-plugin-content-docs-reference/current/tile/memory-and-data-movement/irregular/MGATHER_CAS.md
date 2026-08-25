<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl -->
# MGATHER_CAS

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl`

Atomically compare and conditionally replace GM elements at signed or unsigned byte displacements.

## Normative identity {#PTO-INST-TILE-MGATHER-CAS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mgather-cas-purpose role=purpose -->
## MGATHER_CAS 的作用

`MGATHER_CAS` 是一条由 `TLSU` 执行、通过选择器编码的 Tile 操作。它使用索引、期望值和替换值 Tile 执行逐元素 GM 比较交换，并记录每次观察到的旧值；当前指令契约拥有精确的指令束形式和发布边界。

<!-- PTO-READER-BLOCK: tile-mgather-cas-mechanism role=mechanism -->
## 元素与 Tile 机制

所有描述符与操作数检查成功后，所属 ASL 处理函数使用索引、期望值和替换值 Tile 执行逐元素 GM 比较交换，并记录每次观察到的旧值。当前契约允许别名时，源载荷会在目标写入前完成快照。

处理函数使用解析后的有效区域，不把物理填充区当作输入数据。操作专属的数据类型、布局、舍入、饱和与配置档钩子仍由可执行定义拥有。

<!-- PTO-READER-BLOCK: tile-mgather-cas-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `destination0` 的精确契约角色是“观察旧值的目标”。
- `address` 的精确契约角色是“基址”。
- `source0` 的精确契约角色是“字节位移索引”。
- `source1` 的精确契约角色是“期望值”。
- `source2` 的精确契约角色是“替换值”。

操作读取的每个源坐标都必须在目标发布前处于已定义状态。
`PE_MASK=0000` 是严格无操作，在描述符、分配、载荷、数值状态或内存效果之前即结束。

<!-- PTO-READER-BLOCK: tile-mgather-cas-effects role=effects -->
## 发布、已定义性与填充

完整原子地址预检后，所选 PadValue 载体先初始化每个物理目标坐标；随后观察到的旧值覆盖有效坐标。

成功时，完整物理目标被标记为已定义，并设置 `contents_defined=TRUE`；载荷、已定义性与描述符同时发布。

操作在首次读取、原子事件或目标更新前预检每个启用的 GM 地址；访问失败不会留下部分目标或事件。

<!-- PTO-READER-BLOCK: tile-mgather-cas-constraints role=constraints -->
## 类型、布局与故障边界

索引 Tile 使用 `S32`、`U32`、`S64` 或 `U64`。紧凑四位传输类型 `E2M1X2`、`E1M2X2`、`HiF4X2`、`S4X2` 与 `U4X2` 会被拒绝，因为该索引传输没有半字节选择器。

下方生成的合法性与异常章节是数据类型组合、布局、维度、容量、已定义性、填充控制、配置档行为和故障类别的权威说明。合法性或分配失败发生在任何部分架构效果之前。

<!-- PTO-READER-BLOCK: tile-mgather-cas-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `MGATHER_CAS` 示例说明：索引处旧值为 `5`、期望值为 `5`、替换值为 `9` 时，发布观察值 `5` 并把 GM 更新为 `9`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MGATHER_CAS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MGATHER_CAS | TLSU |  | 8 |  | MGATHER_CAS |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | observed-old-values destination |
| address | base-address |
| source0 | byte-displacement indices |
| source1 | expected values |
| source2 | replacement values |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl -->
```asl
readonly func InstructionContractOperation_MGATHER_CAS() => TileOperation
begin
    return TileOperation_MGATHER_CAS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.CAS DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT IndexTile, ExpectedTile, mask=PE_MASK
B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl -->
```asl
readonly func InstructionContractHandler_MGATHER_CAS() => TileSemanticHandler
begin
    return TileHandler_MGATHER_CAS;
end;

pure func InstructionContractUsesByteDisplacements_MGATHER_CAS()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MGATHER_CAS()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MGATHER_CAS()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractWritesMemory_MGATHER_CAS()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required. RegSrc0 names the PE-private absolute GPR containing the byte-address base; zero selects architectural base address zero. Unused B.IOR fields must encode zero.
- LB0 is required and supplies ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol. Explicit zero is illegal for every present dimension.
- Omitted B.DATR selects PadValue=Null and Layout=NORM. The pad value defines every physical destination element outside ValidRow x ValidCol.
- Each IndexTile logical element is a signed or unsigned byte displacement. Comparison and replacement values use the selected transfer DataType.

## Legality

- MGATHER_CAS is selected only by BSTART.MGATHER.CAS function 8 in the TLSU selector space; it has no standalone opcode.
- Exactly two Local B.IOT bindings are required. The first supplies IndexTile and ExpectedTile without a destination and has L=0. The second supplies ReplacementTile and a newly allocated destination and has L=1. Both carry one common PE_MASK; B.IOS is not accepted.
- IndexTile must be allocated, fully defined, generically indexable, and use S32, U32, S64, or U64. Each logical element is sign- or zero-extended as a byte displacement.
- ExpectedTile and ReplacementTile must be allocated, fully defined, use the selected transfer DataType, and match the resolved ValidRow x ValidCol. Comparison uses their encoded element values.
- Packed four-bit transfer DataTypes E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 are rejected because the block carries no nibble selector.
- Destination physical Rows are derived from TSize, physical Col, and transfer DataType. Rows and Col are powers of two and the physical region contains ValidRow x ValidCol.
- B.IOT PE_MASK=0000 is a strict no-op before schema, GPR, source, dimension, allocation, address, or fault checks.
- B.DATR applicability allows only PadValueOrByteId as PadValue and Layout.

## State effects

- Allocate a new Local destination descriptor using B.IOT TSize, resolved dimensions, selected transfer DataType, selected Layout, and PE_MASK.
- Initialize every physical destination coordinate from the selected PadValue carrier before enabled valid-lane writes.
- On success overwrite enabled valid coordinates with loaded or observed values, mark the full physical destination defined, set contents_defined=TRUE, and publish atomically.

## Memory effects and ordering

### Memory effects

- For each valid coordinate, atomically read the selected transfer-typed element at BaseGPR plus the corresponding signed or unsigned byte displacement, compare it with ExpectedTile, conditionally store ReplacementTile, and place the observed old value in the destination.
- All lane addresses are preflighted before the first atomic event. Duplicate addresses are legal and their per-lane atomic operations serialize in an implementation-defined order; no row-major or other fixed order is architectural.
- After every selected lane completes, publish the observed valid region and pad every remaining physical destination coordinate atomically.

### Ordering

- Each lane is one atomic read-modify-write governed by the block memory-order attributes.
- Duplicate-address lanes serialize in an implementation-defined order. No additional inter-PE order is guaranteed.

## Exceptions

- A missing B.IOR, missing LB0, malformed two-command B.IOT sequence, non-integer IndexTile, shape or type mismatch, packed four-bit transfer DataType, or invalid dimensions raises Fault_TileLegality before destination allocation, atomic events, or memory writes.
- Every valid-region read and write address is probed before the first compare-and-swap. Any access fault leaves the destination unallocated and produces no partial atomic event, memory write, or payload effect.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.MGATHER.CAS DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, ExpectedTile, mask=PE_MASK; B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
