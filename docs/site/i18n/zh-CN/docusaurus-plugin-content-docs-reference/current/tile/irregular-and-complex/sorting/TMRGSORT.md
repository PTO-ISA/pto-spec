<!-- GENERATED FROM: asl/tile/irregular-and-complex/sorting/TMRGSORT.asl -->
# TMRGSORT

**Normative ASL source:** `asl/tile/irregular-and-complex/sorting/TMRGSORT.asl`

Stably merge two sorted single-row Local streams into one newly allocated Local destination.

## Normative identity {#PTO-INST-TILE-TMRGSORT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tmrgsort-purpose role=purpose -->
## 用途

`TMRGSORT` 把两个已排序的单行 Local 流稳定合并到新分配的 Local 目的 Tile。

<!-- PTO-READER-BLOCK: tile-tmrgsort-mechanism role=mechanism -->
## 执行机制

ASL DOC 契约通过该指令的选择器编码块载体选择 `TileHandler_TMRGSORT`。

任何源快照之前，必须检查维度、描述符、布局、DataType、源已定义性、被消费的编码、目的容量、掩码，以及操作专用索引或偏移。

<!-- PTO-READER-BLOCK: tile-tmrgsort-inputs-outputs role=inputs-outputs -->
## 操作数与描述符

`destination0` 是新 Local 合并目的地；`source0` 是持久已排序 Local 左源；`source1` 是持久已排序 Local 右源；`flag0` 是升序或降序选择。

除非当前契约明确指出状态被消费或替换，否则源保持持久；只有完整预检后才发布目的描述符。

<!-- PTO-READER-BLOCK: tile-tmrgsort-effects role=effects -->
## 发布与排序

构造结果之前会先快照源，因此允许的别名看到完整的操作前载荷与已定义性。

完整目的载荷、已定义性、填充 策略和描述符一同发布；拒绝时不会发布部分目的地。

<!-- PTO-READER-BLOCK: tile-tmrgsort-constraints role=constraints -->
## 合法性、填充与故障

绑定格式错误、类型或布局不受支持、形状无效、被消费元素未定义、属性非法或目的容量不足时，会在源快照或发布之前拒绝操作。

分配失败触发所有者定义的 Tile 分配故障；其他被拒绝的绑定模式或值条件触发所有者定义的合法性、块控制或内存故障，且不产生部分效果。

<!-- PTO-READER-BLOCK: tile-tmrgsort-example role=example -->
## 非规范契约草图

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

把 `BSTART.SFU TMRGSORT, FP16; B.IOR a0; B.IOT T0, T1, mask=1111, <last>, ->T0<TSize>; BSTOP` 作为非规范绑定演练，再以下方生成契约确认精确维度、属性和故障行为。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TMRGSORT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMRGSORT | TEPL | 0x06D | 13 | 3 | TMRGSORT |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### B.IOR.RegDst (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

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

### B.IOR.RegSrc2 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

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
| destination0 | new Local merged destination |
| source0 | persistent sorted Local left source |
| source1 | persistent sorted Local right source |
| flag0 | ascending or descending selection |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/sorting/TMRGSORT.asl -->
```asl
readonly func InstructionContractOperation_TMRGSORT() => TileOperation
begin
    return TileOperation_TMRGSORT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TMRGSORT, FP32|FP16
B.DATR all-zero (optional)
B.IOR Descending (optional; omission defaults to ascending)
B.IOT two Local sources and one new Local destination, common PE_MASK, <last>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/sorting/TMRGSORT.asl -->
```asl
pure func InstructionContractDataTypeLegal_TMRGSORT(
    data_type: TileDataType) => boolean
begin
    return TileSortDataTypeSupported(data_type);
end;

pure func InstructionContractDefaultDescending_TMRGSORT() => boolean
begin
    return FALSE;
end;

readonly func InstructionContractOperandsLegal_TMRGSORT(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    descending: boolean) => boolean
begin
    return TileOperandsLegal_TMRGSORT(
        destination,
        source_left,
        source_right,
        descending);
end;

readonly func InstructionContractHandler_TMRGSORT() => TileSemanticHandler
begin
    return TileHandler_TMRGSORT;
end;

func InstructionContractExecute_TMRGSORT(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    descending: boolean)
begin
    assert InstructionContractOperandsLegal_TMRGSORT(
        destination,
        source_left,
        source_right,
        descending);
    TMRGSORT(
        destination,
        source_left,
        source_right,
        descending);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Omitted B.IOR selects ascending order. A present RegSrc0 must contain exactly zero for ascending or one for descending; every unused selector is zero.
- Every B.DIM is omitted. Destination ValidCol is the sum of source ValidCol values and physical Col is the smallest representable power of two that covers that sum.
- Omitted B.DATR selects the operation defaults. A present B.DATR is legal only when every encoded field is zero. Physical padding is Null.

## Legality

- TMRGSORT uses the TEPL encoding carrier Mode 3 Function 13, canonically assembles with BSTART.SFU, and has no standalone opcode.
- The complete Local binding stream supplies exactly two persistent nonempty single-row sorted sources and one newly allocated destination. All are row-major FP32 or FP16 with one common DataType.
- The source streams are sorted in the direction selected by B.IOR before execution. B.DATR is all zero, every B.DIM is absent, B.IOS is illegal, and every B.IOT uses one PE_MASK.
- Every valid source element is defined and has a valid encoding. Signaling NaN is a legal merge value and records numeric invalid status rather than causing a Tile legality fault.

## State effects

- Stably merge two already sorted single-row streams in ascending or descending order.
- Signaling-NaN observation ORs NV into the sticky numeric status. Both sources persist.
- Rejection publishes no destination, descriptor, or numeric status effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Merge is stable. Equal values select the left source first; numeric values precede NaNs in both directions; NaNs retain per-source order and left-source precedence; signed zeros compare equal.
- Destination ValidRow is one and ValidCol is the sum of both source ValidCol values. It contains the complete selected-order merge.
- Complete schema, direction, source ordering, type, descriptor, shape, capacity, mask, allocation, definedness, and encoding preflight precedes both source snapshots. Destination, Null padding, numeric status, and descriptor publish atomically.

## Exceptions

- Malformed or unterminated Local bindings, B.IOS, any B.DIM, unsupported DataType, non-row-major or nonsingle-row sources, nonzero inapplicable B.DATR fields, descending other than zero or one, undefined or invalid source data, or a source not sorted in the selected direction raises Fault_TileLegality before effects.
- A combined width above the architectural physical-column range, insufficient TSize, an unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before effects.
- PE_MASK zero completes as a strict no-op before control reads, source reads, sortedness checks, allocation, faults, numeric status, or payload effects.

## Examples

- BSTART.SFU TMRGSORT, FP16; B.IOR a0; B.IOT T0, T1, mask=1111, <last>, ->T0<TSize>; BSTOP
