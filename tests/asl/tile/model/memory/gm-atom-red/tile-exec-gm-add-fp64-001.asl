// PTO-TEST: {"id":"PTO-AVS-TILE-GM-ADD-NUMERIC-FP64-001","source":"asl/tile/model/memory/gm-atom-red.asl","requirements":["PTO-GM-FLOATING-ADD-NUMERIC-001"],"kind":"execution","summary":"Independent Fraction-oracle RN-even gradual FP64 GM ADD vectors","pass_condition":"All independent expected bit patterns and readonly numeric status match","related_sources":[]}
// Oracle: frozen issue397 Fraction/integer decode/add/round, seed 397; no host float.
func main() => integer
begin
    ResetProfileState();
    let before = NumericStatusFlags();
    let value_0 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x401c000000000000, Zeros{PTO_XLEN} + 0x3ff0000000000000);
    assert value_0 == Zeros{PTO_XLEN} + 0x4020000000000000;
    let value_1 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x4020000000000000, Zeros{PTO_XLEN} + 0x4000000000000000);
    assert value_1 == Zeros{PTO_XLEN} + 0x4024000000000000;
    let value_2 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x3ff0000000000000, Zeros{PTO_XLEN} + 0x3ca0000000000000);
    assert value_2 == Zeros{PTO_XLEN} + 0x3ff0000000000000;
    let value_3 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x3ff0000000000001, Zeros{PTO_XLEN} + 0x3ca0000000000000);
    assert value_3 == Zeros{PTO_XLEN} + 0x3ff0000000000002;
    let value_4 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x1, Zeros{PTO_XLEN} + 0x1);
    assert value_4 == Zeros{PTO_XLEN} + 0x2;
    let value_5 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x10000000000000, Zeros{PTO_XLEN} + 0x800fffffffffffff);
    assert value_5 == Zeros{PTO_XLEN} + 0x1;
    let value_6 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0xfffffffffffff, Zeros{PTO_XLEN} + 0x1);
    assert value_6 == Zeros{PTO_XLEN} + 0x10000000000000;
    let value_7 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x0, Zeros{PTO_XLEN} + 0x8000000000000000);
    assert value_7 == Zeros{PTO_XLEN} + 0x0;
    let value_8 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x8000000000000000, Zeros{PTO_XLEN} + 0x8000000000000000);
    assert value_8 == Zeros{PTO_XLEN} + 0x8000000000000000;
    let value_9 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x3ff0000000000000, Zeros{PTO_XLEN} + 0xbff0000000000000);
    assert value_9 == Zeros{PTO_XLEN} + 0x0;
    let value_10 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7ff0000000000000, Zeros{PTO_XLEN} + 0x3ff0000000000000);
    assert value_10 == Zeros{PTO_XLEN} + 0x7ff0000000000000;
    let value_11 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7ff0000000000000, Zeros{PTO_XLEN} + 0xfff0000000000000);
    assert value_11 == Zeros{PTO_XLEN} + 0x7ff8000000000000;
    let value_12 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7fefffffffffffff, Zeros{PTO_XLEN} + 0x7fefffffffffffff);
    assert value_12 == Zeros{PTO_XLEN} + 0x7ff0000000000000;
    let value_13 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0xffefffffffffffff, Zeros{PTO_XLEN} + 0xffefffffffffffff);
    assert value_13 == Zeros{PTO_XLEN} + 0xfff0000000000000;
    let value_14 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7ff0000000000001, Zeros{PTO_XLEN} + 0x3ff0000000000000);
    assert value_14 == Zeros{PTO_XLEN} + 0x7ff8000000000000;
    let value_15 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7ff8000000000003, Zeros{PTO_XLEN} + 0x3ff0000000000000);
    assert value_15 == Zeros{PTO_XLEN} + 0x7ff8000000000000;
    let value_16 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7fefffffffffffff, Zeros{PTO_XLEN} + 0x1);
    assert value_16 == Zeros{PTO_XLEN} + 0x7fefffffffffffff;
    let value_17 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x8000000000000001, Zeros{PTO_XLEN} + 0x8000000000000001);
    assert value_17 == Zeros{PTO_XLEN} + 0x8000000000000002;
    let value_18 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x8010000000000000, Zeros{PTO_XLEN} + 0xfffffffffffff);
    assert value_18 == Zeros{PTO_XLEN} + 0x8000000000000001;
    let value_19 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0xe5620bf770921484, Zeros{PTO_XLEN} + 0x80cde0e160292329);
    assert value_19 == Zeros{PTO_XLEN} + 0xe5620bf770921484;
    let value_20 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x5efbfb4792e2e6a5, Zeros{PTO_XLEN} + 0xdd32bae47665ba9c);
    assert value_20 == Zeros{PTO_XLEN} + 0x5efbfb4791b7385e;
    let value_21 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0xf60e2505896e377a, Zeros{PTO_XLEN} + 0xd6d221f775c3858a);
    assert value_21 == Zeros{PTO_XLEN} + 0xf60e2505896e377a;
    let value_22 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x945b29baf2640cb1, Zeros{PTO_XLEN} + 0x9efa05cc661dacfa);
    assert value_22 == Zeros{PTO_XLEN} + 0x9efa05cc661dacfa;
    let value_23 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x83fdf8b0d700f394, Zeros{PTO_XLEN} + 0x5adb4c508a1ffaa9);
    assert value_23 == Zeros{PTO_XLEN} + 0x5adb4c508a1ffaa9;
    let value_24 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0xec18aa724eec961, Zeros{PTO_XLEN} + 0xfffc3d098666f429);
    assert value_24 == Zeros{PTO_XLEN} + 0x7ff8000000000000;
    let value_25 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0xa164c8cf1f7e9bbb, Zeros{PTO_XLEN} + 0x962a898c068a9841);
    assert value_25 == Zeros{PTO_XLEN} + 0xa164c8cf1f7e9bbb;
    let value_26 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x162929ad91c48ba6, Zeros{PTO_XLEN} + 0xc17f64acd1428d3e);
    assert value_26 == Zeros{PTO_XLEN} + 0xc17f64acd1428d3e;
    let value_27 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x78a042f1019fbe0f, Zeros{PTO_XLEN} + 0x40cd62776327cd84);
    assert value_27 == Zeros{PTO_XLEN} + 0x78a042f1019fbe0f;
    let value_28 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x54fe75149acbe333, Zeros{PTO_XLEN} + 0x361730d1d6558afd);
    assert value_28 == Zeros{PTO_XLEN} + 0x54fe75149acbe333;
    let value_29 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x806570b665f38691, Zeros{PTO_XLEN} + 0x240e1830a9f4a80d);
    assert value_29 == Zeros{PTO_XLEN} + 0x240e1830a9f4a80d;
    let value_30 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x74643ed94476f692, Zeros{PTO_XLEN} + 0x101b97fa8404c266);
    assert value_30 == Zeros{PTO_XLEN} + 0x74643ed94476f692;
    let value_31 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x44240d3eee69fbc8, Zeros{PTO_XLEN} + 0x33d9dd80fa4bb5ac);
    assert value_31 == Zeros{PTO_XLEN} + 0x44240d3eee69fbc8;
    let value_32 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0xdc51c1875472adf9, Zeros{PTO_XLEN} + 0x6a0ba18a927e689a);
    assert value_32 == Zeros{PTO_XLEN} + 0x6a0ba18a927e689a;
    let value_33 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x22cb9912341d92d9, Zeros{PTO_XLEN} + 0xd48d49e3295630a8);
    assert value_33 == Zeros{PTO_XLEN} + 0xd48d49e3295630a8;
    let value_34 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x6171931ba83e592b, Zeros{PTO_XLEN} + 0x87ac20ad14704fea);
    assert value_34 == Zeros{PTO_XLEN} + 0x6171931ba83e592b;
    let value_35 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0xbc0e48a4d7d0110e, Zeros{PTO_XLEN} + 0x1edb8843ae85ca53);
    assert value_35 == Zeros{PTO_XLEN} + 0xbc0e48a4d7d0110e;
    let value_36 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x66b694a9d2d8f2c3, Zeros{PTO_XLEN} + 0x47e4d3e76eb9b433);
    assert value_36 == Zeros{PTO_XLEN} + 0x66b694a9d2d8f2c3;
    let value_37 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x952363dce5b922ff, Zeros{PTO_XLEN} + 0x3efe2053261536ab);
    assert value_37 == Zeros{PTO_XLEN} + 0x3efe2053261536ab;
    let value_38 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x823c476851b06bf9, Zeros{PTO_XLEN} + 0xf63e67fe2e08898d);
    assert value_38 == Zeros{PTO_XLEN} + 0xf63e67fe2e08898d;
    let value_39 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0xc39ef1249e8c6781, Zeros{PTO_XLEN} + 0xf4a495757c3c06fe);
    assert value_39 == Zeros{PTO_XLEN} + 0xf4a495757c3c06fe;
    let value_40 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x599ce3cff99e0655, Zeros{PTO_XLEN} + 0xf4229234e2396a9d);
    assert value_40 == Zeros{PTO_XLEN} + 0xf4229234e2396a9d;
    let value_41 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x223d1ea75bc76de0, Zeros{PTO_XLEN} + 0x7fb4e36257150528);
    assert value_41 == Zeros{PTO_XLEN} + 0x7fb4e36257150528;
    let value_42 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0xcf62a2b3df93e78c, Zeros{PTO_XLEN} + 0xada71ee97c69aa8e);
    assert value_42 == Zeros{PTO_XLEN} + 0xcf62a2b3df93e78c;
    let value_43 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x9b7b745dd79ea7ac, Zeros{PTO_XLEN} + 0x56f51174610370ac);
    assert value_43 == Zeros{PTO_XLEN} + 0x56f51174610370ac;
    let value_44 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0xac2c60b3cd745828, Zeros{PTO_XLEN} + 0x106d283704f8928b);
    assert value_44 == Zeros{PTO_XLEN} + 0xac2c60b3cd745828;
    let value_45 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x54ecb67dcd4663d, Zeros{PTO_XLEN} + 0xe94353f61ede374);
    assert value_45 == Zeros{PTO_XLEN} + 0xe94353f61ede374;
    let value_46 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x5f0818b5ade780ea, Zeros{PTO_XLEN} + 0x9803b928887349aa);
    assert value_46 == Zeros{PTO_XLEN} + 0x5f0818b5ade780ea;
    let value_47 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0xecca5d8b18b25701, Zeros{PTO_XLEN} + 0xdcab79a78bcf3497);
    assert value_47 == Zeros{PTO_XLEN} + 0xecca5d8b18b25701;
    let value_48 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0xb0fabb46a294149d, Zeros{PTO_XLEN} + 0x9e82262691344c1a);
    assert value_48 == Zeros{PTO_XLEN} + 0xb0fabb46a294149d;
    let value_49 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0xef91d47b75a7bc95, Zeros{PTO_XLEN} + 0x381e45bf5e9de60e);
    assert value_49 == Zeros{PTO_XLEN} + 0xef91d47b75a7bc95;
    let value_50 = GMFloatingAddPTX(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x85156d516572d7dc, Zeros{PTO_XLEN} + 0x73b9dd7cd18ca071);
    assert value_50 == Zeros{PTO_XLEN} + 0x73b9dd7cd18ca071;
    assert NumericStatusFlags() == before;
    return 0;
end;
