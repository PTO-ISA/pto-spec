<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/transcendental/TDIV.asl -->
# TDIV

**Normative ASL source:** `asl/tile/elementwise-tile-tile/transcendental/TDIV.asl`

Divide corresponding Local Tile elements under the selected numeric profile.

## Normative identity {#PTO-INST-TILE-TDIV}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `SFU`

## Assembly

```asm
TDIV <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TDIV | TEPL | 0x003 | 3 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | ordered numerator |
| source1 | ordered denominator |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/transcendental/TDIV.asl -->
```asl
readonly func InstructionContractOperation_TDIV() => TileOperation
begin
    return TileOperation_TDIV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TDIV, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Numerator, Denominator, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/transcendental/TDIV.asl -->
```asl
pure func InstructionContractDataTypeLegal_TDIV(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TDIV(
    destination: TileIndex,
    numerator: TileIndex,
    denominator: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_DIV,
        destination,
        numerator,
        denominator);
end;

readonly func InstructionContractHandler_TDIV() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TDIV(
    destination: TileIndex,
    numerator: TileIndex,
    denominator: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_DIV,
        destination,
        numerator,
        denominator);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and nonzero; omitted LB1 selects ValidRow=1 and omitted LB2 selects Col=ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- The numeric profile owns fixed rounding, floating exceptional values, and floating positive or negative zero division.

## Legality

- TDIV retains TEPL carrier Mode 0 Function 3 but is canonically classified as SFU.
- Exactly one terminating Local B.IOT supplies ordered numerator and denominator sources plus one new Local destination; B.IOR and B.IOS are illegal and PE_MASK zero is a strict no-op.
- DataType is exactly S32, U32, FP32, S16, U16, FP16, or BF16.
- Both source valid rectangles are defined and all three Tiles match physical shape, valid shape, row-major layout, DataType, and the selected mask.
- Only B.DATR PadValueOrByteId is applicable.

## State effects

- Signed integers use signed division, unsigned integers use unsigned division, and floating values use the selected floating division profile.
- The valid quotient and selected physical padding publish atomically; rejection leaves descriptor, payload, and allocation state unchanged.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both source payloads are snapshotted after all legality and integer-zero checks, so aliasing is read-before-write.

## Exceptions

- An integer zero in the valid denominator rectangle raises Fault_TileLegality before source snapshots, allocation publication, or destination effects; denominator padding is not read.
- Malformed bindings, unsupported types, undefined inputs, mismatched descriptors, or invalid capacity reject before effects; floating zero is handled by the selected numeric profile.

## Examples

- BSTART.SFU TDIV, S64; B.DIM LB0=ValidCol; B.IOT Numerator, Denominator, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
