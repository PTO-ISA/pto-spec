<!-- GENERATED FROM: asl/scalar/model/dispatch/top-level.asl -->
# Top Level

**Normative ASL source:** `asl/scalar/model/dispatch/top-level.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-dispatch-top-level-purpose role=purpose-scope -->
## Purpose and scope

This unit is the single entry point for one 16-, 32-, or 48-bit scalar instruction. `ExecuteScalarInstruction` decodes the word, runs the legality checks in a fixed order, calls one family dispatcher, and then either advances TPC or reports a rejection.

The architecture-level [dispatch top level](../../../arch/dispatch/top-level.md) calls it for every non-64-bit word that is not an accepted command form.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-top-level-concepts role=concepts-state -->
## Concepts and visible state

An instruction attempt is one call to the entry point. It starts with `BeginArchitecturalInstructionAttempt`, which clears `_LastFault` and `_FaultAddress` and advances architectural time by one. Every attempt ticks time once, whether it succeeds or not.

The result is `ScalarExecution_Executed` or `ScalarExecution_Rejected`. A rejected attempt leaves `_LastFault` set.

A family is one of AGU, ALU, AMO, BRU, FSU, or SYS. `ScalarFamilyOfForm` returns it for a decoded form.

The unit's metadata lists three reviewed encoding overlaps. In each, the `SETRET`-style form occupies `RegDst == 10`, and the broader `ADDTPC` or `C.MOVI` form excludes that value through a not-equal constraint.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-top-level-rules role=rules-interactions -->
## Rules and interactions

`ExecuteScalarInstruction` performs these steps in order. Each check that fails raises a fault and returns `ScalarExecution_Rejected` at once.

1. Begin the attempt.
2. Decode the form with `DecodeScalarForm`. An unknown word raises `Fault_IllegalInstruction`.
3. If a bundle is active but its body is not, enter the body with `EnterBundleBody`.
4. Check `ScalarOperationApplicable`. Failure raises `Fault_BundleControl`.
5. Check `ScalarFormOperandsLegal` (reserved field values), then `ScalarRegisterOperandsLegal` (T/U source availability), then `ScalarImplicitSourceOperandsLegal` (implicit T#1). Each failure raises `Fault_IllegalInstruction`.
6. Call the family dispatcher.
7. If `_LastFault` is set, return rejected.
8. Unless the handler installs its own TPC, add the instruction length in bytes to TPC.

Design point: the operation-applicability check and the catalog-generated legality checks run before the family dispatcher. An inapplicable operation, a catalog-constrained reserved field, or an unavailable queue source therefore cannot reach a handler's register, memory, or flag effect; the only changes are the time tick, the trap entry performed by `SetFault`, and a possible bundle-body entry.

Design point: body entry happens before applicability. The NDF clause PTO-REQ-SCALAR-BODY-ENTRY-001 requires this, and states that a later scalar fault keeps the body-active transition. An unknown word is rejected in step 2, so it never enters the body.

Design point: TPC advances only after the handler returns without a fault. A fault calls `SetFault`, which saves the trap context with the TPC current at that moment and then writes TPC to the trap vector entry, so adding the instruction length would move TPC off that entry. For a fault raised before the handler changes TPC, the saved TPC is the faulting instruction, which PTO-ARCH-MEMORY-MODEL-REPLAY-001 names as the restart point. The three handlers named by `ScalarHandlerWritesTPC` skip step 8 because they set TPC themselves.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-top-level-boundaries role=boundaries -->
## Architectural boundaries

This unit does not decode fields or compute results. The mask-and-match tables and legality functions are generated from the catalog; the family semantics live in the family dispatch units.

Forms are matched in catalog decode order, which sorts by the number of mask bits, largest first. A narrower form therefore wins over a broader form that could match the same word.

Faults raised inside a family handler, such as data faults, are also reported as rejection. Whether earlier effects of that handler survive is the family's own contract.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-top-level-example role=example-usage -->
## Non-normative reading example

Two 32-bit words differ only in bits 11:7.

| Word | Bits 11:7 | Decoded form | Effect with TPC 0x400 |
| --- | --- | --- | --- |
| 0x00001507 | 10 | `SETRET` (mask 0xFFF) | GPR 10 gets 0x402 |
| 0x00001587 | 11 | `ADDTPC` (mask 0x7F) | GPR 11 gets 0x1400 |

`SETRET` has more mask bits, so it is tried first and takes the `RegDst == 10` encoding. Each word, executed at TPC 0x400, succeeds and leaves TPC at 0x404.

If instead the word were the `ADD` 0x0F818F85 and T#1 were not valid, step 5 would raise `Fault_IllegalInstruction` and nothing would be pushed to T.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-top-level-related role=related-owners-navigation -->
## Related owners

- [Scalar decode helpers](decode.md) interpret fields after legality passes.
- [SYS semantics](../sys/semantics.md) owns `BeginArchitecturalInstructionAttempt` and `ScalarOperationApplicable`.
- [Bundle enter and stop](../../../block/model/lifecycle/enter-stop.md) owns `EnterBundleBody`.
- [Fault precision](../../../arch/memory-model/fault-precision.md) owns `SetFault` and the trap envelope.
- The family dispatchers: [AGU](agu.md), [ALU](alu.md), [AMO](amo.md), [BRU](bru.md), [FSU](fsu.md), and [SYS](sys.md).
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/dispatch/top-level.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL","surface":"scalar","classification":["model","dispatch","top-level"],"depends_on":["PTO-BLOCK-MODEL-LIFECYCLE-ENTER-STOP","PTO-SCALAR-MODEL-DISPATCH-ALU","PTO-SCALAR-MODEL-DISPATCH-BRU","PTO-SCALAR-MODEL-DISPATCH-SYS","PTO-SCALAR-MODEL-DISPATCH-AMO","PTO-SCALAR-MODEL-DISPATCH-AGU","PTO-SCALAR-MODEL-DISPATCH-FSU"],"catalog_projection":{"catalog":"scalar-forms","family_constraints":[],"isa":"PTO Instruction Set Architecture","schema_version":2,"reviewed_encoding_overlaps":[{"broad_form_id":"addtpc_32_e5aa0f0abca3","narrow_form_id":"setret_32_72003dcf3b59","reason":"narrow form occupies RegDst == 10, which the broad form excludes via its not-equal constraint"},{"broad_form_id":"c_movi_16_2c84faf1bc72","narrow_form_id":"c_setret_16_335651ef6c27","reason":"narrow form occupies RegDst == 10, which the broad form excludes via its not-equal constraint"},{"broad_form_id":"hl_addtpc_48_2e8e692eea09","narrow_form_id":"hl_setret_48_302bb793a800","reason":"narrow form occupies RegDst == 10, which the broad form excludes via its not-equal constraint"}]}}

// NDF-BEGIN: PTO-REQ-SCALAR-BODY-ENTRY-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// After a scalar form decodes successfully, scalar dispatch MUST enter any
// active body-inactive bundle, including a Tile block, before operation
// applicability or operand legality. An unmatched carrier MUST reject without
// entering the body. Once decoded, a later scalar fault preserves the
// body-active transition and the active block kind.
// NDF-END: PTO-REQ-SCALAR-BODY-ENTRY-001

func ExecuteScalarInstruction(instruction: bits(48),
                              length_bits: integer {16,32,48})
                              => ScalarExecutionStatus
begin
    BeginArchitecturalInstructionAttempt();
    let decoded = DecodeScalarForm(instruction, length_bits);
    if decoded == PTO_SCALAR_FORM_COUNT then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return ScalarExecution_Rejected;
    end;
    let form = decoded as integer {0..PTO_SCALAR_FORM_COUNT-1};
    let operation = ScalarOperationOfForm(form);
    if BundleIsActive() && !BundleBodyIsActive() then
        EnterBundleBody();
    end;
    if !ScalarOperationApplicable(operation) then
        SetFault(Fault_BundleControl, ReadTPC());
        return ScalarExecution_Rejected;
    end;
    if !ScalarFormOperandsLegal(instruction, form) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return ScalarExecution_Rejected;
    end;
    if !ScalarRegisterOperandsLegal(instruction, form) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return ScalarExecution_Rejected;
    end;
    if !ScalarImplicitSourceOperandsLegal(operation) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return ScalarExecution_Rejected;
    end;
    case ScalarFamilyOfForm(form) of
        when ScalarSemantic_AGU => ExecuteDecodedAGUForm(instruction, form);
        when ScalarSemantic_ALU => ExecuteDecodedALUForm(instruction, form);
        when ScalarSemantic_AMO => ExecuteDecodedAMOForm(instruction, form);
        when ScalarSemantic_BRU => ExecuteDecodedBRUForm(instruction, form);
        when ScalarSemantic_FSU => ExecuteDecodedFSUForm(instruction, form);
        when ScalarSemantic_SYS => ExecuteDecodedSYSForm(instruction, form);
        otherwise => unreachable;
    end;
    if _LastFault != Fault_None then
        return ScalarExecution_Rejected;
    end;
    if !ScalarHandlerWritesTPC(ScalarHandlerOfForm(form)) then
        WriteTPC(ReadTPC() + NaturalToWord(length_bits DIV 8));
    end;
    return ScalarExecution_Executed;
end;
```
<!-- GENERATED-ASL-END: unit -->
