// PTO-TEST: {"id":"PTO-AVS-SCALAR-SYNC-CORE-NEAR-NEIGHBORS-001","source":"asl/scalar/model/dispatch/decode.asl","requirements":["PTO-REQ-INSTRUCTION-DISPATCH-001","PTO-INST-SCALAR-SYNC-CORE"],"kind":"decode-negative","summary":"nearby mode, RW, fixed-field, and opcode words do not alias the exact SYNC.CORE form","pass_condition":"only the exact canonical operation among the tested words resolves to ScalarOperation_SYNC_CORE while the existing FENCE.D and FENCE.I words remain distinct","related_sources":["asl/scalar/sys/SYNC.CORE.asl","asl/scalar/sys/FENCE.D.asl","asl/scalar/sys/FENCE.I.asl"]}

readonly func DecodesAsSyncCore(word: bits(32)) => boolean
begin
    let form = DecodeScalarForm(ZeroExtend{48}(word), 32);
    if form == PTO_SCALAR_FORM_COUNT then return FALSE; end;
    let form_index = form as integer {0..PTO_SCALAR_FORM_COUNT-1};
    return ScalarOperationOfForm(form_index) == ScalarOperation_SYNC_CORE;
end;

func main() => integer
begin
    assert DecodesAsSyncCore('00000011001100001010000000101011');
    assert !DecodesAsSyncCore('00010011001100001010000000101011');
    assert !DecodesAsSyncCore('00000011001100001010000000101010');
    assert !DecodesAsSyncCore('00000011001100001010000010101011');
    assert !DecodesAsSyncCore('00000011001100001000000000101011');
    assert !DecodesAsSyncCore('00000011001100001010000000111011');
    assert !DecodesAsSyncCore('00000000000000000010000000101011');
    assert !DecodesAsSyncCore('00010000000000000010000000101011');
    return 0;
end;
