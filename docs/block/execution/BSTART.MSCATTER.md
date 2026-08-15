<!-- GENERATED FROM: asl/block/execution/BSTART.MSCATTER.asl -->
# BSTART.MSCATTER

**Normative ASL source:** `asl/block/execution/BSTART.MSCATTER.asl`

Begins a TLSU byte-displacement scatter block and selects its transfer DataType.

## Normative identity {#PTO-INST-BLOCK-BSTART-MSCATTER}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

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
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MSCATTER.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MSCATTER() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is always encoded and selects the memory transfer type.
- The completed schema requires explicit B.IOR and LB0. Omitted LB1 defaults to one, omitted LB2 defaults to LB0, and omitted B.DATR selects NORM layout.

## Legality

- bstart_mscatter_32_0f0ba08bd798.DataType accepts only 0..14, 16..20, and 24..28 at decode; all other encodings are reserved.
- Indexed TLSU transfer additionally rejects E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 because MSCATTER carries no nibble selector.
- The body must complete the exact MSCATTER schema documented by PTO-TILE-MSCATTER; no B.IOS or destination is accepted.

## State effects

- Closes any preceding block, initializes a new TileMemory descriptor, and selects TLSU function 5 with the encoded transfer DataType.
- No Tile is allocated and no source is consumed by the start instruction.

## Memory effects and ordering

### Memory effects

- The start itself performs no memory access. BSTOP or the next BSTART commits the completed byte-displacement scatter only after full preflight.

### Ordering

- The start defines no ordering. B.CATR attributes apply when the completed block commits.

## Exceptions

- Reserved DataType encodings raise Fault_IllegalInstruction before architectural effects.
- Malformed composition, source/type/shape/layout mismatch, packed transfer types, or access faults reject the complete block before any store or event effect.

## Examples

- BSTART.MSCATTER DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK, <last>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
