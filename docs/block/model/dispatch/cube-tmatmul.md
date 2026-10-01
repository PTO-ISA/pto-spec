<!-- GENERATED FROM: asl/block/model/dispatch/cube-tmatmul.asl -->
# CUBE Tmatmul

**Normative ASL source:** `asl/block/model/dispatch/cube-tmatmul.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-cube-tmatmul-purpose role=purpose-scope -->
## Purpose and scope

This unit is the bundle handler for the CUBE matrix family: `TMATMUL`, `TGEMV`, and their `_ACC`, `_BIAS`, and `MX` forms. `ExecuteBundleTMATMULOperation` validates the complete bundle, allocates the destination group, reads the operands, and runs the matrix operation.

Tile execution dispatch calls it at bundle commit when `BundleCubeMatrixSelected` holds: the installed descriptor has the Tile matrix class and a valid selector whose low 5 bits name an assigned matrix function.

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-tmatmul-concepts role=concepts-state -->
## Concepts and visible state

- `LB0`, `LB1`, and `LB2` carry M, N, and K.
- The left type comes from the `BSTART` data type. The right type comes from `B.DATR` when present, and otherwise equals the left type.
- `CCTRL` is the 2-bit `B.DATR` pad field, read as zero without `B.DATR`. Bit 0 selects raw accumulator-type output. Bit 1 is an accumulator prefetch hint.
- A cooperative bundle is a non-GEMV matrix bundle with at least one Shared source. `LB0` then holds the Core-total group M, from 1 to 128. Each PE takes 16 rows when group M is at most 64 and 32 rows otherwise, PE `i` owns at most that many rows, starting at row `i` times that count and stopping at group M.

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-tmatmul-rules role=rules-interactions -->
## Rules and interactions

The handler runs these stages in order.

1. If the PE masks select no PE, it returns success with no effect.
2. It requires `B.FPATR`, else `Fault_BundleControl`, and a decodable CUBE operation, else `Fault_IllegalInstruction`.
3. It checks the bundle structure. The type pair, source and destination counts, `B.DATR` fields, `CCTRL` use, dimensions, and PE masks must be legal. All masks must agree, and a cooperative bundle needs mask `1111`. A GEMV function needs M equal to 1. Failures raise `Fault_TileLegality`.
4. It waits, without a fault, until every Shared source is published, and then checks the Shared schemas.
5. A cooperative PE with zero rows consumes its Shared bindings and returns success.
6. Otherwise it resolves relative sources and subviews and checks Local sources, CScale, accumulator and CScale aliasing, the result layout, and post-processing sources. Dispatch clause `PTO-CUBE-ACCUMULATOR-OUTPUT-001` requires the encoded C selector to differ from the zero-extended destination hand before rename. The current executable instead performs the accumulator check after resolution and compares the physical C `TileIndex` with D's destination hand (`DstTile MOD 4`); issue #367 tracks this conflict.
7. It allocates the destination group, snapshots operands, and runs the operation. A fault then rolls the destinations back.

The result type is `FP32` for MX functions. Otherwise it is `S32`, `U32`, or `FP32` for signed, unsigned, and other left types. `CCTRL` bit 1 is legal only for an accumulator function. Bit 0 requires `pre_quant_mode`, `relu_mode`, and `group_n_code` to be zero and `row_max_en`, `group_max_en`, and `max_abs_en` to be false.

Design point: a zero-row PE keeps the group checks of stages 1 to 4 but skips all Local work. The NDF clause requires this, and the ASL comment says Local preparation starts only after group and Shared preflight derive a nonzero fragment. A PE with no rows therefore still faults on group and Shared errors, but changes no Local Tile.

Design point: allocation happens after every rule is closed and before the first operand snapshot, as the ASL comment states. A legality fault therefore leaves no allocated destination.

Design point: the bit 1 prefetch hint and the replacement hint that accompanies bit 0 call implementation-defined hooks that do nothing in the portable model; the hooks do not change the published result, and bit 0 changes it only by selecting raw accumulator-type output.

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-tmatmul-boundaries role=boundaries -->
## Architectural boundaries

This unit does not compute the matrix product; `TMATMULShared` and `TMATMULMXSharedWithOptionalScales` do. Destination layout and allocation belong to the CUBE destination unit, and Shared operand schemas belong to the shared CUBE matrix unit. After a success, dispatch commits Local generations and retires consumer dependencies, except for a zero-row cooperative PE.

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-tmatmul-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

```text
TMATMUL_ACC <M=16, N=16, K=16, FP16>, T#3, T#2, T#1, ->T<1KB>
```

All sources are Local, so the bundle is not cooperative. Source ordinal 0 is the accumulator `T#3`, ordinal 1 is the left matrix `T#2`, and ordinal 2 is the right matrix `T#1`. The example is executable under the current ASL only when queue resolution maps `T#3` to a physical `TileIndex` different from the `->T` destination hand; the encoded spelling alone does not prove that check. The left type is `FP16`, and with no `B.DATR` the right type is also `FP16`, so the result type is `FP32`.

