// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSCATTER-SCHEMA-001","source":"asl/block/execution/BSTART.MSCATTER.asl","requirements":["PTO-BSTART-MSCATTER-SCHEMA-001","PTO-MSCATTER-BYTE-DISPLACEMENT-001"],"kind":"boundary","summary":"MSCATTER rejects missing scalar input and mismatched source contracts before effects.","pass_condition":"Missing B.IOR, source DataType mismatch, and floating IndexTile each raise TileLegality with no memory event or write.","related_sources":["asl/block/model/dispatch/tlsu-mscatter.asl"]}
func ConfigureScatterSchema(source_type: TileDataType,
                            index_type: TileDataType,
                            include_ior: boolean)
begin
    ConfigureTile(1, 128, 1, 1, 1, 1, source_type,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 1, 1, 1, index_type,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x77);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    var start: bits(64) = Zeros{64} + 0x00511181;
    start[31:27] = Zeros{5} + 27;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(FALSE, 0, 0, '0001', TRUE, TRUE, 1, 2, TRUE);
    if include_ior then SetBundleScalarBinding(0, 0, 0, 0, 0, 1); end;
end;

func RejectScatterSchema(source_type: TileDataType,
                         index_type: TileDataType,
                         include_ior: boolean)
begin
    ResetProfileState();
    ConfigureScatterSchema(source_type, index_type, include_ior);
    Store(Zeros{PTO_XLEN} + 0x1c0, 1, Zeros{PTO_XLEN} + 0x55);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    let observed = LoadUnsigned(Zeros{PTO_XLEN} + 0x1c0, 1);
    assert observed == Zeros{PTO_XLEN} + 0x55;
end;

func main() => integer
begin
    RejectScatterSchema(TileDataType_U8, TileDataType_U32, FALSE);
    RejectScatterSchema(TileDataType_U16, TileDataType_U32, TRUE);
    RejectScatterSchema(TileDataType_U8, TileDataType_FP32, TRUE);
    return 0;
end;
