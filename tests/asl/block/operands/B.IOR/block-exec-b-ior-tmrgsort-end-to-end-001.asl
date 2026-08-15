// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMRGSORT-END-TO-END-EXECUTION-001","source":"asl/block/operands/B.IOR.asl","requirements":["PTO-INST-BLOCK-B-IOR","PTO-INST-TILE-TMRGSORT"],"kind":"execution","summary":"decoded BSTART/B.IOR/B.IOT/BSTOP execution for TMRGSORT direction and ties","pass_condition":"FP32 ascending and descending bundles merge stable ties with source-derived destination shape","related_sources":["asl/block/model/dispatch/sorting-schema.asl","asl/tile/model/execution/sorting.asl"]}

pure func BundleTestTEPLStart(selector: bits(10), data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BundleTestScalarBinding(destination: bits(5), source0: bits(5),
                                  source1: bits(5), source2: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[11:7] = destination;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    instruction[31:27] = source2;
    return instruction;
end;

pure func BundleTestTileSourceDestination(size: bits(3), destination: bits(2),
                                          pe_mask: bits(4), source: bits(6),
                                          last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = size;
    instruction[8:7] = destination;
    instruction[18:15] = pe_mask;
    instruction[25:20] = source;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

pure func BundleTestTileSource(source0: bits(6), last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = source0;
    instruction[19] = if last then '1' else '0';
    instruction[18:15] = '0001';
    return instruction;
end;

func TestBundleTMRGSortEndToEnd()
begin
    // Equal keys retain the left source in either direction; the decoded
    // bundle below exercises that tie through the real BSTOP path.
    let one = Zeros{PTO_XLEN} + 0x3f800000;
    let two = Zeros{PTO_XLEN} + 0x40000000;
    let three = Zeros{PTO_XLEN} + 0x40400000;
    let tie_left_ascending = TileSortLeftBefore(
        one, one, FALSE, TileDataType_FP32);
    let tie_left_descending = TileSortLeftBefore(
        one, one, TRUE, TileDataType_FP32);
    assert tie_left_ascending;
    assert tie_left_descending;
    // Both direction cases use sources pre-sorted in the selected direction;
    // equal keys are supplied by the left source first.
    for descending = 0 to 1 do
        ResetProfileState();
        ConfigureTile(16, 128, 16, 2, 1, 2, TileDataType_FP32,
            TileLayout_RowMajor, TileLocation_Any);
        ConfigureTile(17, 128, 16, 2, 1, 2, TileDataType_FP32,
            TileLayout_RowMajor, TileLocation_Any);
        WriteTileElement(16, 0, 0, if descending == 0 then
            one else three);
        WriteTileElement(16, 0, 1, if descending == 0 then
            three else one);
        WriteTileElement(17, 0, 0, if descending == 0 then
            one else two);
        WriteTileElement(17, 0, 1, if descending == 0 then
            two else one);
        let start = ExecuteCommandInstruction(
            BundleTestTEPLStart(Zeros{10} + 0x06d, Zeros{5} + 1), 32);
        let left = ExecuteCommandInstruction(BundleTestTileSourceDestination(
            '001', '00', '0001', Zeros{6} + 16, FALSE), 32);
        let right = ExecuteCommandInstruction(BundleTestTileSource(
            Zeros{6} + 17, TRUE), 32);
        WriteGPR(6, Zeros{PTO_XLEN} + descending);
        let ior = ExecuteCommandInstruction(BundleTestScalarBinding(
            Zeros{5}, Zeros{5} + 6, Zeros{5}, Zeros{5}), 32);
        let tmrg_operation = DecodeTileOperation(
            TileDecode_TEPL, Zeros{12} + 0x06d)
            as integer {0..PTO_TILE_OPERATION_COUNT-1};
        assert BundleOperationBindingsComplete(tmrg_operation);
        assert BundleTileBindingCount() == 2;
        assert BundleLocalTileDestinationCount() == 1;
        assert BundleLocalTileSourceCount() == 2;
        assert _BundleTileBindings[[0]].destination_valid;
        assert _BundleTileBindings[[0]].source0_valid;
        assert !_BundleTileBindings[[1]].destination_valid;
        assert _BundleTileBindings[[1]].source0_valid;
        assert _BundleTileBindings[[0]].pe_mask == '0001';
        assert _BundleTileBindings[[1]].pe_mask == '0001';
        assert TileSourceContentsDefined(16);
        assert TileSourceContentsDefined(17);
        assert _Tiles[[16]].data_type == TileDataType_FP32;
        assert _Tiles[[17]].data_type == TileDataType_FP32;
        assert BundleOperationGPRBindingValuesLegal(tmrg_operation);
        assert SelectedBundleTileMasksLegal();
        let stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
        assert start == CommandExecution_Executed;
        assert left == CommandExecution_Executed;
        assert right == CommandExecution_Executed;
        assert ior == CommandExecution_Executed;
        assert stop == CommandExecution_Executed;
        assert ReadTileElement(0, 0, 0) ==
            (if descending == 0 then one else three);
        assert ReadTileElement(0, 0, 1) ==
            (if descending == 0 then one else two);
        assert ReadTileElement(0, 0, 2) ==
            (if descending == 0 then two else one);
        assert ReadTileElement(0, 0, 3) ==
            (if descending == 0 then three else one);
    end;
end;

func main() => integer
begin
    ResetProfileState();
    TestBundleTMRGSortEndToEnd();
    return 0;
end;
