<!-- GENERATED FROM: asl/block/model/operands/timg2col-parameters.asl -->
# Timg2col Parameters

**Normative ASL source:** `asl/block/model/operands/timg2col-parameters.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-TIMG2COL-PARAMETERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-operands-timg2col-parameters-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the parameter carrier of `BSTART.TIMG2COL`. The convolution geometry travels in general-purpose registers (GPRs) named by two `B.IOR` records. This unit defines the record shape, the bit packing of the three parameter GPRs, the checks on that packing, and the metadata word used by a cooperative Shared build.

<!-- PTO-READER-BLOCK: block-model-operands-timg2col-parameters-concepts role=concepts-state -->
## Concepts and visible state

The unit declares two records and no state variables.

`BundleTIMG2COLParameters` is the decoded geometry. `BundleTIMG2COLParametersFromWords` fills it from three 64-bit words:

| Word | Bits | Fields |
| --- | --- | --- |
| `ParamGPR0` | 0..63 | `input_h` 15:0, `input_w` 31:16, `cin` 47:32, `kernel_h` 55:48, `kernel_w` 63:56 |
| `ParamGPR1` | 0..63 | `pad_top`, `pad_left`, `pad_bottom`, `pad_right` in bytes 0..3, `dilation_h` 36:32, `dilation_w` 41:37, `conv_stride_h` 47:42, `conv_stride_w` 53:48, `param_version` 58:55, `extension_class` 62:59 |
| `ParamGPR2` | 0..63 | `row_start` 31:0, `col_start` 63:32 |

`BundleTIMG2COLIORRecord` is the source-only view of one `B.IOR` record: three source selectors and one destination selector.

<!-- PTO-READER-BLOCK: block-model-operands-timg2col-parameters-rules role=rules-interactions -->
## Rules and interactions

The carrier is exactly two records. The first names `GMBase`, zero, zero. The second names `ParamGPR0`, `ParamGPR1`, `ParamGPR2`. Both destination selectors must be zero, and every used source selector must name a real absolute GPR. `BundleTIMG2COLIORRecordsLegal` and `BundleTIMG2COLIORStreamPreflight` state these conditions.

`BundleTIMG2COLBaseParameterExtensionLegal` requires `ParamGPR1` bit 54, bit 63, `param_version`, and `extension_class` to be zero. `BundleTIMG2COLParametersLegal` then requires nonzero `input_h`, `input_w`, `cin`, kernel sizes, dilations, and strides.

`BundleTIMG2COLParticipantValuesEqual(mask)` reads `GMBase` and the three parameter words from every PE selected by the mask. It is TRUE only when at least one PE is selected and all selected PEs hold identical values.

Design point: parameters are compared across PEs before use. Each PE reads its own GPR copy, and a cooperative build has each PE compute a different row slice from the same geometry. Requiring equal values means all slices belong to one well-defined matrix. A mismatch rejects before any GM access.

Design point: the version and extension fields must be zero in the base version. A nonzero value rejects the operation before GM access, allocation, generation creation, payload, or publication, as the contract `PTO-BSTART-TIMG2COL-PARAMS-001` states. Those bits are not ignored, so they cannot be given a meaning silently.

`BundleTIMG2COLGenerationMetadata` packs source layout, data type, `valid_col`, `valid_row`, `total_col`, size code, and Shared Tile ID into one word. The execution unit passes it with the parameter words to the Shared-generation checks, so every cooperative writer must agree on it.

<!-- PTO-READER-BLOCK: block-model-operands-timg2col-parameters-boundaries role=boundaries -->
## Architectural boundaries

All checks here are called by `BundleTIMG2COLStateLegal` in the execution unit. That function reads the words, applies these checks, and then checks shape legality. The command handler also enforces placement: while the second record is expected, the next header command must be `B.IOR`, so the two records are contiguous.

`BundleTIMG2COLParameterGPR0`, `GPR1`, and `GPR2` return the same fields as tuples. In the current ASL they are exercised by tests, not by the execution path.

<!-- PTO-READER-BLOCK: block-model-operands-timg2col-parameters-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A 56 by 56 input with 64 channels and a 3 by 3 kernel packs `ParamGPR0` as `0x0303_0040_0038_0038`. Stride 1, dilation 1, and padding 1 on each side pack `ParamGPR1` as `0x0001_0421_0101_0101`: bits 32 and 37 hold the dilations, bits 42 and 48 hold the strides. Bits 54 through 63 are zero, so the extension check passes.

<!-- PTO-READER-BLOCK: block-model-operands-timg2col-parameters-related role=related-owners-navigation -->
## Related owners

- [TIMG2COL execution](../dispatch/timg2col-execution.md) reads and checks the carrier.
- [TIMG2COL schema](../dispatch/timg2col-schema.md) checks the resulting shape.
- [Scalar schema](../dispatch/scalar-schema.md) enforces the two-record placement.
- [B.IOR](../../operands/B.IOR.md) is the command page.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/timg2col-parameters.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-TIMG2COL-PARAMETERS","surface":"block","classification":["model","operands","timg2col-parameters"],"depends_on":["PTO-BLOCK-B-IOR","PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES"]}
// PTO-BSTART-TIMG2COL-PARAMS-001 owns the packed parameter carrier.  The
// source-only B.IOR record shape is intentionally represented separately from
// the values carried by the three parameter GPRs.
type BundleTIMG2COLParameters of record {
    input_h: integer {0..65535},
    input_w: integer {0..65535},
    cin: integer {0..65535},
    kernel_h: integer {0..255},
    kernel_w: integer {0..255},
    pad_top: integer {0..255},
    pad_left: integer {0..255},
    pad_bottom: integer {0..255},
    pad_right: integer {0..255},
    dilation_h: integer {0..31},
    dilation_w: integer {0..31},
    conv_stride_h: integer {0..63},
    conv_stride_w: integer {0..63},
    param_version: integer {0..15},
    extension_class: integer {0..15},
    row_start: integer {0..4294967295},
    col_start: integer {0..4294967295}
};

type BundleTIMG2COLIORRecord of record {
    reg_src0: Reg5Selector,
    reg_src1: Reg5Selector,
    reg_src2: Reg5Selector,
    reg_dst: Reg5Selector
};

pure func BundleTIMG2COLParameterGPR0(value: Word)
    => (integer {0..65535}, integer {0..65535}, integer {0..65535},
        integer {0..255}, integer {0..255})
begin
    return (UInt(value[15:0]) as integer {0..65535},
            UInt(value[31:16]) as integer {0..65535},
            UInt(value[47:32]) as integer {0..65535},
            UInt(value[55:48]) as integer {0..255},
            UInt(value[63:56]) as integer {0..255});
end;

pure func BundleTIMG2COLParameterGPR1(value: Word)
    => (integer {0..255}, integer {0..255}, integer {0..255}, integer {0..255},
        integer {0..31}, integer {0..31}, integer {0..63}, integer {0..63},
        bits(1), integer {0..15}, integer {0..15}, bits(1))
begin
    return (UInt(value[7:0]) as integer {0..255},
            UInt(value[15:8]) as integer {0..255},
            UInt(value[23:16]) as integer {0..255},
            UInt(value[31:24]) as integer {0..255},
            UInt(value[36:32]) as integer {0..31},
            UInt(value[41:37]) as integer {0..31},
            UInt(value[47:42]) as integer {0..63},
            UInt(value[53:48]) as integer {0..63},
            value[54:54],
            UInt(value[58:55]) as integer {0..15},
            UInt(value[62:59]) as integer {0..15},
            value[63:63]);
end;

pure func BundleTIMG2COLParameterGPR2(value: Word)
    => (integer {0..4294967295}, integer {0..4294967295})
begin
    return (UInt(value[31:0]) as integer {0..4294967295},
            UInt(value[63:32]) as integer {0..4294967295});
end;

pure func BundleTIMG2COLParametersFromWords(
    param0: Word, param1: Word, param2: Word) => BundleTIMG2COLParameters
begin
    return BundleTIMG2COLParameters {
        input_h = UInt(param0[15:0]), input_w = UInt(param0[31:16]),
        cin = UInt(param0[47:32]), kernel_h = UInt(param0[55:48]),
        kernel_w = UInt(param0[63:56]), pad_top = UInt(param1[7:0]),
        pad_left = UInt(param1[15:8]), pad_bottom = UInt(param1[23:16]),
        pad_right = UInt(param1[31:24]), dilation_h = UInt(param1[36:32]),
        dilation_w = UInt(param1[41:37]),
        conv_stride_h = UInt(param1[47:42]),
        conv_stride_w = UInt(param1[53:48]),
        param_version = UInt(param1[58:55]),
        extension_class = UInt(param1[62:59]),
        row_start = UInt(param2[31:0]), col_start = UInt(param2[63:32])
    };
end;

pure func BundleTIMG2COLBaseParameterExtensionLegal(param1: Word) => boolean
begin
    return param1[54] == '0' && param1[63] == '0' &&
           param1[58:55] == Zeros{4} && param1[62:59] == Zeros{4};
end;

pure func BundleTIMG2COLGenerationMetadata(
    source_layout: bits(5), data_type: bits(5), valid_col: bits(16),
    valid_row: bits(8), total_col: bits(16), size_code: bits(4),
    shared_tile_id: bits(6)) => Word
begin
    var metadata = Zeros{PTO_XLEN};
    metadata[4:0] = source_layout;
    metadata[9:5] = data_type;
    metadata[25:10] = valid_col;
    metadata[33:26] = valid_row;
    metadata[49:34] = total_col;
    metadata[53:50] = size_code;
    metadata[59:54] = shared_tile_id;
    return metadata;
end;

readonly func BundleTIMG2COLParticipantValuesEqual(mask: bits(4)) => boolean
begin
    var reference_valid = FALSE;
    var reference_gm_base: Word = Zeros{PTO_XLEN};
    var reference_param0: Word = Zeros{PTO_XLEN};
    var reference_param1: Word = Zeros{PTO_XLEN};
    var reference_param2: Word = Zeros{PTO_XLEN};
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        if mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' then
            let gm_base = ReadPEAbsoluteGPROperand(
                agent, _BundleScalarBindings[[0]].source0);
            let param0 = ReadPEAbsoluteGPROperand(
                agent, _BundleScalarBindings[[1]].source0);
            let param1 = ReadPEAbsoluteGPROperand(
                agent, _BundleScalarBindings[[1]].source1);
            let param2 = ReadPEAbsoluteGPROperand(
                agent, _BundleScalarBindings[[1]].source2);
            if !reference_valid then
                reference_valid = TRUE;
                reference_gm_base = gm_base;
                reference_param0 = param0;
                reference_param1 = param1;
                reference_param2 = param2;
            elsif gm_base != reference_gm_base || param0 != reference_param0 ||
                  param1 != reference_param1 || param2 != reference_param2 then
                return FALSE;
            end;
        end;
    end;
    return reference_valid;
end;

readonly func BundleTIMG2COLIORBindingsPreflight(mask: bits(4)) => boolean
begin
    let first = BundleTIMG2COLIORRecord {
        reg_src0 = _BundleScalarBindings[[0]].source0,
        reg_src1 = _BundleScalarBindings[[0]].source1,
        reg_src2 = _BundleScalarBindings[[0]].source2,
        reg_dst = _BundleScalarBindings[[0]].destination
    };
    let second = BundleTIMG2COLIORRecord {
        reg_src0 = _BundleScalarBindings[[1]].source0,
        reg_src1 = _BundleScalarBindings[[1]].source1,
        reg_src2 = _BundleScalarBindings[[1]].source2,
        reg_dst = _BundleScalarBindings[[1]].destination
    };
    if !BundleTIMG2COLIORRecordsLegal(first, second, 2) then return FALSE; end;
    let values_equal = BundleTIMG2COLParticipantValuesEqual(mask);
    return BundleTIMG2COLIORStreamPreflight(first, second, 2, TRUE,
        values_equal, values_equal);
end;

pure func BundleTIMG2COLParametersLegal(
    parameters: BundleTIMG2COLParameters) => boolean
begin
    return parameters.input_h != 0 && parameters.input_w != 0 &&
           parameters.cin != 0 && parameters.kernel_h != 0 &&
           parameters.kernel_w != 0 && parameters.dilation_h != 0 &&
           parameters.dilation_w != 0 && parameters.conv_stride_h != 0 &&
           parameters.conv_stride_w != 0 && parameters.param_version == 0 &&
           parameters.extension_class == 0;
end;

pure func BundleTIMG2COLIORRecordsLegal(
    first: BundleTIMG2COLIORRecord,
    second: BundleTIMG2COLIORRecord,
    record_count: integer {0..3}) => boolean
begin
    return record_count == 2 &&
           first.reg_src1 == 0 && first.reg_src2 == 0 && first.reg_dst == 0 &&
           second.reg_dst == 0 &&
           first.reg_src0 < PTO_ABSOLUTE_GPR_COUNT &&
           second.reg_src0 < PTO_ABSOLUTE_GPR_COUNT &&
           second.reg_src1 < PTO_ABSOLUTE_GPR_COUNT &&
           second.reg_src2 < PTO_ABSOLUTE_GPR_COUNT;
end;

pure func BundleTIMG2COLIORRecordIsSourceOnly(
    entry: BundleTIMG2COLIORRecord) => boolean
begin
    return entry.reg_dst == 0 &&
           entry.reg_src0 < PTO_ABSOLUTE_GPR_COUNT &&
           entry.reg_src1 < PTO_ABSOLUTE_GPR_COUNT &&
           entry.reg_src2 < PTO_ABSOLUTE_GPR_COUNT;
end;

pure func BundleTIMG2COLIORStreamPreflight(
    first: BundleTIMG2COLIORRecord,
    second: BundleTIMG2COLIORRecord,
    record_count: integer {0..3}, contiguous: boolean,
    gm_base_equal: boolean, parameters_equal: boolean) => boolean
begin
    return record_count == 2 && contiguous && gm_base_equal &&
           parameters_equal && first.reg_src1 == 0 && first.reg_src2 == 0 &&
           BundleTIMG2COLIORRecordIsSourceOnly(first) &&
           BundleTIMG2COLIORRecordIsSourceOnly(second);
end;

// NDF-BEGIN: PTO-BSTART-TIMG2COL-PARAMS-001
// ndf: kind=contract level=L1 layer=block status=accepted
// Exactly two immediately contiguous source-only B.IOR records carry the
// 64-bit GMBase and the three packed parameter GPR values. The first record
// uses GMBase, zero, zero; the second uses ParamGPR0, ParamGPR1, ParamGPR2.
// The base parameter version requires ParamGPR1 bit 54, ParamVersion,
// ExtensionClass, and bit 63 to be zero; any nonzero extension value rejects
// before GM access, allocation, generation creation, payload, or publication.
// Missing, reordered, interleaved, destination-bearing, differently split, or
// surplus records reject before GM access, allocation, or publication.
// NDF-END: PTO-BSTART-TIMG2COL-PARAMS-001
```
<!-- GENERATED-ASL-END: unit -->
