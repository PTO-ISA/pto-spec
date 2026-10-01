<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/transcendental/TREM.asl -->
# TREM

**Normative ASL source:** `asl/tile/elementwise-tile-tile/transcendental/TREM.asl`

Compute divisor-signed modulo for corresponding Local Tile elements.

## Normative identity {#PTO-INST-TILE-TREM}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-trem-purpose role=purpose -->
## TREM 的作用

`TREM` 对两个 Local Tile 逐元素取模，并把结果写入一个新分配的 Local 目标 Tile。它与 `TDIV` 共用指令束模式、填充和发布规则（包括整数除零检查），并在 `SFU` 引擎上执行。

设计要点：`TREM` 保留 TEPL 载体 Mode 0 Function 4（选择器 `0x004`），没有独立 opcode。其规范头部写作 `BSTART.SFU TREM, DataType`；`SFU` 拼写不增加任何编码位。

<!-- PTO-READER-BLOCK: tile-c-trem-mechanism role=mechanism -->
## 元素与 Tile 机制

完整预检之后，`ExecuteTileBinary` 为有效矩形 `ValidRow x ValidCol` 内的每个坐标计算一个取模结果。规则取决于 `DataType` 的种类：

- 有符号整数使用向下取整取模。非零结果总是与除数同号，且其绝对值小于除数的绝对值。
- 无符号整数使用普通的无符号余数。
- 浮点类型使用浮点取模参考定义：`dividend - q * divisor`，其中 `q` 是向零截断的 `dividend / divisor`，并按固定默认舍入只舍入一次。

设计要点：向下取整取模不同于许多编程语言中的截断余数。对有符号整数，这里 `-7 mod 3` 为 `2` 而不是 `-1`，`7 mod -3` 为 `-2` 而不是 `1`。对有符号整数，让结果符号跟随除数，使得除数为正时结果总是落在 0 到 `divisor - 1` 的有效索引范围内。

有效除数矩形内任何位置出现整数零，都会在任何源快照或目标效果之前引发 `Fault_TileLegality`。除数的填充区不会被读取。整数类型没有表示 `x mod 0` 的编码，因此指令束被拒绝，而不是得到一个虚构的值。

对浮点类型，任一操作数为 NaN、零除数或无穷被除数都会产生静默 NaN。除此之外，无穷除数或零被除数则原样返回被除数。

<!-- PTO-READER-BLOCK: tile-c-trem-inputs-outputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是被除数，必须是已分配的现有 Local Tile。
- `source1` 是除数，其物理行数、物理列数、有效行数、有效列数和布局必须与 `source0` 相同。
- `destination0` 是新分配的 Local Tile，其后备 `DataType` 为所选操作 `DataType`，形状与源一致。

三个 Tile 由同一条终止 `B.IOT` 绑定，并共享一个 `PE_MASK`。`PE_MASK=0000` 是严格无操作。源可以使用位宽相同、非打包的其他后备类型存储；此时这些位按所选 `DataType` 校验和解释。

<!-- PTO-READER-BLOCK: tile-c-trem-effects role=effects -->
## 发布、已定义性与填充

只有在全部合法性检查与整数零检查通过之后，两个源才被快照，因此与目标别名的源会在被覆盖之前读取。目标描述符、有效区域内的结果、填充以及每个元素的已定义性同时发布。被拒绝的指令束不会改变描述符、载荷或分配状态。

`ValidRow x ValidCol` 之外的物理元素接收所选 `PadValue`。`Zero` 写入零；`Max` 与 `Min` 写入该 `DataType` 的最大与最小有限值；`Null` 使这些元素保持未定义。省略 `B.DATR` 选择 `Null`，而显式编码 `00` 选择 `Zero`。

`TREM` 没有全局内存效果。存在 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值，而不是结果。

<!-- PTO-READER-BLOCK: tile-c-trem-constraints role=constraints -->
## 类型、布局与故障边界

ASL 合法性谓词 `TileVecArithmeticDataTypeSupported` 接受 16 种类型：`FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16` 与 `U8`。下方生成的合法性列表更窄，只列出 `S32`、`U32`、`FP32`、`S16`、`U16`、`FP16` 与 `BF16`。浮点取模参考定义仅针对 `FP32`、`FP16` 与 `BF16`，因此代码应使用较窄列表中的类型。

默认布局为 `RowMajor`。显式 `Layout` 可以选择 `CUBE_M16` 或 `CUBE_M32`，所有操作数必须使用同一布局。`CUBE_N8`、Shared Tile 以及混合布局均非法。`TREM` 拒绝非默认的 `RMode`、`Sat` 与 `CMode`。

整数零除数、绑定格式错误、维度缺失或为零、源未定义或不匹配、`DataType` 不受支持或目标容量无效时，会在任何目标效果之前引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: tile-c-trem-example role=example -->
## 非规范演算示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

对 `S32`，被除数行 `[7, -7, 7, -7]` 与除数行 `[3, 3, -3, -3]` 产生目标行 `[1, 2, -2, -1]`。每个非零结果都与其除数同号。

对 `U32`，被除数行 `[7, 9]` 与除数行 `[3, 4]` 产生 `[1, 1]`。

以宏形式表示，一个 8 x 64 的 `S32` 取模写作 `TREM <Row=8, Col=64, S32>, T#1, T#2, ->T<2KB>`，其中 `T#1` 是被除数，`T#2` 是除数。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `SFU`

## Assembly

```asm
TREM <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TREM | TEPL | 0x004 | 4 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | ordered dividend |
| source1 | ordered divisor |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/transcendental/TREM.asl -->
```asl
readonly func InstructionContractOperation_TREM() => TileOperation
begin
    return TileOperation_TREM;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TREM, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Dividend, Divisor, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/transcendental/TREM.asl -->
```asl
pure func InstructionContractDataTypeLegal_TREM(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TREM(
    destination: TileIndex,
    dividend: TileIndex,
    divisor: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_REM,
        destination,
        dividend,
        divisor);
end;

readonly func InstructionContractHandler_TREM() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TREM(
    destination: TileIndex,
    dividend: TileIndex,
    divisor: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_REM,
        destination,
        dividend,
        divisor);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and nonzero; omitted LB1 selects ValidRow=1 and omitted LB2 selects Col=ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- The numeric profile owns fixed rounding, signed overflow boundaries, floating exceptional values, and floating zero modulo.

## Legality

- TREM retains TEPL carrier Mode 0 Function 4 but is canonically classified as SFU.
- Exactly one terminating Local B.IOT supplies ordered dividend and divisor sources plus one new Local destination; B.IOR and B.IOS are illegal and PE_MASK zero is a strict no-op.
- DataType is exactly S32, U32, FP32, S16, U16, FP16, or BF16.
- Only B.DATR PadValueOrByteId is applicable.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- Signed integer modulo uses floor division so a nonzero result has the divisor's sign; unsigned integers use ordinary unsigned remainder and floating values use the selected modulo profile.
- The valid modulo result and selected physical padding publish atomically; rejection leaves descriptor, payload, and allocation state unchanged.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both source payloads are snapshotted after all legality and integer-zero checks, so aliasing is read-before-write.

## Exceptions

- An integer zero in the valid divisor rectangle raises Fault_TileLegality before snapshots, allocation publication, or destination effects; divisor padding is not read.
- Malformed bindings, unsupported types, undefined inputs, mismatched descriptors, or invalid capacity reject before effects; floating zero is handled by the selected numeric profile.

## Examples

- BSTART.SFU TREM, S64; B.DIM LB0=ValidCol; B.IOT Dividend, Divisor, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
