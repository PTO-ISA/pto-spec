<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/transcendental/TRECIP.asl -->
# TRECIP

**Normative ASL source:** `asl/tile/elementwise-tile-tile/transcendental/TRECIP.asl`

Compute the same-type reciprocal of every valid Local Tile element.

## Normative identity {#PTO-INST-TILE-TRECIP}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-trecip-purpose role=purpose -->
## What TRECIP does

`TRECIP` computes the reciprocal `1 / x` of each element of one Local floating Tile and writes the results into a newly allocated Local destination Tile of the same type. Unlike `TADD`, it reads one source, accepts only floating types, and runs on the `SFU` engine.

Design point: `TRECIP` keeps the TEPL carrier Mode 0 Function 20 (selector `0x014`) and has no standalone opcode. Its canonical header is `BSTART.SFU TRECIP, DataType`. `BSTART.SFU` is an alias of `BSTART.TEPL` that adds no encoding bits, so the engine name changes only the assembly spelling.

<!-- PTO-READER-BLOCK: tile-c-trecip-mechanism role=mechanism -->
## Element and Tile mechanism

After complete preflight, `ExecuteTileUnary` computes one result for each coordinate in the valid rectangle `ValidRow x ValidCol`. Each element is first checked against a fixed table of special inputs. Only an ordinary finite input reaches the numeric profile's approximation, whose result is rounded to the `DataType` with the fixed default rounding.

The special-input table for `TRECIP` is:

- Positive or negative zero records DZ and produces the infinity of the same sign. `E4M3` has no infinity, so there either zero produces the canonical quiet NaN `0x7F` and records DZ without OF.
- `+inf` produces `+0`, and `-inf` produces `-0`.
- Any NaN produces the canonical quiet NaN; a signaling NaN also records NV.

Design point: `TRECIP` accepts only floating types, so a zero input always has a defined answer and never raises a legality fault as an integer zero divisor does in `TDIV`. Signs are preserved: applying `TRECIP` twice to `-0` gives `-inf` and then `-0` again.

Each element reports status in the five flags NV, DZ, OF, UF, and NX (invalid, divide-by-zero, overflow, underflow, and inexact). The flags of all active elements are ORed together and recorded when the destination is published. Recording a flag never raises a fault.

<!-- PTO-READER-BLOCK: tile-c-trecip-inputs-outputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the persistent Local floating source. It is not modified.
- `destination0` is a newly allocated Local Tile. Its backing `DataType` is the selected operation `DataType`, and its shape and layout match the source.

Both Tiles are bound by one terminating `B.IOT` and share one `PE_MASK`. `PE_MASK=0000` is a strict no-op before descriptor reads, allocation, faults, numeric status, or payload effects.

Design point: the complete source is snapshotted before the destination is published, so the destination may alias the source and still receives results computed from the old values. A source may be stored with a different same-width, non-packed backing type, for example `U16` data read as `FP16`; its bits are then validated as the selected `DataType`.

<!-- PTO-READER-BLOCK: tile-c-trecip-effects role=effects -->
## Publication, definedness, and padding

The destination descriptor, the valid-region results, the padding, the definedness of every element, and the accumulated numeric status are published together. A rejected bundle leaves architectural state unchanged.

Physical elements outside `ValidRow x ValidCol` receive the selected `PadValue`. `Zero` writes zero; `Max` and `Min` write the largest and smallest finite value of the `DataType`; `Null` leaves those elements undefined. Omitting `B.DATR` selects `Null`, while an explicit code `00` selects `Zero`.

`TRECIP` has no global-memory effect. When an ExecutionMask is in force, inactive coordinates receive the mask's zero or merge value and contribute no status.

<!-- PTO-READER-BLOCK: tile-c-trecip-constraints role=constraints -->
## Type, layout, and fault boundary

`TRECIP` accepts exactly `FP64`, `FP32`, `FP16`, and `BF16`. Special-value and finite-result execution is defined for all four; every other floating, integer, and packed operation type rejects before effects.

