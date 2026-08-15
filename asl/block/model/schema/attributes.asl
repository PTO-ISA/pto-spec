// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-SCHEMA-ATTRIBUTES","surface":"block","classification":["model","schema","attributes"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-HEADER"]}
func SetBundleControlAttributeState(trap_enabled: boolean, atomic: boolean,
                                   acquire: boolean, release: boolean,
                                   far: boolean,
                                   dimension_reduction: boolean)
begin
    _BundleControlAttributes.present = TRUE;
    _BundleControlAttributes.trap_enabled = trap_enabled;
    _BundleControlAttributes.atomic = atomic;
    _BundleControlAttributes.acquire = acquire;
    _BundleControlAttributes.release = release;
    _BundleControlAttributes.far = far;
    _BundleControlAttributes.dimension_reduction = dimension_reduction;
end;

func SetBundleFixedPointAttributeState(pre_quant_mode: bits(6),
                                       relu_mode: bits(3),
                                       group_n_code: bits(4),
                                       row_max_en: boolean,
                                       group_max_en: boolean,
                                       row_max_init: boolean,
                                       max_abs_en: boolean)
begin
    // Header-local field checks happen before the descriptor becomes visible.
    if !BundleFPATRFieldsLegal(pre_quant_mode, relu_mode, group_n_code,
                               row_max_en, group_max_en, row_max_init,
                               max_abs_en) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    _BundleFixedPointAttributes.valid = TRUE;
    _BundleFixedPointAttributes.pre_quant_mode = pre_quant_mode;
    _BundleFixedPointAttributes.relu_mode = relu_mode;
    _BundleFixedPointAttributes.group_n_code = group_n_code;
    _BundleFixedPointAttributes.row_max_en = row_max_en;
    _BundleFixedPointAttributes.group_max_en = group_max_en;
    _BundleFixedPointAttributes.row_max_init = row_max_init;
    _BundleFixedPointAttributes.max_abs_en = max_abs_en;
end;
