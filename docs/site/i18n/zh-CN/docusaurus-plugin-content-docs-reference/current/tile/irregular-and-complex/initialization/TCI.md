<!-- GENERATED FROM: asl/tile/irregular-and-complex/initialization/TCI.asl -->
# TCI

**Normative ASL source:** `asl/tile/irregular-and-complex/initialization/TCI.asl`

Generate a typed integer sequence in a new Local Tile, retaining RowMajor and adding explicit CUBE_M16/CUBE_M32 forms.

## Normative identity {#PTO-INST-TILE-TCI}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tci-purpose role=purpose -->
## TCI 的作用

`TCI` 把一个整数索引序列写入新分配的 Local Tile。它不读取任何源 Tile；唯一的输入是从通用寄存器（GPR）取得的起始值以及方向或步长字。

它有两种形式。RowMajor 形式写一行。CUBE 形式把二维模式写入 `CUBE_M16` 或 `CUBE_M32` Tile。

设计要点：`TCI` 由 `BSTART.SFU` 以 TEPL Mode 3 Function 6（选择器 `0x066`）选中，没有独立 opcode。CUBE 形式只能由显式 `B.DATR` `Layout` 为 `CUBE_M32`（29）或 `CUBE_M16`（31）选中，因此不带该元组的指令束始终保持 RowMajor 形式。

<!-- PTO-READER-BLOCK: tile-tci-mechanism role=mechanism -->
## 生成公式

每个生成值都被截断到元素位宽：只保留其低 16 位或低 32 位。因此每个序列都按元素位宽取模回绕，而不会引发故障或饱和。

RowMajor 形式：方向为递增（0）时，逻辑列 k 接收 `start + k`；方向为递减（1）时接收 `start - k`。只有第 0 行有效。

CUBE 形式：第二个 GPR 是打包的 Step2D 字。位 63 到 32 保存有符号 RowStep，位 31 到 0 保存有符号 ColStep；两者都必须为 -1、0 或 +1。元素 (r, c) 接收 `trunc_W(Start + r*RowStep + c*ColStep)`，并通过 CUBE cell 映射写入。

设计要点：运算是原始载体算术再加截断。越过 65535 的 U16 递增序列会从 0 继续，并且不记录任何数值状态。

CUBE 形式会参考 ExecutionMask：活动坐标接收生成值，非活动坐标接收该掩码规定的零值或合并值。[生成执行](../../model/execution/generation.md)拥有这两个辅助函数。

<!-- PTO-READER-BLOCK: tile-tci-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `destination0` 是新分配的 Local `S64`、`S32`、`S16`、`U64`、`U32` 或 `U16` Tile。
- `scalar0` 是起始值，从 RegSrc0 指定的 GPR 读取。
- `flag0` 是 RowMajor 方向或 CUBE Step2D 字，从 RegSrc1 指定的 GPR 读取。

RowMajor 形状：`B.DIM` LB0 是必需的，给出非零 ValidCol。LB1 默认为 1，显式 LB1 也必须等于 1。LB2 默认为 Col = ValidCol。省略 `B.IOR` 选择起始值 0 与递增方向；显式全零 `B.IOR` 给出相同的值。

CUBE 形状：LB1 给出正的 ValidRow，`CUBE_M16` 时不超过 16。显式 LB2 是精确的物理 Col，必须按 cell 列粒度对齐；省略 LB2 时把 ValidCol 向上对齐到该粒度。存在的 `B.DATR` 必须使用 `DataType=DTYPE_NONE`，且 Pad、CMode、RMode、Sat 与 Canonicalize 全为 0；并且恰好一条 `B.IOR` 必须依次指定 StartGPR、Step2DGPR、zero 与 `->zero`。

目标保持 `BSTART` 数据类型。只允许恰好一条终止的 `B.IOT`：除非由 PredicateCell 提供 ExecutionMask，否则它只绑定目标；此时同一条 `B.IOT` 还必须把该谓词 Tile 绑定为源。第二条 `B.IOT`、`B.IOS` 或任何其他源绑定均非法。

<!-- PTO-READER-BLOCK: tile-tci-effects role=effects -->
## 发布、已定义性与填充

序列载荷、目标描述符以及每个元素的已定义性作为一次操作发布。每个有效元素都变为已定义。

有效区域之外的物理元素接收 `Null` 填充：它们保存零载体但保持未定义。`TCI` 不携带 `PadValue`，因此之后的已定义性检查不会把填充视为生成的数据。

