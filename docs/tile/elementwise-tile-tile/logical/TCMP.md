<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TCMP.asl -->
# TCMP

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TCMP.asl`

Compare two Local numeric Tiles and produce one packed Local predicate Tile.

## Normative identity {#PTO-INST-TILE-TCMP}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TCMP <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCMP | TEPL | 0x00D | 13 | 0 | ExecuteTileCompare |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new packed Local predicate destination |
| source0 | ordered left Local numeric source |
| source1 | ordered right Local numeric source |
| comparison | EQ, NE, LT, GT, LE, or GE selected by CMode |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TCMP.asl -->
```asl
readonly func InstructionContractOperation_TCMP() => TileOperation
begin
    return TileOperation_TCMP;
end;

pure func InstructionContractComparisonCodeLegal_TCMP(
    comparison_code: bits(3)) => boolean
begin
    return UInt(comparison_code) <= 5;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TCMP, DataType
B.DATR CMode, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->Predicate<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TCMP.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCMP(
    data_type: TileDataType) => boolean
begin
    return TileCompareDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCMP(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    comparison: TileComparison) => boolean
begin
    return TileOperandsLegal_ExecuteTileCompare(
        destination,
        source_left,
        source_right,
        comparison);
end;

readonly func InstructionContractHandler_TCMP() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileCompare;
end;

func InstructionContractExecute_TCMP(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    comparison: TileComparison)
begin
    assert InstructionContractOperandsLegal_TCMP(
        destination,
        source_left,
        source_right,
        comparison);
    ExecuteTileCompare(
        destination,
        source_left,
        source_right,
        comparison);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- CMode codes 0, 1, 2, 3, 4, and 5 select EQ, NE, LT, GT, LE, and GE. Codes 6 and 7 are reserved. Omitted B.DATR retains CMode zero and therefore selects EQ.
- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every present dimension must be nonzero.
- Omitted B.DATR selects predicate PadValue=Null. Explicit PadValue 00 and 10 write zero padding bits, 01 writes one padding bits, and 11 leaves padding bits undefined.

## Legality

- TCMP is selected only by VEC Mode 0 Function 13 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies two ordered Local numeric sources and one new Local predicate destination. B.IOR, B.IOS, and additional bindings are illegal.
- The source DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
- Both sources match physical shape, valid shape, row-major layout, and DataType; every valid source element is defined and every constrained floating encoding is valid.
- The destination uses predicate-kind storage with the same Row, Col, ValidRow, and ValidCol. Logical index i occupies bit i mod 8 of byte floor(i/8), and TSize holds at least ceil(Row*Col/8) bytes.
- CMode and PadValueOrByteId are the only applicable B.DATR fields. Explicit nondefault Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.
- All participating Tiles use one PE_MASK. PE_MASK=0000 is a strict no-op before schema, descriptor, source, allocation, status, or payload checks.

## State effects

- Compare corresponding valid elements using signed, unsigned, or selected floating-profile ordering. NaN makes EQ, LT, GT, LE, and GE false and NE true; positive and negative zero compare equal.
- Pack one result bit per logical element with lower logical indices in lower byte bits.
- Publish predicate payload, padding definedness, numeric status, and destination descriptor atomically. Rejection leaves source and destination architectural state unchanged, and sources persist.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, field, type, geometry, layout, definedness, encoding, mask, and packed-capacity preflight precedes source snapshots and destination allocation.
- Both source payloads are snapshotted before comparison, so identical sources and logical source/destination aliases observe read-old values.

## Exceptions

- Malformed bindings, B.IOR or B.IOS presence, missing or zero dimensions, reserved CMode, unsupported DataType, mismatched shape, type or layout, undefined source data, invalid floating source encoding, or insufficient packed destination capacity raises Fault_TileLegality or Fault_TileAllocation before architectural effects.
- A signaling floating NaN produces the relation result defined for NaN and records the selected profile invalid status only with the atomically published destination.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies precise restart and completion behavior after an accepted operation.

## Examples

- BSTART.VEC TCMP, U64; B.DATR EQ, Null (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->Predicate<TSize>; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
