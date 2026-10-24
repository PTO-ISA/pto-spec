// PTO-TEST: {"id":"PTO-AVS-TILE-GM-ADD-NUMERIC-FP32-001","source":"asl/tile/model/memory/gm-atom-red.asl","requirements":["PTO-GM-FLOATING-ADD-NUMERIC-001"],"kind":"execution","summary":"Independent Fraction-oracle RN-even gradual FP32 GM ADD vectors","pass_condition":"All independent expected bit patterns and readonly numeric status match","related_sources":[]}
// Oracle: frozen issue397 Fraction/integer decode/add/round, seed 397; no host float.
func main() => integer
begin
    ResetProfileState();
    let before = NumericStatusFlags();
    let value_0 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x40e00000, Zeros{PTO_XLEN} + 0x3f800000);
    assert value_0 == Zeros{PTO_XLEN} + 0x41000000;
    let value_1 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x41000000, Zeros{PTO_XLEN} + 0x40000000);
    assert value_1 == Zeros{PTO_XLEN} + 0x41200000;
    let value_2 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x3f800000, Zeros{PTO_XLEN} + 0x33800000);
    assert value_2 == Zeros{PTO_XLEN} + 0x3f800000;
    let value_3 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x3f800001, Zeros{PTO_XLEN} + 0x33800000);
    assert value_3 == Zeros{PTO_XLEN} + 0x3f800002;
    let value_4 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x1, Zeros{PTO_XLEN} + 0x1);
    assert value_4 == Zeros{PTO_XLEN} + 0x2;
    let value_5 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x800000, Zeros{PTO_XLEN} + 0x807fffff);
    assert value_5 == Zeros{PTO_XLEN} + 0x1;
    let value_6 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7fffff, Zeros{PTO_XLEN} + 0x1);
    assert value_6 == Zeros{PTO_XLEN} + 0x800000;
    let value_7 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x0, Zeros{PTO_XLEN} + 0x80000000);
    assert value_7 == Zeros{PTO_XLEN} + 0x0;
    let value_8 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x80000000, Zeros{PTO_XLEN} + 0x80000000);
    assert value_8 == Zeros{PTO_XLEN} + 0x80000000;
    let value_9 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x3f800000, Zeros{PTO_XLEN} + 0xbf800000);
    assert value_9 == Zeros{PTO_XLEN} + 0x0;
    let value_10 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7f800000, Zeros{PTO_XLEN} + 0x3f800000);
    assert value_10 == Zeros{PTO_XLEN} + 0x7f800000;
    let value_11 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7f800000, Zeros{PTO_XLEN} + 0xff800000);
    assert value_11 == Zeros{PTO_XLEN} + 0x7fc00000;
    let value_12 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7f7fffff, Zeros{PTO_XLEN} + 0x7f7fffff);
    assert value_12 == Zeros{PTO_XLEN} + 0x7f800000;
    let value_13 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xff7fffff, Zeros{PTO_XLEN} + 0xff7fffff);
    assert value_13 == Zeros{PTO_XLEN} + 0xff800000;
    let value_14 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7f800001, Zeros{PTO_XLEN} + 0x3f800000);
    assert value_14 == Zeros{PTO_XLEN} + 0x7fc00000;
    let value_15 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7fc00003, Zeros{PTO_XLEN} + 0x3f800000);
    assert value_15 == Zeros{PTO_XLEN} + 0x7fc00000;
    let value_16 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7f7fffff, Zeros{PTO_XLEN} + 0x1);
    assert value_16 == Zeros{PTO_XLEN} + 0x7f7fffff;
    let value_17 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x80000001, Zeros{PTO_XLEN} + 0x80000001);
    assert value_17 == Zeros{PTO_XLEN} + 0x80000002;
    let value_18 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x80800000, Zeros{PTO_XLEN} + 0x7fffff);
    assert value_18 == Zeros{PTO_XLEN} + 0x80000001;
    let value_19 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xa6a98406, Zeros{PTO_XLEN} + 0x81c2628e);
    assert value_19 == Zeros{PTO_XLEN} + 0xa6a98406;
    let value_20 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x3b4e9e9e, Zeros{PTO_XLEN} + 0x97501a8f);
    assert value_20 == Zeros{PTO_XLEN} + 0x3b4e9e9e;
    let value_21 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xdbc17b0d, Zeros{PTO_XLEN} + 0xbae92d0f);
    assert value_21 == Zeros{PTO_XLEN} + 0xdbc17b0d;
    let value_22 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7b149367, Zeros{PTO_XLEN} + 0x46e67810);
    assert value_22 == Zeros{PTO_XLEN} + 0x7b149367;
    let value_23 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xdef9a265, Zeros{PTO_XLEN} + 0x44565dfa);
    assert value_23 == Zeros{PTO_XLEN} + 0xdef9a265;
    let value_24 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x6399a23a, Zeros{PTO_XLEN} + 0xb0a0521);
    assert value_24 == Zeros{PTO_XLEN} + 0x6399a23a;
    let value_25 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xa5d84cd4, Zeros{PTO_XLEN} + 0x4f3f57f8);
    assert value_25 == Zeros{PTO_XLEN} + 0x4f3f57f8;
    let value_26 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x466770af, Zeros{PTO_XLEN} + 0x18cfd0ca);
    assert value_26 == Zeros{PTO_XLEN} + 0x466770af;
    let value_27 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xf94508f9, Zeros{PTO_XLEN} + 0xa380d3a8);
    assert value_27 == Zeros{PTO_XLEN} + 0xf94508f9;
    let value_28 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x617399d3, Zeros{PTO_XLEN} + 0xd9290ead);
    assert value_28 == Zeros{PTO_XLEN} + 0x6173992a;
    let value_29 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xbd422f11, Zeros{PTO_XLEN} + 0x959bd7df);
    assert value_29 == Zeros{PTO_XLEN} + 0xbd422f11;
    let value_30 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xe6994893, Zeros{PTO_XLEN} + 0x201c4b50);
    assert value_30 == Zeros{PTO_XLEN} + 0xe6994893;
    let value_31 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xc16ff42d, Zeros{PTO_XLEN} + 0xec435bb9);
    assert value_31 == Zeros{PTO_XLEN} + 0xec435bb9;
    let value_32 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xca6739e2, Zeros{PTO_XLEN} + 0xb2adb6a);
    assert value_32 == Zeros{PTO_XLEN} + 0xca6739e2;
    let value_33 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xd273a777, Zeros{PTO_XLEN} + 0xbd8e1d8c);
    assert value_33 == Zeros{PTO_XLEN} + 0xd273a777;
    let value_34 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x784dbe7c, Zeros{PTO_XLEN} + 0x57b9b351);
    assert value_34 == Zeros{PTO_XLEN} + 0x784dbe7c;
    let value_35 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x8c4081b7, Zeros{PTO_XLEN} + 0xd030fae5);
    assert value_35 == Zeros{PTO_XLEN} + 0xd030fae5;
    let value_36 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x9843caf7, Zeros{PTO_XLEN} + 0x8a4586f4);
    assert value_36 == Zeros{PTO_XLEN} + 0x9843caf7;
    let value_37 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x42421eec, Zeros{PTO_XLEN} + 0xee2a2f78);
    assert value_37 == Zeros{PTO_XLEN} + 0xee2a2f78;
    let value_38 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xbbf0ad37, Zeros{PTO_XLEN} + 0x3d11147d);
    assert value_38 == Zeros{PTO_XLEN} + 0x3ce5fdac;
    let value_39 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x93e1b01b, Zeros{PTO_XLEN} + 0x4967076a);
    assert value_39 == Zeros{PTO_XLEN} + 0x4967076a;
    let value_40 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x13efd06, Zeros{PTO_XLEN} + 0xa0cdb05c);
    assert value_40 == Zeros{PTO_XLEN} + 0xa0cdb05c;
    let value_41 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xdacfcf39, Zeros{PTO_XLEN} + 0xa020b06d);
    assert value_41 == Zeros{PTO_XLEN} + 0xdacfcf39;
    let value_42 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x4ba2e3a7, Zeros{PTO_XLEN} + 0xdeb62742);
    assert value_42 == Zeros{PTO_XLEN} + 0xdeb62742;
    let value_43 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xbf485094, Zeros{PTO_XLEN} + 0xa08a634b);
    assert value_43 == Zeros{PTO_XLEN} + 0xbf485094;
    let value_44 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xcbe85bac, Zeros{PTO_XLEN} + 0x16b596fb);
    assert value_44 == Zeros{PTO_XLEN} + 0xcbe85bac;
    let value_45 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xa51444ed, Zeros{PTO_XLEN} + 0x36c125dc);
    assert value_45 == Zeros{PTO_XLEN} + 0x36c125dc;
    let value_46 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xce33531d, Zeros{PTO_XLEN} + 0x9d74f894);
    assert value_46 == Zeros{PTO_XLEN} + 0xce33531d;
    let value_47 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xb3eec17d, Zeros{PTO_XLEN} + 0x9a4323cf);
    assert value_47 == Zeros{PTO_XLEN} + 0xb3eec17d;
    let value_48 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xc49c55a7, Zeros{PTO_XLEN} + 0x67392886);
    assert value_48 == Zeros{PTO_XLEN} + 0x67392886;
    let value_49 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x69b3bc5e, Zeros{PTO_XLEN} + 0x1606232);
    assert value_49 == Zeros{PTO_XLEN} + 0x69b3bc5e;
    let value_50 = GMFloatingAddPTX(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x5d51b563, Zeros{PTO_XLEN} + 0xc516e120);
    assert value_50 == Zeros{PTO_XLEN} + 0x5d51b563;
    assert GMFloatingAddPTX(TileDataType_FP32, Ones{PTO_XLEN}, Zeros{PTO_XLEN}) ==
        GMFloatingAddPTX(TileDataType_FP32, Zeros{PTO_XLEN} + 0xffffffff, Zeros{PTO_XLEN});
    assert NumericStatusFlags() == before;
    return 0;
end;
