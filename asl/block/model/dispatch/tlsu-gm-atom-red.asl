// PTO-UNIT: {"classification":["model","dispatch","tlsu-gm-atom-red"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-CAS","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE-VALIDATION","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE-WRITER-EFFECTS","PTO-TILE-MODEL-MEMORY-GM-ATOM-RED","PTO-TILE-MODEL-MEMORY-GM-ATOM-RED-EXECUTION","PTO-TILE-MODEL-MEMORY-GM-ATOM-RED-VALUES"],"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-GM-ATOM-RED","surface":"block"}

readonly func BundleGMAtomRedSelected() => boolean
begin
    if !_BundleOperation.valid ||
       _BundleOperation.operation_class != BundleOperation_TileMemory ||
       !_BundleOperation.selector_valid then return FALSE; end;
    let function = UInt(_BundleOperation.selector[4:0]);
    return (function >= 8 && function <= 12) ||
           (function >= 14 && function <= 27);
end;

readonly func BundleGMAtomRedDataTypeLegal(function: integer {0..31},
                                           data_type: TileDataType) => boolean
begin
    if function <= 18 then
        return GMAtomicOperationDataTypeLegal(
            GMAtomicOperationFromFunction(function), data_type);
    end;
    return GMReductionOperationDataTypeLegal(
        GMReductionOperationFromFunction(function), data_type);
end;

