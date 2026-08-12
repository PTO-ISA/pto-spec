// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-RESET-CLEAR-001","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR"],"kind":"state-transition","summary":"B.FPATR fields and encoded presence clear with bundle reset","pass_condition":"reset removes presence and every latched field","related_sources":[]}
func main() => integer
begin
    ResetBundleControlState();
    _BundleFixedPointAttributes.valid = TRUE;
    _BundleFixedPointAttributes.pre_quant_mode = '000011';
    _BundleFixedPointAttributes.relu_mode = '010';
    _BundleFixedPointAttributes.group_n_code = '0001';
    _BundleFixedPointAttributes.row_max_en = TRUE;
    _BundleFixedPointAttributes.group_max_en = TRUE;
    _BundleFixedPointAttributes.row_max_init = TRUE;
    _BundleFixedPointAttributes.max_abs_en = TRUE;
    ResetBundleControlState();
    assert !_BundleFixedPointAttributes.valid;
    assert _BundleFixedPointAttributes.pre_quant_mode == Zeros{6};
    assert _BundleFixedPointAttributes.relu_mode == Zeros{3};
    assert _BundleFixedPointAttributes.group_n_code == Zeros{4};
    assert !_BundleFixedPointAttributes.row_max_en;
    assert !_BundleFixedPointAttributes.group_max_en;
    assert !_BundleFixedPointAttributes.row_max_init;
    assert !_BundleFixedPointAttributes.max_abs_en;
    return 0;
end;
