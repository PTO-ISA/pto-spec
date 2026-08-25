<!-- GENERATED FROM: asl/tile/irregular-and-complex/union/TPARTMUL.asl -->
# TPARTMUL

**Normative ASL source:** `asl/tile/irregular-and-complex/union/TPARTMUL.asl`

Form the origin-anchored union of two Local Tiles and multiply overlap elements.

## Normative identity {#PTO-INST-TILE-TPARTMUL}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tpartmul-purpose role=purpose -->
## 用途

`TPARTMUL` 形成两个原点锚定 Local Tile 的并集，并在重叠区域相乘。

<!-- PTO-READER-BLOCK: tile-tpartmul-mechanism role=mechanism -->
## 执行机制

ASL DOC 契约通过该指令的选择器编码块载体选择 `TileHandler_ExecuteTilePartial`。

覆盖范围、类型、布局、已定义性、编码、掩码和分配预检完成后，快照两个原点锚定的 Local 源矩形。

<!-- PTO-READER-BLOCK: tile-tpartmul-inputs-outputs role=inputs-outputs -->
## 操作数与描述符

`destination0` 是新 Local 并集目的地；`source0` 是原点锚定的持久左 Local 源；`source1` 是原点锚定的持久右 Local 源。

除非当前契约明确指出状态被消费或替换，否则源保持持久；只有完整预检后才发布目的描述符。

<!-- PTO-READER-BLOCK: tile-tpartmul-effects role=effects -->
## 发布与排序

重叠坐标执行所选类型化操作；只被一个源覆盖的坐标逐位复制该源。

结果、粘滞数值标志、描述符，以及有效矩形外未定义的 Null 填充 会原子发布。

<!-- PTO-READER-BLOCK: tile-tpartmul-constraints role=constraints -->
## 合法性、填充与故障

绑定格式错误、类型或布局不受支持、形状无效、被消费元素未定义、属性非法或目的容量不足时，会在源快照或发布之前拒绝操作。

分配失败触发所有者定义的 Tile 分配故障；其他被拒绝的绑定模式或值条件触发所有者定义的合法性、块控制或内存故障，且不产生部分效果。

<!-- PTO-READER-BLOCK: tile-tpartmul-example role=example -->
## 非规范契约草图

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

把 `BSTART.SFU TPARTMUL, S16; B.DIM LB0=16; B.IOT Left, Right, mask=1111, <last>, ->Dst<1>; BSTOP` 作为非规范绑定演练，再以下方生成契约确认精确维度、属性和故障行为。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TPARTMUL <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TPARTMUL | TEPL | 0x072 | 18 | 3 | ExecuteTilePartial |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local union destination |
| source0 | persistent Local left source anchored at origin |
| source1 | persistent Local right source anchored at origin |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/union/TPARTMUL.asl -->
```asl
readonly func InstructionContractOperation_TPARTMUL() => TileOperation
begin
    return TileOperation_TPARTMUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TPARTMUL, FP32|FP16|BF16|S32|S16|U32|U16
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional; omission defaults to 1)
B.DIM LB2=Col (optional; omission defaults to ValidCol)
B.IOT exactly two persistent Local sources and one new Local destination, common PE_MASK, <last>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/union/TPARTMUL.asl -->
```asl
pure func InstructionContractDataTypeLegal_TPARTMUL(
    data_type: TileDataType) => boolean
begin
    return TilePartialDataTypeSupportedForOperation(
        TilePartial_MUL,
        data_type);
end;

readonly func InstructionContractOperandsLegal_TPARTMUL(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTilePartial(
        TilePartial_MUL,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TPARTMUL() => TileSemanticHandler
begin
    return TileHandler_ExecuteTilePartial;
end;

func InstructionContractExecute_TPARTMUL(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    assert InstructionContractOperandsLegal_TPARTMUL(
        destination,
        source_left,
        source_right);
    ExecuteTilePartial(
        TilePartial_MUL,
        destination,
        source_left,
        source_right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow one; omitted LB2 selects physical Col equal to ValidCol.
- B.DATR, B.IOR, and B.IOS are absent. Both sources and the destination use the BSTART DataType and row-major layout.
- Each source rectangle is anchored at origin. A coordinate covered by exactly one source is copied bit-for-bit; a coordinate covered by both sources applies the selected typed operation. Physical padding is Null.

## Legality

- TPARTMUL uses the TEPL encoding carrier Mode 3 Function 18, canonically assembles with BSTART.SFU, and has no standalone opcode.
- Exactly two persistent nonempty Local sources and one newly allocated Local destination are supplied by a terminated B.IOT stream. B.DATR, B.IOR, and B.IOS are illegal.
- Source and destination DataType is exactly one of FP32, FP16, BF16, S32, S16, U32, or U16. All are row-major and use one PE_MASK.
- Both source valid rectangles are origin-anchored, fit within ValidRow by ValidCol, and at least one source covers the entire destination valid rectangle. Thus no valid destination coordinate is uncovered.
- Every valid source element is defined; floating encodings are valid.

## State effects

- At an overlap coordinate, typed multiplication is applied with the common DataType's exact arithmetic, ordering, rounding, NaN, signed-zero, and status behavior.
- At a coordinate covered by only one source, that source element is copied bit-for-bit without arithmetic status.
- Every physical destination coordinate outside ValidRow by ValidCol is undefined Null padding.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, type, shape, capacity, coverage, mask, destination-name, source-definedness, source-encoding, and allocation preflight precedes both source snapshots.
- The sources persist. The result payload, sticky numeric flags, Null padding definedness, and renamed destination descriptor publish atomically; rejection publishes none.

## Exceptions

- Missing, surplus, shared, scalar, data-attribute, malformed, unterminated, mixed-mask, type, layout, shape, undefined-source, or invalid-floating-encoding input raises Fault_TileLegality before effects.
- An unrepresentable destination shape, unavailable renamed destination, insufficient TSize, or exhausted Tile capacity raises Fault_TileAllocation before effects.
- PE_MASK zero completes as a strict no-op before descriptor reads, source reads, allocation, faults, numeric status, padding, or payload effects.

## Examples

- BSTART.SFU TPARTMUL, S16; B.DIM LB0=16; B.IOT Left, Right, mask=1111, <last>, ->Dst<1>; BSTOP
