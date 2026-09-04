<!-- GENERATED FROM: asl/block/execution/BSTART.TIMG2COL.asl -->
# BSTART.TIMG2COL

**Normative ASL source:** `asl/block/execution/BSTART.TIMG2COL.asl`

Begins the TLSU feature-map IMG2COL block and selects its element DataType.

## Normative identity {#PTO-INST-BLOCK-BSTART-TIMG2COL}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-timg2col-purpose role=purpose -->
## What BSTART.TIMG2COL contributes

`BSTART.TIMG2COL` opens a TLSU block that materializes sliding feature-map windows as a two-dimensional Tile. The start command selects the element type; the completed block supplies the source view, window parameters, destination, and publication boundary.

<!-- PTO-READER-BLOCK: block-bstart-timg2col-mechanism role=mechanism -->
## Placement and mechanism

Read the result as a matrix: each logical row identifies one output spatial position, while each logical column identifies one kernel-and-channel position. The source layout chooses dense NCHW or NHWC indexing, and the destination layout chooses a Shared ND result or direct Local CUBE materialization.

```text
Shared: BSTART.TIMG2COL; optional B.DATR; LB0/LB1/LB2; two contiguous B.IOR records; B.IOS; optional B.ASSEMBLE for multiple PEs; BSTOP.
Local CUBE: BSTART.TIMG2COL; explicit CUBE-producing B.DATR; LB0/LB1/LB2; two contiguous B.IOR records; B.IOT; BSTOP.
```

The complete header is validated before any GM read. Spatial padding and channel-tail positions become defined zero elements without issuing a source access for those positions.

<!-- PTO-READER-BLOCK: block-bstart-timg2col-inputs role=inputs-outputs -->
## Operands and header roles

- `DataType` selects the feature-map element representation; the exact accepted codes remain in the generated contract below.
- `B.DATR.Layout` selects the dense source order and whether the result is Shared ND or Local CUBE.
- `B.DIM.LB0`, `B.DIM.LB1`, and `B.DIM.LB2` describe the valid output columns, valid output rows, and total output columns.
- The first `B.IOR` supplies `GMBase`; it is a source-only record.
- The immediately following `B.IOR` supplies the three packed parameter GPRs used for feature-map, kernel, stride, dilation, crop, and channel-padding values.
- `B.IOS` names the Shared destination, while `B.IOT` names the Local CUBE destination.
- `B.ASSEMBLE` joins explicit row ranges when multiple PEs publish one Shared result.

<!-- PTO-READER-BLOCK: block-bstart-timg2col-effects role=effects -->
## Result and publication

Successful completion writes only the logical output rectangle and its definedness. A Shared result becomes visible as one complete generation; a Local CUBE result has the same logical values as the corresponding Shared ND result followed by the selected ND-to-CUBE layout conversion.

<!-- PTO-READER-BLOCK: block-bstart-timg2col-constraints role=constraints -->
## Legality and fault boundary

The block requires supported element and layout codes, one complete parameter set, the required four-PE mask, a compatible destination form, and dimensions that fit the selected capacity. Schema, arithmetic, access, allocation, readiness, alias, and PE-consistency failures are resolved before GM access or destination publication.

<!-- PTO-READER-BLOCK: block-bstart-timg2col-example role=example -->
## Non-normative worked example

This example sketches a cooperative Shared result; symbolic values stand for previously prepared GPRs or dimensions.

```asm
BSTART.TIMG2COL FP16
B.DIM LB0, ValidCol
B.DIM LB1, ValidRow
B.DIM LB2, TotalCol
B.IOR GMBase, zero, zero
B.IOR ParamGPR0, ParamGPR1, ParamGPR2
B.IOS PE_MASK, ->S0<SizeCode>
B.ASSEMBLE 1, 1, zero, 0, ParentSizeCode
BSTOP
```

The two `B.IOR` records stay adjacent. `BSTOP` validates the complete composition and publishes the result only after every participating range succeeds.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TIMG2COL DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_timg2col_32_7a0f8d6c3e21 | L32 | 32 | 0x01c11181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[1,2,3,4,5,6,7,8,13,17,18,19,25,26,27]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_timg2col_32_7a0f8d6c3e21 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

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

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_timg2col_32_7a0f8d6c3e21 | DataType | 5 | 1–8, 13, 17–19, 25–27 | none | 0, 9–12, 14–16, 20–24, 28–31 | element DataType selector | Encoded zero selects FP64 and is inapplicable to TIMG2COL; explicit B.DATR DTYPE_NONE inherits the BSTART type. |

