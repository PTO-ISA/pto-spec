<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TGPR2T.asl -->
# TGPR2T

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TGPR2T.asl`

Re-encode four GPR predicate planes into an ordinary CUBE U8 Tile.

## Normative identity {#PTO-INST-TILE-TGPR2T}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tgpr2t-purpose role=purpose -->
## 用途与范围

`TGPR2T` 把保存在四个通用寄存器（GPR）中的谓词位转置到一个新分配的 `U8` CUBE Tile 中。每个 GPR 保存完整的谓词平面；每个 Tile 行接收所有平面在该行上的位，并打包为字节。

设计要点：`TGPR2T` 由 `BSTART.SFU` 以 TEPL Mode 3 Function 30（选择器 `0x07E`）和操作类型 `U8` 选中。结果是普通数值 `U8` Tile，而不是 PredicateCell，因此其字节可以是 `0x00` 到 `0xFF` 之间的任意值。

<!-- PTO-READER-BLOCK: tile-tgpr2t-mechanism role=mechanism -->
## 位映射

首先，每个填充元素与每个活动的有效元素都被设为有效填充值：`Zero` 为 `0x00`，`Max` 为 `0xFF`。随后字节偏移，即编码的 `B.DATR` `RMode[16:15]` 字段，选择哪一列接收打包字节。

`CUBE_M32`（32 行 4 列）：列 `offset` 的第 r 行接收一个字节，其位 b 为平面 b 在第 r 行的位。平面 p 位于 GPR `p / 2` 的位 `(p mod 2) x 32 + r`，因此平面 0 到 7 用满四个 GPR 的全部 256 位。

`CUBE_M16`（16 行 8 列）：列 `2 x offset` 与 `2 x offset + 1` 的第 r 行分别接收平面 0 到 7 与平面 8 到 15。平面 p 位于 GPR `p / 4` 的位 `(p mod 4) x 16 + r`。

存在 ExecutionMask 时，非活动元素接收该掩码规定的零值或合并值，打包字节只在其坐标为活动时写入。

设计要点：所选字节偏移之外的列保持填充模式。因此读取整个 Tile 的程序看到的是由 `PadValue` 选择的值，而不是先前 Tile 的残留。

<!-- PTO-READER-BLOCK: tile-tgpr2t-inputs role=inputs-outputs -->
## 输入与输出

- `source0` 到 `source3` 是四个 GPR，即上述位映射中的 GPR0 到 GPR3，由 0 到 23 的绝对选择器指定。
- `destination0` 是新分配的数值 `U8` Tile，布局为 `CUBE_M32` 或 `CUBE_M16`。

形状是固定的：`B.DIM` LB1 = 32 且 LB0 = 4 选择 `CUBE_M32`，LB1 = 16 且 LB0 = 8 选择 `CUBE_M16`。两个维度都是必需的，LB2 必须为 1（其默认值），编码的 TSize 必须覆盖整个描述符。

四个 GPR 来自恰好两条紧邻的仅源 `B.IOR` 记录，按 3+1 划分，随后是一条目标 `B.IOT`。[TGPR2T 模式](../../../block/model/dispatch/tgpr2t-schema.md)检查该流。

`B.DATR` 是可选的。省略它时选择 `Zero` 填充与字节偏移 0。

<!-- PTO-READER-BLOCK: tile-tgpr2t-effects role=effects -->
## 效果与状态

四个 GPR 与 PE 掩码都在发布之前被快照，不读取任何旧目标载荷。目标载荷、描述符与已定义性作为一次操作发布；每个元素都变为已定义。

`TGPR2T` 不写任何 GPR，不记录数值状态，也没有全局内存效果。

<!-- PTO-READER-BLOCK: tile-tgpr2t-constraints role=constraints -->
## 边界与失败

- `RMode[17]` 必须为零，`RMode[16:15]` 是字节偏移 0 到 3；对该操作而言，`RMode` 不是舍入方式。
- 有效 `PadValue` 必须为 `Zero` 或 `Max`；`Min` 与 `Null` 会在任何效果之前被拒绝。
- 维度缺失、形状不是 32 x 4 或 16 x 8、中间插入其他命令、`B.IOR` 记录的顺序或划分错误、GPR 目标或多余记录，都会在任何效果之前被拒绝。
- `PE_MASK=0000` 在 `B.IOT` 的 size code 编码检查之后是严格无操作：不再进行模式检查、GPR 读取、分配或效果，但非法的 `B.IOT` size code 仍会引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: tile-tgpr2t-example role=example -->
## 非规范用法示例

生成的 `TGPR2T` 示例仅用于拼写与导航。替换操作数时必须遵守下方 owner 定义的 legality 和状态合同。

头部 `BSTART.SFU TGPR2T, U8` 配合 `B.DIM` LB1 = 32 与 LB0 = 4 选择一个 32 x 4 = 128 字节的 `CUBE_M32` 目标。`B.DATR` 选择 `Zero` 与字节偏移 0。第一个 GPR 为 `0x0000000100000001`，其余三个为零。

第一个 GPR 的位 0 是平面 0 在第 0 行的位，位 32 是平面 1 在第 0 行的位。因此第 0 列的第 0 行接收 `0x03`，其他每个字节都为 `0x00`。若改为 `Max`，第 1 到 3 列保存 `0xFF`，而第 0 列仍在第 0 行保存 `0x03`、在第 1 到 31 行保存 `0x00`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TGPR2T <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGPR2T | TEPL | 0x07E | 30 | 3 | TGPR2T |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | ordinary numeric U8 CUBE destination |
| source0 | ordered source-only GPR0 |
| source1 | ordered source-only GPR1 |
| source2 | ordered source-only GPR2 |
| source3 | ordered source-only GPR3 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TGPR2T.asl -->
```asl
readonly func InstructionContractOperation_TGPR2T() => TileOperation
begin
    return TileOperation_TGPR2T;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TGPR2T, U8
