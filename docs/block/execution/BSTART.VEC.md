<!-- GENERATED FROM: asl/block/execution/BSTART.VEC.asl -->
# BSTART.VEC

**Normative ASL source:** `asl/block/execution/BSTART.VEC.asl`

Canonical Block-start spelling for an operation assigned to the VEC execution engine.

## Normative identity {#PTO-INST-BLOCK-BSTART-VEC}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-vec-purpose role=purpose -->
## What BSTART.VEC does

`BSTART.VEC` is the canonical spelling for starting a block whose operation runs on the VEC engine, for example `TADD`, `TSUB`, `TMUL`, or `TMAX`. It is an encoding alias: it has no bits of its own. `BSTART.VEC TileOp, DataType` resolves `TileOp` to its `Mode:Function` selector and emits the [BSTART.TEPL](BSTART.TEPL.md) word with that selector and `DataType`.

Canonical assembly and disassembly use `BSTART.VEC` for every VEC operation, and [BSTART.SFU](BSTART.SFU.md) for every SFU operation.

<!-- PTO-READER-BLOCK: block-bstart-vec-mechanism role=mechanism -->
## Placement and execution mechanism

The alias owner maps each piece to `BSTART.TEPL`: `InstructionContractMatches_BSTART_VEC` matches the TEPL form, and `InstructionContractHandler_BSTART_VEC` returns the TEPL handler, `CommandHandler_ExecuteBundleStart`. Execution is therefore exactly the TEPL path.

1. [Bundle start dispatch](../model/dispatch/start.md) checks the decoded descriptor before it commits any predecessor.
2. It commits the predecessor, opens a Tile-element block, and installs the descriptor.
3. At `BSTOP` or the next `BSTART`, [Tile execution dispatch](../model/dispatch/tile-execution.md) validates the bundle and runs the operation.

`TileTEPLAliasAcceptsOperation(TileTEPLAlias_VEC, operation)` defines which names the alias accepts: the operation must use the TEPL carrier and its execution engine must be VEC.

Design point: the engine name lives in the spelling, not in the bits. One encoding carries both engines, and the assembler picks `BSTART.VEC` or `BSTART.SFU` from the operation's engine, so a reader sees which engine runs the block without adding an encoding field.

<!-- PTO-READER-BLOCK: block-bstart-vec-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- `TileOp` names a VEC operation carried by TEPL. It becomes `Mode` and `Function`; `TADD` is `Mode` 0 `Function` 0, `TSUB` is `Function` 1, and `TMAX` is `Function` 11.
- `DataType` is the element type, encoded as in `BSTART.TEPL`. It must be concrete.

The remaining header commands are those of the selected operation. For `TADD`, they are `B.DIM LB0`, optional `LB1`, `LB2`, and `B.DATR`, and one terminating `B.IOT` with two Local sources and a new Local destination.

<!-- PTO-READER-BLOCK: block-bstart-vec-effects role=effects -->
## State effects and ordering

The alias adds no state. After the predecessor commits, the start installs exactly the TEPL descriptor for the resolved selector and `DataType`, sets the block kind to Tile element, and moves `TPC` to the next instruction.

The selected VEC operation runs only when the block commits. On success it publishes its destination atomically. On failure the block stays active and its destinations are rolled back. The start has no memory effect.

<!-- PTO-READER-BLOCK: block-bstart-vec-constraints role=constraints -->
## Legality, faults, and atomicity

`BSTART.VEC` accepts only a name that `TileTEPLAliasAcceptsOperation` admits for VEC. An unknown name, an SFU operation such as `TEXP`, or a TLSU or CUBE operation has no `BSTART.VEC` spelling.

For the emitted word, the TEPL checks apply before predecessor commit: a reserved `DataType` code or an unassigned selector raises `Fault_IllegalInstruction`, and the active predecessor is left in place.

Design point: because the alias and `BSTART.TEPL` produce identical bits, no program can observe a difference between them. Both install the same descriptor and fault in the same way.

<!-- PTO-READER-BLOCK: block-bstart-vec-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
BSTART.VEC TADD, FP32
```

`TADD` resolves to `Mode` 0 `Function` 0, and `FP32` is `DataType` 1, so the emitted word is `0x08019181`, the same word as `BSTART.TEPL 0, 0, FP32`. A complete bundle adds `B.DIM` commands and one `B.IOT` naming the two sources and the destination, then `BSTOP`. The same bundle is written in macro form as `TADD <Row=8, Col=64, FP32>, T#1, T#2, ->T<2KB>`.
<!-- SUPPLEMENTARY-END -->

## Alias contract

- **Encoding owner:** `BSTART.TEPL`
- **Canonical engine:** `VEC`

## Assembly

```asm
BSTART.VEC TileOp, DataType
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
| TileOp | assigned VEC operation mnemonic that resolves the Mode:Function selector |
| DataType | tile element data type selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.VEC.asl -->
```asl
readonly func InstructionContractMatches_BSTART_VEC(
    operation: CommandOperation) => boolean
begin
    return InstructionContractMatches_BSTART_TEPL(operation);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
TileOp resolves to one assigned TEPL Mode:Function selector whose execution engine is VEC; the alias adds no encoding bits or ownership.
The resulting block uses the same descriptor, header composition, commit, and rollback rules as BSTART.TEPL.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.VEC.asl -->
```asl
readonly func InstructionContractHandler_BSTART_VEC() => CommandSemanticHandler
begin
    return InstructionContractHandler_BSTART_TEPL();
end;

pure func InstructionContractAliasEngine_BSTART_VEC() => TileExecutionEngine
begin
    return TileEngine_VEC;
end;

pure func InstructionContractAcceptsTileOperation_BSTART_VEC(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileTEPLAliasAcceptsOperation(TileTEPLAlias_VEC, operation);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- BSTART.VEC is a canonical engine alias for BSTART.TEPL; it owns no separate encoding or default.

## Legality

- TileOp must name an assigned direct operation carried by BSTART.TEPL and assigned to VEC.
- The spelling owns no separate encoding; the resolved Mode:Function and DataType bits are exactly the BSTART.TEPL carrier bits.
- Canonical assembly and disassembly use BSTART.VEC for every VEC operation.

## State effects

- Installs exactly the BSTART.TEPL descriptor resolved from TileOp and DataType; this alias has no additional state.
- The selected VEC operation executes only when the block commits.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Alias resolution, VEC-engine match, carrier fields, and descriptor legality precede predecessor retirement and BARG publication.

## Exceptions

- An unknown TileOp, selector hole, SFU/TLSU/CUBE operation, reserved DataType, or invalid descriptor raises before predecessor retirement or new BARG effects.

## Examples

- BSTART.VEC TADD, FP32
