<!-- GENERATED FROM: asl/block/model/dispatch/timg2col-schema.asl -->
# Timg2col Schema

**Normative ASL source:** `asl/block/model/dispatch/timg2col-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TIMG2COL-SCHEMA}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/timg2col-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TIMG2COL-SCHEMA","surface":"block","classification":["model","dispatch","timg2col-schema"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-TIMG2COL-PARAMETERS","PTO-BLOCK-B-DATR","PTO-BLOCK-B-DIM"]}
// PTO-BSTART-TIMG2COL-CONTRACT-001 and PTO-BSTART-TIMG2COL-CROP-001 own
// schema, crop, and physical-shape legality. Function 28 is the exact
// command-only TLSU carrier selected by the descriptor owner.
type BundleTIMG2COLShape of record {
    valid_col: integer {0..65535},
    valid_row: integer {0..65535},
    total_col: integer {0..65535},
    data_type: TileDataType,
    input_h: integer {1..65535},
    input_w: integer {1..65535},
    cin: integer {1..65535},
    kernel_h: integer {1..255},
    kernel_w: integer {1..255},
    pad_top: integer {0..255},
    pad_left: integer {0..255},
    pad_bottom: integer {0..255},
    pad_right: integer {0..255},
    dilation_h: integer {1..31},
    dilation_w: integer {1..31},
    conv_stride_h: integer {1..63},
    conv_stride_w: integer {1..63},
    row_start: integer {0..4294967295},
    col_start: integer {0..4294967295}
};

pure func BundleTIMG2COLC0Elements(data_type: TileDataType)
    => integer {4,8,16,32,64}
begin
    return (256 DIVRM TileElementBits(data_type))
        as integer {4,8,16,32,64};
end;

pure func BundleTIMG2COLC1(cin: integer {1..65535},
                           data_type: TileDataType) => integer
begin
    let c0 = BundleTIMG2COLC0Elements(data_type);
    let numerator = cin + (c0 - 1);
    return (numerator DIVRM c0);
end;

pure func BundleTIMG2COLEffectiveKernelH(
    parameters: BundleTIMG2COLParameters) => integer
begin
    let span = parameters.kernel_h - 1;
    let scaled = span * parameters.dilation_h;
    return scaled + 1;
end;

pure func BundleTIMG2COLEffectiveKernelW(
    parameters: BundleTIMG2COLParameters) => integer
begin
    let span = parameters.kernel_w - 1;
    let scaled = span * parameters.dilation_w;
    return scaled + 1;
end;

pure func BundleTIMG2COLHout(parameters: BundleTIMG2COLParameters)
    => integer
begin
    let effective = BundleTIMG2COLEffectiveKernelH(parameters);
    let padded = (parameters.input_h + parameters.pad_top) +
        parameters.pad_bottom;
    if padded < effective then return 0; end;
    let numerator = padded - effective;
    return (numerator DIVRM parameters.conv_stride_h) + 1;
end;

pure func BundleTIMG2COLWout(parameters: BundleTIMG2COLParameters)
    => integer
begin
    let effective = BundleTIMG2COLEffectiveKernelW(parameters);
    let padded = (parameters.input_w + parameters.pad_left) +
        parameters.pad_right;
    if padded < effective then return 0; end;
    let numerator = padded - effective;
    return (numerator DIVRM parameters.conv_stride_w) + 1;
end;

pure func BundleTIMG2COLKValid(parameters: BundleTIMG2COLParameters,
                               data_type: TileDataType)
    => integer
begin
    let c1 = BundleTIMG2COLC1(
        parameters.cin as integer {1..65535}, data_type);
    let kernel_area = parameters.kernel_h * parameters.kernel_w;
    let padded_channels = c1 * BundleTIMG2COLC0Elements(data_type);
    return kernel_area * padded_channels;
end;

pure func BundleTIMG2COLShapeLegal(shape: BundleTIMG2COLShape) => boolean
begin
    let c0 = BundleTIMG2COLC0Elements(shape.data_type);
    let parameters = BundleTIMG2COLParameters {
        input_h = shape.input_h,
        input_w = shape.input_w,
        cin = shape.cin,
        kernel_h = shape.kernel_h,
        kernel_w = shape.kernel_w,
        pad_top = shape.pad_top,
        pad_left = shape.pad_left,
        pad_bottom = shape.pad_bottom,
        pad_right = shape.pad_right,
        dilation_h = shape.dilation_h,
        dilation_w = shape.dilation_w,
        conv_stride_h = shape.conv_stride_h,
        conv_stride_w = shape.conv_stride_w,
        param_version = 0,
        extension_class = 0,
        row_start = shape.row_start,
        col_start = shape.col_start
    };
    let hout = BundleTIMG2COLHout(parameters);
    let wout = BundleTIMG2COLWout(parameters);
    let kvalid = BundleTIMG2COLKValid(parameters, shape.data_type);
    return c0 != 0 && shape.valid_col != 0 && shape.valid_row != 0 &&
           shape.total_col != 0 && shape.valid_col <= shape.total_col &&
           shape.valid_col MOD c0 == 0 && shape.total_col MOD c0 == 0 &&
           shape.col_start MOD c0 == 0 &&
           shape.row_start + shape.valid_row <= hout * wout &&
           shape.col_start + shape.valid_col <= kvalid;
end;

pure func BundleTIMG2COLMPerPE(valid_row: integer {1..128})
    => integer {16,32}
begin
    return if valid_row <= 64 then 16 else 32;
end;

pure func BundleTIMG2COLValidRowForPE(valid_row: integer {1..128},
                                      pe: integer {0..3})
    => integer {0..32}
begin
    let m_per_pe = BundleTIMG2COLMPerPE(valid_row);
    let consumed = (pe * m_per_pe) as integer {0..128};
    if valid_row <= consumed then return 0; end;
    let remaining = (valid_row - consumed) as integer {1..128};
    if remaining < m_per_pe then
        return remaining as integer {0..32};
    end;
    return m_per_pe as integer {0..32};
end;

pure func BundleTIMG2COLRowStartForPE(valid_row: integer {1..128},
                                      row_start: integer,
                                      pe: integer {0..3})
    => integer
begin
    let m_per_pe = BundleTIMG2COLMPerPE(valid_row);
    if pe == 0 then return row_start; end;
    var result: integer = row_start;
    for previous = 0 to (pe - 1) looplimit 3 do
        result = result + BundleTIMG2COLValidRowForPE(valid_row, previous);
    end;
    return result;
end;

pure func BundleTIMG2COLKIndex(kernel_w: integer {1..255},
                               kh: integer {0..254}, kw: integer {0..254},
                               c1_index: integer {0..65534},
                               c0_lane: integer {0..63},
                               c1_count: integer {1..65535},
                               c0_elements: integer {4,8,16,32,64})
    => integer {0..65535}
begin
    let kernel_offset = ((kh * kernel_w) + kw) as integer {0..65534};
    let channel_block = ((kernel_offset * c1_count) + c1_index) as integer {0..65535};
    let result = ((channel_block * c0_elements) + c0_lane) as integer {0..65535};
    return result as integer {0..65535};
end;

readonly func BundleTIMG2COLSelected() => boolean
begin
    return BundleDescriptorSelectsTIMG2COL(_BundleOperation);
end;

// The following records are the executable, pre-encoding dispatch contract.
// They are deliberately independent of a numerical command encoding: the
// later encoding pass will feed the same resolved request into this path.
type BundleTIMG2COLOutputKind of enumeration {
    BundleTIMG2COLOutput_SharedND,
    BundleTIMG2COLOutput_LocalM16,
    BundleTIMG2COLOutput_LocalM32
};

pure func BundleTIMG2COLDimensionRolesComplete(
    valid_col_present: boolean, valid_row_present: boolean,
    total_col_present: boolean) => boolean
begin
    return valid_col_present && valid_row_present && total_col_present;
end;

pure func BundleTIMG2COLMPerPEForOutput(
    output: BundleTIMG2COLOutputKind, valid_row: integer {1..128})
    => integer {16,32}
begin
    if output == BundleTIMG2COLOutput_LocalM16 then return 16; end;
    if output == BundleTIMG2COLOutput_LocalM32 then return 32; end;
    return BundleTIMG2COLMPerPE(valid_row);
end;

pure func BundleTIMG2COLValidRowForOutput(
    output: BundleTIMG2COLOutputKind, valid_row: integer {1..128},
    pe: integer {0..3}) => integer {0..32}
begin
    let m_per_pe = BundleTIMG2COLMPerPEForOutput(output, valid_row);
    let consumed = (pe * m_per_pe) as integer {0..128};
    if valid_row <= consumed then return 0; end;
    let remaining = (valid_row - consumed) as integer {1..128};
    if remaining < m_per_pe then
        return remaining as integer {0..32};
    end;
    return m_per_pe as integer {0..32};
end;

pure func BundleTIMG2COLRowStartForOutput(
    output: BundleTIMG2COLOutputKind, valid_row: integer {1..128},
    row_start: integer, pe: integer {0..3}) => integer
begin
    if pe == 0 then return row_start; end;
    var result: integer = row_start;
    for previous = 0 to (pe - 1) looplimit 3 do
        result = result + BundleTIMG2COLValidRowForOutput(
            output, valid_row, previous);
    end;
    return result;
end;

type BundleTIMG2COLCellResult of record {
    defined: boolean,
    raw_zero: boolean,
    gm_access: boolean,
    gm_index: integer
};

pure func BundleTIMG2COLLayoutIsDN(layout: TileDataLayout) => boolean
begin
    return layout == TileDataLayout_DN2ND ||
           layout == TileDataLayout_CUBE_M16 ||
           layout == TileDataLayout_CUBE_M32;
end;

pure func BundleTIMG2COLOutputMatchesLayout(
    layout: TileDataLayout, output: BundleTIMG2COLOutputKind) => boolean
begin
    if output == BundleTIMG2COLOutput_SharedND then
        return layout == TileDataLayout_NORM ||
               layout == TileDataLayout_DN2ND;
    end;
    if output == BundleTIMG2COLOutput_LocalM16 then
        return layout == TileDataLayout_ND2M16 ||
               layout == TileDataLayout_CUBE_M16;
    end;
    return layout == TileDataLayout_ND2M32 ||
           layout == TileDataLayout_CUBE_M32;
end;

readonly func BundleTIMG2COLDestinationShapeLegal(
    output: BundleTIMG2COLOutputKind,
    capacity_bytes: integer {128..262144},
    valid_row: integer {1..128}, valid_col: integer {1..65535},
    total_col: integer {1..65535}, data_type: TileDataType) => boolean
begin
    if valid_col > total_col then return FALSE; end;
    if output == BundleTIMG2COLOutput_SharedND then
        return TileDescriptorShapeLegal(capacity_bytes, total_col,
            valid_row, valid_col, data_type);
    end;
    var cube_layout: TileLayout = TileLayout_CUBE_M32;
    if output == BundleTIMG2COLOutput_LocalM16 then
        cube_layout = TileLayout_CUBE_M16;
    end;
    for pe = 0 to 3 do
        let fragment_rows = BundleTIMG2COLValidRowForOutput(
            output, valid_row, pe);
        if fragment_rows != 0 &&
           !TileCubeDescriptorShapeLegal(capacity_bytes, fragment_rows,
               valid_col, data_type, cube_layout) then
            return FALSE;
        end;
    end;
    return TRUE;
end;

pure func BundleTIMG2COLCell(
    layout: TileDataLayout, data_type: TileDataType,
    parameters: BundleTIMG2COLParameters,
    row: integer {0..127}, col: integer {0..65534})
    => BundleTIMG2COLCellResult
begin
    let c0 = BundleTIMG2COLC0Elements(data_type);
    let c1 = BundleTIMG2COLC1(parameters.cin as integer {1..65535},
        data_type);
    let k_per_kernel = (c1 * c0) as integer {4..4194240};
    let expanded_row: integer = parameters.row_start + row;
    let expanded_col: integer = parameters.col_start + col;
    let wout = BundleTIMG2COLWout(parameters) as integer {1..65535};
    let kernel_w = parameters.kernel_w as integer {1..255};
    let output_row: integer = expanded_row DIVRM wout;
    let output_col: integer = expanded_row MOD wout;
    let kernel_offset: integer = expanded_col DIVRM k_per_kernel;
    let channel_block_offset = (expanded_col MOD k_per_kernel)
        as integer {0..4194239};
    let kh = (kernel_offset DIVRM kernel_w)
        as integer {0..4294967295};
    let kw = (kernel_offset MOD kernel_w)
        as integer {0..254};
    let c1_index = (channel_block_offset DIVRM c0)
        as integer {0..65534};
    let c0_lane = (channel_block_offset MOD c0)
        as integer {0..63};
    let channel = (c1_index * c0 + c0_lane)
        as integer {0..65535};
    let hin: integer = ((output_row * parameters.conv_stride_h) +
        (kh * parameters.dilation_h)) - parameters.pad_top;
    let win: integer = ((output_col * parameters.conv_stride_w) +
        (kw * parameters.dilation_w)) - parameters.pad_left;
    let spatial_valid = BundleTIMG2COLSpatialInBounds(hin, win,
        parameters.input_h as integer {1..65535},
        parameters.input_w as integer {1..65535});
    let lane_valid = BundleTIMG2COLCinLaneDefined(channel,
        parameters.cin as integer {1..65535});
    if !spatial_valid || !lane_valid then
        return BundleTIMG2COLCellResult {
            defined = TRUE, raw_zero = TRUE, gm_access = FALSE, gm_index = 0
        };
    end;
    let index = if BundleTIMG2COLLayoutIsDN(layout) then
        BundleTIMG2COLGMIndexDN(channel,
            parameters.input_h as integer {1..65535},
            parameters.input_w as integer {1..65535}, hin as integer {0..65534},
            win as integer {0..65534})
    else
        BundleTIMG2COLGMIndexND(channel,
            parameters.cin as integer {1..65535},
            parameters.input_h as integer {1..65535},
            parameters.input_w as integer {1..65535}, hin as integer {0..65534},
            win as integer {0..65534});
    return BundleTIMG2COLCellResult {
        defined = TRUE, raw_zero = FALSE, gm_access = TRUE, gm_index = index
    };
end;

pure func BundleTIMG2COLWriterRange(
    valid_row: integer {1..128}, row_start: integer,
    pe: integer {0..3}, total_col: integer {1..65535})
    => (integer, integer)
begin
    let first = BundleTIMG2COLRowStartForPE(valid_row, row_start, pe);
    let count = BundleTIMG2COLValidRowForPE(valid_row, pe);
    let start_offset: integer {0..18446744073709551615} =
        (first * total_col) as integer {0..18446744073709551615};
    let row_bytes: integer {0..4294967295} = count * total_col;
    return (start_offset, row_bytes);
end;

// NDF-BEGIN: PTO-BSTART-TIMG2COL-CROP-001
// ndf: kind=contract level=L1 layer=block status=accepted
// LB0, LB1, and LB2 bind ValidCol, ValidRow, and TotalCol exactly once.
// ValidCol and TotalCol are positive C0-aligned physical columns, ValidCol
// does not exceed TotalCol, and the row and column crop remains within the
// wide-arithmetic IMG2COL Hout*Wout and KValid bounds.
// For Shared output, TotalCol is the persistent ordinary-ND row pitch. For
// direct Local output it is the virtual intermediate ND pitch used to define
// composition equivalence; persistent CUBE geometry derives from ValidCol.
// NDF-END: PTO-BSTART-TIMG2COL-CROP-001

// NDF-BEGIN: PTO-BSTART-TIMG2COL-COOPERATIVE-001
// ndf: kind=contract level=L1 layer=concurrency status=accepted
// Four-PE TIMG2COL distribution follows the ordinary core-level M model:
// valid rows 1..64 use four 16-row quarters and rows 65..128 use four
// 32-row quarters. Remainder rows are assigned contiguously; a zero-row PE
// remains a collective participant but performs no allocation or memory
// effect, while assemble coverage still covers the complete physical parent.
// NDF-END: PTO-BSTART-TIMG2COL-COOPERATIVE-001
```
<!-- GENERATED-ASL-END: unit -->
