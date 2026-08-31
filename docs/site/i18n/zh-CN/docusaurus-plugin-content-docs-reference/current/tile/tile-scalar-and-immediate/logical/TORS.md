<!-- GENERATED FROM: asl/tile/tile-scalar-and-immediate/logical/TORS.asl -->
# TORS

**Normative ASL source:** `asl/tile/tile-scalar-and-immediate/logical/TORS.asl`

Bitwise-OR every valid integer Tile element with one scalar.

## Normative identity {#PTO-INST-TILE-TORS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tors-purpose role=purpose -->
## 用途

`TORS` 把每个有效整数 Tile 元素与一个标量执行逐位或。

<!-- PTO-READER-BLOCK: tile-tors-mechanism role=mechanism -->
## 执行机制

ASL DOC 契约通过该指令的选择器编码块载体选择 `TileHandler_ExecuteTileScalar`。

源快照之前，必须检查绑定模式、维度、DataType、行主序布局、源已定义性与编码、PE_MASK、目的容量和适用属性。

<!-- PTO-READER-BLOCK: tile-tors-inputs-outputs role=inputs-outputs -->
## 操作数与描述符

`destination0` 是新 Local 数值目的地；`source0` 是持久 Local 数值源；`scalar0` 是每个参与 PE 的私有 GPR 标量。

除非当前契约明确指出状态被消费或替换，否则源保持持久；只有完整预检后才发布目的描述符。

<!-- PTO-READER-BLOCK: tile-tors-effects role=effects -->
## 发布与排序

每个有效坐标都按所选元素类型执行操作；目的地发布之前会快照全部源和私有 GPR 标量操作数。

有效载荷、选中的物理填充的已定义性、描述符和适用的粘滞数值标志原子发布；拒绝时没有架构效果。

<!-- PTO-READER-BLOCK: tile-tors-constraints role=constraints -->
## 合法性、填充与故障

绑定格式错误、类型或布局不受支持、形状无效、被消费元素未定义、属性非法或目的容量不足时，会在源快照或发布之前拒绝操作。

`PE_MASK=0000` 是严格空操作，先于读取、分配、故障、数值状态、填充或描述符效果。分配失败触发所有者定义的 Tile 分配故障；其他被拒绝的绑定模式或值条件触发所有者定义的合法性、块控制或内存故障，且不产生部分效果。

<!-- PTO-READER-BLOCK: tile-tors-example role=example -->
## 非规范契约草图

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

把 `BSTART.VEC TORS, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR ScalarGPR, zero, zero, ->zero (optional); BSTOP` 作为非规范绑定演练，再以下方生成契约确认精确维度、属性和故障行为。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `tile-scalar-and-immediate`
- **Execution engine:** `VEC`

## Assembly

```asm
TORS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TORS | TEPL | 0x027 | 7 | 1 | ExecuteTileScalar |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### B.DATR.PadValueOrByteId (`PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID`)

Carries the operation-selected PadValue or ByteId union field.

**Encoded zero:** For PadValue operations code zero selects Zero; for ByteId operations it selects ByteId zero.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | Zero-or-ByteId0 |
| 1 | assigned | Max-or-ByteId1 |
| 2 | assigned | Min-or-ByteId2 |
| 3 | assigned | Null-or-ByteId3 |

**Reserved-value behavior:** All four encodings are assigned; the selected operation separately validates whether the field is PadValue, ByteId, or inapplicable.

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
| destination0 | new Local numeric destination |
| source0 | persistent Local numeric source |
| scalar0 | per-participating-PE private-GPR scalar |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-and-immediate/logical/TORS.asl -->
```asl
readonly func InstructionContractOperation_TORS() => TileOperation
begin
    return TileOperation_TORS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TORS, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR ScalarGPR, zero, zero, ->zero (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-and-immediate/logical/TORS.asl -->
```asl
pure func InstructionContractDataTypeLegal_TORS(
    data_type: TileDataType) => boolean
begin
    return TileVecScalarIntegerDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TORS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word) => boolean
begin
    return TileOperandsLegal_ExecuteTileScalar(
        TileBinary_OR,
        destination,
        source,
        scalar);
end;

readonly func InstructionContractHandler_TORS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileScalar;
end;

func InstructionContractExecute_TORS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word)
begin
    assert InstructionContractOperandsLegal_TORS(
        destination,
        source,
        scalar);
    ExecuteTileScalar(
        TileBinary_OR,
        destination,
        source,
        scalar);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Omitted B.IOR supplies zero and therefore preserves every valid source encoding. An explicitly present all-zero B.IOR is distinct but supplies the same value; RegSrc1, RegSrc2, and RegDst must be zero.

## Legality

- TORS is selected only by the TEPL raw carrier Mode 1 Function 7; canonical execution-engine assembly is BSTART.VEC TORS, DataType.
- Exactly one terminating Local B.IOT supplies one persistent Local numeric source and one newly allocated Local destination. B.IOS and additional Tile bindings are illegal.
- The selected DataType is exactly S64, S32, S16, S8, U64, U32, U16, or U8; every other assigned or reserved DataType rejects before effects.
- B.IOR is optional and, when present, only RegSrc0 may be nonzero. PadValueOrByteId is the only applicable B.DATR field; explicit nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.
- Source and destination use one PE_MASK. PE_MASK=0000 is a strict no-op before GPR reads, descriptor reads, allocation, faults, numeric status, or payload effects.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- For each valid element compute source OR scalar in the selected element interpretation.
- Publish valid payload, selected padding definedness, numeric status where applicable, and destination descriptor atomically; the source persists and rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, dimension, type, descriptor, source-definedness, scalar-encoding, mask, capacity, and allocation preflight precedes source and scalar snapshots.
- The source payload and scalar are snapshotted before destination publication, so a source that aliases the renamed destination observes its old value.

## Exceptions

- A malformed Local binding stream, B.IOS presence, surplus B.IOR field, missing or zero dimension, unsupported DataType, source descriptor, definedness, or carrier-width failure, invalid destination capacity, or allocation failure raises Fault_TileLegality or Fault_TileAllocation before effects.
- Only the low element width participates; signedness does not change the raw operation and no numeric-status flag is produced.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies precise restart and completion after an accepted operation.

## Examples

- BSTART.VEC TORS, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR ScalarGPR, zero, zero, ->zero (optional); BSTOP
