<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-layout-conversion.asl -->
# TLSU Layout Conversion

**Normative ASL source:** `asl/block/model/dispatch/tlsu-layout-conversion.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-LAYOUT-CONVERSION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-layout-conversion-purpose role=purpose-scope -->
## Purpose and scope

This unit is the bundle-level handler for `TLOAD` and `TSTORE` bundles that convert between an ordinary memory layout and a Local CUBE layout. It is called CUBE transport in the ASL.

`BundleCubeTransportSelected` recognizes the bundle: a valid `TileMemory` descriptor with a `B.DATR` command present whose `Layout` code is in `21..26`. `ExecuteBundleCubeTransportOperation` validates the bundle, then either loads into a new CUBE Tile (function `0`) or stores an existing CUBE Tile (function `1`).

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-layout-conversion-concepts role=concepts-state -->
## Concepts and visible state

The `B.DATR` layout code chooses both the direction and the CUBE layout.

| Code | Name | Direction | Local layout |
| --- | --- | --- | --- |
| `21` | `ND2M32` | load | `CUBE_M32` |
| `22` | `ND2M16` | load | `CUBE_M16` |
| `23` | `ND2N8` | load | `CUBE_N8` |
| `24` | `M322ND` | store | `CUBE_M32` |
| `25` | `M162ND` | store | `CUBE_M16` |
| `26` | `N82ND` | store | `CUBE_N8` |

`B.DIM` gives valid columns in `LB0` and valid rows in `LB1`, each in `1..65535`. `LB2` must be `1`, because the CUBE layout derives its own physical geometry. An optional `B.IOR` gives the base address in `source0` and the byte row stride in `source1`. Without it, the base is zero and the stride is the dense row size of the valid columns.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-layout-conversion-rules role=rules-interactions -->
## Rules and interactions

The handler first returns success with no effect when `SelectedBundleTileMaskIsZero` holds. The ASL comment places this before every schema, GPR, descriptor, allocation, and memory check.

An unknown TLSU operation code raises `Fault_IllegalInstruction`. The following raise `Fault_TileLegality`: illegal dimensions; a `B.DATR` data type other than `DTYPE_NONE`; nonzero comparison or rounding mode; saturation or canonicalization set; a load layout code with function `1` or a store code with function `0`; a function other than `0` or `1`; a present `B.FPATR`; and a wrong binding schema.

For a load, the single `B.IOT` carries a destination and `last`, and a source only as a predicate-Tile execution mask. For a store, it carries the CUBE source Tile and `last`, with no destination.

The effective data type must pass `TileCubeDataTypeSupported` and must not be HiF4X2. U64 is accepted only for a load into `CUBE_N8`, as the ASL comment states.

A load resolves its destination through `ResolveBundleCubeTransportDestination`. A reused generation destination with a mismatched descriptor raises `Fault_TileLegality`. An illegal CUBE shape, a capacity overflow on a selected PE, or no free Tile slot in the destination hand raises `Fault_TileAllocation`. The handler then validates Local generation writers and calls `TLOAD`. A store checks that the source is a legal defined CUBE Tile with the selected type, layout, and valid shape, allocated on every selected PE, and calls `TSTORE`.

Design point: the load path calls `RollBackBundleTileDestinations` after a memory fault. The ASL comment states that the fault keeps the beats completed before it but must not publish the speculative Local destination.

Design point: this handler checks every `B.DATR` field except the pad value. The generic data-attribute check in the Tile schema states that only these Local CUBE conversion forms may carry a nonzero pad value for `TLOAD` and `TSTORE`.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-layout-conversion-boundaries role=boundaries -->
## Architectural boundaries

`ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` tests this selector after the TIMG2COL, weight-load, and matrix selectors and before `GMOV` and the indexed TLSU selectors. Because it depends only on the layout code, a `TileMemory` bundle with another function and a conversion layout also arrives here and is rejected.

The element placement inside a CUBE layout belongs to the Tile load and store owner.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-layout-conversion-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Suppose a `TLOAD` bundle has `B.DATR` layout `ND2M16`, operation type FP16, `LB0` equal to 64, and `LB1` equal to 16, with no `B.IOR`. The base is zero and the row stride is 64 times 2, which is 128 bytes. The handler allocates a `CUBE_M16` destination in the first free slot of the destination hand and loads 16 rows.

If the same bundle also set `LB2` to 64, it raises `Fault_TileLegality` before allocation.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-layout-conversion-related role=related-owners-navigation -->
## Related owners

- [Tile schema dispatch](tile-schema.md) holds the pad-value rule for other `TLOAD` and `TSTORE` bundles.
- [Tile execution dispatch](tile-execution.md) orders the specialized selectors.
- [Load and store memory](../../../tile/model/memory/load-store.md) defines `TLOAD` and `TSTORE`.
- [BSTART.TLOAD](../../execution/BSTART.TLOAD.md) and [BSTART.TSTORE](../../execution/BSTART.TSTORE.md) are the instruction pages.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-layout-conversion.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-LAYOUT-CONVERSION","surface":"block","classification":["model","dispatch","tlsu-layout-conversion"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","PTO-BLOCK-MODEL-FAULTS-ROLLBACK","PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE","PTO-TILE-MODEL-MEMORY-LOAD-STORE"]}

readonly func BundleCubeTransportSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleDataAttributesPresent &&
           TileDataLayoutIsCubeConversion(
               _BundleDataAttributes.data_layout);
end;

pure func BundleCubeTransportDataTypeSupported(
    data_type: TileDataType, layout: TileLayout, function: integer {0..31})
    => boolean
begin
    // HiF4X2 is accepted only by the Matrix-MX input-role contract.  U64 is
    // the single descriptor-level exception, and only ND2N8 TLOAD may create
    // that Local CUBE_N8 representation.
    if data_type == TileDataType_U64 then
        return function == 0 && layout == TileLayout_CUBE_N8;
    end;
    return TileCubeDataTypeSupported(data_type) &&
           data_type != TileDataType_HiF4X2;
end;

readonly func BundleCubeTransportDimensionsLegal() => boolean
begin
    let valid_columns = UInt(_BundleDimensions[[0]]);
    let valid_rows = UInt(_BundleDimensions[[1]]);
    return 1 <= valid_columns && valid_columns <= 65535 &&
           1 <= valid_rows && valid_rows <= 65535 &&
           UInt(_BundleDimensions[[2]]) == 1;
end;

readonly func BundleCubeTransportDataAttributesLegal() => boolean
begin
    if !_BundleDataAttributesPresent ||
       _BundleDataAttributes.data_type != DTYPE_NONE ||
       !TileDataLayoutIsCubeConversion(
           _BundleDataAttributes.data_layout) ||
       _BundleDataAttributes.comparison_mode != Zeros{3} ||
       _BundleDataAttributes.rounding_mode != Zeros{3} ||
       _BundleDataAttributes.saturating ||
       _BundleDataAttributes.canonicalize then
        return FALSE;
    end;
    if !_BundleOperation.valid ||
       _BundleOperation.operation_class != BundleOperation_TileMemory ||
       !_BundleOperation.selector_valid then
        return FALSE;
    end;
    let function = UInt(_BundleOperation.selector[4:0]);
    if function == 0 then
        return TileDataLayoutConversionIsLoad(
            _BundleDataAttributes.data_layout);
    elsif function == 1 then
        return TileDataLayoutConversionIsStore(
            _BundleDataAttributes.data_layout);
    end;
    return FALSE;
end;

readonly func BundleCubeTransportBindingsLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if BundleSharedBindingCount() != 0 ||
       BundleTileBindingCount() != 1 ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationScalarBindingSchemaLegal(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !SelectedBundleTileMasksLegal() then
        return FALSE;
    end;
    let function = UInt(_BundleOperation.selector[4:0]);
    let binding = _BundleTileBindings[[0]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if !binding.valid || !binding.last then return FALSE; end;
    if function == 0 then
        return binding.destination_valid &&
               !binding.destination_allocated_by_bundle &&
               BundleTileDestinationSizeLegal(0) &&
               (binding.source0_valid == execution_mask_tile) &&
               !binding.source1_valid &&
               (!execution_mask_tile ||
                _BundleExecutionMask.predicate_source_ordinal == 0);
    elsif function == 1 then
        return !binding.destination_valid &&
               binding.source0_valid &&
               (binding.source1_valid == execution_mask_tile) &&
               (!execution_mask_tile ||
                _BundleExecutionMask.predicate_source_ordinal == 1);
    end;
    return FALSE;
end;

func ResolveBundleCubeTransportDestination(
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    data_type: TileDataType,
    layout: TileLayout) => boolean
begin
    let binding = _BundleTileBindings[[0]];
    let capacity_bytes = BundleTileDestinationSizeBytes(0);
    if binding.destination_reused_by_generation then
        let destination = _Tiles[[binding.destination]];
        if !TileCubeDescriptorLegal(destination) ||
           destination.capacity_bytes != capacity_bytes ||
           destination.valid_rows != valid_rows ||
           destination.valid_columns != valid_columns ||
           destination.data_type != data_type ||
           destination.layout != layout ||
           (_TileAllocationMasks[[binding.destination]] AND binding.pe_mask) !=
               binding.pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        return TRUE;
    end;
    if !TileCubeDescriptorShapeLegal(capacity_bytes, valid_rows,
           valid_columns, data_type, layout) ||
       !LocalTileAllocationFits(binding.pe_mask, capacity_bytes) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    let hand = UInt(binding.destination_hand);
    var destination: TileIndex = 0;
    var found = FALSE;
    for offset = 0 to 15 do
        let raw_index: integer = hand * 16 + offset;
        if !found && !_Tiles[[raw_index]].allocated then
            destination = raw_index as TileIndex;
            found = TRUE;
        end;
    end;
    if !found || !ConfigureCubeTileForMask(
           destination, capacity_bytes, valid_rows, valid_columns,
           data_type, layout, binding.pe_mask) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    _BundleTileBindings[[0]].destination = destination;
    _BundleTileBindings[[0]].destination_allocated_by_bundle = TRUE;
    return TRUE;
end;

func ExecuteBundleCubeTransportOperation() => boolean
begin
    // A zero Local mask is resolved before every schema, GPR, descriptor,
    // allocation, and memory check.
    if SelectedBundleTileMaskIsZero() then return TRUE; end;
    let decoded = DecodeTileOperation(
        TileDecode_TLSU, BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if !BundleCubeTransportDimensionsLegal() ||
       !BundleCubeTransportDataAttributesLegal() ||
       !BundleExecutionMaskDataAttributesLegal(operation) ||
       !BundleCubeTransportBindingsLegal(operation) ||
       _BundleFixedPointAttributes.valid then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let (type_valid, data_type) = ResolveBundleEffectiveDataType();
    let layout = TileDataLayoutCubeLayout(
        _BundleDataAttributes.data_layout);
    let function = UInt(_BundleOperation.selector[4:0]);
    if !type_valid || !BundleCubeTransportDataTypeSupported(
           data_type, layout, function) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]])
        as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]])
        as integer {1..65535};
    let base_address = if _BundleScalarBindings[[0]].valid then
        ReadScalarRegisterOperand(_BundleScalarBindings[[0]].source0)
        else Zeros{PTO_XLEN};
    let row_stride_bytes = if _BundleScalarBindings[[0]].valid then
        ReadScalarRegisterOperand(_BundleScalarBindings[[0]].source1)
        else TileDenseRowStrideBytes(valid_columns, data_type);
    if function == 0 then
        if !ResolveBundleCubeTransportDestination(
               valid_rows, valid_columns, data_type, layout) then
            return FALSE;
        end;
        if !ValidateBundleLocalGenerationWriters() then
            RollBackBundleTileDestinations(); return FALSE;
        end;
        let destination = _BundleTileBindings[[0]].destination;
        TLOAD(destination, base_address, row_stride_bytes);
        if _LastFault != Fault_None then
            // A memory fault retains the beats completed before it but must
            // not publish the speculative Local destination.  Release it and
            // re-synchronize the saved trap context exactly like the generic
            // destination path does.
            RollBackBundleTileDestinations();
            return FALSE;
        end;
    else
        let source = _BundleTileBindings[[0]].source0;
        let tile = _Tiles[[source]];
        if !TileCubeDescriptorLegal(tile) ||
           !TileElementwiseSourceContentsDefined(source) ||
           tile.data_type != data_type || tile.layout != layout ||
           tile.valid_rows != valid_rows ||
           tile.valid_columns != valid_columns ||
           (_TileAllocationMasks[[source]] AND
               _BundleTileBindings[[0]].pe_mask) !=
               _BundleTileBindings[[0]].pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        TSTORE(base_address, row_stride_bytes, source);
        if _LastFault != Fault_None then
            RollBackBundleTileDestinations();
            return FALSE;
        end;
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
