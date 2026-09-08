<!-- GENERATED FROM: asl/block/model/commit/validation.asl -->
# Validation

**Normative ASL source:** `asl/block/model/commit/validation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-COMMIT-VALIDATION}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/commit/validation.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-COMMIT-VALIDATION","surface":"block","classification":["model","commit","validation"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DECODE","PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-ARCH-PROFILE-LINX-RUNTIME-COMPAT"]}
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
// compatibility profile completes that block at the following PC without
// opening a replacement bundle; the portable profile keeps the ordinary
// TRACE boundary lifecycle owned by the dispatch command handler.
readonly func LinxTraceBoundaryHintApplies(
    hint_trace: boolean, instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => boolean
begin
    return hint_trace &&
           CommandDecodedBool(instruction, form, CommandField_B_E) &&
           _BundleActive &&
           PTOModelLinxTraceBoundaryCompatibilityEnabled();
end;

func ExecuteLinxTraceBoundaryHint(
    instruction: bits(64),
    length_bits: integer {16,32,48,64}) => CommandExecutionStatus
begin
    if !CompleteBundleAt(
        ReadTPC() + (Zeros{PTO_XLEN} + (length_bits DIV 8))) then
        return CommandExecution_Rejected;
    end;
    _LastBundleHintPayload = instruction;
    return CommandExecution_Executed;
end;
```
<!-- GENERATED-ASL-END: unit -->
