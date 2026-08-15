<!-- GENERATED FROM: asl/block/execution/BSTART.SFU.asl -->
# BSTART.SFU

**Normative ASL source:** `asl/block/execution/BSTART.SFU.asl`

Canonical Block-start spelling for an operation assigned to the SFU execution engine.

## Normative identity {#PTO-INST-BLOCK-BSTART-SFU}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Alias contract

- **Encoding owner:** `BSTART.TEPL`
- **Canonical engine:** `SFU`

## Assembly

```asm
BSTART.SFU TileOp, DataType
```

## Encoding

This spelling reuses the exact encoding owned by `BSTART.TEPL`.

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tepl_32_d022db6dacb3 | L32 | 32 | 0x00019181 / 0x000fffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tepl_32_d022db6dacb3 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| bstart_tepl_32_d022db6dacb3 | Mode | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| bstart_tepl_32_d022db6dacb3 | Function | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `encoding-alias`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

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

## Operands and results

| Field | Architectural role |
| --- | --- |
| TileOp | assigned SFU operation mnemonic that resolves the Mode:Function selector |
| DataType | tile element data type selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.SFU.asl -->
```asl
readonly func InstructionContractMatches_BSTART_SFU(
    operation: CommandOperation) => boolean
begin
    return InstructionContractMatches_BSTART_TEPL(operation);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
TileOp resolves to one assigned TEPL Mode:Function selector whose execution engine is SFU; the alias adds no encoding bits or ownership.
The resulting block uses the same descriptor, header composition, commit, and rollback rules as BSTART.TEPL.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.SFU.asl -->
```asl
readonly func InstructionContractHandler_BSTART_SFU() => CommandSemanticHandler
begin
    return InstructionContractHandler_BSTART_TEPL();
end;

pure func InstructionContractAliasEngine_BSTART_SFU() => TileExecutionEngine
begin
    return TileEngine_SFU;
end;

pure func InstructionContractAcceptsTileOperation_BSTART_SFU(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileTEPLAliasAcceptsOperation(TileTEPLAlias_SFU, operation);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- BSTART.SFU is a canonical engine alias for BSTART.TEPL; it owns no separate encoding or default.

## Legality

- TileOp must name an assigned direct operation carried by BSTART.TEPL and assigned to SFU.
- The spelling owns no separate encoding; the resolved Mode:Function and DataType bits are exactly the BSTART.TEPL carrier bits.
- Canonical assembly and disassembly use BSTART.SFU for every SFU operation.

## State effects

- Installs exactly the BSTART.TEPL descriptor resolved from TileOp and DataType; this alias has no additional state.
- The selected SFU operation executes only when the block commits.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Alias resolution, SFU-engine match, carrier fields, and descriptor legality precede predecessor retirement and BARG publication.

## Exceptions

- An unknown TileOp, selector hole, VEC/TLSU/CUBE operation, reserved DataType, or invalid descriptor raises before predecessor retirement or new BARG effects.

## Examples

- BSTART.SFU TEXP, FP32

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
