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

`BSTART.VEC` opens an active Block descriptor; the body supplies the attributes and bindings required before completion.

<!-- PTO-READER-BLOCK: block-bstart-vec-mechanism role=mechanism -->
## Placement and execution mechanism

`BSTART.VEC` must appear as the starter of its Block. Later attributes, dimensions, and bindings accumulate in the active descriptor until `BSTOP` or the next accepted `BSTART` completion boundary.

The accepted carrier uses the `encoding-alias` encoding class and resolves every displayed field before the command reads bindings or changes state.

At completion, the descriptor runs its selected Block operation only after all schema and state preflight succeeds.

<!-- PTO-READER-BLOCK: block-bstart-vec-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- Encoded operands: `TileOp` — assigned VEC operation mnemonic that resolves the Mode:Function selector; `DataType` — tile element data type selector.
- `BSTART.VEC` resolves `TileOp` through the `BSTART.TEPL` carrier and then uses that owner's descriptor, body composition, commit, and rollback rules.
- Encoded zero remains an assigned value or a specifically documented rejection; it never silently means an omitted operand.

<!-- PTO-READER-BLOCK: block-bstart-vec-effects role=effects -->
## State effects and ordering

Starting the Block records the selected carrier and leaves operation execution deferred until the completion boundary.

After complete preflight and computation, every enabled output publishes as the owner-defined atomic group; successful mathematical sources remain available unless the contract explicitly consumes them.

<!-- PTO-READER-BLOCK: block-bstart-vec-constraints role=constraints -->
## Legality, faults, and atomicity

Fixed bits, reserved values, selector domains, and required Block placement are checked before architectural effects.

The current owner reports invalid schema, state, address, or continuation conditions through the owner-defined fault; no prose on this page creates an additional fault rule.

Complete schema, binding, readiness, alias, capacity, and allocation preflight precedes source snapshots and every destination publication.

<!-- PTO-READER-BLOCK: block-bstart-vec-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
BSTART.VEC TADD, FP32
```

The starter establishes the descriptor first; the following carriers fill its declared schema, and the final completion boundary triggers validation and operation execution.
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
