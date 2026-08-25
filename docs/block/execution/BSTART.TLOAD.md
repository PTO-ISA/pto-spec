<!-- GENERATED FROM: asl/block/execution/BSTART.TLOAD.asl -->
# BSTART.TLOAD

**Normative ASL source:** `asl/block/execution/BSTART.TLOAD.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-TLOAD}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-tload-purpose role=purpose -->
## What BSTART.TLOAD contributes

`BSTART.TLOAD` is a 32-bit block-start command for the TLOAD form. It establishes the pending block identity and selectors; the completed block, not the start command alone, owns body execution and result commitment.

<!-- PTO-READER-BLOCK: block-bstart-tload-mechanism role=mechanism -->
## Placement and mechanism

Header commands execute sequentially after the start, while `BSTOP` or the next `BSTART` is the boundary that validates and retires the completed block. The current owner gives this exact composition checklist:

```text
Local destination: BSTART.TLOAD DataType; optional B.DATR Layout; B.DIM supplies ValidCol, ValidRow, and physical Col; optional B.IOR supplies per-PE base and byte row stride; exactly one terminating destination B.IOT allocates the Local result; BSTOP commits.
Shared destination: replace destination B.IOT with one destination B.IOS naming S0..S63, TSize, and PE_MASK. Each selected quarter uses that PE's private GPR base and stride.
Local CUBE destination: encode B.DATR Layout ND2M32, ND2M16, or ND2N8 with DataType=DTYPE_NONE; require LB0=valid columns and LB1=valid rows, omit LB2, and use one terminating destination B.IOT.
```

After any active predecessor is retired successfully, the command initializes the new pending `BARG` or operation descriptor and continues header execution at the sequential PC. No block destination or memory result becomes visible merely because the start decoded.

<!-- PTO-READER-BLOCK: block-bstart-tload-inputs role=inputs-outputs -->
## Operands and header roles

- `DataType` selects the element data type or inheritance sentinel; its exact assigned domain remains in the generated contract below.
- `B.IOR.RegSrc0` selects the named absolute GPR role; its exact assigned domain remains in the generated contract below.
- `B.IOR.RegSrc1` selects the named absolute GPR role; its exact assigned domain remains in the generated contract below.
- `B.DIM.LB0` supplies the named selector or attribute field; its exact assigned domain remains in the generated contract below.
- `B.DIM.LB1` supplies the named selector or attribute field; its exact assigned domain remains in the generated contract below.
- `B.DIM.LB2` supplies the named selector or attribute field; its exact assigned domain remains in the generated contract below.
- `B.IOT/B.IOS` identifies a destination or publication selector; its exact assigned domain remains in the generated contract below.

<!-- PTO-READER-BLOCK: block-bstart-tload-effects role=effects -->
## Pending state and completion

The start transition is all-or-nothing with predecessor retirement for applicability and target checks. After the start succeeds, the later completion boundary validates the full composition before any body result can commit.

<!-- PTO-READER-BLOCK: block-bstart-tload-constraints role=constraints -->
## Legality and fault boundary

Reserved selectors, invalid targets, malformed completed composition, or failed predecessor retirement are rejected before new-block or body effects.

<!-- PTO-READER-BLOCK: block-bstart-tload-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART.TLOAD DataType
```

Assume predecessor retirement and target checks succeed. `BSTART.TLOAD DataType` opens the pending `BSTART.TLOAD` form; subsequent header/body commands remain provisional until `BSTOP` or the next `BSTART` validates the complete composition.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TLOAD DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tload_32_d0c18bb0ab15 | L32 | 32 | 0x00011181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tload_32_d0c18bb0ab15 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_tload_32_d0c18bb0ab15 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | destination element data type | Encoded zero selects FP64. |

