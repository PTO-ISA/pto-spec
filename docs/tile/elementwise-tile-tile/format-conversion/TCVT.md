<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl -->
# TCVT

**Normative ASL source:** `asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl`

Convert every valid source element to a separately typed and laid-out Local destination.

## Normative identity {#PTO-INST-TILE-TCVT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tcvt-purpose role=purpose -->
## What TCVT does

`TCVT` converts every valid element of one Local source Tile to another element type and writes the results into a newly allocated Local destination Tile. Unlike `TADD`, its destination type is chosen independently of the source type, and it accepts per-instruction `RMode` and `Sat` controls.

Design point: `TCVT` is selected by `BSTART.VEC` Mode 0 Function 27 (TEPL selector `0x01B`) and has no standalone opcode. The `BSTART` header names the source type `SrcDataType`; the destination type `DstDataType` comes from `B.DATR`.

<!-- PTO-READER-BLOCK: tile-tcvt-mechanism role=mechanism -->
## Element and Tile mechanism

The destination type is resolved first. A concrete `B.DATR` `DataType` selects `DstDataType`. Omitting `B.DATR`, or encoding `DataType` as `DTYPE_NONE` (code 31), makes the destination inherit `SrcDataType`. An encoded `DataType` of zero selects `FP64`; it does not mean absence.

Design point: code 0 already names `FP64`, so inheritance needs a separate sentinel. This keeps "no destination type requested" distinct from an explicit request for `FP64`.

Rounding is resolved next. `RMode` code 0 is the operation default: round toward zero (RTZ) when `SrcDataType` is a floating type and `DstDataType` is an integer type, and round to nearest even (RNE) for every other conversion that needs rounding. Codes 1 to 7 select RNE, RTZ, RTM, RTP, RNA, RTO, and RHB explicitly and always override the default.

Design point: the RTZ default makes a default float-to-integer conversion discard the fractional part, while float-to-float narrowing keeps the RNE default.

`Sat` controls range overflow. With `Sat=0`, a floating result that overflows becomes an infinity where the destination format has one, and an overflowing integer result keeps only the low bits of the rounded value. With `Sat=1`, the result is clamped to the largest or smallest finite value of the destination type.

