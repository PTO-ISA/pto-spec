<!-- GENERATED FROM: asl/block/model/dispatch/destination-auxiliary.asl -->
# Destination Auxiliary

**Normative ASL source:** `asl/block/model/dispatch/destination-auxiliary.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-DESTINATION-AUXILIARY}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/destination-auxiliary.asl -->
```asl
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
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
