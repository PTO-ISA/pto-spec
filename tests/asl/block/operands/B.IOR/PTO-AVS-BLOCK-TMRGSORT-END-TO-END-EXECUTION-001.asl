// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMRGSORT-END-TO-END-EXECUTION-001","source":"asl/block/operands/B.IOR.asl","requirements":["PTO-INST-BLOCK-B-IOR","PTO-INST-TILE-TMRGSORT"],"kind":"execution","summary":"decoded BSTART/B.IOR/B.IOT/BSTOP execution for TMRGSORT direction and ties","pass_condition":"TestBundleTMRGSortEndToEnd completes without assertion failure","related_sources":[]}

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
    let tie_left_ascending = TileProfileOrderLeft(Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 1, FALSE, TileDataType_U64);
    let tie_left_descending = TileProfileOrderLeft(Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 1, TRUE, TileDataType_U64);
    assert tie_left_ascending;
    assert tie_left_descending;
    // Both direction cases use sources pre-sorted in the selected direction;
    // equal keys are supplied by the left source first.
    for descending = 0 to 1 do
        ResetProfileState();
        ConfigureTile(16, 128, 1, 2, 1, 2, TileDataType_U64,
            TileLayout_RowMajor, TileLocation_Any);
        ConfigureTile(17, 128, 1, 2, 1, 2, TileDataType_U64,
            TileLayout_RowMajor, TileLocation_Any);
        WriteTileElement(16, 0, 0, if descending == 0 then
            Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN} + 3);
        WriteTileElement(16, 0, 1, if descending == 0 then
            Zeros{PTO_XLEN} + 3 else Zeros{PTO_XLEN} + 1);
        WriteTileElement(17, 0, 0, if descending == 0 then
            Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN} + 2);
        WriteTileElement(17, 0, 1, if descending == 0 then
            Zeros{PTO_XLEN} + 2 else Zeros{PTO_XLEN} + 1);
        let start = ExecuteCommandInstruction(
            BundleTestTEPLStart(Zeros{10} + 0x06d, Zeros{5} + 24), 32);
        SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
        // TMRGSORT's four-column destination must be explicitly described by
        // LB2; otherwise destination physical columns fall back to the first
        // source's two-column shape and BSTOP rejects the allocation.
        SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
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
        assert _Tiles[[16]].data_type == TileDataType_U64;
        assert _Tiles[[17]].data_type == TileDataType_U64;
        assert BundleOperationGPRBindingValuesLegal(tmrg_operation);
        assert SelectedBundleTileMasksLegal();
        let stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
        assert start == CommandExecution_Executed;
        assert left == CommandExecution_Executed;
        assert right == CommandExecution_Executed;
        assert ior == CommandExecution_Executed;
        assert stop == CommandExecution_Executed;
        assert ReadTileElement(0, 0, 0) ==
            (if descending == 0 then Zeros{PTO_XLEN} + 1
             else Zeros{PTO_XLEN} + 3);
        assert ReadTileElement(0, 0, 1) ==
            (if descending == 0 then Zeros{PTO_XLEN} + 1
             else Zeros{PTO_XLEN} + 2);
        assert ReadTileElement(0, 0, 2) ==
            (if descending == 0 then Zeros{PTO_XLEN} + 2
             else Zeros{PTO_XLEN} + 1);
        assert ReadTileElement(0, 0, 3) ==
            (if descending == 0 then Zeros{PTO_XLEN} + 3
             else Zeros{PTO_XLEN} + 1);
    end;
end;

func main() => integer
begin
    ResetProfileState();
    TestBundleTMRGSortEndToEnd();
    return 0;
end;
