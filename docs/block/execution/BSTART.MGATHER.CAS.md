<!-- GENERATED FROM: asl/block/execution/BSTART.MGATHER.CAS.asl -->
# BSTART.MGATHER.CAS

**Normative ASL source:** `asl/block/execution/BSTART.MGATHER.CAS.asl`

Atomically compare and conditionally replace GM elements at signed or unsigned byte displacements.

## Normative identity {#PTO-INST-BLOCK-BSTART-MGATHER-CAS}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-purpose role=purpose -->
## What BSTART.MGATHER.CAS contributes

`BSTART.MGATHER.CAS` is a 32-bit block-start command for the MGATHER.CAS form. It establishes the pending block identity and selectors; the completed block, not the start command alone, owns body execution and result commitment.

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-mechanism role=mechanism -->
## Placement and mechanism

Header commands execute sequentially after the start, while `BSTOP` or the next `BSTART` is the boundary that validates and retires the completed block. The current owner gives this exact composition checklist:

```text
BSTART.MGATHER.CAS DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT IndexTile, ExpectedTile, mask=PE_MASK
B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

After any active predecessor is retired successfully, the command initializes the new pending `BARG` or operation descriptor and continues header execution at the sequential PC. No block destination or memory result becomes visible merely because the start decoded.

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-inputs role=inputs-outputs -->
## Operands and header roles

- `DataType` selects the element data type or inheritance sentinel; its exact assigned domain remains in the generated contract below.

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-effects role=effects -->
## Pending state and completion

The start transition is all-or-nothing with predecessor retirement for applicability and target checks. After the start succeeds, the later completion boundary validates the full composition before any body result can commit.

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-constraints role=constraints -->
## Legality and fault boundary

Reserved selectors, invalid targets, malformed completed composition, or failed predecessor retirement are rejected before new-block or body effects.

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART.MGATHER.CAS DataType
```

Assume predecessor retirement and target checks succeed. `BSTART.MGATHER.CAS DataType` opens the pending `BSTART.MGATHER.CAS` form; subsequent header/body commands remain provisional until `BSTOP` or the next `BSTART` validates the complete composition.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MGATHER.CAS DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mgather_cas_32_fd8c8a3b720a | L32 | 32 | 0x00811181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mgather_cas_32_fd8c8a3b720a | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_mgather_cas_32_fd8c8a3b720a | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | transfer, comparison, replacement, and destination element type | Encoded zero selects FP64. |

- `bstart_mgather_cas_32_fd8c8a3b720a.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | transfer, comparison, replacement, and destination element type |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MGATHER.CAS.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MGATHER_CAS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mgather_cas_32_fd8c8a3b720a);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.CAS DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT IndexTile, ExpectedTile, mask=PE_MASK
B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MGATHER.CAS.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MGATHER_CAS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MGATHER_CAS()
    => TileOperation
begin
    return TileOperation_MGATHER_CAS;
end;

pure func InstructionContractStartsTileBundle_BSTART_MGATHER_CAS()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is always encoded and selects the transfer, comparison, replacement, and destination element type.
- The completed schema requires explicit B.IOR: RegSrc0 supplies the per-PE byte-address base; RegSrc1, RegSrc2, and RegDst must encode zero. Omitted LB1 defaults to one, omitted LB2 defaults to LB0, and omitted B.DATR uses the operation defaults.
- Each IndexTile logical element is a signed or unsigned byte displacement relative to BaseGPR.

## Legality

- bstart_mgather_cas_32_fd8c8a3b720a.DataType accepts only 0..14, 16..20, and 24..28 at decode; all other encodings are reserved.
- Indexed TLSU transfer additionally rejects E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 because MGATHER.CAS carries no nibble selector.
- The body must complete the exact two-B.IOT Local schema documented by PTO-TILE-MGATHER-CAS. B.IOS and extra bindings are not accepted.
- PE_MASK=0000 is a strict no-op before all schema, GPR, source, dimension, allocation, address, and fault checks.
- IndexTile must be allocated, fully defined, generically indexable, and use S32 or U32. Each logical element is sign- or zero-extended as a byte displacement.
- B.IOR RegSrc0 supplies the per-PE byte-address base; RegSrc1, RegSrc2, and RegDst must encode zero.

## State effects

- Closes any preceding block, initializes a TileMemory descriptor, and selects TLSU function 8 with the encoded transfer DataType.
- No destination is allocated until the completed block passes schema, source, dimension, and complete access preflight.

## Memory effects and ordering

### Memory effects

- For each valid coordinate, atomically access BaseGPR plus the corresponding signed or unsigned byte displacement from IndexTile.
- All lane addresses are preflighted before the first atomic event. Duplicate-address lanes serialize in an implementation-defined order.

### Ordering

- Each valid lane is one atomic read-modify-write under the block aq/rl attributes. No fixed order is defined between duplicate-address lanes or between PEs.

## Exceptions

- Reserved DataType encodings raise Fault_IllegalInstruction before architectural effects.
- At bundle completion, malformed two-command B.IOT composition, missing B.IOR or LB0, packed transfer types, non-S32/U32 indices, mismatched source type or shape, invalid dimensions, or any read/write access fault is rejected before destination allocation, atomic events, or memory writes.

## Examples

- BSTART.MGATHER.CAS DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, ExpectedTile, mask=PE_MASK; B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
