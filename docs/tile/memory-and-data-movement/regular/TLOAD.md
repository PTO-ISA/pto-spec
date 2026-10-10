<!-- GENERATED FROM: asl/tile/memory-and-data-movement/regular/TLOAD.asl -->
# TLOAD

**Normative ASL source:** `asl/tile/memory-and-data-movement/regular/TLOAD.asl`

Load one ordinary Local or Shared rectangle, or explicitly convert one GM rectangle into persistent Local CUBE storage.

## Normative identity {#PTO-INST-TILE-TLOAD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tload-purpose role=purpose -->
## What TLOAD does

`TLOAD` reads one typed rectangle from global memory (GM) into a Tile. It is TLSU Function 0, written `BSTART.TLOAD DataType`, and it has no standalone opcode.

The bundle schema selects one of four destination domains: an ordinary Local Tile, a Shared parent, a Local CUBE Tile, or a Shared convolution-weight view. They share the strided GM rectangle and differ in destination representation and padding rule.

<!-- PTO-READER-BLOCK: tile-tload-mechanism role=mechanism -->
## Addressing and access order

Each selected PE and valid coordinate uses the address `base + row * row_stride_bytes + column * element_size` built by `TileMemoryStridedByteAddress`. For the packed four-bit types the column contributes `floor(column / 2)` bytes and the nibble is chosen by column parity.

`B.IOR.RegSrc0` supplies the per-PE GM base and `B.IOR.RegSrc1` the byte row stride. An omitted `B.IOR` gives base zero and the dense stride `TileDenseRowStrideBytes(physical Col, data_type)`, that is `ceil(columns * element_bits / 8)`.

Design point: the dense default is omission-only. An explicitly encoded zero selector reads the zero GPR, so it is a real stride of zero and every row aliases row 0 in GM.

The model `TLOAD` probes, loads, and records one typed load event per element in row-major order, and stops at the first fault. Once every access succeeds the valid region is marked defined, and a CUBE destination then receives `CurrentBundlePadValue()` in its physical CELL tails.

Design point: unlike `MGATHER` and `MSCATTER`, `TLOAD` does not preflight the whole rectangle before its first load (NDF `PTO-TLOAD-MEMORY-001`), so a fault leaves a partially defined destination that is not published as complete.

<!-- PTO-READER-BLOCK: tile-tload-inputs-outputs role=inputs-outputs -->
## Operand roles and bindings

- `destination0` is the new Local destination or the absolute Shared destination.
- `address` is the per-PE private-GPR GM base address.
- `scalar0` is the per-PE private-GPR byte row stride in the ordinary and CUBE forms, and the packed ShapeGPR in weight mode.
- `scalar1` is the weight-mode packed StartGPR and does not apply to the other forms.

The completed block has exactly one destination domain: one terminating destination `B.IOT` for a Local destination, or one destination `B.IOS` for a Shared destination. It has no Tile source and consumes at most one `B.IOR`.

Design point: the destination domain is chosen by the binding kind, not by a data attribute, so one block cannot publish a Local Tile and a Shared parent together.

<!-- PTO-READER-BLOCK: tile-tload-effects role=effects -->
## Publication and partial results

A successful Local form allocates or renames one destination Tile, installs the derived descriptor, and defines the valid region. A singleton Shared issuer publishes the complete parent; several issuers must use `B.ASSEMBLE` with explicit writer ranges.

A CUBE form writes raw valid values through CUBE storage indices and applies `Zero`, `Max`, `Min`, or undefined `Null` to physical tails, which are not counted as valid elements. A fault stops the request at the first failing translation, permission, or alignment check, and completed reads may remain in a partially defined destination.

Design point: NDF `PTO-TLOAD-CUBE-001` applies the encoded `PadValue` only after all valid GM reads complete without a fault, so a faulting CUBE load leaves its physical tails undefined instead of padded.

<!-- PTO-READER-BLOCK: tile-tload-constraints role=constraints -->
## Types, shapes, and faults

`InstructionContractDataTypeLegal_TLOAD` accepts the codes that `TileRegularTLSUDataTypeSupported` admits, namely `0` through `14`, `16` through `20`, and `24` through `28`; codes `15`, `21` through `23`, and `29` through `31` reject before effects.

`ValidCol` and `ValidRow` are nonzero, `ValidCol` may not exceed the physical `Col`, and the derived `Rows` and `Col` are powers of two large enough to contain the valid rectangle. Ordinary and Shared forms permit only `Layout` as a nonzero attribute and require `PadValue` zero; the Local CUBE layouts require `DTYPE_NONE` and accept all four `PadValue` encodings. Weight mode is explicit-only and carries GMBase, ShapeGPR, and StartGPR in one `B.IOR`.

`PE_MASK=0000` is a strict no-op on the Local path, which returns before the operand schema, GPR reads, destination allocation, and GM access, and on the Shared path, which returns as soon as the shared binding mask is zero.

Design point: CUBE forms require explicit nonzero `LB0` and `LB1` and an absent `LB2` (`InstructionContractCubeDimensionsLegal_TLOAD`), because CELL geometry comes from the layout, the data type, and the valid shape rather than from a physical column count.

<!-- PTO-READER-BLOCK: tile-tload-example role=example -->
## Non-normative contract sketch

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

Take `U8`, `Col=64`, `ValidCol=64`, and `ValidRow=8`, with `a0` holding the GM base and `a1` holding the byte row stride `64`.

