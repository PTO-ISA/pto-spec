<!-- GENERATED FROM: asl/block/model/dispatch/tile-schema.asl -->
# Tile Schema

**Normative ASL source:** `asl/block/model/dispatch/tile-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tile-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","surface":"block","classification":["model","dispatch","tile-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA"]}
func BundleTileInstructionOperands(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1})
    => TileInstructionOperands
begin
    var operands = DefaultTileInstructionOperands();
    var destination_count: integer = 0;
    var source_count: integer = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].destination_valid then
                if destination_count == 0 then
                    operands.destination0 =
                        _BundleTileBindings[[binding]].destination;
                elsif destination_count == 1 then
                    operands.destination1 =
                        _BundleTileBindings[[binding]].destination;
                elsif destination_count == 2 then
                    operands.destination2 =
                        _BundleTileBindings[[binding]].destination;
                else
                    SetFault(Fault_TileLegality, ReadTPC());
                    return operands;
                end;
                destination_count = destination_count + 1;
            end;
            if _BundleTileBindings[[binding]].source0_valid then
                case source_count of
                    when 0 => operands.source0 =
                        _BundleTileBindings[[binding]].source0;
                    when 1 => operands.source1 =
                        _BundleTileBindings[[binding]].source0;
                    when 2 => operands.source2 =
                        _BundleTileBindings[[binding]].source0;
                    when 3 => operands.source3 =
                        _BundleTileBindings[[binding]].source0;
                    when 4 => operands.source4 =
                        _BundleTileBindings[[binding]].source0;
                    when 5 => operands.source5 =
                        _BundleTileBindings[[binding]].source0;
                    when 6 => operands.source6 =
                        _BundleTileBindings[[binding]].source0;
                    when 7 => operands.source7 =
                        _BundleTileBindings[[binding]].source0;
                    otherwise => unreachable;
                end;
                source_count = source_count + 1;
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                case source_count of
                    when 0 => operands.source0 =
                        _BundleTileBindings[[binding]].source1;
                    when 1 => operands.source1 =
                        _BundleTileBindings[[binding]].source1;
                    when 2 => operands.source2 =
                        _BundleTileBindings[[binding]].source1;
                    when 3 => operands.source3 =
                        _BundleTileBindings[[binding]].source1;
                    when 4 => operands.source4 =
                        _BundleTileBindings[[binding]].source1;
                    when 5 => operands.source5 =
                        _BundleTileBindings[[binding]].source1;
                    when 6 => operands.source6 =
                        _BundleTileBindings[[binding]].source1;
                    when 7 => operands.source7 =
                        _BundleTileBindings[[binding]].source1;
                    otherwise => unreachable;
                end;
                source_count = source_count + 1;
            end;
        end;
    end;
    // B.IOR inputs are resolved in one architectural order so that optional
    // fields pack densely into RegSrc0..RegSrc2.  TLOAD/TSTORE retain their
    // omission-only dense-row stride default.
    if TileOperandPresent(operation, TileOperand_address) then
        if _BundleScalarBindings[[0]].valid then
            operands.address = ReadScalarRegisterOperand(
                BundleOperationGPRInputSelector(
                    BundleOperationGPRInputSlot(
                        operation, TileOperand_address) as integer {0..2}));
        end;
    end;
    if TileOperandPresent(operation, TileOperand_scalar0) then
        if _BundleScalarBindings[[0]].valid then
            operands.scalar0 = ReadScalarRegisterOperand(
                BundleOperationGPRInputSelector(
                    BundleOperationGPRInputSlot(
                        operation, TileOperand_scalar0) as integer {0..2}));
        elsif TileOperandPresent(operation, TileOperand_address) then
            // TLOAD/TSTORE retain dense-row behavior when B.IOR is omitted:
            // the resolved LB2/Col dimension is the row stride.
            operands.scalar0 = _BundleDimensions[[2]];
        end;
    end;
    if TileOperandPresent(operation, TileOperand_scalar1) &&
       _BundleScalarBindings[[0]].valid then
        operands.scalar1 = ReadScalarRegisterOperand(
            BundleOperationGPRInputSelector(
                BundleOperationGPRInputSlot(
                    operation, TileOperand_scalar1) as integer {0..2}));
    end;
    if TileOperandPresent(operation, TileOperand_diagonal) then
        if _BundleScalarBindings[[0]].valid then
            let raw = ReadScalarRegisterOperand(
                BundleOperationGPRInputSelector(
                    BundleOperationGPRInputSlot(
                        operation, TileOperand_diagonal) as integer {0..2}));
            // Raw conversion is performed only after the complete-bundle
            // preflight has proved the signed value lies in the ASL domain.
            operands.diagonal = SInt(raw) as integer {-65535..65535};
        end;
    end;
    if TileOperandPresent(operation, TileOperand_flag0) then
        if _BundleScalarBindings[[0]].valid then
            let raw = ReadScalarRegisterOperand(
                BundleOperationGPRInputSelector(
                    BundleOperationGPRInputSlot(
                        operation, TileOperand_flag0) as integer {0..2}));
            // Raw booleans accept exactly zero and one; legality is checked
            // before this constrained assignment during bundle commit.
            operands.flag0 = UInt(raw) == 1;
        end;
    end;
    // Matrix post-processing scalar descriptors consume the next dense B.IOR
    // slots after any mathematical scalar controls.  Matrix operations do not
    // currently have scalar0/scalar1 controls, so these are RegSrc0/RegSrc1.
    if _BundleOperation.valid &&
       _BundleOperation.operation_class == BundleOperation_TileMatrix &&
       _BundleFixedPointAttributes.valid &&
       _BundleScalarBindings[[0]].valid then
        var post_slot: integer {0..2} = 0;
        if BundleFPATRModeUsesScalarParameter(
               _BundleFixedPointAttributes.pre_quant_mode) then
            operands.post_quant_param = ReadScalarRegisterOperand(
                BundleOperationGPRInputSelector(post_slot));
            post_slot = (post_slot + 1) as integer {0..2};
        end;
        if BundleFPATRReluModeUsesScalarParameter(
               _BundleFixedPointAttributes.relu_mode) then
            operands.post_lrelu_param = ReadScalarRegisterOperand(
                BundleOperationGPRInputSelector(post_slot));
        end;
    end;
    let dimension0 = UInt(_BundleDimensions[[0]]);
    let dimension1 = UInt(_BundleDimensions[[1]]);
    if dimension0 <= 65535 then
        operands.natural0 = dimension0 as integer {0..65535};
        if dimension0 != 0 then
            operands.positive0 = dimension0 as integer {1..65535};
        end;
    end;
    if dimension1 <= 65535 then
        operands.natural1 = dimension1 as integer {0..65535};
        if dimension1 != 0 then
            operands.positive1 = dimension1 as integer {1..65535};
        end;
    end;
    if dimension0 <= 262144 then
        operands.byte_count = dimension0 as integer {0..262144};
    end;
    if dimension0 >= 1 && dimension0 <= 64 then
        operands.sort_width = dimension0 as integer {1..64};
    end;
    operands.selected_byte = UInt(_BundleDataAttributes.pad_value)
        as integer {0..3};
    case UInt(_BundleDataAttributes.conversion_mode) of
        when 0 => operands.comparison = TileComparison_EQ;
        when 1 => operands.comparison = TileComparison_NE;
        when 2 => operands.comparison = TileComparison_LT;
        when 3 => operands.comparison = TileComparison_GT;
        when 4 => operands.comparison = TileComparison_LE;
        when 5 => operands.comparison = TileComparison_GE;
        otherwise => operands.comparison = TileComparison_EQ;
    end;
    // Generic boolean operands are operation controls, not aliases of the
    // numeric saturation bit. Numeric consumers receive the separate typed
    // control below; other bundle operations retain their operation default.
    operands.numeric_control = DecodeBundleRoundingSelection(
        _BundleDataAttributes.rounding_mode);
    operands.numeric_control.saturating = _BundleDataAttributes.saturating;
    return operands;
end;

func SelectedBundleTileDataAttributesLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let matrix = _BundleOperation.valid &&
        _BundleOperation.operation_class == BundleOperation_TileMatrix;
    let effective_datr_data_type =
        if _BundleDataAttributes.data_type_present &&
           BundleDataTypeConcrete(_BundleDataAttributes.data_type) then
            _BundleDataAttributes.data_type
        else Zeros{5};
    let datr_legal = if matrix then
        _BundleFixedPointAttributes.valid &&
        BundleFPATRDATRFieldsLegal(
            _BundleFixedPointAttributes.pre_quant_mode,
            _BundleDataAttributes.rounding_mode,
            _BundleDataAttributes.saturating)
    else
        TileOperationDATRFieldsLegal(
            operation, _BundleDataAttributes.conversion_mode,
            _BundleDataAttributes.pad_value, _BundleDataAttributes.saturating,
            _BundleDataAttributes.canonicalize, effective_datr_data_type,
            _BundleDataAttributes.rounding_mode,
            _BundleDataAttributes.data_layout);
    if !datr_legal then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if _BundleDataAttributes.pad_value != Zeros{2} &&
       TileOperationDATRPadUnion(operation) ==
           TileDATRPadUnion_MustZero then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    return TRUE;
end;

readonly func SelectedBundleTileMasksLegal() => boolean
begin
    var first_mask = Zeros{4};
    var first_mask_seen = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            let mask = _BundleTileBindings[[binding]].pe_mask;
            if first_mask_seen && mask != first_mask then return FALSE; end;
            first_mask = mask;
            first_mask_seen = TRUE;
            if _BundleOperation.operation_class == BundleOperation_TileMemory &&
               _BundleOperation.selector_valid &&
               _BundleOperation.selector[4:0] == '01101' &&
               mask != '1111' then return FALSE; end;
        end;
    end;
    return TRUE;
end;

readonly func SelectedBundleTileMaskIsZero() => boolean
begin
    var seen = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            seen = TRUE;
            if _BundleTileBindings[[binding]].pe_mask != Zeros{4} then
                return FALSE;
            end;
        end;
    end;
    return seen;
end;

readonly func BundleTileBindingCount() => integer {0..16}
begin
    var count: integer {0..16} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            count = (count + 1) as integer {0..16};
        end;
    end;
    return count;
end;

readonly func BundleLocalTileSourceCount() => integer {0..32}
begin
    var count: integer {0..32} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                count = (count + 1) as integer {0..32};
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                count = (count + 1) as integer {0..32};
            end;
        end;
    end;
    return count;
end;

readonly func BundleLocalTileDestinationCount() => integer {0..16}
begin
    var count: integer {0..16} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            count = (count + 1) as integer {0..16};
        end;
    end;
    return count;
end;

readonly func BundleTileBindingStreamTerminated() => boolean
begin
    var last_count: integer {0..16} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].last then
            last_count = (last_count + 1) as integer {0..16};
        end;
    end;
    return BundleTileBindingCount() > 0 && last_count == 1;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