- `bstart_tload_32_d0c18bb0ab15.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | destination element data type |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |
| B.IOR.RegSrc1 | per-PE private-GPR byte row stride |
| B.DIM.LB0 | ordinary ValidCol or CUBE valid columns |
| B.DIM.LB1 | ordinary ValidRow or CUBE valid rows |
| B.DIM.LB2 | ordinary physical Col; forbidden for CUBE conversion |
| B.IOT/B.IOS | Local or Shared destination, per-PE TSize, and participation mask |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TLOAD.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TLOAD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tload_32_d0c18bb0ab15);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Local destination: BSTART.TLOAD DataType; optional B.DATR Layout; B.DIM supplies ValidCol, ValidRow, and physical Col; optional B.IOR supplies per-PE base and byte row stride; exactly one terminating destination B.IOT allocates the Local result; BSTOP commits.
Shared destination: replace destination B.IOT with one destination B.IOS naming S0..S63, TSize, and PE_MASK. Each selected quarter uses that PE's private GPR base and stride.
Local CUBE destination: encode B.DATR Layout ND2M32, ND2M16, or ND2N8 with DataType=DTYPE_NONE; require LB0=valid columns and LB1=valid rows, omit LB2, and use one terminating destination B.IOT.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TLOAD.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TLOAD() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_TLOAD()
    => TileOperation
begin
    return TileOperation_TLOAD;
end;

pure func InstructionContractStartsTileBundle_BSTART_TLOAD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractCubeLayoutLegal_BSTART_TLOAD(
    data_layout: bits(5)) => boolean
begin
    return TileDataLayoutConversionIsLoad(data_layout);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is explicit. Optional B.DATR omission retains the default NORM layout.
- LB0/ValidCol and LB1/ValidRow default through the common destination-shape contract; omitted LB2/Col defaults to ValidCol. Rows are derived from TSize, Col, and DataType and must be at least ValidRow.
- Omitted B.IOR supplies base zero. Ordinary forms use resolved Col and CUBE forms use LB0 valid columns to derive dense byte row stride as ceil(columns * element_bits / 8). An explicitly encoded zero selector reads the zero GPR value and therefore supplies a real zero base or zero stride.

## Legality

- DataType accepts 0..14, 16..20, and 24..28; all other codes are reserved before effects.
- Exactly one destination domain is used: a terminating destination B.IOT for Local or one destination B.IOS for Shared. Source Tile bindings and mixed Local/Shared destinations are illegal.
- ValidCol and ValidRow must be nonzero and no greater than derived physical Col and Rows; Col and Rows are powers of two under the common Tile descriptor contract.
- PE_MASK=0000 is a strict no-op before GPR reads, allocation, memory access, faults, or descriptor changes.
- CUBE conversion accepts only Layout codes 21 through 23, requires explicit DTYPE_NONE, explicit nonzero LB0/LB1, absent LB2, one Local destination B.IOT, a supported non-64-bit non-HiF4X2 dtype, and no B.IOS.

## State effects

- Allocates/renames one Local destination or reallocates the named Shared destination with Rows derived from TSize, Col, and DataType, then fills selected valid elements and marks their definedness.
- Unselected PE regions remain unchanged for Shared partial-mask updates; a Local result is published through its architectural destination hand only after successful commit.
- A successful CUBE form installs a persistent Matrix-location descriptor with CELL geometry derived from Layout, BSTART DataType, LB1 valid rows, and LB0 valid columns; TSize remains capacity only.

## Memory effects and ordering

### Memory effects

- For every selected PE and every element in ValidRow x ValidCol, read GM at base + row * row_stride_bytes + column * element_size, with packed four-bit columns adding floor(column / 2) to the byte-strided row base and selecting low/high by column parity.
- All accesses participate in PTO-TSO with the block's aq/rl attributes and are precise and restartable.

### Ordering

- Resolve and validate the full schema, dimensions, masks, per-PE GPR inputs, destination allocation, and complete memory footprint before the first architectural load effect.
- On success publish the complete destination atomically at block commit; on failure preserve prior destination and block-visible state for restart.

## Exceptions

- Reserved DataType, unsupported Layout, invalid dimensions, capacity/shape overflow, inconsistent or illegal PE masks, malformed binding schema, allocation failure, or memory translation/permission/alignment fault rejects before destination publication.
- The complete selected-PE footprint is preflighted before any Local or Shared destination payload or descriptor becomes visible.

## Examples

- BSTART.TLOAD U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR zero, a0; B.IOT mask=1111, ->T<1>; BSTOP
- BSTART.TLOAD FP16; B.DIM LB0, 32; B.DIM LB1, 4; B.IOS mask=0011, ->S7<1>; BSTOP
- BSTART.TLOAD FP16; B.DATR {ND2M16, DTYPE_NONE, Null, EQ, Default, 0, 0}; B.DIM LB0=K; B.DIM LB1=M; B.IOT mask=1111, <last>, ->M<1>; BSTOP
