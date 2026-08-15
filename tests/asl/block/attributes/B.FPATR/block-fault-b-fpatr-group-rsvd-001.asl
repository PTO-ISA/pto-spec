// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-GROUP-RSVD-001","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR"],"kind":"fault","summary":"reserved GroupNCode values reject before B.FPATR state","pass_condition":"each code raises Fault_IllegalInstruction without descriptor or TPC changes","related_sources":["asl/block/model/dispatch/decode.asl"]}
func main() => integer
begin
    for code = 10 to 15 do
        ResetProfileState();
        WriteTPC(Zeros{PTO_XLEN} + 0x480);
        _BundleActive = TRUE;
        _BundleOperation.valid = TRUE;
        _BundleOperation.operation_class = BundleOperation_TileMatrix;
        var instruction = Zeros{64} + 0x00002023;
        instruction[22:19] = Zeros{4} + code;

        let status = ExecuteCommandInstruction(instruction, 32);
        assert status == CommandExecution_Rejected;
        assert _LastFault == Fault_IllegalInstruction;
        assert !_BundleFixedPointAttributes.valid;
        assert ReadTPC() == Zeros{PTO_XLEN} + 0x480;
    end;
    return 0;
end;