- The canonical macro spelling is `TLOAD <Row=8, Col=64, U8>, [base=a0, stride=a1], ->T<512B>`, a 512-byte destination holding 8 rows of 64 elements.
- Omitting the `B.IOR` derives the dense stride `64`; encoding `a1` as zero instead makes every row read the same 64 GM bytes.
- The destination is published only when all `512` element loads and their load events complete without a fault.
<!-- SUPPLEMENTARY-END -->

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
| scalar0 | ordinary per-PE private-GPR byte row stride or weight-mode packed ShapeGPR |
| scalar1 | weight-mode packed StartGPR; inapplicable to ordinary and CUBE forms |

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
Shared: replace B.IOT with one destination B.IOS carrying absolute S0..S63, SizeCode, and PE_MASK. One issuer loads the complete parent; multiple issuers require B.ASSEMBLE with explicit writer ranges.
Weight Shared: B.DATR OHWI2NK/OIHW2NK selects the convolution-weight transformation; LB0/LB1/LB2 are ValidK/ValidN/TotalK and one B.IOR carries GMBase, ShapeGPR, StartGPR.
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
- Weight mode is explicit-only and uses DTYPE_NONE with Zero/EQ/Default/0/0 controls; the destination view is row-major NK with K contiguous.

## Legality

- TLOAD is selected only by TLSU Function 0 through BSTART.TLOAD; it has no standalone opcode.
- The completed block has exactly one destination domain: one terminating destination B.IOT for Local or one destination B.IOS for Shared. It has no Tile source and consumes at most one B.IOR.
- The BSTART DataType accepts every assigned Tile DataType code and rejects 15, 21..23, and 29..31 before effects. Ordinary and Shared forms permit only Layout and require PadValue zero; Local CUBE codes 21 through 23 additionally permit all four PadValue encodings and require DTYPE_NONE while CMode, RMode, Sat, and Canonicalize retain zero meanings.
- ValidCol and ValidRow are nonzero, ValidCol does not exceed physical Col, and the derived Rows and Col are powers of two large enough for the valid rectangle.
- PE_MASK=0000 is a strict no-op before GPR reads, allocation, memory access, faults, load events, descriptor changes, or payload changes.
- Ordinary forms require nonzero ValidCol and ValidRow, ValidCol not greater than physical Col, and power-of-two physical Rows and Col. CUBE forms require explicit nonzero LB0/LB1, absent LB2, and derive CELL geometry from Layout, dtype, and valid shape.
- Weight layouts 10 and 11 are accepted only by the specialized BSTART.TLOAD weight Shared schema; reserved KN codes 12 and 13 are not implemented. The exact three-source B.IOR, packed-field reservations, K/C0 alignment, row-major NK shape, and selected-PE equality checks are mandatory.
- The existing explicit ND2M32/M322ND Local conversion forms admit FP64, S64 and U64 with 256 physical bytes per column under issue #371; ordinary and Shared form layout rules remain owned separately.

## State effects

- A successful Local form allocates or renames exactly one destination Tile, installs the derived descriptor, loads every selected valid element, and marks the valid region defined.
- A successful singleton Shared form loads and publishes the complete parent from that issuer PE. A multi-PE Shared form uses B.ASSEMBLE explicit ranges; TLOAD never modifies source GPRs or GM.
- A successful CUBE form writes raw valid values through CUBE storage indices and applies Zero, Max, Min, or undefined Null to physical tail positions without counting tails as valid elements.
- Weight mode reuses the existing Shared row-major descriptor and B.ASSEMBLE generation protocol; ordinary TLOAD semantics are unchanged.

## Memory effects and ordering

### Memory effects

- For each selected PE and each element in ValidRow x ValidCol, read GM at base + row * row_stride_bytes + column * element_size. Packed four-bit types add floor(column / 2) to each byte-strided row base and select the nibble from column parity.
- The accesses participate in PTO-RC using the block aq/rl attributes; the request reports the first fault and may retain effects completed before it.
- Weight mode reads dense OHWI/OIHW source elements in canonical [kh][kw][c1][c0] order, supplies defined raw-zero Cin padding, and atomically publishes the Shared generation after complete preflight.

### Ordering

- Resolve the complete schema, selected PE mask, per-PE GPR inputs, dimensions, and destination capacity before the first architectural load effect; translate and access each element until the first fault.
- On success publish the complete Local destination or complete Shared parent at block commit. A fault may leave a partially defined Local destination or Shared generation, which is not advertised as complete or whole-parent-ready.

## Exceptions

- Reserved DataType, unsupported or wrong-direction Layout, operation-inapplicable PadValue, malformed B.IOR/B.IOT/B.IOS schema, invalid dimensions, capacity or shape overflow, allocation failure, or GM translation, permission, or alignment fault rejects before destination publication.
- The request stops at the first memory fault; reads and load events completed before that fault may remain in a partially defined Local destination or Shared generation. A partial result is not complete or whole-parent-ready.

## Examples

- BSTART.TLOAD U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR zero, a0; B.IOT mask=1111, ->T<1>; BSTOP
- BSTART.TLOAD FP16; B.DIM LB0, 32; B.DIM LB1, 4; B.IOS mask=0001, ->S7<1>; BSTOP
- BSTART.TLOAD FP16; B.DATR {ND2N8, DTYPE_NONE, Max, EQ, Default, 0, 0}; B.DIM LB0=N; B.DIM LB1=K; B.IOT mask=1111, <last>, ->N<3>; BSTOP
- BSTART.TLOAD FP16; B.DATR {OIHW2NK, DTYPE_NONE, Zero, EQ, Default, 0, 0}; B.DIM LB0=ValidK; B.DIM LB1=ValidN; B.DIM LB2=TotalK; B.IOR GMBase, ShapeGPR, StartGPR, ->zero; B.IOS mask, ->S0<SizeCode>; BSTOP
