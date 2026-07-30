func TestBlockStateLifecycle()
begin
    ResetBlockControlState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    ClearFault();
    BeginBlock(BlockKind_Standard, BlockTransfer_Direct,
        Zeros{PTO_XLEN} + 0x200, Zeros{PTO_XLEN} + 0x104,
        Zeros{PTO_XLEN} + 0x104, TRUE);
    assert _LastFault == Fault_None;
    assert BlockIsActive();
    assert !BlockBodyIsActive();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x200;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x200;

    EnterBlockBody();
    assert _LastFault == Fault_None;
    assert BlockBodyIsActive();

    StopBlock();
    assert _LastFault == Fault_None;
    assert !BlockIsActive();
    assert !BlockBodyIsActive();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;
end;

func TestBlockFaults()
begin
    ResetBlockControlState();
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    ClearFault();
    StopBlock();
    assert _LastFault == Fault_BlockControl;
    assert _ACRTrapNumber[[CurrentACR()]] == Zeros{6} + 6;

    ResetBlockControlState();
    ClearFault();
    BeginBlock(BlockKind_Standard, BlockTransfer_Direct,
        Zeros{PTO_XLEN} + 0x401, Zeros{PTO_XLEN} + 0x304,
        Zeros{PTO_XLEN} + 0x304, TRUE);
    assert _LastFault == Fault_InstructionPC;
    assert !BlockIsActive();
end;

func TestTrapContextRouteAndRecover()
begin
    ResetBlockControlState();
    ClearFault();
    SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f01, Zeros{PTO_XLEN} + 0x900);

    SetCurrentACR(2);
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    WriteBPC(Zeros{PTO_XLEN} + 0x340);
    SetBlockArgument(Zeros{PTO_XLEN} + 0x55);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x11);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0x22);
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xacc);
    _Accumulator.live = TRUE;
    _Accumulator.info = _Tiles[[0]];
    BeginBlock(BlockKind_Standard, BlockTransfer_Direct,
        Zeros{PTO_XLEN} + 0x500, Zeros{PTO_XLEN} + 0x304,
        Zeros{PTO_XLEN} + 0x304, TRUE);
    EnterBlockBody();

    SetFault(Fault_DataPage, Zeros{PTO_XLEN} + 0x2222);
    assert CurrentACR() == 1;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x900;
    assert _ACRTrapNumber[[1]] == Zeros{6} + 35;
    assert _ACRTrapArgument0[[1]] == Zeros{PTO_XLEN} + 0x2222;
    assert _TrapContexts[[1]].valid;
    assert _TrapContexts[[1]].source_acr == 2;
    assert _TrapContexts[[1]].tpc == Zeros{PTO_XLEN} + 0x500;
    assert _TrapContexts[[1]].bpc == Zeros{PTO_XLEN} + 0x500;
    assert _TrapContexts[[1]].block_argument == Zeros{PTO_XLEN} + 0x55;
    assert _TrapContexts[[1]].block_body_active;
    assert _TrapContexts[[1]].t_queue[[0]] == Zeros{PTO_XLEN} + 0x11;
    assert _TrapContexts[[1]].u_queue[[0]] == Zeros{PTO_XLEN} + 0x22;
    assert _TrapContexts[[1]].accumulator.live;
    assert _TrapContexts[[1]].accumulator.info.payload[[0]] ==
        Zeros{PTO_XLEN} + 0xacc;

    WriteTPC(Zeros{PTO_XLEN} + 0xabc);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x99);
    _Accumulator.live = FALSE;
    ArchitectureEnterRequest('0001');
    assert CurrentACR() == 2;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x500;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x500;
    assert _BlockArgument == Zeros{PTO_XLEN} + 0x55;
    assert _CommitArgument == Zeros{PTO_XLEN} + 0x55;
    assert BlockBodyIsActive();
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x11;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x22;
    assert _Accumulator.live;
    assert _Accumulator.info.payload[[0]] == Zeros{PTO_XLEN} + 0xacc;
    assert !_TrapContexts[[1]].valid;
    _Accumulator.live = FALSE;
    ReleaseTile(0);
end;

