<!-- GENERATED FROM: asl/tile/tile-scalar-and-immediate/logical/TSELS.asl -->
# TSELS

**Normative ASL source:** `asl/tile/tile-scalar-and-immediate/logical/TSELS.asl`

Select each result encoding from a Local Tile or scalar under one legacy Predicate, CUBE PredicateCell, or GPR mask carrier.

## Normative identity {#PTO-INST-TILE-TSELS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tsels-purpose role=purpose -->
## What TSELS does

`TSELS` builds a new Local Tile by choosing, for each element in the valid rectangle, either the element of a true-source Tile or one scalar. A predicate of one selects the Tile element and zero selects the scalar. It is selected by TEPL Mode 1 Function 26 (selector `0x03A`), written canonically as `BSTART.VEC TSELS, DataType`, and has no standalone opcode.

Design point: the false alternative is a scalar, not a Tile. The Tile-Tile form `TSEL` needs a second source Tile, so replacing rejected elements with one constant that way first requires a Tile filled with it. `TSELS` takes the constant directly from a GPR.

<!-- PTO-READER-BLOCK: tile-c-tsels-mechanism role=mechanism -->
## Selection mechanism

The false scalar comes from a `B.IOR` source register resolved in each participating PE's private GPR file. In the RowMajor and PredicateCell forms described below, omitting `B.IOR` makes the scalar the all-zero encoding of the selected `DataType`.

The GPR value is narrowed by `TileRawElementValue` to the low element-width bits of the selected `DataType`. No numeric conversion happens.

Design point: selection is a raw copy. A predicate of one copies the exact true-source encoding, and zero copies the narrowed scalar bits. Neither value is validated as a number, and there is no rounding, saturation, canonicalization, or numeric-status update, so selecting a NaN does not raise the invalid status.

Complete preflight finishes before the predicate, true source, and scalar are snapshotted, and the destination is published only after every element is chosen.

<!-- PTO-READER-BLOCK: tile-c-tsels-inputs-outputs role=inputs-outputs -->
## Operand roles and mask carriers

- `source0` is the mask. Its carrier depends on the form described below.
- `source1` is the true source, an existing Local numeric Tile that persists unchanged.
- `scalar0` is the per-PE false scalar.
- `destination0` is a newly allocated Local Tile whose `DataType` is the selected `DataType`.

Three mutually exclusive forms are described by the contract:

- RowMajor: a legacy packed predicate Tile in `B.IOT`, one bit per element. The false scalar is `B.IOR.RegSrc0`. This remains the intended legacy form, but the current executable schema cannot reach it: the same first Tile is required to pass both Predicate and Numeric carrier checks. Treat this branch as an executable-model gap tracked in issue #367, not as a runnable form.
- `CUBE_M16` or `CUBE_M32` with a PredicateCell: a `U8` PredicateCell in `B.IOT` whose basis equals the operation `DataType`. The false scalar is `B.IOR.RegSrc0`.
- `CUBE_M16` or `CUBE_M32` with a GPR mask: one source-only `B.IOR` carries the mask words first and then the false scalar, so the scalar is the second source for a one-word mask and the third source for the two-word mask of an 8-bit type.

Design point: fixed `B.IOT` decoding and SizeCode legality still apply when `PE_MASK=0000`. After those checks, the zero-mask command returns before placement and schema checks. At commit, zero participation makes Tile dispatch return before the TSELS operation handler is called, so no GPR or descriptor is read and no Tile is allocated.

<!-- PTO-READER-BLOCK: tile-c-tsels-effects role=effects -->
## Publication, definedness, and padding

The destination payload, padding definedness, and descriptor are published as one unit. A rejected bundle has no architectural effect, and `TSELS` has no global-memory effect.

Physical elements outside `ValidRow x ValidCol` receive the selected `PadValue`. `Zero`, `Max`, and `Min` define them; `Null`, the default when `B.DATR` is omitted, leaves them undefined.

With an ExecutionMask on a CUBE form, inactive coordinates receive the mask's zero or merge value instead of a selected value.

<!-- PTO-READER-BLOCK: tile-c-tsels-constraints role=constraints -->
## Type, layout, and fault boundary

The operation `DataType` set is `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`. The CUBE forms are further limited: the PredicateCell form excludes `FP64`, `S64`, and `U64` and its basis must equal the operation type, and the GPR form is limited by the GPR predicate geometry.

The true source may use a different same-width, non-packed backing type; the destination always uses the operation `DataType`. `PadValueOrByteId` is the only applicable `B.DATR` field, and the layout comes from the source descriptor.

Mask bytes and true-source elements must be defined at every active coordinate, and PredicateCell bytes must be canonical `0x00` or `0x01`. A malformed or mixed carrier schema, a wrong PredicateCell basis, a shape or layout mismatch, insufficient capacity, or an allocation failure rejects the bundle before any effect.

<!-- PTO-READER-BLOCK: tile-c-tsels-example role=example -->
## Non-normative example

This example illustrates the current ASL-bound contract and is not a second instruction definition.

