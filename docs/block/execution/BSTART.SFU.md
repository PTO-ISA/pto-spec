<!-- GENERATED FROM: asl/block/execution/BSTART.SFU.asl -->
# BSTART.SFU

**Normative ASL source:** `asl/block/execution/BSTART.SFU.asl`

Canonical Block-start spelling for an operation assigned to the SFU execution engine.

## Normative identity {#PTO-INST-BLOCK-BSTART-SFU}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-sfu-purpose role=purpose -->
## What BSTART.SFU contributes

`BSTART.SFU` is the canonical spelling for starting a block whose operation runs on the SFU engine, for example `TEXP`, `TDIV`, or `TSQRT`. It is an encoding alias: it has no bits of its own. `BSTART.SFU TileOp, DataType` resolves `TileOp` to its `Mode:Function` selector and emits the [BSTART.TEPL](BSTART.TEPL.md) word with that selector and `DataType`.

Canonical assembly and disassembly use `BSTART.SFU` for every SFU operation, and [BSTART.VEC](BSTART.VEC.md) for every VEC operation.

<!-- PTO-READER-BLOCK: block-bstart-sfu-mechanism role=mechanism -->
## Placement and mechanism

The alias owner maps each piece to `BSTART.TEPL`: `InstructionContractMatches_BSTART_SFU` matches the TEPL form, and `InstructionContractHandler_BSTART_SFU` returns the TEPL handler, `CommandHandler_ExecuteBundleStart`. Execution is therefore exactly the TEPL path.

1. [Bundle start dispatch](../model/dispatch/start.md) checks the decoded descriptor before it commits any predecessor.
2. It commits the predecessor, opens a Tile-element block, and installs the descriptor.
3. At `BSTOP` or the next `BSTART`, [Tile execution dispatch](../model/dispatch/tile-execution.md) validates the bundle and runs the operation.

`TileTEPLAliasAcceptsOperation(TileTEPLAlias_SFU, operation)` defines which names the alias accepts: the operation must use the TEPL carrier and its execution engine must be SFU.

Design point: some SFU operations keep a TEPL selector that sits among VEC selectors. `TEXP` is `Mode` 0 `Function` 18, and `TDIV` is `Mode` 0 `Function` 3. The engine is a property of the operation, so the spelling follows the engine while the selector bits stay unchanged.

<!-- PTO-READER-BLOCK: block-bstart-sfu-inputs role=inputs-outputs -->
## Operands and header roles

- `TileOp` names an SFU operation carried by TEPL. It becomes `Mode` and `Function`.
- `DataType` is the element type, encoded as in `BSTART.TEPL`. It must be concrete.

The remaining header commands are those of the selected operation. For `TEXP`, they are `B.DIM LB0`, optional `LB1`, `LB2`, and `B.DATR`, and one terminating `B.IOT` with one Local source and a new Local destination.

<!-- PTO-READER-BLOCK: block-bstart-sfu-effects role=effects -->
## Pending state and completion

The alias adds no state. After the predecessor commits, the start installs exactly the TEPL descriptor for the resolved selector and `DataType`, sets the block kind to Tile element, and moves `TPC` to the next instruction.

The selected SFU operation runs only when the block commits. On success it publishes its destination atomically. On failure the block stays active and its destinations are rolled back. The start has no memory effect.

<!-- PTO-READER-BLOCK: block-bstart-sfu-constraints role=constraints -->
## Legality and fault boundary

`BSTART.SFU` accepts only a name that `TileTEPLAliasAcceptsOperation` admits for SFU. An unknown name, a VEC operation such as `TADD`, or a TLSU or CUBE operation has no `BSTART.SFU` spelling.

For the emitted word, the TEPL checks apply before predecessor commit: a reserved `DataType` code or an unassigned selector raises `Fault_IllegalInstruction`, and the active predecessor is left in place.

Design point: because the alias and `BSTART.TEPL` produce identical bits, no program can observe a difference between them. Both install the same descriptor and fault in the same way.

<!-- PTO-READER-BLOCK: block-bstart-sfu-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART.SFU TEXP, FP32
```

`TEXP` resolves to `Mode` 0 `Function` 18, and `FP32` is `DataType` 1, so the emitted word is `0x09219181`, the same word as `BSTART.TEPL 0, 18, FP32`. A complete bundle adds `B.DIM` commands and one `B.IOT` naming the source and the destination, then `BSTOP`. The same bundle is written in macro form as `TEXP <Row=8, Col=64, FP32>, T#1, ->T<2KB>`.
<!-- SUPPLEMENTARY-END -->

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
| bstart_tepl_32_d022db6dacb3 | L32 | 32 | 0x00019181 / 0x000fffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,24,25,26,27,28]}] |

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
