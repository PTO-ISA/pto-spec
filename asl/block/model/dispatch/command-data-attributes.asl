// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-COMMAND-DATA-ATTRIBUTES","surface":"block","classification":["model","dispatch","command-data-attributes"],"depends_on":["PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS"]}
readonly func BundleExecutionMaskDataAttributesLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let mask_present = _BundleExecutionMask.valid ||
        _BundleScalarBindings[[0]].execution_mask_present ||
        _BundleScalarBindings[[1]].execution_mask_present;
    if (_BundleDataAttributes.execution_mask_invert ||
        _BundleDataAttributes.execution_mask_zero) && !mask_present then
        return FALSE;
    end;
    if mask_present &&
       (!TileOperationExecutionMaskEligible(operation) ||
        (CurrentBundleTileLayout() != TileLayout_CUBE_M16 &&
         CurrentBundleTileLayout() != TileLayout_CUBE_M32) ||
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
