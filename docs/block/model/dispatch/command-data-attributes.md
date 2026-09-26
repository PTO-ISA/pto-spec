<!-- GENERATED FROM: asl/block/model/dispatch/command-data-attributes.asl -->
# Command Data Attributes

**Normative ASL source:** `asl/block/model/dispatch/command-data-attributes.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-COMMAND-DATA-ATTRIBUTES}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/command-data-attributes.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-COMMAND-DATA-ATTRIBUTES","surface":"block","classification":["model","dispatch","command-data-attributes"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-EXECUTION-MASK-SCHEMA","PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS"]}
readonly func BundleExecutionMaskDataAttributesLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded_operation = TileOperationOfIndex(operation);
    let mask_present = _BundleExecutionMask.valid ||
        _BundleScalarBindings[[0]].execution_mask_present ||
        _BundleScalarBindings[[1]].execution_mask_present ||
        BundleExecutionMaskTileCarrierPresent(operation);
    if (_BundleDataAttributes.execution_mask_invert ||
        _BundleDataAttributes.execution_mask_zero) && !mask_present then
        return FALSE;
    end;
    var local_cube_layout = CurrentBundleTileLayout() == TileLayout_CUBE_M16 ||
        CurrentBundleTileLayout() == TileLayout_CUBE_M32;
    // TCMP and TCMPS own a closed B.DATR schema that leaves Layout zero.
    // Their Local CUBE domain comes from the comparison source tiles,
    // while DATR Layout remains independently validated as zero by the
    // operation owner.
    if decoded_operation == TileOperation_TCMP then
        let binding = _BundleTileBindings[[0]];
        if binding.valid && binding.source0_valid && binding.source1_valid then
            let left = BundleTileSourceIndex(0, FALSE);
            let right = BundleTileSourceIndex(0, TRUE);
            local_cube_layout =
                (_Tiles[[left]].layout == TileLayout_CUBE_M16 ||
                 _Tiles[[left]].layout == TileLayout_CUBE_M32) &&
                _Tiles[[right]].layout == _Tiles[[left]].layout;
        else
            local_cube_layout = FALSE;
        end;
    elsif decoded_operation == TileOperation_TCMPS then
        let binding = _BundleTileBindings[[0]];
        if binding.valid && binding.source0_valid then
            let source = BundleTileSourceIndex(0, FALSE);
            local_cube_layout = _Tiles[[source]].layout == TileLayout_CUBE_M16 ||
                _Tiles[[source]].layout == TileLayout_CUBE_M32;
        else
            local_cube_layout = FALSE;
        end;
    // TSEL/TSELS also keep B.DATR Layout closed at zero.  For the
    // ExecutionMask intersection, derive the Local CUBE domain from the
    // operation's numeric input descriptors instead of DATR Layout.
    elsif decoded_operation == TileOperation_TSEL then
        let inputs = _BundleTileBindings[[0]];
        if inputs.valid && inputs.source0_valid then
            let first = BundleTileSourceIndex(0, FALSE);
            if _Tiles[[first]].storage_kind == TileStorage_PredicateCell then
                if inputs.source1_valid &&
                   _BundleTileBindings[[1]].valid &&
                   _BundleTileBindings[[1]].source0_valid then
                    let source_true = BundleTileSourceIndex(0, TRUE);
                    let source_false = BundleTileSourceIndex(1, FALSE);
                    local_cube_layout =
                        (_Tiles[[source_true]].layout == TileLayout_CUBE_M16 ||
                         _Tiles[[source_true]].layout == TileLayout_CUBE_M32) &&
                        _Tiles[[source_false]].layout ==
                            _Tiles[[source_true]].layout;
                else
                    local_cube_layout = FALSE;
                end;
            elsif inputs.source1_valid then
                let source_true = BundleTileSourceIndex(0, FALSE);
                let source_false = BundleTileSourceIndex(0, TRUE);
                local_cube_layout =
                    (_Tiles[[source_true]].layout == TileLayout_CUBE_M16 ||
                     _Tiles[[source_true]].layout == TileLayout_CUBE_M32) &&
                    _Tiles[[source_false]].layout ==
                        _Tiles[[source_true]].layout;
            else
                local_cube_layout = FALSE;
            end;
        else
            local_cube_layout = FALSE;
        end;
    elsif decoded_operation == TileOperation_TSELS then
        let inputs = _BundleTileBindings[[0]];
        if inputs.valid && inputs.source0_valid then
            let first = BundleTileSourceIndex(0, FALSE);
            if _Tiles[[first]].storage_kind == TileStorage_PredicateCell then
                if inputs.source1_valid then
                    let source_true = BundleTileSourceIndex(0, TRUE);
                    local_cube_layout =
                        _Tiles[[source_true]].layout == TileLayout_CUBE_M16 ||
                        _Tiles[[source_true]].layout == TileLayout_CUBE_M32;
                else
                    local_cube_layout = FALSE;
                end;
            else
                local_cube_layout =
                    _Tiles[[first]].layout == TileLayout_CUBE_M16 ||
                    _Tiles[[first]].layout == TileLayout_CUBE_M32;
            end;
        else
            local_cube_layout = FALSE;
        end;
    end;
    if mask_present &&
       (!TileOperationExecutionMaskEligible(operation) ||
        !local_cube_layout ||
        (_BundleDataAttributes.execution_mask_zero &&
         !TileOperandPresent(operation, TileOperand_destination0) &&
         TileOperationOfIndex(operation) != TileOperation_TCMP &&
         TileOperationOfIndex(operation) != TileOperation_TCMPS)) then
        return FALSE;
    end;
    return TRUE;
end;

func SetBundleDataAttributesFromCommand(
    instruction: bits(64), form: integer {0..PTO_COMMAND_FORM_COUNT-1})
begin
    SetBundleDataAttributeState(
        DecodeCommandOperandRaw(instruction, form,
            CommandField_DataType)[4:0],
        DecodeCommandOperandRaw(instruction, form,
            CommandField_Layout)[4:0],
        DecodeCommandOperandRaw(instruction, form,
            CommandField_PadValueOrByteId)[1:0],
        DecodeCommandOperandRaw(instruction, form,
            CommandField_CMode)[2:0],
        DecodeCommandOperandRaw(instruction, form,
            CommandField_RMode)[2:0],
        CommandDecodedBool(instruction, form, CommandField_Sat),
        CommandDecodedBool(instruction, form, CommandField_Canonicalize));
    if _LastFault == Fault_None then
        _BundleDataAttributes.execution_mask_invert =
            CommandDecodedBool(instruction, form, CommandField_PredInv);
        _BundleDataAttributes.execution_mask_zero =
            CommandDecodedBool(instruction, form, CommandField_Zero);
        _BundleDataAttributesPresent = TRUE;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
