// PTO-TEST: {"id":"PTO-AVS-TILE-TLEA-SCHEMA-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TLEA.asl","requirements":["PTO-INST-TILE-TLEA","PTO-TLEA-CONTRACT-001"],"kind":"boundary","summary":"TLEA rejects malformed type, width and scalar binders before allocation or result effects.","pass_condition":"All invalid cases fault with unchanged source and capacity; widening capacity failure follows allocation faults.","related_sources":["asl/block/model/dispatch/lea-schema.asl","asl/block/model/dispatch/descriptor-legality.asl","asl/block/model/dispatch/destination-operation.asl"]}
pure func LEAStart(source_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '01';
    instruction[24:20] = '01110';
    instruction[31:27] = TileDataTypeToEncoding(source_type);
    return instruction;
end;

func LEAReject(element_bits: Word, source_type: TileDataType,
    selected_type: TileDataType, bind_scalar: boolean,
    unused_selector: Reg5Selector)
begin
    ResetProfileState();
    ConfigureTile(1, 128, 16, 2, 1, 2, source_type, TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 9);
    WriteGPR(2, element_bits);
    let capacity_before = CoreTileCapacityInUse();
    let started = ExecuteCommandInstruction(LEAStart(selected_type), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(TRUE, 0, 1, '0001', TRUE, FALSE, 1, 0, TRUE);
    if bind_scalar then
        SetBundleScalarBinding(0, 0, 2, unused_selector, 0, 3);
    end;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == (if unused_selector != 0 then
        Fault_BundleControl else Fault_TileLegality);
    assert CoreTileCapacityInUse() == capacity_before;
    assert _Tiles[[1]].data_type == source_type;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 7;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
end;

func main() => integer
begin
    LEAReject(Zeros{PTO_XLEN} + 4, TileDataType_U32, TileDataType_U32, TRUE, 0);
    LEAReject(Zeros{PTO_XLEN}, TileDataType_U32, TileDataType_U32, TRUE, 0);
    LEAReject(Zeros{PTO_XLEN} + 128, TileDataType_U32, TileDataType_U32, TRUE, 0);
    LEAReject(Zeros{PTO_XLEN} + 32, TileDataType_U32, TileDataType_U32, FALSE, 0);
    LEAReject(Zeros{PTO_XLEN} + 32, TileDataType_U32, TileDataType_U32, TRUE, 3);
    LEAReject(Zeros{PTO_XLEN} + 32, TileDataType_U32, TileDataType_S32, TRUE, 0);
    LEAReject(Zeros{PTO_XLEN} + 32, TileDataType_S32, TileDataType_S16, TRUE, 0);
    ResetProfileState();
    ConfigureTile(1, 128, 1, 32, 1, 32, TileDataType_U32, TileLayout_RowMajor);
    for column = 0 to 31 do
        WriteTileElement(1, 0, column as integer {0..65535}, Zeros{PTO_XLEN} + 1);
    end;
    WriteGPR(2, Zeros{PTO_XLEN} + 32);
    let started = ExecuteCommandInstruction(LEAStart(TileDataType_U32), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 32);
    AddBundleTileBinding(TRUE, 0, 1, '0001', TRUE, FALSE, 1, 0, TRUE);
    SetBundleScalarBinding(0, 0, 2, 0, 0, 3);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileAllocation;
    assert CoreTileCapacityInUse() == 128;
    return 0;
end;
