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
           PTOModelLinxTraceBoundaryCompatibilityEnabled();
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
