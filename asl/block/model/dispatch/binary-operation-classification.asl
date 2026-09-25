// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-BINARY-OP-CLASSIFICATION","surface":"block","classification":["model","dispatch","binary-operation-classification"],"depends_on":[]}
pure func TileOperationUsesClosedBinarySchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TADD ||
           decoded == TileOperation_TSUB ||
           decoded == TileOperation_TMUL ||
           decoded == TileOperation_TDIV ||
           decoded == TileOperation_TREM ||
           decoded == TileOperation_TMAX ||
           decoded == TileOperation_TMIN ||
           decoded == TileOperation_TEXPDIF;
end;
