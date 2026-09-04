// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-MEMORY-TIMG2COL-GM","surface":"block","classification":["model","memory","timg2col-gm"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TIMG2COL-SCHEMA"]}
// PTO-BSTART-TIMG2COL-DEFINEDNESS-001 owns dense address generation and the
// distinction between defined raw zeros and untouched physical tails.
pure func BundleTIMG2COLSpatialInBounds(hin: integer,
                                        win: integer,
                                        input_h: integer {1..65535},
                                        input_w: integer {1..65535}) => boolean
begin
    return hin >= 0 && hin < input_h && win >= 0 && win < input_w;
end;

pure func BundleTIMG2COLCinLaneDefined(channel: integer {0..65535},
                                       logical_cin: integer {1..65535})
    => boolean
begin
    return channel < logical_cin;
end;

pure func BundleTIMG2COLGMIndexDN(channel: integer {0..65535},
                                  input_h: integer {1..65535},
                                  input_w: integer {1..65535},
                                  hin: integer {0..65534},
                                  win: integer {0..65534})
    => integer
begin
    let channel_base: integer = channel * input_h * input_w;
    let spatial_base: integer = hin * input_w + win;
    return channel_base + spatial_base;
end;

pure func BundleTIMG2COLGMIndexND(channel: integer {0..65535},
                                  input_cin: integer {1..65535},
                                  input_h: integer {1..65535},
                                  input_w: integer {1..65535},
                                  hin: integer {0..65534},
                                  win: integer {0..65534})
    => integer
begin
    let spatial: integer = hin * input_w + win;
    let pixel_base: integer = spatial * input_cin;
    return pixel_base + channel;
end;

pure func BundleTIMG2COLCellIsDefined(
    spatial_in_bounds: boolean, cin_lane_defined: boolean) => boolean
begin
    // Both out-of-bounds spatial coordinates and Cin padding lanes are raw
    // zero cells, hence defined. Only a valid source lane requires a GM read.
    return TRUE;
end;

pure func BundleTIMG2COLPhysicalTailDefined(
    row: integer {0..65535}, col: integer {0..65535},
    valid_row: integer {1..65535}, valid_col: integer {1..65535}) => boolean
begin
    return row < valid_row && col < valid_col;
end;

func BundleTIMG2COLPreflightGM(
    layout: TileDataLayout, data_type: TileDataType,
    parameters: BundleTIMG2COLParameters,
    valid_row: integer {0..128}, valid_col: integer {1..65535},
    gm_base: Word, element_bytes: integer {1,2,4,8}) => boolean
begin
    if valid_row == 0 then return TRUE; end;
    // Complete translation and permission checks before allocation, payload,
    // definedness, or Shared-generation effects.
    for row = 0 to valid_row - 1 looplimit 128 do
        for col = 0 to valid_col - 1 looplimit 65535 do
            let cell = BundleTIMG2COLCell(layout, data_type, parameters,
                row as integer {0..127}, col as integer {0..65534});
            if cell.gm_access then
                let byte_offset: integer = cell.gm_index * element_bytes;
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

// NDF-BEGIN: PTO-BSTART-TIMG2COL-DEFINEDNESS-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// Dense NCHW/DN and NHWC/ND source indices use wide unsigned arithmetic.
// Spatial out-of-bounds and Cin-to-C0 padding lanes produce defined raw zero
// without a GM access. Physical storage tails remain undefined and are never
// read or written.
// NDF-END: PTO-BSTART-TIMG2COL-DEFINEDNESS-001
