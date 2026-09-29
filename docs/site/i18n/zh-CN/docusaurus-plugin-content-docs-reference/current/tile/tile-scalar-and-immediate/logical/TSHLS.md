<!-- GENERATED FROM: asl/tile/tile-scalar-and-immediate/logical/TSHLS.asl -->
# TSHLS

**Normative ASL source:** `asl/tile/tile-scalar-and-immediate/logical/TSHLS.asl`

Shift every valid integer Tile element left by one scalar count.

## Normative identity {#PTO-INST-TILE-TSHLS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tshls-purpose role=purpose -->
## TSHLS 的作用

`TSHLS` 把整数 Local 源 Tile 有效矩形内的每个元素左移一个标量计数，并把结果写入一个新分配的 Local 目标 Tile。它由 TEPL Mode 1 Function 9（选择器 `0x029`）选中，规范写法为 `BSTART.VEC TSHLS, DataType`，没有独立 opcode。

设计要点：标量是指令束操作数，而不是 Tile。Tile-Tile 形式 `TSHL` 需要第二个形状和布局都相同的源 Tile，因此用它施加同一个值时，必须先构造一个填满该值的 Tile，例如使用 `TEXPANDS`。`TSHLS` 直接从 GPR 读取该值，因此不需要分配广播 Tile，也不需要使其成为已定义。

<!-- PTO-READER-BLOCK: tile-c-tshls-mechanism role=mechanism -->
## 标量来源与元素机制

标量来自 `B.IOR.RegSrc0`。每个参与的 PE 在自己的私有 GPR 文件中解析该选择器，因此同一 `PE_MASK` 选中的各 PE 可以使用不同的标量值。指令束中没有用于标量的立即数字段；省略 `B.IOR` 时标量为零。

64 位 GPR 值由 `TileRawElementValue` 收窄：只保留与所选 `DataType` 元素位宽一致的低 8、16、32 或 64 位。不发生数值转换。保留下来的位作为元素位宽的原始位模式使用。

预检通过后，`ExecuteTileScalar` 对 `ValidRow x ValidCol` 内的每个坐标计算 `source << count`。对元素位宽 W，移位计数是标量低 log2(W) 位的无符号值：8 位类型取 3 位，16 位取 4 位，32 位取 5 位，64 位取 6 位。移出 W 之外的位被丢弃，有符号性不改变结果。

设计要点：对计数取掩码意味着每个标量值都是合法计数，因此不存在越界移位故障，也不存在依赖标量值的拒绝。大于或等于 W 的计数会回绕：对 `U8` Tile，计数 9 实际移 1 位。

设计要点：包括标量检查在内的所有检查都在对源和标量做快照之前完成，并且只有在所有元素计算完成后才发布结果。因此与目标别名的源按其旧值读取。

<!-- PTO-READER-BLOCK: tile-c-tshls-inputs-outputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是 Tile 操作数，必须是已存在的 Local 数值 Tile，并保持不变。
- `scalar0` 是来自 `B.IOR.RegSrc0` 的逐 PE 标量。显式 `B.IOR` 必须使 `RegSrc1`、`RegSrc2` 和 `RegDst` 保持为零。
- `destination0` 是新分配的 Local Tile，其后备 `DataType` 为所选 `DataType`，形状与布局与源一致。

一条终止 `B.IOT` 绑定源与目标，二者使用同一个 `PE_MASK`。`B.IOS` 与额外的 Tile 绑定均非法。

设计要点：`PE_MASK=0000` 是严格无操作。它在任何 GPR 读取、描述符读取、分配、故障或状态效果之前退出，因此没有 PE 参与的指令束永远不会读取标量寄存器。

设计要点：源可以使用位宽相同、非打包的其他后备类型存储。按位与移位操作直接消费存储的载体位，因此这些位不会按数值校验；位宽不一致或打包四位载体仍然非法。

<!-- PTO-READER-BLOCK: tile-c-tshls-effects role=effects -->
## 发布、已定义性与填充

目标作为一个整体变为可见：描述符、有效区域结果、填充以及每个元素的已定义性同时发布。该操作不产生数值状态，被拒绝的指令束没有任何架构效果。

`ValidRow x ValidCol` 之外的物理元素接收所选 `PadValue`。`Zero`、`Max` 与 `Min` 用该 `DataType` 的对应值定义这些元素；`Null` 使其保持未定义。省略 `B.DATR` 选择 `Null`，而显式编码 `00` 选择 `Zero`。

省略 `B.IOR` 时提供零计数，因此每个有效源编码都原样复制。

`TSHLS` 没有全局内存效果。存在 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值，而不是计算结果。

<!-- PTO-READER-BLOCK: tile-c-tshls-constraints role=constraints -->
## 类型、布局与故障边界

可接受的数据类型集合为 `S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16`、`U8`。浮点、打包及其他编码会在任何效果之前被拒绝。

