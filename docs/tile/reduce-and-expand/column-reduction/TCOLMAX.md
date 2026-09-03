<!-- GENERATED FROM: asl/tile/reduce-and-expand/column-reduction/TCOLMAX.asl -->
# TCOLMAX

**Normative ASL source:** `asl/tile/reduce-and-expand/column-reduction/TCOLMAX.asl`

Reduce each valid column to its maximum with exact typed row-order semantics.

## Normative identity {#PTO-INST-TILE-TCOLMAX}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tcolmax-purpose role=purpose -->
## What TCOLMAX does

`TCOLMAX` is a selector-encoded Tile operation executed by `SFU`. It folds each column in increasing row order with typed maximum; its current instruction contract owns the exact bundle form and publication boundary.

<!-- PTO-READER-BLOCK: tile-tcolmax-mechanism role=mechanism -->
## Element and Tile mechanism

After all descriptor and operand checks succeed, the owning ASL handler folds each column in increasing row order with typed maximum. Source payloads are snapshotted before destination writes whenever the contract permits aliasing.

The handler uses the resolved valid region rather than treating physical padding as input data. Its operation-specific dtype, layout, rounding, saturation, and profile hooks remain the executable definition.

<!-- PTO-READER-BLOCK: tile-tcolmax-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `destination0` has the exact contract role **new Local same-type numeric destination**.
- `source0` has the exact contract role **persistent Local numeric source**.

Participating source and destination descriptors use the selected RowMajor, CUBE_M16, or CUBE_M32 layout and the logical-shape relationships stated by the current contract.
Every source coordinate read by the operation must be defined before execution reaches destination publication.
`PE_MASK=0000` is a strict no-op before descriptor, allocation, payload, numeric-status, or memory effects.

<!-- PTO-READER-BLOCK: tile-tcolmax-effects role=effects -->
## Publication, definedness, and padding

Destination-visible state is published only after complete preflight; where the contract names atomic publication, payload, descriptor, definedness, padding, and status become visible together.

Physical coordinates outside the valid rectangle follow the contract-selected padding rule; `Null` padding remains undefined when that rule applies.

The operation has no GM memory effect; descriptor, payload, definedness, padding, and numeric-status changes are limited to those listed by the current contract.

<!-- PTO-READER-BLOCK: tile-tcolmax-constraints role=constraints -->
## Type, layout, and fault boundary

The accepted data-type set is `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`.

The generated legality and exception sections below are authoritative for dtype pairs, layout, dimensions, capacity, definedness, padding controls, profile behavior, and fault class. Legality and allocation failures occur before partial architectural effects.

<!-- PTO-READER-BLOCK: tile-tcolmax-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `TCOLMAX` example, columns `[[1, 4], [3, 2]]` reduce to `[3, 4]`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TCOLMAX <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCOLMAX | TEPL | 0x051 | 17 | 2 | ExecuteTileReduction |

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

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local same-type numeric destination |
| source0 | persistent Local numeric source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/column-reduction/TCOLMAX.asl -->
```asl
readonly func InstructionContractOperation_TCOLMAX() => TileOperation
begin
    return TileOperation_TCOLMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TCOLMAX, DataType
B.DATR Layout, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/column-reduction/TCOLMAX.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCOLMAX(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCOLMAX(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileReduction(
        TileReduction_MAX,
        TileAxis_Column,
        destination,
        source);
end;

readonly func InstructionContractHandler_TCOLMAX() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileReduction;
end;

func InstructionContractExecute_TCOLMAX(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TCOLMAX(
        destination,
        source);
    ExecuteTileReduction(
        TileReduction_MAX,
        TileAxis_Column,
        destination,
        source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- TCOLMAX computes a typed increasing-row TMAX fold initialized from row zero; the scan order is architectural and tree reassociation is not permitted.

## Legality

- TCOLMAX is selected by the TEPL raw encoding carrier Mode 2 Function 17; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent Local source and one newly allocated Local destination. B.IOR, B.IOS, a second B.IOT, or a nonterminating binding is illegal.
- The source DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
- The destination DataType equals the source DataType.
- The source is a fully defined numeric Tile in the selected RowMajor, CUBE_M16, or CUBE_M32 layout whose ValidRow, ValidCol, and physical Col exactly match the B.DIM-derived source geometry; every constrained floating encoding is valid. The reduction source allocated capacity is at most 2048 bytes and is checked before the source snapshot or destination allocation.
- The destination has logical ValidRow equal to one and ValidCol equal to source.ValidCol; its physical geometry is derived from the selected layout and capacity.
- Layout and PadValueOrByteId are the only applicable nonzero B.DATR fields. Source and destination share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.

## State effects

- For each valid column, compute a typed increasing-row TMAX fold initialized from row zero.
- Write the typed reduction value without widening integer arithmetic or reassociating the fold.
- Apply the selected PadValue to physical destination coordinates outside the valid result rectangle, then publish the complete result atomically.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, dimension, type, descriptor, source-definedness, source-encoding, mask, capacity, name-allocation, and storage preflight precedes the source snapshot.
- The source is scanned in strictly increasing row order; the source persists and is never modified.
- Numeric status, all valid results, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.

## Exceptions

- A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType, unsupported, mixed, or mismatched source layout, undefined source element, invalid source encoding, or mismatched source geometry raises Fault_TileLegality before effects.
- An unrepresentable result shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.
- Floating numeric status is accumulated across the architectural fold and publishes atomically with the result.

## Examples

- BSTART.SFU TCOLMAX, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
