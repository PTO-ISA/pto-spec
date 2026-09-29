<!-- GENERATED FROM: asl/block/model/memory/timg2col-gm.asl -->
# Timg2col Gm

**Normative ASL source:** `asl/block/model/memory/timg2col-gm.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-MEMORY-TIMG2COL-GM}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-memory-timg2col-gm-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the Global Memory (GM) side of `BSTART.TIMG2COL`. TIMG2COL builds an image-to-column matrix: each destination cell is one input pixel of one channel, selected by an output position and a kernel offset.

The unit defines how a source coordinate becomes a GM element index, which coordinates are padding, and the preflight that proves every GM read is legal before any allocation, payload, definedness, or Shared-generation effect. The coordinate arithmetic that produces `hin`, `win`, and the channel lives in the TIMG2COL schema unit; this unit only consumes it.

<!-- PTO-READER-BLOCK: block-model-memory-timg2col-gm-concepts role=concepts-state -->
## Concepts and visible state

The unit holds no state. It is a set of helpers:

- `BundleTIMG2COLSpatialInBounds` is TRUE when `0 <= hin < input_h` and `0 <= win < input_w`.
- `BundleTIMG2COLCinLaneDefined` is TRUE when the channel is below the logical `cin`. Channels from `cin` up to the padded channel block are Cin padding lanes.
- `BundleTIMG2COLGMIndexDN` computes `channel * input_h * input_w + hin * input_w + win`, the NCHW (DN) element index.
- `BundleTIMG2COLGMIndexND` computes `(hin * input_w + win) * input_cin + channel`, the NHWC (ND) element index.
- `BundleTIMG2COLPreflightGM` walks the whole requested rectangle and probes each GM address.

The schema unit selects the DN formula for the `DN2ND`, `CUBE_M16`, and `CUBE_M32` data layouts and the ND formula otherwise.

<!-- PTO-READER-BLOCK: block-model-memory-timg2col-gm-rules role=rules-interactions -->
## Rules and interactions

A cell reads GM only when its spatial coordinate is in bounds and its channel lane is a real channel. A spatial out-of-bounds coordinate or a Cin padding lane yields a raw zero cell with no GM access. `BundleTIMG2COLCell` marks both kinds of cell, and every GM-backed cell, as `defined`, and `BundleTIMG2COLCellIsDefined` returns TRUE unconditionally, so every cell inside the valid rectangle is defined.

Preflight visits every row below `valid_row` and every column below `valid_col`. For each cell that needs GM, it forms `gm_base + gm_index * element_bytes`. If the unsigned result is below `gm_base`, the sum wrapped, and preflight raises `Fault_DataPage` at that address. Otherwise it calls `ProbeTileMemoryAccess` as a read and stops at the first fault that `RaiseDataAccessFault` reports.

Design point: preflight runs before allocation, payload writes, definedness updates, and Shared-generation effects. The execution unit calls it before it picks or allocates a destination. A translation or permission fault therefore leaves no partly built destination behind.

Design point: the execution unit passes the encoded parameters and the full `valid_row` to preflight, not the per-PE row slice. Each PE that has at least one row to write checks the complete rectangle, so no such PE starts reading GM while another PE's part of the footprint would fault. A cooperative PE with zero rows skips preflight and reads nothing.

Design point: padding is produced as a defined zero instead of a memory read. The destination's valid region is completely defined after the build, and no read is issued outside the input image or beyond the real channels.

<!-- PTO-READER-BLOCK: block-model-memory-timg2col-gm-boundaries role=boundaries -->
## Architectural boundaries

`BundleTIMG2COLPhysicalTailDefined` states the boundary for storage outside the valid rectangle: only `row < valid_row` and `col < valid_col` are defined. The contract `PTO-BSTART-TIMG2COL-DEFINEDNESS-001` says physical tails are never read or written, and the build loop in the execution unit only visits the valid rectangle.

This unit does not load payload. The execution unit repeats the same wrap check and probe for each real access, then performs the load and records the load event.

<!-- PTO-READER-BLOCK: block-model-memory-timg2col-gm-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Take FP16 input with `input_h` 4, `input_w` 5, and `cin` 3. For FP16 the channel block holds 16 lanes, so lanes 3 through 15 are padding lanes.

- Channel 2 at `hin` 1, `win` 3 in DN order has index 2 x 4 x 5 + 1 x 5 + 3 = 48, which is byte offset 96 from `gm_base`.
- The same cell in ND order has index (1 x 5 + 3) x 3 + 2 = 26, which is byte offset 52.
- A cell with `hin` equal to -1 (top padding) or with channel 7 is a raw zero and issues no GM access.

<!-- PTO-READER-BLOCK: block-model-memory-timg2col-gm-related role=related-owners-navigation -->
## Related owners

- [TIMG2COL schema](../dispatch/timg2col-schema.md) computes `hin`, `win`, the channel, and the layout choice.
- [TIMG2COL execution](../dispatch/timg2col-execution.md) calls the preflight and performs the loads.
- [TIMG2COL parameters](../operands/timg2col-parameters.md) owns the packed parameter carrier.
- [BSTART.TIMG2COL](../../execution/BSTART.TIMG2COL.md) is the instruction page.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/memory/timg2col-gm.asl -->
```asl
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
```
<!-- GENERATED-ASL-END: unit -->
