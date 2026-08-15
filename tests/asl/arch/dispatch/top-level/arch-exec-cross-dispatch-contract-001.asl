// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-ARCH-TESTCROSSDISPATCHEXECUTIONCONTRACT-EXECUTION-001","source":"asl/arch/dispatch/top-level.asl","requirements":[],"kind":"execution","summary":"Covers Cross Dispatch Execution Contract.","pass_condition":"TestCrossDispatchExecutionContract completes without assertion failure","related_sources":[]}
func TestCrossDispatchExecutionContract()
begin
    // Unknown scalar encodings reject, tick exactly once, and preserve state
    // outside the synchronous trap envelope.
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    WriteGPR(2, Zeros{PTO_XLEN} + 0xaa);
    let scalar_unknown = ExecuteScalarInstruction(Zeros{48}, 32);
    assert scalar_unknown == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 1;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0xaa;
    assert _TrapContexts[[0]].valid;
    assert _TrapContexts[[0]].tpc == Zeros{PTO_XLEN} + 0x100;

    // A command-local constraint failure cannot install or clear bundle state.
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    SetBundleArgument(Zeros{PTO_XLEN} + 0x55);
    var illegal_branch_type: bits(64) = Zeros{64};
    illegal_branch_type[13:11] = '010';
    let command_illegal = ExecuteCommandInstruction(illegal_branch_type, 16);
    assert command_illegal == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 1;
    assert _BundleArgument == Zeros{PTO_XLEN} + 0x55;
    assert !_BundleOperation.valid;
    assert !BundleIsActive();

    // Unknown tile selectors and recognized operations with illegal operands
    // share rejection semantics and preserve the destination payload.
    ResetProfileState();
    ConfigureTile(2, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 99);
    var unknown_operands = DefaultTileInstructionOperands();
    unknown_operands.destination0 = 2;
    let (tile_unknown, -) = ExecuteTileInstruction(
        TileDecode_TEPL, Zeros{12} + 0x3e0, unknown_operands);
    assert tile_unknown == TileExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 99;

    ResetProfileState();
    ConfigureTile(0, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 99);
    var illegal_operands = DefaultTileInstructionOperands();
    illegal_operands.destination0 = 2;
    illegal_operands.source0 = 0;
    illegal_operands.source1 = 1;
    let (tile_illegal, -) = ExecuteTileInstruction(
        TileDecode_TEPL, Zeros{12}, illegal_operands);
    assert tile_illegal == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 99;

    // A new attempt clears only the transient fault result. The manager's
    // visible trap record survives and the valid instruction is not poisoned
    // by the previous fault.
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    SetFault(Fault_DataPage, Zeros{PTO_XLEN} + 0x2222);
    let trap_entry = ReadTPC();
    assert _ACRTrapNumber[[0]] == Zeros{6} + 35;
    assert _ACRTrapArgument0[[0]] == Zeros{PTO_XLEN} + 0x2222;
    assert _TrapContexts[[0]].valid;
    let recovered_attempt = ExecuteScalarInstruction(
        Zeros{48} + 0x00000015, 32);
    assert recovered_attempt == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert _FaultAddress == Zeros{PTO_XLEN};
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 1;
    assert ReadTPC() == trap_entry + (Zeros{PTO_XLEN} + 4);
    assert _ACRTrapNumber[[0]] == Zeros{6} + 35;
    assert _ACRTrapArgumentValid[[0]];
    assert _ACRTrapArgument0[[0]] == Zeros{PTO_XLEN} + 0x2222;
    assert _TrapContexts[[0]].valid;
end;
func main() => integer
begin
    ResetProfileState();
    TestCrossDispatchExecutionContract();
    return 0;
end;
