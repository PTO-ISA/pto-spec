<!-- GENERATED FROM: asl/block/model/dispatch/tile-execution.asl -->
# Tile Execution

**Normative ASL source:** `asl/block/model/dispatch/tile-execution.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tile-execution.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION","surface":"block","classification":["model","dispatch","tile-execution"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL","PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-GENERATION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-HISTOGRAM-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-PARTIAL-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-REDUCTION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-SORTING-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV","PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER","PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-CAS","PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-MASK","PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER","PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER-MASK","PTO-BLOCK-MODEL-DISPATCH-TLSU-PREFETCH","PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU","PTO-TILE-MODEL-DISPATCH-TOP-LEVEL"]}
readonly func BundleTileTypesMatch(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1},
    operands: TileInstructionOperands,
    expected: TileDataType) => boolean
begin
    if TileOperandPresent(operation, TileOperand_destination0) &&
       _Tiles[[operands.destination0]].allocated &&
       _Tiles[[operands.destination0]].data_type != expected then return FALSE; end;
    if TileOperandPresent(operation, TileOperand_source0) &&
       _Tiles[[operands.source0]].allocated &&
       _Tiles[[operands.source0]].data_type != expected then return FALSE; end;
    if TileOperandPresent(operation, TileOperand_source1) &&
       _Tiles[[operands.source1]].allocated &&
       _Tiles[[operands.source1]].data_type != expected then return FALSE; end;
    return TRUE;
end;

func ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules(
    rules: NumericApplicabilityRuleSet) => boolean
begin
    if _BundleZeroParticipationSeen && BundleTileBindingCount() == 0 &&
       BundleSharedBindingCount() == 0 then return TRUE; end;
    if BundleCubeMatrixSelected() then
        return ExecuteBundleTMATMULOperation();
    elsif BundleGMOVSelected() then
        return ExecuteBundleGMOVOperation();
    elsif BundleMGATHERCASSelected() then
        return ExecuteBundleMGATHERCASOperation();
    elsif BundleMGATHERMASKSelected() then
        return ExecuteBundleMGATHERMASKOperation();
    elsif BundleMGATHERSelected() then
        return ExecuteBundleMGATHEROperation();
    elsif BundleMSCATTERSelected() then
        return ExecuteBundleMSCATTEROperation();
    elsif BundleMSCATTERMASKSelected() then
        return ExecuteBundleMSCATTERMASKOperation();
    elsif BundleTPREFETCHSelected() then
        return ExecuteBundleTPREFETCHOperation();
    elsif BundleSharedTLSUSelected() then
        return ExecuteBundleSharedTLSUOperation();
    elsif BundleSharedBindingsUnconsumed() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let family = BundleTileDecodeFamily(_BundleOperation.operation_class);
    let code = BundleOperationDecodeCode(_BundleOperation);
    let decoded = DecodeTileOperation(family, code);
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if SelectedBundleTileMaskIsZero() then return TRUE; end;
    if _BundleFixedPointAttributes.valid &&
       _BundleOperation.operation_class != BundleOperation_TileMatrix then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if !BundleOperationBindingsComplete(operation) then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    // Validate raw B.IOR controls only after the PE mask zero no-effect exit
    // and before destination allocation/resolution.  Invalid values never
    // enter constrained TileInstructionOperands fields or architectural Tile
    // state.
    if !BundleOperationGPRBindingValuesLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then
        return FALSE;
    end;
    if !SelectedBundleClosedBinarySchemaLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleClosedUnarySchemaLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleClosedTFMASchemaLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleClosedQuantizationSchemaLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleClosedGenerationSchemaLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleClosedHistogramSchemaLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleClosedReductionSchemaLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleClosedSortingSchemaLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleClosedPartialSchemaLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleClosedExpansionSchemaLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleClosedTCVTSchemaLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleClosedTCMPSchemaLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleClosedTSELSchemaLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleClosedTileScalarBinarySchemaLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleClosedTCMPSSchemaLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleClosedTSELSSchemaLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleClosedTEXPANDSSchemaLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileMasksLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !ResolveBundleTileDestinationsForOperation(operation) then return FALSE; end;
    let operands = BundleTileInstructionOperands(operation);
    let (status, -) =
        ExecuteTileInstructionWithoutTimeWithAcceptedApplicabilityRules(
            rules, family, code, operands);
    if _LastFault != Fault_None || status != TileExecution_Executed then
        RollBackBundleTileDestinations();
        return FALSE;
    end;
    FinalizeBundleTileAttempt(status);
    return TRUE;
end;

func ExecuteFarBundleTileOperationWithAcceptedApplicabilityRules(
    rules: NumericApplicabilityRuleSet) => boolean
begin
    // Routing and transport are not architecturally observable.  The formal
    // model therefore executes the selected operation against the initiating
    // core's captured inputs and publishes the returned results only through
    // the same commit path as a local block.  A concrete implementation may
    // dispatch this work to the target selected by its routing state, but it
    // may not expose an intermediate remote result or a partial local commit.
    return ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules(
        rules);
end;

func ExecuteBundleTileOperationWithAcceptedApplicabilityRules(
    rules: NumericApplicabilityRuleSet) => boolean
begin
    if _BundleControlAttributes.far then
        return ExecuteFarBundleTileOperationWithAcceptedApplicabilityRules(
            rules);
    else
        return ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules(
            rules);
    end;
end;

func ExecuteBundleTileOperation() => boolean
begin
    return ExecuteBundleTileOperationWithAcceptedApplicabilityRules(
        NumericApplicabilityRules_None);
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