func TestBlockConfigurationState()
begin
    ResetBlockControlState();
    WriteGPR(2, Zeros{PTO_XLEN} + 33);
    SetBlockDimension(1, ReadScalarRegisterOperand(2) + (Zeros{PTO_XLEN} + 7));
    assert _BlockDimensions[[1]] == Zeros{PTO_XLEN} + 40;

    SetBlockScalarBinding(0, 5, 2, 3, 4, 3);
    assert _BlockScalarBindings[[0]].valid;
    assert _BlockScalarBindings[[0]].destination == 5;
    assert _BlockScalarBindings[[0]].source2 == 4;

    SetBlockTileBinding(0, TRUE, 2, 8, TRUE, TRUE, 10, 11,
        TRUE, FALSE, TRUE);
    assert _BlockTileBindings[[0]].valid;
    assert _BlockTileBindings[[0]].destination_valid;
    assert _BlockTileBindings[[0]].destination == 2;
    assert _BlockTileBindings[[0]].source0 == 10;
    assert _BlockTileBindings[[0]].source0_reuse;
    assert _BlockTileBindings[[0]].last;
    assert BlockTileDestinationSizeBytes(0) == 4096;

    ClearFault();
    SetBlockTileBinding(0, TRUE, 4, 8, FALSE, FALSE, 0, 0,
        FALSE, FALSE, TRUE);
    assert _LastFault == Fault_TileLegality;

    ConfigureTile(10, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(11, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ClearFault();
    SetBlockTileBinding(0, FALSE, 0, 0, TRUE, TRUE, 10, 11,
        FALSE, TRUE, TRUE);
    FinalizeBlockTileAttempt(TileExecution_Faulted);
    assert _Tiles[[10]].allocated;
    assert _Tiles[[11]].allocated;
    FinalizeBlockTileAttempt(TileExecution_Executed);
    assert !_Tiles[[10]].allocated;
    assert _Tiles[[11]].allocated;
    ReleaseTile(11);
end;

func TestDecodedBlockStartAndStop()
begin
    ResetBlockControlState();
    ClearFault();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    var direct: bits(64) = Zeros{64} + 0x00000011;
    direct[31:7] = Zeros{25} + 4;
    let direct_status = ExecuteCommandInstruction(direct, 32);
    assert direct_status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert BlockIsActive();
    assert _BlockTransfer == BlockTransfer_Direct;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x108;

    var stop: bits(64) = Zeros{64} + 0x00000001;
    let stop_status = ExecuteCommandInstruction(stop, 32);
    assert stop_status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert !BlockIsActive();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;

    ResetBlockControlState();
    ClearFault();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    ExecuteSetCommit(ScalarCondition_EQ, Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 1);
    var conditional: bits(64) = Zeros{64} + 0x00000021;
    conditional[31:7] = Zeros{25} + 4;
    let conditional_status = ExecuteCommandInstruction(conditional, 32);
    assert conditional_status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert !BlockIsActive();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x204;

    ResetBlockControlState();
    ClearFault();
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    var call: bits(64) = Zeros{64} + 0x50160002;
    call[15:4] = Zeros{12} + 4;
    call[26:22] = Zeros{5} + 3;
    let call_status = ExecuteCommandInstruction(call, 32);
    assert call_status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert _BlockTransfer == BlockTransfer_Call;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x308;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0x308;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x308;
end;

// A decoded B.IOT descriptor and decoded BSTART.TEPL selector converge on the
// same generated execution boundary used by direct Tile dispatch.
func TestDecodedBlockTileExecutionBridge()
begin
    ResetProfileState();
    ResetBlockControlState();
    ClearFault();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 11);

    let iot_status = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x0409cd13, 32);
    assert iot_status == CommandExecution_Executed;
    assert _BlockTileBindings[[0]].valid;
    assert _BlockTileBindings[[0]].destination == 2;
    assert _BlockTileBindings[[0]].source0 == 0;
    assert _BlockTileBindings[[0]].source1 == 1;

    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    let bstart_status = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xc0019181, 32);
    assert bstart_status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert BlockTileOperationSelected();
    assert _BlockTileOperation.family == '00';
    assert _BlockTileOperation.code == Zeros{12};
    assert _BlockTileOperation.data_type == Zeros{5} + 24;
    assert _BlockTileBindings[[0]].destination == 32;
    assert _BlockTileBindings[[0]].destination_allocated_by_block;
    assert _Tiles[[32]].capacity_bytes == 128;
    assert ReadTileElement(32, 0, 0) == Zeros{PTO_XLEN} + 18;
    assert _Tiles[[0]].allocated;
    assert _Tiles[[1]].allocated;
    ReleaseTile(0);
    ReleaseTile(1);
    ReleaseTile(32);
