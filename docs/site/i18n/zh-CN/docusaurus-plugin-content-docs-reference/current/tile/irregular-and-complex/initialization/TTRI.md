<!-- GENERATED FROM: asl/tile/irregular-and-complex/initialization/TTRI.asl -->
# TTRI

**Normative ASL source:** `asl/tile/irregular-and-complex/initialization/TTRI.asl`

Generate an exact typed lower or upper triangular matrix in a new Local Tile.

## Normative identity {#PTO-INST-TILE-TTRI}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-ttri-purpose role=purpose -->
## TTRI 的作用

`TTRI` 在新的 Local Tile 中生成精确带类型的下三角或上三角矩阵。

<!-- PTO-READER-BLOCK: tile-c-ttri-mechanism role=mechanism -->
## 操作机制

下三角方向在 `c <= r + diagonal` 时写带类型的一；上三角方向在 `c >= r + diagonal` 时写带类型的一。

有符号边界比较不回绕，其余有效坐标写带类型的零。

<!-- PTO-READER-BLOCK: tile-c-ttri-inputs-outputs role=inputs-outputs -->
## 操作数、形状与类型

- `destination0` 标识新分配的目的 Tile。

- `flag0` 选择下三角或上三角方向。

- `diagonal` 提供有符号对角线位移。

- 封闭的适用 DataType 集合为 `FP32`、`FP16`、`S32`、`S16`、`U32`、`U16`。

- 除非该助记符显式选择其他允许布局，数据 Tile 使用行主序布局。

- `LB0`、`LB1`、`LB2` 按该助记符契约补全有效形状与物理形状；所有必需有效范围都必须非零。

<!-- PTO-READER-BLOCK: tile-c-ttri-effects role=effects -->
## 已定义性、填充与发布

该操作没有源 Tile，也不执行源快照。类型、维度、方向、对角线、掩码、容量与分配会在生成前完成预检。

三角载荷、目标描述符、有效区域已定义性与未定义 Null 填充会原子发布；拒绝路径不发布任何部分。

<!-- PTO-READER-BLOCK: tile-c-ttri-constraints role=constraints -->
## 合法性、故障与顺序边界

仅目标绑定、维度、DataType、行主序布局、全零 B.DATR、方向、对角线、容量与分配都会在效果前预检。

合法性或分配检查失败会引发相应 Tile 故障，不留下部分目标、状态或内存效果。

`PE_MASK=0000` 是严格无操作，发生在操作数读取、分配、故障、数值状态或载荷效果之前。

<!-- PTO-READER-BLOCK: tile-c-ttri-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

`TTRI <bundle operands>` 只执行目标侧预检，不读取或快照源 Tile；随后生成三角载荷，并与 Null 填充一起原子发布。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TTRI <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TTRI | TEPL | 0x067 | 7 | 3 | TTRI |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### B.IOR.RegDst (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

### B.IOR.RegSrc0 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

### B.IOR.RegSrc1 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

### B.IOR.RegSrc2 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local triangular destination |
| flag0 | lower or upper orientation |
| diagonal | signed diagonal displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/initialization/TTRI.asl -->
```asl
readonly func InstructionContractOperation_TTRI() => TileOperation
begin
    return TileOperation_TTRI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TTRI, FP32|FP16|S32|S16|U32|U16
B.DATR all-zero (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col (optional, default ValidCol)
B.IOR Diagonal, Orientation (optional; omission selects 0 and lower)
B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/initialization/TTRI.asl -->
```asl
pure func InstructionContractDataTypeLegal_TTRI(
    data_type: TileDataType) => boolean
begin
    return TileTTRIDataTypeSupported(data_type);
end;

pure func InstructionContractDefaultDiagonal_TTRI()
    => integer {-65535..65535}
begin
    return 0;
end;

pure func InstructionContractDefaultUpper_TTRI() => boolean
begin
    return FALSE;
end;

readonly func InstructionContractOperandsLegal_TTRI(
    destination: TileIndex,
    upper: boolean,
    diagonal: integer {-65535..65535}) => boolean
begin
    return TileOperandsLegal_TTRI(
        destination,
        upper,
        diagonal);
end;

readonly func InstructionContractHandler_TTRI() => TileSemanticHandler
begin
    return TileHandler_TTRI;
end;

func InstructionContractExecute_TTRI(
    destination: TileIndex,
    upper: boolean,
    diagonal: integer {-65535..65535})
begin
    assert InstructionContractOperandsLegal_TTRI(
        destination,
        upper,
        diagonal);
    TTRI(
        destination,
        upper,
        diagonal);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow one. Omitted LB2 selects Col equal to ValidCol.
- Omitted B.IOR selects diagonal zero and lower orientation. An explicitly present all-zero B.IOR is a distinct descriptor with the same operand values.
- Omitted B.DATR selects the operation defaults. A present B.DATR is legal only when every encoded field is zero. Physical padding is always Null.

## Legality

- TTRI is selected by the TEPL encoding carrier Mode 3 Function 7, canonically assembled with BSTART.SFU, and has no standalone opcode.
- Exactly one terminating destination-only Local B.IOT supplies one newly allocated destination. Every source binding, a second B.IOT, B.IOS, or an unterminated binding stream is illegal.
- The selected DataType is exactly FP32, FP16, S32, S16, U32, or U16. The destination is row-major with nonzero ValidRow and ValidCol, and Col is at least ValidCol.
- A present B.IOR consumes RegSrc0 as signed diagonal and RegSrc1 as exact zero or one orientation. RegSrc2 and RegDst are zero.
- Every explicit nonzero B.DATR field is illegal. PE_MASK zero is a strict no-op before GPR reads, descriptor checks, allocation, faults, or payload effects.

## State effects

- For lower orientation, logical element [r,c] is typed one exactly when c is at most r plus diagonal; otherwise it is typed zero.
- For upper orientation, logical element [r,c] is typed one exactly when c is at least r plus diagonal; otherwise it is typed zero.
- Signed boundary comparison does not wrap. FP32 and FP16 use their exact positive-zero and positive-one encodings. Every physical coordinate outside the valid rectangle is undefined Null padding.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, type, dimensions, TSize, diagonal, orientation, mask, destination-name, and allocation preflight precedes generation.
- The triangular payload, Null padding definedness, and renamed destination descriptor publish atomically; rejection publishes none.

## Exceptions

- Malformed bindings, B.IOS, unsupported DataType, non-row-major layout, missing or invalid dimensions, orientation other than zero or one, diagonal outside -65535 through 65535, or a nonzero inapplicable B.DATR field raises Fault_TileLegality before allocation.
- An unrepresentable shape, unavailable renamed destination, insufficient TSize, or exhausted Tile capacity raises Fault_TileAllocation before allocation.
- PE_MASK zero completes as a strict no-op before every validation or effect.

## Examples

- BSTART.SFU TTRI, FP16; B.DIM LB0=16; B.DIM LB1=8; B.IOR a0, a1; B.IOT mask=1111, <last>, ->T0<2>; BSTOP
