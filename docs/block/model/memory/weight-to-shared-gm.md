<!-- GENERATED FROM: asl/block/model/memory/weight-to-shared-gm.asl -->
# Weight To Shared Gm

**Normative ASL source:** `asl/block/model/memory/weight-to-shared-gm.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-MEMORY-WEIGHT-TO-SHARED-GM}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-memory-weight-to-shared-gm-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the Global Memory (GM) side of weight-mode `TLOAD`. Weight mode is selected when `BSTART.TLOAD` carries a `B.DATR` layout of `OHWI2NK` or `OIHW2NK`. It loads a convolution weight tensor into a Shared Tile as an N by K matrix, where N is the output channel and K walks the kernel window and the input channels.

The unit defines how one destination cell maps to a GM element index and the preflight that proves every GM read is legal before any effect.

<!-- PTO-READER-BLOCK: block-model-memory-weight-to-shared-gm-concepts role=concepts-state -->
## Concepts and visible state

The unit holds no state. `BundleWeightTLOADCell` returns a `BundleWeightTLOADCellResult` with four fields: `defined`, `raw_zero`, `gm_access`, and `gm_index`.

For destination row `local_row` and column `local_col`, the cell uses:

- `global_n = n_start + local_row` and `global_k = k_start + local_col`;
- `c0`, the channel-block width, equal to 32 bytes divided by the element size;
- `c1`, the number of channel blocks, equal to `cin` rounded up to a multiple of `c0`, divided by `c0`.

`global_k` is split in `[kh][kw][c1][c0]` order, with `c0` fastest. The lane's input channel is `ci = c1_index * c0 + c0_lane`.

<!-- PTO-READER-BLOCK: block-model-memory-weight-to-shared-gm-rules role=rules-interactions -->
## Rules and interactions

If `ci >= cin`, the cell is a Cin padding lane. It is defined, it is a raw zero, and it has no GM access.

Otherwise the cell reads GM. For `OHWI2NK` the index is `((global_n * kernel_h + kh) * kernel_w + kw) * cin + ci`. For the other weight layout, `OIHW2NK`, it is `((global_n * cin + ci) * kernel_h + kh) * kernel_w + kw`.

`BundleWeightTLOADPreflightGM` visits every row below `row_count` and every column below `col_count`. For each GM cell it forms `gm_base + gm_index * element_bytes`. If the unsigned sum is below `gm_base`, it raises `Fault_DataPage` at that address. Otherwise it probes the address as a read with `ProbeTileMemoryAccess` and stops at the first fault.

Design point: both layouts produce the same K order. The source layout changes only the index formula. A consumer of the loaded Shared Tile therefore sees the same K ordering whether the weights were stored as OHWI or OIHW.

Design point: the execution unit calls preflight with the encoded `n_start` and the full `valid_row`, before it builds the candidate Tile. Its comment states the rule: every participant proves the complete selected-PE footprint before any participant may issue the first GM read. A fault anywhere in the footprint stops the operation before any PE has loaded payload.

Design point: `gm_index` is typed as a wide unsigned integer, and the sum is checked for wrap. An index that would overflow the address space faults instead of silently reading a low address.

<!-- PTO-READER-BLOCK: block-model-memory-weight-to-shared-gm-boundaries role=boundaries -->
## Architectural boundaries

The contract `PTO-BSTART-TLOAD-WEIGHT-DEFINEDNESS-001` states that physical rows and columns outside the valid rectangle stay untouched and undefined. The build loop only visits `valid_row` by `valid_col` cells.

This unit does not check shape legality, split rows across PEs, or publish the Shared Tile. The weight schema and execution units own those steps.

<!-- PTO-READER-BLOCK: block-model-memory-weight-to-shared-gm-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Take FP16 weights with `cin` 3 and a 3 by 3 kernel. For FP16, `c0` is 16 and `c1` is 1, so each kernel position spans 16 K columns.

- `global_k` 34 gives kernel offset 2, so `kh` is 0 and `kw` is 2, and lane 2 gives `ci` 2. For `global_n` 1, the `OHWI2NK` index is ((1 x 3 + 0) x 3 + 2) x 3 + 2 = 35, byte offset 70. The `OIHW2NK` index is ((1 x 3 + 2) x 3 + 0) x 3 + 2 = 47, byte offset 94.
- `global_k` 37 gives lane 5, so `ci` is 5. That is at least `cin`, so the cell is a raw zero with no GM access.

<!-- PTO-READER-BLOCK: block-model-memory-weight-to-shared-gm-related role=related-owners-navigation -->
## Related owners

- [Weight parameters](../operands/weight-to-shared-parameters.md) owns the packed `ShapeGPR` and `StartGPR` fields.
- [Weight schema](../dispatch/weight-to-shared-schema.md) owns `c0`, `c1`, and shape legality.
- [Weight execution](../dispatch/weight-to-shared-execution.md) calls the preflight, loads payload, and publishes.
- [TLOAD](../../../tile/memory-and-data-movement/regular/TLOAD.md) is the instruction page.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/memory/weight-to-shared-gm.asl -->
```asl
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
```
<!-- GENERATED-ASL-END: unit -->
