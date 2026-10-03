<!-- GENERATED FROM: asl/tile/memory-and-data-movement/pe-movement/GMOV.asl -->
# GMOV

**Normative ASL source:** `asl/tile/memory-and-data-movement/pe-movement/GMOV.asl`

Copies peer-resolved Local fragments within a Core4 collective.

## Normative identity {#PTO-INST-TILE-GMOV}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-gmov-purpose role=purpose -->
## GMOV 的作用

`GMOV` 把 Core4 PE 组内一个由对端选择的 Local 片段复制到新分配的 Local 目标中。它是 TLSU Function 13，写作 `BSTART.GMOV DataType`，并且没有独立 opcode。

每个 PE 提供自己的 `peer_tid`，即它想要的 Local 片段所属 PE 的编号，并接收该片段的字节。`PE_MASK` 决定哪些 PE 获得目标。本操作不记录内存效果：它从不转换地址、不做权限检查，也不发出 load、store、atomic 或 fence 事件。

<!-- PTO-READER-BLOCK: tile-gmov-mechanism role=mechanism -->
## 对端解析与就绪

分派器 `ExecuteBundleGMOVOperation` 从指令束标量绑定指定的 GPR 中为每个 PE 读取一个绝对 `peer_tid`。省略 `B.IOR` 时，每个 PE 的 `peer_tid` 为零；显式编码的零选择子读取零 GPR，它同样指向 PE 0，但属于不同的 schema 状态。

在 `BundleGMOVCore4SourceReady` 接受源快照之前不会开始任何目标写入。该帮助函数要求源内容已定义并且在四个 PE 中都已分配，因为它检查 `_TileAllocationMasks[[source]] == '1111'`。每个 PE 还会检查自己的 `peer_tid` 是否在 `0..3` 范围内。

随后模型 `GMOV` 复制源 payload、已定义元素、已定义打包元素、已定义有效元素计数以及 `contents_defined` 标志，因此字节与已定义性一起传递。

设计要点：就绪是整个 Core4 组的属性。只要有一个 PE 的 Local 片段未分配或未完全定义，整个会合就会被阻塞，因此部分 `PE_MASK` 无法读取另一个 PE 尚未产生的片段。

<!-- PTO-READER-BLOCK: tile-gmov-inputs role=inputs-outputs -->
## 操作数角色与绑定

- `destination0` 是选中的 Local 目标片段。指令束在其 `B.IOT` 下分配它，并采用源的有效行数、有效列数、物理列数与数据类型。
- `source0` 是 Core4 对端解析的 read-old Local 源快照。目标 `TSize` 必须等于该源的每 PE 容量。
- `scalar0` 是每个 PE 的绝对 `peer_tid`。

恰好一条终止 `B.IOT` 同时携带源与目标，且 `L=1`。指令束不接受第二个 Tile 源，也不接受 `B.IOS`，Shared 绑定会被拒绝。

设计要点：`GMOV` 没有独立的形状操作数。每个解析后的 `B.DIM` 值必须等于 `1`，目标描述符由源描述符得到，因此复制不能重塑 payload。

<!-- PTO-READER-BLOCK: tile-gmov-effects role=effects -->
## 改变的内容

成功时，每个被选中 PE 新分配的目标保存已解析源片段的保字节副本，具有相同的已定义元素与相同的 `contents_defined` 标志。未被选中的目标以及所有 Shared 与 GM 状态保持不变。

设计要点：已定义性是被复制而不是被重新计算，因此后续消费者继承源片段的已定义性边界，而不必重新推导它。

<!-- PTO-READER-BLOCK: tile-gmov-constraints role=constraints -->
## 类型、布局与故障

`InstructionContractDataTypeLegal_GMOV` 恰好接受 `TileCarrierOrPackedBaselineDataTypeSupported` 允许的类型：所有最高 64 位的非打包载体，加上打包四位基线。64 位源在 `RowMajor` 中仍合法；在 CUBE 布局中则要求 `CUBE_M32` double-CELL 存储。

源与目标必须在数据类型、布局、存储种类、行数、列数、有效行数与有效列数上一致（`TileOperandsLegal_GMOV`）。布局必须是 `RowMajor`、`CUBE_M16` 或 `CUBE_M32`；`CUBE_N8` 与 Shared 操作数非法。 64 位 CUBE 操作数要求 `CUBE_M32` double-CELL 映射；`CUBE_M16` 会拒绝。

