// PTO-TEST: {"id":"PTO-AVS-TILE-MGATHER-MASK-PREDICATE-VALUES-001","source":"asl/tile/memory-and-data-movement/irregular/MGATHER_MASK.asl","requirements":["PTO-MGATHER-MASK-PREDICATE-001"],"kind":"boundary","summary":"MGATHER_MASK rejects every noncanonical ordinary U8 predicate value before effects.","pass_condition":"Ordinary Local U8 predicate values 0x02 and 0x80, plus a CUBE_M16 value 0xff, reject with no memory event or write.","related_sources":["asl/tile/model/legality/predicate-carriers.asl","asl/tile/model/legality/memory-schema.asl"]}
func RejectPredicate(layout: TileLayout, predicate_value: Word)
begin
    ResetProfileState();
    var destination_ready: boolean = FALSE;
    var index_ready: boolean = FALSE;
    var mask_ready: boolean = FALSE;
    if layout == TileLayout_RowMajor then
        ConfigureTile(0, 128, 1, 1, 1, 1,
            TileDataType_U32, layout);
        ConfigureTile(1, 128, 1, 1, 1, 1,
            TileDataType_S32, layout);
        ConfigureTile(2, 128, 1, 1, 1, 1,
            TileDataType_U8, layout);
        destination_ready = TRUE;
        index_ready = TRUE;
        mask_ready = TRUE;
    else
        destination_ready = ConfigureCubeTile(0, 128, 1, 1,
            TileDataType_U32, layout);
        index_ready = ConfigureCubeTile(1, 128, 1, 1,
            TileDataType_S32, layout);
        mask_ready = ConfigureCubeTile(2, 128, 1, 1,
            TileDataType_U8, layout);
    end;
    assert destination_ready && index_ready && mask_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x11);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 0, predicate_value);
    Store(Zeros{PTO_XLEN} + 0x204, 4, Zeros{PTO_XLEN} + 0x77);
    StartMemoryEventCapture(0);
    assert !TileOperandsLegal_MGATHER_MASK(0,
        Zeros{PTO_XLEN} + 0x200, 1, 2, TilePad_Zero);
    assert _MemoryEventCount == 0;
    let unchanged = LoadUnsigned(Zeros{PTO_XLEN} + 0x204, 4);
    assert unchanged == Zeros{PTO_XLEN} + 0x77;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x11;
    StopMemoryEventCapture();
end;

func main() => integer
begin
    RejectPredicate(TileLayout_RowMajor, Zeros{PTO_XLEN} + 0x02);
    RejectPredicate(TileLayout_RowMajor, Zeros{PTO_XLEN} + 0x80);
    RejectPredicate(TileLayout_CUBE_M16, Zeros{PTO_XLEN} + 0xff);
    return 0;
end;