B.DATR PadValueOrByteId, RMode (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow
B.IOR GPR0, GPR1, GPR2
B.IOR GPR3
B.IOT mask=PE_MASK, <last>, ->destination<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TGPR2T.asl -->
```asl
readonly func InstructionContractHandler_TGPR2T() => TileSemanticHandler
begin
    return TileHandler_TGPR2T;
end;

pure func InstructionContractDataTypeLegal_TGPR2T(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_U8;
end;

readonly func InstructionContractOperandsLegal_TGPR2T(
    destination: TileIndex, source0: TileIndex, source1: TileIndex,
    source2: TileIndex, source3: TileIndex) => boolean
begin
    return TileOperandsLegal_TGPR2T(
        destination, source0, source1, source2, source3);
end;

func InstructionContractExecute_TGPR2T(
    destination: TileIndex, source0: TileIndex, source1: TileIndex,
    source2: TileIndex, source3: TileIndex)
begin
    assert InstructionContractOperandsLegal_TGPR2T(
        destination, source0, source1, source2, source3);
    TGPR2T(destination, source0, source1, source2, source3);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Omitted B.DATR selects Zero padding and ByteOffset0.
- LB1/LB0=32/4 selects CUBE_M32; LB1/LB0=16/8 selects CUBE_M16. Both dimensions are mandatory and LB2 is absent.

## Legality

- TGPR2T uses TEPL Mode 3 Function 30 (0x07E) with U8 operation type.
- Exact dimensions 32x4 select an ordinary numeric CUBE_M32 destination and 16x8 select CUBE_M16; LB2 is absent and the encoded TSize must cover the complete descriptor.
- Four ordered source-only 64-bit GPRs are supplied by exactly two contiguous B.IOR records with arity 3+1; selectors are absolute GPR0..GPR23.
- Zero and Max are the only padding values. PE_MASK=0000 is a strict no-op before schema, GPR reads, allocation, or effects.

## State effects

- Pack M32 rows as eight predicate bits into one selected U8 byte; pack M16 rows as sixteen bits into two selected U8 bytes.
- PadValue is independent of ByteOffset; the operation does not change GPRs or status.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- All four GPR sources and PE mask are snapshotted before destination publication.
- No old destination payload is read; successful publication is atomic.

## Exceptions

- RMode[17] must be zero. PadValue accepts only Zero or Max; Min and Null reject before effects.
- Exactly two immediately contiguous source-only B.IOR records split 3+1 are required, followed by one destination B.IOT. Missing dimensions, an intervening command, wrong order/split, GPR destination, or surplus record rejects before effects.

## Examples

- BSTART.SFU TGPR2T, U8; B.DATR PadValueOrByteId, RMode; B.DIM LB0=ValidCol; B.DIM LB1=ValidRow; B.IOR a0, a1, a2; B.IOR a3; B.IOT mask=1111, <last>, ->T0<TSize>; BSTOP