Consider a `CUBE_M16` `FP32` true-source row `[-1.5, 2.0]`, a matching PredicateCell row `[0, 1]`, and an omitted false scalar. Conceptually, CUBE selection produces `[+0.0, 2.0]`: the first element takes the all-zero scalar and the second copies the source encoding. This is only a non-normative data-flow example; it does not claim a particular macro expansion or make the unreachable RowMajor branch runnable.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `tile-scalar-and-immediate`
- **Execution engine:** `VEC`

## Assembly

```asm
TSELS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSELS | TEPL | 0x03A | 26 | 1 | ExecuteTileSelectScalar |

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

### B.IOR.RegSrc0 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new RowMajor or CUBE numeric destination |
| source0 | legacy packed Predicate, CUBE PredicateCell, or GPR mask role |
| source1 | persistent source selected by predicate one |
| scalar0 | independent scalar selected by predicate zero |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-and-immediate/logical/TSELS.asl -->
```asl
readonly func InstructionContractOperation_TSELS() => TileOperation
begin
    return TileOperation_TSELS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TSELS, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT PredicateCell, SrcTrue, mask=PE_MASK, <last>, ->DstTile<TSize> OR GPR predicate form without PredicateCell
B.IOR predicate-GPR source and optional scalar-false source
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-and-immediate/logical/TSELS.asl -->
```asl
pure func InstructionContractDataTypeLegal_TSELS(
    data_type: TileDataType) => boolean
begin
    return TileSelectDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TSELS(
    destination: TileIndex,
    predicate: TileIndex,
    source_true: TileIndex,
    scalar_false: Word) => boolean
begin
    return TileOperandsLegal_ExecuteTileSelectScalar(
        destination,
        predicate,
        source_true,
        scalar_false);
end;

readonly func InstructionContractHandler_TSELS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileSelectScalar;
end;

func InstructionContractExecute_TSELS(
    destination: TileIndex,
    predicate: TileIndex,
    source_true: TileIndex,
    scalar_false: Word)
begin
    assert InstructionContractOperandsLegal_TSELS(
        destination,
        predicate,
        source_true,
        scalar_false);
    ExecuteTileSelectScalar(
        destination,
        predicate,
        source_true,
        scalar_false);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol.
- Omitted B.IOR supplies the selected operation DataType all-zero false scalar; explicit all-zero is distinct but supplies the same value. TSELS is a raw-carrier operation: predicate-one copies SrcTrue backing bits, predicate-zero copies the scalar's normalized low physical bits, publishes the destination with the operation DataType, does not require TileNumericEncodingValid for selected source or scalar payloads, and performs no conversion or numeric-status update.
- Omitted B.DATR selects PadValue=Null. Explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.

## Legality

- TSELS selects TEPL Mode 1 Function 26 and executes on VEC. PE_MASK=0000 is a strict no-op before GPR, predicate, source, allocation, or payload checks.
- Legacy RowMajor form uses one terminating B.IOT with packed Predicate, SrcTrue, and one new destination; one B.IOR source supplies scalar-false or omission selects the operation-type zero, and the source backing is checked independently; exact backing/operation type identity is legal, while a cross-type source/backing pair requires equal width and a non-four-bit carrier.
- CUBE_M16/M32 PredicateCell form uses one terminating B.IOT with a descriptor-valid PredicateCell whose basis equals the operation DataType and whose ExecutionMask-active bytes are defined and canonical, SrcTrue, and one new CUBE destination plus an optional scalar-false B.IOR source; omission selects the operation-type zero. The true-source backing is checked independently; exact backing/operation type identity is legal, while a cross-type source/backing pair requires equal width and a non-four-bit carrier.
- CUBE_M16/M32 GPR form uses one B.IOT with SrcTrue and one new CUBE destination. One source-only B.IOR carries the complete predicate mask followed by the independent scalar-false source: two sources for one-word masks and three for U8's two-word mask. The operation type is a 32-bit or 16-bit type from the closed CUBE domain, plus U8; the true-source backing is checked independently; exact backing/operation type identity is legal, while a cross-type source/backing pair requires equal width and a non-four-bit carrier.
- Legacy, PredicateCell, and GPR forms are complete and mutually exclusive. PadValueOrByteId is the only applicable B.DATR field.

## State effects

- Predicate bit one copies the exact SrcTrue backing encoding and bit zero copies the normalized operation-type scalar encoding.
- Selection performs no rounding, saturation, canonicalization, or numeric-status update.
- Selected payload, padding definedness, and destination descriptor publish atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, dimensions, attributes, predicate-kind, source-definedness, scalar encoding, mask, capacity, and allocation preflight precedes snapshots.
- Predicate bits, true-source payload, and scalar are snapshotted before destination publication.

## Exceptions

- Malformed or mixed carrier schemas, unsupported type, wrong operation-type PredicateCell basis, noncanonical or undefined ExecutionMask-active predicate bytes, undefined active source data, shape/layout mismatch, insufficient destination capacity, or allocation failure rejects before effects.
- TSELS copies raw carrier encodings and does not itself raise floating invalid for a selected NaN payload.

## Examples

- BSTART.VEC TSELS, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT Predicate, SrcTrue, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR ScalarFalseGPR, zero, zero, ->zero (optional); BSTOP
