<!-- GENERATED FROM: asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl -->
# TCMPS

**Normative ASL source:** `asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl`

Compare each valid Local Tile element with a scalar and produce one legacy Predicate, CUBE PredicateCell, or GPR carrier.

## Normative identity {#PTO-INST-TILE-TCMPS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tcmps-purpose role=purpose -->
## What TCMPS does

`TCMPS` is a selector-encoded Tile operation executed by `VEC`. It compares each valid numeric element with one private-GPR scalar under `CMode` and packs the predicates; its current instruction contract owns the exact bundle form and publication boundary.

<!-- PTO-READER-BLOCK: tile-tcmps-mechanism role=mechanism -->
## Element and Tile mechanism

After all descriptor and operand checks succeed, the owning ASL handler compares each valid numeric element with one private-GPR scalar under `CMode` and packs the predicates. Source payloads are snapshotted before destination writes whenever the contract permits aliasing.

The handler uses the resolved valid region rather than treating physical padding as input data. Its operation-specific dtype, layout, rounding, saturation, and profile hooks remain the executable definition.

<!-- PTO-READER-BLOCK: tile-tcmps-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `destination0` has the exact contract role **new packed Local predicate destination**.
- `source0` has the exact contract role **persistent Local numeric source**.
- `scalar0` has the exact contract role **per-participating-PE private-GPR scalar**.
- `comparison` has the exact contract role **six-mode comparison**.

Participating source and destination descriptors use the row-major and shape relationships stated by the current contract.
Every source coordinate read by the operation must be defined before execution reaches destination publication.
`PE_MASK=0000` is a strict no-op before descriptor, allocation, payload, numeric-status, or memory effects.

<!-- PTO-READER-BLOCK: tile-tcmps-effects role=effects -->
## Publication, definedness, and padding

Destination-visible state is published only after complete preflight; where the contract names atomic publication, payload, descriptor, definedness, padding, and status become visible together.

Physical coordinates outside the valid rectangle follow the contract-selected padding rule; `Null` padding remains undefined when that rule applies.

The operation has no GM memory effect; descriptor, payload, definedness, padding, and numeric-status changes are limited to those listed by the current contract.

<!-- PTO-READER-BLOCK: tile-tcmps-constraints role=constraints -->
## Type, layout, and fault boundary

The accepted data-type set is `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`.

The generated legality and exception sections below are authoritative for dtype pairs, layout, dimensions, capacity, definedness, padding controls, profile behavior, and fault class. Legality and allocation failures occur before partial architectural effects.

<!-- PTO-READER-BLOCK: tile-tcmps-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `TCMPS` example, under greater-than mode, `[1, 3]` compared with scalar `2` produces `[0, 1]`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `tile-scalar-and-immediate`
- **Execution engine:** `VEC`

## Assembly

```asm
TCMPS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCMPS | TEPL | 0x02D | 13 | 1 | ExecuteTileCompareScalar |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### B.DATR.CMode (`PTO-FIELD-BLOCK-CMODE`)

Selects the operation-defined comparison or indexed-memory mode.

**Encoded zero:** Equality for comparisons; Row mode for indexed TLSU.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | EQ-or-Row |
| 1 | assigned | NE-or-Elem |
| 2 | assigned | LT |
| 3 | assigned | GT |
| 4 | assigned | LE |
| 5 | assigned | GE |
| 6 | reserved | future extension |
| 7 | reserved | future extension |

**Reserved-value behavior:** Codes 6 and 7 are reserved and reject before architectural effects.

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
| destination0 | legacy packed Predicate or CUBE PredicateCell destination; absent for GPR producer |
| source0 | persistent Local numeric source |
| scalar0 | per-participating-PE compare scalar |
| comparison | six-mode comparison |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl -->
```asl
readonly func InstructionContractOperation_TCMPS() => TileOperation
begin
    return TileOperation_TCMPS;
end;

pure func InstructionContractComparisonCodeLegal_TCMPS(
    comparison_code: bits(3)) => boolean
begin
    return UInt(comparison_code) <= 5;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TCMPS, DataType
B.DATR CMode, PadValue, SatMode (U8 GPR form only)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->PredicateCell<TSize> OR no destination
B.IOR scalar-compare source and optional predicate-GPR destination
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCMPS(
    data_type: TileDataType) => boolean
begin
    return TileCompareDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCMPS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word,
    comparison: TileComparison) => boolean
begin
    return TileOperandsLegal_ExecuteTileCompareScalar(
        destination,
        source,
        scalar,
        comparison);
end;

readonly func InstructionContractHandler_TCMPS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileCompareScalar;
end;

func InstructionContractExecute_TCMPS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word,
    comparison: TileComparison)
begin
    assert InstructionContractOperandsLegal_TCMPS(
        destination,
        source,
        scalar,
        comparison);
    ExecuteTileCompareScalar(
        destination,
        source,
        scalar,
        comparison);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- CMode codes 0, 1, 2, 3, 4, and 5 select EQ, NE, LT, GT, LE, and GE; codes 6 and 7 are reserved. Omitted B.DATR selects EQ.
- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every present dimension must be nonzero.
- Omitted B.IOR supplies the selected source DataType all-zero scalar encoding. Omitted PadValue selects Null predicate padding.

## Legality

- TCMPS selects TEPL Mode 1 Function 13 and executes on VEC. PE_MASK=0000 is a strict no-op before GPR, source, allocation, status, or payload checks.
- Legacy RowMajor form uses one terminating B.IOT with source and new packed Predicate destination; one optional B.IOR supplies the compare scalar.
- CUBE_M16/M32 PredicateCell form uses one terminating B.IOT with source and new basis-tagged U8 PredicateCell destination plus an optional scalar-source B.IOR; omission selects zero. The source type is exactly one of FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S32, S16, S8, U32, U16, or U8.
- CUBE_M16/M32 GPR form uses one source-only B.IOT and one B.IOR carrying the scalar source plus one destination GPR. The source type is 32-bit or 16-bit types from the closed CUBE domain, plus U8; U8 Sat selects Low or High columns.
- Legacy, PredicateCell, and GPR forms are complete and mutually exclusive. CMode and PadValue apply to all; Sat is nonzero only for U8 GPR selection; Canonicalize remains zero.

## State effects

- Each valid comparison publishes through the selected carrier: legacy low-first packed bit, canonical PredicateCell byte, or GPR predicate bit.
- Zero and Min padding write zero predicate bits, Max writes one bits, and Null leaves padding undefined.
- Selected carrier payload, padding, numeric status, and descriptor or GPR result publish atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, dimensions, attributes, type, source, scalar, predicate capacity, mask, and allocation preflight precedes source and scalar snapshots.
- The source payload and scalar are snapshotted before packed destination publication.

## Exceptions

- Malformed or mixed carrier schemas, missing dimensions, reserved CMode, unsupported DataType, undefined or invalid source/scalar data, insufficient PredicateCell capacity, or allocation failure rejects before effects.
- Signaling floating NaN status publishes atomically with the selected GPR or PredicateCell result.

## Examples

- BSTART.VEC TCMPS, DataType; B.DATR CMode, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->Predicate<TSize>; B.IOR ScalarGPR, zero, zero, ->zero (optional); BSTOP
