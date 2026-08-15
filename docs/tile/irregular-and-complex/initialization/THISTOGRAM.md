<!-- GENERATED FROM: asl/tile/irregular-and-complex/initialization/THISTOGRAM.asl -->
# THISTOGRAM

**Normative ASL source:** `asl/tile/irregular-and-complex/initialization/THISTOGRAM.asl`

Build one inclusive 256-bin U32 prefix histogram per source row after the ByteId-specific filter.

## Normative identity {#PTO-INST-TILE-THISTOGRAM}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
THISTOGRAM <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| THISTOGRAM | TEPL | 0x068 | 8 | 3 | THISTOGRAM |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### BSTART.DataType (`PTO-FIELD-BLOCK-DATATYPE`)

Selects the Tile element data type carried by Block data attributes and typed Block starts.

**Encoded zero:** Code zero selects FP64; zero never means absent, inherited, NONE, or NULL.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | FP64 |
| 1 | assigned | FP32 |
| 2 | assigned | TF32 |
| 3 | assigned | HF32 |
| 4 | assigned | FP16 |
| 5 | assigned | BF16 |
| 6 | assigned | HiF8 |
| 7 | assigned | E4M3 |
| 8 | assigned | E5M2 |
| 9 | assigned | E3M2 |
| 10 | assigned | E2M3 |
| 11 | assigned | E2M1X2 |
| 12 | assigned | E1M2X2 |
| 13 | assigned | E8M0 |
| 14 | assigned | HiF4X2 |
| 15 | reserved | future extension |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | reserved | future extension |
| 22 | reserved | future extension |
| 23 | reserved | future extension |
| 24 | assigned | U64 |
| 25 | assigned | U32 |
| 26 | assigned | U16 |
| 27 | assigned | U8 |
| 28 | assigned | U4X2 |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Reserved values are held for future extension and reject before architectural effects.

### B.DATR.DataType (`PTO-FIELD-BLOCK-DATATYPE`)

Selects the Tile element data type carried by Block data attributes and typed Block starts.

**Encoded zero:** Code zero selects FP64; zero never means absent, inherited, NONE, or NULL.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | FP64 |
| 1 | assigned | FP32 |
| 2 | assigned | TF32 |
| 3 | assigned | HF32 |
| 4 | assigned | FP16 |
| 5 | assigned | BF16 |
| 6 | assigned | HiF8 |
| 7 | assigned | E4M3 |
| 8 | assigned | E5M2 |
| 9 | assigned | E3M2 |
| 10 | assigned | E2M3 |
| 11 | assigned | E2M1X2 |
| 12 | assigned | E1M2X2 |
| 13 | assigned | E8M0 |
| 14 | assigned | HiF4X2 |
| 15 | reserved | future extension |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | reserved | future extension |
| 22 | reserved | future extension |
| 23 | reserved | future extension |
| 24 | assigned | U64 |
| 25 | assigned | U32 |
| 26 | assigned | U16 |
| 27 | assigned | U8 |
| 28 | assigned | U4X2 |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Reserved values are held for future extension and reject before architectural effects.

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
| destination0 | new Local U32 prefix-histogram destination |
| source0 | persistent Local U16 or U32 source |
| source1 | persistent Local U8 prefix filter |
| selected_byte | B.DATR ByteId zero through three |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/initialization/THISTOGRAM.asl -->
```asl
readonly func InstructionContractOperation_THISTOGRAM() => TileOperation
begin
    return TileOperation_THISTOGRAM;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU THISTOGRAM, U16|U32
B.DATR DstDataType=U32, ByteId=0..3 (mandatory)
B.IOT SourceTile, FilterTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/initialization/THISTOGRAM.asl -->
```asl
pure func InstructionContractSourceDataTypeLegal_THISTOGRAM(
    data_type: TileDataType) => boolean
begin
    return TileHistogramSourceDataTypeSupported(data_type);
end;

pure func InstructionContractSelectedByteLegal_THISTOGRAM(
    data_type: TileDataType,
    selected_byte: integer {0..3}) => boolean
