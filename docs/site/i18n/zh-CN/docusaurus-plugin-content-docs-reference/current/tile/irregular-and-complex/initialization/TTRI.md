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

`TTRI` 把一个由类型化的一和零组成的三角掩码写入新分配的 Local RowMajor Tile。它不读取任何源 Tile；对角线与方向来自 GPR。

设计要点：`TTRI` 由 `BSTART.SFU` 以 TEPL Mode 3 Function 7（选择器 `0x067`）选中，没有独立 opcode。

<!-- PTO-READER-BLOCK: tile-c-ttri-mechanism role=mechanism -->
## 生成公式

对位于第 r 行、第 c 列的每个有效元素，下三角方向在 `c <= r + diagonal` 时写入一，上三角方向在 `c >= r + diagonal` 时写入一。其他所有有效元素接收零。

一是精确的类型化编码：FP64 为 `0x3ff0000000000000`，FP32 为 `0x3f800000`，FP16 为 `0x3c00`，整数类型为整数 1。零为正零。

设计要点：边界比较使用有符号整数，并且不回绕。因此当对角线小于等于 -ValidRow 时，下三角方向的所有元素都为零；而很大的正对角线使下三角方向的所有元素都为一。

<!-- PTO-READER-BLOCK: tile-c-ttri-inputs-outputs role=inputs-outputs -->
## 操作数、形状与类型

- `destination0` 是新分配的 Local RowMajor Tile，类型为 `FP64`、`FP32`、`FP16`、`S64`、`S32`、`S16`、`U64`、`U32` 或 `U16`。
- `diagonal` 是从 RegSrc0 读取的有符号位移；它必须位于 -65535 到 65535 之间。
- `flag0` 是从 RegSrc1 读取的方向：0 选择下三角，1 选择上三角。RegSrc2 与 RegDst 必须为零。

省略 `B.DIM` LB0 时取架构默认值一；显式编码的零非法，因为 ValidCol 必须非零。LB1 默认使 ValidRow 为 1，LB2 默认为 Col = ValidCol。省略 `B.IOR` 选择对角线 0 与下三角方向；显式全零 `B.IOR` 读取 GPR0，并给出相同的值。

存在的 `B.DATR` 必须所有字段为零。只允许恰好一条终止的仅目标 `B.IOT`。

<!-- PTO-READER-BLOCK: tile-c-ttri-effects role=effects -->
## 已定义性、填充与发布

没有源 Tile，也没有源快照。三角载荷、目标描述符以及每个元素的已定义性作为一次操作发布；每个有效元素都变为已定义。

有效区域之外的物理元素接收 `Null` 填充：一个保持未定义的零载体。`TTRI` 没有全局内存、GPR 或数值状态效果。

<!-- PTO-READER-BLOCK: tile-c-ttri-constraints role=constraints -->
## 合法性、故障与顺序边界

绑定格式错误、`B.IOS`、不支持的类型、非 RowMajor 布局、维度缺失或无效、方向不是 0 或 1、对角线超出 -65535 到 65535，或非零 `B.DATR` 字段，会在分配之前引发 `Fault_TileLegality`。

形状无法表示、目标寄存器不可用、TSize 过小或 Tile 容量耗尽，会在分配之前引发 `Fault_TileAllocation`。

`PE_MASK=0000` 在 `B.IOT` 的 size code 编码检查之后是严格无操作：不再进行 GPR 读取、描述符检查、分配或操作故障，但非法的 `B.IOT` size code 仍会引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: tile-c-ttri-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

一个 FP32 目标有 3 个有效行、4 个有效列，下三角方向，对角线为 0，保存下面各行，其中 1 表示 `0x3f800000`。若对角线改为 1，每行多一个一：1 1 0 0，然后 1 1 1 0，然后 1 1 1 1。

```text
row 0: 1 0 0 0
row 1: 1 1 0 0
row 2: 1 1 1 0
```

同样的对角线 0 在上三角方向下，在 `c >= r` 处写入一：1 1 1 1，然后 0 1 1 1，然后 0 0 1 1。两种方向下主对角线都为一。
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
BSTART.SFU TTRI, FP64|FP32|FP16|S64|S32|S16|U64|U32|U16
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
- The selected DataType is exactly FP64, FP32, FP16, S64, S32, S16, U64, U32, or U16. The destination is row-major with nonzero ValidRow and ValidCol, and Col is at least ValidCol.
- A present B.IOR consumes RegSrc0 as signed diagonal and RegSrc1 as exact zero or one orientation. RegSrc2 and RegDst are zero.
- Every explicit nonzero B.DATR field is illegal. PE_MASK zero is a strict no-op before GPR reads, descriptor checks, allocation, faults, or payload effects.

## State effects

- For lower orientation, logical element [r,c] is typed one exactly when c is at most r plus diagonal; otherwise it is typed zero.
- For upper orientation, logical element [r,c] is typed one exactly when c is at least r plus diagonal; otherwise it is typed zero.
- Signed boundary comparison does not wrap. FP64, FP32, and FP16 use their exact positive-zero and positive-one encodings. Every physical coordinate outside the valid rectangle is undefined Null padding.

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
