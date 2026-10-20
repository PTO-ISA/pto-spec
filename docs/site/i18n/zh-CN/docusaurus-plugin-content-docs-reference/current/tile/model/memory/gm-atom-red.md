<!-- GENERATED FROM: asl/tile/model/memory/gm-atom-red.asl -->
# Gm Atom Red

**Normative ASL source:** `asl/tile/model/memory/gm-atom-red.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-GM-ATOM-RED}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-purpose role=purpose-scope -->
## 作用与范围

本单元定义 GM atom/red 族的词汇：操作枚举、操作/类型矩阵、逐元素结果规则，以及操作数合法性谓词。执行体位于 GM atom/red execution 单元。

- atom 形式对每个通道执行一次原子读-改-写，并把每个旧值返回到目标 Tile。
- red（归约）形式执行同类更新，但没有目标。

它还包含旧式 `MGATHER_CAS` 拼写的 NDF 条款，以及该族编码、主体 schema、类型合法性、INC/DEC 与 POPC 语义、排序与故障的条款。

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-concepts role=concepts-state -->
## 概念与可见状态

`GMAtomicOperation` 列出 CAS、EXCH、MAX、MIN、ADD、INC、DEC、AND、OR 与 XOR。`GMReductionOperation` 列出 MAX、MIN、ADD、INC、DEC、AND、OR、XOR 与 POPC；它没有 CAS 或 EXCH。

每个操作接受的元素类型是固定的：

| 操作 | 接受的类型 |
| --- | --- |
| CAS（仅 atom） | U16, U32, U64 |
| EXCH（仅 atom） | U32, U64 |
| ADD | FP16, BF16, FP32, FP64, S32, U32, U64 |
| MAX, MIN | S32, S64, U32, U64 |
| AND, OR, XOR | U32, U64 |
| INC, DEC | U32 |
| POPC（仅 red） | U32 |

该矩阵中没有四位或 8 位类型。

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-rules role=rules-interactions -->
## 规则与交互

`GMAtomicResult` 返回新值以及是否发生写入。

- CAS 在元素宽度上（`GMRawElementValue`）比较旧值与 `expected`，仅在匹配时写入 `replacement`；否则报告不写入。
- EXCH 无条件写入新值。
- 整数 ADD 把两个元素宽度的原始值相加；随后的存储截断到元素宽度，因此会回绕。
- MAX 与 MIN 对 S32 与 S64 按有符号比较，其他情况按无符号比较。
- AND、OR 与 XOR 为按位运算。
- INC 与 DEC 使用 `GMIncValue` 与 `GMDecValue`，以通道值作为上限。

设计要点：INC 与 DEC 是带显式上限的回绕计数器（NDF `PTO-ATOM-RED-INC-DEC-SEMANTICS-001`）。当旧值达到或超过上限时，INC 返回 0。当旧值为 0 或超过上限时，DEC 返回上限。因此计数器在 `0..limit` 内循环，而不是在类型宽度处回绕。

浮点 ADD 调用 `GMFloatingAddPTX`，这是一个实现定义的钩子。其注释指明了冻结的 PTX 派生配置档：就近舍入到偶数，FP16 与 BF16 不做清零，FP32 全局原子做清零。该钩子的模型函数体把原始字相加，并不是浮点加法。

四个 `TileOperandsLegal_GM_*` 谓词都要求索引内容已定义，且索引为 S32、U32、S64 或 U64。CAS、VALUE 与 red VALUE 形式还要求类型对该操作合法、所绑定的各数据 Tile 数据类型相同，并且这些 Tile 有效形状与布局相同；两个 atom 形式还要求目标描述符合法。`TileOperandsLegal_GM_RED_POPC` 只检查索引 Tile。

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-boundaries role=boundaries -->
## 架构边界

类型矩阵排除 Shared 操作数、向量、打包的 FP16x2 与 BF16x2，以及 U128（NDF `PTO-ATOM-RED-TYPE-LEGALITY-001`）。块分派器在任何效果之前以 `Fault_TileLegality` 拒绝其他组合。

这些函数不访问内存。探测、排序、重复地址串行化与事件记录属于执行单元与架构内存模型。

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-example role=example-usage -->
## 非规范阅读示例

上限为 3 的 U32 INC：

- 旧值 0 得 1，旧值 2 得 3，旧值 3 得 0，旧值 7 得 0。

上限为 3 的 U32 DEC：

- 旧值 0 得 3，旧值 2 得 1，旧值 7 得 3。

旧值 `0xFFFFFFFF`、加数 2 的 U32 ADD 计算得 `0x100000001`；4 字节存储写入 `0x00000001`。

旧值 `0xFFFFFFFF`（-1）、值 1 的 S32 MAX 保留 1，因为比较是有符号的。相同位模式的 U32 MAX 保留 `0xFFFFFFFF`。

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-related role=related-owners-navigation -->
## 相关归属

- [GM atom/red execution](gm-atom-red-execution.md) 对内存执行这些规则。
- [Atomics](atomics.md) 拥有 `MGATHER_CAS` 执行体。
- [Addressing](addressing.md) 拥有字节位移地址。
- [Memory atomicity](../../../arch/memory-model/atomicity.md) 拥有原子事件。
- [Block GM atom/red dispatch](../../../block/model/dispatch/tlsu-gm-atom-red.md) 拥有指令束 schema 检查。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/gm-atom-red.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-GM-ATOM-RED","surface":"tile","classification":["model","memory","gm-atom-red"],"depends_on":["PTO-ARCH-DATA-TYPES-NUMERIC-CLASSIFICATION","PTO-ARCH-DATA-TYPES-NUMERIC-FORMATS","PTO-ARCH-FEATURES-MX-FORMATS","PTO-TILE-MODEL-MEMORY-ATOMICS","PTO-TILE-MODEL-EXECUTION-ELEMENTWISE","PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA"]}
// NDF-BEGIN: PTO-MGATHER-CAS-ATOMIC-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// The legacy MGATHER_CAS spelling aliases mgather.cas and MUST accept only
// U16, U32, and U64 transfer DataTypes. Each valid request MUST perform one
// atomic compare-and-swap at its signed or unsigned byte displacement and
// place the value observed by that request in the corresponding destination
// element. Duplicate-address requests MUST serialize in an implementation-
// defined order and MUST NOT expose a fixed row-major ordering requirement.
// NDF-END: PTO-MGATHER-CAS-ATOMIC-001
// NDF-BEGIN: PTO-MGATHER-CAS-PUBLICATION-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// The legacy MGATHER_CAS spelling MUST preflight every valid-region read and
// write address before its first atomic effect. On success it MUST publish
// one fully defined destination whose non-valid physical elements contain the
// selected pad value.
// NDF-END: PTO-MGATHER-CAS-PUBLICATION-001
// NDF-BEGIN: PTO-ATOM-RED-ENCODING-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TLSU Functions 8 through 27 select the GM atom/red family with the fixed
// low carrier 0x11181 and mask 0x07ffffff; 28 through 31 remain reserved.
// NDF-END: PTO-ATOM-RED-ENCODING-001
// NDF-BEGIN: PTO-ATOM-RED-BODY-SCHEMA-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Atom forms bind a destination-bearing Local B.IOT; red forms bind only
// source tiles. mscatter.popc has indices only and no ValueTile.
// NDF-END: PTO-ATOM-RED-BODY-SCHEMA-001
// NDF-BEGIN: PTO-ATOM-RED-TYPE-LEGALITY-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// The GM operation/type matrix is explicit and excludes Shared, vectors,
// packed f16x2/bf16x2, and U128.
// NDF-END: PTO-ATOM-RED-TYPE-LEGALITY-001
// NDF-BEGIN: PTO-ATOM-RED-INC-DEC-SEMANTICS-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// INC and DEC are U32 limit operations: inc returns zero at or above the
// limit, while dec returns the limit for zero or above-limit old values.
// NDF-END: PTO-ATOM-RED-INC-DEC-SEMANTICS-001
// NDF-BEGIN: PTO-ATOM-RED-POPC-SEMANTICS-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// mscatter.popc contributes one U32 increment per valid effective GM address and
// has no ValueTile or destination.
// NDF-END: PTO-ATOM-RED-POPC-SEMANTICS-001
// NDF-BEGIN: PTO-ATOM-RED-ORDERING-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Every valid request is one intrinsic atomic event; duplicate effective
// addresses serialize in implementation-defined order and all are effective.
// All address probes complete before the first event or local publication.
// NDF-END: PTO-ATOM-RED-ORDERING-001
// NDF-BEGIN: PTO-ATOM-RED-FAULTS-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Reserved encodings fault IllegalInstruction, unsupported tuples fault
// TileLegality, malformed bundles fault BundleControl, and alignment/page
// failures are preflighted before any architectural effect.
// NDF-END: PTO-ATOM-RED-FAULTS-001

// NDF-BEGIN: PTO-GM-FLOATING-ADD-NUMERIC-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// GM FP16/BF16/FP32/FP64 ADD MUST preserve subnormal inputs and round once per
// RMW to its own dtype using RN-even with gradual-underflow results. This
// accepted issue #397 N1 amendment supersedes issue #208's FP32 GM FTZ rule.
// NaN operands or opposite infinities MUST yield the format canonical NaN;
// other infinity sums MUST retain infinity. Overflow MUST yield signed
// infinity. Minus zero plus minus zero MUST yield minus zero; other exact
// cancellation MUST yield plus zero. Narrow carriers MUST ignore high bits.
// Indexed atom.add/red.add and strided atomic TSTORE MUST share the readonly
// helper and MUST NOT introduce numeric-status writes or scalar results.
// NDF-END: PTO-GM-FLOATING-ADD-NUMERIC-001

type GMAtomicOperation of enumeration {
    GMAtomic_CAS,
    GMAtomic_EXCH,
    GMAtomic_MAX,
    GMAtomic_MIN,
    GMAtomic_ADD,
    GMAtomic_INC,
    GMAtomic_DEC,
    GMAtomic_AND,
    GMAtomic_OR,
    GMAtomic_XOR
};

type GMReductionOperation of enumeration {
    GMReduction_MAX,
    GMReduction_MIN,
    GMReduction_ADD,
    GMReduction_INC,
    GMReduction_DEC,
    GMReduction_AND,
    GMReduction_OR,
    GMReduction_XOR,
    GMReduction_POPC
};

pure func GMReductionOperationForTStoreMode(mode: bits(3))
    => GMReductionOperation
begin
    case UInt(mode) of
        when 0 => return GMReduction_ADD;
        when 1 => return GMReduction_MIN;
        when 2 => return GMReduction_MAX;
        when 3 => return GMReduction_AND;
        when 4 => return GMReduction_OR;
        when 5 => return GMReduction_XOR;
        when 6 => return GMReduction_INC;
        otherwise => return GMReduction_DEC;
    end;
end;

// One authoritative no-return reduction primitive is shared by indexed
// MSCATTER red forms and strided Atomic TSTORE. The address generators differ;
// dtype legality and per-RMW arithmetic do not.
readonly func GMReductionResult(operation: GMReductionOperation,
    data_type: TileDataType, old: Word, input: Word) => Word
begin
    case operation of
        when GMReduction_ADD =>
            if TileDataTypeIsFloating(data_type) then
                return GMFloatingAddPTX(data_type, old, input);
            end;
            return old + input;
        when GMReduction_INC => return GMIncValue(old, input);
        when GMReduction_DEC => return GMDecValue(old, input);
        when GMReduction_AND => return old AND input;
        when GMReduction_OR => return old OR input;
        when GMReduction_XOR => return old XOR input;
        when GMReduction_MAX =>
            if TileDataTypeIsSigned(data_type) then
                if SInt(old) > SInt(input) then return old; else return input; end;
            end;
            if UInt(old) > UInt(input) then return old; else return input; end;
        when GMReduction_MIN =>
            if TileDataTypeIsSigned(data_type) then
                if SInt(old) < SInt(input) then return old; else return input; end;
            end;
            if UInt(old) < UInt(input) then return old; else return input; end;
        otherwise => return old;
    end;
end;

pure func GMAtomicOperationDataTypeLegal(
    operation: GMAtomicOperation, data_type: TileDataType) => boolean
begin
    case operation of
        when GMAtomic_CAS =>
            return data_type == TileDataType_U16 ||
                   data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
        when GMAtomic_EXCH =>
            return data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
        when GMAtomic_ADD =>
            return data_type == TileDataType_FP16 ||
                   data_type == TileDataType_BF16 ||
                   data_type == TileDataType_FP32 ||
                   data_type == TileDataType_FP64 ||
                   data_type == TileDataType_S32 ||
                   data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
        when GMAtomic_INC, GMAtomic_DEC => return data_type == TileDataType_U32;
        when GMAtomic_MAX, GMAtomic_MIN =>
            return data_type == TileDataType_S32 ||
                   data_type == TileDataType_S64 ||
                   data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
        when GMAtomic_AND, GMAtomic_OR, GMAtomic_XOR =>
            return data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
    end;
end;

pure func GMReductionOperationDataTypeLegal(
    operation: GMReductionOperation, data_type: TileDataType) => boolean
begin
    case operation of
        when GMReduction_POPC => return data_type == TileDataType_U32;
        when GMReduction_INC, GMReduction_DEC => return data_type == TileDataType_U32;
        when GMReduction_ADD =>
            return data_type == TileDataType_FP16 ||
                   data_type == TileDataType_BF16 ||
                   data_type == TileDataType_FP32 ||
                   data_type == TileDataType_FP64 ||
                   data_type == TileDataType_S32 ||
                   data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
        when GMReduction_MAX, GMReduction_MIN =>
            return data_type == TileDataType_S32 ||
                   data_type == TileDataType_S64 ||
                   data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
        when GMReduction_AND, GMReduction_OR, GMReduction_XOR =>
            return data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
    end;
end;

pure func GMIncValue(old: Word, limit: Word) => Word
begin
    if UInt(old) >= UInt(limit) then return Zeros{PTO_XLEN}; end;
    return old + Zeros{PTO_XLEN} + 1;
end;

pure func GMDecValue(old: Word, limit: Word) => Word
begin
    if UInt(old) == 0 || UInt(old) > UInt(limit) then return limit; end;
    return old - (Zeros{PTO_XLEN} + 1);
end;

// Build exact powers for FP64 exponent alignment without host floating point.
pure func GMFloatingAddPowerOfTwo(exponent: integer {0..2100}) => integer
begin
    var result: integer = 1;
    var remaining = exponent;
    var factor: integer = 2;
    while remaining > 0 looplimit 12 do
        if remaining MOD 2 == 1 then result = result * factor; end;
        factor = factor * factor;
        remaining = (remaining DIVRM 2) as integer {0..2100};
    end;
    return result;
end;

readonly func GMFloatingAddPTX(data_type: TileDataType, old: Word,
                             value: Word) => Word
begin
    assert data_type == TileDataType_FP64 || data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP16 || data_type == TileDataType_BF16;
    let descriptor = TileNumericFormatDescriptor(data_type);
    let fraction_bits = descriptor.fraction_bits_min;
    let bias = descriptor.exponent_bias;
    let minimum_exponent = 1 - bias;
    let maximum_exponent = bias;
    let hidden = GMFloatingAddPowerOfTwo(fraction_bits as integer {0..2100});
    let infinity = hidden * (2 * bias + 1);
    let sign_bit = GMFloatingAddPowerOfTwo(descriptor.sign_bit as integer {0..2100});
    let left = TileRawElementValue(old, data_type);
    let right = TileRawElementValue(value, data_type);
    let left_class = TileNumericValueClass(data_type, left);
    let right_class = TileNumericValueClass(data_type, right);
    if NumericValueClassIsNaN(left_class) || NumericValueClassIsNaN(right_class) then
        let (available, nan) = TileNumericCanonicalNaN(data_type);
        assert available;
        return nan;
    end;
    let left_negative = left[descriptor.sign_bit] == '1';
    let right_negative = right[descriptor.sign_bit] == '1';
    let left_infinite = NumericValueClassIsInfinity(left_class);
    let right_infinite = NumericValueClassIsInfinity(right_class);
    if left_infinite && right_infinite && left_negative != right_negative then
        let (available, nan) = TileNumericCanonicalNaN(data_type);
        assert available;
        return nan;
    elsif left_infinite then return left;
    elsif right_infinite then return right;
    end;
    let (left_valid, -, left_significand, left_exponent) =
        TileNumericFiniteDecomposition(data_type, left);
    let (right_valid, -, right_significand, right_exponent) =
        TileNumericFiniteDecomposition(data_type, right);
    assert left_valid && right_valid;
    let common_exponent = if left_exponent < right_exponent then
        left_exponent else right_exponent;
    let left_integer = UInt(left_significand) * GMFloatingAddPowerOfTwo(
        (left_exponent - common_exponent) as integer {0..2100});
    let right_integer = UInt(right_significand) * GMFloatingAddPowerOfTwo(
        (right_exponent - common_exponent) as integer {0..2100});
    let exact = (if left_negative then -left_integer else left_integer) +
                (if right_negative then -right_integer else right_integer);
    if exact == 0 then
        if left_integer == 0 && right_integer == 0 && left_negative && right_negative then
            return Zeros{PTO_XLEN} + sign_bit;
        end;
        return Zeros{PTO_XLEN};
    end;
    let negative = exact < 0;
    let magnitude = if negative then -exact else exact;
    let sign = if negative then sign_bit else 0;
    var scaled = magnitude;
    var bit_count: integer {0..2101} = 0;
    while scaled > 0 looplimit 2101 do
        scaled = scaled DIVRM 2;
        bit_count = (bit_count + 1) as integer {0..2101};
    end;
    let exact_exponent = (common_exponent + bit_count) - 1;
    let quantum = if exact_exponent < minimum_exponent then
        minimum_exponent - fraction_bits else exact_exponent - fraction_bits;
    let shift = quantum - common_exponent;
    var rounded: integer = magnitude;
    if shift > 0 then
        let divisor = GMFloatingAddPowerOfTwo(shift as integer {0..2100});
        rounded = magnitude DIVRM divisor;
        let remainder = magnitude MOD divisor;
        if 2 * remainder > divisor ||
           (2 * remainder == divisor && rounded MOD 2 == 1) then
            rounded = rounded + 1;
        end;
    elsif shift < 0 then
        rounded = magnitude * GMFloatingAddPowerOfTwo((-shift) as integer {0..2100});
    end;
    if rounded < hidden then return Zeros{PTO_XLEN} + sign + rounded; end;
    var result_exponent: integer = quantum + fraction_bits;
    if rounded >= 2 * hidden then
        rounded = rounded DIVRM 2;
        result_exponent = result_exponent + 1;
    end;
    if result_exponent > maximum_exponent then
        return Zeros{PTO_XLEN} + sign + infinity;
    end;
    return Zeros{PTO_XLEN} + sign +
        (result_exponent + bias) * hidden + (rounded - hidden);
end;

func GMAtomicResult(operation: GMAtomicOperation,
                         data_type: TileDataType, old: Word,
                         value: Word, expected: Word,
                         replacement: Word) => (Word, boolean)
begin
    case operation of
        when GMAtomic_CAS =>
            let matched = GMRawElementValue(old, data_type) ==
                GMRawElementValue(expected, data_type);
            if matched then return (GMRawElementValue(replacement, data_type), TRUE); end;
            return (old, FALSE);
        when GMAtomic_EXCH => return (GMRawElementValue(value, data_type), TRUE);
        when GMAtomic_ADD =>
            if TileDataTypeIsFloating(data_type) then
                return (GMFloatingAddPTX(data_type, old, value), TRUE);
            end;
            return (GMRawElementValue(old, data_type) +
                    GMRawElementValue(value, data_type), TRUE);
        when GMAtomic_INC => return (GMIncValue(old, value), TRUE);
        when GMAtomic_DEC => return (GMDecValue(old, value), TRUE);
        when GMAtomic_AND => return (old AND value, TRUE);
        when GMAtomic_OR => return (old OR value, TRUE);
        when GMAtomic_XOR => return (old XOR value, TRUE);
        when GMAtomic_MAX =>
            if TileDataTypeIsSigned(data_type) then
                if SInt(old) > SInt(value) then return (old, TRUE); else return (value, TRUE); end;
            end;
            if UInt(old) > UInt(value) then return (old, TRUE); else return (value, TRUE); end;
        when GMAtomic_MIN =>
            if TileDataTypeIsSigned(data_type) then
                if SInt(old) < SInt(value) then return (old, TRUE); else return (value, TRUE); end;
            end;
            if UInt(old) < UInt(value) then return (old, TRUE); else return (value, TRUE); end;
    end;
end;

pure func GMRawElementValue(value: Word, data_type: TileDataType) => Word
begin
    return TileRawElementValue(value, data_type);
end;

readonly func TileOperandsLegal_GM_ATOM_CAS(
    operation: GMAtomicOperation, destination: TileIndex, base_address: Word, indices: TileIndex,
    expected: TileIndex, replacement: TileIndex,
    pad_value: TilePadValue) => boolean
begin
    let data_type = _Tiles[[destination]].data_type;
    return IndexedTLSUNumericDescriptorLegal(destination) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUExecutionMaskContentsDefined(expected) &&
           IndexedTLSUExecutionMaskContentsDefined(replacement) &&
           GMAtomicOperationDataTypeLegal(operation, data_type) &&
           _Tiles[[expected]].data_type == data_type &&
           _Tiles[[replacement]].data_type == data_type &&
           _Tiles[[destination]].valid_rows == _Tiles[[indices]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[indices]].valid_columns &&
           _Tiles[[destination]].valid_rows == _Tiles[[expected]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[expected]].valid_columns &&
           _Tiles[[destination]].valid_rows == _Tiles[[replacement]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[replacement]].valid_columns &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           _Tiles[[destination]].layout == _Tiles[[indices]].layout &&
           _Tiles[[destination]].layout == _Tiles[[expected]].layout &&
           _Tiles[[destination]].layout == _Tiles[[replacement]].layout;
end;

readonly func TileOperandsLegal_GM_ATOM_VALUE(
    operation: GMAtomicOperation, destination: TileIndex, base_address: Word, indices: TileIndex,
    value: TileIndex, pad_value: TilePadValue) => boolean
begin
    let data_type = _Tiles[[destination]].data_type;
    return IndexedTLSUNumericDescriptorLegal(destination) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUExecutionMaskContentsDefined(value) &&
           GMAtomicOperationDataTypeLegal(operation, data_type) &&
           _Tiles[[value]].data_type == data_type &&
           _Tiles[[destination]].valid_rows == _Tiles[[indices]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[indices]].valid_columns &&
           _Tiles[[destination]].valid_rows == _Tiles[[value]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[value]].valid_columns &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           _Tiles[[destination]].layout == _Tiles[[indices]].layout &&
           _Tiles[[destination]].layout == _Tiles[[value]].layout;
end;

readonly func TileOperandsLegal_GM_RED_VALUE(
    operation: GMReductionOperation, base_address: Word, indices: TileIndex, value: TileIndex,
    pad_value: TilePadValue) => boolean
begin
    return IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUExecutionMaskContentsDefined(value) &&
           GMReductionOperationDataTypeLegal(
               operation, _Tiles[[value]].data_type) &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           _Tiles[[indices]].valid_rows == _Tiles[[value]].valid_rows &&
           _Tiles[[indices]].valid_columns == _Tiles[[value]].valid_columns &&
           _Tiles[[indices]].layout == _Tiles[[value]].layout;
end;

readonly func TileOperandsLegal_GM_RED_POPC(
    operation: GMReductionOperation, base_address: Word, indices: TileIndex) => boolean
begin
    return IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type);
end;
```
<!-- GENERATED-ASL-END: unit -->
