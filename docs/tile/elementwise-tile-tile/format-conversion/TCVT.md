<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl -->
# TCVT

**Normative ASL source:** `asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl`

Convert every valid source element to a separately typed and laid-out Local destination.

## Normative identity {#PTO-INST-TILE-TCVT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

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
| 15 | reserved | future extension |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | reserved | future extension |
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
| 15 | reserved | future extension |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | reserved | future extension |
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
    // TileDataType has exactly the twenty-five assigned architectural values.
    // Reserved five-bit encodings never enter this semantic type.
    return TRUE;
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

## Legality

- TCVT is selected only by VEC Mode 0 Function 27 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one source and one newly allocated destination. B.IOR, B.IOS, a second source, and a second binding are illegal.
- The source type equals the BSTART DataType. The destination type is the concrete B.DATR DataType or the inherited source type.
- Source and destination have equal Row, Col, ValidRow, and ValidCol. Their capacities and packing independently match their own DataTypes.
- Every assigned Tile DataType is legal. Reserved five-bit DataType codes reject before effects; HiF4X2 is TCVT-only.
- Every assigned Layout code has executable indexing. The source descriptor matches the transform source layout and the destination descriptor matches its target layout.
- A private CUBE source requires Canonicalize=1 and Layout=NORM. An ordinary source requires Canonicalize=0.
- The source valid region is fully defined and contains valid encodings. PE_MASK=0000 is a strict no-op before schema, descriptor, allocation, or payload checks.

## State effects

- Snapshot the persistent source, convert every valid logical element under the resolved rounding and saturation controls, and write the corresponding logical coordinate in the destination layout.
- Define or undefine every physical padding coordinate according to PadValue and publish the destination as a public representation.
- The source may alias the destination; execution observes the complete pre-execution source snapshot.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, type, geometry, layout, canonicalization, capacity, encoding, and definedness preflight precedes the source snapshot and destination allocation.
- Converted payload, numeric status, padding definedness, public representation state, and destination descriptor publish atomically.

## Exceptions

- Malformed bindings, missing or zero dimensions, type, shape, capacity, layout, canonicalization, encoding, or definedness mismatch raises Fault_TileLegality before destination allocation or payload effects.
- Reserved selector, DataType, or Layout encodings raise the corresponding instruction or Tile legality fault before effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.VEC TCVT, SrcDataType; B.DATR DstDataType, RMode, Sat, Canonicalize, Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
