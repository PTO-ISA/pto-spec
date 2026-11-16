// PTO-TEST: {"id":"PTO-AVS-BLOCK-PREDICATE-COMPARE-LOGICAL-CHAIN-001","source":"asl/block/model/dispatch/comparison-schema.asl","requirements":["PTO-TCMP-CONTRACT-001","PTO-TAND-CONTRACT-001","PTO-TOR-CONTRACT-001","PTO-TXOR-CONTRACT-001"],"kind":"execution","summary":"Decoded comparisons with distinct bases feed decoded logical composition","pass_condition":"TCMP U32 and FP32 results feed TAND TOR and TXOR as canonical U8-basis PredicateCells on M16 and M32","related_sources":["asl/tile/model/legality/operand-schema.asl","asl/block/model/dispatch/destination-operation.asl"]}
pure func ChainStart(function: integer {0..31}, data_type: TileDataType) => bits(64)
begin
    var start = Zeros{64} + 0x00019181;
    start[24:20] = Zeros{5} + function;
    start[31:27] = TileDataTypeToEncoding(data_type);
    return start;
end;
func ChainBegin(function: integer {0..31}, data_type: TileDataType, layout: TileLayout)
begin
    let started = ExecuteCommandInstruction(ChainStart(function,data_type),32);
    var attrs = Zeros{64} + 0x00001023;
    attrs[24:20] = DTYPE_NONE;
    attrs[11:7] = if function == 13 then Zeros{5}
        else if layout == TileLayout_CUBE_M16 then Zeros{5} + 31 else Zeros{5} + 29;
    let attributed = ExecuteCommandInstruction(attrs,32);
    assert started == CommandExecution_Executed && attributed == CommandExecution_Executed;
    SetBundleDimension(0,Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1,Zeros{PTO_XLEN} + 1);
end;
func ChainFinish()
begin
    _BundleActive = FALSE; _BundleBodyActive = FALSE; ClearBundleHeaderState();
end;
func RunCompareLogicalChain(layout: TileLayout, function: integer {6..8})
begin
    ResetProfileState();
    let a = ConfigureCubeTile(10,512,1,4,TileDataType_U32,layout);
    let b = ConfigureCubeTile(11,512,1,4,TileDataType_U32,layout);
    let c = ConfigureCubeTile(12,512,1,4,TileDataType_FP32,layout);
    let d = ConfigureCubeTile(13,512,1,4,TileDataType_FP32,layout);
    assert a && b && c && d;
    WriteTileElement(10,0,0,Zeros{PTO_XLEN} + 1); WriteTileElement(10,0,1,Zeros{PTO_XLEN} + 2);
    WriteTileElement(11,0,0,Zeros{PTO_XLEN} + 1); WriteTileElement(11,0,1,Zeros{PTO_XLEN} + 2);
    WriteTileElement(10,0,2,Zeros{PTO_XLEN} + 2); WriteTileElement(10,0,3,Zeros{PTO_XLEN} + 2);
    WriteTileElement(11,0,2,Zeros{PTO_XLEN} + 1); WriteTileElement(11,0,3,Zeros{PTO_XLEN} + 1);
    WriteTileElement(12,0,0,Zeros{PTO_XLEN} + 0x3f800000); WriteTileElement(12,0,1,Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(13,0,0,Zeros{PTO_XLEN} + 0x3f800000); WriteTileElement(13,0,1,Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(12,0,2,Zeros{PTO_XLEN} + 0x3f800000); WriteTileElement(12,0,3,Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(13,0,2,Zeros{PTO_XLEN} + 0x3f800000); WriteTileElement(13,0,3,Zeros{PTO_XLEN} + 0x40000000);
    MarkTileValidRegionDefined(10); MarkTileValidRegionDefined(11);
    MarkTileValidRegionDefined(12); MarkTileValidRegionDefined(13);
    ChainBegin(13,TileDataType_U32,layout);
    AddBundleTileBinding(TRUE,0,1,'0001',TRUE,TRUE,10,11,TRUE);
    let op = DecodeTileOperation(TileDecode_TEPL,Zeros{12} + 13) as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert SelectedBundleComparisonDimensionsLegal();
    assert SelectedBundleComparisonShapeMatches(10);
    assert BundleOperationBindingsComplete(op);
    assert BundleOperationGPRBindingValuesLegal(op);
    let attribute_legal = SelectedBundleTileDataAttributesLegal(op);
    assert attribute_legal;
    assert SelectedBundleClosedTCMPSchemaLegal(op);
    assert SelectedBundleTileMasksLegal();
    let prepared = PrepareSelectedBundleStage2();
    assert prepared;
    let first = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert first;
    let pred0 = _BundleTileBindings[[0]].destination;
    assert _Tiles[[pred0]].predicate_basis_type == TileDataType_U32;
    ChainFinish();
    ChainBegin(13,TileDataType_FP32,layout);
    AddBundleTileBinding(TRUE,1,1,'0001',TRUE,TRUE,12,13,TRUE);
    let second = ExecuteBundleTileOperation(); assert second && _LastFault == Fault_None;
    let pred1 = _BundleTileBindings[[0]].destination;
    assert _Tiles[[pred1]].predicate_basis_type == TileDataType_FP32;
    ChainFinish();
    ChainBegin(function,TileDataType_U8,layout);
    AddBundleTileBinding(TRUE,2,1,'0001',TRUE,TRUE,pred0,pred1,TRUE);
    let composed = ExecuteBundleTileOperation(); assert composed && _LastFault == Fault_None;
    let output = _BundleTileBindings[[0]].destination;
    assert _Tiles[[output]].storage_kind == TileStorage_PredicateCell &&
           _Tiles[[output]].predicate_basis_type == TileDataType_U8 &&
           ReadTileElement(output,0,0) == (if function == 8 then Zeros{PTO_XLEN} else Zeros{PTO_XLEN} + 1) &&
           ReadTileElement(output,0,1) == (if function == 6 then Zeros{PTO_XLEN} else Zeros{PTO_XLEN} + 1) &&
           ReadTileElement(output,0,2) == (if function == 6 then Zeros{PTO_XLEN} else Zeros{PTO_XLEN} + 1) &&
           ReadTileElement(output,0,3) == Zeros{PTO_XLEN};
end;
func main() => integer
begin
    for function = 6 to 8 do
        RunCompareLogicalChain(TileLayout_CUBE_M16,function as integer {6..8});
        RunCompareLogicalChain(TileLayout_CUBE_M32,function as integer {6..8});
    end;
    return 0;
end;
