<!-- GENERATED FROM: asl/block/lifecycle/BSTOP.asl -->
# BSTOP

**Normative ASL source:** `asl/block/lifecycle/BSTOP.asl`

Commits the current bundle and transfers to its selected continuation.

## Normative identity {#PTO-INST-BLOCK-BSTOP}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstop-purpose role=purpose -->
## What BSTOP does

`BSTOP` ends the active block and commits it. A block (also called a bundle) opens with a block-start command, collects configuration from header commands, runs its body, and takes effect as one unit at its commit boundary. `BSTOP` is the explicit, 32-bit form of that boundary; the next block start is the implicit one.

At commit, the block's selected operation runs, the continuation recorded in `BARG` (the block argument register) is applied, and all block-private state is cleared.

<!-- PTO-READER-BLOCK: block-bstop-mechanism role=mechanism -->
## Placement and execution mechanism

`BSTOP` belongs at the end of an active block's body. It calls the commit owner in [commit validation](../model/commit/validation.md) with the address after itself as the sequential continuation. Commit runs these steps and stops at the first failure:

1. No active block raises `Fault_BundleControl`.
2. An odd continuation, or an odd next PC selected by `BARG`, raises `Fault_InstructionPC`.
3. A `DR` control attribute on a block that is not a Tile element or Tile memory block raises `Fault_BundleControl`.
4. A Tile operation selected by the start command runs, with its own preflight and rollback.
5. [Stop](../model/lifecycle/enter-stop.md) clears block state and writes `TPC`.

Design point: the stop forms `BSTOP`, [C.BSTOP](C.BSTOP.md), and [L.BSTOP](L.BSTOP.md) share one handler, `ExecuteBundleStop`. They differ only in length, and the length decides the fall-through address. A 4-byte `BSTOP` at `P` continues at `P + 4` when the block does not select `BPCN`.

<!-- PTO-READER-BLOCK: block-bstop-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- The carrier is the single 32-bit word `0x00000001`.
- `BSTOP` has no operand field. Every bit is fixed, so there is no default and no encoded zero to interpret.
- The inputs are the accumulated block state: `BARG`, the operation descriptor installed by the start command, the header attributes, dimensions, and operand bindings.

<!-- PTO-READER-BLOCK: block-bstop-effects role=effects -->
## State effects and ordering

The next PC is `BARG.BPCN` for a `DIRECT`, `CALL`, `IND`, `ICALL`, or `RET` block, and for a `COND` block whose `TAKEN` flag is set. Otherwise it is the address after `BSTOP`.

Every architecture-visible memory effect of the block commits before the continuation is selected. After a successful commit, `BARG`, `BPC`, the descriptor, dimensions, operand bindings, attributes, and the active and body flags are cleared, and `TPC` receives the next PC.

Design point: the next PC and the `B.CATR` `trap` attribute are captured before state is cleared. If `trap` was set, `Fault_BundlePostCommit` is raised after the block has retired, with the next PC as its address. Recovery therefore resumes after the block and cannot run it twice.

<!-- PTO-READER-BLOCK: block-bstop-constraints role=constraints -->
## Legality, faults, and atomicity

A schema, applicability, execution, or final-PC fault is raised before block-private state is cleared. The block stays active with its header intact, and `BARG` is not applied, so the trap context still describes the block that failed.

Design point: the final target is checked at commit because a body `SETC.TGT` may replace `BPCN` after the start command. A bad target is therefore rejected before any Tile result of the block is published.

After a system-block terminal request (`ACRC`), only a stop or a block start may follow; `BSTOP` is allowed there. The generated exception section below is authoritative.

<!-- PTO-READER-BLOCK: block-bstop-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
BSTOP
```

A `COND` block has `BPCN = 0x2000`. Its `BSTOP` is at `0x1040`, so the sequential continuation is `0x1044`. If no body `SETC.*` sets `TAKEN`, commit selects `0x1044`; if `TAKEN` is set, it selects `0x2000`. In both cases the header state is cleared and the block is no longer active.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTOP
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstop_32_d25b09fdd59c | L32 | 32 | 0x00000001 / 0xffffffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/BSTOP.asl -->
```asl
readonly func InstructionContractMatches_BSTOP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstop_32_d25b09fdd59c);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/BSTOP.asl -->
```asl
readonly func InstructionContractHandler_BSTOP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStop;
end;

pure func InstructionContractCommitsActiveBundle_BSTOP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractClearsHeaderState_BSTOP()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The instruction has no encoded operand field and therefore no operand default.

## Legality

- All bit patterns not excluded by the form decode are assigned by this instruction contract.

## State effects

- Commits the active block, selects BARG.BPCN for DIRECT/CALL/IND/ICALL/RET or taken COND, otherwise selects the sequential PC.
- After successful commit, clears BARG, BPC, descriptor fields, dimensions, operand bindings, attributes, and active/body state.

## Memory effects and ordering

### Memory effects

- Commits every architecture-visible memory effect of the active block before selecting its continuation.

### Ordering

- Validate the active block and final BARG continuation, execute the selected block operation, then select BARG.BPCN or the sequential PC and clear block-private state.

## Exceptions

- No active block raises Fault_BundleControl.
- Schema, applicability, execution, or final-PC faults reject before block-private state is cleared.

## Examples

- BSTOP