Now suppose a cooperative `TMATMUL` with a Shared right group and group M of 40. Each PE takes 16 rows. PE0 owns 16 rows, PE1 owns 16, PE2 owns 8, and PE3 owns 0. PE3 passes stages 1 to 4 and then stops at stage 5.

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-tmatmul-related role=related-owners-navigation -->
## Related owners

- [Tile execution dispatch](tile-execution.md) selects this handler and commits after it.
- [CUBE destination](cube-destination.md) resolves and allocates the destination group.
- [Shared CUBE matrix](shared-cube-matrix.md) owns cooperative row distribution and Shared schemas.
- [CUBE accumulator routing](cube-accumulator-routing.md) owns the `CCTRL` rules.
- [TMATMUL_ACC](../../../tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_ACC.md) is the accumulating instruction page.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/cube-tmatmul.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL","surface":"block","classification":["model","dispatch","cube-tmatmul"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-CUBE-DESTINATION","PTO-BLOCK-MODEL-DISPATCH-MATRIX-SCALE","PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX","PTO-BLOCK-MODEL-FAULTS-ROLLBACK","PTO-TILE-MODEL-LEGALITY-MATRIX-OPERANDS","PTO-TILE-MODEL-EXECUTION-CUBE","PTO-TILE-MODEL-EXECUTION-INTERNAL-ACCUMULATOR"]}
// NDF-BEGIN: PTO-CUBE-ACCUMULATOR-OUTPUT-001
// ndf: kind=contract level=L1 layer=block status=accepted
// Every Matrix ACC form MUST bind explicit C and D. C's encoded relative
// selector MUST differ from zero-extended DstTile before any effects, and
// direct Tile calls MUST use different C/D TileIndex values. C MUST remain the
// architectural accumulator input and MUST persist while D, reductions, and
// numeric status publish atomically. CCTRL[1] MAY hint transparent cache use or
// prefetch of C. CCTRL[0] selects raw accumulator-type D output and MAY hint
// transparent cache replacement with the identical published D value.
// NDF-END: PTO-CUBE-ACCUMULATOR-OUTPUT-001
// NDF-BEGIN: PTO-CUBE-GROUP-M-DISTRIBUTION-001
// ndf: kind=contract level=L1 layer=block status=accepted
// Every cooperative Local-A/Shared-B or Shared-A/Shared-B TMATMUL form MUST
// interpret LB0 as Core-total group_M in 1..128 and MUST use PE_MASK=1111.
// group_M<=64 selects M_per_PE=16; group_M>=65 selects M_per_PE=32; PE i owns
// valid_M=clamp(group_M-i*M_per_PE,0,M_per_PE). A zero-row PE MUST retain
// structural, collective, and Shared preflight while suppressing all
// compute-only Local resolution, dependency, subview, alias, allocation,
// generation, payload, parameter, and output effects. TGEMV remains Local-only.
// NDF-END: PTO-CUBE-GROUP-M-DISTRIBUTION-001
readonly func BundleCubeMatrixSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMatrix &&
           _BundleOperation.selector_valid &&
           TileMatrixFunctionAssigned(
               UInt(_BundleOperation.selector[4:0]));
end;
readonly func BundleTMATMULDataAttributesLegal() => boolean
begin
    if !_BundleDataAttributesPresent then return TRUE; end;
    return _BundleDataAttributes.data_layout == Zeros{5} &&
           _BundleDataAttributes.comparison_mode == Zeros{3} &&
           !_BundleDataAttributes.canonicalize;
