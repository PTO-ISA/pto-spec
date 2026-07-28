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

    WriteTPC(Zeros{PTO_XLEN} + 0xabc);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x99);
    ArchitectureEnterRequest('0001');
    assert CurrentACR() == 2;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x500;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x500;
    assert _BlockArgument == Zeros{PTO_XLEN} + 0x55;
    assert _CommitArgument == Zeros{PTO_XLEN} + 0x55;
    assert BlockBodyIsActive();
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x11;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x22;
    assert !_TrapContexts[[1]].valid;
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

    SetBlockTileBinding(0, TRUE, 6, 8, TRUE, TRUE, 10, 11,
        TRUE, FALSE, TRUE);
    assert _BlockTileBindings[[0]].valid;
    assert _BlockTileBindings[[0]].destination_valid;
    assert _BlockTileBindings[[0]].destination == 6;
    assert _BlockTileBindings[[0]].source0 == 10;
    assert _BlockTileBindings[[0]].source0_reuse;
    assert _BlockTileBindings[[0]].last;
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
end;
