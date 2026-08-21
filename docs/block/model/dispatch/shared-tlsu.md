<!-- GENERATED FROM: asl/block/model/dispatch/shared-tlsu.asl -->
# Shared TLSU

**Normative ASL source:** `asl/block/model/dispatch/shared-tlsu.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/shared-tlsu.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU","surface":"block","classification":["model","dispatch","shared-tlsu"],"depends_on":["PTO-BLOCK-MODEL-FAULTS-ROLLBACK","PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS"]}
readonly func BundleSharedTLSUSelected() => boolean
begin
    if !_BundleOperation.valid ||
       _BundleOperation.operation_class != BundleOperation_TileMemory ||
       !_BundleOperation.selector_valid then return FALSE; end;
    let function = UInt(_BundleOperation.selector[4:0]);
    return BundleSharedBindingCount() > 0 ||
           (9 <= function && function <= 12) || function == 14;
end;

readonly func BundleSharedStoreValidColumns(shared_id: bits(8))
    => integer {0..65535}
begin
    if _BundleDimensionPresent[[0]] then
        if UInt(_BundleDimensions[[0]]) <= 65535 then
            return UInt(_BundleDimensions[[0]]) as integer {0..65535};
        end;
        return 0;
    end;
    let shared = SharedTileRecord(shared_id);
    if shared.descriptor_valid then return shared.tile.valid_columns; end;
    return 1;
end;

readonly func BundleSharedStoreValidRows(shared_id: bits(8))
    => integer {0..65535}
begin
    if _BundleDimensionPresent[[1]] then
        if UInt(_BundleDimensions[[1]]) <= 65535 then
            return UInt(_BundleDimensions[[1]]) as integer {0..65535};
        end;
        return 0;
    end;
    let shared = SharedTileRecord(shared_id);
    if shared.descriptor_valid then return shared.tile.valid_rows; end;
    return 1;
end;

readonly func BundleSharedStoreColumns(shared_id: bits(8),
                                        valid_columns: integer {0..65535})
    => integer {0..65535}
begin
    if _BundleDimensionPresent[[2]] then
        if UInt(_BundleDimensions[[2]]) <= 65535 then
            return UInt(_BundleDimensions[[2]]) as integer {0..65535};
        end;
        return 0;
    end;
    let shared = SharedTileRecord(shared_id);
    if shared.descriptor_valid then return shared.tile.columns; end;
    return valid_columns;
end;

readonly func BundleSharedTMOVLocalSchemaLegal() => boolean
begin
    if BundleSharedBindingCount() != 1 ||
       BundleTileBindingCount() != 1 then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let shared_size = BundleSharedBindingSize(0);
    let shared_mask = BundleSharedBindingMask(0);
    if !binding.valid || binding.destination_valid ||
       !binding.source0_valid || binding.source1_valid || !binding.last ||
       binding.destination_size != 0 ||
       !TileSizeCodeIsLegal(shared_size) ||
       binding.pe_mask != shared_mask then return FALSE; end;
    if shared_mask == Zeros{4} then return TRUE; end;
    if !TileSourceContentsDefined(binding.source0) ||
       _Tiles[[binding.source0]].capacity_bytes !=
           TileSizeCodeBytes(shared_size as integer {1..12}) then
        return FALSE;
    end;
    var candidate = _Tiles[[binding.source0]];
    candidate.location = TileLocation_Any;
    return SharedTileUpdateCompatible(
        BundleSharedBindingId(0), candidate, shared_mask);
end;

readonly func BundleSharedTMOVDestinationSchemaLegal(
    shared_id: bits(8), function: integer {0..31}) => boolean
begin
    if BundleSharedBindingCount() != 1 ||
       BundleTileBindingCount() != 1 then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let shared_mask = BundleSharedBindingMask(0);
    if !binding.valid || !binding.destination_valid ||
       binding.source0_valid || binding.source1_valid || !binding.last ||
       !LocalTileSizeCodeIsLegal(binding.destination_size) ||
       BundleSharedBindingIsDestination(0) ||
       binding.pe_mask != shared_mask then return FALSE; end;
    if shared_mask == Zeros{4} then return TRUE; end;
    let capacity_bytes = TileSizeCodeBytes(
        binding.destination_size as integer {1..10});
    let valid_rows = BundleDestinationValidRows(FALSE, 0);
    let valid_columns = BundleDestinationValidColumns(FALSE, 0);
    let columns = BundleDestinationPhysicalColumns(FALSE, 0);
    if valid_rows < 1 || valid_columns < 1 || columns < 1 ||
       valid_columns > columns then return FALSE; end;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let layout = CurrentBundleTileLayout();
    if !SharedTileReadSchemaLegalAtCapacity(shared_id, valid_rows,
           valid_columns, columns, data_type, layout, capacity_bytes) then
        return FALSE;
    end;
    if function == 11 then
        let shared = SharedTileRecord(shared_id);
        return shared_mask == '1111' &&
               shared.allocation_mask == '1111' &&
               SharedTilePublished(shared_id);
    end;
    return function == 12;
end;

func ExecuteBundleSharedTLSUOperation() => boolean
begin
    let function = UInt(_BundleOperation.selector[4:0]);
    if BundleSharedBindingCount() != 1 then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let shared_id = BundleSharedBindingId(0);
    let shared_size = BundleSharedBindingSize(0);
    let shared_mask = BundleSharedBindingMask(0);
    if shared_mask == Zeros{4} then return TRUE; end;
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let transfer_data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if (function == 0 || function == 1 || function == 14) &&
       !TileRegularTLSUDataTypeSupported(transfer_data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !BundleOperationScalarBindingSchemaLegal(operation) then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then
        return FALSE;
    end;
    if function == 0 then
        if !BundleSharedBindingIsDestination(0) ||
           !TileSizeCodeIsLegal(shared_size) ||
           BundleTileBindingCount() != 0 then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        let valid_columns = UInt(_BundleDimensions[[0]]);
        let valid_rows = UInt(_BundleDimensions[[1]]);
        let columns = UInt(_BundleDimensions[[2]]);
        if valid_columns < 1 || valid_columns > 65535 ||
           valid_rows < 1 || valid_rows > 65535 ||
           columns < 1 || columns > 65535 || valid_columns > columns then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        var load_base_addresses: CorePEWords;
        var load_row_stride_bytes: CorePEWords;
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let agent = pe as MemoryAgentId;
            load_base_addresses[[agent]] =
                if _BundleScalarBindings[[0]].valid then
                    ReadPEAbsoluteGPROperand(agent,
                        _BundleScalarBindings[[0]].source0)
                else Zeros{PTO_XLEN};
            load_row_stride_bytes[[agent]] =
                if _BundleScalarBindings[[0]].valid then
                    ReadPEAbsoluteGPROperand(agent,
                        _BundleScalarBindings[[0]].source1)
                else TileDenseRowStrideBytes(
                    columns as integer {0..65535}, transfer_data_type);
        end;
        TLOADShared(shared_id, load_base_addresses, load_row_stride_bytes,
            shared_size as integer {1..12}, valid_rows as integer {1..65535},
            columns as integer {1..65535},
            valid_rows as integer {1..65535},
            valid_columns as integer {1..65535},
            transfer_data_type,
            CurrentBundleTileLayout(), shared_mask);
    elsif function == 1 || function == 14 then
        if !SharedStorePEMaskLegal(function, shared_mask) ||
           BundleSharedBindingIsDestination(0) ||
           BundleTileBindingCount() != 0 then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        let store_valid_columns = BundleSharedStoreValidColumns(shared_id);
        let store_valid_rows = BundleSharedStoreValidRows(shared_id);
        let store_columns = BundleSharedStoreColumns(
            shared_id, store_valid_columns);
        let store_data_type = transfer_data_type;
        let store_layout = CurrentBundleTileLayout();
        if store_valid_columns < 1 || store_valid_rows < 1 ||
           store_columns < 1 || store_valid_columns > store_columns ||
           !SharedTileReadSchemaLegal(shared_id, store_valid_rows,
               store_valid_columns, store_columns, store_data_type,
               store_layout) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        let store_tile = MaterializeSharedTileForReadSchema(
            shared_id, store_valid_rows, store_valid_columns, store_columns,
            store_data_type, store_layout);
        var store_base_addresses: CorePEWords;
        var store_row_stride_bytes: CorePEWords;
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let agent = pe as MemoryAgentId;
            store_base_addresses[[agent]] =
                if _BundleScalarBindings[[0]].valid then
                    ReadPEAbsoluteGPROperand(agent,
                        _BundleScalarBindings[[0]].source0)
                else Zeros{PTO_XLEN};
            store_row_stride_bytes[[agent]] =
                if _BundleScalarBindings[[0]].valid then
                    ReadPEAbsoluteGPROperand(agent,
                        _BundleScalarBindings[[0]].source1)
                else TileDenseRowStrideBytes(
                    store_columns as integer {0..65535}, store_data_type);
        end;
        TSTOREShared(store_base_addresses, store_row_stride_bytes, shared_id,
            store_tile, shared_mask);
    elsif function == 9 || function == 10 then
        if !BundleSharedTMOVLocalSchemaLegal() then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        let binding = _BundleTileBindings[[0]];
        TMOVLocalToShared(shared_id, binding.source0,
            shared_size as integer {1..12}, shared_mask, function == 10);
    elsif function == 11 || function == 12 then
        if !BundleSharedTMOVDestinationSchemaLegal(shared_id, function) ||
           !SelectedBundleTileMasksLegal() then
            if _LastFault == Fault_None then
                SetFault(Fault_TileLegality, ReadTPC());
            end;
            return FALSE;
        end;
        let binding = _BundleTileBindings[[0]];
        let capacity_bytes = TileSizeCodeBytes(
            binding.destination_size as integer {1..10});
        let valid_rows = BundleDestinationValidRows(FALSE, 0);
        let valid_columns = BundleDestinationValidColumns(FALSE, 0);
        let columns = BundleDestinationPhysicalColumns(FALSE, 0);
        let data_type = TileDataTypeFromEncoding(
            CurrentBundleTileOperationDataTypeCode()
                as TileDataTypeEncoding);
        let shared_tile = MaterializeSharedTileForReadSchemaAtCapacity(
            shared_id, valid_rows, valid_columns, columns, data_type,
            CurrentBundleTileLayout(), capacity_bytes);
        if !ResolveBundleTileDestinations() then return FALSE; end;
        let destination = _BundleTileBindings[[0]].destination;
        if _Tiles[[destination]].rows != shared_tile.rows ||
           _Tiles[[destination]].columns != shared_tile.columns ||
           _Tiles[[destination]].valid_rows != shared_tile.valid_rows ||
           _Tiles[[destination]].valid_columns != shared_tile.valid_columns ||
           _Tiles[[destination]].data_type != shared_tile.data_type ||
           _Tiles[[destination]].layout != shared_tile.layout then
            RollBackBundleTileDestinations();
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        TMOVSharedToLocal(destination, shared_id, shared_tile, shared_mask);
    else
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if _LastFault != Fault_None then
        RollBackBundleTileDestinations();
        return FALSE;
    end;
    ConsumeBundleSharedBindings(1);
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
