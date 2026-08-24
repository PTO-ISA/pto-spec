// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-TRANSPOSE-RSVD-012","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR","PTO-CUBE-CSCALE-001"],"kind":"fault","summary":"B.FPATR bit ten remains reserved after assigning CScaleEn.","pass_condition":"Bit ten rejects before TPC or fixed-point descriptor state changes while bit nine is owned by decoded CScale evidence.","related_sources":["asl/block/model/dispatch/decode.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x720);
    _BundleActive = TRUE;
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_TileMatrix;
    var instruction: bits(64) = Zeros{64} + 0x00002023;
    instruction[10] = '1';

    let status = ExecuteCommandInstruction(instruction, 32);

    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert !_BundleFixedPointAttributes.valid;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x720;
    return 0;
end;
