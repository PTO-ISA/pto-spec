<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TNEG.asl -->
# TNEG

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TNEG.asl`

Typed elementwise arithmetic negation over one Local Tile source.

## Normative identity {#PTO-INST-TILE-TNEG}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tneg-purpose role=purpose -->
## Purpose

`TNEG` performs typed elementwise arithmetic negation.

<!-- PTO-READER-BLOCK: tile-tneg-mechanism role=mechanism -->
## Execution mechanism

The ASL DOC contract selects `TileHandler_ExecuteTileUnary` through the instruction's selector-encoded block carrier.

Binding schema, dimensions, DataType, row-major layout, source definedness and encoding, PE_MASK, destination capacity, and applicable attributes are checked before source snapshots.

<!-- PTO-READER-BLOCK: tile-tneg-inputs-outputs role=inputs-outputs -->
## Operands and descriptors

`destination0` is the new Local destination; `source0` is the negation source.

Sources remain persistent unless the current contract explicitly names a consumed or replaced state; destination descriptors are published only after complete preflight.

<!-- PTO-READER-BLOCK: tile-tneg-effects role=effects -->
## Publication and ordering

Every valid coordinate applies the operation at the selected element type; all sources and private-GPR scalar operands are snapshotted before destination publication.

The valid payload, selected physical padding definedness, descriptor, and applicable sticky numeric flags publish atomically; rejection has no architectural effect.

<!-- PTO-READER-BLOCK: tile-tneg-constraints role=constraints -->
## Legality, padding, and faults

Malformed bindings, unsupported types or layouts, invalid shapes, undefined consumed elements, illegal attributes, or insufficient destination capacity are rejected before source snapshots or publication.

`PE_MASK=0000` is a strict no-op before reads, allocation, faults, numeric status, padding, or descriptor effects. Allocation failure raises the owner-defined Tile allocation fault; other rejected schema or value conditions raise the owner-defined legality, bundle-control, or memory fault without partial effects.

<!-- PTO-READER-BLOCK: tile-tneg-example role=example -->
## Non-normative contract sketch

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

Read `BSTART.VEC TNEG, U64; B.DIM LB0=ValidCol; B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP` as a non-normative binding walkthrough, then use the generated contract below for exact dimensions, attributes, and fault behavior.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TNEG <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TNEG | TEPL | 0x011 | 17 | 0 | ExecuteTileUnary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | negation source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TNEG.asl -->
```asl
readonly func InstructionContractOperation_TNEG() => TileOperation
begin
    return TileOperation_TNEG;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TNEG, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TNEG.asl -->
```asl
pure func InstructionContractDataTypeLegal_TNEG(
    data_type: TileDataType) => boolean
begin
    return TileTNegDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TNEG(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_NEG,
        destination,
        source);
end;

pure func InstructionContractValue_TNEG(
    data_type: TileDataType,
    source: Word) => Word
begin
    let (result, -) = TileFixedUnaryValue(
        TileUnary_NEG,
        data_type,
        source);
    return result;
end;

readonly func InstructionContractHandler_TNEG() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TNEG(
    destination: TileIndex,
    source: TileIndex)
begin
    ExecuteTileUnary(TileUnary_NEG, destination, source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Integer negation is zero minus the source modulo the selected element width, including unsigned types. Floating negation toggles only the sign bit, preserving zeros, infinities, NaN class, and NaN payload without reporting invalid solely for TNEG.

## Legality

- TNEG is BSTART.VEC Mode 0 Function 17 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one Local source and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of S32, S16, S8, FP32, FP16, or BF16.
- Source and destination match physical shape, valid shape, row-major layout, DataType, and PE_MASK; the source valid region is fully defined.
- Only B.DATR PadValueOrByteId is applicable; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.
- Floating source encodings invalid for the selected DataType reject before allocation or destination effects; PE_MASK zero is a strict no-op.

## State effects

- For every valid coordinate, negate modulo the selected integer width or toggle only the floating sign bit according to DataType.
- Publish the complete valid result and selected physical padding atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- The source payload is snapshotted after complete schema, dimension, DataType, layout, definedness, encoding, mask, and destination-capacity preflight and before destination writes.
- Source-to-destination aliasing therefore observes the complete pre-operation source payload.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched source state, unsupported DataType, non-row-major layout, or invalid floating source encoding raises Fault_TileLegality before effects; an unrepresentable destination shape or insufficient TSize capacity raises Fault_TileAllocation before allocation.
- This operation introduces no memory fault and reports no floating invalid condition solely from its value transform.

## Examples

- BSTART.VEC TNEG, U64; B.DIM LB0=ValidCol; B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