end;

// Generated DATR applicability is enforced at the decoded BSTART boundary.
// The zero-valued TADD case above is legal; a non-zero shared pad/byte field is
// not applicable to TADD and must fault before its hand destination is claimed.
func TestDecodedBlockDATRApplicability()
begin
    assert TileOperationDATRPadUnion(85) == TileDATRPadUnion_PadValue;
    assert TileOperationDATRPadUnion(91) == TileDATRPadUnion_PadValue;
    assert TileOperationDATRPadUnion(109) ==
        TileDATRPadUnion_HistogramByteId;
    assert TileOperationDATRFieldsLegal(85, Zeros{3}, '11', FALSE,
        FALSE, Zeros{5}, Zeros{3}, Zeros{5});
    assert TileOperationDATRFieldsLegal(109, Zeros{3}, '10', FALSE,
        FALSE, Zeros{5}, Zeros{3}, Zeros{5});
    assert !TileOperationDATRFieldsLegal(0, Zeros{3}, '01', FALSE,
        FALSE, Zeros{5}, Zeros{3}, Zeros{5});

    // Positive decoded path: the same non-zero union field is PadValue for
    // TFILLPAD (TEPL selector 0x065), so BSTART may allocate and execute.
    ResetProfileState();
    ResetBlockControlState();
    ClearFault();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 11);
    let positive_datr_status = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x08001023, 32);
    assert positive_datr_status == CommandExecution_Executed;
    let positive_iot_status = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x0409cd13, 32);
    assert positive_iot_status == CommandExecution_Executed;
    WriteTPC(Zeros{PTO_XLEN} + 0x440);
    let positive_bstart_status = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xc6519181, 32);
    assert positive_bstart_status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert _BlockTileOperation.code == '000001100101';
    assert _BlockTileBindings[[0]].destination == 32;
    assert _BlockTileBindings[[0]].destination_allocated_by_block;
    assert ReadTileElement(32, 0, 0) == Zeros{PTO_XLEN} + 7;
    ReleaseTile(0);
    ReleaseTile(1);
    ReleaseTile(32);

    // Negative decoded path: PadValueOrByteId is must-zero for TADD.
    ResetProfileState();
    ResetBlockControlState();
    ClearFault();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 11);

    // B.DATR with PadValueOrByteId=1; all other fields remain zero.
    let datr_status = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x08001023, 32);
    assert datr_status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert _BlockDataAttributes.pad_value == '01';

    let iot_status = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x0409cd13, 32);
    assert iot_status == CommandExecution_Executed;
    assert !_Tiles[[32]].allocated;

    WriteTPC(Zeros{PTO_XLEN} + 0x480);
    let bstart_status = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xc0019181, 32);
    assert bstart_status == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[32]].allocated;
    assert !_BlockTileBindings[[0]].destination_allocated_by_block;
    assert _BlockTileBindings[[0]].destination == 2;
    assert _Tiles[[0]].allocated;
    assert _Tiles[[1]].allocated;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 11;
    ReleaseTile(0);
    ReleaseTile(1);
end;

func TestBlockTileAllocationFaultPreservesSources()
begin
    ResetProfileState();
    ResetBlockControlState();
    ClearFault();
    ConfigureTile(10, PTO_TILE_CAPACITY_BYTES, 1, 1, 1, 1,
        TileDataType_U64, TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 0x5a);
    SetBlockTileBinding(0, TRUE, 1, 3, TRUE, FALSE, 10, 0,
        FALSE, FALSE, TRUE);
    SetBlockTileOperationSelection('00', '000000001100',
        Zeros{5} + 24);
    let status = ExecuteSelectedBlockTileOperation();
    assert status == TileExecution_Faulted;
    assert _LastFault == Fault_TileAllocation;
    assert _Tiles[[10]].allocated;
    assert ReadTileElement(10, 0, 0) == Zeros{PTO_XLEN} + 0x5a;
    assert _BlockTileBindings[[0]].destination == 1;
    assert !_BlockTileBindings[[0]].destination_allocated_by_block;
    ReleaseTile(10);
end;
