<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TNOT.asl -->
# TNOT

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TNOT.asl`

Element-width bitwise complement over one Local integer Tile source.

## Normative identity {#PTO-INST-TILE-TNOT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TNOT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TNOT | TEPL | 0x010 | 16 | 0 | ExecuteTileUnary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | bitwise source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TNOT.asl -->
```asl
readonly func InstructionContractOperation_TNOT() => TileOperation
begin
    return TileOperation_TNOT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TNOT, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TNOT.asl -->
```asl
pure func InstructionContractDataTypeLegal_TNOT(
    data_type: TileDataType) => boolean
begin
    return TileUnaryDataTypeSupported(TileUnary_NOT, data_type);
end;

readonly func InstructionContractOperandsLegal_TNOT(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_NOT,
        destination,
        source);
end;

pure func InstructionContractValue_TNOT(
    data_type: TileDataType,
    source: Word) => Word
begin
    let (result, -) = TileFixedUnaryValue(
        TileUnary_NOT,
        data_type,
        source);
    return result;
end;

readonly func InstructionContractHandler_TNOT() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TNOT(
    destination: TileIndex,
    source: TileIndex)
begin
    ExecuteTileUnary(TileUnary_NOT, destination, source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- TNOT complements exactly the selected 8-, 16-, 32-, or 64-bit element width and zero-extends the result to the Tile payload carrier.

## Legality

- TNOT is BSTART.VEC Mode 0 Function 16 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one Local source and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of S64, S32, S16, S8, U64, U32, U16, or U8.
- Source and destination match physical shape, valid shape, row-major layout, DataType, and PE_MASK; the source valid region is fully defined.
- Only B.DATR PadValueOrByteId is applicable; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.
- PE_MASK zero is a strict no-op before dimensions, source access, schema checks, or destination allocation.

## State effects

- For every valid coordinate, complement exactly the selected integer element width and clear upper carrier bits.
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

- BSTART.VEC TNOT, U64; B.DIM LB0=ValidCol; B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
