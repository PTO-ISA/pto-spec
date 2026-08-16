<!-- GENERATED FROM: asl/block/attributes/B.DATR.asl -->
# B.DATR

**Normative ASL source:** `asl/block/attributes/B.DATR.asl`

Latches the optional per-block tile layout, data type, padding, comparison, rounding, saturation, and canonicalization attributes.

## Normative identity {#PTO-INST-BLOCK-B-DATR}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
B.DATR {layout, datatype, padvalue_or_byteid, cmode, rmode, sat, canonicalize}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_datr_32_c161a042ff38 | L32 | 32 | 0x00001023 / 0x000c707f | [{"field":"CMode","operator":"one-of","values":[0,1,2,3,4,5]},{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28,31]},{"field":"Layout","operator":"one-of","values":[0,1,3,4,6,8,9,17,18,20,27,28,30]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_datr_32_c161a042ff38 | CMode | 3 | encoding-defined | [{"instruction_lsb":29,"value_lsb":0,"width":3}] |
| b_datr_32_c161a042ff38 | PadValueOrByteId | 2 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":2}] |
| b_datr_32_c161a042ff38 | Sat | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| b_datr_32_c161a042ff38 | Canonicalize | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |
| b_datr_32_c161a042ff38 | DataType | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| b_datr_32_c161a042ff38 | RMode | 3 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":3}] |
| b_datr_32_c161a042ff38 | Layout | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Field value dispositions

### CMode (`PTO-FIELD-BLOCK-CMODE`)

Selects the comparison relation used by TCMP and TCMPS.

**Encoded zero:** Code zero selects equality comparison.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | EQ |
| 1 | assigned | NE |
| 2 | assigned | LT |
| 3 | assigned | GT |
| 4 | assigned | LE |
| 5 | assigned | GE |
| 6 | reserved | future extension |
| 7 | reserved | future extension |

**Reserved-value behavior:** Codes 6 and 7 are reserved and reject before architectural effects.

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

### PadValueOrByteId (`PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID`)

Carries the operation-selected PadValue or ByteId union field.

**Encoded zero:** For PadValue operations code zero selects Zero; for ByteId operations it selects ByteId zero.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | Zero-or-ByteId0 |
| 1 | assigned | Max-or-ByteId1 |
| 2 | assigned | Min-or-ByteId2 |
| 3 | assigned | Null-or-ByteId3 |

**Reserved-value behavior:** All four encodings are assigned; the selected operation separately validates whether the field is PadValue, ByteId, or inapplicable.

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_datr_32_c161a042ff38 | CMode | 3 | 0–5 | none | 6–7 | comparison predicate selector: 0 EQ, 1 NE, 2 LT, 3 GT, 4 LE, 5 GE | EQ |
| b_datr_32_c161a042ff38 | PadValueOrByteId | 2 | 0–3 | none | none | operation-selected padding value or byte identifier | Zero padding, or ByteId zero when the selected operation interprets the union as a byte identifier |
| b_datr_32_c161a042ff38 | Sat | 1 | 0–1 | none | none | saturation enable | disabled |
| b_datr_32_c161a042ff38 | Canonicalize | 1 | 0–1 | none | none | TCVT private-format canonicalization enable | disabled |
| b_datr_32_c161a042ff38 | DataType | 5 | 0–14, 16–20, 24–28, 31 | none | 15, 21–23, 29–30 | concrete Tile element type or DTYPE_NONE inheritance sentinel | FP64; code 31, not code zero, is DTYPE_NONE |
| b_datr_32_c161a042ff38 | RMode | 3 | 0–7 | none | none | rounding selector: 0 operation default, 1 RNE, 2 RTZ, 3 RTM, 4 RTP, 5 RNA, 6 RTO, 7 RHB | operation-defined default rounding |
| b_datr_32_c161a042ff38 | Layout | 5 | 0–1, 3–4, 6, 8–9, 17–18, 20, 27–28, 30 | none | 2, 5, 7, 10–16, 19, 21–26, 29, 31 | tile data layout selector | NORM |

- `b_datr_32_c161a042ff38.CMode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_datr_32_c161a042ff38.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_datr_32_c161a042ff38.Layout` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| Layout | tile data layout selector |
| DataType | concrete Tile element type or DTYPE_NONE inheritance sentinel |
| PadValueOrByteId | operation-selected padding value or byte identifier |
| CMode | comparison predicate selector: 0 EQ, 1 NE, 2 LT, 3 GT, 4 LE, 5 GE |
| RMode | rounding selector: 0 operation default, 1 RNE, 2 RTZ, 3 RTM, 4 RTP, 5 RNA, 6 RTO, 7 RHB |
| Sat | saturation enable |
| Canonicalize | TCVT private-format canonicalization enable |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/attributes/B.DATR.asl -->
```asl
readonly func InstructionContractMatches_B_DATR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_datr_32_c161a042ff38);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Optional header command after BSTART and before B.IOR, B.IOT, B.IOS, or the first body instruction; at most one B.DATR is permitted.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/attributes/B.DATR.asl -->
```asl
// DataType code 31 has the canonical spelling DTYPE_NONE. It is an encoded
// field sentinel, not a TileDataType. A concrete B.DATR type overrides the
// BSTART type; DTYPE_NONE preserves a concrete BSTART type and still latches
// the remaining B.DATR controls. If no concrete type can be resolved, complete
// bundle preflight raises Fault_TileLegality before allocation or effects.
readonly func InstructionContractHandler_B_DATR() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleDataAttributes;
end;

pure func InstructionContractHeaderOnly_B_DATR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractDuplicateRejects_B_DATR()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.DATR is optional. When omitted, DataType inherits the typed BSTART DataType, PadValueOrByteId supplies Null padding to pad-valued operations, and Layout, CMode, RMode, Sat, and Canonicalize retain their zero meanings.
- An explicit B.DATR encodes every field. Concrete DataType codes override the BSTART type; DTYPE_NONE preserves the BSTART type while latching the remaining controls. Encoded DataType zero selects FP64 and encoded PadValueOrByteId zero selects Zero padding or ByteId zero.

## Legality

- B.DATR may appear at most once, after BSTART and before the block body.
- DataType accepts the 25 concrete TileDataType codes plus code 31 DTYPE_NONE; codes 15, 21..23, and 29..30 are reserved and reject before effects.
- Layout must be one of codes 0, 1, 3, 4, 6, 8, 9, 17, 18, 20, 27, 28, or 30 and must be supported by the active profile.
- CMode codes 0..5 select EQ, NE, LT, GT, LE, and GE respectively; codes 6..7 are reserved.
- All RMode codes 0..7 are assigned: operation default, RNE, RTZ, RTM, RTP, RNA, RTO, and RHB.
- Canonicalize is legal only for TCVT; each selected tile operation separately constrains the applicable nonzero B.DATR fields and PadValueOrByteId interpretation.

## State effects

- Latch the accepted bundle data attributes for the current block and mark B.DATR present without modifying tile or memory state.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- A duplicate B.DATR or a B.DATR outside an active block header raises Illegal Block Exception before attribute state changes.
- Reserved DataType or CMode, unassigned Layout, unsupported Layout, or operation-inapplicable nonzero fields raise an architectural fault before effects.

## Examples

- B.DATR {NORM, FP32, Zero, None, RNE, 0, 0}

<!-- SUPPLEMENTARY-BEGIN -->
DataType code 31 is canonically spelled `DTYPE_NONE`. It is a valid encoded
field value, but it is not a `TileDataType` and has no width, arithmetic
meaning, or implicit U8/U32 default. Effective type resolution uses a concrete
`B.DATR.DataType`, then a concrete `BSTART.DataType`, then—only for TMOV—the
bound Local or Shared source descriptor. Thus `B.DATR DTYPE_NONE` preserves a
concrete BSTART type while its layout, padding, rounding, and other controls
still apply. If a concrete type remains unresolved, complete-bundle preflight
raises `Fault_TileLegality` before destination allocation or source effects.
<!-- SUPPLEMENTARY-END -->
