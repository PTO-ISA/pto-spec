<!-- GENERATED FROM: asl/arch/data-types/tile-data-types.asl -->
# Tile Data Types

**Normative ASL source:** `asl/arch/data-types/tile-data-types.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/tile-data-types.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES","surface":"arch","classification":["data-types","tile-data-types"],"depends_on":["PTO-ARCH-FEATURES-MX-FORMATS"]}
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
    TileDataType_S64,
    TileDataType_S32,
    TileDataType_S16,
    TileDataType_S8,
    TileDataType_S4X2,
    TileDataType_U64,
    TileDataType_U32,
    TileDataType_U16,
    TileDataType_U8,
    TileDataType_U4X2
};

type TileDataLayout of enumeration {
    TileDataLayout_NORM,
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
    TileDataLayout_NZ2ZN
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
    TileLayout_CUBE_M32,
    TileLayout_CUBE_M16,
    TileLayout_CUBE_N8,
    TileLayout_ImplementationDefined
};

// CUBE storage geometry is resolved from the matrix operand role at tile
// allocation time.  The role is descriptor state only; it is not an encoded
// persistent MShard4/group tag.
type TileCubeOperandRole of enumeration {
    TileCubeOperand_None,
    TileCubeOperand_A,
    TileCubeOperand_B,
    TileCubeOperand_C,
    TileCubeOperand_D
};

type TileLocation of enumeration {
    TileLocation_Vector,
    TileLocation_Matrix,
    TileLocation_Memory,
    TileLocation_Any
};
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