After complete preflight, the source is snapshotted and each valid logical element is converted independently. The common Tile rule covers `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, and signed or unsigned 64-, 32-, 16-, and 8-bit integers. Reduced floating destinations use their exact fixed encoders. `E8M0`, `E6M2`, `RCPE6M2`, `E2M1X2`, and `E1M2X2` retain dedicated pair rules. The broader Tile set does not add scalar conversion opcodes or pairs.

<!-- PTO-READER-BLOCK: tile-tcvt-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the persistent Local source. Its bits are interpreted as `SrcDataType`.
- `destination0` is a newly allocated Local Tile whose backing type is the resolved `DstDataType`.
- `numeric_control` is not a Tile. It is the resolved pair of rounding mode and saturation taken from `RMode` and `Sat`.

One terminating `B.IOT` binds the source and the destination. `B.IOR`, `B.IOS`, a second source, and a second binding are illegal. `PE_MASK=0000` is a strict no-op before schema, descriptor, allocation, or payload checks.

The source backing type may differ from `SrcDataType` only when both types are non-packed, have the same element width, and are carrier-compatible. The source descriptor is never retagged.

For an ordinary source, the destination has the same `Row`, `Col`, `ValidRow`, and `ValidCol` as the source. An explicit `Layout` code names both the layout the source must have and the layout the destination receives; `NORM` keeps `RowMajor` on both sides.

For a `CUBE_M16` or `CUBE_M32` source, `B.DATR` `Layout` must stay `NORM` and `LB2` must be omitted. The destination keeps the same CUBE layout and the same `ValidRow` and `ValidCol`, while its physical shape, CELL count, and minimum `TSize` are derived from `DstDataType`.

Design point: CUBE physical geometry depends on element width. Deriving it independently for the destination lets, for example, an `FP32` CUBE Tile convert to a narrower type without first converting the layout.

For `CUBE_M32`, an `FP64`, `S64`, or `U64` source or destination uses the double-CELL mapping while preserving the logical shape. `CUBE_M16` rejects any pair whose source or destination is 64-bit.

<!-- PTO-READER-BLOCK: tile-tcvt-effects role=effects -->
## Publication, definedness, and padding

The converted payload, the accumulated numeric status, the padding, the definedness of every element, and the destination descriptor are published as one operation. A rejected bundle has no destination effect, and the source persists unchanged.

Numeric status uses the five flags NV, DZ, OF, UF, and NX. The flags of every converted element are ORed together and recorded at publication.

Physical elements outside `ValidRow x ValidCol` receive the selected `PadValue`. `Zero` writes zero; `Max` and `Min` write the largest and smallest finite value of `DstDataType`; `Null` leaves those elements undefined. Omitting `B.DATR` selects `Null`, while an explicit code `00` selects `Zero`.

The source may alias the destination, and execution observes the complete pre-execution source. `TCVT` has no global-memory effect. When an ExecutionMask is in force, inactive coordinates receive the mask's zero or merge value and contribute no status.

<!-- PTO-READER-BLOCK: tile-tcvt-constraints role=constraints -->
## Type, layout, and fault boundary

Every assigned `DataType` except `HiF4X2` may name a `TCVT` type, subject to these pair restrictions:

- `E2M1X2` and `E1M2X2` convert only to or from `FP32`, `FP16`, or `BF16`, and exactly one side must be packed.
- `E6M2` converts only to or from `FP16` or `BF16`, and only with RNE or RNA rounding.
- `RCPE6M2` is source-only, converts only to `FP16` or `BF16`, and only with RNE or RNA rounding.
- `E8M0` converts only to or from `FP16`, `BF16`, or `FP32`.

For an `E8M0` destination, zero, negative values, and NaNs produce `0xFF` with NV. A positive finite value produces the code `exponent+127` after rounding its base-two exponent under `RMode`. Positive infinity and values above the range produce `0xFF` when `Sat=0` or `0xFE` when `Sat=1`; values below the range produce `0xFF` or `0x00`. An `E8M0` source code `0xFF` produces the destination canonical quiet NaN without NV.

`Canonicalize=1` is reserved and rejects before effects. A missing or zero dimension, a type, shape, capacity, layout, encoding, or definedness mismatch, or an unsupported pair or rounding mode raises `Fault_TileLegality` before destination allocation. For a CUBE source whose logical shape is accepted, an insufficient destination `TSize` raises `Fault_TileAllocation`.

<!-- PTO-READER-BLOCK: tile-tcvt-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

Converting `FP32` to `S32` with the default `RMode`, a source row `[2.7, -2.7, 3.0e9]` uses RTZ. With `Sat=1` the destination row is `[2, -2, 2147483647]`, and the recorded status includes OF and NX.

Converting `FP32` to `FP16` with the default RNE, the value `65536.0` exceeds the largest finite `FP16` value, 65504. With `Sat=0` it becomes `+inf`; with `Sat=1` it becomes `65504`. Both record OF and NX.

For an 8 x 64 `RowMajor` Tile, the header is `BSTART.VEC TCVT, FP32` and `B.DATR` selects the destination `DataType` `FP16`. The source holds 8 x 64 x 4 = 2048 bytes, and the destination needs 8 x 64 x 2 = 1024 bytes.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TCVT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCVT | TEPL | 0x01B | 27 | 0 | TCVT |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### BSTART.DataType (`PTO-FIELD-BLOCK-DATATYPE`)

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

### B.DATR.DataType (`PTO-FIELD-BLOCK-DATATYPE`)

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
| destination0 | new typed and laid-out Local destination |
| source0 | persistent Local source |
| numeric_control | resolved rounding and saturation |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl -->
```asl
readonly func InstructionContractOperation_TCVT() => TileOperation
begin
    return TileOperation_TCVT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TCVT, SrcDataType
B.DATR DstDataType, RMode, Sat, Canonicalize, Layout, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCVT(
    data_type: TileDataType) => boolean
begin
    // Assigned identity is separate from TCVT pair legality. HiF4X2 remains
    // an assigned Matrix/MX payload but is not a standalone TCVT type.
    return data_type != TileDataType_HiF4X2;
end;

pure func InstructionContractDestinationDataType_TCVT(
    source_type: TileDataType,
    data_type_field_present: boolean,
    data_type_code: bits(5)) => TileDataType
begin
    if data_type_field_present && BundleDataTypeConcrete(data_type_code) then
        return BundleTileDataType(data_type_code);
    end;
    return source_type;
end;

pure func InstructionContractDefaultRounding_TCVT(
    source_type: TileDataType,
    destination_type: TileDataType) => NumericRoundingMode
begin
    if TileDataTypeIsFloating(source_type) &&
       TileDataTypeIsInteger(destination_type) then
        return NumericRound_RTZ;
    end;
    return NumericRound_RNE;
end;

func InstructionContractExecute_TCVT(
    destination: TileIndex,
    source: TileIndex,
    control: NumericExecutionControl)
begin
    assert TileOperandsLegal_TCVT(destination, source, control);
    TCVT(destination, source, control);
