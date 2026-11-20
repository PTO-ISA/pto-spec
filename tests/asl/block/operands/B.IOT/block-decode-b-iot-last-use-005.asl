// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOT-LAST-USE-DECODE-005","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-B-IOT-STREAM-001","PTO-INST-BLOCK-B-IOT"],"kind":"decode-positive","summary":"B.IOT lifetime encodings decode to the approved independent reuse combinations while legacy words retain both sources.","pass_condition":"funct3 100/010/011/111 decode reuse/reuse, last/last, reuse/last, and last/reuse; one-source bit26 zero/one decode reuse/last-use for source-only and destination forms.","related_sources":["asl/block/model/dispatch/commands.asl"]}
func main() => integer
begin
    assert BIOTSource0Reuse(
        CommandOperation_b_iot_32_2c07e7177fad);
    assert BIOTSource1Reuse(
        CommandOperation_b_iot_32_2c07e7177fad);

    assert !BIOTSource0Reuse(
        CommandOperation_b_iot_32_ll_src);
    assert !BIOTSource1Reuse(
        CommandOperation_b_iot_32_ll_src);
    assert BIOTSource0Reuse(
        CommandOperation_b_iot_32_rl_src);
    assert !BIOTSource1Reuse(
        CommandOperation_b_iot_32_rl_src);
    assert !BIOTSource0Reuse(
        CommandOperation_b_iot_32_lr_src);
    assert BIOTSource1Reuse(
        CommandOperation_b_iot_32_lr_src);

    assert BIOTSource0Reuse(
        CommandOperation_b_iot_32_c11eb189dd83);
    assert !BIOTSource0Reuse(
        CommandOperation_b_iot_32_last_src);
    assert BIOTSource0Reuse(
        CommandOperation_b_iot_32_10db6db84f5d);
    assert !BIOTSource0Reuse(
        CommandOperation_b_iot_32_last_dst);
    return 0;
end;
