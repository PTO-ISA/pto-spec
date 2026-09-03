<!-- GENERATED FROM: asl/tile/reduce-and-expand/row-reduction/TROWMAX.asl -->
# TROWMAX

**Normative ASL source:** `asl/tile/reduce-and-expand/row-reduction/TROWMAX.asl`

Reduce each valid row to its maximum with exact typed column-order semantics.

## Normative identity {#PTO-INST-TILE-TROWMAX}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-trowmax-purpose role=purpose -->
## What TROWMAX does

`TROWMAX` reduces each row to its maximum.

<!-- PTO-READER-BLOCK: tile-c-trowmax-mechanism role=mechanism -->
## Operation mechanism

Each row is scanned in strictly increasing column order; reassociation is not permitted.

Floating results and element status follow the active named numeric profile; the portable contract owns selection, shape, publication, and fault order.

<!-- PTO-READER-BLOCK: tile-c-trowmax-inputs-outputs role=inputs-outputs -->
## Operands, shape, and type

- `destination0` identifies a newly allocated destination.

- `source0` supplies a persistent source Tile.

- The closed applicable DataType set is `FP32`, `FP16`, `BF16`, `S32`, `S16`, `S8`, `U32`, `U16`, `U8`.

- Data Tiles use row-major layout unless this mnemonic explicitly selects another permitted layout.

- `LB0`, `LB1`, and `LB2` complete the valid and physical shape according to this mnemonic’s contract; every required valid extent is nonzero.

<!-- PTO-READER-BLOCK: tile-c-trowmax-effects role=effects -->
## Definedness, padding, and publication

All source descriptors and payloads are validated and snapshotted before destination publication.

The complete destination payload, descriptor, definedness, padding state, and applicable numeric status publish atomically; rejection publishes none.

Null padding leaves physical coordinates outside the valid rectangle undefined; an explicit non-Null PadValue defines those coordinates with the selected typed value.

Source Tiles persist and are not modified by successful execution.

<!-- PTO-READER-BLOCK: tile-c-trowmax-constraints role=constraints -->
## Legality, fault, and order boundaries

Complete binding schema, dimensions, DataType, layout, source definedness, numeric encoding, destination capacity, and allocation are preflighted before effects.

A failed legality or allocation check raises the applicable Tile fault without partial destination, status, or memory effects.

`PE_MASK=0000` is a strict no-op before operand reads, allocation, faults, numeric status, or payload effects.

<!-- PTO-READER-BLOCK: tile-c-trowmax-example role=example -->
## Non-normative example

This example illustrates the current ASL-bound contract and is not a second instruction definition.

`TROWMAX <bundle operands>` snapshots the source and scans each valid row in increasing column order before atomically publishing the row result.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TROWMAX <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TROWMAX | TEPL | 0x041 | 1 | 2 | ExecuteTileReduction |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/row-reduction/TROWMAX.asl -->
```asl
readonly func InstructionContractOperation_TROWMAX() => TileOperation
begin
    return TileOperation_TROWMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TROWMAX, DataType
B.DATR Layout, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/row-reduction/TROWMAX.asl -->
```asl
pure func InstructionContractDataTypeLegal_TROWMAX(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TROWMAX(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileReduction(
        TileReduction_MAX,
        TileAxis_Row,
        destination,
        source);
end;

readonly func InstructionContractHandler_TROWMAX() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileReduction;
end;

func InstructionContractExecute_TROWMAX(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TROWMAX(
        destination,
        source);
    ExecuteTileReduction(
        TileReduction_MAX,
        TileAxis_Row,
        destination,
        source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- TROWMAX computes a typed increasing-column TMAX fold initialized from column zero; the scan order is architectural and tree reassociation is not permitted.

## Legality

- TROWMAX is selected by the TEPL raw encoding carrier Mode 2 Function 1; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent Local source and one newly allocated Local destination. B.IOR, B.IOS, a second B.IOT, or a nonterminating binding is illegal.
- The source DataType is exactly S32, U32, FP32, S16, U16, FP16, BF16, S8, or U8.
- The destination DataType equals the source DataType.
- The source is a fully defined numeric Tile in the selected RowMajor, CUBE_M16, or CUBE_M32 layout whose ValidRow, ValidCol, and physical Col exactly match the B.DIM-derived source geometry; every constrained floating encoding is valid. The reduction source allocated capacity is at most 2048 bytes and is checked before the source snapshot or destination allocation.
- The destination has ValidRow equal to source.ValidRow and logical ValidCol equal to one; its physical geometry is derived from the selected layout and capacity.
- Layout and PadValueOrByteId are the only applicable nonzero B.DATR fields. Source and destination share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.

## State effects

- For each valid row, compute a typed increasing-column TMAX fold initialized from column zero.
- Write the typed reduction value without widening integer arithmetic or reassociating the fold.
- Apply the selected PadValue to physical destination coordinates outside the valid result rectangle, then publish the complete result atomically.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, dimension, type, descriptor, source-definedness, source-encoding, mask, capacity, name-allocation, and storage preflight precedes the source snapshot.
- The source is scanned in strictly increasing column order; the source persists and is never modified.
- Numeric status, all valid results, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.

## Exceptions

- A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType, unsupported, mixed, or mismatched source layout, undefined source element, invalid source encoding, or mismatched source geometry raises Fault_TileLegality before effects.
- An unrepresentable result shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.
- Floating numeric status is accumulated across the architectural fold and publishes atomically with the result.

## Examples

- BSTART.SFU TROWMAX, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