end;

readonly func InstructionContractHandler_TCVT() => TileSemanticHandler
begin
    return TileHandler_TCVT;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The BSTART DataType is SrcDataType. Omitted B.DATR or DTYPE_NONE inherits SrcDataType as DstDataType; an explicitly encoded DataType zero selects FP64.
- LB0 is required and supplies ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol. Every present dimension must be nonzero.
- RMode zero selects RTZ for floating-to-integer conversion and RNE for every other conversion that requires rounding. Sat zero disables saturation and Canonicalize zero selects an ordinary public source.
- Omitted B.DATR selects Layout=NORM and PadValue=Null. Explicit PadValue codes 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- For an E8M0 destination, RMode rounds the base-two exponent. Exact powers of two are exact; Sat selects finite endpoint clamp versus 0xFF for finite range overflow or underflow.

## Legality

- TCVT is selected only by VEC Mode 0 Function 27 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one source and one newly allocated destination. B.IOR, B.IOS, a second source, and a second binding are illegal.
- For ordinary layouts, source and destination have equal Row, Col, ValidRow, and ValidCol. For a CUBE_M16 or CUBE_M32 source, the destination preserves the same CUBE layout and ValidRow/ValidCol, while Row, Col, CELL count, capacity, and packing independently match the destination DataType.
- TCVT legal pairs are profile-scoped: FP32/FP16/BF16 <-> E2M1X2/E1M2X2; FP16/BF16 <-> E6M2; RCPE6M2 -> FP16/BF16. No pair contains HiF4X2, and RCPE6M2 has no destination encoding. Reserved five-bit DataType codes reject before effects.
- Every assigned Layout code has executable indexing. The source descriptor matches the transform source layout and the destination descriptor matches its target layout; CUBE_M16 and CUBE_M32 conversions retain the source layout.
- Canonicalize=1 is reserved-illegal before effects. CUBE_M16 and CUBE_M32 sources with Canonicalize=0 preserve the source layout while the destination independently derives its geometry from the destination DataType. An ordinary source requires Canonicalize=0.
- The source valid region is fully defined and contains valid encodings. PE_MASK=0000 is a strict no-op before schema, descriptor, allocation, or payload checks.
- Under the named hardware profile, an E8M0 destination accepts exactly FP16, BF16, or FP32 sources. E8M0 as a source accepts exactly FP16, BF16, or FP32 destinations; 0x00..0xFE denote powers of two and 0xFF produces the target canonical quiet NaN without NV. Every other E8M0 pair rejects before destination allocation.
- The BSTART DataType is the TCVT source operation interpretation, not necessarily the source backing DataType. RowMajor and CUBE_M16/M32 sources may differ only when backing and operation types are non-packed, equal-width, and carrier-compatible; the operation view never mutates the backing descriptor. The destination backing type is the resolved B.DATR destination type.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- Snapshot the persistent source, convert every valid logical element under the resolved rounding and saturation controls, and write the corresponding logical coordinate in the destination layout.
- Define or undefine every physical padding coordinate according to PadValue and publish the destination; ordinary conversions use the resolved public layout, while CUBE_M16 and CUBE_M32 conversions retain the source CUBE layout.
- The source may alias the destination; execution observes the complete pre-execution source snapshot.
- For a supported conversion to an E8M0 destination, map the rounded base-two exponent to code exponent+127 and accumulate exact NV/UF/OF/NX status before atomic publication.
- For FP64, FP32, FP16, E4M3, S64, S32, S16, S8, U64, U32, U16, and U8 source/destination pairs, TCVT uses the same deterministic conversion result and flags as the scalar conversion family.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, type, logical geometry, layout, canonicalization, capacity, encoding, and definedness preflight precedes the source snapshot and destination allocation.
- Converted payload, numeric status, padding definedness, public representation state, and destination descriptor publish atomically.

## Exceptions

- Malformed bindings, missing or zero dimensions, type, shape, capacity, layout, canonicalization, encoding, or definedness mismatch raises Fault_TileLegality before destination allocation or payload effects.
- Reserved selector, DataType, or Layout encodings raise the corresponding instruction or Tile legality fault before effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.
- For conversion to an E8M0 destination, zero, negative values, and NaNs produce 0xFF with NV. Positive infinity follows the overflow rule. Finite values below 2^-127 or above 2^127 produce 0xFF when Sat=0 or clamp to 0x00/0xFE when Sat=1, with UF/OF plus NX.

## Examples

- BSTART.VEC TCVT, SrcDataType; B.DATR DstDataType, RMode, Sat, Canonicalize, Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
