// PTO-TEST: {"id":"PTO-AVS-BLOCK-TIMG2COL-GM-001","source":"asl/block/model/memory/timg2col-gm.asl","requirements":["PTO-BSTART-TIMG2COL-DEFINEDNESS-001"],"kind":"execution","summary":"Dense DN and ND address generation is distinct while OOB and Cin padding are defined raw zero.","pass_condition":"The two dense formulas return their specified indices, valid source cells are defined, and physical tails remain undefined.","related_sources":["asl/block/model/dispatch/timg2col-schema.asl"]}
func main() => integer
begin
    assert BundleTIMG2COLGMIndexDN(1, 2, 3, 1, 2) == 11;
    assert BundleTIMG2COLGMIndexND(1, 4, 2, 3, 1, 2) == 21;
    assert BundleTIMG2COLSpatialInBounds(0, 0, 2, 3);
    assert !BundleTIMG2COLSpatialInBounds(-1, 0, 2, 3);
    let parameters = BundleTIMG2COLParameters {
        input_h = 2, input_w = 2, cin = 3, kernel_h = 1, kernel_w = 1,
        pad_top = 1, pad_left = 0, pad_bottom = 0, pad_right = 0,
        dilation_h = 1, dilation_w = 1, conv_stride_h = 1,
        conv_stride_w = 1, param_version = 0, extension_class = 0,
        row_start = 0, col_start = 0
    };
    let valid_cell = BundleTIMG2COLCell(
        TileDataLayout_NORM, TileDataType_U8, parameters, 2, 0);
    assert valid_cell.defined && !valid_cell.raw_zero && valid_cell.gm_access;
    let spatial_zero = BundleTIMG2COLCell(
        TileDataLayout_NORM, TileDataType_U8, parameters, 1, 0);
    assert spatial_zero.defined && spatial_zero.raw_zero &&
           !spatial_zero.gm_access;
    let cin_zero = BundleTIMG2COLCell(
        TileDataLayout_NORM, TileDataType_U8, parameters, 2, 3);
    assert cin_zero.defined && cin_zero.raw_zero && !cin_zero.gm_access;
    assert BundleTIMG2COLCellIsDefined(FALSE, TRUE);
    assert BundleTIMG2COLCellIsDefined(TRUE, FALSE);
    assert BundleTIMG2COLPhysicalTailDefined(0, 0, 2, 32);
    assert !BundleTIMG2COLPhysicalTailDefined(2, 0, 2, 32);
    assert !BundleTIMG2COLPhysicalTailDefined(0, 32, 2, 32);
    return 0;
end;
