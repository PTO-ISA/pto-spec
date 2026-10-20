// PTO-TEST: {"id":"PTO-AVS-TILE-GM-ADD-NUMERIC-FP16-001","source":"asl/tile/model/memory/gm-atom-red.asl","requirements":["PTO-GM-FLOATING-ADD-NUMERIC-001"],"kind":"execution","summary":"Independent Fraction-oracle RN-even gradual FP16 GM ADD vectors","pass_condition":"All independent expected bit patterns and readonly numeric status match","related_sources":[]}
// Oracle: frozen issue397 Fraction/integer decode/add/round, seed 397; no host float.
func main() => integer
begin
    ResetProfileState();
    let before = NumericStatusFlags();
    let value_0 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x4700, Zeros{PTO_XLEN} + 0x3c00);
    assert value_0 == Zeros{PTO_XLEN} + 0x4800;
    let value_1 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x4800, Zeros{PTO_XLEN} + 0x4000);
    assert value_1 == Zeros{PTO_XLEN} + 0x4900;
    let value_2 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x3c00, Zeros{PTO_XLEN} + 0x1000);
    assert value_2 == Zeros{PTO_XLEN} + 0x3c00;
    let value_3 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x3c01, Zeros{PTO_XLEN} + 0x1000);
    assert value_3 == Zeros{PTO_XLEN} + 0x3c02;
    let value_4 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x1, Zeros{PTO_XLEN} + 0x1);
    assert value_4 == Zeros{PTO_XLEN} + 0x2;
    let value_5 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x400, Zeros{PTO_XLEN} + 0x83ff);
    assert value_5 == Zeros{PTO_XLEN} + 0x1;
    let value_6 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x3ff, Zeros{PTO_XLEN} + 0x1);
    assert value_6 == Zeros{PTO_XLEN} + 0x400;
    let value_7 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x0, Zeros{PTO_XLEN} + 0x8000);
    assert value_7 == Zeros{PTO_XLEN} + 0x0;
    let value_8 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x8000, Zeros{PTO_XLEN} + 0x8000);
    assert value_8 == Zeros{PTO_XLEN} + 0x8000;
    let value_9 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x3c00, Zeros{PTO_XLEN} + 0xbc00);
    assert value_9 == Zeros{PTO_XLEN} + 0x0;
    let value_10 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7c00, Zeros{PTO_XLEN} + 0x3c00);
    assert value_10 == Zeros{PTO_XLEN} + 0x7c00;
    let value_11 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7c00, Zeros{PTO_XLEN} + 0xfc00);
    assert value_11 == Zeros{PTO_XLEN} + 0x7e00;
    let value_12 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7bff, Zeros{PTO_XLEN} + 0x7bff);
    assert value_12 == Zeros{PTO_XLEN} + 0x7c00;
    let value_13 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0xfbff, Zeros{PTO_XLEN} + 0xfbff);
    assert value_13 == Zeros{PTO_XLEN} + 0xfc00;
    let value_14 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7c01, Zeros{PTO_XLEN} + 0x3c00);
    assert value_14 == Zeros{PTO_XLEN} + 0x7e00;
    let value_15 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7e03, Zeros{PTO_XLEN} + 0x3c00);
    assert value_15 == Zeros{PTO_XLEN} + 0x7e00;
    let value_16 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7bff, Zeros{PTO_XLEN} + 0x1);
    assert value_16 == Zeros{PTO_XLEN} + 0x7bff;
    let value_17 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x8001, Zeros{PTO_XLEN} + 0x8001);
    assert value_17 == Zeros{PTO_XLEN} + 0x8002;
    let value_18 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x8400, Zeros{PTO_XLEN} + 0x3ff);
    assert value_18 == Zeros{PTO_XLEN} + 0x8001;
    let value_19 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x1ee6, Zeros{PTO_XLEN} + 0x171c);
    assert value_19 == Zeros{PTO_XLEN} + 0x2056;
    let value_20 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x6509, Zeros{PTO_XLEN} + 0x75f1);
    assert value_20 == Zeros{PTO_XLEN} + 0x7642;
    let value_21 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0xc7f0, Zeros{PTO_XLEN} + 0xbc0b);
    assert value_21 == Zeros{PTO_XLEN} + 0xc879;
    let value_22 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x53, Zeros{PTO_XLEN} + 0xb1e3);
    assert value_22 == Zeros{PTO_XLEN} + 0xb1e3;
    let value_23 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x46c5, Zeros{PTO_XLEN} + 0x95dd);
    assert value_23 == Zeros{PTO_XLEN} + 0x46c5;
    let value_24 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0xd06b, Zeros{PTO_XLEN} + 0x24b4);
    assert value_24 == Zeros{PTO_XLEN} + 0xd06a;
    let value_25 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x3c92, Zeros{PTO_XLEN} + 0xba23);
    assert value_25 == Zeros{PTO_XLEN} + 0x3602;
    let value_26 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x65a4, Zeros{PTO_XLEN} + 0x6718);
    assert value_26 == Zeros{PTO_XLEN} + 0x6a5e;
    let value_27 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x1c88, Zeros{PTO_XLEN} + 0x5e1b);
    assert value_27 == Zeros{PTO_XLEN} + 0x5e1b;
    let value_28 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x5360, Zeros{PTO_XLEN} + 0xda3f);
    assert value_28 == Zeros{PTO_XLEN} + 0xd867;
    let value_29 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0xa9a3, Zeros{PTO_XLEN} + 0x8641);
    assert value_29 == Zeros{PTO_XLEN} + 0xa9a6;
    let value_30 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0xfc2b, Zeros{PTO_XLEN} + 0x7fc0);
    assert value_30 == Zeros{PTO_XLEN} + 0x7e00;
    let value_31 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0xd9b7, Zeros{PTO_XLEN} + 0x8216);
    assert value_31 == Zeros{PTO_XLEN} + 0xd9b7;
    let value_32 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x59ad, Zeros{PTO_XLEN} + 0x69eb);
    assert value_32 == Zeros{PTO_XLEN} + 0x6a46;
    let value_33 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0xa805, Zeros{PTO_XLEN} + 0xd14);
    assert value_33 == Zeros{PTO_XLEN} + 0xa7f6;
    let value_34 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0xbbe6, Zeros{PTO_XLEN} + 0x54c0);
    assert value_34 == Zeros{PTO_XLEN} + 0x54b0;
    let value_35 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x75f9, Zeros{PTO_XLEN} + 0xb333);
    assert value_35 == Zeros{PTO_XLEN} + 0x75f9;
    let value_36 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0xa4d8, Zeros{PTO_XLEN} + 0xc8e9);
    assert value_36 == Zeros{PTO_XLEN} + 0xc8eb;
    let value_37 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x5c0d, Zeros{PTO_XLEN} + 0xd035);
    assert value_37 == Zeros{PTO_XLEN} + 0x5b0d;
    let value_38 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0xc0c0, Zeros{PTO_XLEN} + 0x58d8);
    assert value_38 == Zeros{PTO_XLEN} + 0x58c5;
    let value_39 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7e9, Zeros{PTO_XLEN} + 0x4b9d);
    assert value_39 == Zeros{PTO_XLEN} + 0x4b9d;
    let value_40 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7590, Zeros{PTO_XLEN} + 0xcae3);
    assert value_40 == Zeros{PTO_XLEN} + 0x758f;
    let value_41 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x760b, Zeros{PTO_XLEN} + 0xe6fa);
    assert value_41 == Zeros{PTO_XLEN} + 0x759b;
    let value_42 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0xeaf9, Zeros{PTO_XLEN} + 0xf70b);
    assert value_42 == Zeros{PTO_XLEN} + 0xf7ea;
    let value_43 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0xadb8, Zeros{PTO_XLEN} + 0xb06);
    assert value_43 == Zeros{PTO_XLEN} + 0xadb4;
    let value_44 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0xbdfe, Zeros{PTO_XLEN} + 0x50b7);
    assert value_44 == Zeros{PTO_XLEN} + 0x5087;
    let value_45 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x8e6a, Zeros{PTO_XLEN} + 0xb724);
    assert value_45 == Zeros{PTO_XLEN} + 0xb726;
    let value_46 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x3d89, Zeros{PTO_XLEN} + 0x3263);
    assert value_46 == Zeros{PTO_XLEN} + 0x3e55;
    let value_47 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7cf0, Zeros{PTO_XLEN} + 0xe44f);
    assert value_47 == Zeros{PTO_XLEN} + 0x7e00;
    let value_48 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x3098, Zeros{PTO_XLEN} + 0xd18b);
    assert value_48 == Zeros{PTO_XLEN} + 0xd186;
    let value_49 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0xbe95, Zeros{PTO_XLEN} + 0x54a);
    assert value_49 == Zeros{PTO_XLEN} + 0xbe95;
    let value_50 = GMFloatingAddPTX(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x5867, Zeros{PTO_XLEN} + 0xf794);
    assert value_50 == Zeros{PTO_XLEN} + 0xf78b;
    assert GMFloatingAddPTX(TileDataType_FP16, Ones{PTO_XLEN}, Zeros{PTO_XLEN}) ==
        GMFloatingAddPTX(TileDataType_FP16, Zeros{PTO_XLEN} + 0xffff, Zeros{PTO_XLEN});
    assert NumericStatusFlags() == before;
    return 0;
end;
