<!-- GENERATED FROM: asl/tile/reduce-and-expand/column-reduction/TCOLSUM.asl -->
# TCOLSUM

**Normative ASL source:** `asl/tile/reduce-and-expand/column-reduction/TCOLSUM.asl`

Reduce each valid column to its sum with exact typed row-order semantics.

## Normative identity {#PTO-INST-TILE-TCOLSUM}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TCOLSUM <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCOLSUM | TEPL | 0x050 | 16 | 2 | ExecuteTileReduction |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/column-reduction/TCOLSUM.asl -->
```asl
readonly func InstructionContractOperation_TCOLSUM() => TileOperation
begin
    return TileOperation_TCOLSUM;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TCOLSUM, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/column-reduction/TCOLSUM.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCOLSUM(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCOLSUM(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileReduction(
        TileReduction_SUM,
        TileAxis_Column,
        destination,
        source);
end;

readonly func InstructionContractHandler_TCOLSUM() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileReduction;
end;

func InstructionContractExecute_TCOLSUM(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TCOLSUM(
        destination,
        source);
    ExecuteTileReduction(
        TileReduction_SUM,
        TileAxis_Column,
        destination,
        source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- TCOLSUM computes a typed increasing-row left fold from zero using TADD; the scan order is architectural and tree reassociation is not permitted.

## Legality

- TCOLSUM is selected by the TEPL raw encoding carrier Mode 2 Function 16; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent Local source and one newly allocated Local destination. B.IOR, B.IOS, a second B.IOT, or a nonterminating binding is illegal.
- The source DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
- The destination DataType equals the source DataType.
- The source is a fully defined row-major numeric Tile whose ValidRow, ValidCol, and physical Col exactly match the B.DIM-derived source geometry; every constrained floating encoding is valid.
- The destination has ValidRow equal to one, ValidCol equal to source.ValidCol, physical Col equal to source.Col, and capacity-derived physical Rows.
- PadValueOrByteId is the only applicable B.DATR field. Source and destination share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.

## State effects

- For each valid column, compute a typed increasing-row left fold from zero using TADD.
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

- A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType, non-row-major source, undefined source element, invalid source encoding, or mismatched source geometry raises Fault_TileLegality before effects.
- An unrepresentable result shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.
- Floating numeric status is accumulated across the architectural fold and publishes atomically with the result.

## Examples

- BSTART.SFU TCOLSUM, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
