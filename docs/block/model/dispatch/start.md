<!-- GENERATED FROM: asl/block/model/dispatch/start.asl -->
# Start

**Normative ASL source:** `asl/block/model/dispatch/start.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-START}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-start-purpose role=purpose-scope -->
## Purpose and scope

This unit executes a decoded `BSTART` form. A `BSTART` opens a bundle: a group of header commands and body instructions that commits as one unit at `BSTOP` or at the next `BSTART`.

`ExecuteDecodedBundleStartWithAcceptedApplicabilityRules` does four jobs in a fixed order. It validates the operation descriptor, computes the candidate continuation target, commits any active predecessor bundle, and then opens the new bundle. `ExecuteDecodedBundleStart` is the same function with `NumericApplicabilityRules_None`. The command dispatcher calls it for `CommandHandler_ExecuteBundleStart`.

<!-- PTO-READER-BLOCK: block-model-dispatch-start-concepts role=concepts-state -->
## Concepts and visible state

- The operation descriptor is decoded from the instruction by `DecodeBundleOperationDescriptor`. It names the operation class, selector, data type, and optional branch type that the bundle will run at commit.
- The transfer kind comes from the descriptor branch type when `branch_type_valid` is set, and otherwise from the encoded form.
- The fallthrough address is the instruction PC plus the instruction length in bytes.
- The return target is the fallthrough address, unless the form carries a `uimm5` field. Then it is the instruction PC plus the length minus 2, plus `uimm5` shifted left by 1.
- `taken` is false only for a conditional transfer.

The unit reads `_BundleActive`, `_BARG`, `_ReturnAddress`, and `TPC`. It writes bundle state through `CompleteBundleAtWithAcceptedApplicabilityRules` (the predecessor commit), `ClearBundleHeaderState`, `BeginBundleAt`, and `InstallBundleOperationDescriptor`, and records faults with `SetFault`.

<!-- PTO-READER-BLOCK: block-model-dispatch-start-rules role=rules-interactions -->
## Rules and interactions

The target is chosen in this order: `Return` uses `_ReturnAddress`; `Indirect` and `IndirectCall` use the retiring bundle's `BARG.BPCN`; `Fallthrough` uses the fallthrough address; a form with a signed offset uses `TPC` plus the offset shifted left by 1; any other form uses the fallthrough address.

The checks that fault are, in order:

1. An illegal descriptor, or one rejected by the accepted applicability rules, raises `Fault_IllegalInstruction`.
2. An indirect transfer with no retiring Standard or Floating bundle raises `Fault_BundleControl`.
3. A target with bit 0 set raises `Fault_InstructionPC`.

All three happen before the predecessor commits, so a rejected `BSTART` leaves the active predecessor in place.

Design point: an indirect `BSTART` reads the retiring bundle's `BARG.BPCN` before that bundle commits. `RetiringBundleBPCNAvailable` requires an active Standard or Floating bundle, because only those kinds carry a candidate word. The value is taken as a snapshot in `retiring_bpcn`, so the commit cannot change it.

Design point: the NDF clause `PTO-REQ-BSTART-PREDECESSOR-TRANSFER-001` requires the fetched `BSTART` to be installed only when the predecessor's commit selects this instruction PC. If the predecessor commit fails, or transfers somewhere else, the function returns without opening a bundle. The `BSTART` sat on a path the program did not take, and the predecessor's chosen `TPC` is kept.

After the predecessor step, the unit clears header state and calls `BeginBundleAt`. It installs the descriptor only if no fault was recorded.

<!-- PTO-READER-BLOCK: block-model-dispatch-start-boundaries role=boundaries -->
## Architectural boundaries

This unit does not decode the command form or check the form's operand fields; the top-level command dispatcher does that first. It does not define what commit does. That belongs to the commit validation owner, which runs the selected Tile operation and then stops the bundle. It also does not write `BARG`, `BPC`, or the execution-domain token directly; `BeginBundleAt` owns those writes.

<!-- PTO-READER-BLOCK: block-model-dispatch-start-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Suppose a Standard bundle is active and its `BARG` selects fallthrough. A 4-byte `BSTART` at `0x1010` has a signed offset of `0x40`. The target is `0x1010 + 0x80 = 0x1090`, which is even. The predecessor commits and its continuation is `0x1010`, which equals the instruction PC. The new bundle opens with `BPCN` equal to `0x1090` and `TPC` equal to `0x1014`. If the predecessor had instead selected `0x2000`, this `BSTART` would not open a bundle and execution would continue at `0x2000`.

<!-- PTO-READER-BLOCK: block-model-dispatch-start-related role=related-owners-navigation -->
## Related owners

- [Begin](../lifecycle/begin.md) defines the state transition that opens the bundle.
- [Commit validation](../commit/validation.md) defines the predecessor commit.
- [Commands](commands.md) routes `CommandHandler_ExecuteBundleStart` to this unit.
- [Descriptor legality](descriptor-legality.md) defines descriptor legality and the branch-type mapping.
- [BSTART](../../lifecycle/BSTART.md) is the instruction page for the plain start forms.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/start.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-START","surface":"block","classification":["model","dispatch","start"],"depends_on":["PTO-BLOCK-MODEL-COMMIT-VALIDATION"]}

// NDF-BEGIN: PTO-REQ-BSTART-PREDECESSOR-TRANSFER-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A following BSTART MUST first commit an active predecessor.  It MUST install
// the fetched BSTART only when the predecessor-selected TPC equals the fetched
// instruction PC; otherwise it MUST preserve that selected TPC and MUST NOT
// install the BSTART from the unselected path.
// NDF-END: PTO-REQ-BSTART-PREDECESSOR-TRANSFER-001

readonly func CommandDecodedBundleTarget(
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => Word
begin
    let offset = CommandSignedOffsetOfForm(instruction, form);
    return ReadTPC() + LSL(offset, 1);
end;

readonly func RetiringBundleBPCNAvailable() => boolean
begin
    return _BundleActive &&
           (_BARG.block_type == BundleKind_Standard ||
            _BARG.block_type == BundleKind_Floating);
end;

func ExecuteDecodedBundleStartWithAcceptedApplicabilityRules(
    rules: NumericApplicabilityRuleSet,
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1},
    length_bits: integer {16,32,48,64})
begin
    let instruction_pc = ReadTPC();
    let kind = CommandBundleKindOfForm(form);
    let descriptor = DecodeBundleOperationDescriptor(instruction, form);
    if !BundleOperationDescriptorLegal(descriptor) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;
    if BundleOperationDescriptorRejectedByAcceptedApplicabilityRules(
        rules, descriptor) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;
    let transfer = if descriptor.branch_type_valid then
        BundleTransferOfBranchType(descriptor.branch_type)
        else CommandBundleTransferOfForm(form);
    let fallthrough = instruction_pc +
        (Zeros{PTO_XLEN} + (length_bits DIV 8));
    let reads_retiring_bpcn =
        transfer == BundleTransfer_Indirect ||
        transfer == BundleTransfer_IndirectCall;
    if reads_retiring_bpcn && !RetiringBundleBPCNAvailable() then
        SetFault(Fault_BundleControl, instruction_pc);
        return;
    end;
    let retiring_bpcn = _BARG.bpcn;
    let target = if transfer == BundleTransfer_Return then _ReturnAddress
        else if reads_retiring_bpcn then retiring_bpcn
        else if transfer == BundleTransfer_Fallthrough then fallthrough
        else if CommandHasSignedOffset(form) then
            CommandDecodedBundleTarget(instruction, form)
        else fallthrough;
    let return_target = if CommandOperandPresent(form, CommandField_uimm5) then
        instruction_pc + (Zeros{PTO_XLEN} + ((length_bits DIV 8) - 2)) +
        LSL(CommandDecodedWord(instruction, form, CommandField_uimm5), 1)
        else fallthrough;
    let taken = transfer != BundleTransfer_Conditional;
    if target[0] == '1' then
        SetFault(Fault_InstructionPC, target);
        return;
    end;
    // A following BSTART first commits the active predecessor.  The fetched
    // BSTART is installed only when that commit selects this instruction PC;
    // otherwise it belongs to an unselected path and must not replace the
    // predecessor-selected continuation.
    if _BundleActive then
        if !CompleteBundleAtWithAcceptedApplicabilityRules(
            rules, instruction_pc) then
            return;
        end;
        if ReadTPC() != instruction_pc then
            return;
        end;
    end;
    ClearBundleHeaderState();
    BeginBundleAt(instruction_pc, kind, transfer, target, fallthrough,
        return_target, taken);
    if _LastFault == Fault_None then
        InstallBundleOperationDescriptor(descriptor);
    end;
end;

func ExecuteDecodedBundleStart(instruction: bits(64),
                              form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                              length_bits: integer {16,32,48,64})
begin
    ExecuteDecodedBundleStartWithAcceptedApplicabilityRules(
        NumericApplicabilityRules_None, instruction, form, length_bits);
end;
```
<!-- GENERATED-ASL-END: unit -->