end;
readonly func BundleTMATMULMasksAgree() => boolean
begin
    var seen = FALSE;
    var selected = Zeros{4};
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            let mask = _BundleTileBindings[[binding]].pe_mask;
            if seen && mask != selected then return FALSE; end;
            selected = mask;
            seen = TRUE;
        end;
    end;
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid then
            let mask = _BundleSharedBindings[[binding]].pe_mask;
            if seen && mask != selected then return FALSE; end;
            selected = mask;
            seen = TRUE;
        end;
    end;
    return seen;
end;
readonly func BundleTMATMULSharedMasksAreZero() => boolean
begin
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].pe_mask != Zeros{4} then
            return FALSE;
        end;
    end;
    return TRUE;
end;
readonly func BundleMatrixPostProcessSourceCount() => integer {0..3}
begin
    return
        (if _BundleFixedPointAttributes.row_max_en &&
            _BundleFixedPointAttributes.row_max_init
         then 1 else 0) +
        (if BundleFPATRModeUsesVectorParameter(
               _BundleFixedPointAttributes.pre_quant_mode)
         then 1 else 0) +
        (if BundleFPATRReluModeUsesVectorParameter(
               _BundleFixedPointAttributes.relu_mode)
         then 1 else 0);
end;
readonly func BundleMatrixDestinationCount() => integer {1..3}
begin
    return 1 +
        (if _BundleFixedPointAttributes.row_max_en then 1 else 0) +
        (if _BundleFixedPointAttributes.group_max_en then 1 else 0);
end;
readonly func BundleMatrixDynamicBindingsComplete(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1},
    function: integer {0..31},
    left_type: TileDataType,
    right_type: TileDataType,
    shared_count: integer {0..4}) => boolean
begin
    if !_BundleFixedPointAttributes.valid ||
       !TileMatrixSharedSourceCountLegal(
           function, left_type, right_type, shared_count) then
        return FALSE;
    end;
    let mathematical_sources = TileMatrixLocalMathematicalSourceCount(
        function, left_type, right_type, shared_count) +
        (if _BundleFixedPointAttributes.c_scale_en then 1 else 0);
    let expected_sources = mathematical_sources +
        BundleMatrixPostProcessSourceCount();
    return BundleLocalTileSourceCount() == expected_sources &&
           BundleLocalTileDestinationCount() + BundleLocalTileParentRefCount() ==
               BundleMatrixDestinationCount() &&
           BundleTileBindingStreamTerminated() &&
           BundleOperationScalarBindingSchemaLegal(operation);
end;
pure func BundleTMATMULCooperativeSelected(
    function: integer {0..31},
    shared_count: integer {0..4}) => boolean
begin
    return shared_count > 0 && !TileMatrixFunctionIsGEMV(function);
end;
pure func BundleTMATMULCooperativeMaskValueLegal(mask: bits(4)) => boolean
begin
    return mask == '1111';
end;
readonly func BundleTMATMULCooperativeMasksLegal(
    function: integer {0..31},
    shared_count: integer {0..4}) => boolean
begin
    if !BundleTMATMULCooperativeSelected(function, shared_count) then
        return TRUE;
    end;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           !BundleTMATMULCooperativeMaskValueLegal(
               _BundleTileBindings[[binding]].pe_mask) then
            return FALSE;
        end;
    end;
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           !BundleTMATMULCooperativeMaskValueLegal(
               _BundleSharedBindings[[binding]].pe_mask) then
            return FALSE;
        end;
    end;
    return TRUE;
end;
readonly func BundleTMATMULSelectedMask() => bits(4)
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            return _BundleTileBindings[[binding]].pe_mask;
        end;
    end;
    return Zeros{4};
end;
readonly func BundleTMATMULCurrentPEInactive() => boolean
begin
    if !BundleCubeMatrixSelected() then return FALSE; end;
    let function = UInt(_BundleOperation.selector[4:0]);
    let shared_count = BundleSharedBindingCount();
    if !BundleTMATMULCooperativeSelected(function, shared_count) then
        return FALSE;
    end;
    let group_m = BundleCubeDimensionValue(BundleDimension_LB0);
    if group_m == 0 || group_m > 128 then return FALSE; end;
    return BundleMatrixCooperativeValidM(
        group_m as integer {1..65535}, _CurrentMemoryAgent) == 0;
end;
readonly func BundleMatrixPrimaryDestinationCapacityBytes()
    => integer {0,128,256,512,1024,2048,4096,8192,16384,32768,65536,
                131072,262144}
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            return BundleTileDestinationSizeBytes(
                binding as BundleTileBindingIndex);
        end;
    end;
    return 0;
