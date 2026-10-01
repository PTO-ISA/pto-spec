<!-- GENERATED FROM: asl/scalar/model/types/operands.asl -->
# Operands

**Normative ASL source:** `asl/scalar/model/types/operands.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-TYPES-OPERANDS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-types-operands-purpose role=purpose-scope -->
## Purpose and scope

This unit defines what a 5-bit scalar register code (a Reg5 selector) means when it is read as a source or written as a destination. Decoded scalar register operands pass through these functions, and several bundle dispatch units use them too.

It defines:

- `ScalarSourceSelectorLegal` and `ScalarDestinationSelectorLegal`, which decide whether a selector is usable;
- `ScalarImplicitSourceOperandsLegal`, which checks the hidden T#1 source of some compressed forms;
- `ReadScalarRegisterOperand` and `ReadPEAbsoluteGPROperand`, which read a value;
- `WriteScalarDestination` and `WriteCompressedTResult`, which publish a result.

<!-- PTO-READER-BLOCK: scalar-model-types-operands-concepts role=concepts-state -->
## Concepts and visible state

There are `PTO_ABSOLUTE_GPR_COUNT` (24) absolute GPRs. GPR 0 always reads as zero, and writes to it are dropped.

The T queue and the U queue each hold `PTO_TEMPORARY_QUEUE_DEPTH` (4) entries with a valid bit. Index 0 is the newest entry. A push shifts every entry one place older, drops the oldest, and stores the new value at index 0 as valid.

A Reg5 selector means different things in the two directions:

| Code | As a source | As a destination |
| --- | --- | --- |
| 0 | GPR 0, reads zero | discard |
| 1 to 23 | GPR 1 to 23 | write GPR 1 to 23 |
| 24 to 27 | T#1 to T#4 | discard |
| 28 and 29 | U#1 and U#2 | discard |
| 30 | U#3 | push to U |
| 31 | U#4 | push to T |

<!-- PTO-READER-BLOCK: scalar-model-types-operands-rules role=rules-interactions -->
## Rules and interactions

A GPR source is always legal. A queue source is legal only when that entry's valid bit is set. `ScalarDestinationSelectorLegal` accepts every code.

Reading a queue entry does not remove it. In this unit, only a push changes a queue.

Design point: queue reads are non-consuming. The same entry can feed several instructions, and an instruction that faults after reading a queue has not changed it. In this unit an entry leaves a queue only when four newer pushes shift it out.

`C.SDI`, `C.SLLI`, `C.SRLI`, and `C.SWI` read T#1 without naming it in a field, and `ScalarImplicitSourceOperandsLegal` requires T#1 to be valid for them. `C.CMP.EQI` and `C.CMP.NEI` also read T#1 implicitly, but this function does not check them.

Design point: for those four operations, availability is checked during top-level legality, before the family handler runs. If T#1 is empty, the instruction raises `Fault_IllegalInstruction` before any handler effect instead of reading a stale value.

`WriteCompressedTResult` always pushes to T. Compressed forms that use it, such as `C.LDI` and `C.SLLI`, have no destination field; `C.MOVI` and `C.MOVR` instead write an encoded `RegDst`.

<!-- PTO-READER-BLOCK: scalar-model-types-operands-boundaries role=boundaries -->
## Architectural boundaries

`ReadPEAbsoluteGPROperand` asserts that the selector is below 24 and reads the GPR of a named PE. Its comment explains that shared operations apply one encoded selector to each PE's own register file. Block dispatch units, for example `scalar-schema` and the `tlsu-*` units, call it.

The generated per-form function `ScalarRegisterOperandsLegal` calls the two selector-legality functions for each Reg5 field of a form.

Queue state belongs to the execution context, and `ResetProfileState` clears it on reset. This unit only reads and pushes.

<!-- PTO-READER-BLOCK: scalar-model-types-operands-example role=example-usage -->
## Non-normative reading example

Start with the T queue holding A, B, C, and D at T#1 through T#4, all valid, and U empty.

- An instruction that reads selector 25 gets B. The T queue does not change.
- An instruction that reads selector 28 fails legality, because U#1 is not valid.
- `WriteScalarDestination(31, X)` pushes X to T. T#1 is X, T#2 is A, T#3 is B, T#4 is C, and D is gone.
- `WriteScalarDestination(26, Y)` does nothing, because 26 is a discard code.

<!-- PTO-READER-BLOCK: scalar-model-types-operands-related role=related-owners-navigation -->
## Related owners

- [Execution context](../../../arch/programming-model/execution-context.md) owns the T and U queues and `PushTemporaryQueue`.
- [Scalar registers](../../../arch/programming-model/scalar-registers.md) owns `ReadGPR` and `WriteGPR`.
- [Scalar top-level dispatch](../dispatch/top-level.md) runs the legality checks.
- [Operation types](operations.md) is the other scalar types unit.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/types/operands.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-TYPES-OPERANDS","surface":"scalar","classification":["model","types","operands"],"depends_on":["PTO-SCALAR-MODEL-TYPES-OPERATIONS","PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS"]}
// PTO-REQ-SCALAR-OPERAND-001: one-level Reg5 source and destination behavior.

// Reg5 codes 0..23 select absolute GPRs. Codes 24..27 select T#1..T#4
// and codes 28..31 select U#1..U#4. Queue index zero is the newest value.
readonly func ScalarSourceSelectorLegal(selector: Reg5Selector) => boolean
begin
    if selector < PTO_ABSOLUTE_GPR_COUNT then
        return TRUE;
    elsif selector < 28 then
        return TemporaryQueueSourceAvailable(
            TRUE,
            (selector - 24) as TemporaryQueueIndex);
    else
        return TemporaryQueueSourceAvailable(
            FALSE,
            (selector - 28) as TemporaryQueueIndex);
    end;
end;

readonly func ScalarDestinationSelectorLegal(selector: Reg5Selector) => boolean
begin
    return TRUE;
end;

readonly func ScalarImplicitSourceOperandsLegal(
    operation: ScalarOperation)
    => boolean
begin
    case operation of
        when ScalarOperation_C_SDI,
             ScalarOperation_C_SLLI,
             ScalarOperation_C_SRLI =>
            return TemporaryQueueSourceAvailable(TRUE, 0);
        when ScalarOperation_C_SWI =>
            return TemporaryQueueSourceAvailable(TRUE, 0);
        otherwise =>
            return TRUE;
    end;
end;

readonly func ReadScalarRegisterOperand(selector: Reg5Selector) => Word
begin
    if selector < PTO_ABSOLUTE_GPR_COUNT then
        return ReadGPR(selector as GPRIndex);
    elsif selector < 28 then
        return ReadTemporaryQueue(TRUE,
            (selector - 24) as TemporaryQueueIndex);
    else
        return ReadTemporaryQueue(FALSE,
            (selector - 28) as TemporaryQueueIndex);
    end;
end;

// B.IOR uses only absolute GPR selectors.  Shared operations apply one encoded
// selector to each PE's private register file rather than sharing a value
// resolved by the PE that happened to dispatch the block.
readonly func ReadPEAbsoluteGPROperand(pe: MemoryAgentId,
                                      selector: Reg5Selector) => Word
begin
    assert selector < PTO_ABSOLUTE_GPR_COUNT;
    return ReadPEGPR(pe, selector as GPRIndex);
end;

func WriteScalarDestination(selector: Reg5Selector, value: Word)
begin
    if selector < PTO_ABSOLUTE_GPR_COUNT then
        WriteGPR(selector as GPRIndex, value);
    elsif selector == 30 then
        PushTemporaryQueue(FALSE, value);
    elsif selector == 31 then
        PushTemporaryQueue(TRUE, value);
    end;
    // Destination selectors 24..29 are non-writing encodings. Codes 30 and 31
    // are the encoded ->u and ->t queue-push destinations respectively.
end;

func WriteCompressedTResult(value: Word)
begin
    PushTemporaryQueue(TRUE, value);
end;
```
<!-- GENERATED-ASL-END: unit -->
