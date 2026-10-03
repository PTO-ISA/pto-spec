<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/transcendental/TEXP.asl -->
# TEXP

**Normative ASL source:** `asl/tile/elementwise-tile-tile/transcendental/TEXP.asl`

Compute the same-type natural exponential of every valid Local Tile element.

## Normative identity {#PTO-INST-TILE-TEXP}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-texp-purpose role=purpose -->
## What TEXP does

`TEXP` computes the natural exponential `exp(x)` of each element of one Local floating Tile and writes the results into a newly allocated Local destination Tile of the same type. Unlike `TADD`, it reads one source, accepts only floating types, and runs on the `SFU` engine.

Design point: `TEXP` keeps the TEPL carrier Mode 0 Function 18 (selector `0x012`) and has no standalone opcode. Its canonical header is `BSTART.SFU TEXP, DataType`. `BSTART.SFU` is an alias of `BSTART.TEPL` that adds no encoding bits, so the engine name changes only the assembly spelling.

<!-- PTO-READER-BLOCK: tile-texp-mechanism role=mechanism -->
## Element and Tile mechanism

After complete preflight, `ExecuteTileUnary` computes one result for each coordinate in the valid rectangle `ValidRow x ValidCol`. Each element is first checked against a fixed table of special inputs. Only an ordinary finite input reaches the numeric profile's approximation, whose result is rounded to the `DataType` with the fixed default rounding.

The special-input table for `TEXP` is:

- Positive or negative zero produces exactly `1.0`.
- `+inf` stays `+inf`.
- `-inf` produces `+0`.
- Any NaN produces the canonical quiet NaN; a signaling NaN also records NV.

Design point: the special table fixes the exact answers before any approximation runs. `exp(0)` is exactly one and `exp(-inf)` is exactly zero on every implementation, so a program can use `-inf` inputs to produce exact zeros.

Each element reports status in the five flags NV, DZ, OF, UF, and NX (invalid, divide-by-zero, overflow, underflow, and inexact). The flags of all active elements are ORed together and recorded when the destination is published. Recording a flag never raises a fault.

<!-- PTO-READER-BLOCK: tile-texp-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the persistent Local floating source. It is not modified.
- `destination0` is a newly allocated Local Tile. Its backing `DataType` is the selected operation `DataType`, and its shape and layout match the source.

Both Tiles are bound by one terminating `B.IOT` and share one `PE_MASK`. `PE_MASK=0000` is a strict no-op before descriptor reads, allocation, faults, numeric status, or payload effects.

Design point: the complete source is snapshotted before the destination is published, so the destination may alias the source and still receives results computed from the old values. A source may be stored with a different same-width, non-packed backing type, for example `U16` data read as `FP16`; its bits are then validated as the selected `DataType`.

<!-- PTO-READER-BLOCK: tile-texp-effects role=effects -->
## Publication, definedness, and padding

The destination descriptor, the valid-region results, the padding, the definedness of every element, and the accumulated numeric status are published together. A rejected bundle leaves architectural state unchanged.

Physical elements outside `ValidRow x ValidCol` receive the selected `PadValue`. `Zero` writes zero; `Max` and `Min` write the largest and smallest finite value of the `DataType`; `Null` leaves those elements undefined. Omitting `B.DATR` selects `Null`, while an explicit code `00` selects `Zero`.

`TEXP` has no global-memory effect. When an ExecutionMask is in force, inactive coordinates receive the mask's zero or merge value and contribute no status.

<!-- PTO-READER-BLOCK: tile-texp-constraints role=constraints -->
## Type, layout, and fault boundary

`TEXP` legality accepts `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, and `E5M2`. The validated finite reference paths cover `FP64`, `FP32`, `FP16`, and `BF16`; the pre-existing finite, non-special result gap remains for `TF32`, `HF32`, `E4M3`, and `E5M2`. Integer and packed operation types reject before effects.

The layout is `RowMajor` by default. An explicit `Layout` may select `CUBE_M16` or `CUBE_M32`, and both operands must use that same layout; among CUBE layouts, a 64-bit operation type is legal only in `CUBE_M32`; `CUBE_M16` rejects it. `CUBE_N8`, Shared Tiles, and mixed layouts are illegal. `TEXP` rejects nondefault `RMode`, `Sat`, and `CMode`.

Malformed bindings, `B.IOR` or `B.IOS`, missing or zero dimensions, an unsupported `DataType`, an undefined source or invalid source encoding, a descriptor mismatch, or an invalid capacity raise the applicable Tile fault before any destination effect. Special floating inputs never fault; they produce the table results above.

<!-- PTO-READER-BLOCK: tile-texp-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For `FP32`, a source row `[0.0, -inf, +inf, NaN]` produces the destination row `[1.0, +0.0, +inf, NaN]`. No flag is recorded for these inputs when the NaN is quiet.

In macro form, an 8 x 64 `FP32` operation is `TEXP <Row=8, Col=64, FP32>, T#1, ->T<2KB>`, where `T#1` is the source. The destination payload is 8 x 64 x 4 = 2048 bytes, exactly the 2KB capacity.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `SFU`

## Assembly

```asm
TEXP <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TEXP | TEPL | 0x012 | 18 | 0 | ExecuteTileUnary |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/transcendental/TEXP.asl -->
```asl
readonly func InstructionContractOperation_TEXP() => TileOperation
begin
    return TileOperation_TEXP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TEXP, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/transcendental/TEXP.asl -->
```asl
pure func InstructionContractDataTypeLegal_TEXP(
    data_type: TileDataType) => boolean
begin
    return TileUnaryDataTypeSupported(
        TileUnary_EXP,
        data_type);
end;

readonly func InstructionContractOperandsLegal_TEXP(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_EXP,
        destination,
        source);
end;

readonly func InstructionContractHandler_TEXP() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TEXP(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TEXP(
        destination,
        source);
    ExecuteTileUnary(
        TileUnary_EXP,
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

- TEXP retains its TEPL raw Mode 0 carrier and executes canonically on the SFU engine.
- Exactly one terminating Local B.IOT supplies one persistent source and one newly allocated destination. B.IOR and B.IOS are illegal.
- The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, or E5M2.
- B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- Source and destination use one PE_MASK. PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, numeric status, or payload effects.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- For each valid element compute the selected profile's same-type natural exponential.
- Accumulate all element status flags, apply selected physical padding, and publish payload, definedness, numeric status, and destination descriptor atomically; rejection leaves architectural state unchanged.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, dimension, type, descriptor, source-definedness, source-encoding, mask, capacity, and allocation preflight precedes the source snapshot and profile evaluation.
- The complete source payload is snapshotted before destination publication, so source/destination aliasing observes the old source value.

## Exceptions

- Malformed Local bindings, B.IOR or B.IOS presence, missing or zero dimensions, unsupported DataType, undefined or invalid source encoding, descriptor mismatch, invalid capacity, or allocation failure raises the applicable Tile fault before effects.
- exp(positive or negative zero) is positive one; positive infinity remains positive infinity; negative infinity becomes positive zero; signaling NaN records invalid and every NaN produces a quiet-NaN result.

## Examples

- BSTART.SFU TEXP, DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
