// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-MEMORY-WEIGHT-TO-SHARED-GM","surface":"block","classification":["model","memory","weight-to-shared-gm"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-WEIGHT-TO-SHARED-SCHEMA","PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS","PTO-TILE-MODEL-MEMORY-ADDRESSING"]}
// NDF-BEGIN: PTO-BSTART-TLOAD-WEIGHT-KORDER-001
// ndf: kind=contract level=L1 layer=block status=accepted
// Weight-mode TLOAD maps each destination K coordinate to [kh][kw][c1][c0]
// order, with c0 fastest, spatial coordinates before channel blocks, and
// reads OHWI or OIHW using the selected source-layout index formula.
// NDF-END: PTO-BSTART-TLOAD-WEIGHT-KORDER-001
// NDF-BEGIN: PTO-BSTART-TLOAD-WEIGHT-DEFINEDNESS-001
// ndf: kind=contract level=L1 layer=block status=accepted
// Cin padding lanes inside the valid canonical K rectangle are defined raw
// zero and do not access GM. All valid source lanes use wide unsigned address
// arithmetic and complete preflight; physical rows and columns outside the
// valid rectangle remain untouched and undefined.
// NDF-END: PTO-BSTART-TLOAD-WEIGHT-DEFINEDNESS-001
// PTO-BSTART-TLOAD-WEIGHT-KORDER-001 owns the canonical [kh][kw][c1][c0]
// reduction order and source-layout address projection.
type BundleWeightTLOADCellResult of record {
    defined: boolean,
    raw_zero: boolean,
    gm_access: boolean,
    gm_index: integer {0..18446744073709551615}
};

pure func BundleWeightTLOADCell(
    layout: TileDataLayout, data_type: TileDataType,
    parameters: BundleWeightTLOADParameters,
    local_row: integer {0..65534}, local_col: integer {0..65534})
    => BundleWeightTLOADCellResult
begin
    let c0 = BundleWeightTLOADC0Elements(data_type);
    let c1 = BundleWeightTLOADC1(
        parameters.cin as integer {1..65535}, data_type);
    let channel_span = (c1 * c0) as integer {4..65536};
    let global_k: integer = parameters.k_start + local_col;
    let global_n: integer = parameters.n_start + local_row;
    let kernel_offset: integer = global_k DIVRM channel_span;
    let channel_block_offset: integer = global_k MOD channel_span;
    let kh: integer = kernel_offset DIVRM parameters.kernel_w;
    let kw: integer = kernel_offset MOD parameters.kernel_w;
    let c1_index: integer = channel_block_offset DIVRM c0;
    let c0_lane: integer = channel_block_offset MOD c0;
    let ci: integer = c1_index * c0 + c0_lane;
    if ci >= parameters.cin then
        return BundleWeightTLOADCellResult {
            defined = TRUE, raw_zero = TRUE, gm_access = FALSE, gm_index = 0
        };
    end;
    var index: integer {0..18446744073709551615} = 0;
    if layout == TileDataLayout_OHWI2NK then
        index = (((global_n * parameters.kernel_h + kh) *
            parameters.kernel_w + kw) * parameters.cin + ci)
            as integer {0..18446744073709551615};
    else
        index = (((global_n * parameters.cin + ci) *
            parameters.kernel_h + kh) * parameters.kernel_w + kw)
            as integer {0..18446744073709551615};
    end;
    return BundleWeightTLOADCellResult {
        defined = TRUE, raw_zero = FALSE, gm_access = TRUE, gm_index = index
    };
end;

func BundleWeightTLOADPreflightGM(
    layout: TileDataLayout, data_type: TileDataType,
    parameters: BundleWeightTLOADParameters,
    row_count: integer {0..65535}, col_count: integer {1..65535},
    gm_base: Word, element_bytes: integer {1,2,4,8}) => boolean
begin
    if row_count == 0 then return TRUE; end;
    for row = 0 to row_count - 1 looplimit 65535 do
        for col = 0 to col_count - 1 looplimit 65535 do
            let cell = BundleWeightTLOADCell(layout, data_type, parameters,
                row as integer {0..65534}, col as integer {0..65534});
            if cell.gm_access then
                let byte_offset = (cell.gm_index * element_bytes)
                    as integer {0..18446744073709551615};
                let address = gm_base + byte_offset;
                if UInt(address) < UInt(gm_base) then
                    SetFault(Fault_DataPage, address);
                    return FALSE;
                end;
                let probe = ProbeTileMemoryAccess(address, data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then return FALSE; end;
            end;
        end;
    end;
    return TRUE;
end;