默认布局为 `RowMajor`。显式 `B.DATR` `Layout` 可以选择 `CUBE_M16` 或 `CUBE_M32`；源与目标必须使用同一布局，`CUBE_N8` 与 Shared Tile 均非法。`B.DATR` 只接受 `PadValueOrByteId` 与 `Layout`，因此非默认的 `RMode`、`Sat`、`CMode`、`Canonicalize` 或次级 `DataType` 会被拒绝。

有效矩形内的每个源元素（存在 ExecutionMask 时为每个活动元素）都必须已定义。绑定格式错误、出现 `B.IOS`、`B.IOR` 字段多余、维度缺失或为零、`DataType` 不受支持、载体位宽不匹配、容量或分配失败时，会在任何目标效果之前引发 `Fault_TileLegality` 或 `Fault_TileAllocation`。

<!-- PTO-READER-BLOCK: tile-c-tshls-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

以 `U8` 为例：源行 `[0x81, 0x03]` 与标量 `9` 使用计数 1，产生 `[0x02, 0x06]`；`0x81` 的最高位被丢弃。

其宏形式为 `TSHLS <Row=8, Col=64, U8>, T#1, a2, ->T<512B>`；全部 512 个单字节元素均有效。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `tile-scalar-and-immediate`
- **Execution engine:** `VEC`

## Assembly

```asm
TSHLS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSHLS | TEPL | 0x029 | 9 | 1 | ExecuteTileScalar |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### B.DATR.PadValueOrByteId (`PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID`)

Carries the operation-selected PadValue or ByteId union field.

**Encoded zero:** For PadValue operations code zero selects Zero; for ByteId operations it selects ByteId zero.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | Zero-or-ByteId0 |
| 1 | assigned | Max-or-ByteId1 |
| 2 | assigned | Min-or-ByteId2 |
| 3 | assigned | Null-or-ByteId3 |

**Reserved-value behavior:** All four encodings are assigned; the selected operation separately validates whether the field is PadValue, ByteId, or inapplicable.

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

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local numeric destination |
| source0 | persistent Local numeric source |
| scalar0 | per-participating-PE private-GPR scalar |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-and-immediate/logical/TSHLS.asl -->
```asl
readonly func InstructionContractOperation_TSHLS() => TileOperation
begin
    return TileOperation_TSHLS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TSHLS, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR ScalarGPR, zero, zero, ->zero (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-and-immediate/logical/TSHLS.asl -->
```asl
pure func InstructionContractDataTypeLegal_TSHLS(
    data_type: TileDataType) => boolean
begin
    return TileBinaryDataTypeSupported(
        TileBinary_SHL,
        data_type);
end;

readonly func InstructionContractOperandsLegal_TSHLS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word) => boolean
begin
    return TileOperandsLegal_ExecuteTileScalar(
        TileBinary_SHL,
        destination,
        source,
        scalar);
end;

readonly func InstructionContractHandler_TSHLS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileScalar;
end;

func InstructionContractExecute_TSHLS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word)
begin
    assert InstructionContractOperandsLegal_TSHLS(
        destination,
        source,
        scalar);
    ExecuteTileScalar(
        TileBinary_SHL,
        destination,
        source,
        scalar);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null and Layout=NORM (RowMajor). Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Omitted B.IOR supplies a zero shift count and therefore preserves every valid source encoding. An explicitly present all-zero B.IOR is distinct but supplies the same value; RegSrc1, RegSrc2, and RegDst must be zero.

## Legality

- TSHLS is selected only by the TEPL raw carrier Mode 1 Function 9; canonical execution-engine assembly is BSTART.VEC TSHLS, DataType.
- Exactly one terminating Local B.IOT supplies one persistent Local numeric source and one newly allocated Local destination. B.IOS and additional Tile bindings are illegal.
- The selected DataType is exactly S64, S32, S16, S8, U64, U32, U16, or U8; every other assigned or reserved DataType rejects before effects.
- B.IOR is optional and, when present, only RegSrc0 may be nonzero. B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; explicit nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- Source and destination use one PE_MASK. PE_MASK=0000 is a strict no-op before GPR reads, descriptor reads, allocation, faults, numeric status, or payload effects.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- For each valid element compute source << masked_count in the selected element interpretation.
- Publish valid payload, selected padding definedness, numeric status where applicable, and destination descriptor atomically; the source persists and rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, dimension, type, descriptor, source-definedness, scalar-encoding, mask, capacity, and allocation preflight precedes source and scalar snapshots.
- The source payload and scalar are snapshotted before destination publication, so a source that aliases the renamed destination observes its old value.

## Exceptions

- A malformed Local binding stream, B.IOS presence, surplus B.IOR field, missing or zero dimension, unsupported DataType, source descriptor, definedness, or carrier-width failure, invalid destination capacity, or allocation failure raises Fault_TileLegality or Fault_TileAllocation before effects.
- For element width W, the count is the scalar low log2(W) bits and the stored result is truncated to W bits.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies precise restart and completion after an accepted operation.

## Examples

- BSTART.VEC TSHLS, DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR ScalarGPR, zero, zero, ->zero (optional); BSTOP
