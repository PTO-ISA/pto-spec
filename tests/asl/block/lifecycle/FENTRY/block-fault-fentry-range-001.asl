// PTO-TEST: {"id":"PTO-AVS-BLOCK-FENTRY-RANGE-001","source":"asl/block/lifecycle/FENTRY.asl","requirements":["PTO-INST-BLOCK-FENTRY"],"kind":"fault","summary":"FENTRY rejects endpoints outside R2 through R23 and undersized frames before effects","pass_condition":"invalid endpoints and frame sizes raise Fault_IllegalInstruction while preserving sp, memory, frame depth, progress, and TPC","related_sources":["asl/block/model/lifecycle/lifetime.asl"]}
func AssertFENTRYRejected(begin_reg: Reg5Selector,
                          end_reg: Reg5Selector,
                          size: Word)
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x540);
    WriteGPR(1, Zeros{PTO_XLEN} + 0x300);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x2f8, Zeros{8} + 0xaa);

    EnterFrame(begin_reg, end_reg, size);

    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0x300;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 0x2f8) == Zeros{8} + 0xaa;
    assert _FrameDepth == 0;
    assert !_FrameTemplate.active;
end;

func main() => integer
begin
    AssertFENTRYRejected(1, 3, Zeros{PTO_XLEN} + 16);
    AssertFENTRYRejected(2, 24, Zeros{PTO_XLEN} + 16);
    AssertFENTRYRejected(2, 4, Zeros{PTO_XLEN} + 16);
    return 0;
end;