begin
    return TileHistogramSelectedByteSupported(
        data_type,
        selected_byte);
end;

readonly func InstructionContractOperandsLegal_THISTOGRAM(
    destination: TileIndex,
    source: TileIndex,
    filter: TileIndex,
    selected_byte: integer {0..3}) => boolean
begin
    return TileOperandsLegal_THISTOGRAM(
        destination,
        source,
        filter,
        selected_byte);
end;

readonly func InstructionContractHandler_THISTOGRAM() => TileSemanticHandler
begin
    return TileHandler_THISTOGRAM;
end;

func InstructionContractExecute_THISTOGRAM(
    destination: TileIndex,
    source: TileIndex,
    filter: TileIndex,
    selected_byte: integer {0..3})
begin
    assert InstructionContractOperandsLegal_THISTOGRAM(
        destination,
        source,
        filter,
        selected_byte);
    THISTOGRAM(
        destination,
        source,
        filter,
        selected_byte);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- BSTART explicitly selects source DataType U16 or U32. B.DATR is mandatory: its secondary DataType must be U32 and PadValueOrByteId supplies ByteId 0 through 3.
- No B.IOR or B.DIM is permitted. Exactly one terminating Local B.IOT supplies source, filter, and a newly allocated destination.
- The filter binding is structurally mandatory. U16 ByteId1 and U32 ByteId3 are unfiltered and do not read filter shape, payload, or definedness.
- Physical destination padding is always Null.

## Legality

- THISTOGRAM is selected by the TEPL encoding carrier Mode 3 Function 8, is canonically assembled with BSTART.SFU, and has no standalone opcode.
- The source is a fully defined row-major numeric Local U16 or U32 Tile. The filter is a numeric Local U8 Tile whose logical layout is honored.
- The newly allocated destination is row-major U32 with ValidRow equal to source ValidRow, ValidCol exactly 256, physical Row at least ValidRow, physical Col at least 256, and sufficient capacity.
- For U16, ByteId0 requires one defined filter element at logical [row,0] for every source row; ByteId1 is unfiltered. ByteId2 and ByteId3 are illegal.
- For U32, ByteId2, ByteId1, and ByteId0 require respectively one, two, and three defined global prefix bytes at filter logical [0,0], [1,0], and [2,0]; ByteId3 is unfiltered.
- The destination must be distinct from source and filter. Source and filter persist.

## State effects

- For each source row, consider only values passing the selected ByteId filter and count the selected source byte into 256 bins.
- U16 ByteId0 matches the source high byte against filter[row,0] and histograms the low byte; U16 ByteId1 histograms the high byte without reading filter data.
- U32 ByteId2, ByteId1, and ByteId0 match the more-significant one, two, or three bytes against the global filter prefix before histogramming the selected byte; ByteId3 is unfiltered.
- Destination element [row,bin] is the inclusive cumulative count from bin zero through bin. Every physical coordinate outside the valid rectangle is undefined Null padding.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, mask, type, descriptor, consumed-definedness, shape, capacity, destination-name, and allocation preflight precedes every snapshot and effect.
- The complete source and consumed filter payloads are snapshotted before histogram evaluation. The U32 payload, Null padding definedness, and destination descriptor publish atomically; rejection publishes none.

## Exceptions

- Malformed bindings, B.IOR, B.IOS, B.DIM, omitted B.DATR, unsupported source or destination DataType, illegal ByteId for U16, descriptor mismatch, undefined consumed source or filter data, shape mismatch, capacity failure, or allocation failure raises the applicable Tile fault before effects.
- U16 ByteId2 and ByteId3 are reserved for this operation and raise Fault_TileLegality before allocation or payload effects.
- PE_MASK zero completes as a strict no-op before schema, descriptor, filter, allocation, fault, or payload checks.

## Examples

- BSTART.SFU THISTOGRAM, U16; B.DATR U32, ByteId=0; B.IOT T0, T1, mask=1111, <last>, ->T2<4>; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
