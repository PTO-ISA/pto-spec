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

`GMOV` 是一条由 `TLSU` 执行、通过选择器编码的 Tile 操作。它为每个 PE 解析一个由对等标识选择的旧 Local 片段，并逐字节复制到被选中的新 Local 片段；当前指令契约拥有精确的指令束形式和发布边界。

<!-- PTO-READER-BLOCK: tile-gmov-mechanism role=mechanism -->
## 元素与 Tile 机制

所有描述符与操作数检查成功后，所属 ASL 处理函数为每个 PE 解析一个由对等标识选择的旧 Local 片段，并逐字节复制到被选中的新 Local 片段。当前契约允许别名时，源载荷会在目标写入前完成快照。

处理函数使用解析后的有效区域，不把物理填充区当作输入数据。操作专属的数据类型、布局、舍入、饱和与配置档钩子仍由可执行定义拥有。

<!-- PTO-READER-BLOCK: tile-gmov-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `destination0` 的精确契约角色是“被选中的 Local 目标片段”。
- `source0` 的精确契约角色是“Core4 对等解析的旧 Local 源快照”。
- `scalar0` 的精确契约角色是“每个 PE 的绝对 peer_tid”。

`PE_MASK=0000` 是严格无操作，在描述符、分配、载荷、数值状态或内存效果之前即结束。

<!-- PTO-READER-BLOCK: tile-gmov-effects role=effects -->
## 发布、已定义性与填充

只有完整预检后才发布目标可见状态；契约规定原子发布时，载荷、描述符、已定义性、填充和状态同时可见。

本页不暗示当前处理函数契约之外的填充行为。

该协同操作只改变被选中的 Local 目标片段；Shared 与 GM 状态保持不变。

<!-- PTO-READER-BLOCK: tile-gmov-constraints role=constraints -->
## 类型、布局与故障边界

精确的可接受类型或类型组合由下方生成的合法性章节拥有；本指南不会扩大该集合。

下方生成的合法性与异常章节是数据类型组合、布局、维度、容量、已定义性、填充控制、配置档行为和故障类别的权威说明。合法性或分配失败发生在任何部分架构效果之前。

<!-- PTO-READER-BLOCK: tile-gmov-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `GMOV` 示例说明：若 PE 1 解析得到 `peer_tid=0`，则被选中的目标片段接收 PE 0 的源字节及相同已定义性。
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
- All four peer-resolved source fragments are ready before any selected request; each private peer_tid is 0..3 and may repeat.

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

- Reject incompatible source/destination capacity, shape, type, layout, location, incomplete Core4 source readiness, peer_tid outside 0..3 in any PE, nonterminating or surplus bindings, B.DIM, or B.IOS before effects.
- A failed collective preflight allocates and writes no destination.

## Examples

- BSTART.GMOV U8; B.IOT T#1, mask=0101, size=1, ->T; B.IOR zero, a0; BSTOP
