// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMOV-EXTRACT-001","source":"asl/block/execution/BSTART.TMOV.asl","requirements":["PTO-INST-BLOCK-BSTART-TMOV"],"kind":"decode-negative","summary":"the former Shared extract carrier cannot access undefined Shared payload","pass_condition":"the former carrier is reserved before any bundle execution state is created","related_sources":["asl/tile/model/state/shared-registers.asl","asl/tile/model/memory/shared-movement.asl"]}
func main() => integer
begin
    ResetProfileState();
    assert DecodeCommandForm(Zeros{64} + 0x00c11181, 32) != 47;
    assert !_BundleActive;
    return 0;
end;
