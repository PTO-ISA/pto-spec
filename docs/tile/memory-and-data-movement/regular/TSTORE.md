<!-- GENERATED FROM: asl/tile/memory-and-data-movement/regular/TSTORE.asl -->
# TSTORE

**Normative ASL source:** `asl/tile/memory-and-data-movement/regular/TSTORE.asl`

Store one Local or Shared Tile valid rectangle to GM with per-PE bases and logical row strides after full-footprint preflight.

## Normative identity {#PTO-INST-TILE-TSTORE}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
TSTORE <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSTORE | TLSU |  | 1 |  | TSTORE |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### DataType (`PTO-FIELD-BLOCK-DATATYPE`)

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

## Operands and results

| Field | Architectural role |
| --- | --- |
| source0 | Local Tile or absolute Shared S0..S255 source |
| address | per-PE private-GPR GM base address |
| scalar0 | per-PE private-GPR logical row stride in elements |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/regular/TSTORE.asl -->
```asl
readonly func InstructionContractOperation_TSTORE() => TileOperation
begin
    return TileOperation_TSTORE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
The Local form uses TLSU Function 1, exactly one terminating source B.IOT, at most one B.IOR, and no B.IOS.
The Shared full form uses TLSU Function 1, exactly one source B.IOS, at most one B.IOR, no B.IOT, and PE_MASK=1111 for every nonzero access.
The Shared partial form uses TLSU Function 14 (TSTORE.SPART), exactly one source B.IOS, at most one B.IOR, no B.IOT, and any nonzero PE subset.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/regular/TSTORE.asl -->
```asl
pure func InstructionContractDataTypeLegal_TSTORE(code: bits(5)) => boolean
begin
    return TileDataTypeEncodingValid(code as TileDataTypeEncoding);
end;

readonly func InstructionContractHandler_TSTORE() => TileSemanticHandler
begin
    return TileHandler_TSTORE;
end;

readonly func InstructionContractGMAddress_TSTORE(
    base_address: Word,
    row: integer {0..65535},
    column: integer {0..65535},
    row_stride_elements: Word,
    data_type: TileDataType) => Word
begin
    let logical_index = TileMemoryStridedIndex(
        row,
        column,
        row_stride_elements);
    return TileMemoryIndexedAddress(
        base_address,
        logical_index,
        data_type);
end;

readonly func InstructionContractDenseStride_TSTORE(
    columns: integer {0..262144}) => Word
begin
    return NaturalToWord(columns);
end;

pure func InstructionContractSharedMaskLegal_TSTORE(
    function: integer {0..31}, pe_mask: bits(4)) => boolean
begin
    return SharedStorePEMaskLegal(function, pe_mask);
end;

pure func InstructionContractZeroMaskNoEffect_TSTORE(
    pe_mask: bits(4)) => boolean
begin
    return pe_mask == Zeros{4};
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is explicit in BSTART.TSTORE. Omitted B.DATR selects NORM layout; every other nonzero B.DATR field is illegal.
- For an allocated source, omitted LB0, LB1, and LB2 inherit ValidCol, ValidRow, and physical Col from its descriptor. For an unallocated Shared source they default to 1, 1, and ValidCol.
- An unallocated Shared source derives the smallest legal 128 B through 8 KiB per-PE capacity containing the completed shape. The temporary descriptor supplies undefined-register values and is never written back.
- Omitted B.IOR supplies base zero and dense logical-element row stride equal to resolved Col. An encoded zero selector is present and supplies the real zero GPR value, so an explicitly encoded zero stride aliases rows.

## Legality

- TSTORE is selected only by BSTART.TSTORE/TLSU Function 1 or the Function 14 TSTORE.SPART variant and has no standalone opcode.
- DataType accepts 0..14, 16..20, and 24..28; codes 15, 21..23, and 29..31 are reserved and reject before effects.
- The completed block has exactly one source domain. Function 1 accepts one Local B.IOT or one Shared B.IOS; Function 14 accepts only one Shared B.IOS. Source/destination role mismatches and mixed domains are illegal.
- A nonzero Function 1 Shared store requires PE_MASK=1111. Function 14 accepts every nonzero subset. PE_MASK=0000 is a strict no-op.
- ValidCol and ValidRow are nonzero, ValidCol does not exceed physical Col, and the valid rectangle fits the persistent source descriptor or the derived temporary Shared descriptor.

## State effects

- Read one Local or Shared source without modifying its payload, descriptor, allocation mask, initialized mask, or lifetime.
- A Shared undefined-source read remains non-allocating and non-mutating. On success only GM and memory-event state change; normal block completion consumes the source binding, not the Tile value.

## Memory effects and ordering

### Memory effects

- For every selected PE and each element in ValidRow x ValidCol, write GM at base + ((row * row_stride_elements + column) * element_size). Packed four-bit formats apply the logical element index before selecting the addressed nibble.
- The complete selected-PE footprint is translated and permission-checked before the first GM write. A fault therefore produces no partial GM or memory-event effect.

### Ordering

- Snapshot the source payload, resolve the complete schema and dimensions, validate the source descriptor or temporary descriptor, and preflight every selected GM access before storing any element.
- After successful preflight, store beats have no architecture-defined relative order. Software avoids overlapping selected-PE GM regions or establishes ordering separately.

## Exceptions

- Reserved DataType, unsupported Layout, invalid dimensions, source descriptor mismatch, malformed bindings, illegal PE mask, or GM translation, permission, or alignment fault raises Illegal Block Exception or the applicable data fault before the first GM write.
- An unallocated or selected-quarter-uninitialized Shared source is not an exception; it reads as an undefined register through a non-mutating operation-derived descriptor.

## Examples

- BSTART.TSTORE U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR a0, a1; B.IOT T1, mask=1111, last; BSTOP
- BSTART.TSTORE FP16; B.IOS S7, mask=1111; BSTOP
- BSTART.TSTORE FP16 using Function 14; B.IOS S7, mask=0011; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
