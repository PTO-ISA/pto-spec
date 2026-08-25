<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TRELU.asl -->
# TRELU

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TRELU.asl`

Same-type elementwise rectifier over one Local Tile source.

## Normative identity {#PTO-INST-TILE-TRELU}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-trelu-purpose role=purpose -->
## What TRELU does

`TRELU` applies an elementwise rectifier to every valid element and publishes a new Local destination.

<!-- PTO-READER-BLOCK: tile-c-trelu-mechanism role=mechanism -->
## Operation mechanism

The operation evaluates only the valid rectangle using the mnemonic-selected typed element rule.

<!-- PTO-READER-BLOCK: tile-c-trelu-inputs-outputs role=inputs-outputs -->
## Operands, shape, and type

- `destination0` identifies a newly allocated destination.

- `source0` supplies a persistent source Tile.

- The closed applicable DataType set is `FP16`, `BF16`, `FP32`, `S32`.

- Data Tiles use row-major layout unless this mnemonic explicitly selects another permitted layout.

- `LB0`, `LB1`, and `LB2` complete the valid and physical shape according to this mnemonic’s contract; every required valid extent is nonzero.

<!-- PTO-READER-BLOCK: tile-c-trelu-effects role=effects -->
## Definedness, padding, and publication

All source descriptors and payloads are validated and snapshotted before destination publication.

The complete destination payload, descriptor, definedness, padding state, and applicable numeric status publish atomically; rejection publishes none.

Null padding leaves physical coordinates outside the valid rectangle undefined; an explicit non-Null PadValue defines those coordinates with the selected typed value.

Source Tiles persist and are not modified by successful execution.

<!-- PTO-READER-BLOCK: tile-c-trelu-constraints role=constraints -->
## Legality, fault, and order boundaries

Complete binding schema, dimensions, DataType, layout, source definedness, numeric encoding, destination capacity, and allocation are preflighted before effects.

A failed legality or allocation check raises the applicable Tile fault without partial destination, status, or memory effects.

`PE_MASK=0000` is a strict no-op before operand reads, allocation, faults, numeric status, or payload effects.

<!-- PTO-READER-BLOCK: tile-c-trelu-example role=example -->
## Non-normative example

This example illustrates the current ASL-bound contract and is not a second instruction definition.

`TRELU <bundle operands>` performs complete preflight and source snapshotting before atomically publishing the mnemonic-defined result and padding state.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TRELU <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TRELU | TEPL | 0x017 | 23 | 0 | ExecuteTileUnary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | rectifier source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TRELU.asl -->
```asl
readonly func InstructionContractOperation_TRELU() => TileOperation
begin
    return TileOperation_TRELU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TRELU, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TRELU.asl -->
```asl
pure func InstructionContractDataTypeLegal_TRELU(
    data_type: TileDataType) => boolean
begin
    return TileTReluDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TRELU(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_RELU,
        destination,
        source);
end;

pure func InstructionContractValue_TRELU(
    data_type: TileDataType,
    source: Word) => (Word, boolean)
begin
    return TileFixedUnaryValue(
        TileUnary_RELU,
        data_type,
        source);
end;

readonly func InstructionContractHandler_TRELU() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TRELU(
    destination: TileIndex,
    source: TileIndex)
begin
    ExecuteTileUnary(TileUnary_RELU, destination, source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Signed negative integers become zero and unsigned integers are unchanged. Floating negative finite values, negative infinity, and both signed zeros become positive zero; positive values and positive infinity are preserved; NaNs become the profile quiet NaN and signaling NaN reports invalid.

## Legality

- TRELU is BSTART.VEC Mode 0 Function 23 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one Local source and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of FP16, BF16, FP32, or S32.
- Source and destination match physical shape, valid shape, row-major layout, DataType, and PE_MASK; the source valid region is fully defined.
- Only B.DATR PadValueOrByteId is applicable; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.
- Floating source encodings invalid for the selected DataType reject before allocation or destination effects; PE_MASK zero is a strict no-op.

## State effects

- For every valid coordinate, apply the same-type integer or floating rectifier selected by DataType.
- Publish the complete valid result and selected physical padding atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- The source payload is snapshotted after complete schema, dimension, DataType, layout, definedness, encoding, mask, and destination-capacity preflight and before destination writes.
- Source-to-destination aliasing therefore observes the complete pre-operation source payload.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched source state, unsupported DataType, non-row-major layout, or invalid floating source encoding raises Fault_TileLegality before effects; an unrepresentable destination shape or insufficient TSize capacity raises Fault_TileAllocation before allocation.
- For TRELU, a signaling NaN publishes the profile quiet NaN and records the selected numeric-profile invalid condition only after complete legality preflight.

## Examples

- BSTART.VEC TRELU, U64; B.DIM LB0=ValidCol; B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
