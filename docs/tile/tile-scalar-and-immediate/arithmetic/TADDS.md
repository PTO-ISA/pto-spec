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

`TADDS` adds one scalar to every element in the valid rectangle of a Local source Tile and writes the sums into a newly allocated Local destination Tile. It is selected by TEPL Mode 1 Function 0 (selector `0x020`), written canonically as `BSTART.VEC TADDS, DataType`, and has no standalone opcode.

Design point: the scalar is a bundle operand, not a Tile. The Tile-Tile form `TADD` needs a second source Tile with the same shape and layout, so applying one value that way first requires a Tile filled with it, for example by `TEXPANDS`. `TADDS` reads the value directly from a GPR, so no broadcast Tile has to be allocated or made defined.

<!-- PTO-READER-BLOCK: tile-tadds-mechanism role=mechanism -->
## Scalar source and element mechanism

The scalar comes from `B.IOR.RegSrc0`. Each participating PE resolves that selector in its own private GPR file, so PEs selected by one `PE_MASK` can use different scalar values. The bundle has no immediate field for the scalar; when `B.IOR` is omitted the scalar is zero.

The 64-bit GPR value is narrowed by `TileRawElementValue`: only the low 8, 16, 32, or 64 bits, matching the element width of the selected `DataType`, are kept. No numeric conversion happens. A floating scalar must already be in the encoding of the selected type, and a signed integer scalar is read as a two's-complement value of the element width.

After preflight, `ExecuteTileScalar` computes `source + scalar` for each coordinate in `ValidRow x ValidCol`. Integer addition wraps at the element width. Floating-point addition follows the numeric profile of the selected `DataType`, including its fixed default rounding, overflow, and special values.

Design point: all checks, including the scalar checks, finish before the source and scalar are snapshotted, and the result is published only after every element is computed. A source that aliases the destination is therefore read with its old values.

<!-- PTO-READER-BLOCK: tile-tadds-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the Tile operand. It is an existing Local numeric Tile and persists unchanged.
- `scalar0` is the per-PE scalar from `B.IOR.RegSrc0`. An explicit `B.IOR` must keep `RegSrc1`, `RegSrc2`, and `RegDst` zero.
- `destination0` is a newly allocated Local Tile. Its backing `DataType` is the selected `DataType`, and its shape and layout match the source.

One terminating `B.IOT` binds the source and destination, and both use one `PE_MASK`. `B.IOS` and additional Tile bindings are illegal.

Design point: `PE_MASK=0000` is a strict no-op. It exits before any GPR read, descriptor read, allocation, fault, or status effect, so a bundle with no participating PE never reads the scalar register.

Design point: the source may be stored with a different same-width, non-packed backing type, for example `U16` data read as `FP16`. Its bits and the scalar are then validated and interpreted as the selected `DataType`, which allows a reinterpreting read without a copy. A width mismatch or a packed four-bit carrier remains illegal.

<!-- PTO-READER-BLOCK: tile-tadds-effects role=effects -->
## Publication, definedness, and padding

The destination becomes visible as one unit: its descriptor, the valid-region results, the padding, the definedness of every element, and any numeric status are published together. A rejected bundle has no architectural effect.

Physical elements outside `ValidRow x ValidCol` receive the selected `PadValue`. `Zero`, `Max`, and `Min` define them with the corresponding value of the `DataType`; `Null` leaves them undefined. Omitting `B.DATR` selects `Null`, while explicit code `00` selects `Zero`.

Omitting `B.IOR` makes the scalar zero, so each valid result is the profile-defined sum of its source element and zero.

`TADDS` has no global-memory effect. When an ExecutionMask is in force, inactive coordinates receive the mask's zero or merge value instead of a computed result.

<!-- PTO-READER-BLOCK: tile-tadds-constraints role=constraints -->
## Type, layout, and fault boundary

`TADDS` accepts exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. Floating execution is defined for `FP64`, `FP32`, `FP16`, and `BF16`; the pre-existing `TF32`, `HF32`, `E4M3`, and `E5M2` finite-result gap remains, while every admitted integer type is executable.

The layout is `RowMajor` by default. An explicit `B.DATR` `Layout` may select `CUBE_M16` or `CUBE_M32`; the source and destination must use the same layout, and `CUBE_N8` and Shared Tiles are illegal; among CUBE layouts, a 64-bit operation type is legal only in `CUBE_M32`; `CUBE_M16` rejects it. `B.DATR` accepts only `PadValueOrByteId` and `Layout`, so nondefault `RMode`, `Sat`, `CMode`, `Canonicalize`, or a secondary `DataType` is rejected.

Every source element in the valid rectangle (every active one, when an ExecutionMask is in force) must be defined. A malformed binding, `B.IOS`, a surplus `B.IOR` field, a missing or zero dimension, an unsupported `DataType`, an invalid source or scalar encoding, or a capacity or allocation failure raises `Fault_TileLegality` or `Fault_TileAllocation` before any destination effect.

<!-- PTO-READER-BLOCK: tile-tadds-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a `U8` example, a source row `[250, 3]` and a GPR `a2` holding `0x107` use the scalar `0x07`, that is `7`, because only the low 8 bits are kept. The destination row is `[1, 10]`: 250 + 7 = 257 wraps to `1`.

A partial `FP32` Tile is written in macro form as `TADDS <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32, Zero>, T#1, a2, ->T<2KB>`. The 7 x 60 = 420 sums are computed, and the other 92 physical elements of the 8 x 64 destination are defined as zero.
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
B.DATR PadValue, Layout (optional)
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
- Omitted B.DATR selects PadValue=Null and Layout=NORM (RowMajor). Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Omitted B.IOR supplies scalar zero. An explicitly present all-zero B.IOR is distinct but supplies the same value; RegSrc1, RegSrc2, and RegDst must be zero.

## Legality

- TADDS is selected only by the TEPL raw carrier Mode 1 Function 0; canonical execution-engine assembly is BSTART.VEC TADDS, DataType.
- Exactly one terminating Local B.IOT supplies one persistent Local numeric source and one newly allocated Local destination. B.IOS and additional Tile bindings are illegal.
- The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
- B.IOR is optional and, when present, only RegSrc0 may be nonzero. B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; explicit nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- Source and destination use one PE_MASK. PE_MASK=0000 is a strict no-op before GPR reads, descriptor reads, allocation, faults, numeric status, or payload effects.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

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

- BSTART.VEC TADDS, DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR ScalarGPR, zero, zero, ->zero (optional); BSTOP
