<!-- GENERATED FROM: asl/block/model/dispatch/top-level.asl -->
# Top Level

**Normative ASL source:** `asl/block/model/dispatch/top-level.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TOP-LEVEL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-top-level-purpose role=purpose-scope -->
## Purpose and scope

This unit is the entry point for one block command instruction. `ExecuteCommandInstruction` takes the raw instruction bits and their length, decides whether they form a legal command, and hands a legal command to `ExecuteDecodedBundleCommand`. It returns `CommandExecution_Executed` or `CommandExecution_Rejected`.

A command is any block-surface instruction: `BSTART` and `BSTOP` forms, header commands such as `B.DIM`, `B.DATR`, `B.IOT`, and `B.IOR`, and other command forms such as `HL.QPUSH` or `MCOPY`. The architecture entry point `ExecutePTOInstruction` calls this unit when `DecodeCommandForm` recognizes the bits.

<!-- PTO-READER-BLOCK: block-model-dispatch-top-level-concepts role=concepts-state -->
## Concepts and visible state

- A command form is one accepted encoding. `DecodeCommandForm` returns its index, or `PTO_COMMAND_FORM_COUNT` when no form matches.
- A handler is the semantic action for a form, returned by `CommandHandlerOfForm`.
- `_SystemBlockTerminalPending` is a block control flag. The scalar `ACRC` request sets it inside a system block. It is cleared when a bundle begins or header state is cleared.

The unit reads `_SystemBlockTerminalPending` and `TPC`. Before any check it calls `BeginArchitecturalInstructionAttempt`, which clears `_LastFault` and `_FaultAddress` and advances architectural time.

<!-- PTO-READER-BLOCK: block-model-dispatch-top-level-rules role=rules-interactions -->
## Rules and interactions

The unit makes three checks in order. Each rejects with a fault at the current `TPC` and returns `CommandExecution_Rejected`.

1. If no command form matches, it raises `Fault_IllegalInstruction`.
2. If a system-block terminal request is pending, any handler other than `CommandHandler_ExecuteBundleStop` or `CommandHandler_ExecuteBundleStart` raises `Fault_BundleControl`.
3. If `CommandFormOperandsLegal` rejects the operand fields of the matched form, it raises `Fault_IllegalInstruction`.

Only a command that passes all three reaches `ExecuteDecodedBundleCommand`, whose status is returned unchanged.

Design point: after `ACRC` marks the system block as terminating, the only commands that may follow are the two that end the bundle. Any other command is rejected with `Fault_BundleControl` before its handler runs, so it cannot add header state to a bundle that is already closing.

Design point: the ASL comment says that the 16-bit pattern `0x0800` is a compressed `C.BSTART.STD FALL` in ordinary bundles but a compressed stop at a selecting legacy entry boundary, and that the disambiguation stays in ASL and is context-sensitive. In the current text, `normalized_instruction` is the unchanged input, so this unit performs no rewrite. The comment records where that choice belongs.

Because the attempt begins before decoding, a rejected command still counts as one architectural attempt, and its fault replaces any fault left by a previous instruction.

<!-- PTO-READER-BLOCK: block-model-dispatch-top-level-boundaries role=boundaries -->
## Architectural boundaries

This unit does not execute any command semantics. Placement rules, stream rules, per-handler legality, and `TPC` advance belong to `ExecuteDecodedBundleCommand`. The form decoder and operand-field legality predicate are generated from the command encoding catalog; this unit only calls them. Deciding between a command and a scalar instruction belongs to the architecture dispatch owner.

<!-- PTO-READER-BLOCK: block-model-dispatch-top-level-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Inside a system block, a program executes `ACRC`, which sets `_SystemBlockTerminalPending`. The next instruction is a `B.DIM` command. It decodes to a legal form, but its handler is `CommandHandler_SetBundleDimension`, so this unit raises `Fault_BundleControl` and returns `CommandExecution_Rejected`. If the next instruction were `BSTOP`, it would pass this check and reach the stop handler.

<!-- PTO-READER-BLOCK: block-model-dispatch-top-level-related role=related-owners-navigation -->
## Related owners

- [Architecture dispatch](../../../arch/dispatch/top-level.md) calls this unit for recognized command encodings.
- [Commands](commands.md) defines `ExecuteDecodedBundleCommand` and the per-handler rules.
- [Decode](decode.md) defines handler mapping and sequential advance.
- [ACRC](../../../scalar/sys/ACRC.md) is the scalar request that sets the terminal flag.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/top-level.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TOP-LEVEL","surface":"block","classification":["model","dispatch","top-level"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMMANDS"]}
func ExecuteCommandInstruction(instruction: bits(64),
                               length_bits: integer {16,32,48,64})
                               => CommandExecutionStatus
begin
    BeginArchitecturalInstructionAttempt();
    // 0x0800 is emitted as C.BSTART.STD FALL in ordinary fallthrough
    // bundles, but as a compressed stop at the selecting legacy entry
    // boundary. Keep the disambiguation in ASL and context-sensitive.
    let normalized_instruction = instruction;
    let decoded = DecodeCommandForm(normalized_instruction, length_bits);
    if decoded == PTO_COMMAND_FORM_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return CommandExecution_Rejected;
    end;
    let form = decoded as integer {0..PTO_COMMAND_FORM_COUNT-1};
    let handler = CommandHandlerOfForm(form);
    if _SystemBlockTerminalPending &&
       handler != CommandHandler_ExecuteBundleStop &&
       handler != CommandHandler_ExecuteBundleStart then
        SetFault(Fault_BundleControl, ReadTPC());
        return CommandExecution_Rejected;
    end;
    if !CommandFormOperandsLegal(normalized_instruction, form) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return CommandExecution_Rejected;
    end;
    return ExecuteDecodedBundleCommand(normalized_instruction, form, length_bits);
end;
```
<!-- GENERATED-ASL-END: unit -->