`TCI` 没有全局内存效果，不写任何 GPR，也不记录数值状态。被拒绝的指令束不发布任何内容。

<!-- PTO-READER-BLOCK: tile-tci-constraints role=constraints -->
## 类型、布局与故障边界

可接受的数据类型为 `S64`、`S32`、`S16`、`U64`、`U32` 与 `U16`。64 位 CUBE 形式要求 `CUBE_M32`；这些类型在 `CUBE_M16` 中仍非法。

- RowMajor 形式：绑定格式错误、`B.IOS`、不支持的类型、维度缺失或无效、方向不是 0 或 1，或非零的不适用 `B.DATR` 字段，会引发 `Fault_TileLegality`。
- CUBE 形式：命令或 `B.IOR` 结构格式错误引发 `Fault_BundleControl`；无效的选择器、元组、维度、步长或对齐引发 `Fault_TileLegality`；几何合法但 TSize 过小或 Tile 容量耗尽时引发 `Fault_TileAllocation`。
- `PE_MASK=0000` 在 `B.IOT` 的 size code 编码检查之后是严格无操作：不再进行模式验证、GPR 读取、分配或操作故障，但非法的 `B.IOT` size code 仍会引发 `Fault_IllegalInstruction`。

所有拒绝都发生在分配或发布之前，因此故障不会留下部分序列。

<!-- PTO-READER-BLOCK: tile-tci-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

U16 RowMajor 目标有 4 个有效列，起始寄存器保存 `0x1fffe`，方向为递增。起始值被截断为 65534，因此该行为 65534、65535、0、1；第三个值是 65536 截断到 16 位的结果。

U16 `CUBE_M16` 目标的 ValidRow 为 2、ValidCol 为 3，起始值为 5，Step2D 为 `0xFFFFFFFF00000001`，即 RowStep -1、ColStep +1。第 0 行为 5、6、7，第 1 行为 4、5、6。

以宏形式表示，使用默认起始值与方向的 64 元素 U32 序列写作下面的形式。256B 目标容纳 64 x 4 = 256 字节。

