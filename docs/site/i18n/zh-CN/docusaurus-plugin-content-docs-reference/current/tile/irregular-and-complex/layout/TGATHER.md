<!-- GENERATED FROM: asl/tile/irregular-and-complex/layout/TGATHER.asl -->
# TGATHER

**Normative ASL source:** `asl/tile/irregular-and-complex/layout/TGATHER.asl`

Gather values from source rows selected independently at each destination coordinate.

## Normative identity {#PTO-INST-TILE-TGATHER}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tgather-purpose role=purpose -->
## 用途

`TGATHER` 在每个目的坐标独立选择源行并收集对应值。

<!-- PTO-READER-BLOCK: tile-tgather-mechanism role=mechanism -->
## 执行机制

ASL DOC 契约通过该指令的选择器编码块载体选择 `TileHandler_TGATHER`。

任何源快照之前，必须检查维度、描述符、布局、DataType、源已定义性、被消费的编码、目的容量、掩码，以及操作专用索引或偏移。

<!-- PTO-READER-BLOCK: tile-tgather-inputs-outputs role=inputs-outputs -->
## 操作数与描述符

`destination0` 是新 Local 值目的地；`source0` 是持久 Local 值源；`source1` 是持久 Local 行索引源，类型为 S16、U16、S32、U32、S64 或 U64。

除非当前契约明确指出状态被消费或替换，否则源保持持久；只有完整预检后才发布目的描述符。

<!-- PTO-READER-BLOCK: tile-tgather-effects role=effects -->
## 发布与排序

构造结果之前会先快照源，因此允许的别名看到完整的操作前载荷与已定义性。

完整目的载荷、已定义性、填充 策略和描述符一同发布；拒绝时不会发布部分目的地。

<!-- PTO-READER-BLOCK: tile-tgather-constraints role=constraints -->
## 合法性、填充与故障

绑定格式错误、类型或布局不受支持、形状无效、被消费元素未定义、属性非法或目的容量不足时，会在源快照或发布之前拒绝操作。

分配失败触发所有者定义的 Tile 分配故障；其他被拒绝的绑定模式或值条件触发所有者定义的合法性、块控制或内存故障，且不产生部分效果。

<!-- PTO-READER-BLOCK: tile-tgather-example role=example -->
## 非规范契约草图

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

把 `BSTART.SFU TGATHER, U16; B.DIM LB0=2; B.DIM LB1=2; B.IOT ValueSrc, IndexSrc, mask=1111, <last>, ->Dst<2>; BSTOP` 作为非规范绑定演练，再以下方生成契约确认精确维度、属性和故障行为。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TGATHER <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGATHER | TEPL | 0x06F | 15 | 3 | TGATHER |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local value destination |
| source0 | persistent Local value source |
| source1 | persistent Local S16, U16, S32, U32, S64, or U64 row-index source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/layout/TGATHER.asl -->
```asl
readonly func InstructionContractOperation_TGATHER() => TileOperation
begin
    return TileOperation_TGATHER;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TGATHER, ValueDataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT ValueSrc, IndexSrc, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/layout/TGATHER.asl -->
```asl
readonly func InstructionContractOperandsLegal_TGATHER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex) => boolean
begin
    return TileOperandsLegal_TGATHER(destination, source, indices);
end;

readonly func InstructionContractHandler_TGATHER() => TileSemanticHandler
begin
    return TileHandler_TGATHER;
end;

func InstructionContractExecute_TGATHER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex)
begin
    assert InstructionContractOperandsLegal_TGATHER(
        destination,
        source,
        indices);
    TGATHER(destination, source, indices);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero destination ValidCol; omitted LB1 selects destination ValidRow=1 and omitted LB2 selects physical Col=ValidCol.
- Omitted B.DATR retains row-major destination layout; an assigned legal Layout changes only destination physical placement. PadValueOrByteId, secondary DataType, CMode, RMode, Sat, and Canonicalize remain zero.
- Physical destination coordinates outside the valid rectangle are undefined Null padding.

## Legality

- TGATHER uses the TEPL encoding carrier Mode 3 Function 15, is canonically assembled with BSTART.SFU, and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent value source, one persistent row-index source, and one newly allocated destination; B.IOR and B.IOS are illegal.
- Value source and destination use the same one of HiF8, E4M3, E5M2, E3M2, E2M3, E8M0, S8, U8, FP16, BF16, S16, U16, FP32, TF32, HF32, S32, U32, FP64, S64, or U64. The index source is exactly S16, U16, S32, U32, S64, or U64.
- Index and destination valid shapes are equal and nonzero. The value source has at least destination ValidCol columns.
- Every signed index is nonnegative and every index is less than source ValidRow. The complete index rectangle and every selected source[value,row,column] element are defined and validly encoded.
- All three bindings use the same PE_MASK; any nonzero subset is legal.

## State effects

- For every destination coordinate [r,c], read k=index[r,c] and copy source[k,c] bit-for-bit to destination[r,c].
- Indices select logical source rows and never flatten, wrap, clamp, or select another column.
- Both sources persist and rejection publishes no destination state.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, descriptor, type, dimension, layout, capacity, index-range, and referenced-definedness preflight precedes source snapshots.
- Both source payloads are snapshotted before result construction; complete destination payload, definedness, Null padding, and descriptor publish atomically.

## Exceptions

- Malformed bindings, B.IOR, B.IOS, unsupported value or index DataType, zero or mismatched valid shape, insufficient source columns, negative or out-of-range index, undefined index, undefined selected source element, invalid consumed encoding, reserved Layout, or insufficient destination capacity raises the applicable Tile fault before effects.
- PE_MASK=0000 is a strict no-op before Tile reads, index checks, allocation, faults, or payload effects.

## Examples

- BSTART.SFU TGATHER, U16; B.DIM LB0=2; B.DIM LB1=2; B.IOT ValueSrc, IndexSrc, mask=1111, <last>, ->Dst<2>; BSTOP
