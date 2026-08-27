// PTO-TEST: {"id":"PTO-AVS-ARCH-GLOBAL-MEMORY-ACCESS-MASK-BOUNDARY-001","source":"asl/arch/memory-model/global-memory-access.asl","requirements":["PTO-ARCH-GM-ACCESS-001"],"kind":"boundary","summary":"Canonical Shared TSTORE accepts every participation mask only under Function 1.","pass_condition":"Function 1 accepts zero and every nonzero subset; all other TLSU functions, including retired Function 14, reject Shared stores.","related_sources":["asl/block/model/dispatch/shared-tlsu.asl"]}
func main() => integer
begin
    assert SharedStorePEMaskLegal(1, Zeros{4});
    assert SharedStorePEMaskLegal(1, '1111');
    assert SharedStorePEMaskLegal(1, '0001');
    assert SharedStorePEMaskLegal(1, '1100');
    assert SharedStorePEMaskLegal(14, Zeros{4});
    assert !SharedStorePEMaskLegal(14, '0001');
    assert !SharedStorePEMaskLegal(14, '1100');
    assert !SharedStorePEMaskLegal(14, '1111');
    assert !SharedStorePEMaskLegal(2, '1111');
    return 0;
end;
