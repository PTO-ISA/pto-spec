// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-TRANSPOSE-RSVD-012","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"fault","summary":"B.FPATR bits nine and ten remain reserved after assigning transpose controls","pass_condition":"each reserved bit rejects before TPC or fixed-point descriptor state changes","related_sources":["asl/block/model/dispatch/decode.asl"]}
func main() => integer
begin
    for bit_index = 9 to 10 do
        ResetProfileState();
        WriteTPC(Zeros{PTO_XLEN} + 0x720);
        _BundleActive = TRUE;
        _BundleOperation.valid = TRUE;
        _BundleOperation.operation_class = BundleOperation_TileMatrix;
        var instruction: bits(64) = Zeros{64} + 0x00002023;
        instruction[bit_index] = '1';

        let status = ExecuteCommandInstruction(instruction, 32);

        assert status == CommandExecution_Rejected;
        assert _LastFault == Fault_IllegalInstruction;
        assert !_BundleFixedPointAttributes.valid;
        assert ReadTPC() == Zeros{PTO_XLEN} + 0x720;
    end;
    return 0;
end;
