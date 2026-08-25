<!-- GENERATED FROM: asl/arch/dispatch/top-level.asl -->
# Top Level

**Normative ASL source:** `asl/arch/dispatch/top-level.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DISPATCH-TOP-LEVEL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-dispatch-top-level-purpose-scope role=purpose-scope -->
## Purpose and scope

`ExecutePTOInstruction` is the total entry point for one encoded `PTO` instruction and returns either `PTOInstruction_Executed` or `PTOInstruction_Rejected`.

It separates command-form dispatch from scalar dispatch and provides one explicit rejection path for unmatched 64-bit inputs.

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-concepts-state role=concepts-state -->
## Concepts and visible state

- The input carrier is `bits(64)` and `length_bits` is restricted to `16`, `32`, `48`, or `64`.
- `DecodeCommandForm` is tried first. A recognized command form is passed to `ExecuteCommandInstruction`.
- If no command form matches and length is not `64`, the low `48` bits are passed to `ExecuteScalarInstruction` with the original `16`/`32`/`48` length.

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-rules-interactions role=rules-interactions -->
## Rules and interactions

A command execution status maps directly to the top-level executed/rejected status.

A scalar execution status maps in the same way after the command decoder reports no form.

An unmatched `64`-bit input begins an architectural instruction attempt, sets `Fault_IllegalInstruction` at `ReadTPC()`, and returns rejected.

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-boundaries role=boundaries -->
## Architectural boundaries

This dispatcher does not duplicate command or scalar legality and operation semantics; it delegates them to their current owners.

The explicit illegal-instruction path applies only after command decoding fails and the selected length is `64`.

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-example-usage role=example-usage -->
## Non-normative reading example

A recognized 48-bit scalar form first fails command-form recognition, then reaches `ExecuteScalarInstruction`; its final status is projected back to `PTOInstructionExecutionStatus`.

A random 64-bit carrier that matches no command form does not fall through to scalar decoding; it takes the explicit illegal-instruction path.

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-related-owners role=related-owners-navigation -->
## Related owners

- [Command dispatch owner](../../block/model/dispatch/top-level.md)
- [Scalar dispatch owner](../../scalar/model/dispatch/top-level.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/dispatch/top-level.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DISPATCH-TOP-LEVEL","surface":"arch","classification":["dispatch","top-level"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TOP-LEVEL","PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL"]}
// PTO-REQ-INSTRUCTION-DISPATCH-001: total PTO encoded-instruction entry point.

type PTOInstructionExecutionStatus of enumeration {
    PTOInstruction_Executed,
    PTOInstruction_Rejected
};

func ExecutePTOInstruction(instruction: bits(64),
                           length_bits: integer {16,32,48,64})
                           => PTOInstructionExecutionStatus
begin
    if DecodeCommandForm(instruction, length_bits) != PTO_COMMAND_FORM_COUNT then
        let command_status = ExecuteCommandInstruction(instruction, length_bits);
        if command_status == CommandExecution_Executed then
            return PTOInstruction_Executed;
        else
            return PTOInstruction_Rejected;
        end;
    elsif length_bits != 64 then
        let scalar_status = ExecuteScalarInstruction(
            instruction[47:0], length_bits as integer {16,32,48});
        if scalar_status == ScalarExecution_Executed then
            return PTOInstruction_Executed;
        else
            return PTOInstruction_Rejected;
        end;
    else
        BeginArchitecturalInstructionAttempt();
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return PTOInstruction_Rejected;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
