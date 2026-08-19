// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-E8M0-PAIRS-005","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"fault","summary":"The hardware profile accepts only FP16, BF16, and FP32 sources for an E8M0 destination.","pass_condition":"All three assigned source pairs pass operand preflight while FP64, compact, integer, and E8M0 sources reject before destination effects.","related_sources":["asl/tile/model/legality/operand-schema.asl","asl/arch/data-types/formats/e8m0.asl"]}
func PairLegal(source_type: TileDataType) => boolean
begin
    ResetProfileState();
    let source_capacity = TileStorageBytes(16, 8, source_type)
        as integer {0..262144};
    ConfigureTile(0, source_capacity, 16, 8, 1, 1, source_type,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 16, 8, 1, 1, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    return TileOperandsLegal_TCVT(
        1, 0, DefaultNumericExecutionControl());
end;

func main() => integer
begin
    let fp16 = PairLegal(TileDataType_FP16);
    let bf16 = PairLegal(TileDataType_BF16);
    let fp32 = PairLegal(TileDataType_FP32);
    let fp64 = PairLegal(TileDataType_FP64);
    let e4m3 = PairLegal(TileDataType_E4M3);
    let s32 = PairLegal(TileDataType_S32);
    let e8m0 = PairLegal(TileDataType_E8M0);
    assert fp16;
    assert bf16;
    assert fp32;
    assert !fp64;
    assert !e4m3;
    assert !s32;
    assert !e8m0;

    ResetProfileState();
    ConfigureTile(0, 1024, 16, 8, 1, 1, TileDataType_FP64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3ff0000000000000);
    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x01b19181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 13,
        Zeros{5},
        '11',
        Zeros{3},
        Zeros{3},
        FALSE,
        FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 8);
    AddBundleTileBinding(
        TRUE, 0, 1, '0001', TRUE, FALSE, 0, 0, TRUE);
    let capacity_before = CoreTileCapacityInUse();
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert CoreTileCapacityInUse() == capacity_before;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    return 0;
end;
