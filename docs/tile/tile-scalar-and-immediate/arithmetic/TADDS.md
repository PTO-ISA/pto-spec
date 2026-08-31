<!-- GENERATED FROM: asl/tile/tile-scalar-and-immediate/arithmetic/TADDS.asl -->
# TADDS

**Normative ASL source:** `asl/tile/tile-scalar-and-immediate/arithmetic/TADDS.asl`

Add one private-GPR scalar to every valid element of a Local Tile.

## Normative identity {#PTO-INST-TILE-TADDS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tadds-purpose role=purpose -->
## What TADDS does

`TADDS` is a selector-encoded Tile operation executed by `VEC`. It adds one participating PE private-GPR scalar to each valid Local source element; its current instruction contract owns the exact bundle form and publication boundary.

<!-- PTO-READER-BLOCK: tile-tadds-mechanism role=mechanism -->
## Element and Tile mechanism

After all descriptor and operand checks succeed, the owning ASL handler adds one participating PE private-GPR scalar to each valid Local source element. Source payloads are snapshotted before destination writes whenever the contract permits aliasing.

The handler uses the resolved valid region rather than treating physical padding as input data. Its operation-specific dtype, layout, rounding, saturation, and profile hooks remain the executable definition.

<!-- PTO-READER-BLOCK: tile-tadds-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `destination0` has the exact contract role **new Local numeric destination**.
- `source0` has the exact contract role **persistent Local numeric source**.
- `scalar0` has the exact contract role **per-participating-PE private-GPR scalar**.

Participating source and destination descriptors use the row-major and shape relationships stated by the current contract.
Every source coordinate read by the operation must be defined before execution reaches destination publication.
`PE_MASK=0000` is a strict no-op before descriptor, allocation, payload, numeric-status, or memory effects.

<!-- PTO-READER-BLOCK: tile-tadds-effects role=effects -->
## Publication, definedness, and padding

Destination-visible state is published only after complete preflight; where the contract names atomic publication, payload, descriptor, definedness, padding, and status become visible together.

Physical coordinates outside the valid rectangle follow the contract-selected padding rule; `Null` padding remains undefined when that rule applies.

The operation has no GM memory effect; descriptor, payload, definedness, padding, and numeric-status changes are limited to those listed by the current contract.

<!-- PTO-READER-BLOCK: tile-tadds-constraints role=constraints -->
## Type, layout, and fault boundary

The accepted data-type set is `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`.

The generated legality and exception sections below are authoritative for dtype pairs, layout, dimensions, capacity, definedness, padding controls, profile behavior, and fault class. Legality and allocation failures occur before partial architectural effects.

<!-- PTO-READER-BLOCK: tile-tadds-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `TADDS` example, source `[1, 2]` and scalar `3` produce `[4, 5]`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `tile-scalar-and-immediate`
- **Execution engine:** `VEC`

## Assembly

```asm
TADDS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TADDS | TEPL | 0x020 | 0 | 1 | ExecuteTileScalar |

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
| destination0 | new Local numeric destination |
| source0 | persistent Local numeric source |
| scalar0 | per-participating-PE private-GPR scalar |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-and-immediate/arithmetic/TADDS.asl -->
```asl
readonly func InstructionContractOperation_TADDS() => TileOperation
begin
    return TileOperation_TADDS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TADDS, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR ScalarGPR, zero, zero, ->zero (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-and-immediate/arithmetic/TADDS.asl -->
```asl
pure func InstructionContractDataTypeLegal_TADDS(
    data_type: TileDataType) => boolean
begin
    return TileBinaryDataTypeSupported(
        TileBinary_ADD,
        data_type);
end;

readonly func InstructionContractOperandsLegal_TADDS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word) => boolean
begin
    return TileOperandsLegal_ExecuteTileScalar(
        TileBinary_ADD,
        destination,
        source,
        scalar);
end;

readonly func InstructionContractHandler_TADDS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileScalar;
end;

func InstructionContractExecute_TADDS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word)
begin
    assert InstructionContractOperandsLegal_TADDS(
        destination,
        source,
        scalar);
    ExecuteTileScalar(
        TileBinary_ADD,
        destination,
        source,
        scalar);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Omitted B.IOR supplies scalar zero. An explicitly present all-zero B.IOR is distinct but supplies the same value; RegSrc1, RegSrc2, and RegDst must be zero.

## Legality

- TADDS is selected only by the TEPL raw carrier Mode 1 Function 0; canonical execution-engine assembly is BSTART.VEC TADDS, DataType.
- Exactly one terminating Local B.IOT supplies one persistent Local numeric source and one newly allocated Local destination. B.IOS and additional Tile bindings are illegal.
- The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
- B.IOR is optional and, when present, only RegSrc0 may be nonzero. PadValueOrByteId is the only applicable B.DATR field; explicit nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.
- Source and destination use one PE_MASK. PE_MASK=0000 is a strict no-op before GPR reads, descriptor reads, allocation, faults, numeric status, or payload effects.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- For each valid element compute source + scalar in the selected element interpretation.
- Publish valid payload, selected padding definedness, numeric status where applicable, and destination descriptor atomically; the source persists and rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, dimension, type, descriptor, source-definedness, scalar-encoding, mask, capacity, and allocation preflight precedes source and scalar snapshots.
- The source payload and scalar are snapshotted before destination publication, so a source that aliases the renamed destination observes its old value.

## Exceptions

- A malformed Local binding stream, B.IOS presence, surplus B.IOR field, missing or zero dimension, unsupported DataType, source descriptor or encoding failure, invalid destination capacity, or allocation failure raises Fault_TileLegality or Fault_TileAllocation before effects.
- Floating results and numeric status follow the selected profile; integer results wrap at the element width.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies precise restart and completion after an accepted operation.

## Examples

- BSTART.VEC TADDS, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR ScalarGPR, zero, zero, ->zero (optional); BSTOP
