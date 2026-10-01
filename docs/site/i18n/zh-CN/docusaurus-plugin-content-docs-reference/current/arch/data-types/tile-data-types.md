<!-- GENERATED FROM: asl/arch/data-types/tile-data-types.asl -->
# Tile Data Types

**Normative ASL source:** `asl/arch/data-types/tile-data-types.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-tile-data-types-purpose-scope role=purpose-scope -->
## 目的与范围

本单元拥有 `TileHand` 枚举、`TileDataType` 命名空间及其五位编码、`TileDataLayout` 变换名、物理 `TileLayout` 枚举，以及 `TilePadValue`。

它是编码的数据类型域与数值及 Tile 执行归属单元所消费的类型化值之间的边界；它的第 1 行记录还声明了域 `PTO-FIELD-BLOCK-DATATYPE`，用于 Block 数据属性和带类型的 Block 起始。

设计要点：同一个单元既声明 `bits(5)` 编码类型，也声明两个转换函数。因此该编码空间是一个真实的五位值，有 32 个可能编号，27 个具名成员与 5 个未分配编号是两个可数且不相交的集合，而不是一份缺口不可见的清单。

<!-- PTO-READER-BLOCK: arch-tile-data-types-concepts-state role=concepts-state -->
## 概念与可见状态

- `TileHand` 有 4 个成员：`TileHand_T`、`TileHand_U`、`TileHand_M` 和 `TileHand_N`。
- `TileDataType` 有 27 个成员：编号 `0` 到 `15` 的 16 个浮点与缩放成员，编号 `16` 到 `20` 的 5 个有符号整数成员，编号 `21` 的派生成员 `TileDataType_RCPE6M2`，以及编号 `24` 到 `28` 的 5 个无符号整数成员。
- `TileDataTypeEncoding` 是 `bits(5)`，而 `TileDataTypeEncodingValid` 接受那三个已分配范围，因此编号 `22`、`23`、`29`、`30` 和 `31` 是保留值。
- `TileDataLayout` 有 23 个从 `TileDataLayout_NORM` 到 `TileDataLayout_CUBE_M16` 的变换名，`TilePadValue` 有 4 个成员 `TilePad_Zero`、`TilePad_Max`、`TilePad_Min` 和 `TilePad_Null`，`TileLayout` 有 8 个成员 `TileLayout_RowMajor`、`TileLayout_ColumnMajor`、`TileLayout_ZN`、`TileLayout_NZ`、`TileLayout_CUBE_M16`、`TileLayout_CUBE_M32`、`TileLayout_CUBE_N8` 和 `TileLayout_ImplementationDefined`。

设计要点：编号 `0` 的声明域含义是 `FP64`，并且该记录声明零绝不表示缺失、继承、`NONE` 或 `NULL`。因此数据类型域为零是一个完整可用的 64 位浮点格式，“没有数据类型”需要另一个编号，本单元把它提供为独立哨兵 `DTYPE_NONE`，而不是零值。

<!-- PTO-READER-BLOCK: arch-tile-data-types-rules-interactions role=rules-interactions -->
## 规则与交互

`TileDataTypeFromEncoding` 以 `assert TileDataTypeEncodingValid(encoded)` 开始，并以 `otherwise => unreachable` 结束其 `case`，因此保留编号无法通过该函数产生数据类型。域声明指出保留值在产生架构效果之前被拒绝。

`TileDataTypeToEncoding` 是反向映射，返回显式常量而不是枚举位置。两个方向的缺口在 `TileDataType_RCPE6M2` 处可见：它编码为 `21`，而下一个声明的成员 `TileDataType_U64` 编码为 `24`。

`DTYPE_NONE` 是五位常量 `'11111'`，即编号 `31`。它故意不是 `TileDataType`，因此没有宽度、没有格式、也没有算术语义。

设计要点：把合法性谓词与映射函数分开，使归属单元可以在调用映射函数之前检查编号，而映射函数随后可以把其他任何值视为不可达，而不必构造回退。因此保留编号在检查处被拒绝，而不会被转换成默认数据类型。

<!-- PTO-READER-BLOCK: arch-tile-data-types-boundaries role=boundaries -->
## 架构边界

保留编号为将来扩展而保留，并在产生架构效果之前被拒绝。本单元不为它们分配含义，也不说明消费指令对它们做什么。

有一个成员明确是非架构的。`TileLayout_ImplementationDefined` 的存在是为了让模型夹具能够证明通用执行会拒绝不透明的实现定义布局，文件也记录没有任何已分配的 `B.DATR` 布局编号映射到它。

`TileDataLayout` 与 `TileLayout` 是成员不同的两个命名空间。诸如 `TileDataLayout_ND2M32` 这样的 23 个变换名不是物理 `TileLayout` 的成员，后者的 8 个成员是两种主序、`ZN`、`NZ`、三种 `CUBE` 形式和实现定义夹具。

设计要点：把变换名与存储布局分开，意味着编码的转换名不会被误认为 Tile 的存储布局：需要存储布局的使用方必须向 Tile 状态归属单元索取 `TileLayout`，而解码得到的转换名是 `TileDataLayout`。

<!-- PTO-READER-BLOCK: arch-tile-data-types-example-usage role=example-usage -->
## 非规范阅读示例

以编号 `2` 为例。`TileDataTypeEncodingValid` 接受它，因为它落在 `0` 到 `16` 的范围内，`TileDataTypeFromEncoding` 返回 `TileDataType_TF32`。换成编号 `31`：它在三个范围之外，合法性谓词返回假，`assert` 失败，因此 `31` 永远不会变成数据类型，位模式 `'11111'` 只有作为 `DTYPE_NONE` 才有意义。

反方向上，`TileDataTypeToEncoding(TileDataType_U4X2)` 返回 `Zeros{5} + 28`，这与域分配给 `U4X2` 的编号相同。

编号解码之后，格式元数据来自 `TileNumericFormatDescriptor`，操作支持来自消费指令。本单元两者都不决定。

<!-- PTO-READER-BLOCK: arch-tile-data-types-related-owners role=related-owners-navigation -->
## 相关归属单元

- [数值格式分派](numeric-formats.md)
- [Packed 概念](packed.md)
- [格式描述符记录](format-descriptor.md)
- [硬件数值配置档](../features/mx-formats.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/tile-data-types.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES","surface":"arch","classification":["data-types","tile-data-types"],"depends_on":["PTO-ARCH-FEATURES-MX-FORMATS"],"field_domains":[{"id":"PTO-FIELD-BLOCK-DATATYPE","width":5,"role":"Selects the Tile element data type carried by Block data attributes and typed Block starts.","zero_meaning":"Code zero selects FP64; zero never means absent, inherited, NONE, or NULL.","assigned":[{"value":0,"meaning":"FP64"},{"value":1,"meaning":"FP32"},{"value":2,"meaning":"TF32"},{"value":3,"meaning":"HF32"},{"value":4,"meaning":"FP16"},{"value":5,"meaning":"BF16"},{"value":6,"meaning":"HiF8"},{"value":7,"meaning":"E4M3"},{"value":8,"meaning":"E5M2"},{"value":9,"meaning":"E3M2"},{"value":10,"meaning":"E2M3"},{"value":11,"meaning":"E2M1X2"},{"value":12,"meaning":"E1M2X2"},{"value":13,"meaning":"E8M0"},{"value":14,"meaning":"HiF4X2"},{"value":15,"meaning":"E6M2"},{"value":16,"meaning":"S64"},{"value":17,"meaning":"S32"},{"value":18,"meaning":"S16"},{"value":19,"meaning":"S8"},{"value":20,"meaning":"S4X2"},{"value":21,"meaning":"RCPE6M2"},{"value":24,"meaning":"U64"},{"value":25,"meaning":"U32"},{"value":26,"meaning":"U16"},{"value":27,"meaning":"U8"},{"value":28,"meaning":"U4X2"}],"reserved":[22,23,29,30,31],"rejection":"Reserved values are held for future extension and reject before architectural effects."}]}
type TileHand of enumeration {
    TileHand_T,
    TileHand_U,
    TileHand_M,
    TileHand_N
};

type TileDataType of enumeration {
    TileDataType_FP64,
    TileDataType_FP32,
    TileDataType_TF32,
    TileDataType_HF32,
    TileDataType_FP16,
    TileDataType_BF16,
    TileDataType_HiF8,
    TileDataType_E4M3,
    TileDataType_E5M2,
    TileDataType_E3M2,
    TileDataType_E2M3,
    TileDataType_E2M1X2,
    TileDataType_E1M2X2,
    TileDataType_E8M0,
    TileDataType_HiF4X2,
    TileDataType_E6M2,
    TileDataType_S64,
    TileDataType_S32,
    TileDataType_S16,
    TileDataType_S8,
    TileDataType_S4X2,
    TileDataType_RCPE6M2,
    TileDataType_U64,
    TileDataType_U32,
    TileDataType_U16,
    TileDataType_U8,
    TileDataType_U4X2
};

type TileDataTypeEncoding of bits(5);

pure func TileDataTypeEncodingValid(encoded: TileDataTypeEncoding) => boolean
begin
    let code = UInt(encoded);
    return code <= 16 || (17 <= code && code <= 21) ||
           (24 <= code && code <= 28);
end;

pure func TileDataTypeFromEncoding(encoded: TileDataTypeEncoding) => TileDataType
begin
    assert TileDataTypeEncodingValid(encoded);
    case UInt(encoded) of
        when 0 => return TileDataType_FP64;
        when 1 => return TileDataType_FP32;
        when 2 => return TileDataType_TF32;
        when 3 => return TileDataType_HF32;
        when 4 => return TileDataType_FP16;
        when 5 => return TileDataType_BF16;
        when 6 => return TileDataType_HiF8;
        when 7 => return TileDataType_E4M3;
        when 8 => return TileDataType_E5M2;
        when 9 => return TileDataType_E3M2;
        when 10 => return TileDataType_E2M3;
        when 11 => return TileDataType_E2M1X2;
        when 12 => return TileDataType_E1M2X2;
        when 13 => return TileDataType_E8M0;
        when 14 => return TileDataType_HiF4X2;
        when 15 => return TileDataType_E6M2;
        when 16 => return TileDataType_S64;
        when 17 => return TileDataType_S32;
        when 18 => return TileDataType_S16;
        when 19 => return TileDataType_S8;
        when 20 => return TileDataType_S4X2;
        when 21 => return TileDataType_RCPE6M2;
        when 24 => return TileDataType_U64;
        when 25 => return TileDataType_U32;
        when 26 => return TileDataType_U16;
        when 27 => return TileDataType_U8;
        when 28 => return TileDataType_U4X2;
        otherwise => unreachable;
    end;
end;

pure func TileDataTypeToEncoding(data_type: TileDataType)
        => TileDataTypeEncoding
begin
    case data_type of
        when TileDataType_FP64 => return Zeros{5};
        when TileDataType_FP32 => return Zeros{5} + 1;
        when TileDataType_TF32 => return Zeros{5} + 2;
        when TileDataType_HF32 => return Zeros{5} + 3;
        when TileDataType_FP16 => return Zeros{5} + 4;
        when TileDataType_BF16 => return Zeros{5} + 5;
        when TileDataType_HiF8 => return Zeros{5} + 6;
        when TileDataType_E4M3 => return Zeros{5} + 7;
        when TileDataType_E5M2 => return Zeros{5} + 8;
        when TileDataType_E3M2 => return Zeros{5} + 9;
        when TileDataType_E2M3 => return Zeros{5} + 10;
        when TileDataType_E2M1X2 => return Zeros{5} + 11;
        when TileDataType_E1M2X2 => return Zeros{5} + 12;
        when TileDataType_E8M0 => return Zeros{5} + 13;
        when TileDataType_HiF4X2 => return Zeros{5} + 14;
        when TileDataType_E6M2 => return Zeros{5} + 15;
        when TileDataType_S64 => return Zeros{5} + 16;
        when TileDataType_S32 => return Zeros{5} + 17;
        when TileDataType_S16 => return Zeros{5} + 18;
        when TileDataType_S8 => return Zeros{5} + 19;
        when TileDataType_S4X2 => return Zeros{5} + 20;
        when TileDataType_RCPE6M2 => return Zeros{5} + 21;
        when TileDataType_U64 => return Zeros{5} + 24;
        when TileDataType_U32 => return Zeros{5} + 25;
        when TileDataType_U16 => return Zeros{5} + 26;
        when TileDataType_U8 => return Zeros{5} + 27;
        when TileDataType_U4X2 => return Zeros{5} + 28;
    end;
end;
// Encoded DataType 31 is a field-level sentinel. It is deliberately not a
// TileDataType and therefore has no width, format, or arithmetic semantics.
constant DTYPE_NONE = '11111';

type TileDataLayout of enumeration {
    TileDataLayout_NORM,
    TileDataLayout_OHWI2NK,
    TileDataLayout_OIHW2NK,
    TileDataLayout_ND2DN,
    TileDataLayout_ND2ZN,
    TileDataLayout_ND2NZ,
    TileDataLayout_DN2ND,
    TileDataLayout_DN2ZN,
    TileDataLayout_DN2NZ,
    TileDataLayout_ZN2ND,
    TileDataLayout_ZN2DN,
    TileDataLayout_ZN2NZ,
    TileDataLayout_NZ2ND,
    TileDataLayout_NZ2DN,
    TileDataLayout_NZ2ZN,
    TileDataLayout_ND2M32,
    TileDataLayout_ND2M16,
    TileDataLayout_ND2N8,
    TileDataLayout_M322ND,
    TileDataLayout_M162ND,
    TileDataLayout_N82ND,
    TileDataLayout_CUBE_M32,
    TileDataLayout_CUBE_M16
};

type TilePadValue of enumeration {
    TilePad_Zero,
    TilePad_Max,
    TilePad_Min,
    TilePad_Null
};

type TileLayout of enumeration {
    TileLayout_RowMajor,
    TileLayout_ColumnMajor,
    TileLayout_ZN,
    TileLayout_NZ,
    TileLayout_CUBE_M16,
    TileLayout_CUBE_M32,
    TileLayout_CUBE_N8,
    // Non-architectural model fixtures may use this value to prove that
    // generic execution rejects an opaque implementation layout.  No
    // assigned B.DATR Layout code maps to it.
    TileLayout_ImplementationDefined
};
```
<!-- GENERATED-ASL-END: unit -->
