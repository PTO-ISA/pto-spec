// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTFRAMETEMPLATEEXECUTION-EXECUTION-001","source":"asl/block/model/lifecycle/lifetime.asl","requirements":["PTO-INST-BLOCK-FENTRY","PTO-INST-BLOCK-FEXIT","PTO-INST-BLOCK-FRET-RA","PTO-INST-BLOCK-FRET-STK"],"kind":"execution","summary":"Decoded frame commands implement the PTO-v0 frame-template layout, restore, return-source, and retirement contract.","pass_condition":"TestFrameTemplateExecution completes without assertion failure","related_sources":["asl/block/lifecycle/FENTRY.asl","asl/block/lifecycle/FEXIT.asl","asl/block/lifecycle/FRET.RA.asl","asl/block/lifecycle/FRET.STK.asl"]}
pure func FrameTestInstruction(base: bits(32), begin_reg: integer {0..31},
                               end_reg: integer {0..31}, size_units: integer {1..32767})
                               => bits(64)
begin
    var instruction: bits(64) = Zeros{64};
    instruction[31:0] = base;
    instruction[19:15] = Zeros{5} + begin_reg;
    instruction[24:20] = Zeros{5} + end_reg;
    instruction[31:25] = Zeros{7} + size_units;
    return instruction;
end;

pure func FrameTestHLCall() => bits(64)
begin
    var call: bits(64) = Zeros{64} + 0x501600000011;
    call[31:7] = Zeros{25} + 4;
    call[42:38] = Zeros{5} + 3;
    return call;
end;

