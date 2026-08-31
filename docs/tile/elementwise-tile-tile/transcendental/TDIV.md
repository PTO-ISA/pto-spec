<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/transcendental/TDIV.asl -->
# TDIV

**Normative ASL source:** `asl/tile/elementwise-tile-tile/transcendental/TDIV.asl`

Divide corresponding Local Tile elements under the selected numeric profile.

## Normative identity {#PTO-INST-TILE-TDIV}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tdiv-purpose role=purpose -->
## What TDIV does

`TDIV` is a selector-encoded Tile operation executed by `SFU`. It divides corresponding numerator and denominator elements under the selected integer or floating interpretation; its current instruction contract owns the exact bundle form and publication boundary.

<!-- PTO-READER-BLOCK: tile-tdiv-mechanism role=mechanism -->
## Element and Tile mechanism

After all descriptor and operand checks succeed, the owning ASL handler divides corresponding numerator and denominator elements under the selected integer or floating interpretation. Source payloads are snapshotted before destination writes whenever the contract permits aliasing.

The handler uses the resolved valid region rather than treating physical padding as input data. Its operation-specific dtype, layout, rounding, saturation, and profile hooks remain the executable definition.

<!-- PTO-READER-BLOCK: tile-tdiv-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `destination0` has the exact contract role **new Local destination**.
- `source0` has the exact contract role **ordered numerator**.
- `source1` has the exact contract role **ordered denominator**.

Participating source and destination descriptors use the row-major and shape relationships stated by the current contract.
Every source coordinate read by the operation must be defined before execution reaches destination publication.
`PE_MASK=0000` is a strict no-op before descriptor, allocation, payload, numeric-status, or memory effects.

<!-- PTO-READER-BLOCK: tile-tdiv-effects role=effects -->
## Publication, definedness, and padding

Destination-visible state is published only after complete preflight; where the contract names atomic publication, payload, descriptor, definedness, padding, and status become visible together.

Physical coordinates outside the valid rectangle follow the contract-selected padding rule; `Null` padding remains undefined when that rule applies.

The operation has no GM memory effect; descriptor, payload, definedness, padding, and numeric-status changes are limited to those listed by the current contract.

<!-- PTO-READER-BLOCK: tile-tdiv-constraints role=constraints -->
## Type, layout, and fault boundary

The accepted data-type set is `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`.

The generated legality and exception sections below are authoritative for dtype pairs, layout, dimensions, capacity, definedness, padding controls, profile behavior, and fault class. Legality and allocation failures occur before partial architectural effects.

<!-- PTO-READER-BLOCK: tile-tdiv-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `TDIV` example, numerator `8` and denominator `2` produce quotient `4`.
<!-- SUPPLEMENTARY-END -->

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
- The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
- Only B.DATR PadValueOrByteId is applicable.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

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
