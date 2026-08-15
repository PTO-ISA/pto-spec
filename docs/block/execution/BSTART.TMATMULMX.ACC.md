<!-- GENERATED FROM: asl/block/execution/BSTART.TMATMULMX.ACC.asl -->
# BSTART.TMATMULMX.ACC

**Normative ASL source:** `asl/block/execution/BSTART.TMATMULMX.ACC.asl`

Starts CUBE Function 6 for the TMATMUL_MX_ACC Matrix-matrix complete-bundle operation.

## Normative identity {#PTO-INST-BLOCK-BSTART-TMATMULMX-ACC}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
BSTART.TMATMULMX.ACC DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tmatmulmx_acc_32_70fa59b0ab4c | L32 | 32 | 0x00631181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tmatmulmx_acc_32_70fa59b0ab4c | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_tmatmulmx_acc_32_70fa59b0ab4c | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | tile element data type selector | Encoded zero selects FP64. |

- `bstart_tmatmulmx_acc_32_70fa59b0ab4c.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | tile element data type selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TMATMULMX.ACC.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TMATMULMX_ACC(
    operation: CommandOperation) => boolean
begin
    return operation ==
        CommandOperation_bstart_tmatmulmx_acc_32_70fa59b0ab4c;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TMATMULMX.ACC AType
B.DATR BType, RMode, Sat (optional; BType defaults to AType)
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one)
B.DIM LB0 M (optional, default 1)
B.DIM LB1 N (optional, default 1)
B.DIM LB2 K (optional, default 1)
B.IOS complete right or both matrix operand groups (optional; executing mask 1111)
B.IOT ordered Local mathematical sources: C accumulator, A matrix, optional A scale, B matrix, optional B scale
B.IOT D, optional RowMaxOut, optional GroupMaxOut destinations
B.IOT/B.IOR postprocess operands selected by B.FPATR
BSTOP or the next BSTART completion boundary
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TMATMULMX.ACC.asl -->
```asl
readonly func InstructionContractTileOperation_BSTART_TMATMULMX_ACC()
    => TileOperation
begin
    return TileOperation_TMATMUL_MX_ACC;
end;

readonly func InstructionContractCubeFunction_BSTART_TMATMULMX_ACC()
    => integer {0..31}
begin
    return 6;
end;

readonly func InstructionContractSharedOperandsAllowed_BSTART_TMATMULMX_ACC()
    => boolean
begin
    return TRUE;
end;

readonly func InstructionContractHandler_BSTART_TMATMULMX_ACC()
    => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.
- Omitted LB0, LB1, and LB2 default M, N, and K independently to one.
- Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.

## Legality

- The carrier selects exactly CUBE Function 6 and TileOperation_TMATMUL_MX_ACC.
- Each matrix side independently requires an E8M0 scale exactly when its MX input type is not FP16 or BF16. C is one explicit Local MxN accumulator source and D is a newly published destination; C and D may use one architectural Tile name. Published Shared operands may replace the right group or both matrix groups; supplementary operands and destinations remain Local.
- Every executing Local or Shared binding uses PE_MASK=1111; mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.
- B.DATR permits only BType, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.

## State effects

- Start a CUBE Function 6 descriptor with encoded DataType preserved as AType.
- At block completion execute TileOperation_TMATMUL_MX_ACC using the resolved M, N, K, input types, mathematical operands, and B.FPATR postprocess schema.
- Publish the complete output group atomically after successful preflight and computation; do not consume mathematical or postprocess sources.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, field, type, dimension, descriptor, shape, capacity, readiness, alias, and allocation preflight precedes every source snapshot and destination effect.
- D and every enabled reduction output publish as one atomic group; rejection publishes none and successful sources persist.

## Exceptions

- A reserved DataType or fixed-bit mismatch raises Fault_IllegalInstruction before block state changes.
- Missing, duplicate, or non-Matrix B.FPATR use raises Fault_BundleControl before allocation or payload effects.
- Illegal types, dimensions, masks, binding streams, descriptors, shapes, capacities, aliases, readiness, or postprocess values raise Fault_TileLegality before source snapshots and effects.

## Examples

- BSTART.TMATMULMX.ACC AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one); B.DIM LB0 M (optional, default 1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOS complete right or both matrix operand groups (optional; executing mask 1111); B.IOT ordered Local mathematical sources: C accumulator, A matrix, optional A scale, B matrix, optional B scale; B.IOT D, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
