<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TIMG2COL.asl -->
# TIMG2COL

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TIMG2COL.asl`

Extract an offset window from one descriptor-defined feature map into standard Left matrix order.

## Normative identity {#PTO-INST-TILE-TIMG2COL}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TIMG2COL <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TIMG2COL | TEPL | 0x064 | 4 | 3 | TIMG2COL |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

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

### B.IOR.RegSrc1 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

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
| destination0 | new Local Matrix destination |
| source0 | persistent Local Matrix feature-map source |
| natural0 | unsigned low-sixteen-bit posM |
| natural1 | unsigned low-sixteen-bit posK |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TIMG2COL.asl -->
```asl
readonly func InstructionContractOperation_TIMG2COL() => TileOperation
begin
    return TileOperation_TIMG2COL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TIMG2COL, DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR PosMGPR, PosKGPR, zero, ->zero (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TIMG2COL.asl -->
```asl
pure func InstructionContractDataTypeLegal_TIMG2COL(
    data_type: TileDataType) => boolean
begin
    return TileImg2ColDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TIMG2COL(
    destination: TileIndex,
    source: TileIndex,
    position_m: integer {0..65535},
    position_k: integer {0..65535}) => boolean
begin
    return TileOperandsLegal_TIMG2COL(
        destination,
        source,
        position_m,
        position_k);
end;

readonly func InstructionContractHandler_TIMG2COL() => TileSemanticHandler
begin
    return TileHandler_TIMG2COL;
end;

func InstructionContractExecute_TIMG2COL(
    destination: TileIndex,
    source: TileIndex,
    position_m: integer {0..65535},
    position_k: integer {0..65535})
begin
    assert InstructionContractOperandsLegal_TIMG2COL(
        destination,
        source,
        position_m,
        position_k);
    TIMG2COL(
        destination,
        source,
        position_m,
        position_k);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero destination ValidCol. Omitted LB1 selects ValidRow=1 and omitted LB2 selects physical Col=ValidCol.
- Omitted B.IOR selects posM=0 and posK=0. When present, RegSrc0 and RegSrc1 contribute their unsigned low sixteen bits; RegSrc2 and RegDst must be zero.
- The source feature-map descriptor supplies layout, dimensions, filter, stride, dilation, four-sided padding, logical channel count, and the typed padding value.

## Legality

- TIMG2COL retains TEPL raw Mode 3 Function 4 and canonicalizes to the SFU engine without changing the carrier encoding.
- Exactly one terminating Local B.IOT supplies one persistent Matrix-location source and one newly allocated Matrix-location destination; B.IOS is illegal.
- The source descriptor layout is NC1HWC0 or NDC1HWC0; every dimension, filter, stride, and dilation is nonzero, padding is nonnegative, logical channels do not exceed C1*C0, and transposed mode is illegal.
- Source and destination use the same one of FP32, FP16, BF16, S32, S16, S8, U32, U16, or U8, row-major layout, and PE_MASK.
- B.DATR contributes no field. B.IOR is optional and only RegSrc0 and RegSrc1 may be nonzero.
- The complete destination window at posM,posK fits N*D*outH*outW by C1*filterH*filterW*C0, and every actually referenced in-range source element is defined and validly encoded.

## State effects

- For each destination row and column, add posM and posK, decompose the logical matrix coordinates, and copy the matching NC1HWC0 or NDC1HWC0 source element.
- Out-of-range spatial coordinates and packed channels beyond logical_channels receive the descriptor typed padding value.
- Publish the complete standard Left matrix result without modifying the source or its feature-map descriptor.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, descriptor, range, type, capacity, referenced-definedness, and allocation preflight precedes source snapshot.
- The source payload and feature-map descriptor are read-only; complete destination payload and definedness publish atomically.

## Exceptions

- An absent or invalid feature-map descriptor, transposed request, unsupported DataType, malformed binding, invalid B.DATR contribution, out-of-range matrix window, undefined referenced source element, invalid numeric encoding, or insufficient destination capacity raises the applicable Tile fault before effects.
- PE_MASK=0000 is a strict no-op before descriptor or GPR reads, allocation, faults, or payload effects.

## Examples

- BSTART.SFU TIMG2COL, FP16; B.DIM LB0=KWindow; B.DIM LB1=MWindow; B.IOT Src, mask=PE_MASK, <last>, ->Dst<TSize>; B.IOR PosM, PosK, zero, ->zero; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
