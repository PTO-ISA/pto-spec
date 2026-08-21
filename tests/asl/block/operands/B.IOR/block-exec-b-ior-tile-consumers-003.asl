// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOR-TILE-CONSUMERS-EXEC-003","source":"asl/block/operands/B.IOR.asl","requirements":["PTO-INST-BLOCK-B-IOR","PTO-INST-TILE-TCI","PTO-INST-TILE-TTRI","PTO-INST-TILE-TSORT","PTO-INST-TILE-TMRGSORT"],"kind":"execution","summary":"B.IOR bindings drive direct Tile consumers end to end","pass_condition":"B.IOR Tile consumer assertions hold","related_sources":[]}
pure func BundleTestTEPLStart(selector: bits(10), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BundleTestScalarBinding(destination: bits(5), source0: bits(5),
                                  source1: bits(5), source2: bits(5))
                                  => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[11:7] = destination;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    instruction[31:27] = source2;
    return instruction;
end;

pure func BundleTestTileDestination(size_code: bits(4), destination: bits(2),
                                    pe_mode: bits(3), last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[8:7] = destination;
    instruction[11:9] = pe_mode;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

pure func BundleTestTileSourceDestination(size_code: bits(4), destination: bits(2),
                                          pe_mode: bits(3), source: bits(6),
                                          last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[18:15] = size_code;
    instruction[8:7] = destination;
    instruction[11:9] = pe_mode;
    instruction[25:20] = source;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

func TestBundleOrderedGPRControlsEndToEnd()
begin
    // TCI executes the complete decoded BSTART/B.IOT/B.IOR/BSTOP path. The
    // B.IOR logical order is scalar0(RegSrc0), flag0(RegSrc1).
    ResetProfileState();
    let tci_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10} + 0x066, Zeros{5} + 25), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    WriteGPR(2, Zeros{PTO_XLEN} + 5);
    WriteGPR(3, Zeros{PTO_XLEN} + 1);
    let tci_destination = ExecuteCommandInstruction(
        BundleTestTileDestination('0001', '00', '111', TRUE), 32);
    let tci_ior = ExecuteCommandInstruction(
        BundleTestScalarBinding(Zeros{5}, Zeros{5} + 2,
            Zeros{5} + 3, Zeros{5}), 32);
    let tci_stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert tci_start == CommandExecution_Executed;
    assert tci_destination == CommandExecution_Executed;
    assert tci_ior == CommandExecution_Executed;
    assert tci_stop == CommandExecution_Executed;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(0, 0, 3) == Zeros{PTO_XLEN} + 2;

    // Omission and encoded zero are distinct: omission uses ascending start 0,
    // while an explicit zero selector binds the same value as R0.
    ResetProfileState();
    let omitted_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10} + 0x066, Zeros{5} + 25), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    let omitted_destination = ExecuteCommandInstruction(BundleTestTileDestination(
        '0001', '00', '111', TRUE), 32);
    let omitted_stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert omitted_stop == CommandExecution_Executed;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 1;

    ResetProfileState();
    let zero_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10} + 0x066, Zeros{5} + 25), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    let zero_destination = ExecuteCommandInstruction(BundleTestTileDestination(
        '0001', '00', '111', TRUE), 32);
    let zero_ior = ExecuteCommandInstruction(BundleTestScalarBinding(
        Zeros{5}, Zeros{5}, Zeros{5}, Zeros{5}), 32);
    let zero_stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert zero_stop == CommandExecution_Executed;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 1;

    // TTRI validates signed diagonal and raw boolean at BSTOP before any
    // destination allocation or mutation.
    ResetProfileState();
    ConfigureTile(0, 128, 2, 2, 2, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 99);
    let ttri_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10} + 0x067, Zeros{5} + 24), 32);
    let ttri_destination = ExecuteCommandInstruction(BundleTestTileDestination(
        '0001', '00', '111', TRUE), 32);
    WriteGPR(4, Zeros{PTO_XLEN} + 65536);
    WriteGPR(5, Zeros{PTO_XLEN} + 1);
    let ttri_ior = ExecuteCommandInstruction(BundleTestScalarBinding(
        Zeros{5}, Zeros{5} + 4, Zeros{5} + 5, Zeros{5}), 32);
    let ttri_stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert ttri_stop == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 99;
    assert !_Tiles[[1]].allocated;

    // Both diagonal overflow directions and raw boolean 2 are rejected.
    for overflow = 0 to 1 do
        ResetProfileState();
        let overflow_start = ExecuteCommandInstruction(
            BundleTestTEPLStart(Zeros{10} + 0x067, Zeros{5} + 24), 32);
        let overflow_destination = ExecuteCommandInstruction(BundleTestTileDestination(
            '0001', '00', '111', TRUE), 32);
        WriteGPR(4, if overflow == 0 then
            Zeros{PTO_XLEN} + 65536 else Ones{PTO_XLEN} - 65535);
        WriteGPR(5, Zeros{PTO_XLEN} + 1);
        let overflow_ior = ExecuteCommandInstruction(BundleTestScalarBinding(
            Zeros{5}, Zeros{5} + 4, Zeros{5} + 5, Zeros{5}), 32);
        let overflow_stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
        assert overflow_stop == CommandExecution_Rejected;
        assert _LastFault == Fault_TileLegality;
    end;
    ResetProfileState();
    let bool_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10} + 0x066, Zeros{5} + 25), 32);
    let bool_destination = ExecuteCommandInstruction(BundleTestTileDestination(
        '0001', '00', '111', TRUE), 32);
    WriteGPR(2, Zeros{PTO_XLEN} + 5);
    WriteGPR(3, Zeros{PTO_XLEN} + 2);
    let bool_ior = ExecuteCommandInstruction(BundleTestScalarBinding(
        Zeros{5}, Zeros{5} + 2, Zeros{5} + 3, Zeros{5}), 32);
    let bool_stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert bool_stop == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[0]].allocated;

    // TSORT runs through BSTOP in both directions and retains stable ties.
    for descending = 0 to 1 do
        ResetProfileState();
        ConfigureTile(16, 128, 1, 4, 1, 4, TileDataType_FP32,
            TileLayout_RowMajor, TileLocation_Any);
        WriteTileElement(16, 0, 0, Zeros{PTO_XLEN} + 0x40000000);
        WriteTileElement(16, 0, 1, Zeros{PTO_XLEN} + 0x3f800000);
        WriteTileElement(16, 0, 2, Zeros{PTO_XLEN} + 0x40000000);
        WriteTileElement(16, 0, 3, Zeros{PTO_XLEN});
        let sort_start = ExecuteCommandInstruction(
            BundleTestTEPLStart(Zeros{10} + 0x06c, Zeros{5} + 1), 32);
        SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
        let sort_source = ExecuteCommandInstruction(BundleTestTileSourceDestination(
            '0001', '00', '111', Zeros{6} + 16, FALSE), 32);
        let sort_destination = ExecuteCommandInstruction(BundleTestTileDestination(
            '0001', '00', '111', TRUE), 32);
        WriteGPR(6, Zeros{PTO_XLEN} + descending);
        let sort_ior = ExecuteCommandInstruction(BundleTestScalarBinding(
            Zeros{5}, Zeros{5} + 6, Zeros{5}, Zeros{5}), 32);
        let sort_stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
        assert sort_stop == CommandExecution_Executed;
        let first = if descending == 0 then Zeros{PTO_XLEN}
                    else Zeros{PTO_XLEN} + 0x40000000;
        assert ReadTileElement(0, 0, 0) == first;
        assert ReadTileElement(0, 0, 1) ==
            (if descending == 0 then Zeros{PTO_XLEN} + 0x3f800000
             else Zeros{PTO_XLEN} + 0x40000000);
        assert ReadTileElement(1, 0, 0) ==
            (if descending == 0 then Zeros{PTO_XLEN} + 3
             else Zeros{PTO_XLEN});
    end;

    // PE_MASK=0000 exits before raw GPR reads/validation/allocation.
    ResetProfileState();
    let zero_mask_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10} + 0x066, Zeros{5} + 25), 32);
    let zero_mask_destination = ExecuteCommandInstruction(BundleTestTileDestination(
        '0001', '00', '000', TRUE), 32);
    WriteGPR(2, Zeros{PTO_XLEN} + 5);
    WriteGPR(3, Zeros{PTO_XLEN} + 2);
    let zero_mask_ior = ExecuteCommandInstruction(BundleTestScalarBinding(
        Zeros{5}, Zeros{5} + 2, Zeros{5} + 3, Zeros{5}), 32);
    let zero_mask_stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert zero_mask_stop == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert !_Tiles[[0]].allocated;

    // A second B.IOR faults at the command boundary and preserves the first.
    ResetProfileState();
    let second_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10} + 0x066, Zeros{5} + 25), 32);
    let first_ior = ExecuteCommandInstruction(BundleTestScalarBinding(
        Zeros{5}, Zeros{5} + 2, Zeros{5}, Zeros{5}), 32);
    let second_ior = ExecuteCommandInstruction(BundleTestScalarBinding(
        Zeros{5}, Zeros{5} + 3, Zeros{5}, Zeros{5}), 32);
    assert first_ior == CommandExecution_Executed;
    assert second_ior == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert _BundleScalarBindings[[0]].source0 == 2;
end;

func main() => integer
begin
    ResetProfileState();
    TestBundleOrderedGPRControlsEndToEnd();
    return 0;
end;
