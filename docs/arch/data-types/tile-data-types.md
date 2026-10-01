<!-- GENERATED FROM: asl/arch/data-types/tile-data-types.asl -->
# Tile Data Types

**Normative ASL source:** `asl/arch/data-types/tile-data-types.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-tile-data-types-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit owns the `TileHand` enumeration, the `TileDataType` namespace and its five-bit encoding, the `TileDataLayout` transformation names, the physical `TileLayout` enumeration, and `TilePadValue`.

It is the boundary between an encoded data-type field and the typed values that numeric and Tile execution owners consume, and its line-1 record declares the field domain `PTO-FIELD-BLOCK-DATATYPE` for Block data attributes and typed Block starts.

Design point: one unit declares both the `bits(5)` encoding type and the two conversion functions. The code space is therefore a real five-bit value with 32 possible codes, so the 27 named members and the 5 unassigned codes are two countable, disjoint sets instead of a list whose gaps are invisible.

<!-- PTO-READER-BLOCK: arch-tile-data-types-concepts-state role=concepts-state -->
## Concepts and visible state

- `TileHand` has four members: `TileHand_T`, `TileHand_U`, `TileHand_M`, and `TileHand_N`.
- `TileDataType` has 27 members: 16 floating and scale members carrying codes `0` through `15`, 5 signed integer members carrying codes `16` through `20`, the derived member `TileDataType_RCPE6M2` carrying code `21`, and 5 unsigned integer members carrying codes `24` through `28`.
- `TileDataTypeEncoding` is `bits(5)`, and `TileDataTypeEncodingValid` accepts the three assigned ranges, so codes `22`, `23`, `29`, `30`, and `31` are reserved.
- `TileDataLayout` has 23 transformation names from `TileDataLayout_NORM` to `TileDataLayout_CUBE_M16`, `TilePadValue` has four members `TilePad_Zero`, `TilePad_Max`, `TilePad_Min`, and `TilePad_Null`, and `TileLayout` has 8 members `TileLayout_RowMajor`, `TileLayout_ColumnMajor`, `TileLayout_ZN`, `TileLayout_NZ`, `TileLayout_CUBE_M16`, `TileLayout_CUBE_M32`, `TileLayout_CUBE_N8`, and `TileLayout_ImplementationDefined`.

Design point: the declared field meaning of code `0` is `FP64`, and the record states that zero never means absent, inherited, `NONE`, or `NULL`. A data-type field of zero is therefore a complete and usable 64-bit floating format, and "no data type" needs a different code, which the unit supplies as the separate sentinel `DTYPE_NONE` rather than as a zero value.

<!-- PTO-READER-BLOCK: arch-tile-data-types-rules-interactions role=rules-interactions -->
## Rules and interactions

`TileDataTypeFromEncoding` opens with `assert TileDataTypeEncodingValid(encoded)` and ends its `case` with `otherwise => unreachable`, so a reserved code cannot produce a data type through this function. The field domain states that reserved values reject before architectural effects.

`TileDataTypeToEncoding` is the reverse mapping and returns explicit constants instead of enum positions. The gap between the two directions is visible at `TileDataType_RCPE6M2`, which encodes to `21`, and the next declared member `TileDataType_U64`, which encodes to `24`.

`DTYPE_NONE` is the five-bit constant `'11111'`, which is code `31`. It is deliberately not a `TileDataType`, so it has no width, no format, and no arithmetic semantics.

Design point: separating the validity predicate from the mapping function lets an owner test a code before calling the mapping function, which can then treat every other value as unreachable rather than inventing a fallback. A reserved code is consequently rejected at the check instead of becoming a default data type.

<!-- PTO-READER-BLOCK: arch-tile-data-types-boundaries role=boundaries -->
## Architectural boundaries

Reserved codes are held for future extension and reject before architectural effects. This unit assigns them no meaning and does not say what a consuming instruction does with them.

One member is explicitly non-architectural. `TileLayout_ImplementationDefined` exists so that model fixtures can prove that generic execution rejects an opaque implementation layout, and the file records that no assigned `B.DATR` layout code maps to it.

`TileDataLayout` and `TileLayout` are separate namespaces with separate members. The 23 transformation names such as `TileDataLayout_ND2M32` are not members of the physical `TileLayout`, whose 8 members are the two major orders, `ZN`, `NZ`, the three `CUBE` forms, and the implementation-defined fixture.

Design point: keeping the transformation name apart from the storage layout means an encoded conversion name cannot be mistaken for the layout a Tile is stored in: a consumer that needs the stored layout must ask the Tile state owner for a `TileLayout`, while a decoded conversion name is a `TileDataLayout`.

<!-- PTO-READER-BLOCK: arch-tile-data-types-example-usage role=example-usage -->
## Non-normative reading example

Take the code `2`. `TileDataTypeEncodingValid` accepts it, because it falls in the range `0` through `16`, and `TileDataTypeFromEncoding` returns `TileDataType_TF32`. Take the code `31` instead: it is outside all three ranges, the validity predicate returns false, and the `assert` fails, so `31` never becomes a data type and the bit pattern `'11111'` is meaningful only as `DTYPE_NONE`.

In the other direction, `TileDataTypeToEncoding(TileDataType_U4X2)` returns `Zeros{5} + 28`, which is the same code the field domain assigns to `U4X2`.

Once a code has been decoded, format metadata comes from `TileNumericFormatDescriptor` and operation support comes from the consuming instruction. This unit decides neither.

<!-- PTO-READER-BLOCK: arch-tile-data-types-related-owners role=related-owners-navigation -->
## Related owners

- [Numeric format dispatch](numeric-formats.md)
- [Packed concept](packed.md)
- [Format descriptor record](format-descriptor.md)
- [Hardware numeric profile](../features/mx-formats.md)
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
