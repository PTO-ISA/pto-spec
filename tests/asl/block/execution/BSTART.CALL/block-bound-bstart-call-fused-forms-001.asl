// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-CALL-FUSED-FORMS-001","source":"asl/block/execution/BSTART.CALL.asl","requirements":["PTO-INST-BLOCK-BSTART-CALL"],"kind":"boundary","summary":"Only fused direct and indirect BSTART call forms decode.","pass_condition":"Both fused forms decode with ExecuteBundleStart and every bare CALL or ICALL form rejects.","related_sources":["asl/block/model/dispatch/start.asl"]}
func main() => integer
begin
    let direct = DecodeCommandForm(Zeros{64} + 0x50160002, 32);
    assert direct != PTO_COMMAND_FORM_COUNT;
    assert CommandHandlerOfForm(direct as integer {0..PTO_COMMAND_FORM_COUNT-1}) ==
        CommandHandler_ExecuteBundleStart;
    assert CommandBundleTransferOfForm(
        direct as integer {0..PTO_COMMAND_FORM_COUNT-1}) == BundleTransfer_Call;

    let indirect = DecodeCommandForm(Zeros{64} + 0x50166001, 32);
    assert indirect != PTO_COMMAND_FORM_COUNT;
    assert CommandHandlerOfForm(
        indirect as integer {0..PTO_COMMAND_FORM_COUNT-1}) ==
        CommandHandler_ExecuteBundleStart;
    assert CommandBundleTransferOfForm(
        indirect as integer {0..PTO_COMMAND_FORM_COUNT-1}) ==
        BundleTransfer_IndirectCall;

    assert DecodeCommandForm(Zeros{64} + 0x00004101, 32) ==
        PTO_COMMAND_FORM_COUNT;
    assert DecodeCommandForm(Zeros{64} + 0x00006101, 32) ==
        PTO_COMMAND_FORM_COUNT;
    assert DecodeCommandForm(Zeros{64} + 0x00004001, 32) ==
        PTO_COMMAND_FORM_COUNT;
    assert DecodeCommandForm(Zeros{64} + 0x00006001, 32) ==
        PTO_COMMAND_FORM_COUNT;
    return 0;
end;