- `bstart_timg2col_32_7a0f8d6c3e21.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | element DataType selector |
| B.DATR.Layout | dense GM source view and output destination path |
| B.DIM.LB0/LB1/LB2 | ValidCol, ValidRow, TotalCol |
| B.IOR | GMBase and packed parameter GPRs |
| B.IOS/B.IOT | Shared ND or Local CUBE destination |
| B.ASSEMBLE | Shared cooperative row-range coverage |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TIMG2COL.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TIMG2COL(
    operation: CommandOperation) => boolean
begin
    return operation ==
        CommandOperation_bstart_timg2col_32_7a0f8d6c3e21;
end;

// The standalone TLSU carrier is Function 28 with mask 0x07ffffff and match
// 0x01c11181; DataType occupies instruction bits [31:27].
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TIMG2COL DataType; optional B.DATR; exactly one write-once binding for each of LB0/LB1/LB2; exactly two immediately contiguous source-only B.IOR records; Shared singleton uses one B.IOS; Shared multi-PE uses one B.IOS with PE_MASK=1111 followed by B.ASSEMBLE; Local direct output uses one B.IOT with PE_MASK=1111; BSTOP or the next BSTART completes the block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TIMG2COL.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TIMG2COL() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

pure func InstructionContractTIMG2COLLayoutLegal(layout: bits(5)) => boolean
begin
    return layout == Zeros{5} + 0 ||
           layout == Zeros{5} + 6 ||
           layout == Zeros{5} + 21 ||
           layout == Zeros{5} + 22 ||
           layout == Zeros{5} + 29 ||
           layout == Zeros{5} + 31;
end;

pure func InstructionContractTIMG2COLIsLocalCube(layout: bits(5)) => boolean
begin
    return layout == Zeros{5} + 21 || layout == Zeros{5} + 22 ||
           layout == Zeros{5} + 29 || layout == Zeros{5} + 31;
end;

pure func InstructionContractTIMG2COLIsM32(layout: bits(5)) => boolean
begin
    return layout == Zeros{5} + 21 || layout == Zeros{5} + 29;
end;

pure func InstructionContractTIMG2COLDATRLegal(
    layout: bits(5), data_type: bits(5), pad: bits(2), cmode: bits(3),
    rmode: bits(3), sat: boolean, canonicalize: boolean) => boolean
begin
    return InstructionContractTIMG2COLLayoutLegal(layout) &&
           data_type == DTYPE_NONE && pad == Zeros{2} &&
           cmode == Zeros{3} && rmode == Zeros{3} && !sat && !canonicalize;
end;

pure func InstructionContractTIMG2COLCoreMaskLegal(mask: bits(4)) => boolean
begin
    return mask == '1111';
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Omitted B.DATR is equivalent to NORM/ND2ND with DTYPE_NONE, Zero pad, and zero controls. Explicit B.DATR must use DTYPE_NONE and zero controls.

## Legality

- TLSU Function=28 with mask 0x07ffffff and match 0x01c11181.
- The operation accepts only FP32, TF32, HF32, FP16, BF16, HiF8, E4M3, E5M2, E8M0, S32, S16, S8, U32, U16, and U8.
- B.DATR accepts exactly NORM/ND2ND, DN2ND, ND2M16, ND2M32, DN2M16, and DN2M32; Shared uses ND output and Local uses explicit CUBE M16/M32.
- LB0, LB1, LB2 bind ValidCol, ValidRow, TotalCol exactly once each.
- Exactly two contiguous source-only B.IOR records bind GMBase and ParamGPR0..2; no source or destination binding is accepted for GM.
- The four-PE mask is 1111 for cooperative forms; zero-row PEs remain collective participants but perform no allocation or memory effect.

## State effects

- Writes the expanded-and-cropped logical rectangle with defined zeros for spatial OOB and Cin padding.
- Direct Local CUBE materialization is equivalent to Shared ND followed by existing ND2CUBE for every valid element and definedness result.

## Memory effects and ordering

### Memory effects

- Dense NCHW/DN and NHWC/ND source indices are computed with wide unsigned arithmetic; spatial OOB and Cin padding lanes produce defined raw zero without a GM access.
- Physical storage tails are not written or marked defined.

### Ordering

- All schema, dimensions, crop, distribution, address, capacity, translation, permission, readiness, allocation, alias, and PE consistency checks precede source reads, destination payload, definedness, or publication.
- Shared output publishes a complete generation atomically; failure preserves the previous generation.

## Exceptions

- Reserved or unsupported DataType, malformed B.IOR sequence, wrong layout direction, invalid dimensions/crop/capacity, unsupported destination binding, address overflow, translation/permission, readiness, allocation, or PE consistency raises the applicable fault before GM access or visible target effects.

## Examples

- BSTART.TIMG2COL FP16; B.DIM LB0, ValidCol; B.DIM LB1, ValidRow; B.DIM LB2, TotalCol; B.IOR GMBase, zero, zero; B.IOR ParamGPR0, ParamGPR1, ParamGPR2; B.IOS PE_MASK, ->S0<SizeCode>; B.ASSEMBLE 1, 1, zero, 0, ParentSizeCode; BSTOP
