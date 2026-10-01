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

`BSTART.TIMG2COL` opens a Tile memory bundle whose operation is IMG2COL: it reads a convolution input image from global memory (GM) and writes it as a matrix. Each matrix row is one output pixel, and each matrix column is one kernel position and input channel, grouped in 32-byte `C0` channel groups. The command is one 32-bit word (match `0x01c11181`, mask `0x07ffffff`) with `DataType` in bits 31 to 27. It is command form 94 and carries the fixed TLSU selector 28.

The result goes to one of two places: a Shared Tile in ordinary row-major (ND) order, or a Local Tile in `CUBE_M16` or `CUBE_M32` layout, ready for the CUBE engine.

Design point: [descriptor legality](../model/dispatch/descriptor-legality.md) has a dedicated rule for form 94. The descriptor is legal only as the exact TIMG2COL descriptor with a supported `DataType`. An unsupported code therefore raises `Fault_IllegalInstruction` at the `BSTART`, before [bundle start dispatch](../model/dispatch/start.md) commits any predecessor.

<!-- PTO-READER-BLOCK: block-bstart-timg2col-mechanism role=mechanism -->
## Placement and mechanism

At commit, [Tile execution](../model/dispatch/tile-execution.md) tests the TIMG2COL selector first and calls [TIMG2COL execution](../model/dispatch/timg2col-execution.md). It skips the generic effect-eligibility check, stage-2 preparation, Local continuation reuse, and ExecutionMask capture for this operation. The handler validates the whole bundle, then builds the matrix.

The `B.DATR` layout picks the output. `ND2M16` (code 22) and code 31 select Local M16; `ND2M32` (code 21) and code 29 select Local M32; `NORM` (code 0), `DN2ND` (code 6), or an absent `B.DATR` select Shared ND. Codes 6, 29, and 31 read the image through the channel-major (DN, NCHW) index; the other layouts use the channel-minor (ND, NHWC) index. The geometry of each cell is defined by [TIMG2COL schema](../model/dispatch/timg2col-schema.md).

Design point: validation reads no memory, and `BundleTIMG2COLPreflightGM` then probes every GM address of all ValidRow rows before the first load. A translation or permission fault leaves no load event, allocation, or Shared generation change behind.

Design point: a cell whose input coordinate falls in the spatial padding, or whose channel is not below `Cin`, is a defined raw zero with no GM access. Padding never faults and never records a load event.

<!-- PTO-READER-BLOCK: block-bstart-timg2col-inputs role=inputs-outputs -->
## Operands and header roles

- `DataType` is the element type: `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `HiF8`, `E4M3`, `E5M2`, `E8M0`, `S32`, `S16`, `S8`, `U32`, `U16`, or `U8`.
- An explicit `B.DATR` must use `DTYPE_NONE`, Zero pad (code 0), and zero comparison, rounding, saturation, and canonicalization controls; only its layout matters.
- `B.DIM` `LB0`, `LB1`, and `LB2` give ValidCol, ValidRow (1 to 128, at most 64 for Local M16), and TotalCol.
- Two contiguous source-only `B.IOR` records: the first is `GMBase, zero, zero`, the second is `ParamGPR0, ParamGPR1, ParamGPR2`. [TIMG2COL parameters](../model/operands/timg2col-parameters.md) defines the packing.
- Shared ND output uses exactly one `B.IOS` and no `B.IOT`. Local output uses exactly one destination `B.IOT` with `PE_MASK` `1111` and no `B.IOS`.

Design point: every participating PE must hold identical `GMBase` and parameter words. Each PE computes a different row share from the same geometry, so this check keeps all shares in one matrix; a mismatch rejects before any GM access.

<!-- PTO-READER-BLOCK: block-bstart-timg2col-effects role=effects -->
## Result and publication

ValidRow is split over the four PEs, filling PE 0 first. Local M16 uses 16 rows per PE and Local M32 uses 32; Shared ND uses 16 when ValidRow is at most 64 and 32 otherwise. A Local PE with zero rows allocates nothing and reads nothing, but stays a participant.

A Shared ND mask must be a single PE or `1111` and must include the current PE. A single PE must not use `B.ASSEMBLE` and publishes the Tile directly. With `1111`, `B.ASSEMBLE` is required: PE 0 carries INIT, PE 3 carries LAST, and PEs 1 and 2 carry neither. Its register and immediate must be zero, because the handler derives each writer's offset from the row start in 32-byte units. The parent publishes only when the gap-free LAST writer arrives.

Only the logical rectangle and its definedness are written; physical storage tails are neither written nor marked defined. A Local CUBE result equals the Shared ND result followed by the ordinary ND-to-CUBE conversion.

<!-- PTO-READER-BLOCK: block-bstart-timg2col-constraints role=constraints -->
## Legality and fault boundary

The crop must be `C0`-aligned: ValidCol, TotalCol, and ColStart are multiples of `C0`, ValidCol does not exceed TotalCol, `RowStart + ValidRow` does not exceed `Hout * Wout`, and `ColStart + ValidCol` does not exceed `KValid`. Nonzero parameter extension bits, zero sizes, and a wrong binding count also reject.

A failed check without a recorded fault becomes `Fault_TileLegality`; a memory fault keeps its own kind. On any failure `BundleTIMG2COLAbortFailedAttempt` aborts the Shared generation or rolls back the Local destination, so the previous Shared generation stays in place.

Design point: repeat, transpose, dual-source, and hidden descriptor state are outside this per-bundle interface, as the NDF clause `PTO-BSTART-TIMG2COL-CONTRACT-001` states. Every input of the operation is visible in the bundle's own commands and GPRs.

<!-- PTO-READER-BLOCK: block-bstart-timg2col-example role=example -->
## Non-normative worked example

This example sketches a cooperative Shared result; symbolic values stand for previously prepared GPRs or dimensions.

```asm
BSTART.TIMG2COL FP16
B.DIM zero, 64, ->LB0
B.DIM zero, 64, ->LB1
B.DIM zero, 64, ->LB2
B.IOR a0, zero, zero
B.IOR a1, a2, a3
B.IOS mask=1111, ->S0<7>
B.ASSEMBLE 1, 0, zero, 0, 5
BSTOP
```

This is the bundle of PE 0. PEs 1 and 2 bind `B.IOS S0, mask=1111` with `B.ASSEMBLE 0, 0, zero, 0, 5`, and PE 3 uses `B.ASSEMBLE 0, 1, zero, 0, 5`. With `FP16`, `C0` is 16. ValidRow 64 gives each PE 16 rows, and each writer covers 16 * 64 / 16 = 64 units of 32 bytes, at offsets 0, 64, 128, and 192. `SizeCode` 7 is 8192 bytes, or 256 units, so PE 3's LAST range ends exactly at 256 and the parent is published.
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
