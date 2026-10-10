<!-- GENERATED FROM: asl/tile/tile-scalar-and-immediate/arithmetic/TREMS.asl -->
# TREMS

**Normative ASL source:** `asl/tile/tile-scalar-and-immediate/arithmetic/TREMS.asl`

Compute divisor-signed modulo of every valid Local Tile element by one scalar.

## Normative identity {#PTO-INST-TILE-TREMS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-trems-purpose role=purpose -->
## TREMS 的作用

`TREMS` 计算 Local 源 Tile 有效矩形内每个元素对一个标量除数的模，并把结果写入一个新分配的 Local 目标 Tile。它由 TEPL Mode 1 Function 4（选择器 `0x024`）选中，规范写法为 `BSTART.SFU TREMS, DataType`，没有独立 opcode。

设计要点：标量是指令束操作数，而不是 Tile。Tile-Tile 形式 `TREM` 需要第二个形状和布局都相同的源 Tile，因此用它施加同一个值时，必须先构造一个填满该值的 Tile，例如使用 `TEXPANDS`。`TREMS` 直接从 GPR 读取该值，因此不需要分配广播 Tile，也不需要使其成为已定义。

<!-- PTO-READER-BLOCK: tile-c-trems-mechanism role=mechanism -->
## 标量来源与元素机制

标量来自 `B.IOR.RegSrc0`。每个参与的 PE 在自己的私有 GPR 文件中解析该选择器，因此同一 `PE_MASK` 选中的各 PE 可以使用不同的标量值。指令束中没有用于标量的立即数字段；省略 `B.IOR` 时标量为零。

64 位 GPR 值由 `TileRawElementValue` 收窄：只保留与所选 `DataType` 元素位宽一致的低 8、16、32 或 64 位。不发生数值转换。浮点标量必须已经是所选类型的编码，有符号整数标量按元素位宽的补码值读取。

预检通过后，`ExecuteTileScalar` 对 `ValidRow x ValidCol` 内的每个坐标计算 `source mod scalar`。操作数顺序是固定的：结果是 `source mod scalar`，标量是除数。对有符号整数，商向负无穷取整，因此每个非零结果都与除数同号。无符号类型使用普通无符号取模。浮点类型把商向零截断，因此非零浮点结果与被除数同号，而不是与除数同号。

设计要点：对有符号整数，这不是许多编程语言中的截断余数。`TileSignedModulo` 先求截断余数；当它非零且符号与除数不同时，再加上一次除数。因此结果要么为零，要么与除数同号，且其绝对值小于除数的绝对值。

当至少一个坐标处于活动状态时，整数零除数会在预检阶段被拒绝；没有活动坐标的 ExecutionMask 使该操作成为合法的无操作。浮点正零或负零除数是合法的；它产生规范静默 NaN 并置无效状态。

设计要点：包括标量检查在内的所有检查都在对源和标量做快照之前完成，并且只有在所有元素计算完成后才发布结果。因此与目标别名的源按其旧值读取。

<!-- PTO-READER-BLOCK: tile-c-trems-inputs-outputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是 Tile 操作数，必须是已存在的 Local 数值 Tile，并保持不变。
- `scalar0` 是来自 `B.IOR.RegSrc0` 的逐 PE 标量。显式 `B.IOR` 必须使 `RegSrc1`、`RegSrc2` 和 `RegDst` 保持为零。
- `destination0` 是新分配的 Local Tile，其后备 `DataType` 为所选 `DataType`，形状与布局与源一致。

一条终止 `B.IOT` 绑定源与目标，二者使用同一个 `PE_MASK`。`B.IOS` 与额外的 Tile 绑定均非法。

设计要点：`PE_MASK=0000` 是严格无操作。它在任何 GPR 读取、描述符读取、分配、故障或状态效果之前退出，因此没有 PE 参与的指令束永远不会读取标量寄存器。

设计要点：源可以使用位宽相同、非打包的其他后备类型存储，例如以 `FP16` 读取 `U16` 数据。此时源的位与标量都按所选 `DataType` 校验和解释，从而无需拷贝即可完成重解释读取。位宽不一致或打包四位载体仍然非法。

<!-- PTO-READER-BLOCK: tile-c-trems-effects role=effects -->
## 发布、已定义性与填充

目标作为一个整体变为可见：描述符、有效区域结果、填充、每个元素的已定义性以及任何数值状态同时发布。被拒绝的指令束没有任何架构效果。

`ValidRow x ValidCol` 之外的物理元素接收所选 `PadValue`。`Zero`、`Max` 与 `Min` 用该 `DataType` 的对应值定义这些元素；`Null` 使其保持未定义。省略 `B.DATR` 选择 `Null`，而显式编码 `00` 选择 `Zero`。

省略 `B.IOR` 时标量为零：对存在活动坐标的整数 `DataType`，它是非法除数；对浮点 `DataType`，它是合法的正零除数。

`TREMS` 没有全局内存效果。存在 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值，而不是计算结果。

<!-- PTO-READER-BLOCK: tile-c-trems-constraints role=constraints -->
## 类型、布局与故障边界

