<!-- GENERATED FROM: asl/tile/tile-scalar-and-immediate/arithmetic/TLEA.asl -->
# TLEA

**Normative ASL source:** `asl/tile/tile-scalar-and-immediate/arithmetic/TLEA.asl`

Extend logical element indices to 64 bits and explicitly scale them to byte offsets.

## Normative identity {#PTO-INST-TILE-TLEA}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tlea-purpose role=purpose -->
## TLEA 的作用

`TLEA` 把 Local Tile 中的逻辑元素索引转换为一个新的 Local 字节偏移 Tile。它由 TEPL Mode 1 Function 14（选择器 `0x02E`）选中，规范头部为 `BSTART.VEC TLEA, SrcDataType`，没有独立 opcode。

设计要点：结果是偏移 Tile，不是地址 Tile。`TLEA` 不读取基址寄存器，也不访问内存。后续的索引内存操作（如 [`MGATHER`](../../memory-and-data-movement/irregular/MGATHER.md)）使用自己的基址与字节位移组合地址。

<!-- PTO-READER-BLOCK: tile-tlea-mechanism role=mechanism -->
## 先扩展再按字节缩放

每个参与 PE 从 `B.IOR.RegSrc0` 选中的私有 GPR 读取 `element_bits`。只接受 8、16、32 和 64，因此对应的字节缩放因子为 1、2、4 和 8。该 GPR 值描述被索引元素的位宽，不会加到结果中。

对每个活动坐标，有符号 `S32` 或 `S64` 索引先符号扩展为 `S64`，无符号 `U32` 或 `U64` 索引先零扩展为 `U64`。随后，扩展后的 64 位值乘以 `element_bits / 8`，并保留结果的低 64 位。目标类型遵循源的符号性：有符号输入生成 `S64`，无符号输入生成 `U64`。

设计要点：扩展先于缩放，使负的 `S32` 索引仍表示负的 64 位位移。例如，32 位元素下的 `S32(-1)` 在乘以 4 之前先成为 64 位位模式 `0xFFFFFFFFFFFFFFFF`，结果为 `0xFFFFFFFFFFFFFFFC`。这是模 2^64 的定宽位向量乘法，不依赖 C 或 C++ 的有符号溢出行为。

相比之下，`element_bits=32` 时，`U32` 行 `[0, 1, 2]` 生成字节偏移 `[0, 4, 8]`。把这些值交给索引操作时，职责边界清晰：`TLEA` 负责逻辑索引到字节偏移的转换，`MGATHER` 负责基址相加与内存访问。

<!-- PTO-READER-BLOCK: tile-tlea-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是持久 Local 索引 Tile，后备类型必须恰为 `S32`、`U32`、`S64` 或 `U64`。
- `scalar0` 是来自 `B.IOR.RegSrc0` 的必需逐 PE 元素位宽。除既有 ExecutionMask 绑定扩展外，`RegSrc1`、`RegSrc2` 与 `RegDst` 保持为零。
- `destination0` 是新分配的 Local 字节偏移 Tile，元素类型为对应的 `S64` 或 `U64`。

一条终止 `B.IOT` 绑定源与重命名目标。源和目标具有相同的逻辑 `ValidRow x ValidCol` 形状及相同布局，但各自独立检查物理描述符。这在 32 位索引扩展为 64 位偏移时尤其重要；合法 CUBE 目标所需的容量或物理列几何可以与源不同。

`PE_MASK=0000` 是严格无操作，在 GPR 读取、描述符读取、分配、源快照或故障之前退出。其他情况下，所有合法性与分配检查均在源快照前完成，因此 `S64` 或 `U64` 源与目标直接别名时读取旧载荷。

<!-- PTO-READER-BLOCK: tile-tlea-effects role=effects -->
## 发布、掩码与填充

预检与源快照完成后，目标描述符、活动坐标结果、填充和已定义性一起变为可见。源保持不变，不更新数值状态；被拒绝的操作不产生目标效果。

对于 `CUBE_M32`，非活动 ExecutionMask 坐标遵循既有 ZERO 或 MERGE 规则，并且不读取对应源元素。一个掩码位控制完整 64 位逻辑结果，包括两个物理 CELL 平面。MERGE 通过既有目标掩码源取得值；ZERO 提供目标类型的零编码。

逻辑有效矩形之外的物理元素接收所选 `PadValue`。省略 `B.DATR` 选择 `Null` 与 `RowMajor`；唯一显式 CUBE 布局是 `CUBE_M32`。填充与有效矩形内部的 ExecutionMask 处理相互独立。

<!-- PTO-READER-BLOCK: tile-tlea-constraints role=constraints -->
## 类型、布局与故障边界

源操作类型与后备类型必须完全相同，并且只能是 `S32`、`U32`、`S64` 或 `U64`。打包四位类型、浮点类型、更窄整数、Shared Tile 与 `CUBE_N8` 均不支持。标量元素位宽必须恰为 8、16、32 或 64 位；对于活动 block，零和其他所有 GPR 值都会被拒绝。

