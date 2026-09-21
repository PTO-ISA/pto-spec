// PTO-TEST: {"id":"PTO-AVS-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING-PEMODE-001","source":"asl/block/model/schema/bundle-encoding.asl","requirements":[],"kind":"static-invariant","summary":"The common PEMode decoder maps all eight encoded modes to fixed PE identities and masks.","pass_condition":"Every PEMode witness returns the exact four-bit semantic mask, including zero and all four-PE combinations.","related_sources":["asl/block/operands/B.IOT.asl","asl/block/operands/B.IOS.asl"]}
func main() => integer
begin
    assert PEMaskOfPEMode('000') == '0000';
    assert PEMaskOfPEMode('001') == '1000';
    assert PEMaskOfPEMode('010') == '0100';
    assert PEMaskOfPEMode('011') == '0010';
    assert PEMaskOfPEMode('100') == '0001';
    assert PEMaskOfPEMode('101') == '1100';
    assert PEMaskOfPEMode('110') == '1110';
    assert PEMaskOfPEMode('111') == '1111';
    assert PTOPEMaskBitOfPEIdentity(0) == 3;
    assert PTOPEMaskBitOfPEIdentity(1) == 2;
    assert PTOPEMaskBitOfPEIdentity(2) == 1;
    assert PTOPEMaskBitOfPEIdentity(3) == 0;
    return 0;
end;