```text
TCI <Row=1, Col=64, U32>, ->T<256B>
```
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TCI <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCI | TEPL | 0x066 | 6 | 3 | TCI |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local S64, S32, S16, U64, U32, or U16 destination |
| scalar0 | typed sequence start from RowMajor/CUBE RegSrc0 |
| flag0 | RowMajor direction or CUBE packed Step2D from RegSrc1 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/initialization/TCI.asl -->
```asl
readonly func InstructionContractOperation_TCI() => TileOperation
begin
    return TileOperation_TCI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TCI, S64|S32|S16|U64|U32|U16
B.DATR RowMajor all-zero (optional), or explicit CUBE_M32/CUBE_M16 tuple
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (RowMajor optional, default 1; when present must equal 1; CUBE required positive)
B.DIM LB2=Col (RowMajor optional, default ValidCol; CUBE optional; omitted aligns ValidCol to the cell-column quantum)
RowMajor: B.IOR Start, Direction (optional; omission selects 0 and ascending)
CUBE: exactly one B.IOR StartGPR, Step2DGPR, zero, ->zero
B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/initialization/TCI.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCI(
    data_type: TileDataType) => boolean
begin
    return TileTCIDataTypeSupported(data_type);
end;

pure func InstructionContractDefaultStart_TCI() => Word
begin
    return Zeros{PTO_XLEN};
end;

pure func InstructionContractDefaultDescending_TCI() => boolean
begin
    return FALSE;
end;

readonly func InstructionContractOperandsLegal_TCI(
    destination: TileIndex,
    start: Word,
    descending: boolean) => boolean
begin
    return TileOperandsLegal_TCI(
        destination,
        start,
        descending);
end;

readonly func InstructionContractHandler_TCI() => TileSemanticHandler
begin
    return TileHandler_TCI;
end;

func InstructionContractExecute_TCI(
    destination: TileIndex,
    start: Word,
    descending: boolean)
begin
    assert InstructionContractOperandsLegal_TCI(
        destination,
        start,
        descending);
    TCI(
        destination,
        start,
        descending);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- RowMajor retains the existing defaults: LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow one; an explicit LB1 must also equal one. Omitted LB2 selects Col equal to ValidCol.
- Omitted B.IOR selects start zero and ascending direction. An explicitly present all-zero B.IOR is a distinct descriptor with the same operand values.
- CUBE is selected only by explicit B.DATR Layout=CUBE_M32 (29) or CUBE_M16 (31); its present B.DATR must use DataType=DTYPE_NONE, Pad=0, CMode=0, RMode=0, Sat=0, and Canonicalize=0.
- CUBE omitted LB2 selects Col=align_up(ValidCol, TileCubeCellColumns(Layout, DataType)); explicit Col is never rounded. CUBE requires one canonical B.IOR with StartGPR, packed Step2DGPR, zero, and ->zero. Physical padding is always Null.

## Legality

- TCI is selected by the TEPL encoding carrier Mode 3 Function 6, canonically assembled with BSTART.SFU, and has no standalone opcode.
- Exactly one terminating destination-only Local B.IOT supplies one newly allocated destination. Every source binding, a second B.IOT, B.IOS, or an unterminated binding stream is illegal.
- The selected DataType is exactly S64, S32, S16, U64, U32, or U16. The existing RowMajor form remains one-row with ValidRow one, ValidCol nonzero, and Col at least ValidCol.
- The CUBE form is selected only by explicit Layout CUBE_M32 (29) or CUBE_M16 (31), uses a Matrix-location Local numeric destination, and retains one exact TileInfo.columns physical Col independently of ValidCol. S64 and U64 CUBE destinations use only CUBE_M32 double-CELL storage; CUBE_M16 remains illegal for b64.
- CUBE M16 requires ValidRow>0 and ValidRow<=16; CUBE M32 accepts every positive ValidRow. Both forms require ValidCol<=Col and a cell-column-aligned explicit Col.
- CUBE B.DATR is exactly {Layout=CUBE_M32/CUBE_M16, DataType=DTYPE_NONE, Pad=0, CMode=0, RMode=0, Sat=0, Canonicalize=0}.
- CUBE B.IOR is exactly StartGPR, packed Step2DGPR with signed s32 RowStep in bits [63:32] and signed s32 ColStep in bits [31:0], then zero and ->zero. Each step is exactly -1, 0, or +1.
- For every logical [0,ValidRow) x [0,ValidCol), CUBE writes trunc_W(Start + r*RowStep + c*ColStep) through the physical CELL mapping. TCI.COL and TCI.ROW spellings are reader-only aliases for the four unit-step tuples and do not add an opcode, selector, or catalog identity.
- PE_MASK zero is a strict no-op before GPR reads, validation, allocation, faults, or payload effects.

## State effects

- For RowMajor logical column k, ascending TCI writes start plus k and descending TCI writes start minus k.
- RowMajor sequence arithmetic wraps modulo the selected element width; only its ValidRow=1 row participates.
- For CUBE, sequence arithmetic wraps modulo the selected element width over the logical rectangle [0,ValidRow) x [0,ValidCol).
- For RowMajor, every physical destination coordinate outside the one-row valid region is undefined Null padding.
- For CUBE, every physical destination coordinate outside the valid rectangle is undefined Null padding.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, form/type, dimensions, exact CUBE Col, TSize, step/selector, mask, destination-name, and capacity preflight precedes private-GPR snapshots.
- The sequence payload, Null padding definedness, and renamed destination descriptor publish atomically; rejection publishes none.

## Exceptions

- RowMajor keeps the existing Fault_TileLegality rules for malformed bindings, B.IOS, unsupported DataType, non-row-major layout, missing or invalid dimensions, direction other than zero or one, and nonzero inapplicable B.DATR fields.
- CUBE malformed command/B.IOR structure raises Fault_BundleControl; invalid selectors, tuple, dimensions, steps, alignment, or representability raise Fault_TileLegality; a legal CUBE geometry with insufficient explicit TSize or exhausted Tile capacity raises Fault_TileAllocation. All reject before allocation/publication.
- PE_MASK zero completes as a strict no-op before every validation, GPR read, descriptor check, allocation, fault, and payload effect.

## Examples

- BSTART.SFU TCI, U16; B.DIM LB0=16; B.IOR a0, a1; B.IOT mask=1111, <last>, ->T0<1>; BSTOP
- BSTART.SFU TCI, U16; B.DATR CUBE_M16, DTYPE_NONE, 0, 0, 0, 0, 0; B.DIM LB0=3; B.DIM LB1=2; B.DIM LB2=4; B.IOR StartGPR, Step2DGPR, zero, ->zero; B.IOT mask=1111, <last>, ->T0<1>; BSTOP
