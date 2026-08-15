// PTO-TEST: {"id":"PTO-AVS-ARCH-TILEDATATYPE-RESERVED-001","source":"asl/arch/data-types/tile-data-types.asl","requirements":[],"kind":"boundary","summary":"The five-bit Tile DataType namespace assigns 25 codes and rejects exactly seven future-extension codes.","pass_condition":"All 32 five-bit encodings have the required assigned or reserved disposition and assigned encodings round-trip.","related_sources":["asl/block/attributes/B.DATR.asl"]}
func TestTileDataTypeReservedEncodings()
begin
    for code = 0 to 31 looplimit 32 do
        let encoded = (Zeros{5} + code) as TileDataTypeEncoding;
        let expected_reserved = code == 15 ||
                                (21 <= code && code <= 23) ||
                                (29 <= code && code <= 31);
        assert TileDataTypeEncodingValid(encoded) == !expected_reserved;
    end;

    assert TileDataTypeToEncoding(TileDataType_FP64) == Zeros{5};
    assert TileDataTypeToEncoding(TileDataType_HiF4X2) == Zeros{5} + 14;
    assert TileDataTypeToEncoding(TileDataType_S4X2) == Zeros{5} + 20;
    assert TileDataTypeToEncoding(TileDataType_U4X2) == Zeros{5} + 28;
    assert TileDataTypeFromEncoding(Zeros{5}) == TileDataType_FP64;
    assert TileDataTypeFromEncoding(Zeros{5} + 28) == TileDataType_U4X2;
end;

func main() => integer
begin
    TestTileDataTypeReservedEncodings();
    return 0;
end;
