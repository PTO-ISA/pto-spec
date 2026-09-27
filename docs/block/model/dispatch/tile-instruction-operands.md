<!-- GENERATED FROM: asl/block/model/dispatch/tile-instruction-operands.asl -->
# Tile Instruction Operands

**Normative ASL source:** `asl/block/model/dispatch/tile-instruction-operands.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TILE-INSTRUCTION-OPERANDS}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tile-instruction-operands.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TILE-INSTRUCTION-OPERANDS","surface":"block","classification":["model","dispatch","tile-instruction-operands"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMMAND-DATA-ATTRIBUTES","PTO-BLOCK-MODEL-DISPATCH-EXECUTION-MASK-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA","PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR","PTO-TILE-MODEL-EXECUTION-UNARY"]}
func BundleTileInstructionOperands(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1})
    => TileInstructionOperands
begin
    var operands = DefaultTileInstructionOperands();
    var destination_count: integer = 0;
    var source_count: integer = 0;
    var tile_source_ordinal: integer {0..31} = 0;
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
                if !_BundleExecutionMask.valid ||
                   _BundleExecutionMask.carrier != BundleExecutionMask_PredicateTile ||
                   tile_source_ordinal !=
                       _BundleExecutionMask.predicate_source_ordinal then
                    case source_count of
                        when 0 => operands.source0 = BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                        when 1 => operands.source1 = BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                        when 2 => operands.source2 = BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                        when 3 => operands.source3 = BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                        when 4 => operands.source4 = BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                        when 5 => operands.source5 = BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                        when 6 => operands.source6 = BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                        when 7 => operands.source7 = BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                        when 8 => operands.source8 = BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                        otherwise => unreachable;
                    end;
                    source_count = source_count + 1;
                end;
                tile_source_ordinal = (tile_source_ordinal + 1) as integer {0..31};
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                if !_BundleExecutionMask.valid ||
                   _BundleExecutionMask.carrier != BundleExecutionMask_PredicateTile ||
                   tile_source_ordinal !=
                       _BundleExecutionMask.predicate_source_ordinal then
                    case source_count of
                        when 0 => operands.source0 = BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                        when 1 => operands.source1 = BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                        when 2 => operands.source2 = BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                        when 3 => operands.source3 = BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                        when 4 => operands.source4 = BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                        when 5 => operands.source5 = BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                        when 6 => operands.source6 = BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                        when 7 => operands.source7 = BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                        when 8 => operands.source8 = BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                        otherwise => unreachable;
                    end;
                    source_count = source_count + 1;
                end;
                tile_source_ordinal = (tile_source_ordinal + 1) as integer {0..31};
            end;
        end;
    end;
    if TileOperationOfIndex(operation) == TileOperation_TGPR2T then
        operands.source0 = _BundleScalarBindings[[0]].source0 as TileIndex;
        operands.source1 = _BundleScalarBindings[[0]].source1 as TileIndex;
        operands.source2 = _BundleScalarBindings[[0]].source2 as TileIndex;
        operands.source3 = _BundleScalarBindings[[1]].source0 as TileIndex;
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
        elsif TileOperationOfIndex(operation) == TileOperation_TLOAD ||
              TileOperationOfIndex(operation) == TileOperation_TSTORE then
            // Regular TLSU omission derives a byte pitch from the resolved
            // physical column count and transfer data type. TPREFETCH retains
            // its separately owned logical-element stride contract.
            let tstore = TileOperationOfIndex(operation) ==
                TileOperation_TSTORE;
            let columns = BundleDestinationPhysicalColumns(
                tstore, operands.source0);
            operands.scalar0 = TileDenseRowStrideBytes(
                columns,
                TileDataTypeFromEncoding(
                    CurrentBundleTileOperationDataTypeCode()
                        as TileDataTypeEncoding));
        elsif TileOperandPresent(operation, TileOperand_address) then
            operands.scalar0 = _BundleDimensions[[2]];
        end;
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
    if TileOperandPresent(operation, TileOperand_flag0) && !(TileOperationOfIndex(operation) == TileOperation_TCI && (CurrentBundleTileLayout() == TileLayout_CUBE_M16 || CurrentBundleTileLayout() == TileLayout_CUBE_M32)) then
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
    // currently have no mathematical scalar controls, so these are
    // RegSrc0/RegSrc1.
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
    let dimension2 = UInt(_BundleDimensions[[2]]);
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
    if dimension2 >= 1 && dimension2 <= 65535 then
        operands.positive2 = dimension2 as integer {1..65535};
    end;
    if dimension0 <= 262144 then
        operands.byte_count = dimension0 as integer {0..262144};
    end;
    if dimension0 >= 1 && dimension0 <= 64 then
        operands.sort_width = dimension0 as integer {1..64};
    end;
    operands.selected_byte = UInt(_BundleDataAttributes.pad_value)
        as integer {0..3};
    case UInt(_BundleDataAttributes.comparison_mode) of
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
```
<!-- GENERATED-ASL-END: unit -->
