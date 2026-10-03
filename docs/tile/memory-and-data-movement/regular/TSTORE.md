<!-- GENERATED FROM: asl/tile/memory-and-data-movement/regular/TSTORE.asl -->
# TSTORE

**Normative ASL source:** `asl/tile/memory-and-data-movement/regular/TSTORE.asl`

Store one ordinary Local or Shared rectangle, or explicitly convert persistent Local CUBE storage into one GM rectangle.

## Normative identity {#PTO-INST-TILE-TSTORE}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tstore-purpose role=purpose -->
## What TSTORE does

`TSTORE` writes one Tile rectangle to global memory (GM). It is TLSU Function 1, written `BSTART.TSTORE DataType`, and it has no standalone opcode.

The completed block has exactly one source domain. A Local source arrives through one terminating source `B.IOT`; a Shared source arrives through one source `B.IOS` and must already be published and whole-parent-ready. A Local CUBE form stores a persistent CUBE descriptor through `M322ND`, `M162ND`, or `N82ND`.

<!-- PTO-READER-BLOCK: tile-c-tstore-mechanism role=mechanism -->
## Addressing and access order

Each selected PE and each active valid coordinate is written at `base + row * row_stride_bytes + column * element_size` through `TileMemoryStridedByteAddress`. For the packed four-bit types the column contributes `floor(column / 2)` bytes and the low or high nibble is chosen by column parity.

`B.IOR.RegSrc0` supplies the per-PE GM base and `B.IOR.RegSrc1` the byte row stride. An omitted `B.IOR` gives base zero and the dense stride derived from the resolved physical `Col` and the data type, that is `ceil(columns * element_bits / 8)`; an explicitly encoded zero selector is a real stride of zero.

Design point: the dense default is omission-only. Because an encoded zero reads the zero GPR, a program that encodes zero stride aliases every row onto row 0 in GM instead of getting the dense layout.

The model `TSTORE` probes, stores, and records one typed store event per active element in row-major order, and stops at the first memory fault. Under a predicate-Tile ExecutionMask only the active coordinates are stored, so inactive coordinates produce no probe and no event.

Design point: a four-bit store is a read-modify-write of the containing GM byte. The ASL loads that byte, replaces only the selected nibble, and stores it back, so the neighbouring nibble always survives.

<!-- PTO-READER-BLOCK: tile-c-tstore-inputs-outputs role=inputs-outputs -->
## Operand roles, shape, and type

- `source0` is a Local Tile or the absolute Shared source S0 through S63. Its payload, descriptor, producer mask, readiness, and lifetime are left unchanged, and the binding is consumed by normal block completion.
- `address` is the per-PE private-GPR GM base address.
- `scalar0` is the per-PE private-GPR byte row stride.

`LB0`, `LB1`, and `LB2` each have effective value one when omitted, and the resolved dimensions are checked against the source descriptor rather than inherited from it. A Shared source selects its consumer PEs through a nonzero `PE_MASK`, and `B.SUBVIEW` is the only partial-source range mechanism.

Design point: an unpublished, pending, or incomplete Shared source makes the block wait without raising a fault and without any GM, binding-consumption, or descriptor effect, so a consumer cannot observe a half-written Shared parent.

<!-- PTO-READER-BLOCK: tile-c-tstore-effects role=effects -->
## Definedness, padding, and publication

The source payload and descriptor persist after success and after rejection; `TSTORE` allocates no destination and publishes no Tile state. Only GM and the memory-event stream change.

A memory translation, permission, or alignment fault stops the request at the first fault, and the GM writes and memory events completed before it may remain visible in GM and in the event stream.

Design point: once every requested store completes without a fault, store beats have no architecture-defined relative order. Two selected PEs that write the same GM bytes therefore need software to avoid the overlap or to establish order separately.

<!-- PTO-READER-BLOCK: tile-c-tstore-constraints role=constraints -->
## Legality, fault, and order boundaries

`InstructionContractDataTypeLegal_TSTORE` accepts the codes that `TileRegularTLSUDataTypeSupported` admits, namely `0` through `14`, `16` through `20`, and `24` through `28`; the remaining codes are reserved and reject before effects.

`ValidCol` and `ValidRow` are nonzero, `ValidCol` may not exceed the physical `Col`, and the resolved valid rectangle must fit the persistent source descriptor. Ordinary and Shared forms require `PadValue` zero; the Local CUBE codes `24` through `26` require `DTYPE_NONE`, accept all four `PadValue` encodings, and store only valid elements while ignoring physical padding.

A malformed binding stream, missing dimensions, an unsupported `DataType`, a non-row-major source, an undefined Local source element, an invalid source encoding, or mismatched source geometry raises `Fault_TileLegality` before effects.

`PE_MASK=0000` is a strict no-op in both destination domains: a zero `B.IOT` mask leaves the block without effect, and a zero `B.IOS` mask returns before schema, descriptor, GPR, memory, fault, and source-consumption effects.

Design point: `SharedStorePEMaskLegal` accepts any nonzero mask for Function 1 and rejects a nonzero mask for every other function, so a `B.IOS` store can never silently infer quarter selection from the mask.

<!-- PTO-READER-BLOCK: tile-c-tstore-example role=example -->
## Non-normative example

This example illustrates the current ASL-bound contract and is not a second instruction definition.

Take `U8`, a Local source `T#1` with `Col=64`, `ValidCol=64`, and `ValidRow=8`, and a per-PE byte row stride of `64` in `a1` with the GM base in `a0`.

