// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-TRANSPOSE-011","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"decode-positive","summary":"B.FPATR bits seven and eight latch independent Shared A and B transpose controls","pass_condition":"all four TransA and TransB combinations decode and preserve the exact two booleans","related_sources":["asl/block/model/schema/attributes.asl"]}
func main() => integer
begin
    for controls = 0 to 3 do
        ResetProfileState();
        _BundleActive = TRUE;
        _BundleOperation.valid = TRUE;
        _BundleOperation.operation_class = BundleOperation_TileMatrix;
        var instruction: bits(64) = Zeros{64} + 0x00002023;
        instruction[8:7] = Zeros{2} + controls;

        let status = ExecuteCommandInstruction(instruction, 32);

        assert status == CommandExecution_Executed;
        assert _LastFault == Fault_None;
        assert _BundleFixedPointAttributes.valid;
        assert _BundleFixedPointAttributes.trans_a ==
            (controls MOD 2 == 1);
        assert _BundleFixedPointAttributes.trans_b ==
            (controls >= 2);
        assert !_BundleFixedPointAttributes.c_scale_en;
    end;
    return 0;
end;
