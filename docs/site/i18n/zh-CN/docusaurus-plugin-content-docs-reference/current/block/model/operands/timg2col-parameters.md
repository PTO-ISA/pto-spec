<!-- GENERATED FROM: asl/block/model/operands/timg2col-parameters.asl -->
# Timg2col Parameters

**Normative ASL source:** `asl/block/model/operands/timg2col-parameters.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-TIMG2COL-PARAMETERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-operands-timg2col-parameters-purpose role=purpose-scope -->
## 用途与范围

本单元拥有 `BSTART.TIMG2COL` 的参数载体。卷积几何通过由两条 `B.IOR` 记录指名的通用寄存器（GPR）传递。本单元定义记录的形状、三个参数 GPR 的位打包、对该打包的检查，以及协作式 Shared 构建所用的元数据字。

<!-- PTO-READER-BLOCK: block-model-operands-timg2col-parameters-concepts role=concepts-state -->
## 概念与可见状态

本单元声明两个记录，不声明状态变量。

`BundleTIMG2COLParameters` 是解码后的几何。`BundleTIMG2COLParametersFromWords` 从三个 64 位字填充它：

| 字 | 位 | 字段 |
| --- | --- | --- |
| `ParamGPR0` | 0..63 | `input_h` 15:0，`input_w` 31:16，`cin` 47:32，`kernel_h` 55:48，`kernel_w` 63:56 |
| `ParamGPR1` | 0..63 | 字节 0..3 中的 `pad_top`、`pad_left`、`pad_bottom`、`pad_right`，`dilation_h` 36:32，`dilation_w` 41:37，`conv_stride_h` 47:42，`conv_stride_w` 53:48，`param_version` 58:55，`extension_class` 62:59 |
| `ParamGPR2` | 0..63 | `row_start` 31:0，`col_start` 63:32 |

`BundleTIMG2COLIORRecord` 是一条 `B.IOR` 记录的只含源视图：三个源选择子和一个目标选择子。

<!-- PTO-READER-BLOCK: block-model-operands-timg2col-parameters-rules role=rules-interactions -->
## 规则与交互

载体恰好是两条记录。第一条指名 `GMBase`、零、零。第二条指名 `ParamGPR0`、`ParamGPR1`、`ParamGPR2`。两个目标选择子都必须为零，每个使用的源选择子都必须指名一个真实的绝对 GPR。`BundleTIMG2COLIORRecordsLegal` 和 `BundleTIMG2COLIORStreamPreflight` 表述了这些条件。

`BundleTIMG2COLBaseParameterExtensionLegal` 要求 `ParamGPR1` 的位 54、位 63、`param_version` 和 `extension_class` 为零。随后 `BundleTIMG2COLParametersLegal` 要求 `input_h`、`input_w`、`cin`、卷积核大小、膨胀和步长都非零。

`BundleTIMG2COLParticipantValuesEqual(mask)` 从掩码选中的每个 PE 读取 `GMBase` 和三个参数字。只有当至少选中一个 PE 且所有选中的 PE 持有相同值时，它才为 TRUE。

设计要点：参数在使用之前跨 PE 比较。每个 PE 读取自己的 GPR 副本，而协作构建让每个 PE 从同一几何计算不同的行切片。要求值相等意味着所有切片属于同一个定义明确的矩阵。不匹配会在任何 GM 访问之前被拒绝。

设计要点：在基础版本中，版本和扩展字段必须为零。如契约 `PTO-BSTART-TIMG2COL-PARAMS-001` 所述，非零值会在 GM 访问、分配、代次创建、载荷或发布之前拒绝该操作。这些位不会被忽略，因此不能被悄悄赋予含义。

`BundleTIMG2COLGenerationMetadata` 把源布局、数据类型、`valid_col`、`valid_row`、`total_col`、大小码和 Shared Tile ID 打包到一个字中。执行单元把它与参数字一起传给 Shared 代次检查，因此每个协作写者都必须在它上面达成一致。

<!-- PTO-READER-BLOCK: block-model-operands-timg2col-parameters-boundaries role=boundaries -->
## 架构边界

这里的所有检查都由执行单元中的 `BundleTIMG2COLStateLegal` 调用。该函数读取这些字，应用这些检查，然后检查形状合法性。命令处理程序还强制放置规则：在期待第二条记录时，下一条头部命令必须是 `B.IOR`，因此两条记录是连续的。

`BundleTIMG2COLParameterGPR0`、`GPR1` 和 `GPR2` 以元组形式返回相同的字段。在当前 ASL 中，它们由测试使用，而不在执行路径中使用。

<!-- PTO-READER-BLOCK: block-model-operands-timg2col-parameters-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

一个 56 乘 56、64 通道、3 乘 3 卷积核的输入把 `ParamGPR0` 打包为 `0x0303_0040_0038_0038`。步长 1、膨胀 1、每边填充 1 把 `ParamGPR1` 打包为 `0x0001_0421_0101_0101`：位 32 和 37 保存膨胀，位 42 和 48 保存步长。位 54 到 63 为零，因此扩展检查通过。

<!-- PTO-READER-BLOCK: block-model-operands-timg2col-parameters-related role=related-owners-navigation -->
## 相关所有者

- [TIMG2COL 执行](../dispatch/timg2col-execution.md)读取并检查该载体。
- [TIMG2COL schema](../dispatch/timg2col-schema.md) 检查得到的形状。
- [标量 schema](../dispatch/scalar-schema.md) 强制两条记录的放置规则。
- [B.IOR](../../operands/B.IOR.md) 是命令页面。
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
