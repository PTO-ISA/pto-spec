// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-DESTINATION-AUXILIARY","surface":"block","classification":["model","dispatch","destination-auxiliary"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA"]}
readonly func BundleGroupMaxColumns(columns: integer {0..65535})
                                      => integer {0..65535}
begin
    let group_n = BundleFPATRGroupN(_BundleFixedPointAttributes.group_n_code);
    if !_BundleFixedPointAttributes.group_max_en || group_n == 0 then
        return columns;
    end;
    return ((columns + (group_n - 1)) DIVRM group_n)
        as integer {0..65535};
end;
