<!-- GENERATED FROM: asl/tile/memory-and-data-movement/regular/TLOAD.asl -->
# TLOAD

**Normative ASL source:** `asl/tile/memory-and-data-movement/regular/TLOAD.asl`

Load one ordinary Local or Shared rectangle, or explicitly convert one GM rectangle into persistent Local CUBE storage.

## Normative identity {#PTO-INST-TILE-TLOAD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
TLOAD <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TLOAD | TLSU |  | 0 |  | TLOAD |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination or absolute Shared destination |
| address | per-PE private-GPR GM base address |
| scalar0 | per-PE private-GPR byte row stride |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/regular/TLOAD.asl -->
```asl
readonly func InstructionContractOperation_TLOAD() => TileOperation
begin
    return TileOperation_TLOAD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Local: BSTART.TLOAD DataType; optional B.DATR Layout; B.DIM defines ValidCol, ValidRow, and physical Col; optional B.IOR defines the per-PE GM base and byte row stride; one terminating destination B.IOT allocates the result; BSTOP commits.
Shared: replace B.IOT with one destination B.IOS carrying absolute S0..S255, per-PE TSize, and PE_MASK. Local sources, Shared sources, multiple destinations, and mixed destination domains are illegal.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/regular/TLOAD.asl -->
```asl
pure func InstructionContractDataTypeLegal_TLOAD(code: bits(5)) => boolean
begin
    if !TileDataTypeEncodingValid(code as TileDataTypeEncoding) then
        return FALSE;
    end;
    let data_type = TileDataTypeFromEncoding(code as TileDataTypeEncoding);
    return TileRegularTLSUDataTypeSupported(data_type);
end;

readonly func InstructionContractDestinationShapeLegal_TLOAD(
    size_code: integer {1..12}, columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType) => boolean
begin
    return TileDescriptorShapeLegal(TileSizeCodeBytes(size_code), columns,
        valid_rows, valid_columns, data_type);
end;

readonly func InstructionContractHandler_TLOAD() => TileSemanticHandler
begin
    return TileHandler_TLOAD;
end;

readonly func InstructionContractGMAddress_TLOAD(
    base_address: Word, row: integer {0..65535},
    column: integer {0..65535}, row_stride_bytes: Word,
    data_type: TileDataType) => Word
begin
    return TileMemoryStridedByteAddress(
        base_address, row, column, row_stride_bytes, data_type);
end;

readonly func InstructionContractDenseStride_TLOAD(
    columns: integer {0..65535}, data_type: TileDataType) => Word
begin
    return TileDenseRowStrideBytes(columns, data_type);
end;

pure func InstructionContractZeroMaskNoEffect_TLOAD(
    pe_mask: bits(4)) => boolean
begin
    return pe_mask == Zeros{4};
end;

pure func InstructionContractCubeDimensionsLegal_TLOAD(
    lb0_present: boolean, lb0: integer {0..65535},
    lb1_present: boolean, lb1: integer {0..65535},
    lb2_present: boolean) => boolean
begin
    return lb0_present && lb0 != 0 &&
           lb1_present && lb1 != 0 && !lb2_present;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is explicit in BSTART.TLOAD. Omitted B.DATR selects ordinary NORM layout. Explicit CUBE Layout 21 through 23 requires DTYPE_NONE and consumes PadValue for physical CELL tails.
- LB0/ValidCol and LB1/ValidRow default through the common destination-shape rules. Omitted LB2/Col defaults to ValidCol. Rows are derived from TSize, Col, and DataType and must contain ValidRow.
- Omitted B.IOR supplies base zero. Ordinary forms use resolved Col and CUBE forms use LB0 valid columns to derive dense byte row stride as ceil(columns * element_bits / 8). An encoded zero GPR selector is present and reads zero, so an explicitly encoded zero stride aliases rows rather than selecting the omission default.

## Legality

- TLOAD is selected only by TLSU Function 0 through BSTART.TLOAD; it has no standalone opcode.
- The completed block has exactly one destination domain: one terminating destination B.IOT for Local or one destination B.IOS for Shared. It has no Tile source and consumes at most one B.IOR.
- The BSTART DataType accepts every assigned Tile DataType code and rejects 15, 21..23, and 29..31 before effects. Ordinary and Shared forms permit only Layout and require PadValue zero; Local CUBE codes 21 through 23 additionally permit all four PadValue encodings and require DTYPE_NONE while CMode, RMode, Sat, and Canonicalize retain zero meanings.
- ValidCol and ValidRow are nonzero, ValidCol does not exceed physical Col, and the derived Rows and Col are powers of two large enough for the valid rectangle.
- PE_MASK=0000 is a strict no-op before GPR reads, allocation, memory access, faults, load events, descriptor changes, or payload changes.
- Ordinary forms require nonzero ValidCol and ValidRow, ValidCol not greater than physical Col, and power-of-two physical Rows and Col. CUBE forms require explicit nonzero LB0/LB1, absent LB2, and derive CELL geometry from Layout, dtype, and valid shape.

## State effects

- A successful Local form allocates or renames exactly one destination Tile, installs the derived descriptor, loads every selected valid element, and marks the valid region defined.
- A successful Shared form reallocates the named S register when required and updates only the quarters selected by PE_MASK. TLOAD does not modify source GPRs or GM.
- A successful CUBE form writes raw valid values through CUBE storage indices and applies Zero, Max, Min, or undefined Null to physical tail positions without counting tails as valid elements.

## Memory effects and ordering

### Memory effects

- For each selected PE and each element in ValidRow x ValidCol, read GM at base + row * row_stride_bytes + column * element_size. Packed four-bit types add floor(column / 2) to each byte-strided row base and select the nibble from column parity.
- The accesses participate in PTO-TSO using the block aq/rl attributes and are precise and restartable.

### Ordering

- Resolve the complete schema, selected PE mask, per-PE GPR inputs, dimensions, destination capacity, and all memory translations before the first architectural load effect.
- On success publish the complete Local destination or the selected Shared quarters atomically at block commit. Unselected Shared quarters remain unchanged; on failure the prior destination and restart-visible block state are preserved.

## Exceptions

- Reserved DataType, unsupported or wrong-direction Layout, operation-inapplicable PadValue, malformed B.IOR/B.IOT/B.IOS schema, invalid dimensions, capacity or shape overflow, allocation failure, or GM translation, permission, or alignment fault rejects before destination publication.
- Every selected memory address is preflighted before any destination payload, descriptor, allocation, definedness, or load event becomes visible. A failed Local allocation is rolled back; a failed Shared update preserves the prior Shared record.

## Examples

- BSTART.TLOAD U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR zero, a0; B.IOT mask=1111, ->T<1>; BSTOP
- BSTART.TLOAD FP16; B.DIM LB0, 32; B.DIM LB1, 4; B.IOS mask=0011, ->S7<1>; BSTOP
- BSTART.TLOAD FP16; B.DATR {ND2N8, DTYPE_NONE, Max, EQ, Default, 0, 0}; B.DIM LB0=N; B.DIM LB1=K; B.IOT mask=1111, <last>, ->N<3>; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->
Both Local (`B.IOT`) and Shared (`B.IOS`) destination forms use LB0 as valid
columns, LB1 as valid rows, and LB2 as physical Col. The embedded shape helper
checks the same per-PE TSize/Col/dtype derivation for both forms before memory
probing. An explicit B.IOR supplies base and row stride; omission uses base zero
and LB2 as the dense row stride, while an encoded zero stride remains zero.
<!-- SUPPLEMENTARY-END -->
