// PTO-TEST: {"id":"PTO-AVS-TILE-INDEXED-TYPES-001","source":"asl/tile/model/legality/indexed-rearrangement.asl","requirements":[],"kind":"boundary","summary":"Indexed rearrangement exposes independent non-packed data and index domains.","pass_condition":"Non-packed gather/scatter values accept cross-width indices while packed values and unsupported M-family index widths reject.","related_sources":["asl/tile/irregular-and-complex/layout/TGATHER.asl","asl/tile/irregular-and-complex/layout/TSCATTER.asl"]}

func main() => integer
begin
    assert TGATHERValueDataTypeLegal(
        TileDataType_FP32);
    assert TGATHERValueDataTypeLegal(
        TileDataType_U8);
    assert !TGATHERValueDataTypeLegal(
        TileDataType_E2M1X2);
    assert TGATHERIndexDataTypeLegal(
        TileDataType_S32);
    assert TGATHERIndexDataTypeLegal(
        TileDataType_U16);
    assert TGATHERIndexDataTypeLegal(
        TileDataType_U64);
    assert TSCATTERTypePairLegal(
        TileDataType_U8,
        TileDataType_S16);
    assert TSCATTERTypePairLegal(
        TileDataType_U8,
        TileDataType_U32);
    assert TSCATTERTypePairLegal(
        TileDataType_U8,
        TileDataType_S64);
    assert !TSCATTERTypePairLegal(
        TileDataType_U8,
        TileDataType_S8);
    return 0;
end;