func TestFrameTemplateExecution()
begin
    // FENTRY [R10~R10],16: save R10 at caller-SP-8, set SP, retire +4.
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    WriteGPR(1, Zeros{PTO_XLEN} + 0x100);
    WriteGPR(10, Zeros{PTO_XLEN} + 0x222);
    let entry = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x41, 10, 10, 2), 32);
    assert entry == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0xf0;
    assert LoadTranslatedUnsigned(Zeros{PTO_XLEN} + 0xf8, 8) ==
        Zeros{PTO_XLEN} + 0x222;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;

    // FEXIT restores R10 and its PTO return-address shadow, then retires +4.
    WriteGPR(10, Zeros{PTO_XLEN} + 0x999);
    let exit = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x1041, 10, 10, 2), 32);
    assert exit == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0x100;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0x222;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x222;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x108;

    // FRET.STK uses slot zero, not bundle-return state, and owns TPC.
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    WriteGPR(1, Zeros{PTO_XLEN} + 0xf0);
    WriteGPR(10, Zeros{PTO_XLEN} + 0x777);
    Store(Zeros{PTO_XLEN} + 0xf8, 8, Zeros{PTO_XLEN} + 0x240);
    _BundleReturnTarget = Zeros{PTO_XLEN} + 0x280;
    let stack_return = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x3041, 10, 10, 2), 32);
    assert stack_return == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x240;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0x100;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0x240;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x240;

    // An endpoint outside R2..R23 is rejected before any frame effect.
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    WriteGPR(1, Zeros{PTO_XLEN} + 0x100);
    let malformed = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x41, 1, 10, 2), 32);
    assert malformed == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0x100;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x300;
    assert _MemoryEventCount == 0;
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x100);
    let queue_endpoint = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x41, 24, 10, 2), 32);
    assert queue_endpoint == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0x100;
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0xf0);
    let stack_begin = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x3041, 9, 10, 2), 32);
    assert stack_begin == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0xf0;

    // Insufficient frame size is malformed before any access or effect.
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x100);
    let short_frame = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x41, 10, 11, 1), 32);
    assert short_frame == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0x100;
    assert _MemoryEventCount == 0;

    // FRET.STK validates an odd slot-zero target before any restore effect.
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0xf0);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0xf8, Zeros{8} + 0x41);
    let odd_stack = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x3041, 10, 10, 2), 32);
    assert odd_stack == CommandExecution_Rejected;
    assert _LastFault == Fault_InstructionPC;
    assert _FaultAddress == Zeros{PTO_XLEN} + 0x41;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0xf0;
    assert _MemoryEventCount == 0;

    // FRET.RA retains pre-restore shadow state while restoring a distinct R10.
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    WriteGPR(1, Zeros{PTO_XLEN} + 0xf0);
    let ra_producer = ExecuteCommandInstruction(FrameTestHLCall(), 48);
    assert ra_producer == CommandExecution_Executed;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x40a;
    var overwrite_ra: bits(48) = Zeros{48} + 0x15;
    overwrite_ra[11:7] = Zeros{5} + 10;
    overwrite_ra[31:20] = Zeros{12} + 0x777;
    let overwrite_status = ExecuteScalarInstruction(overwrite_ra, 32);
    assert overwrite_status == ScalarExecution_Executed;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0x777;
    WriteMemoryByte(Zeros{PTO_XLEN} + 0xf8, Zeros{8} + 0x88);
    let ra_return = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x2041, 10, 10, 2), 32);
    assert ra_return == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x40a;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0x88;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x88;

    // FRET.STK slot zero is one captured load, and an even unmodeled target
    // is accepted without a marker/fetchability check.
    ResetProfileState();
    StartMemoryEventCapture(0);
    WriteGPR(1, Zeros{PTO_XLEN} + 0xf0);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0xf8, Zeros{8} + 0x40);
    let captured_return = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x3041, 10, 10, 2), 32);
    assert captured_return == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0xf8;
    assert _MemoryEvents[[0]].size_bytes == 8;
    assert _MemoryEvents[[0]].read_value == Zeros{PTO_XLEN} + 0x40;
    assert _MemoryEvents[[0]].order == MemoryOrder_Relaxed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x40;
    StopMemoryEventCapture();

    // FRET.RA odd target wins before frame-slot probing and has zero effects.
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x500);
    WriteGPR(1, Zeros{PTO_XLEN} + 0xf0);
    _ReturnAddress = Zeros{PTO_XLEN} + 0x241;
    let odd_ra = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x2041, 10, 10, 2), 32);
    assert odd_ra == CommandExecution_Rejected;
    assert _LastFault == Fault_InstructionPC;
    assert _FaultAddress == Zeros{PTO_XLEN} + 0x241;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0xf0;
    assert _MemoryEventCount == 0;

    // FRET.STK slot-zero alignment and page faults preserve the frame.
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0xf1);
    let alignment_fault = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x3041, 10, 10, 2), 32);
    assert alignment_fault == CommandExecution_Rejected;
    assert _LastFault == Fault_DataAlignment;
    assert _FaultAddress == Zeros{PTO_XLEN} + 0xf9;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0xf1;
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0xff8);
    let page_fault = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x3041, 10, 10, 2), 32);
    assert page_fault == CommandExecution_Rejected;
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} + 0x1000;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0xff8;

    // A later slot fault (slot zero is valid at address 0; slot one wraps out
    // of the bounded data space) proves complete preflight and no partial
    // restore/publication.
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} - 8);
    WriteGPR(10, Zeros{PTO_XLEN} + 0xaaaa);
    WriteGPR(11, Zeros{PTO_XLEN} + 0xbbbb);
    WriteMemoryByte(Zeros{PTO_XLEN}, Zeros{8} + 0x40);
    let later_slot_fault = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x1041, 10, 11, 2), 32);
    assert later_slot_fault == CommandExecution_Rejected;
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} - 8;
    assert ReadGPR(1) == Zeros{PTO_XLEN} - 8;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0xaaaa;

    // FENTRY likewise preflights every store: slot zero is valid, then slot
    // one faults, with no earlier store or SP publication.
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 8);
    WriteGPR(10, Zeros{PTO_XLEN} + 0xaaaa);
    WriteGPR(11, Zeros{PTO_XLEN} + 0xbbbb);
    let entry_later_slot_fault = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x41, 10, 11, 2), 32);
    assert entry_later_slot_fault == CommandExecution_Rejected;
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} - 8;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 8;
    assert LoadTranslatedUnsigned(Zeros{PTO_XLEN}, 8) == Zeros{PTO_XLEN};

    // FRET.STK validates slot zero, then later restore slots, before commit.
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} - 8);
    WriteGPR(10, Zeros{PTO_XLEN} + 0xaaaa);
    WriteGPR(11, Zeros{PTO_XLEN} + 0xbbbb);
    WriteMemoryByte(Zeros{PTO_XLEN}, Zeros{8} + 0x40);
    let stack_later_slot_fault = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x3041, 10, 11, 2), 32);
    assert stack_later_slot_fault == CommandExecution_Rejected;
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} - 8;
    assert ReadGPR(1) == Zeros{PTO_XLEN} - 8;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0xaaaa;
    assert _MemoryEventCount == 0;

    // R22~R3 wraps R23->R2 and preserves exact slot/ring order.
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x300);
    WriteGPR(22, Zeros{PTO_XLEN} + 0x22);
    WriteGPR(23, Zeros{PTO_XLEN} + 0x23);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x02);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x03);
    let wrap_entry = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x41, 22, 3, 4), 32);
    assert wrap_entry == CommandExecution_Executed;
    assert LoadTranslatedUnsigned(Zeros{PTO_XLEN} + 0x2f8, 8) == Zeros{PTO_XLEN} + 0x22;
    assert LoadTranslatedUnsigned(Zeros{PTO_XLEN} + 0x2f0, 8) == Zeros{PTO_XLEN} + 0x23;
    assert LoadTranslatedUnsigned(Zeros{PTO_XLEN} + 0x2e8, 8) == Zeros{PTO_XLEN} + 0x02;
    assert LoadTranslatedUnsigned(Zeros{PTO_XLEN} + 0x2e0, 8) == Zeros{PTO_XLEN} + 0x03;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0x2e0;

    // A full 22-register ring remains legal with capture disabled.
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x300);
    let full_ring = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x41, 2, 23, 22), 32);
    assert full_ring == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0x250;

    // Decoded call -> FENTRY -> FRET.STK uses the stack-saved call return PC.
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    WriteGPR(1, Zeros{PTO_XLEN} + 0x300);
    var call: bits(64) = FrameTestHLCall();
    let call_status = ExecuteCommandInstruction(call, 48);
    assert call_status == CommandExecution_Executed;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x30a;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x306;
    let entry_status = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x41, 10, 10, 2), 32);
    assert entry_status == CommandExecution_Executed;
    let return_status = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x3041, 10, 10, 2), 32);
    assert return_status == CommandExecution_Executed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x30a;

    // Two decoded call/frame levels return inner then outer stack targets.
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    WriteGPR(1, Zeros{PTO_XLEN} + 0x300);
    var outer_call: bits(64) = FrameTestHLCall();
    let outer_call_status = ExecuteCommandInstruction(outer_call, 48);
    assert outer_call_status == CommandExecution_Executed;
    let outer_entry_status = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x41, 10, 10, 2), 32);
    assert outer_entry_status == CommandExecution_Executed;
    let outer_return = _ReturnAddress;
    var inner_call: bits(64) = FrameTestHLCall();
    let inner_call_status = ExecuteCommandInstruction(inner_call, 48);
    assert inner_call_status == CommandExecution_Executed;
    let inner_return = _ReturnAddress;
    let inner_entry_status = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x41, 10, 10, 2), 32);
    assert inner_entry_status == CommandExecution_Executed;
    let inner_return_status = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x3041, 10, 10, 2), 32);
    assert inner_return_status == CommandExecution_Executed;
    assert ReadTPC() == inner_return;
    let outer_return_status = ExecuteCommandInstruction(
        FrameTestInstruction(Zeros{32} + 0x3041, 10, 10, 2), 32);
    assert outer_return_status == CommandExecution_Executed;
    assert ReadTPC() == outer_return;
end;

func main() => integer
begin
    TestFrameTemplateExecution();
    return 0;
end;