end;
readonly func BundleMatrixAccumulatorDestinationIndicesDistinct(
    function: integer {0..31}) => boolean
begin
    if !TileMatrixFunctionUsesAccumulator(function) then return TRUE; end;
    let (destination_seen, destination_hand) =
        BundleMatrixPrimaryDestinationHand();
    if !destination_seen then return FALSE; end;
    var accumulator: TileIndex = 0;
    var found = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if !found && _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                accumulator = BundleTileArchitecturalSourceIndex(
                    binding as BundleTileBindingIndex, FALSE);
                found = TRUE;
            elsif _BundleTileBindings[[binding]].source1_valid then
                accumulator = BundleTileArchitecturalSourceIndex(
                    binding as BundleTileBindingIndex, TRUE);
                found = TRUE;
            end;
        end;
    end;
    if !found then return FALSE; end;
    return accumulator != destination_hand;
end;
func ExecuteBundleTMATMULOperation() => boolean
begin
    // Zero-mask B.IOT/B.IOS commands do not install bindings.  Their sole
    // architectural trace is the participation marker, which exits before
    // descriptor, readiness, dimension, allocation, or payload inspection.
    if SelectedBundleTileMaskIsZero() &&
       BundleTMATMULSharedMasksAreZero() then
        return TRUE;
    end;
    if !_BundleFixedPointAttributes.valid then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    let decoded = DecodeTileOperation(TileDecode_CUBE,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let function = UInt(_BundleOperation.selector[4:0]);
    let cctrl = BundleTMATMULCCTRL();
    let left_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let right_type = if _BundleDataAttributesPresent then
        TileDataTypeFromEncoding(
            _BundleDataAttributes.data_type as TileDataTypeEncoding)
        else left_type;
    let shared_count = BundleSharedBindingCount();
    let matrix_types_legal = if TileMatrixFunctionUsesMX(function) then
        TileMXOperandPairLegal(left_type, right_type)
    else
        TileOrdinaryMatrixInputTypesSameClass(left_type, right_type);
    if !matrix_types_legal ||
       !BundleMatrixDynamicBindingsComplete(
           operation, function, left_type, right_type, shared_count) ||
       !BundleTMATMULDataAttributesLegal() ||
       !BundleTMATMULAccumulatorControlLegal(function, cctrl) ||
       !BundleTMATMULPartialPostProcessLegal(cctrl) ||
       !BundleTMATMULDimensionsLegal(shared_count) ||
       !SelectedBundleTileMasksLegal() ||
       !BundleTMATMULMasksAgree() ||
       !BundleTMATMULCooperativeMasksLegal(function, shared_count) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let m_raw = BundleCubeDimensionValue(BundleDimension_LB0);
    let n_raw = BundleCubeDimensionValue(BundleDimension_LB1);
    let k_raw = BundleCubeDimensionValue(BundleDimension_LB2);
    let m = m_raw as integer {1..65535};
    let n = n_raw as integer {1..65535};
    let k = k_raw as integer {1..65535};
    if TileMatrixFunctionIsGEMV(function) && m != 1 then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    // Structurally legal Shared groups wait until whole-ready and published.
    if !BundleMatrixSharedSourcesReady(shared_count) then return FALSE; end;
    if !BundleMatrixSharedSchemasLegal(
           function, left_type, right_type,
           m, n, k, shared_count) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let cooperative = BundleTMATMULCooperativeSelected(
        function, shared_count);
    let valid_m = if cooperative then
        BundleMatrixCooperativeValidM(m, _CurrentMemoryAgent)
    else m;
    if cooperative && valid_m == 0 then
        ConsumeBundleSharedBindings(shared_count as integer {1..4});
        FinalizeBundleTileAttempt(TileExecution_Executed);
        return TRUE;
    end;
    let pe_m = valid_m as integer {1..65535};
    // Generic Stage2 Local dependency/subview/generation work occurs only
    // after group-level and Shared preflight has derived a nonzero current-PE
    // fragment. Zero-row PEs returned above without touching Local state.
    if !PrepareSelectedBundleStage2() then return FALSE; end;
    if !ReuseBundleLocalGenerationDestination() then return FALSE; end;
    if !BundleOperationGPRBindingValuesLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let mathematical_sources = TileMatrixLocalMathematicalSourceCount(
        function, left_type, right_type, shared_count) +
        (if _BundleFixedPointAttributes.c_scale_en then 1 else 0);
    let result_type = if TileMatrixFunctionUsesMX(function) then
        TileDataType_FP32
    else
        TileOrdinaryMatrixAccumulatorType(left_type, right_type);
    if _BundleFixedPointAttributes.c_scale_en &&
       (!TileMatrixFunctionAllowsCScale(function) ||
        result_type != TileDataType_FP32) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !BundleMatrixLocalMathematicalSourcesLegal(
           function, left_type, right_type, pe_m, n, k, shared_count,
           result_type, BundleMatrixPrimaryDestinationCapacityBytes()) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !BundleMatrixAccumulatorDestinationIndicesDistinct(function) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if _BundleFixedPointAttributes.c_scale_en &&
       !BundleMatrixCScaleDestinationIndicesDistinct(
           (mathematical_sources - 1) as integer {0..8}) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let (layout_found, primary_layout) =
        BundleMatrixCooperativeMLayout(
            function, right_type, pe_m, shared_count);
    if !layout_found then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !BundleMatrixPostProcessSourcesLegal(
           mathematical_sources, pe_m, n, result_type, primary_layout) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    // Every field, stream, Local/Shared descriptor, parameter payload, shape,
    // and capacity rule is now closed. Allocate the atomic destination group
    // before taking the first mathematical or scalar payload snapshot.
    let allocation_mask = if cooperative then
        BundleMatrixCooperativeCurrentPEMask(m, _CurrentMemoryAgent)
    else BundleTMATMULSelectedMask();
    let partial_output = BundleTMATMULRawPartialOutput(cctrl);
    if !ResolveBundleTMATMULDestination(
           pe_m, n, result_type, TRUE, primary_layout,
           allocation_mask) then
        return FALSE;
    end;
    if !ValidateBundleLocalGenerationWriters() then
        RollBackBundleTileDestinations();
        return FALSE;
    end;
    let operands = BundleTileInstructionOperands(operation);
    var left = _Tiles[[0]];
    var right = _Tiles[[0]];
    var left_scale = _Tiles[[0]];
    var right_scale = _Tiles[[0]];
    let left_scale_present = TileMatrixFunctionUsesMX(function) &&
        TileMXInputTypeNeedsScale(left_type);
    let right_scale_present = TileMatrixFunctionUsesMX(function) &&
        TileMXInputTypeNeedsScale(right_type);
    var accumulator: TileIndex = operands.destination0;
    var bias: TileIndex = operands.destination0;
    var c_scale: TileIndex = operands.destination0;
    var local_ordinal: integer {0..6} = 0;
    var shared_ordinal: integer {0..4} = 0;
    if TileMatrixFunctionUsesAccumulator(function) then
        accumulator = BundleMatrixSourceAt(
            local_ordinal as integer {0..8});
        local_ordinal = (local_ordinal + 1) as integer {0..6};
    end;
    if shared_count == 0 then
        left = _Tiles[[BundleMatrixSourceAt(
            local_ordinal as integer {0..8})]];
        local_ordinal = (local_ordinal + 1) as integer {0..6};
        if left_scale_present then
            left_scale = _Tiles[[BundleMatrixSourceAt(
                local_ordinal as integer {0..8})]];
            local_ordinal = (local_ordinal + 1) as integer {0..6};
        end;
        right = _Tiles[[BundleMatrixSourceAt(
            local_ordinal as integer {0..8})]];
        local_ordinal = (local_ordinal + 1) as integer {0..6};
        if right_scale_present then
            right_scale = _Tiles[[BundleMatrixSourceAt(
                local_ordinal as integer {0..8})]];
            local_ordinal = (local_ordinal + 1) as integer {0..6};
        end;
    else
        let right_group = TileMatrixRightGroupSourceCount(
            function, right_type);
        if shared_count == right_group then
            left = _Tiles[[BundleMatrixSourceAt(
                local_ordinal as integer {0..8})]];
            local_ordinal = (local_ordinal + 1) as integer {0..6};
            if left_scale_present then
                left_scale = _Tiles[[BundleMatrixSourceAt(
                    local_ordinal as integer {0..8})]];
                local_ordinal = (local_ordinal + 1) as integer {0..6};
            end;
        else
            left = MaterializeBundleSharedMatrixLeftPrimary(
                shared_ordinal as integer {0..3},
                m, k, left_type,
                _BundleFixedPointAttributes.trans_a,
                _CurrentMemoryAgent);
            shared_ordinal = (shared_ordinal + 1) as integer {0..4};
            if left_scale_present then
                left_scale = MaterializeBundleSharedMatrixLeftScale(
                    shared_ordinal as integer {0..3},
                    m, k, left_type,
                    _CurrentMemoryAgent);
                shared_ordinal = (shared_ordinal + 1) as integer {0..4};
            end;
        end;
        right = MaterializeBundleSharedMatrixPrimary(
            shared_ordinal as integer {0..3},
            k, n, right_type,
            _BundleFixedPointAttributes.trans_b,
            _CurrentMemoryAgent);
        shared_ordinal = (shared_ordinal + 1) as integer {0..4};
        if right_scale_present then
            let scale_groups = TileMXScaleGroupCount(k, right_type);
            right_scale = MaterializeBundleSharedMatrixPrimary(
                shared_ordinal as integer {0..3},
                scale_groups, n,
                TileMXScaleCarrierType(right_type),
                FALSE, _CurrentMemoryAgent);
            shared_ordinal = (shared_ordinal + 1) as integer {0..4};
        end;
    end;

    if TileMatrixFunctionUsesBias(function) then
        bias = BundleMatrixSourceAt(
            local_ordinal as integer {0..8});
        local_ordinal = (local_ordinal + 1) as integer {0..6};
    end;

    if _BundleFixedPointAttributes.c_scale_en then
        c_scale = BundleMatrixSourceAt(
            local_ordinal as integer {0..8});
    end;

    let right_group = TileMatrixRightGroupSourceCount(
        function, right_type);
    let shape_legal = if shared_count == 0 then
        TileMatrixCubeInfosMatchDimensions(left, right, pe_m, n, k)
    else if shared_count == right_group then
        TileMatrixMixedInfosMatchDimensions(left, right, pe_m, n, k)
    else
        TileMatrixInfosMatchDimensions(left, right, pe_m, n, k);
    let operand_types_legal = left.data_type == left_type &&
        right.data_type == right_type;
    let scales_legal = !TileMatrixFunctionUsesMX(function) ||
        TileMatrixInfoOptionalScalesLegal(
            left, left_scale, left_scale_present,
            right, right_scale, right_scale_present);
    assert shape_legal && operand_types_legal && scales_legal;

    let accumulator_legal = !TileMatrixFunctionUsesAccumulator(function) ||
        TileMatrixLocalCubeAccumulatorSchemaLegal(
            accumulator, pe_m, n, result_type, primary_layout,
            BundleMatrixPrimaryDestinationCapacityBytes());
    assert accumulator_legal;
    assert !TileMatrixFunctionUsesBias(function) ||
           TileMatrixInfoBiasLegal(
               left, right, bias, TileMatrixFunctionUsesMX(function));
    if TileMatrixFunctionUsesAccumulator(function) &&
       BundleTMATMULAccumulatorPrefetchHint(cctrl) then
        TileProfileInternalAccumulatorPrefetchHint(
            accumulator, _Tiles[[accumulator]].cube_storage_bytes);
    end;
    let destination = BundleMatrixDestinationAt(0);
    let destination_template = _Tiles[[destination]];
    if TileMatrixFunctionUsesMX(function) then
        TMATMULMXSharedWithOptionalScales(
            destination, destination_template, accumulator,
            left, left_scale, left_scale_present,
            right, right_scale, right_scale_present,
            bias, TileMatrixFunctionUsesBias(function),
            TileMatrixFunctionUsesAccumulator(function),
            c_scale, _BundleFixedPointAttributes.c_scale_en,
            cctrl[0:0] != Zeros{1});
    else
        TMATMULShared(
            destination, destination_template, accumulator, left, right, bias,
            TileMatrixFunctionUsesBias(function),
            TileMatrixFunctionUsesAccumulator(function),
            c_scale, _BundleFixedPointAttributes.c_scale_en,
            cctrl[0:0] != Zeros{1});
    end;
    if _LastFault != Fault_None then
        RollBackBundleTileDestinations();
        return FALSE;
    end;
    if partial_output then
        TileProfileInternalAccumulatorReplacementHint(
            destination, _Tiles[[destination]].cube_storage_bytes);
    end;
    if shared_count > 0 then
        ConsumeBundleSharedBindings(shared_count as integer {1..4});
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
