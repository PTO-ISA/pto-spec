<!-- GENERATED FROM: asl/block/model/operands/shared-bindings.asl -->
# Shared Bindings

**Normative ASL source:** `asl/block/model/operands/shared-bindings.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/shared-bindings.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS","surface":"block","classification":["model","operands","shared-bindings"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-DIMENSIONS"]}
func BindBundleSharedIO(shared_id: bits(8), size_code: integer {0..7},
                        pe_mask: bits(4))
begin
    for index = 0 to 3 do
        if _BundleSharedBindings[[index]].valid &&
           _BundleSharedBindings[[index]].shared_id == shared_id &&
           !_BundleSharedBindings[[index]].consumed then
            SetFault(Fault_TileLegality, ReadTPC());
            return;
        end;
    end;
    for index = 0 to 3 do
        if !_BundleSharedBindings[[index]].valid then
            _BundleSharedBindings[[index]].valid = TRUE;
            _BundleSharedBindings[[index]].shared_id = shared_id;
            _BundleSharedBindings[[index]].size_code = size_code;
            _BundleSharedBindings[[index]].pe_mask = pe_mask;
            _BundleSharedBindings[[index]].consumed = FALSE;
            return;
        end;
    end;
    SetFault(Fault_TileLegality, ReadTPC());
end;

readonly func BundleSharedBindingCount() => integer {0..4}
begin
    var count: integer {0..4} = 0;
    for index = 0 to 3 do
        if _BundleSharedBindings[[index]].valid then
            count = (count + 1) as integer {0..4};
        end;
    end;
    return count;
end;

readonly func BundleSharedBindingId(ordinal: integer {0..3}) => bits(8)
begin
    assert _BundleSharedBindings[[ordinal]].valid &&
           !_BundleSharedBindings[[ordinal]].consumed;
    return _BundleSharedBindings[[ordinal]].shared_id;
end;

readonly func BundleSharedBindingSize(ordinal: integer {0..3})
        => integer {0..7}
begin
    assert _BundleSharedBindings[[ordinal]].valid &&
           !_BundleSharedBindings[[ordinal]].consumed;
    return _BundleSharedBindings[[ordinal]].size_code;
end;

readonly func BundleSharedBindingMask(ordinal: integer {0..3}) => bits(4)
begin
    assert _BundleSharedBindings[[ordinal]].valid &&
           !_BundleSharedBindings[[ordinal]].consumed;
    return _BundleSharedBindings[[ordinal]].pe_mask;
end;

readonly func BundleSharedBindingIsDestination(
    ordinal: integer {0..3}) => boolean
begin
    return BundleSharedBindingSize(ordinal) != 0;
end;

func ConsumeBundleSharedBindings(count: integer {1..4})
begin
    assert BundleSharedBindingCount() == count;
    for index = 0 to count - 1 looplimit 4 do
        assert _BundleSharedBindings[[index]].valid &&
               !_BundleSharedBindings[[index]].consumed;
        _BundleSharedBindings[[index]].consumed = TRUE;
    end;
end;

readonly func BundleSharedBindingsUnconsumed() => boolean
begin
    for index = 0 to 3 do
        if _BundleSharedBindings[[index]].valid &&
           !_BundleSharedBindings[[index]].consumed then return TRUE; end;
    end;
    return FALSE;
end;

readonly func BundleTileMaskCanAppend(pe_mask: bits(4)) => boolean
begin
    if pe_mask == Zeros{4} then return FALSE; end;
    for index = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[index]].valid &&
           _BundleTileBindings[[index]].pe_mask != pe_mask then
            return FALSE;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