`TREMS` 恰好接受 `FP64`、`S64`、`U64`、`S32`、`U32`、`FP32`、`S16`、`U16`、`FP16` 与 `BF16`。四种被接受的浮点类型（包括 `FP64`）都有可执行浮点余数定义；整数形式保留其带类型余数规则。

默认布局为 `RowMajor`。显式 `B.DATR` `Layout` 可以选择 `CUBE_M16` 或 `CUBE_M32`；源与目标必须使用同一布局，`CUBE_N8` 与 Shared Tile 均非法；在 CUBE 布局中，64 位操作类型只在 `CUBE_M32` 中合法；`CUBE_M16` 会拒绝。`B.DATR` 只接受 `PadValueOrByteId` 与 `Layout`，因此非默认的 `RMode`、`Sat`、`CMode`、`Canonicalize` 或次级 `DataType` 会被拒绝。

有效矩形内的每个源元素（存在 ExecutionMask 时为每个活动元素）都必须已定义。绑定格式错误、出现 `B.IOS`、`B.IOR` 字段多余、维度缺失或为零、`DataType` 不受支持、源或标量编码无效、非法整数零除数、容量或分配失败时，会在任何目标效果之前引发 `Fault_TileLegality` 或 `Fault_TileAllocation`。

<!-- PTO-READER-BLOCK: tile-c-trems-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

以 `S32` 为例：源行 `[-7, 7]` 与标量 `3` 产生 `[2, 1]`，与标量 `-3` 产生 `[-1, -2]`。截断余数对标量 `3` 则会给出 `[-1, 1]`。对 `FP32`，`-7.0 mod 3.0` 为 `-1.0`，因为浮点取模按截断计算。

其宏形式为 `TREMS <Row=8, Col=64, S32>, T#1, a2, ->T<2KB>`。它使用规范的 `BSTART.SFU` 汇编，同时保留 TEPL Mode 1 Function 4 编码。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `tile-scalar-and-immediate`
- **Execution engine:** `SFU`

## Assembly

```asm
TREMS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TREMS | TEPL | 0x024 | 4 | 1 | ExecuteTileScalar |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-and-immediate/arithmetic/TREMS.asl -->
```asl
readonly func InstructionContractOperation_TREMS() => TileOperation
begin
    return TileOperation_TREMS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TREMS, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR ScalarGPR, zero, zero, ->zero (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-and-immediate/arithmetic/TREMS.asl -->
```asl
pure func InstructionContractDataTypeLegal_TREMS(
    data_type: TileDataType) => boolean
begin
    return TileBinaryDataTypeSupported(
        TileBinary_REM,
        data_type);
end;

readonly func InstructionContractOperandsLegal_TREMS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word) => boolean
begin
    return TileOperandsLegal_ExecuteTileScalar(
        TileBinary_REM,
        destination,
        source,
        scalar);
end;

readonly func InstructionContractHandler_TREMS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileScalar;
end;

func InstructionContractExecute_TREMS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word)
begin
    assert InstructionContractOperandsLegal_TREMS(
        destination,
        source,
        scalar);
    ExecuteTileScalar(
        TileBinary_REM,
        destination,
        source,
        scalar);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null and Layout=NORM (RowMajor). Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Omitted B.IOR supplies scalar zero; this is illegal for integer DataTypes when at least one logical coordinate is ExecutionMask-active, is a legal no-op when every coordinate is inactive, and remains a legal profile-defined positive-zero divisor for floating DataTypes. An explicitly present all-zero B.IOR is distinct but supplies the same value; RegSrc1, RegSrc2, and RegDst must be zero.

## Legality

- TREMS is selected only by the TEPL raw carrier Mode 1 Function 4; canonical execution-engine assembly is BSTART.SFU TREMS, DataType.
- Exactly one terminating Local B.IOT supplies one persistent Local numeric source and one newly allocated Local destination. B.IOS and additional Tile bindings are illegal.
- The selected DataType is exactly FP64, S64, U64, S32, U32, FP32, S16, U16, FP16, or BF16; every other assigned or reserved DataType rejects before effects.
- B.IOR is optional and, when present, only RegSrc0 may be nonzero. B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; explicit nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- Source and destination use one PE_MASK. PE_MASK=0000 is a strict no-op before GPR reads, descriptor reads, allocation, faults, numeric status, or payload effects.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- For each valid element compute source mod scalar in the selected element interpretation.
- Publish valid payload, selected padding definedness, numeric status where applicable, and destination descriptor atomically; the source persists and rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, dimension, type, descriptor, source-definedness, scalar-encoding, mask, capacity, and allocation preflight precedes source and scalar snapshots.
- The source payload and scalar are snapshotted before destination publication, so a source that aliases the renamed destination observes its old value.

## Exceptions

- A malformed Local binding stream, B.IOS presence, surplus B.IOR field, missing or zero dimension, unsupported DataType, source descriptor or encoding failure, invalid destination capacity, or allocation failure raises Fault_TileLegality or Fault_TileAllocation before effects.
- Signed integer quotient selection uses floor division so a nonzero result has the divisor sign; integer scalar zero is illegal before effects when at least one logical coordinate is ExecutionMask-active, while an all-inactive operation is a legal no-op.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies precise restart and completion after an accepted operation.

## Examples

- BSTART.SFU TREMS, DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR ScalarGPR, zero, zero, ->zero (optional); BSTOP
