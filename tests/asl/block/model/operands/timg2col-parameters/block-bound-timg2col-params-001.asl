// PTO-TEST: {"id":"PTO-AVS-BLOCK-TIMG2COL-PARAMS-001","source":"asl/block/model/operands/timg2col-parameters.asl","requirements":["PTO-BSTART-TIMG2COL-PARAMS-001"],"kind":"boundary","summary":"The frozen parameter carrier extracts the specified fields and accepts exactly two source-only B.IOR records.","pass_condition":"The field extraction and canonical two-record schema predicates return the frozen values.","related_sources":["asl/block/execution/BSTART.TIMG2COL.asl"]}
func main() => integer
begin
    let (input_h, input_w, cin, kernel_h, kernel_w) =
        BundleTIMG2COLParameterGPR0(Zeros{64} + 1);
    assert input_h == 1 && input_w == 0 && cin == 0 &&
           kernel_h == 0 && kernel_w == 0;
    let first = BundleTIMG2COLIORRecord {
        reg_src0 = 1, reg_src1 = 0, reg_src2 = 0, reg_dst = 0
    };
    let second = BundleTIMG2COLIORRecord {
        reg_src0 = 2, reg_src1 = 3, reg_src2 = 4, reg_dst = 0
    };
    assert BundleTIMG2COLIORRecordsLegal(first, second, 2);
    assert !BundleTIMG2COLIORRecordsLegal(first, second, 1);
    var destination_bearing = second;
    destination_bearing.reg_dst = 5;
    assert !BundleTIMG2COLIORRecordsLegal(first, destination_bearing, 2);
    assert BundleTIMG2COLIORStreamPreflight(
        first, second, 2, TRUE, TRUE, TRUE);
    assert !BundleTIMG2COLIORStreamPreflight(
        first, second, 2, FALSE, TRUE, TRUE);
    assert BundleTIMG2COLBaseParameterExtensionLegal(Zeros{PTO_XLEN});
    assert !BundleTIMG2COLBaseParameterExtensionLegal(
        Zeros{PTO_XLEN} + (1 << 54));
    assert !BundleTIMG2COLBaseParameterExtensionLegal(
        Zeros{PTO_XLEN} + (1 << 55));
    assert !BundleTIMG2COLBaseParameterExtensionLegal(
        Zeros{PTO_XLEN} + (1 << 59));
    assert !BundleTIMG2COLBaseParameterExtensionLegal(
        Zeros{PTO_XLEN} + (1 << 63));
    let generation = BundleTIMG2COLGenerationMetadata(
        Zeros{5}, Zeros{5} + 27, Zeros{16} + 32, Zeros{8} + 1,
        Zeros{16} + 64, Zeros{4} + 1, Zeros{6} + 8);
    assert generation != BundleTIMG2COLGenerationMetadata(
        Zeros{5} + 6, Zeros{5} + 27, Zeros{16} + 32, Zeros{8} + 1,
        Zeros{16} + 64, Zeros{4} + 1, Zeros{6} + 8);
    assert generation != BundleTIMG2COLGenerationMetadata(
        Zeros{5}, Zeros{5} + 27, Zeros{16} + 64, Zeros{8} + 1,
        Zeros{16} + 64, Zeros{4} + 1, Zeros{6} + 8);
    assert generation != BundleTIMG2COLGenerationMetadata(
        Zeros{5}, Zeros{5} + 27, Zeros{16} + 32, Zeros{8} + 2,
        Zeros{16} + 64, Zeros{4} + 1, Zeros{6} + 8);
    return 0;
end;
