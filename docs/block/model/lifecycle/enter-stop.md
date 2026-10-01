<!-- GENERATED FROM: asl/block/model/lifecycle/enter-stop.asl -->
# Enter Stop

**Normative ASL source:** `asl/block/model/lifecycle/enter-stop.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-LIFECYCLE-ENTER-STOP}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-lifecycle-enter-stop-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the two remaining lifecycle transitions of a bundle: entry into the body, and the final stop that retires the bundle and moves the program to its continuation.

A bundle has two phases. In the header phase, configuration commands (`B.*`) accumulate state. In the body phase, ordinary scalar instructions run. The stop transition is the last step of a commit; validation and tile effects happen before it.

<!-- PTO-READER-BLOCK: block-model-lifecycle-enter-stop-concepts role=concepts-state -->
## Concepts and visible state

- `EnterBundleBody` sets `_BundleBodyActive`. The scalar dispatcher calls it for the first scalar instruction executed while a bundle is active and still in its header.
- `StopBundle` calls `StopBundleAt` with `_BundleSequentialPC` as the continuation.
- `StopBundleAt(continuation)` receives the sequential continuation from its caller and computes the next PC with `BARGCommitPC`. The result is `BARG.BPCN` when `BARG` selects the candidate target, and `continuation` otherwise.

<!-- PTO-READER-BLOCK: block-model-lifecycle-enter-stop-rules role=rules-interactions -->
## Rules and interactions

`EnterBundleBody`, `StopBundle`, and `StopBundleAt` each raise `Fault_BundleControl` when no bundle is active.

`StopBundleAt` checks both the continuation and the selected next PC. If either has bit 0 set, it raises `Fault_InstructionPC` with the selected address and leaves the bundle active.

On success, `StopBundleAt` does the following in order:

1. Captures the next PC and the `trap` control attribute from `B.CATR`.
2. Clears `_BundleActive` and `_BundleBodyActive`.
3. Calls `ClearBundleHeaderState` to discard the header configuration and bindings.
4. Resets `BARG` to `Standard`, `Fallthrough`, `taken` false, `BPCN` zero, and clears `_BundleSequentialPC`, `_FrameStackReturnTarget`, and `BPC`.
5. Writes `TPC` with the next PC.
6. If `trap` was set, raises `Fault_BundlePostCommit` with the next PC.

Design point: the next PC and the `trap` flag are read before any state is cleared. Clearing the header erases `B.CATR`, and resetting `BARG` erases the target, so reading afterwards would lose both values.

Design point: the post-commit trap is raised after the block has been fully retired. The ASL comment states that the trap snapshots the committed, cleared state, so recovering that context resumes at the next PC, never at the retired block or its `BSTOP`. A `trap` attribute therefore cannot cause the block to run twice.

Design point: an invalid continuation faults before any clearing. The bundle stays active with its configuration intact, so the saved context still describes the block that failed.

<!-- PTO-READER-BLOCK: block-model-lifecycle-enter-stop-boundaries role=boundaries -->
## Architectural boundaries

`StopBundleAt` does not execute the bundle's operation. The commit owner in [validation](../commit/validation.md) runs the selected tile operation first and calls `StopBundleAt` only after that succeeds.

Local and Shared generation records are not part of the header state, so step 3 leaves them in place. They end only through their own `LAST` or abort paths, or at reset.

<!-- PTO-READER-BLOCK: block-model-lifecycle-enter-stop-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A conditional bundle has `BARG.BPCN = 0x2000`, and a body `SETC` instruction sets `taken` false. A 4-byte `BSTOP` at `0x1040` commits with continuation `0x1044`. `BARGCommitPC` returns `0x1044`, `TPC` becomes `0x1044`, and the header state and `BARG` are cleared. If `taken` had been true, `TPC` would become `0x2000` instead.

<!-- PTO-READER-BLOCK: block-model-lifecycle-enter-stop-related role=related-owners-navigation -->
## Related owners

- [Begin](begin.md) opens the bundle whose state this unit clears.
- [Commit validation](../commit/validation.md) runs legality checks and the operation before calling `StopBundleAt`.
- [BARG helpers](../state/barg.md) define `BARGCommitPC`.
- [Descriptor state](../state/descriptor-state.md) defines `ClearBundleHeaderState`.
- [BSTOP](../../lifecycle/BSTOP.md) is the explicit stop instruction.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/lifecycle/enter-stop.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-LIFECYCLE-ENTER-STOP","surface":"block","classification":["model","lifecycle","enter-stop"],"depends_on":["PTO-BLOCK-MODEL-LIFECYCLE-BEGIN","PTO-BLOCK-MODEL-STATE-BARG"]}
func EnterBundleBody()
begin
    if !_BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    else
        _BundleBodyActive = TRUE;
    end;
end;

func StopBundle()
begin
    if !_BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    else
        StopBundleAt(_BundleSequentialPC);
    end;
end;

func StopBundleAt(continuation: Word)
begin
    if !_BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    elsif continuation[0] == '1' || BARGCommitPC(continuation)[0] == '1' then
        SetFault(Fault_InstructionPC, BARGCommitPC(continuation));
    else
        let next_pc = BARGCommitPC(continuation);
        let post_commit_trap = _BundleControlAttributes.trap_enabled;
        _BundleActive = FALSE;
        _BundleBodyActive = FALSE;
        ClearBundleHeaderState();
        _BARG.block_type = BundleKind_Standard;
        _BARG.transfer_type = BundleTransfer_Fallthrough;
        _BARG.taken = FALSE;
        _BARG.bpcn = Zeros{PTO_XLEN};
        _BundleSequentialPC = Zeros{PTO_XLEN};
        _FrameStackReturnTarget = Zeros{PTO_XLEN};
        WriteBPC(Zeros{PTO_XLEN});
        WriteTPC(next_pc);
        if post_commit_trap then
            // SetFault snapshots the already committed, cleared block state.
            // Recovering that context resumes next_pc, never the retired
            // block or its BSTOP instruction.
            SetFault(Fault_BundlePostCommit, next_pc);
        end;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
