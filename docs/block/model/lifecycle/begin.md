<!-- GENERATED FROM: asl/block/model/lifecycle/begin.asl -->
# Begin

**Normative ASL source:** `asl/block/model/lifecycle/begin.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-LIFECYCLE-BEGIN}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-lifecycle-begin-purpose role=purpose-scope -->
## Purpose and scope

This unit defines what happens at the moment a bundle opens. A bundle (also called a block) is a group of instructions that starts with a `BSTART` form, collects configuration from header commands such as `B.DIM`, `B.DATR`, and `B.IOT`, and ends at a commit boundary: `BSTOP` or the next `BSTART`.

`BeginBundleAt` is the single state transition that marks a bundle active and records where the program continues after the bundle commits. `BeginBundle` is the same transition with the current `TPC` used as the start address.

<!-- PTO-READER-BLOCK: block-model-lifecycle-begin-concepts role=concepts-state -->
## Concepts and visible state

A successful begin writes the following state.

- `_BundleActive` becomes true and `_BundleBodyActive` becomes false. The bundle is now in its header phase.
- The per-bundle markers `_BundleCommitTargetSet`, `_BundleConditionSet`, and `_SystemBlockTerminalPending` are cleared.
- `BARG` receives the block kind, the transfer type, the `taken` flag, and the candidate next address `BPCN`. `BARG` is the bundle argument register: the single record that decides where execution goes when the bundle commits.
- `_BundleSequentialPC` receives the address of the instruction after the `BSTART`, and `_FrameStackReturnTarget` receives the supplied return target.
- `BPC` is set to the `BSTART` address, and `TPC` is set to the sequential address, so the next fetched instruction is the first header command.
- A fresh execution-domain token is taken from `_NextBundleExecutionDomainToken`, and the counter is incremented.

For a call or indirect call, `_ReturnAddress` and GPR 10 are also written with the return target.

<!-- PTO-READER-BLOCK: block-model-lifecycle-begin-rules role=rules-interactions -->
## Rules and interactions

Begin faults in two cases, and in both cases it changes no bundle state. If a bundle is already active, it raises `Fault_BundleControl` at the current `TPC`. If the target address has bit 0 set, it raises `Fault_InstructionPC` with that target.

A system block (`BundleKind_System`) ignores the supplied transfer. Its `BARG` is written as `Fallthrough`, `taken` false, and `BPCN` zero.

Design point: a SYS block has no candidate continuation, so it stores a fixed canonical value instead of whatever the encoding supplied. Its `BARG` can therefore never select `BPCN` at commit, and no leftover target from the encoding reaches the commit decision.

Design point: `BSTART` does not change control flow when it executes. It only records the candidate target in `BARG.BPCN` and moves `TPC` to the next sequential instruction. The transfer is applied later, at the commit boundary, after the whole bundle has been validated. A bundle that faults before it retires has therefore not yet redirected the program.

Design point: every dynamic execution of a bundle gets a new execution-domain token, even when the same `BSTART` address runs again. The ASL comment states the reason: static `BSTART` addresses are program locations and never stand in for dynamic replay or squash identity. Two runs of one loop body are therefore distinct writers.

<!-- PTO-READER-BLOCK: block-model-lifecycle-begin-boundaries role=boundaries -->
## Architectural boundaries

This unit does not decode the `BSTART` encoding, validate the operation descriptor, or commit a predecessor bundle. The dispatch owner does those steps first. It checks the target, commits any active predecessor, and continues only if that commit selected this `BSTART` address as the next `TPC`; if the predecessor transferred elsewhere, this `BSTART` is on an unselected path and is not installed. Otherwise dispatch clears the header state and then calls `BeginBundleAt`. After a fault-free begin it installs the operation descriptor.

The odd-target check here applies to the target passed in. A later `SETC.TGT` may replace `BPCN`, and that final value is checked again at commit.

<!-- PTO-READER-BLOCK: block-model-lifecycle-begin-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Suppose a 4-byte `BSTART DIRECT, <label>` sits at address `0x1000` and the label is at `0x2000`. After begin, `BPC` is `0x1000`, `BARG.BPCN` is `0x2000`, `_BundleSequentialPC` and `TPC` are `0x1004`, and the bundle is in its header phase. Execution continues at `0x1004`. The jump to `0x2000` happens only when the bundle commits.

<!-- PTO-READER-BLOCK: block-model-lifecycle-begin-related role=related-owners-navigation -->
## Related owners

- [Bundle start dispatch](../dispatch/start.md) validates the descriptor, commits a predecessor, and calls this transition.
- [BARG helpers](../state/barg.md) define how the recorded fields select the next PC at commit.
- [Enter and stop](enter-stop.md) defines body entry and the commit-time clearing of this state.
- [BSTART](../../lifecycle/BSTART.md) is the instruction page for the plain start forms.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/lifecycle/begin.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-LIFECYCLE-BEGIN","surface":"block","classification":["model","lifecycle","begin"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-ATTRIBUTES"]}
func BeginBundleAt(start_pc: Word, kind: BundleKind, transfer: BundleTransfer,
                   target: Word, sequential: Word, return_target: Word,
                   taken: boolean)
begin
    if _BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    elsif target[0] == '1' then
        SetFault(Fault_InstructionPC, target);
    else
        _BundleActive = TRUE;
        _BundleBodyActive = FALSE;
        _BundleCommitTargetSet = FALSE;
        _BundleConditionSet = FALSE;
        _SystemBlockTerminalPending = FALSE;
        _BARG.block_type = kind;
        if kind == BundleKind_System then
            // SYS has no architectural candidate continuation. Keep the
            // shared representation in a canonical non-selecting state.
            _BARG.transfer_type = BundleTransfer_Fallthrough;
            _BARG.taken = FALSE;
            _BARG.bpcn = Zeros{PTO_XLEN};
        else
            _BARG.transfer_type = transfer;
            _BARG.taken = taken;
            _BARG.bpcn = target;
        end;
        _BundleSequentialPC = sequential;
        _FrameStackReturnTarget = return_target;
        // Each dynamic block execution receives a distinct mathematical
        // domain identity. Static BSTART addresses remain program locations
        // and never stand in for dynamic replay/squash identity.
        _BundleExecutionDomainToken = _NextBundleExecutionDomainToken;
        _NextBundleExecutionDomainToken =
            _NextBundleExecutionDomainToken + 1;
        // BPC is the address of this BSTART. BPCN is retained in
        // BARG.BPCN until BSTOP or the next BSTART commits the block.
        WriteBPC(start_pc);
        // BSTART installs the transfer selected for the bundle commit. Header
        // commands remain sequential until BSTOP or the next BSTART commits it.
        WriteTPC(sequential);
        if transfer == BundleTransfer_Call ||
           transfer == BundleTransfer_IndirectCall then
            _ReturnAddress = return_target;
            WriteGPR(10, return_target);
        end;
    end;
end;

func BeginBundle(kind: BundleKind, transfer: BundleTransfer, target: Word,
                 sequential: Word, return_target: Word, taken: boolean)
begin
    BeginBundleAt(ReadTPC(), kind, transfer, target, sequential,
        return_target, taken);
end;
```
<!-- GENERATED-ASL-END: unit -->
