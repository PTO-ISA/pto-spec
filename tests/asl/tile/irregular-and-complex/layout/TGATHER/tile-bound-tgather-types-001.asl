// PTO-TEST: {"id":"PTO-AVS-TILE-TGATHER-TYPES-001","source":"asl/tile/irregular-and-complex/layout/TGATHER.asl","requirements":["PTO-TGATHER-CONTRACT-001"],"kind":"boundary","summary":"TGATHER exposes its non-packed value and independent six-type index domains.","pass_condition":"All non-packed value types and S16/U16/S32/U32/S64/U64 row-index types are legal while packed value and index types remain rejected.","related_sources":["asl/tile/model/legality/indexed-rearrangement.asl"]}

func main() => integer
begin
    assert TGATHERValueDataTypeLegal(TileDataType_FP32);
    assert TGATHERValueDataTypeLegal(TileDataType_FP16);
    assert TGATHERValueDataTypeLegal(TileDataType_BF16);
    assert TGATHERValueDataTypeLegal(TileDataType_S8);
    assert TGATHERValueDataTypeLegal(TileDataType_U64);
    assert TGATHERValueDataTypeLegal(TileDataType_S32);
    assert TGATHERValueDataTypeLegal(TileDataType_U16);
    assert !TGATHERValueDataTypeLegal(TileDataType_E2M1X2);
    assert !TGATHERValueDataTypeLegal(TileDataType_U4X2);
    assert TGATHERIndexDataTypeLegal(TileDataType_S16);
    assert TGATHERIndexDataTypeLegal(TileDataType_U16);
    assert TGATHERIndexDataTypeLegal(TileDataType_S32);
    assert TGATHERIndexDataTypeLegal(TileDataType_U32);
    assert TGATHERIndexDataTypeLegal(TileDataType_S64);
    assert TGATHERIndexDataTypeLegal(TileDataType_U64);
    assert !TGATHERIndexDataTypeLegal(TileDataType_S8);
    assert !TGATHERIndexDataTypeLegal(TileDataType_E2M1X2);
    return 0;
end;
