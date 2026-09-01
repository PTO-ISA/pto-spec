<!-- GENERATED FROM: asl/block/execution/BSTART.MSCATTER.asl -->
# BSTART.MSCATTER

**Normative ASL source:** `asl/block/execution/BSTART.MSCATTER.asl`

Begins a strided indexed TLSU scatter block.

## Normative identity {#PTO-INST-BLOCK-BSTART-MSCATTER}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mscatter-purpose role=purpose -->
## What BSTART.MSCATTER contributes

`BSTART.MSCATTER` is a 32-bit block-start command for the MSCATTER form. It establishes the pending block identity and selectors; the completed block, not the start command alone, owns body execution and result commitment.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-mechanism role=mechanism -->
## Placement and mechanism

Header commands execute sequentially after the start, while `BSTOP` or the next `BSTART` is the boundary that validates and retires the completed block. The current owner gives this exact composition checklist:

```text
BSTART.MSCATTER DataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT DataTile, IndexTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

After any active predecessor is retired successfully, the command initializes the new pending `BARG` or operation descriptor and continues header execution at the sequential PC. No block destination or memory result becomes visible merely because the start decoded.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-inputs role=inputs-outputs -->
## Operands and header roles

- `DataType` selects the element data type or inheritance sentinel; its exact assigned domain remains in the generated contract below.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-effects role=effects -->
## Pending state and completion

The start transition is all-or-nothing with predecessor retirement for applicability and target checks. After the start succeeds, the later completion boundary validates the full composition before any body result can commit.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-constraints role=constraints -->
## Legality and fault boundary

Reserved selectors, invalid targets, malformed completed composition, or failed predecessor retirement are rejected before new-block or body effects.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART.MSCATTER DataType
```

Assume predecessor retirement and target checks succeed. `BSTART.MSCATTER DataType` opens the pending `BSTART.MSCATTER` form; subsequent header/body commands remain provisional until `BSTOP` or the next `BSTART` validates the complete composition.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MSCATTER DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_32_0f0ba08bd798 | L32 | 32 | 0x00511181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_32_0f0ba08bd798 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_mscatter_32_0f0ba08bd798 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | memory transfer element type selector | Encoded zero selects FP64. |

- `bstart_mscatter_32_0f0ba08bd798.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | memory transfer element type selector |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |
| B.IOR.RegSrc1 | per-PE private-GPR GM row stride in elements |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MSCATTER.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MSCATTER(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mscatter_32_0f0ba08bd798);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER DataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT DataTile, IndexTile, mask=PE_MASK, <last>
B.IOR BaseGPR, StrideGPR, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MSCATTER.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MSCATTER() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MSCATTER()
    => TileOperation
begin
    return TileOperation_MSCATTER;
end;

pure func InstructionContractStartsTileBundle_BSTART_MSCATTER()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is always encoded and selects the memory transfer type.
- The completed schema requires explicit B.IOR: RegSrc0 supplies the per-PE GM base address and RegSrc1 supplies a nonzero GM row stride in elements no smaller than ValidCol. RegSrc2 and RegDst remain zero. Omitted LB1 defaults to one, omitted LB2 defaults to LB0, and omitted B.DATR uses the operation defaults.

## Legality

- bstart_mscatter_32_0f0ba08bd798.DataType accepts only 0..14, 16..20, and 24..28 at decode; all other encodings are reserved.
- Indexed TLSU transfer additionally rejects E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 because MSCATTER carries no nibble selector.
- The body must complete the exact MSCATTER schema documented by PTO-TILE-MSCATTER; no B.IOS or destination is accepted.
- B.IOR RegSrc0 supplies the per-PE GM base and RegSrc1 supplies the GM row stride in elements. RegSrc1 must be at least ValidCol; RegSrc2 and RegDst must be zero.

## State effects

- Closes any preceding block, initializes a new TileMemory descriptor, and selects TLSU function 5 with the encoded transfer DataType.
- No Tile is allocated and no source is consumed by the start instruction.

## Memory effects and ordering

### Memory effects

- The start itself performs no memory access. BSTOP or the next BSTART commits the completed strided indexed scatter only after full preflight.

### Ordering

- The start defines no ordering. B.CATR attributes apply when the completed block commits.

## Exceptions

- Reserved DataType encodings raise Fault_IllegalInstruction before architectural effects.
- Malformed composition, source/type/shape/layout mismatch, packed transfer types, or access faults reject the complete block before any store or event effect.

## Examples

- BSTART.MSCATTER DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK, <last>; B.IOR BaseGPR, StrideGPR, zero, ->zero; BSTOP
