<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-prefetch.asl -->
# TLSU Prefetch

**Normative ASL source:** `asl/block/model/dispatch/tlsu-prefetch.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-PREFETCH}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-prefetch.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-PREFETCH","surface":"block","classification":["model","dispatch","tlsu-prefetch"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU","PTO-TILE-MODEL-MEMORY-GATHER-SCATTER"]}

readonly func BundleTPREFETCHSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           UInt(_BundleOperation.selector[4:0]) == 3;
end;

readonly func BundleTPREFETCHDimensionsLegal() => boolean
begin
    // Omitted dimensions use the destination-free TLOAD defaults.  An
    // explicitly encoded zero or out-of-range value remains a value and is
    // therefore illegal rather than being reinterpreted as omission.
    for dimension = 0 to PTO_BUNDLE_DIMENSION_COUNT - 1 do
        if _BundleDimensionPresent[[dimension]] &&
           (UInt(_BundleDimensions[[dimension]]) == 0 ||
            UInt(_BundleDimensions[[dimension]]) > 65535) then
            return FALSE;
        end;
    end;
    let valid_columns = BundleDestinationValidColumns(FALSE, 0);
    let valid_rows = BundleDestinationValidRows(FALSE, 0);
    let columns = BundleDestinationPhysicalColumns(FALSE, 0);
    return valid_columns <= columns && IsNonzeroPowerOfTwo(columns) &&
           valid_rows * valid_columns <= PTO_MODEL_TILE_ELEMENTS;
end;

func ExecuteBundleTPREFETCHOperation() => boolean
begin
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    // TPREFETCH has implicit PE participation 1111 and no Local or Shared Tile
    // operand.  Any B.IOT or B.IOS is a malformed complete-bundle schema.
    if BundleTileBindingCount() != 0 || BundleSharedBindingCount() != 0 ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !BundleTPREFETCHDimensionsLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return FALSE; end;

    let valid_columns = BundleDestinationValidColumns(FALSE, 0);
    let valid_rows = BundleDestinationValidRows(FALSE, 0);
    let columns = BundleDestinationPhysicalColumns(FALSE, 0);
    var base_addresses: CorePEWords;
    var row_strides: CorePEWords;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        base_addresses[[agent]] =
            if _BundleScalarBindings[[0]].valid then
                ReadPEAbsoluteGPROperand(agent,
                    _BundleScalarBindings[[0]].source0)
            else Zeros{PTO_XLEN};
        row_strides[[agent]] =
            if _BundleScalarBindings[[0]].valid then
                ReadPEAbsoluteGPROperand(agent,
                    _BundleScalarBindings[[0]].source1)
            else NaturalToWord(columns);
    end;
    TPREFETCHCore(base_addresses, row_strides,
        valid_columns as integer {1..65535},
        valid_rows as integer {1..65535},
        columns as integer {1..65535},
        TileDataTypeFromEncoding(
            CurrentBundleTileOperationDataTypeCode()
                as TileDataTypeEncoding));
    if _LastFault != Fault_None then return FALSE; end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
