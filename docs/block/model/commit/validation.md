<!-- GENERATED FROM: asl/block/model/commit/validation.asl -->
# Validation

**Normative ASL source:** `asl/block/model/commit/validation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-COMMIT-VALIDATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-commit-validation-purpose role=purpose-scope -->
## Purpose and scope

This unit defines bundle commit. `CompleteBundleAt(continuation)` is called by `BSTOP`, by a following `BSTART`, by a trace `B.HINT` that closes the active bundle, and by the architecture enter request. It checks that the bundle may commit, runs the selected tile operation, and then retires the bundle through `StopBundleAt`.

The unit also defines the Linx runtime trace-boundary hint helpers.

<!-- PTO-READER-BLOCK: block-model-commit-validation-concepts role=concepts-state -->
## Concepts and visible state

Commit reads the accumulated bundle state: the `BARG` continuation record, the `B.CATR` control attributes, and the operation descriptor installed by `BSTART`. The `continuation` argument is the sequential next address. `BSTOP` passes the address after itself; a following `BSTART` or a trace `B.HINT` passes its own address, so a fall-through predecessor continues into that instruction; the architecture enter request passes `_BundleSequentialPC`.

The result is true only when commit finished with no fault.

<!-- PTO-READER-BLOCK: block-model-commit-validation-rules role=rules-interactions -->
## Rules and interactions

Commit applies these steps in order and stops at the first failure:

1. No active bundle raises `Fault_BundleControl`.
2. An odd continuation, or an odd next PC selected by `BARG`, raises `Fault_InstructionPC`.
3. The `DR` (dimension reduction) control attribute on a block that is not `TileElement` or `TileMemory` raises `Fault_BundleControl`.
4. A tile-operation descriptor (`TileElement`, `TileMemory`, or `TileMatrix`) runs the tile operation. If it fails, commit returns false. A `FixedPoint` descriptor raises `Fault_IllegalInstruction`.
5. `StopBundleAt(continuation)` retires the bundle and writes `TPC`.

Design point: the continuation is checked before any tile effect. The ASL comment notes that `SETC.TGT` can replace `BARG.BPCN` after `BSTART`, so the final target is known only at commit. Checking it first means a bad target never leaves behind a published Tile result.

Design point: `DR` is checked at commit, not when `B.CATR` executes. The ASL comment explains that the raw bit may be collected before the complete header selects its operation. The check reads the block kind from `BARG` and runs at commit, before any block effect.

Design point: a failed tile operation returns before `StopBundleAt`. The bundle therefore stays active with its header intact, and the `BARG` continuation is not applied. The tile-execution owner has already rolled back allocations and aborted generations. A trap handler sees the failing block, and recovery can retry it as a whole.

<!-- PTO-READER-BLOCK: block-model-commit-validation-boundaries role=boundaries -->
## Architectural boundaries

This unit does not contain operation-specific legality. Schema, binding, type, and shape checks live in the tile-execution path, which checks them before destination allocation and the operation body.

A bundle with no valid descriptor, or a control-only descriptor, commits without an operation and goes straight to `StopBundleAt`.

`LinxTraceBoundaryHintApplies` always returns false, because its condition ends with a constant `FALSE`. The portable profile therefore never takes the Linx marker path, and trace hints follow the ordinary `B.HINT` lifecycle.

<!-- PTO-READER-BLOCK: block-model-commit-validation-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A bundle `BSTART.VEC TADD, FP32` has a missing source binding. `BSTOP` calls `CompleteBundleAt`. Steps 1 to 3 pass. The tile path rejects the incomplete operand set with `Fault_BundleControl` and returns false. `StopBundleAt` is not reached. The trap context saved by the fault records the bundle as active and the `BSTOP` address as its `TPC`, and no destination Tile exists.

<!-- PTO-READER-BLOCK: block-model-commit-validation-related role=related-owners-navigation -->
## Related owners

- [Tile execution](../dispatch/tile-execution.md) runs the selected operation with its own preflight and rollback.
- [Enter and stop](../lifecycle/enter-stop.md) defines `StopBundleAt`.
- [Bundle start dispatch](../dispatch/start.md) commits a predecessor before opening a new bundle.
- [BSTOP](../../lifecycle/BSTOP.md) and [B.HINT](../../lifecycle/B.HINT.md) are commit boundaries.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/commit/validation.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-COMMIT-VALIDATION","surface":"block","classification":["model","commit","validation"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DECODE","PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION","PTO-BLOCK-MODEL-STATE-CONTROL-STATE"]}
func CompleteBundleAtWithAcceptedApplicabilityRules(
    rules: NumericApplicabilityRuleSet, continuation: Word) => boolean
begin
    if !_BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    // SETC.TGT can replace BARG.BPCN after BSTART. Validate the final selected
    // continuation before any tile or block effect is made visible.
    if continuation[0] == '1' || BARGCommitPC(continuation)[0] == '1' then
        SetFault(Fault_InstructionPC, BARGCommitPC(continuation));
        return FALSE;
    end;
    // DR is group execution for VEC/SFU/TLSU only.  The raw bit may be
    // collected before the complete header selects its operation, so reject
    // the incompatible completed block here, before any block effect.
    if _BundleControlAttributes.dimension_reduction &&
       _BARG.block_type != BundleKind_TileElement &&
       _BARG.block_type != BundleKind_TileMemory then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if _BundleOperation.valid then
        if _BundleOperation.operation_class == BundleOperation_TileElement ||
           _BundleOperation.operation_class == BundleOperation_TileMemory ||
           _BundleOperation.operation_class == BundleOperation_TileMatrix then
            if !ExecuteBundleTileOperationWithAcceptedApplicabilityRules(
                rules) then
                return FALSE;
            end;
        elsif _BundleOperation.operation_class == BundleOperation_FixedPoint then
            SetFault(Fault_IllegalInstruction, ReadTPC());
            return FALSE;
        end;
    end;
    StopBundleAt(continuation);
    return _LastFault == Fault_None;
end;

func CompleteBundleAt(continuation: Word) => boolean
begin
    return CompleteBundleAtWithAcceptedApplicabilityRules(
        NumericApplicabilityRules_None, continuation);
end;

// A TRACE hint selects the active direct block boundary. The Linx runtime
// compatibility profile records the boundary kind as a marker of the active
// block; the marker takes effect only when that block commits at its own
// boundary, so the hint never completes the block itself and cannot re-drive
// an active frame template. The portable profile keeps the ordinary TRACE
// boundary lifecycle owned by the dispatch command handler.
readonly func LinxTraceBoundaryHintApplies(
    hint_trace: boolean, instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => boolean
begin
    return hint_trace &&
           CommandDecodedBool(instruction, form, CommandField_B_E) &&
           _BundleActive &&
           FALSE;
end;

func ExecuteLinxTraceBoundaryHint(
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => CommandExecutionStatus
begin
    // Marker only: the trace boundary starts at the active block and takes
    // effect when that block commits at its own boundary. The hint does not
    // complete the block and has no memory effects, so an active frame
    // template keeps its saved state until its own commit.
    _LastBundleHintPayload = instruction;
    _BundleHint.present = TRUE;
    _BundleHint.trace = TRUE;
    _BundleHint.trace_end =
        CommandDecodedBool(instruction, form, CommandField_B_E);
    _BundleHint.branch_valid = FALSE;
    _BundleHint.branch_likely = FALSE;
    _BundleHint.temperature = Zeros{2};
    _BundleHint.prefetch_size = Zeros{12};
    BundleTransformHint();
    return CommandExecution_Executed;
end;
```
<!-- GENERATED-ASL-END: unit -->