func ExecuteBundleGMAtomRedOperation() => (boolean, BundleLocalGenerationCubeWriterEffects)
begin
    var result_writer_effects = EmptyBundleLocalGenerationCubeWriterEffects();
    // PE_MASK=0000 exits before every schema, descriptor, type, or memory check.
    if SelectedBundleTileMaskIsZero() then return (TRUE, result_writer_effects); end;
    let function = UInt(_BundleOperation.selector[4:0]) as integer {0..31};
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if BundleSharedBindingCount() != 0 ||
       !_BundleScalarBindings[[0]].valid ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !SelectedBundleTileMasksLegal() ||
       !BundleMGATHERDimensionsLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return (FALSE, result_writer_effects); end;
    let binding = _BundleTileBindings[[0]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    let atom = function <= 18;
    let cas = function == 8;
    let popc = function == 27;
    var expected_binding_count: integer {1..2} = 1;
    if cas then expected_binding_count = 2; end;
    if execution_mask_tile && !popc && !cas then
        expected_binding_count = 2;
    end;
    if atom && BundleTileBindingCount() != expected_binding_count then
        SetFault(Fault_BundleControl, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    if !atom && BundleTileBindingCount() != expected_binding_count then
        SetFault(Fault_BundleControl, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    // mgather.cas and the legacy MGATHER.CAS alias use the two-command schema:
    // the first B.IOT carries indices and expected values, while the second
    // carries replacement and the destination.  Other atom forms carry all
    // operands in one destination-bearing B.IOT.
    if !binding.valid || !binding.source0_valid ||
       ((!cas && !popc &&
         (binding.last == execution_mask_tile)) || (cas && binding.last)) ||
       (cas && (binding.destination_valid || !binding.source1_valid)) ||
       (cas && execution_mask_tile &&
        (_BundleTileBindings[[1]].source1_valid == FALSE)) ||
       (!cas && !execution_mask_tile &&
        binding.destination_valid != atom) ||
       (execution_mask_tile && atom && !cas &&
        binding.destination_valid) ||
       (!popc && !cas && !binding.source1_valid) then
        SetFault(Fault_TileLegality, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    if execution_mask_tile && !cas && !popc then
        let final_binding = _BundleTileBindings[[1]];
        if !final_binding.valid || !final_binding.source0_valid ||
           final_binding.source1_valid || !final_binding.last ||
           (final_binding.destination_valid != atom) then
            SetFault(Fault_TileLegality, ReadTPC());
            return (FALSE, result_writer_effects);
        end;
    end;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !BundleGMAtomRedDataTypeLegal(function, data_type) ||
       !IndexedTLSUExecutionMaskContentsDefined(binding.source0) ||
       (!popc && (!IndexedTLSUExecutionMaskContentsDefined(binding.source1) ||
           _Tiles[[binding.source1]].data_type != data_type)) then
        SetFault(Fault_TileLegality, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    if _Tiles[[binding.source0]].valid_rows != valid_rows ||
       _Tiles[[binding.source0]].valid_columns != valid_columns ||
       _Tiles[[binding.source0]].layout != CurrentBundleTileLayout() ||
       !IndexedTLSUMemoryIndexDataTypeLegal(
           _Tiles[[binding.source0]].data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    if !popc && (_Tiles[[binding.source1]].valid_rows != valid_rows ||
       _Tiles[[binding.source1]].valid_columns != valid_columns ||
       _Tiles[[binding.source1]].layout != CurrentBundleTileLayout()) then
        SetFault(Fault_TileLegality, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    let base_address = ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source0);
    if atom then
        var destination: TileIndex = if execution_mask_tile && !cas then
            _BundleTileBindings[[1]].destination else binding.destination;
        if cas then
            let second = _BundleTileBindings[[1]];
            if !second.destination_valid || !second.source0_valid ||
               (second.source1_valid != execution_mask_tile) || !second.last ||
               !IndexedTLSUExecutionMaskContentsDefined(second.source0) ||
               _Tiles[[second.source0]].layout !=
                   CurrentBundleTileLayout() then
                SetFault(Fault_TileLegality, ReadTPC());
                return (FALSE, result_writer_effects);
            end;
            destination = second.destination;
        end;
        if !IndexedTLSUPhysicalShapeLegal(CurrentBundleTileLayout(), data_type,
               valid_rows, valid_columns, columns) then return (FALSE, result_writer_effects); end;
        let (destinations_resolved, resolved_writer_effects) =
            ResolveBundleTileDestinationsWithShapeAndTypeAndWriterEffects(
                TRUE, valid_rows, valid_columns, columns, TRUE, data_type);
        if !destinations_resolved then return (FALSE, result_writer_effects); end;
        var writer_effects = resolved_writer_effects;
        if !ValidateBundleLocalGenerationWritersWithWriterEffects(
               writer_effects) then
            RollBackBundleTileDestinations(); return (FALSE, result_writer_effects);
        end;
        destination = if cas || execution_mask_tile then
            _BundleTileBindings[[1]].destination
            else _BundleTileBindings[[0]].destination;
        let (writer_found, writer_value) =
            BundleLocalGenerationCubeWriterValueForDestination(
                writer_effects, destination, _Tiles[[destination]]);
        if writer_found then
            let target = TileOutputValueTarget {
                destination = destination,
                value = writer_value
            };
            if cas then
                let second = _BundleTileBindings[[1]];
                if !TileOperandsLegal_GM_ATOM_CASToValue(
                       GMAtomic_CAS, target, base_address,
                       binding.source0, binding.source1, second.source0,
                       CurrentBundlePadValue()) then
                    FinishBundleLocalGenerationCubeWriterEffects(
                        writer_effects);
                    RollBackBundleTileDestinations();
                    SetFault(Fault_TileLegality, ReadTPC());
                    return (FALSE, result_writer_effects);
                end;
                let result = GM_ATOM_CASToValue(GMAtomic_CAS, target,
                    base_address, binding.source0, binding.source1,
                    second.source0,
                    CurrentBundlePadValue());
                writer_effects =
                    BundleLocalGenerationCubeWriterEffectWithOutput(
                        writer_effects, destination, result);
            else
                if !TileOperandsLegal_GM_ATOM_VALUEToValue(
                       GMAtomicOperationFromFunction(function), target,
                       base_address, binding.source0, binding.source1,
                       CurrentBundlePadValue()) then
                    FinishBundleLocalGenerationCubeWriterEffects(
                        writer_effects);
                    RollBackBundleTileDestinations();
                    SetFault(Fault_TileLegality, ReadTPC());
                    return (FALSE, result_writer_effects);
                end;
                let result = GM_ATOM_VALUEToValue(
                    GMAtomicOperationFromFunction(function), target,
                    base_address, binding.source0, binding.source1,
                    CurrentBundlePadValue());
                writer_effects =
                    BundleLocalGenerationCubeWriterEffectWithOutput(
                        writer_effects, destination, result);
            end;
        else
            if cas then
            let second = _BundleTileBindings[[1]];
            if !TileOperandsLegal_GM_ATOM_CAS(GMAtomic_CAS, destination, base_address,
                   binding.source0, binding.source1, second.source0,
                   CurrentBundlePadValue()) then
                result_writer_effects = writer_effects;
        FinishBundleLocalGenerationCubeWriterEffects(writer_effects);
                RollBackBundleTileDestinations();
                SetFault(Fault_TileLegality, ReadTPC());
                return (FALSE, result_writer_effects);
            end;
            GM_ATOM_CAS(GMAtomic_CAS, destination, base_address,
                binding.source0, binding.source1, second.source0,
                CurrentBundlePadValue());
        else
            if !TileOperandsLegal_GM_ATOM_VALUE(
                   GMAtomicOperationFromFunction(function), destination,
                   base_address, binding.source0, binding.source1,
                   CurrentBundlePadValue()) then
                result_writer_effects = writer_effects;
        FinishBundleLocalGenerationCubeWriterEffects(writer_effects);
                RollBackBundleTileDestinations();
                SetFault(Fault_TileLegality, ReadTPC());
                return (FALSE, result_writer_effects);
            end;
            GM_ATOM_VALUE(GMAtomicOperationFromFunction(function), destination,
                base_address, binding.source0, binding.source1,
                CurrentBundlePadValue());
            end;
        end;
        result_writer_effects = writer_effects;
        FinishBundleLocalGenerationCubeWriterEffects(writer_effects);
    elsif popc then
        if !TileOperandsLegal_GM_RED_POPC(GMReduction_POPC, base_address,
               binding.source0) then
            SetFault(Fault_TileLegality, ReadTPC());
            return (FALSE, result_writer_effects);
        end;
        GM_RED_POPC(GMReduction_POPC, base_address, binding.source0);
    else
        if !TileOperandsLegal_GM_RED_VALUE(
               GMReductionOperationFromFunction(function), base_address,
               binding.source0, binding.source1, CurrentBundlePadValue()) then
            SetFault(Fault_TileLegality, ReadTPC());
            return (FALSE, result_writer_effects);
        end;
        GM_RED_VALUE(GMReductionOperationFromFunction(function), base_address,
            binding.source0, binding.source1, CurrentBundlePadValue());
    end;
    if _LastFault != Fault_None then
        if atom then RollBackBundleTileDestinations(); end;
        return (FALSE, result_writer_effects);
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return (TRUE, result_writer_effects);
end;
