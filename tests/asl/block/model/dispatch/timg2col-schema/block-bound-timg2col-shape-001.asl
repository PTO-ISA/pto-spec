// PTO-TEST: {"id":"PTO-AVS-BLOCK-TIMG2COL-SHAPE-001","source":"asl/block/model/dispatch/timg2col-schema.asl","requirements":["PTO-BSTART-TIMG2COL-CONTRACT-001","PTO-BSTART-TIMG2COL-CROP-001"],"kind":"boundary","summary":"The frozen IMG2COL shape contract enforces C0 alignment and crop bounds.","pass_condition":"A valid crop is accepted while misaligned and out-of-range crops are rejected.","related_sources":["asl/block/model/operands/timg2col-parameters.asl"]}
func main() => integer
begin
    let valid = BundleTIMG2COLShape {
        valid_col = 32, valid_row = 2, total_col = 64,
        data_type = TileDataType_U8,
        input_h = 5, input_w = 5, cin = 3,
        kernel_h = 3, kernel_w = 3,
        pad_top = 0, pad_left = 0, pad_bottom = 0, pad_right = 0,
        dilation_h = 1, dilation_w = 1,
        conv_stride_h = 1, conv_stride_w = 1,
        row_start = 0, col_start = 0
    };
    assert BundleTIMG2COLShapeLegal(valid);
    var misaligned = valid;
    misaligned.valid_col = 31;
    assert !BundleTIMG2COLShapeLegal(misaligned);
    var misaligned_total = valid;
    misaligned_total.total_col = 63;
    assert !BundleTIMG2COLShapeLegal(misaligned_total);
    var out_of_range = valid;
    out_of_range.row_start = 8;
    assert !BundleTIMG2COLShapeLegal(out_of_range);
    assert BundleTIMG2COLKValid(
        BundleTIMG2COLParameters {
            input_h = 5, input_w = 5, cin = 3, kernel_h = 3, kernel_w = 3,
            pad_top = 0, pad_left = 0, pad_bottom = 0, pad_right = 0,
            dilation_h = 1, dilation_w = 1, conv_stride_h = 1,
            conv_stride_w = 1, param_version = 0, extension_class = 0,
            row_start = 0, col_start = 0
        }, TileDataType_U8) == 288;
    let wide_parameters = BundleTIMG2COLParameters {
        input_h = 65535, input_w = 65535, cin = 65535,
        kernel_h = 1, kernel_w = 1,
        pad_top = 255, pad_left = 255, pad_bottom = 255, pad_right = 255,
        dilation_h = 1, dilation_w = 1, conv_stride_h = 1,
        conv_stride_w = 1, param_version = 0, extension_class = 0,
        row_start = 0, col_start = 0
    };
    assert BundleTIMG2COLHout(wide_parameters) == 66045;
    assert BundleTIMG2COLWout(wide_parameters) == 66045;
    assert BundleTIMG2COLHout(wide_parameters) *
        BundleTIMG2COLWout(wide_parameters) > 65535;
    var wide_kernel = wide_parameters;
    wide_kernel.kernel_h = 255;
    wide_kernel.kernel_w = 255;
    assert BundleTIMG2COLKValid(wide_kernel, TileDataType_U8) > 65535;
    return 0;
end;
