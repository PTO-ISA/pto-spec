<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/arithmetic/TMAX.asl -->
# TMAX

**Normative ASL source:** `asl/tile/elementwise-tile-tile/arithmetic/TMAX.asl`

Maximum corresponding Local Tile elements under typed integer and floating ordering.

## Normative identity {#PTO-INST-TILE-TMAX}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tmax-purpose role=purpose -->
## Purpose

`TMAX` selects typed maxima from corresponding Local Tile elements.

<!-- PTO-READER-BLOCK: tile-tmax-mechanism role=mechanism -->
## Execution mechanism

The ASL DOC contract selects `TileHandler_ExecuteTileBinary` through the instruction's selector-encoded block carrier.

Binding schema, dimensions, DataType, row-major layout, source definedness and encoding, PE_MASK, destination capacity, and applicable attributes are checked before source snapshots.

<!-- PTO-READER-BLOCK: tile-tmax-inputs-outputs role=inputs-outputs -->
## Operands and descriptors

`destination0` is the new Local destination; `source0` is the left comparison source; `source1` is the right comparison source.

Sources remain persistent unless the current contract explicitly names a consumed or replaced state; destination descriptors are published only after complete preflight.

<!-- PTO-READER-BLOCK: tile-tmax-effects role=effects -->
## Publication and ordering

Every valid coordinate applies the operation at the selected element type; all sources and private-GPR scalar operands are snapshotted before destination publication.

The valid payload, selected physical padding definedness, descriptor, and applicable sticky numeric flags publish atomically; rejection has no architectural effect.

<!-- PTO-READER-BLOCK: tile-tmax-constraints role=constraints -->
## Legality, padding, and faults

Malformed bindings, unsupported types or layouts, invalid shapes, undefined consumed elements, illegal attributes, or insufficient destination capacity are rejected before source snapshots or publication.

`PE_MASK=0000` is a strict no-op before reads, allocation, faults, numeric status, padding, or descriptor effects. Allocation failure raises the owner-defined Tile allocation fault; other rejected schema or value conditions raise the owner-defined legality, bundle-control, or memory fault without partial effects.

<!-- PTO-READER-BLOCK: tile-tmax-example role=example -->
## Non-normative contract sketch

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

Read `BSTART.VEC TMAX, FP32; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP` as a non-normative binding walkthrough, then use the generated contract below for exact dimensions, attributes, and fault behavior.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TMAX <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMAX | TEPL | 0x00B | 11 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | left comparison source |
| source1 | right comparison source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/arithmetic/TMAX.asl -->
```asl
readonly func InstructionContractOperation_TMAX() => TileOperation
begin
    return TileOperation_TMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TMAX, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/arithmetic/TMAX.asl -->
```asl
pure func InstructionContractDataTypeLegal_TMAX(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TMAX(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_MAX,
        destination,
        source_left,
        source_right);
end;

pure func InstructionContractFloatingValue_TMAX(
    data_type: TileDataType,
    source_left: Word,
    source_right: Word) => (Word, boolean)
begin
    assert InstructionContractDataTypeLegal_TMAX(data_type);
    assert TileDataTypeIsFloating(data_type);
    return TileFloatingMinMaxValue(
        TileBinary_MAX,
        data_type,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TMAX() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TMAX(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_MAX,
        destination,
        source_left,
        source_right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- For floating TMAX, one NaN selects the numeric operand, two NaNs select canonical NaN, signaling NaN reports invalid, and mixed signed zeros select positive zero.

## Legality

- TMAX is BSTART.VEC Mode 0 Function 11 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies two ordered Local sources and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of S32, U32, FP32, S16, U16, FP16, BF16, S8, or U8.
- Only B.DATR PadValueOrByteId is applicable; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.
- Floating source encodings invalid for the selected operation reject before allocation or destination effects; PE_MASK zero is a strict no-op.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- Select the typed elementwise maximum for every valid coordinate.
- Signed integers use signed ordering, unsigned integers use unsigned ordering, and supported floating carriers use deterministic NaN and signed-zero rules.
- Publish the complete valid result and selected physical padding atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both source payloads are snapshotted after complete legality and encoding preflight and before destination writes.
- Source aliasing and source-to-destination aliasing therefore observe pre-operation values.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched sources, unsupported DataType, non-row-major layout, invalid source encoding, or invalid destination capacity raises Fault_TileLegality before effects.
- A signaling NaN reports the selected numeric profile invalid condition without changing the deterministic selected result.

## Examples

- BSTART.VEC TMAX, FP32; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
