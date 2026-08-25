<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/transcendental/TREM.asl -->
# TREM

**Normative ASL source:** `asl/tile/elementwise-tile-tile/transcendental/TREM.asl`

Compute divisor-signed modulo for corresponding Local Tile elements.

## Normative identity {#PTO-INST-TILE-TREM}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-trem-purpose role=purpose -->
## What TREM does

`TREM` computes divisor-signed modulo for corresponding elements and publishes a new Local destination.

<!-- PTO-READER-BLOCK: tile-c-trem-mechanism role=mechanism -->
## Operation mechanism

The operation evaluates only the valid rectangle using the mnemonic-selected typed element rule.

Floating results and element status follow the active named numeric profile; the portable contract owns selection, shape, publication, and fault order.

<!-- PTO-READER-BLOCK: tile-c-trem-inputs-outputs role=inputs-outputs -->
## Operands, shape, and type

- `destination0` identifies a newly allocated destination.

- `source0` carries its mnemonic-defined operand.

- `source1` carries its mnemonic-defined operand.

- The closed applicable DataType set is `FP32`, `FP16`, `BF16`, `S32`, `S16`, `U32`, `U16`.

- Data Tiles use row-major layout unless this mnemonic explicitly selects another permitted layout.

- `LB0`, `LB1`, and `LB2` complete the valid and physical shape according to this mnemonic’s contract; every required valid extent is nonzero.

<!-- PTO-READER-BLOCK: tile-c-trem-effects role=effects -->
## Definedness, padding, and publication

All source descriptors and payloads are validated and snapshotted before destination publication.

The complete destination payload, descriptor, definedness, padding state, and applicable numeric status publish atomically; rejection publishes none.

Null padding leaves physical coordinates outside the valid rectangle undefined; an explicit non-Null PadValue defines those coordinates with the selected typed value.

Source Tiles persist and are not modified by successful execution.

<!-- PTO-READER-BLOCK: tile-c-trem-constraints role=constraints -->
## Legality, fault, and order boundaries

Complete binding schema, dimensions, DataType, layout, source definedness, numeric encoding, destination capacity, and allocation are preflighted before effects.

A failed legality or allocation check raises the applicable Tile fault without partial destination, status, or memory effects.

`PE_MASK=0000` is a strict no-op before operand reads, allocation, faults, numeric status, or payload effects.

<!-- PTO-READER-BLOCK: tile-c-trem-example role=example -->
## Non-normative example

This example illustrates the current ASL-bound contract and is not a second instruction definition.

`TREM <bundle operands>` performs complete preflight and source snapshotting before atomically publishing the mnemonic-defined result and padding state.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `SFU`

## Assembly

```asm
TREM <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TREM | TEPL | 0x004 | 4 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | ordered dividend |
| source1 | ordered divisor |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/transcendental/TREM.asl -->
```asl
readonly func InstructionContractOperation_TREM() => TileOperation
begin
    return TileOperation_TREM;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TREM, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Dividend, Divisor, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/transcendental/TREM.asl -->
```asl
pure func InstructionContractDataTypeLegal_TREM(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TREM(
    destination: TileIndex,
    dividend: TileIndex,
    divisor: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_REM,
        destination,
        dividend,
        divisor);
end;

readonly func InstructionContractHandler_TREM() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TREM(
    destination: TileIndex,
    dividend: TileIndex,
    divisor: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_REM,
        destination,
        dividend,
        divisor);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and nonzero; omitted LB1 selects ValidRow=1 and omitted LB2 selects Col=ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- The numeric profile owns fixed rounding, signed overflow boundaries, floating exceptional values, and floating zero modulo.

## Legality

- TREM retains TEPL carrier Mode 0 Function 4 but is canonically classified as SFU.
- Exactly one terminating Local B.IOT supplies ordered dividend and divisor sources plus one new Local destination; B.IOR and B.IOS are illegal and PE_MASK zero is a strict no-op.
- DataType is exactly S32, U32, FP32, S16, U16, FP16, or BF16.
- Both source valid rectangles are defined and all three Tiles match physical shape, valid shape, row-major layout, DataType, and the selected mask.
- Only B.DATR PadValueOrByteId is applicable.

## State effects

- Signed integer modulo uses floor division so a nonzero result has the divisor's sign; unsigned integers use ordinary unsigned remainder and floating values use the selected modulo profile.
- The valid modulo result and selected physical padding publish atomically; rejection leaves descriptor, payload, and allocation state unchanged.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both source payloads are snapshotted after all legality and integer-zero checks, so aliasing is read-before-write.

## Exceptions

- An integer zero in the valid divisor rectangle raises Fault_TileLegality before snapshots, allocation publication, or destination effects; divisor padding is not read.
- Malformed bindings, unsupported types, undefined inputs, mismatched descriptors, or invalid capacity reject before effects; floating zero is handled by the selected numeric profile.

## Examples

- BSTART.SFU TREM, S64; B.DIM LB0=ValidCol; B.IOT Dividend, Divisor, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
