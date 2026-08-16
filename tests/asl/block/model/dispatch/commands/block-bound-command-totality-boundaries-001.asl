// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTBUNDLECOMMANDTOTALITYBOUNDARIES-BOUNDARY-001","source":"asl/block/model/dispatch/commands.asl","requirements":[],"kind":"boundary","summary":"Covers Bundle Command Totality Boundaries.","pass_condition":"TestBundleCommandTotalityBoundaries completes without assertion failure","related_sources":[]}
readonly func FirstCommandFormWithHandler(handler: CommandSemanticHandler)
    => integer {0..PTO_COMMAND_FORM_COUNT-1}
begin
    var selected: integer {0..PTO_COMMAND_FORM_COUNT-1} = 0;
    var found = FALSE;
    for form = 0 to PTO_COMMAND_FORM_COUNT - 1 do
        if !found &&
           CommandHandlerOfForm(
               form as integer {0..PTO_COMMAND_FORM_COUNT-1}) == handler then
            selected = form as integer {0..PTO_COMMAND_FORM_COUNT-1};
            found = TRUE;
        end;
    end;
    assert found;
    return selected;
end;

func TestBundleCommandTotalityBoundaries()
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    let memory_copy_form =
        FirstCommandFormWithHandler(CommandHandler_ExecuteMemoryCopy);
    let memory_command_status = ExecuteDecodedBundleCommand(
        Zeros{64}, memory_copy_form, 32);
    assert memory_command_status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x204;

    ResetProfileState();
    WriteMemoryByte(Zeros{PTO_XLEN} + 8, Zeros{8} + 0x11);
    WriteMemoryByte(Zeros{PTO_XLEN} + 9, Zeros{8} + 0x22);
    WriteMemoryByte(Zeros{PTO_XLEN} + 10, Zeros{8} + 0x33);
    ExecuteMemoryCopyTemplate(Zeros{PTO_XLEN} + 16,
        Zeros{PTO_XLEN} + 8, Zeros{PTO_XLEN} + 3);
    assert _LastFault == Fault_None;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 16) == Zeros{8} + 0x11;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 17) == Zeros{8} + 0x22;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 18) == Zeros{8} + 0x33;
    ExecuteMemoryCopyTemplate(Zeros{PTO_XLEN} + 128,
        Zeros{PTO_XLEN} + 8, Zeros{PTO_XLEN} + 64);
    assert _LastFault == Fault_None;
    assert _LastMemoryCommandAddress == Zeros{PTO_XLEN} + 128;
    assert _LastMemoryCommandSize == Zeros{PTO_XLEN} + 64;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 128) == Zeros{8} + 0x11;

    // The decoded MSET path applies the same full-XLEN bound and does not
    // reduce 64 to zero through a low-bit surrogate.
    ResetProfileState();
    WriteGPR(2, Zeros{PTO_XLEN} + 0x80);
    WriteGPR(3, Zeros{PTO_XLEN} + 0xa5);
    WriteGPR(4, Zeros{PTO_XLEN} + 64);
    WriteTPC(Zeros{PTO_XLEN} + 0x280);
    var oversized_mset: bits(64) = Zeros{64} + 0x00002031;
    oversized_mset[19:15] = Zeros{5} + 2;
    oversized_mset[24:20] = Zeros{5} + 3;
    oversized_mset[31:27] = Zeros{5} + 4;
    let oversized_mset_status = ExecuteCommandInstruction(oversized_mset, 32);
    assert oversized_mset_status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x280;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 0x80) == Zeros{8};

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    let hint_block =
        ExecuteCommandInstruction(Zeros{64} + 0x00011181, 32);
    assert hint_block == CommandExecution_Executed;
    let hint_instruction = Ones{64};
    let hint_form =
        FirstCommandFormWithHandler(CommandHandler_SetBundleHint);
    let hint_status =
        ExecuteDecodedBundleCommand(hint_instruction, hint_form, 32);
    assert hint_status == CommandExecution_Executed;
    assert _LastBundleHintPayload == hint_instruction;
    assert _BundleHintEpoch == 1;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x308;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleCommandTotalityBoundaries();
    return 0;
end;