- The canonical macro spelling is `TSTORE <Row=8, Col=64, ValidRow=8, ValidCol=64, U8>, T#1, [base=a0, stride=a1]`, which writes `8 * 64 = 512` GM bytes per selected PE.
- If `a1` holds `0`, all eight rows write the same 64 GM bytes, and the final content of those bytes is not architecture-defined.
- A fault at the third row leaves the first two rows stored and visible; the source Tile is unchanged.
<!-- SUPPLEMENTARY-END -->

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
| 15 | assigned | E6M2 |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | assigned | RCPE6M2 |
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
| source0 | Local Tile or absolute Shared S0..S63 source |
| address | per-PE private-GPR GM base address |
| scalar0 | per-PE private-GPR byte row stride |

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
The Shared form uses canonical TLSU Function 1, exactly one source B.IOS, at most one B.IOR, no B.IOT, and any nonzero consumer PE_MASK; optional B.SUBVIEW supplies the only partial-source range.
The Local CUBE form uses Function 1, explicit B.DATR M322ND, M162ND, or N82ND with DTYPE_NONE, explicit LB0/LB1, absent LB2, and one persistent source B.IOT.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/regular/TSTORE.asl -->
```asl
pure func InstructionContractDataTypeLegal_TSTORE(code: bits(5)) => boolean
begin
    if !TileDataTypeEncodingValid(code as TileDataTypeEncoding) then
        return FALSE;
    end;
    let data_type = TileDataTypeFromEncoding(code as TileDataTypeEncoding);
    return TileRegularTLSUDataTypeSupported(data_type);
end;

readonly func InstructionContractHandler_TSTORE() => TileSemanticHandler
begin
    return TileHandler_TSTORE;
end;

readonly func InstructionContractGMAddress_TSTORE(
    base_address: Word,
    row: integer {0..65535},
    column: integer {0..65535},
    row_stride_bytes: Word,
    data_type: TileDataType) => Word
begin
    return TileMemoryStridedByteAddress(
        base_address, row, column, row_stride_bytes, data_type);
end;

readonly func InstructionContractDenseStride_TSTORE(
    columns: integer {0..65535}, data_type: TileDataType) => Word
begin
    return TileDenseRowStrideBytes(columns, data_type);
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

pure func InstructionContractCubeDimensionsLegal_TSTORE(
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

- DataType is explicit in BSTART.TSTORE. Omitted B.DATR selects ordinary NORM layout. Ordinary and Shared forms require PadValue zero; Local CUBE codes 24 through 26 require DTYPE_NONE, accept all four PadValue encodings, and ignore physical padding while storing only valid elements.
- Omitted LB0, LB1, and LB2 each have effective value one. The resolved dimensions are checked against the source descriptor; omission does not inherit its shape.
- An unallocated, pending, or incomplete Shared source remains waiting and produces no GM, binding-consumption, or descriptor effect.
- Omitted B.IOR supplies base zero. Ordinary forms use resolved Col and CUBE forms use LB0 valid columns to derive dense byte row stride as ceil(columns * element_bits / 8). An encoded zero selector is present and supplies the real zero GPR value, so an explicitly encoded zero stride aliases rows.

## Legality

- TSTORE is selected by TLSU Function 1 and has no standalone opcode.
- DataType accepts 0..14, 16..20, and 24..28; all other codes are reserved before effects.
- The completed block has exactly one source domain. Function 1 accepts one Local B.IOT or one Shared B.IOS; Shared source access requires whole-parent readiness and publication.
- Shared PE_MASK selects participating consumer PEs and never infers quarter selection. B.SUBVIEW is the explicit source range mechanism.
- ValidCol and ValidRow are nonzero, ValidCol does not exceed physical Col, and the resolved valid rectangle fits the persistent source descriptor.
- The existing explicit ND2M32/M322ND Local conversion forms admit FP64, S64 and U64 with 256 physical bytes per column under issue #371; ordinary and Shared form layout rules remain owned separately.

## State effects

- Reads one Local or published, whole-parent-ready Shared source without modifying its payload, descriptor, producer mask, readiness, or lifetime.
- On success only GM and memory-event state change; the source binding is consumed by normal block completion.

## Memory effects and ordering

### Memory effects

- For every selected PE and each element in ValidRow x ValidCol, write GM at base + row * row_stride_bytes + column * element_size. Packed four-bit columns add floor(column / 2) to each byte-strided row base and select low/high by column parity.
- The selected-PE footprint is accessed element by element until the first fault. Stores and memory events completed before that fault may remain visible.

### Ordering

- Snapshot the source payload, resolve the complete schema and dimensions, validate the source descriptor or temporary descriptor, and access each selected GM element until the first fault.
- After all requested stores complete without a fault, store beats have no architecture-defined relative order. Software avoids overlapping selected-PE GM regions or establishes ordering separately.

## Exceptions

- A malformed binding stream, missing dimensions, unsupported DataType, non-row-major source, undefined Local source element, invalid source encoding, or mismatched source geometry raises Fault_TileLegality before effects. An unpublished or not-whole-ready Shared source waits without fault or effect.
- A memory translation, permission, or alignment fault stops the request at the first fault; prior GM writes and memory events may remain visible.

## Examples

- BSTART.TSTORE U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR a0, a1; B.IOT T1, mask=1111, last; BSTOP
- BSTART.TSTORE FP16; B.IOS S7, mask=0011; B.SUBVIEW 0, a0, 0, 7; BSTOP
