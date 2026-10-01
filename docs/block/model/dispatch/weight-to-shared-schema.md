<!-- GENERATED FROM: asl/block/model/dispatch/weight-to-shared-schema.asl -->
# Weight To Shared Schema

**Normative ASL source:** `asl/block/model/dispatch/weight-to-shared-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-WEIGHT-TO-SHARED-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-schema-purpose role=purpose-scope -->
## Purpose and scope

This unit defines how the model recognizes a weight-mode `TLOAD` and the pure geometry that mode uses. A weight-mode `TLOAD` copies a crop of a convolution weight tensor from global memory (GM) into a Shared Tile, laid out as an N by K matrix. N is the output channel and K is the flattened kernel position and input channel.

The unit reads no registers and changes no state. [Weight-to-shared execution](weight-to-shared-execution.md) uses these helpers to validate and build the result.

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-schema-concepts role=concepts-state -->
## Selection and derived quantities

`BundleWeightTLOADSelected` is true when the bundle is a Tile-memory operation with decode code zero (the `TLOAD` function), and `B.DATR` is present with layout `OHWI2NK` (code 10) or `OIHW2NK` (code 11). Without such a `B.DATR` layout, the ordinary `TLOAD` path handles the bundle.

- `C0` is the number of elements in 32 bytes: 32 divided by the element size in bytes. FP16 gives 16 and FP32 gives 8.
- `C1` is `Cin` divided by `C0`, rounded up.
- The full K extent is `KernelH * KernelW * C1 * C0`, so each kernel position owns a `C0`-padded channel span.
- `BundleWeightTLOADShape` holds ValidCol, ValidRow, and TotalCol from `B.DIM`, the data type, and the decoded `Cin`, `Cout`, `KernelH`, `KernelW`, NStart, and KStart.

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-schema-rules role=rules-interactions -->
## Shape and row-split rules

`BundleWeightTLOADDataTypeSupported` accepts FP32, TF32, HF32, FP16, BF16, HiF8, E4M3, E5M2, E8M0, S32, S16, S8, U32, U16, and U8.

`BundleWeightTLOADShapeLegal` requires a supported type, ValidCol no larger than TotalCol, `NStart + ValidRow <= Cout`, `KStart + ValidCol` no larger than the full K extent, KStart and ValidCol that are multiples of `C0`, and a TotalCol that is a nonzero power of two.

Design point: KStart and ValidCol are `C0`-aligned, so a crop never splits a 32-byte channel group. Each K window therefore begins on a whole group of the padded channel span.

The row split serves the cooperative case, where several PEs each write part of the N rows. `BundleWeightTLOADRowsForRank` gives each selected PE `ValidRow DIVRM count` rows, plus one more row for each rank below the remainder. `BundleWeightTLOADRowStartForRank` sums the rows of the lower ranks. `BundleWeightTLOADCurrentPERank` counts selected PEs with a lower PE number than the current PE, and asserts that the current PE is selected. `BundleWeightTLOADFirstPE` and `BundleWeightTLOADLastPE` return the lowest and highest selected PE.

Design point: row ranges are contiguous and follow PE order. The NDF clause `PTO-BSTART-TLOAD-WEIGHT-COOPERATIVE-001` requires this, and it lets the first PE open and the last PE close the assembly.

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-schema-boundaries role=boundaries -->
## Architectural boundaries

This unit does not read `B.IOR` registers, check `B.DATR` fields, or probe memory. It does not define the GM index of a cell; [weight-to-shared GM access](../memory/weight-to-shared-gm.md) does. It does not decide publication; the execution unit does.

`BundleWeightTLOADSelected` is also read outside this unit. For example, [Tile schema](tile-schema.md) rejects a weight layout on any other operation, and [Tile execution](tile-execution.md) uses it to route the bundle before generic stage-2 preparation.

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-schema-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Take FP16 weights with `Cin` 20, `Cout` 64, and a 3 by 3 kernel. `C0` is 16, `C1` is 2, and the full K extent is 9 * 2 * 16 = 288. KStart 32 and ValidCol 64 are legal because both are multiples of 16 and 96 <= 288. KStart 40 is illegal because it is not a multiple of 16.

With four selected PEs and ValidRow 10, the base is 2 and the remainder is 2. Ranks 0 and 1 get 3 rows, and ranks 2 and 3 get 2 rows. Their row starts are 0, 3, 6, and 8.

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-schema-related role=related-owners-navigation -->
## Related owners

- [Weight-to-shared execution](weight-to-shared-execution.md) validates the bundle and publishes the Shared Tile.
- [Weight-to-shared parameters](../operands/weight-to-shared-parameters.md) unpacks the shape and start words.
- [Weight-to-shared GM access](../memory/weight-to-shared-gm.md) maps each cell to an OHWI or OIHW GM index.
- [BSTART.TLOAD](../../execution/BSTART.TLOAD.md) is the instruction page for the load bundle.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/weight-to-shared-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-WEIGHT-TO-SHARED-SCHEMA","surface":"block","classification":["model","dispatch","weight-to-shared-schema"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-WEIGHT-PARAMETERS","PTO-BLOCK-B-DATR","PTO-BLOCK-B-DIM","PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}
// PTO-BSTART-TLOAD-WEIGHT-NK-CONTRACT-001 owns the specialized carrier
// selection and the NK physical descriptor shape.  The generic TLOAD carrier
// remains the fallback whenever this explicit B.DATR layout is absent.
type BundleWeightTLOADShape of record {
    valid_col: integer {1..65535},
    valid_row: integer {1..65535},
    total_col: integer {1..65535},
    data_type: TileDataType,
    cin: integer {1..65535},
    cout: integer {1..65535},
    kernel_h: integer {1..255},
    kernel_w: integer {1..255},
    n_start: integer {0..4294967295},
    k_start: integer {0..4294967295}
};

readonly func BundleWeightTLOADSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           BundleOperationDecodeCode(_BundleOperation) == Zeros{12} &&
           _BundleDataAttributesPresent &&
           TileDataLayoutIsWeightTLOAD(TileDataLayoutOfCode(
               _BundleDataAttributes.data_layout));
end;

pure func BundleWeightTLOADDataTypeSupported(data_type: TileDataType)
    => boolean
begin
    case data_type of
        when TileDataType_FP32, TileDataType_TF32, TileDataType_HF32,
             TileDataType_FP16, TileDataType_BF16, TileDataType_HiF8,
             TileDataType_E4M3, TileDataType_E5M2, TileDataType_E8M0,
             TileDataType_S32, TileDataType_S16, TileDataType_S8,
             TileDataType_U32, TileDataType_U16, TileDataType_U8 =>
            return TRUE;
        otherwise => return FALSE;
    end;
end;

pure func BundleWeightTLOADC0Elements(data_type: TileDataType) => integer
begin
    return (32 DIVRM TileElementBytes(data_type)) as integer {4,8,16,32};
end;

pure func BundleWeightTLOADC1(cin: integer {1..65535},
                              data_type: TileDataType) => integer
begin
    let c0 = BundleWeightTLOADC0Elements(data_type);
    return ((cin + (c0 - 1)) DIVRM c0) as integer {1..16384};
end;

pure func BundleWeightTLOADKFull(cin: integer {1..65535},
                                 kernel_h: integer {1..255},
                                 kernel_w: integer {1..255},
                                 data_type: TileDataType) => integer
begin
    let c0 = BundleWeightTLOADC0Elements(data_type);
    let c1 = BundleWeightTLOADC1(cin, data_type);
    return (kernel_h * kernel_w * c1 * c0) as integer {1..18446744073709551615};
end;

pure func BundleWeightTLOADShapeLegal(shape: BundleWeightTLOADShape) => boolean
begin
    let c0 = BundleWeightTLOADC0Elements(shape.data_type);
    let k_full = BundleWeightTLOADKFull(shape.cin, shape.kernel_h,
        shape.kernel_w, shape.data_type);
    return BundleWeightTLOADDataTypeSupported(shape.data_type) &&
           shape.valid_col <= shape.total_col &&
           shape.n_start + shape.valid_row <= shape.cout &&
           shape.k_start + shape.valid_col <= k_full &&
           (shape.k_start MOD c0) == 0 &&
           (shape.valid_col MOD c0) == 0 &&
           IsNonzeroPowerOfTwo(shape.total_col);
end;

readonly func BundleWeightTLOADPEBit() => bits(4)
begin
    var result = Zeros{4};
    result[PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent)] = '1';
    return result;
end;

pure func BundleWeightTLOADSelectedPECount(mask: bits(4)) => integer {1..4}
begin
    return PEMaskPopulation(mask) as integer {1..4};
end;

readonly func BundleWeightTLOADCurrentPERank(mask: bits(4)) => integer {0..3}
begin
    var rank: integer {0..3} = 0;
    let current = PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent);
    for pe = 0 to 3 looplimit 4 do
        if pe < (_CurrentMemoryAgent as integer {0..3}) &&
           mask[PTOPEMaskBitOfPEIdentity(pe as MemoryAgentId)] == '1' then
            rank = (rank + 1) as integer {0..3};
        end;
    end;
    assert mask[current] == '1';
    return rank;
end;

pure func BundleWeightTLOADRowsForRank(valid_row: integer {1..65535},
                                       mask: bits(4), rank: integer {0..3})
                                       => integer {0..65535}
begin
    let count = BundleWeightTLOADSelectedPECount(mask);
    let base = (valid_row DIVRM count) as integer {0..65535};
    let remainder = (valid_row MOD count) as integer {0..3};
    return (base + (if rank < remainder then 1 else 0))
        as integer {0..65535};
end;

pure func BundleWeightTLOADRowStartForRank(
    n_start: integer {0..4294967295}, valid_row: integer {1..65535},
    mask: bits(4), rank: integer {0..3}) => integer
begin
    var result: integer = n_start;
    for previous = 0 to 2 looplimit 3 do
        if previous < rank then
            result = result + BundleWeightTLOADRowsForRank(
                valid_row, mask, previous);
        end;
    end;
    return result;
end;

pure func BundleWeightTLOADFirstPE(mask: bits(4)) => integer {0..3}
begin
    for pe = 0 to 3 looplimit 4 do
        if mask[PTOPEMaskBitOfPEIdentity(pe as MemoryAgentId)] == '1' then
            return pe as integer {0..3};
        end;
    end;
    return 0;
end;

pure func BundleWeightTLOADLastPE(mask: bits(4)) => integer {0..3}
begin
    var result: integer {0..3} = 0;
    for pe = 0 to 3 looplimit 4 do
        if mask[PTOPEMaskBitOfPEIdentity(pe as MemoryAgentId)] == '1' then
            result = pe as integer {0..3};
        end;
    end;
    return result;
end;
```
<!-- GENERATED-ASL-END: unit -->
