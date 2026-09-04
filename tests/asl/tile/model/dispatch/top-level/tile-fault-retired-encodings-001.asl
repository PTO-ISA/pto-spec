// PTO-TEST: {"id":"PTO-AVS-TILE-RETIRED-ENCODINGS-FAULT-001","source":"asl/tile/model/dispatch/top-level.asl","requirements":["PTO-ARCH-ENCODING-OWNERSHIP-001"],"kind":"fault","summary":"retired complete TEPL encodings reject before any operand read or tile effect","pass_condition":"all eight retired selectors return TileExecution_Rejected with Fault_IllegalInstruction and preserve tile state and TPC","related_sources":["asl/arch/overview/encoding-ownership.asl"]}
readonly func RetiredEncodingFingerprint() => Word
begin
    var fingerprint = Zeros{PTO_XLEN};
    if _Tiles[[0]].allocated then
        fingerprint = fingerprint + Zeros{PTO_XLEN} + 1;
    end;
    if _Tiles[[0]].contents_defined then
        fingerprint = fingerprint + Zeros{PTO_XLEN} + 2;
    end;
    fingerprint = fingerprint + _Tiles[[0]].payload[[0]];
    if _Tiles[[0]].defined_elements[0] == '1' then
        fingerprint = fingerprint + Zeros{PTO_XLEN} + 4;
    end;
    return fingerprint;
end;

func AssertRetiredEncoding(code: bits(12))
begin
    ResetProfileState();
    ConfigureTile(0, 256, 1, 4, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x55);
    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    operands.source0 = 0;
    operands.source1 = 0;
    let before_tile = RetiredEncodingFingerprint();
    let before_tpc = ReadTPC();
    ClearFault();
    let (status, value) = ExecuteTileInstruction(TileDecode_TEPL, code, operands);
    assert status == TileExecution_Rejected;
    assert value == Zeros{PTO_XLEN};
    assert _LastFault == Fault_IllegalInstruction;
    assert RetiredEncodingFingerprint() == before_tile;
    assert ReadTPC() == before_tpc;
end;

func main() => integer
begin
    AssertRetiredEncoding(Zeros{12} + 0x060);
    AssertRetiredEncoding(Zeros{12} + 0x062);
    AssertRetiredEncoding(Zeros{12} + 0x063);
    AssertRetiredEncoding(Zeros{12} + 0x068);
    AssertRetiredEncoding(Zeros{12} + 0x06A);
    AssertRetiredEncoding(Zeros{12} + 0x06B);
    AssertRetiredEncoding(Zeros{12} + 0x06C);
    AssertRetiredEncoding(Zeros{12} + 0x06D);
    return 0;
end;
