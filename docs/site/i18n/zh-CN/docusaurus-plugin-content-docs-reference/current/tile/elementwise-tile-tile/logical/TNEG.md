<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TNEG.asl -->
# TNEG

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TNEG.asl`

Typed elementwise arithmetic negation over one Local Tile source.

## Normative identity {#PTO-INST-TILE-TNEG}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tneg-purpose role=purpose -->
## TNEG 的作用

`TNEG` 对一个 Local Tile 的每个元素取负，并把结果写入一个新分配的 Local 目标 Tile。整数按元素位宽回绕取负；浮点值翻转其符号位。

设计要点：`TNEG` 没有独立 opcode。它由 `BSTART.VEC` Mode 0 Function 17（TEPL 选择器 `0x011`）选中，并与 `TABS`、`TNOT` 和 `TRELU` 共用封闭的一元指令束模式。

<!-- PTO-READER-BLOCK: tile-tneg-mechanism role=mechanism -->
## 元素与 Tile 机制

完整预检通过后，`ExecuteTileUnary` 读取源，并变换有效矩形 `ValidRow x ValidCol` 内的每个坐标。

- 整数类型（有符号与无符号）：结果为按元素位宽取模的 `0 - source`。对 `U8`，1 变为 `0xFF`。对 `S8`，-128（`0x80`）仍为 `0x80`，因为 +128 无法表示。
- 浮点类型：只翻转符号位。正零与负零互换编码，无穷大改变符号，NaN 保持其类别与载荷。

设计要点：浮点 `TNEG` 是符号位翻转，而不是用零减去该值。因此它从不舍入，从不报告无效条件（即使遇到信号 NaN），并把正零映射为负零，而 `0 - x` 不会这样做。

设计要点：在任何效果之前，有效区域内的每个源元素（存在 ExecutionMask 时为每个活动元素）都必须是所选 `DataType` 的合法编码。无效的浮点编码（例如低位尾数不为零的 `TF32` 值）会被拒绝，即使该变换只涉及符号位。

<!-- PTO-READER-BLOCK: tile-tneg-inputs-outputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是取负的源，必须是已分配的现有 Local Tile。
- `destination0` 是新分配的 Local Tile，其后备 `DataType` 为所选操作 `DataType`，物理形状、有效形状和布局与源一致。

一条终止 `B.IOT` 在同一个 `PE_MASK` 下绑定两个 Tile；`B.IOR` 与 `B.IOS` 非法。源可以使用位宽相同、非打包的其他后备类型；此时其位按所选 `DataType` 校验和解释。

<!-- PTO-READER-BLOCK: tile-tneg-effects role=effects -->
## 发布、已定义性与填充

源载荷在第一次写目标之前被快照，因此与目标互为别名的源按旧值读取。

目标描述符、有效区域结果、填充以及每个元素的已定义性同时发布。`ValidRow x ValidCol` 之外的元素接收所选 `PadValue`：`Zero`、`Max` 与 `Min` 为已定义值，而 `Null`（省略 `B.DATR` 时的值）使其保持未定义。存在 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值。`TNEG` 没有全局内存效果。

<!-- PTO-READER-BLOCK: tile-tneg-constraints role=constraints -->
## 类型、布局与故障边界

ASL 类型谓词 `TileTNegDataTypeSupported` 接受 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16`、`U8`。打包四位格式不在其中。默认布局为 `RowMajor`，显式 `Layout` 可选择 `CUBE_M16` 或 `CUBE_M32`；`CUBE_N8`、Shared Tile 以及混合布局均非法。

`PE_MASK=0000` 是严格无操作。否则，绑定格式错误、维度缺失或为零、源状态未定义或不匹配、`DataType` 不受支持、布局非所选布局、出现非默认的 `CMode`、`Sat`、`Canonicalize`、第二 `DataType` 或 `RMode`，或浮点源编码无效时，会在任何效果之前引发 `Fault_TileLegality`。目标形状无法表示或 `TSize` 容量不足时，会在分配之前引发 `Fault_TileAllocation`。

<!-- PTO-READER-BLOCK: tile-tneg-example role=example -->
## 非规范契约草图

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

当 `DataType=S8` 时，有效元素 `[5, -3, 0, -128]` 变为 `[-5, 3, 0, -128]`。当 `DataType=FP32` 时，`0x3F800000`（1.0）变为 `0xBF800000`（-1.0），`0x00000000`（正零）变为 `0x80000000`（负零）。

宏形式 `TNEG <Row=8, Col=64, FP32>, T#1, ->T<2KB>` 把一个 `FP32` Tile 的全部 8 x 64 个元素取负，写入新的 2 KB 目标。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TNEG <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TNEG | TEPL | 0x011 | 17 | 0 | ExecuteTileUnary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | negation source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TNEG.asl -->
```asl
readonly func InstructionContractOperation_TNEG() => TileOperation
begin
    return TileOperation_TNEG;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TNEG, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TNEG.asl -->
```asl
pure func InstructionContractDataTypeLegal_TNEG(
    data_type: TileDataType) => boolean
begin
    return TileTNegDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TNEG(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_NEG,
        destination,
        source);
end;

pure func InstructionContractValue_TNEG(
    data_type: TileDataType,
    source: Word) => Word
begin
    let (result, -) = TileFixedUnaryValue(
        TileUnary_NEG,
        data_type,
        source);
    return result;
end;

readonly func InstructionContractHandler_TNEG() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TNEG(
    destination: TileIndex,
    source: TileIndex)
begin
    ExecuteTileUnary(TileUnary_NEG, destination, source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Integer negation is zero minus the source modulo the selected element width, including unsigned types. Floating negation toggles only the sign bit, preserving zeros, infinities, NaN class, and NaN payload without reporting invalid solely for TNEG.

## Legality

- TNEG is BSTART.VEC Mode 0 Function 17 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one Local source and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of S32, S16, S8, FP32, FP16, or BF16.
- Source and destination match physical shape, valid shape, selected layout, DataType, and PE_MASK; the source valid region is fully defined.
- B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- Floating source encodings invalid for the selected DataType reject before allocation or destination effects; PE_MASK zero is a strict no-op.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- For every valid coordinate, negate modulo the selected integer width or toggle only the floating sign bit according to DataType.
- Publish the complete valid result and selected physical padding atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- The source payload is snapshotted after complete schema, dimension, DataType, layout, definedness, encoding, mask, and destination-capacity preflight and before destination writes.
- Source-to-destination aliasing therefore observes the complete pre-operation source payload.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched source state, unsupported DataType, non-selected layout, or invalid floating source encoding raises Fault_TileLegality before effects; an unrepresentable destination shape or insufficient TSize capacity raises Fault_TileAllocation before allocation.
- This operation introduces no memory fault and reports no floating invalid condition solely from its value transform.

## Examples

- BSTART.VEC TNEG, U64; B.DIM LB0=ValidCol; B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
