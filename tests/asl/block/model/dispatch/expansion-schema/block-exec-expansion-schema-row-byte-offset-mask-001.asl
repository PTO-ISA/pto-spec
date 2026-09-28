// PTO-TEST: {"id":"PTO-AVS-BLOCK-ROW-EXPAND-BROADCAST-BYTE-OFFSET-R2-MASK-001","source":"asl/block/model/dispatch/expansion-schema.asl","requirements":["PTO-TROWEXPAND-CONTRACT-001","PTO-TROWEXPANDDIV-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-DATR-FIELDS-001","PTO-B-IOR-BINDING-001"],"kind":"execution","summary":"Selected row-broadcast slots remain qualified by ExecutionMask and independent of PredInv/Zero, including integer DIV zero preflight.","pass_condition":"An inactive undefined selected row succeeds under Predicate-GPR ExecutionMask, an active undefined selected row faults before destination allocation, PredInv selects the complementary defined row while Zero fills the inactive row, and DIV validates and divides by the selected slot only for active outputs.","related_sources":["asl/block/model/dispatch/execution-mask-schema.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/expansion.asl"]}

pure func RowExpandStart(data_type: TileDataType,
                         function: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '10';
    instruction[24:20] = function;
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func RowExpandAttributes(data_type: bits(5), layout: bits(5),
                               byte_offset: bits(3), pred_inv: boolean,
                               zero: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = data_type;
    instruction[17:15] = byte_offset;
    instruction[14] = if pred_inv then '1' else '0';
    instruction[13] = if zero then '1' else '0';
    instruction[11:7] = layout;
    return instruction;
end;

pure func RowExpandIOR(register: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = register;
    instruction[26] = '1';
    return instruction;
end;

pure func RowExpandBinaryBinding(source0: bits(6), source1: bits(6))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[25:20] = source0;
    instruction[31:26] = source1;
    instruction[19] = '1';
    instruction[18:15] = '0010';
    instruction[11:9] = '001';
    return instruction;
end;

pure func RowExpandCopyBinding(source: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = source;
    instruction[19] = '1';
    instruction[18:15] = '0010';
    instruction[11:9] = '001';
    return instruction;
end;

pure func RowExpandPredicateCopyBinding(source: bits(6), mask: bits(6))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[25:20] = source;
    instruction[31:26] = mask;
    instruction[19] = '1';
    instruction[18:15] = '0010';
    instruction[11:9] = '001';
    return instruction;
end;

func RunMaskedCopy(predicate_row: integer {0..1}, pred_inv: boolean,
                   row0_defined: boolean, row1_defined: boolean,
                   expect_complete: boolean)
begin
    ResetProfileState();
    let broadcast_ready = ConfigureCubeTile(1, 256, 2, 2,
        TileDataType_BF16, TileLayout_CUBE_M16);
    let mask_ready = ConfigurePredicateCell(12, 256, 2, 2,
        TileDataType_BF16, TileLayout_CUBE_M16);
    assert broadcast_ready && mask_ready;
    InstallRelativeTileFixture(12, 12);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 1 looplimit 2 do
            WriteTileElement(12, row, column,
                if row == predicate_row then
                    Zeros{PTO_XLEN} + 1
                else Zeros{PTO_XLEN});
        end;
    end;
    MarkTileValidRegionDefined(12);
    if row0_defined then
        WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x4001);
    end;
    if row1_defined then
        WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 0x4041);
    end;
    let started = ExecuteCommandInstruction(
        RowExpandStart(TileDataType_BF16, '00100'), 32);
    let attributed = ExecuteCommandInstruction(
        RowExpandAttributes(DTYPE_NONE, Zeros{5} + 31,
            Zeros{3} + 2, pred_inv, TRUE), 32);
    assert started == CommandExecution_Executed &&
           attributed == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let binding = ExecuteCommandInstruction(
        RowExpandPredicateCopyBinding(Zeros{6} + 1, Zeros{6} + 12), 32);
    assert binding == CommandExecution_Executed;
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x044)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let completed = ExecuteBundleTileOperation();
    assert completed == expect_complete;
    if expect_complete then
        assert _LastFault == Fault_None;
        let destination = _BundleTileBindings[[0]].destination;
        if pred_inv then
            assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN};
            assert ReadTileElement(destination, 1, 1) ==
                Zeros{PTO_XLEN} + 0x4041;
        else
            assert ReadTileElement(destination, 0, 0) ==
                Zeros{PTO_XLEN} + 0x4001;
            assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN};
        end;
        assert _Tiles[[1]].data_type == TileDataType_BF16;
        assert NumericStatusFlags() == Zeros{5};
    else
        assert _LastFault == Fault_TileLegality;
        assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    end;
end;

func RunMaskedSelectedDivision(selected_zero: boolean)
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(1, 256, 2, 2,
        TileDataType_U16, TileLayout_CUBE_M16);
    let broadcast_ready = ConfigureCubeTile(2, 256, 2, 2,
        TileDataType_U16, TileLayout_CUBE_M16);
    assert source_ready && broadcast_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 8);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 1,
        if selected_zero then Zeros{PTO_XLEN}
        else Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 9);
    WriteTileElement(2, 1, 1, Zeros{PTO_XLEN});
    var execution_mask = Zeros{PTO_XLEN};
    execution_mask[0] = '1';
    WritePEGPR(0, 2, execution_mask);
    let started = ExecuteCommandInstruction(
        RowExpandStart(TileDataType_U16, '01000'), 32);
    let attributed = ExecuteCommandInstruction(
        RowExpandAttributes(DTYPE_NONE, Zeros{5} + 31,
            Zeros{3} + 2, FALSE, TRUE), 32);
    assert started == CommandExecution_Executed &&
           attributed == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let execution_mask_command = ExecuteCommandInstruction(
        RowExpandIOR(Zeros{5} + 2), 32);
    let binding = ExecuteCommandInstruction(
        RowExpandBinaryBinding(Zeros{6} + 1, Zeros{6} + 2), 32);
    assert execution_mask_command == CommandExecution_Executed &&
           binding == CommandExecution_Executed;
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x048)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed == !selected_zero;
    if selected_zero then
        assert _LastFault == Fault_TileLegality;
        assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    else
        assert _LastFault == Fault_None;
        let destination = _BundleTileBindings[[0]].destination;
        assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 2;
        assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
        assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN};
        assert NumericStatusFlags() == Zeros{5};
    end;
end;

func main() => integer
begin
    // Predicate row zero is active.  Row one leaves the selected slot
    // undefined; it is not read or validated.
    RunMaskedCopy(0, FALSE, TRUE, FALSE, TRUE);
    // Inverting a row-uniform PredicateCell makes row one active; define only
    // its selected slot and verify Zero fills the inactive row.
    RunMaskedCopy(0, TRUE, FALSE, TRUE, TRUE);
    // The selected undefined element faults when row one is active.
    RunMaskedCopy(1, FALSE, TRUE, FALSE, FALSE);
    RunMaskedSelectedDivision(FALSE);
    RunMaskedSelectedDivision(TRUE);
    return 0;
end;
