// PTO-TEST: {"id":"PTO-AVS-TILE-TLEA-DECODED-UNSIGNED-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TLEA.asl","requirements":["PTO-TLEA-CONTRACT-001","PTO-INST-TILE-TLEA"],"kind":"execution","summary":"Decoded TLEA preserves unsigned high bits and independent source/destination physical columns.","pass_condition":"U32 high-bit extension and U64 modulo scaling publish exact U64 offsets into two-column destinations from four-column sources.","related_sources":["asl/block/model/dispatch/lea-schema.asl","asl/block/model/dispatch/destination-operation.asl"]}
func UnsignedLEACase(source_type: TileDataType, source_rows: integer {1..65535},
    width_bits: Word, source_value: Word, expected: Word)
begin
    ResetProfileState();
    ConfigureTile(1, 128, source_rows, 4, 1, 2, source_type, TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, source_value);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteGPR(2, width_bits);
    var start: bits(64) = Zeros{64} + 0x02e19181;
    start[31:27] = TileDataTypeToEncoding(source_type);
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(TRUE, 0, 1, '0001', TRUE, FALSE, 1, 0, TRUE);
    SetBundleScalarBinding(0, 0, 2, 0, 0, 3);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_U64;
    assert _Tiles[[destination]].columns == 2;
    assert _Tiles[[1]].columns == 4;
    assert ReadTileElement(destination, 0, 0) == expected;
    assert ReadTileElement(destination, 0, 1) == (if width_bits == Zeros{PTO_XLEN} + 32 then
        Zeros{PTO_XLEN} + 8 else Zeros{PTO_XLEN} + 16);
    assert ReadTileElement(1, 0, 0) == source_value;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
end;

func main() => integer
begin
    UnsignedLEACase(TileDataType_U32, 8, Zeros{PTO_XLEN} + 32,
        Zeros{PTO_XLEN} + 0x80000001, Zeros{PTO_XLEN} + 0x200000004);
    UnsignedLEACase(TileDataType_U64, 4, Zeros{PTO_XLEN} + 64,
        Ones{PTO_XLEN}, Ones{PTO_XLEN} - 7);
    return 0;
end;
