// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA","surface":"block","classification":["model","dispatch","scalar-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY"]}
pure func BundleOperationConsumesScalarSource0(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperandPresent(operation, TileOperand_address) ||
           TileOperandPresent(operation, TileOperand_scalar0);
end;

pure func BundleOperationConsumesScalarSource1(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return (TileOperandPresent(operation, TileOperand_address) &&
            (TileOperandPresent(operation, TileOperand_scalar0) ||
             TileOperandPresent(operation, TileOperand_scalar1))) ||
           (TileOperandPresent(operation, TileOperand_scalar0) &&
            TileOperandPresent(operation, TileOperand_scalar1));
end;

readonly func BundleOperationScalarBindingSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !_BundleScalarBindings[[0]].valid then return TRUE; end;
    if _BundleScalarBindings[[0]].destination != 0 ||
       _BundleScalarBindings[[0]].source2 != 0 then return FALSE; end;
    if !BundleOperationConsumesScalarSource0(operation) &&
       _BundleScalarBindings[[0]].source0 != 0 then return FALSE; end;
    if !BundleOperationConsumesScalarSource1(operation) &&
       _BundleScalarBindings[[0]].source1 != 0 then return FALSE; end;
    return TRUE;
end;
