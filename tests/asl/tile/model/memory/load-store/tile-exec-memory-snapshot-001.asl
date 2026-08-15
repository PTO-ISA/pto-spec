// PTO-TEST: {"id":"PTO-AVS-TILE-MEM-SNAPSHOT-001","source":"asl/tile/model/memory/load-store.asl","requirements":[],"kind":"execution","summary":"One raw memory snapshot supplies both the event value and decoded Tile element.","pass_condition":"raw byte decoding preserves integer width, sign, and packed nibble selection","related_sources":["asl/tile/model/memory/gather-scatter.asl","asl/tile/model/memory/atomics.asl"]}
func main() => integer
begin
    let raw_byte = Zeros{PTO_XLEN} + 0xab;

    assert DecodeTileMemoryElementRaw(
        raw_byte, TileDataType_U8, FALSE) == raw_byte;
    assert DecodeTileMemoryElementRaw(
        raw_byte, TileDataType_S8, FALSE) ==
        SignExtend{PTO_XLEN}('10101011');
    assert DecodeTileMemoryElementRaw(
        raw_byte, TileDataType_U4X2, FALSE) == Zeros{PTO_XLEN} + 0xb;
    assert DecodeTileMemoryElementRaw(
        raw_byte, TileDataType_U4X2, TRUE) == Zeros{PTO_XLEN} + 0xa;

    return 0;
end;
