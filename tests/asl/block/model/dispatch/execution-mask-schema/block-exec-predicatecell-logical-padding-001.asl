// PTO-TEST: {"id":"PTO-AVS-BLOCK-PREDICATECELL-LOGICAL-PADDING-001","source":"asl/block/model/dispatch/execution-mask-schema.asl","requirements":["PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-TAND-CONTRACT-001","PTO-B-IOT-STREAM-001"],"kind":"execution","summary":"Decoded PredicateCell TAND applies all four physical padding modes","pass_condition":"Null leaves padding undefined; Zero and Min pad with zero, Max pads with one","related_sources":["asl/block/model/dispatch/tile-schema.asl","asl/block/model/dispatch/tile-instruction-operands.asl","asl/tile/model/execution/elementwise.asl"]}
pure func PredicateLogicalStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = Zeros{2};
    instruction[24:20] = Zeros{5} + 6;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func PredicateLogicalAttributes(pad: bits(2)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 31;
    instruction[13] = '1';
    instruction[28:27] = pad;
    return instruction;
end;

func RunPredicatePadding(pad: bits(2))
begin
    ResetProfileState();
    let left_ready = ConfigurePredicateCell(
        1, 128, 2, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let right_ready = ConfigurePredicateCell(
        2, 128, 2, 2, TileDataType_FP32, TileLayout_CUBE_M16);
    let predicate_ready = ConfigurePredicateCell(
        3, 128, 2, 2, TileDataType_FP32, TileLayout_CUBE_M16);
    assert left_ready && right_ready && predicate_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 1, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(3, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(3, 1, 1, Zeros{PTO_XLEN} + 1);
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);
    _Tiles[[3]].contents_defined = TRUE;

    let started = ExecuteCommandInstruction(PredicateLogicalStart(), 32);
    assert started == CommandExecution_Executed;
    let attributes = ExecuteCommandInstruction(
        PredicateLogicalAttributes(pad), 32);
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 8);
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 3, 0, TRUE);

    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 6)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleExecutionMaskTileCarrierPresent(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[1]].destination;
    assert _Tiles[[destination]].storage_kind == TileStorage_PredicateCell;
    assert _Tiles[[destination]].predicate_basis_type == TileDataType_U8;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN};
    if pad == '11' then
        assert !TileElementDefined(destination,0,2);
    else
        assert TileElementDefined(destination,0,2);
        assert ReadTileElement(destination,0,2) ==
            (if pad == '01' then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
    end;
end;
func main() => integer
begin
    RunPredicatePadding('00'); RunPredicatePadding('01');
    RunPredicatePadding('10'); RunPredicatePadding('11');
    return 0;
end;
