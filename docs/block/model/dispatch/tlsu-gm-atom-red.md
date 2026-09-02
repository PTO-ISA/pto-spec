<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-gm-atom-red.asl -->
# TLSU Gm Atom Red

**Normative ASL source:** `asl/block/model/dispatch/tlsu-gm-atom-red.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-GM-ATOM-RED}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-gm-atom-red.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-GM-ATOM-RED","surface":"block","classification":["model","dispatch","tlsu-gm-atom-red"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-CAS","PTO-TILE-MODEL-MEMORY-GM-ATOM-RED","PTO-TILE-MODEL-MEMORY-GM-ATOM-RED-EXECUTION"]}

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

func ExecuteBundleGMAtomRedOperation() => boolean
begin
    // PE_MASK=0000 exits before every schema, descriptor, type, or memory check.
    if SelectedBundleTileMaskIsZero() then return TRUE; end;
    let function = UInt(_BundleOperation.selector[4:0]) as integer {0..31};
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if BundleSharedBindingCount() != 0 ||
       !_BundleScalarBindings[[0]].valid ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !SelectedBundleTileMasksLegal() ||
       !BundleMGATHERDimensionsLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let atom = function <= 18;
    let cas = function == 8;
    let popc = function == 27;
    var expected_binding_count: integer {1..2} = 1;
    if cas then expected_binding_count = 2; end;
    if atom && BundleTileBindingCount() != expected_binding_count then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if !atom && BundleTileBindingCount() != 1 then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    // mgather.cas and the legacy MGATHER.CAS alias use the two-command schema:
    // the first B.IOT carries indices and expected values, while the second
    // carries replacement and the destination.  Other atom forms carry all
    // operands in one destination-bearing B.IOT.
    if !binding.valid || !binding.source0_valid ||
       ((!cas && binding.last == FALSE) || (cas && binding.last)) ||
       (cas && (binding.destination_valid || !binding.source1_valid)) ||
       (!cas && binding.destination_valid != atom) ||
       (!popc && !cas && !binding.source1_valid) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !BundleGMAtomRedDataTypeLegal(function, data_type) ||
       !TileSourceContentsDefined(binding.source0) ||
       (!popc && !TileSourceContentsDefined(binding.source1)) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = if _BundleDimensionPresent[[1]] then
        UInt(_BundleDimensions[[1]]) as integer {1..65535} else 1;
    if _Tiles[[binding.source0]].valid_rows != valid_rows ||
       _Tiles[[binding.source0]].valid_columns != valid_columns then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !popc && (_Tiles[[binding.source1]].valid_rows != valid_rows ||
       _Tiles[[binding.source1]].valid_columns != valid_columns) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let base_address = ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source0);
    if atom then
        var destination: TileIndex = binding.destination;
        if cas then
            let second = _BundleTileBindings[[1]];
            if !second.destination_valid || !second.source0_valid ||
               second.source1_valid || !second.last ||
               !TileSourceContentsDefined(second.source0) then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            destination = second.destination;
        end;
        if !ResolveBundleTileDestinationsWithShapeAndType(TRUE, valid_rows,
               valid_columns, valid_columns, TRUE, data_type) then return FALSE; end;
        if cas then
            destination = _BundleTileBindings[[1]].destination;
        else
            destination = _BundleTileBindings[[0]].destination;
        end;
        if cas then
            let second = _BundleTileBindings[[1]];
            if !TileOperandsLegal_GM_ATOM_CAS(GMAtomic_CAS, destination, base_address,
                   binding.source0, binding.source1, second.source0,
                   CurrentBundlePadValue()) then
                RollBackBundleTileDestinations();
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            GM_ATOM_CAS(GMAtomic_CAS, destination, base_address,
                binding.source0, binding.source1, second.source0,
                CurrentBundlePadValue());
        else
            if !TileOperandsLegal_GM_ATOM_VALUE(
                   GMAtomicOperationFromFunction(function), destination,
                   base_address, binding.source0, binding.source1,
                   CurrentBundlePadValue()) then
                RollBackBundleTileDestinations();
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            GM_ATOM_VALUE(GMAtomicOperationFromFunction(function), destination,
                base_address, binding.source0, binding.source1,
                CurrentBundlePadValue());
        end;
    elsif popc then
        if !TileOperandsLegal_GM_RED_POPC(GMReduction_POPC, base_address,
               binding.source0) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        GM_RED_POPC(GMReduction_POPC, base_address, binding.source0);
    else
        if !TileOperandsLegal_GM_RED_VALUE(
               GMReductionOperationFromFunction(function), base_address,
               binding.source0, binding.source1, CurrentBundlePadValue()) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        GM_RED_VALUE(GMReductionOperationFromFunction(function), base_address,
            binding.source0, binding.source1, CurrentBundlePadValue());
    end;
    if _LastFault != Fault_None then
        if atom then RollBackBundleTileDestinations(); end;
        return FALSE;
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