任一 PE 的 `peer_tid` 超出 `0..3`、Core4 源未就绪、`B.DIM` 值不为 `1`、`TSize` 不匹配、绑定多余或未终止，或出现 `B.IOS`，都会在复制之前引发 `Fault_TileLegality`；集体预检失败时不分配也不写入任何目标。

`PE_MASK` 可以是任意非零值，部分掩码只选择这些 PE 的目标。零掩码不选择任何 PE。与 atom/red、gather 和 scatter 分派器不同，`ExecuteBundleGMOVOperation` 没有零掩码提前返回，因此就绪、`peer_tid` 范围、类型、布局与维度检查仍会执行，也仍可能引发故障。

设计要点：`peer_tid` 范围检查对每个 PE 都执行，包括 `PE_MASK` 未选中的 PE，因为对端身份在目标存在之前作为一次集体步骤被校验。

<!-- PTO-READER-BLOCK: tile-gmov-example role=example -->
## 非规范演算示例

本示例说明当前 ASL owner，并不取代规范操作。

取 `U8`，源 `T#1` 的每 PE 容量为 1 KB 且其 payload 已完全定义，`PE_MASK` 指定 PE 0 与 PE 1，并且每个 PE 的 `peer_tid` 都为 1。

- 预检：`T#1` 必须在四个 PE 中都已分配且完全定义，并且 `a2` 中的 `peer_tid` 在每个 PE 中必须在 `0..3` 内。
- 每个解析后的 `B.DIM` 值必须为 `1`，并且目标 `TSize` 必须等于 `T#1` 的 1 KB 每 PE 容量。
- 规范宏写法是 `GMOV <U8, PE0_1>, T#1, a2, ->T<1KB>`。PE 0 与 PE 1 各获得一个新的目标，其字节与已定义性是已解析 PE 1 片段的副本；PE 2 与 PE 3 保持不变。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
GMOV <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| GMOV | TLSU |  | 13 |  | GMOV |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | selected Local destination fragments |
| source0 | Core4 peer-resolved read-old Local source snapshot |
| scalar0 | each PE's absolute peer_tid |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/pe-movement/GMOV.asl -->
```asl
readonly func InstructionContractOperation_GMOV() => TileOperation
begin
    return TileOperation_GMOV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.GMOV DataType
B.DATR Layout (optional)
B.IOT source, destination, PE_MASK, TSize, L=1
B.IOR peer_tid (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/pe-movement/GMOV.asl -->
```asl
pure func InstructionContractDataTypeLegal_GMOV(
    data_type: TileDataType) => boolean
begin
    return TileCarrierOrPackedBaselineDataTypeSupported(data_type);
end;

readonly func InstructionContractHandler_GMOV() => TileSemanticHandler
begin
    return TileHandler_GMOV;
end;

pure func InstructionContractRequiresCoreFourReadiness_GMOV()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractPartialMaskWritesSelectedPEs_GMOV()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Omitted B.DATR selects NORM.
- Omitted B.IOR supplies peer_tid zero in each PE; an explicit zero selector reads the zero GPR and is not absence.

## Legality

- GMOV is TLSU Function 13 and has no standalone opcode.
- Exactly one terminating Local source-plus-destination B.IOT is required. Its destination TSize equals the source per-PE capacity.
- Any nonzero PE_MASK is legal; it selects destination writes but not rendezvous or source readiness. Mask zero is a strict no-op.
- All four peer-resolved source fragments are ready before any selected request; each private peer_tid is 0..3 and may repeat. Local RowMajor, CUBE_M16, and CUBE_M32 forms preserve one selected layout; CUBE_N8 and Shared are illegal.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- Copies the byte-preserving resolved source fragment into each selected PE's newly allocated Local destination and copies definedness.
- Unselected destinations and all Shared/GM state remain unchanged.

## Memory effects and ordering

### Memory effects

- none; GMOV neither accesses global memory nor emits load, store, atomic, or fence events

### Ordering

- Combined Core4 rendezvous, descriptor, readiness, and peer validation precedes destination allocation and payload publication.
- The source payload and definedness are snapshotted before any destination write.

## Exceptions

- Reject incompatible source/destination capacity, shape, type, or layout, incomplete Core4 source readiness, peer_tid outside 0..3 in any PE, nonterminating or surplus bindings, any resolved B.DIM value other than one, or B.IOS before effects.
- A failed collective preflight allocates and writes no destination.

## Examples

- BSTART.GMOV U8; B.IOT T#1, mask=0101, size=1, ->T; B.IOR zero, a0; BSTOP
