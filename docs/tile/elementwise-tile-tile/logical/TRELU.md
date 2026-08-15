<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TRELU.asl -->
# TRELU

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TRELU.asl`

Same-type elementwise rectifier over one Local Tile source.

## Normative identity {#PTO-INST-TILE-TRELU}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

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
    return TileUnaryDataTypeSupported(TileUnary_RELU, data_type);
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
- DataType is one of FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
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

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