`RowMajor` 与 `CUBE_M32` 使用相同逻辑形状，同时允许源与目标拥有独立合法物理描述符。每个 TLEA 目标都是 64 位，因此其 CUBE_M32 描述符对每个逻辑列使用两个完整 CELL；32 位 CUBE_M32 源可以只用一个。即使源索引类型为 32 位，`CUBE_M16` 也非法。

保留低 64 位的乘积不会引发溢出故障。`TLEA` 只生成字节偏移，因此也不会引入内存访问故障；后续的基址算术、地址校验或内存事件由消费该偏移的内存指令负责。

<!-- PTO-READER-BLOCK: tile-tlea-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

对于 `U32` 源行 `[0, 1, 2]` 与 `element_bits=32`，零扩展得到相同的三个 64 位值，再乘以 4 得到 `U64` 行 `[0, 4, 8]`。若 `MGATHER` 随后使用基址 `0x1000`，其内存地址为 `0x1000`、`0x1004` 与 `0x1008`；该基址相加由 `MGATHER` 执行，不由 `TLEA` 执行。

对于相同元素位宽下的 `S32` 源行 `[-1, 0, 1]`，符号扩展后进行模 2^64 乘法，得到 `S64` 位模式 `[0xFFFFFFFFFFFFFFFC, 0x0000000000000000, 0x0000000000000004]`。第一个结果表示 -4 字节位移，不会触发宿主语言的有符号溢出。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `tile-scalar-and-immediate`
- **Execution engine:** `VEC`

## Assembly

```asm
TLEA <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TLEA | TEPL | 0x02E | 14 | 1 | TLEA |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

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
| destination0 | new Local S64/U64 byte-offset destination |
| source0 | persistent Local S32/U32/S64/U64 element indices |
| scalar0 | per-PE element width in bits |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-and-immediate/arithmetic/TLEA.asl -->
```asl
readonly func InstructionContractOperation_TLEA() => TileOperation
begin
    return TileOperation_TLEA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TLEA, SrcDataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=DstCol (optional)
B.IOT IndexTile, mask=PE_MASK, <last>, ->ByteOffsetTile<TSize>
B.IOR ElementBitsGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-and-immediate/arithmetic/TLEA.asl -->
```asl
pure func InstructionContractDataTypeLegal_TLEA(data_type: TileDataType)
    => boolean
begin
    return TileLEAIndexDataTypeLegal(data_type);
end;

readonly func InstructionContractHandler_TLEA() => TileSemanticHandler
begin
    return TileHandler_TLEA;
end;

func InstructionContractExecute_TLEA(
    destination: TileIndex, source: TileIndex, element_bits: Word)
begin
    assert TileOperandsLegal_TLEA(destination, source, element_bits);
    TLEA(destination, source, element_bits);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies ValidCol; omitted LB1 selects one and omitted LB2 selects destination physical Col equal to ValidCol.
- B.IOR is required and RegSrc0 supplies element width in bits; there is no implicit width or base address.
- Omitted B.DATR selects PadValue=Null and RowMajor; Layout 29/31 select CUBE_M32/CUBE_M16.

## Legality

- TEPL Mode 1 Function 14 (selector 0x02E) accepts exactly S32, U32, S64 and U64 source operation/backing types.
- The scalar element width is exactly 8, 16, 32 or 64 bits; packed four-bit widths reject.
- One terminating Local B.IOT supplies one index source and a renamed destination; B.IOR is required and unused selectors/destination encode zero, subject to explicit ExecutionMask binding extensions.
- Source and destination have matching logical valid shape and RowMajor/CUBE_M32 layout, with independent physical capacity and geometry; Shared and CUBE_N8 reject.
- B.DATR accepts padding/layout and existing applicable ExecutionMask controls; numeric conversion controls are not applicable.
- PE_MASK=0000 is a strict no-op before reads, allocation and faults.
- Local CUBE_M32 S64/U64 output uses the issue #371 double-CELL mapping; RowMajor is also legal and CUBE_M16 b64 output is not assigned.

## State effects

- Signed inputs sign-extend to S64 and unsigned inputs zero-extend to U64 before multiplication by element_bits/8; retain the low 64 bits.
- TLEA generates byte offsets only, without BaseGPR addition, memory events or numeric-status updates.
- Inactive Local CUBE ExecutionMask coordinates follow existing MERGE/ZERO without source reads; direct S64/U64 aliasing reads old source payloads.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete legality/allocation preflight and source snapshots precede atomic destination publication.

## Exceptions

- Unsupported index types, element widths, layout, descriptor, schema or logical-shape mismatch rejects before effects; insufficient destination capacity follows Fault_TileAllocation.
- No overflow, memory-access or numeric-status fault is introduced.

## Examples

- BSTART.VEC TLEA, S32; B.DIM LB0=ValidCol; B.IOT IndexTile, mask=PE_MASK, <last>, ->ByteOffsetTile<TSize>; B.IOR ElementBitsGPR, zero, zero, ->zero; BSTOP
