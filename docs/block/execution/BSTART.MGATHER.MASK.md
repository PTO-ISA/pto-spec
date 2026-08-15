<!-- GENERATED FROM: asl/block/execution/BSTART.MGATHER.MASK.asl -->
# BSTART.MGATHER.MASK

**Normative ASL source:** `asl/block/execution/BSTART.MGATHER.MASK.asl`

Begins a predicate-masked TLSU byte-displacement gather block.

## Normative identity {#PTO-INST-BLOCK-BSTART-MGATHER-MASK}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
BSTART.MGATHER.MASK DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mgather_mask_32_5573241cd944 | L32 | 32 | 0x00611181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mgather_mask_32_5573241cd944 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_mgather_mask_32_5573241cd944 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | transfer and destination element type | Encoded zero selects FP64. |

- `bstart_mgather_mask_32_5573241cd944.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | transfer and destination element type |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MGATHER.MASK.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MGATHER_MASK(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mgather_mask_32_5573241cd944);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.MASK DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MGATHER.MASK.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MGATHER_MASK() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is always encoded and selects the transfer and destination element type.
- The completed schema requires explicit B.IOR and LB0. Omitted LB1 defaults to one, omitted LB2 defaults to LB0, and omitted B.DATR selects Null padding with NORM layout.

## Legality

- bstart_mgather_mask_32_5573241cd944.DataType accepts only 0..14, 16..20, and 24..28 at decode; all other encodings are reserved.
- Indexed TLSU transfer additionally rejects E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 because MGATHER.MASK carries no nibble selector.
- The body must complete the exact single-B.IOT Local schema documented by PTO-TILE-MGATHER-MASK. B.IOS and extra bindings are not accepted.
- PE_MASK=0000 is a strict no-op before all schema, GPR, source, predicate, dimension, allocation, address, and fault checks.

## State effects

- Closes any preceding block, initializes a TileMemory descriptor, and selects TLSU function 6 with the encoded transfer DataType.
- No destination is allocated until the completed block passes schema, predicate, source, dimension, and enabled-address preflight.

## Memory effects and ordering

### Memory effects

- The start itself performs no memory access. BSTOP or the next BSTART preflights and loads only lanes whose exact predicate value is one.
- Disabled lanes perform no memory-side operation and receive PadValue together with every non-valid physical destination coordinate.

### Ordering

- Enabled loads use the block aq/rl attributes and PTO memory-order domain. No additional lane or inter-PE issue order is defined.

## Exceptions

- Reserved DataType encodings raise Fault_IllegalInstruction before architectural effects.
- At bundle completion, malformed B.IOT composition, missing B.IOR or LB0, packed transfer types, non-integer indices, predicate values other than zero or one, source shape or layout mismatch, invalid dimensions, or any enabled-lane access fault is rejected before destination allocation, memory events, or memory reads.

## Examples

- BSTART.MGATHER.MASK DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
