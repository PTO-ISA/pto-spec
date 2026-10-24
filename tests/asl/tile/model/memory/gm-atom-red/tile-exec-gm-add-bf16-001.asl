// PTO-TEST: {"id":"PTO-AVS-TILE-GM-ADD-NUMERIC-BF16-001","source":"asl/tile/model/memory/gm-atom-red.asl","requirements":["PTO-GM-FLOATING-ADD-NUMERIC-001"],"kind":"execution","summary":"Independent Fraction-oracle RN-even gradual BF16 GM ADD vectors","pass_condition":"All independent expected bit patterns and readonly numeric status match","related_sources":[]}
// Oracle: frozen issue397 Fraction/integer decode/add/round, seed 397; no host float.
func main() => integer
begin
    ResetProfileState();
    let before = NumericStatusFlags();
    let value_0 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x40e0, Zeros{PTO_XLEN} + 0x3f80);
    assert value_0 == Zeros{PTO_XLEN} + 0x4100;
    let value_1 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x4100, Zeros{PTO_XLEN} + 0x4000);
    assert value_1 == Zeros{PTO_XLEN} + 0x4120;
    let value_2 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x3f80, Zeros{PTO_XLEN} + 0x3b80);
    assert value_2 == Zeros{PTO_XLEN} + 0x3f80;
    let value_3 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x3f81, Zeros{PTO_XLEN} + 0x3b80);
    assert value_3 == Zeros{PTO_XLEN} + 0x3f82;
    let value_4 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x1, Zeros{PTO_XLEN} + 0x1);
    assert value_4 == Zeros{PTO_XLEN} + 0x2;
    let value_5 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x80, Zeros{PTO_XLEN} + 0x807f);
    assert value_5 == Zeros{PTO_XLEN} + 0x1;
    let value_6 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x7f, Zeros{PTO_XLEN} + 0x1);
    assert value_6 == Zeros{PTO_XLEN} + 0x80;
    let value_7 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x0, Zeros{PTO_XLEN} + 0x8000);
    assert value_7 == Zeros{PTO_XLEN} + 0x0;
    let value_8 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x8000, Zeros{PTO_XLEN} + 0x8000);
    assert value_8 == Zeros{PTO_XLEN} + 0x8000;
    let value_9 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x3f80, Zeros{PTO_XLEN} + 0xbf80);
    assert value_9 == Zeros{PTO_XLEN} + 0x0;
    let value_10 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x7f80, Zeros{PTO_XLEN} + 0x3f80);
    assert value_10 == Zeros{PTO_XLEN} + 0x7f80;
    let value_11 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x7f80, Zeros{PTO_XLEN} + 0xff80);
    assert value_11 == Zeros{PTO_XLEN} + 0x7fc0;
    let value_12 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x7f7f, Zeros{PTO_XLEN} + 0x7f7f);
    assert value_12 == Zeros{PTO_XLEN} + 0x7f80;
    let value_13 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0xff7f, Zeros{PTO_XLEN} + 0xff7f);
    assert value_13 == Zeros{PTO_XLEN} + 0xff80;
    let value_14 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x7f81, Zeros{PTO_XLEN} + 0x3f80);
    assert value_14 == Zeros{PTO_XLEN} + 0x7fc0;
    let value_15 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x7fc3, Zeros{PTO_XLEN} + 0x3f80);
    assert value_15 == Zeros{PTO_XLEN} + 0x7fc0;
    let value_16 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x7f7f, Zeros{PTO_XLEN} + 0x1);
    assert value_16 == Zeros{PTO_XLEN} + 0x7f7f;
    let value_17 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x8001, Zeros{PTO_XLEN} + 0x8001);
    assert value_17 == Zeros{PTO_XLEN} + 0x8002;
    let value_18 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x8080, Zeros{PTO_XLEN} + 0x7f);
    assert value_18 == Zeros{PTO_XLEN} + 0x8001;
    let value_19 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x892b, Zeros{PTO_XLEN} + 0x7462);
    assert value_19 == Zeros{PTO_XLEN} + 0x7462;
    let value_20 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0xc958, Zeros{PTO_XLEN} + 0xae2e);
    assert value_20 == Zeros{PTO_XLEN} + 0xc958;
    let value_21 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x60b8, Zeros{PTO_XLEN} + 0x5dc6);
    assert value_21 == Zeros{PTO_XLEN} + 0x60bb;
    let value_22 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x2a80, Zeros{PTO_XLEN} + 0xa020);
    assert value_22 == Zeros{PTO_XLEN} + 0x2a80;
    let value_23 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x37c7, Zeros{PTO_XLEN} + 0x22b0);
    assert value_23 == Zeros{PTO_XLEN} + 0x37c7;
    let value_24 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x708b, Zeros{PTO_XLEN} + 0x3ca7);
    assert value_24 == Zeros{PTO_XLEN} + 0x708b;
    let value_25 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0xbaed, Zeros{PTO_XLEN} + 0xc6ea);
    assert value_25 == Zeros{PTO_XLEN} + 0xc6ea;
    let value_26 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0xd15c, Zeros{PTO_XLEN} + 0xe2da);
    assert value_26 == Zeros{PTO_XLEN} + 0xe2da;
    let value_27 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0xab1f, Zeros{PTO_XLEN} + 0x5fa7);
    assert value_27 == Zeros{PTO_XLEN} + 0x5fa7;
    let value_28 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0xc70d, Zeros{PTO_XLEN} + 0x6397);
    assert value_28 == Zeros{PTO_XLEN} + 0x6397;
    let value_29 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x4696, Zeros{PTO_XLEN} + 0x50a0);
    assert value_29 == Zeros{PTO_XLEN} + 0x50a0;
    let value_30 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x151d, Zeros{PTO_XLEN} + 0x4cb);
    assert value_30 == Zeros{PTO_XLEN} + 0x151d;
    let value_31 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x286c, Zeros{PTO_XLEN} + 0x669c);
    assert value_31 == Zeros{PTO_XLEN} + 0x669c;
    let value_32 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0xab04, Zeros{PTO_XLEN} + 0xa5ac);
    assert value_32 == Zeros{PTO_XLEN} + 0xab04;
    let value_33 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0xab83, Zeros{PTO_XLEN} + 0x793b);
    assert value_33 == Zeros{PTO_XLEN} + 0x793b;
    let value_34 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0xa9aa, Zeros{PTO_XLEN} + 0xa919);
    assert value_34 == Zeros{PTO_XLEN} + 0xa9f6;
    let value_35 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x33c0, Zeros{PTO_XLEN} + 0xea90);
    assert value_35 == Zeros{PTO_XLEN} + 0xea90;
    let value_36 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0xb68e, Zeros{PTO_XLEN} + 0x6b1e);
    assert value_36 == Zeros{PTO_XLEN} + 0x6b1e;
    let value_37 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x7dd4, Zeros{PTO_XLEN} + 0xa588);
    assert value_37 == Zeros{PTO_XLEN} + 0x7dd4;
    let value_38 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0xf5aa, Zeros{PTO_XLEN} + 0x32db);
    assert value_38 == Zeros{PTO_XLEN} + 0xf5aa;
    let value_39 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x40c2, Zeros{PTO_XLEN} + 0x9c4);
    assert value_39 == Zeros{PTO_XLEN} + 0x40c2;
    let value_40 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0xa2f2, Zeros{PTO_XLEN} + 0x2c25);
    assert value_40 == Zeros{PTO_XLEN} + 0x2c25;
    let value_41 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x990f, Zeros{PTO_XLEN} + 0x8d15);
    assert value_41 == Zeros{PTO_XLEN} + 0x990f;
    let value_42 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x7e22, Zeros{PTO_XLEN} + 0xc10e);
    assert value_42 == Zeros{PTO_XLEN} + 0x7e22;
    let value_43 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0xc83a, Zeros{PTO_XLEN} + 0x9b97);
    assert value_43 == Zeros{PTO_XLEN} + 0xc83a;
    let value_44 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x8550, Zeros{PTO_XLEN} + 0x9ca);
    assert value_44 == Zeros{PTO_XLEN} + 0x9ca;
    let value_45 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0xe003, Zeros{PTO_XLEN} + 0xf44b);
    assert value_45 == Zeros{PTO_XLEN} + 0xf44b;
    let value_46 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x6aa9, Zeros{PTO_XLEN} + 0x39d9);
    assert value_46 == Zeros{PTO_XLEN} + 0x6aa9;
    let value_47 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x460, Zeros{PTO_XLEN} + 0xddb1);
    assert value_47 == Zeros{PTO_XLEN} + 0xddb1;
    let value_48 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x3e2, Zeros{PTO_XLEN} + 0xf68f);
    assert value_48 == Zeros{PTO_XLEN} + 0xf68f;
    let value_49 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x7c16, Zeros{PTO_XLEN} + 0x47b9);
    assert value_49 == Zeros{PTO_XLEN} + 0x7c16;
    let value_50 = GMFloatingAddPTX(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x2475, Zeros{PTO_XLEN} + 0xef95);
    assert value_50 == Zeros{PTO_XLEN} + 0xef95;
    assert GMFloatingAddPTX(TileDataType_BF16, Ones{PTO_XLEN}, Zeros{PTO_XLEN}) ==
        GMFloatingAddPTX(TileDataType_BF16, Zeros{PTO_XLEN} + 0xffff, Zeros{PTO_XLEN});
    assert NumericStatusFlags() == before;
    return 0;
end;