The layout is `RowMajor` by default. An explicit `Layout` may select `CUBE_M16` or `CUBE_M32`, and both operands must use that same layout; among CUBE layouts, a 64-bit operation type is legal only in `CUBE_M32`; `CUBE_M16` rejects it. `CUBE_N8`, Shared Tiles, and mixed layouts are illegal. `TRECIP` rejects nondefault `RMode`, `Sat`, and `CMode`.

Malformed bindings, `B.IOR` or `B.IOS`, missing or zero dimensions, an unsupported `DataType`, an undefined source or invalid source encoding, a descriptor mismatch, or an invalid capacity raise the applicable Tile fault before any destination effect. Special floating inputs never fault; they produce the table results above.

<!-- PTO-READER-BLOCK: tile-c-trecip-example role=example -->
## Non-normative worked example

This example illustrates the current ASL-bound contract and is not a second instruction definition.

For `FP16`, a source row `[2.0, -0.0, +inf, 4.0]` produces the destination row `[0.5, -inf, +0.0, 0.25]`, and the recorded status includes DZ.

In macro form, an 8 x 64 `FP32` operation is `TRECIP <Row=8, Col=64, FP32>, T#1, ->T<2KB>`, where `T#1` is the source. The destination payload is 8 x 64 x 4 = 2048 bytes, exactly the 2KB capacity.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `SFU`

## Assembly

```asm
TRECIP <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TRECIP | TEPL | 0x014 | 20 | 0 | ExecuteTileUnary |

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
| destination0 | new Local floating destination |
| source0 | persistent Local floating source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/transcendental/TRECIP.asl -->
```asl
readonly func InstructionContractOperation_TRECIP() => TileOperation
begin
    return TileOperation_TRECIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TRECIP, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/transcendental/TRECIP.asl -->
```asl
pure func InstructionContractDataTypeLegal_TRECIP(
    data_type: TileDataType) => boolean
begin
    return TileUnaryDataTypeSupported(
        TileUnary_RECIP,
        data_type);
end;

readonly func InstructionContractOperandsLegal_TRECIP(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_RECIP,
        destination,
        source);
end;

readonly func InstructionContractHandler_TRECIP() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TRECIP(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TRECIP(
        destination,
        source);
    ExecuteTileUnary(
        TileUnary_RECIP,
        destination,
        source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null and Layout=NORM (RowMajor). Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- The selected numeric profile supplies the operation-fixed approximation, rounding, exceptional result, and exact NV/DZ/OF/UF/NX status vector.

## Legality

- TRECIP retains its TEPL raw Mode 0 carrier and executes canonically on the SFU engine.
- Exactly one terminating Local B.IOT supplies one persistent source and one newly allocated destination. B.IOR and B.IOS are illegal.
- The selected DataType is exactly FP64, FP16, FP32, or BF16; every integer, exponent-only, other compact, packed, assigned-but-inapplicable, or reserved DataType rejects before effects.
- B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- Source and destination use one PE_MASK. PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, numeric status, or payload effects.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- For each valid element compute the selected profile's same-type reciprocal.
- Accumulate all element status flags, apply selected physical padding, and publish payload, definedness, numeric status, and destination descriptor atomically; rejection leaves architectural state unchanged.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, dimension, type, descriptor, source-definedness, source-encoding, mask, capacity, and allocation preflight precedes the source snapshot and profile evaluation.
- The complete source payload is snapshotted before destination publication, so source/destination aliasing observes the old source value.

## Exceptions

- Malformed Local bindings, B.IOR or B.IOS presence, missing or zero dimensions, unsupported DataType, undefined or invalid source encoding, descriptor mismatch, invalid capacity, or allocation failure raises the applicable Tile fault before effects.
- Floating zero is legal, reports divide-by-zero, and produces signed infinity where representable; signed infinity produces signed zero; signaling NaN records invalid and every NaN produces a quiet-NaN result.
- E4M3 has no infinity encoding and TRECIP does not admit saturation, so either signed zero produces canonical E4M3 quiet NaN 0x7F and records only divide-by-zero without overflow.

## Examples

- BSTART.SFU TRECIP, DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
