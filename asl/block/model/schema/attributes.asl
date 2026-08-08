// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-SCHEMA-ATTRIBUTES","surface":"block","classification":["model","schema","attributes"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-HEADER"]}
func SetBundleControlAttributeState(trap_enabled: boolean, atomic: boolean,
                                   acquire: boolean, release: boolean,
                                   far: boolean, direct_register: boolean)
begin
    _BundleControlAttributes.trap_enabled = trap_enabled;
    _BundleControlAttributes.atomic = atomic;
    _BundleControlAttributes.acquire = acquire;
    _BundleControlAttributes.release = release;
    _BundleControlAttributes.far = far;
    _BundleControlAttributes.direct_register = direct_register;
end;

func SetBundleDataAttributeState(data_type: bits(5), data_layout: bits(5),
                                pad_value: bits(2), conversion_mode: bits(3),
                                rounding_mode: bits(3), saturating: boolean)
begin
    _BundleDataAttributes.data_type = data_type;
    _BundleDataAttributes.data_layout = data_layout;
    _BundleDataAttributes.pad_value = pad_value;
    _BundleDataAttributes.conversion_mode = conversion_mode;
    _BundleDataAttributes.rounding_mode = rounding_mode;
    _BundleDataAttributes.saturating = saturating;
    _BundleDataAttributes.canonicalize = FALSE;
end;

