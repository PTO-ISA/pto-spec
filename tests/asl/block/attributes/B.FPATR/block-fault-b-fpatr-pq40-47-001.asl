// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-PQ40-47-001","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR"],"kind":"fault","summary":"reserved PreQuantMode codes 40 through 47 reject before B.FPATR state","pass_condition":"each code raises Fault_IllegalInstruction without descriptor or TPC changes","related_sources":["asl/block/model/dispatch/decode.asl"]}
func main() => integer
begin
    for code = 40 to 47 do
        ResetProfileState();
        WriteTPC(Zeros{PTO_XLEN} + 0x480);
        _BundleActive = TRUE;
        _BundleOperation.valid = TRUE;
        _BundleOperation.operation_class = BundleOperation_TileMatrix;
        var instruction = Zeros{64} + 0x00002023;
        instruction[31:26] = Zeros{6} + code;

        let status = ExecuteCommandInstruction(instruction, 32);
        assert status == CommandExecution_Rejected;
        assert _LastFault == Fault_IllegalInstruction;
        assert !_BundleFixedPointAttributes.valid;
        assert ReadTPC() == Zeros{PTO_XLEN} + 0x480;
    end;
    return 0;
end;
