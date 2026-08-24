// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-MATRIX-SCALE","surface":"block","classification":["model","dispatch","matrix-scale"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS"]}

readonly func BundleMatrixCScaleDestinationIndicesDistinct(
    c_scale_ordinal: integer {0..8}) => boolean
begin
    let c_scale = BundleMatrixArchitecturalSourceAt(c_scale_ordinal);
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           c_scale == UInt(_BundleTileBindings[[binding]].destination_hand) then
            return FALSE;
        end;
    end;
    return TRUE;
end;
