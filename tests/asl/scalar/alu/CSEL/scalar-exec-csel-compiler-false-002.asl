// PTO-TEST: {"id":"PTO-AVS-SCALAR-CSEL-COMPILER-FALSE-002","source":"asl/scalar/alu/CSEL.asl","requirements":["PTO-INST-SCALAR-CSEL"],"kind":"execution","summary":"Compiler-emitted raw selector 11 preserves the CSEL false source.","pass_condition":"Exact encoding 0xcfcc0177 with a zero T#2 predicate publishes the unmodified U#1 value.","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/dispatch/decode.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0x45880800);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN});
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN});
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0xbf4ab632);

    let status = ExecuteScalarInstruction(
        Zeros{48} + 0xcfcc0177,
        32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0x45880800;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;
    return 0;
end;
