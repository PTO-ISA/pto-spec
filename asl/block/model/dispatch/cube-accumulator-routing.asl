// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-CUBE-ACCUMULATOR-ROUTING","surface":"block","classification":["model","dispatch","cube-accumulator-routing"],"depends_on":["PTO-BLOCK-B-DATR","PTO-TILE-MODEL-LEGALITY-MATRIX-FUNCTIONS"]}

readonly func BundleTMATMULCCTRL() => bits(2)
begin
    if !_BundleDataAttributesPresent then return Zeros{2}; end;
    return _BundleDataAttributes.pad_value;
end;

pure func BundleTMATMULRawPartialOutput(cctrl: bits(2)) => boolean
begin
    return cctrl[0:0] != Zeros{1};
end;

pure func BundleTMATMULAccumulatorPrefetchHint(cctrl: bits(2)) => boolean
begin
    return cctrl[1:1] != Zeros{1};
end;

readonly func BundleTMATMULAccumulatorControlLegal(
    function: integer {0..31}, cctrl: bits(2)) => boolean
begin
    if TileMatrixFunctionUsesAccumulator(function) then return TRUE; end;
    return !BundleTMATMULAccumulatorPrefetchHint(cctrl);
end;

readonly func BundleTMATMULPartialPostProcessLegal(
    cctrl: bits(2)) => boolean
begin
    if !BundleTMATMULRawPartialOutput(cctrl) then return TRUE; end;
    return UInt(_BundleFixedPointAttributes.pre_quant_mode) == 0 &&
           UInt(_BundleFixedPointAttributes.relu_mode) == 0 &&
           UInt(_BundleFixedPointAttributes.group_n_code) == 0 &&
           !_BundleFixedPointAttributes.row_max_en &&
           !_BundleFixedPointAttributes.group_max_en &&
           !_BundleFixedPointAttributes.max_abs_en;
end;
