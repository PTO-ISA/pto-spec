<!-- GENERATED FROM: asl/block/execution/BSTART.GMOV.asl -->
# BSTART.GMOV

**Normative ASL source:** `asl/block/execution/BSTART.GMOV.asl`

Collectively copies peer-PE Local fragments to selected Local destinations.

## Normative identity {#PTO-INST-BLOCK-BSTART-GMOV}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-gmov-purpose role=purpose -->
## BSTART.GMOV 的作用

`BSTART.GMOV` 打开一个 Tile-memory 类指令束，其操作为 `GMOV`：在一个 Core 的四个 PE 之间集体复制 Local 片段。每个 PE 用自己的 `peer_tid` 解析出一个源片段，每个被选中的 PE 发布一个目标，该目标逐字节接收该片段的载荷与已定义性。该命令不进行全局内存访问，也不产生 Shared 寄存器效果。

唯一的形式是 `BSTART.GMOV DataType`，一个 32 位字，在掩码 `0x07ffffff` 下匹配 `0x00d11181`，因此 `DataType` 位于第 31 至 27 位，固定的低位携带 TLSU 选择子 13，由 `BundleGMOVSelected` 匹配。该操作是 `TileOperation_GMOV`，且 `InstructionContractStartsTileBundle_BSTART_GMOV` 返回 TRUE。

设计要点：与同样发布 Local 目标的 `MGATHER` 不同，`GMOV` 没有索引 Tile，也没有基地址。它复制的源是经过 peer 解析的快照，因此目标采用源自身的有效形状、物理列数与容量，而不是 `B.DIM` 形状。

<!-- PTO-READER-BLOCK: block-bstart-gmov-mechanism role=mechanism -->
## 位置与机制

Tile 执行在 CAS、atom、gather 与 scatter 选择子之前测试 `BundleGMOVSelected`，因此选择子 13 总是到达 `ExecuteBundleGMOVOperation`。该 handler 要求恰好一个 Local 绑定，且带有目标、`source0`，没有 `source1`，并带有 `last`；Shared 绑定、不完整的绑定或非零的未使用 `B.IOR` 字段会引发 `Fault_TileLegality`。

随后该 handler 从 `B.IOR.RegSrc0` 指定的私有 GPR 中为四个 PE 分别读取 `peer_tid`，并要求每个值都小于 4。重复的 peer 标识是合法的，因此两个 PE 可以读取同一个片段。三个 `B.DIM` 通道都必须等于 1，因为目标形状来自源而不是来自维度。

设计要点：就绪性是一个集体见证。`BundleGMOVCore4SourceReady` 要求源内容已定义且其分配掩码为 `1111`，因此只有当四个 PE 都已分配该片段时复制才会执行。复制本身是对该快照的读旧值写新值，因此任何 PE 都无法观察到更新到一半的片段。

设计要点：与 gather、scatter 和 atom handler 不同，`ExecuteBundleGMOVOperation` 没有 `PE_MASK=0000` 提前退出。因此对每个到达该 handler 的编码，无论掩码的非零取值如何，其 schema、就绪性、peer 范围、维度、类型与容量检查都会执行。`PE_MASK=0000` 永远不会到达该 handler：零掩码下 `B.IOT` 不记录任何绑定，随后 `ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` 在 `asl/block/model/dispatch/tile-execution.asl:143` 处直接返回真。

<!-- PTO-READER-BLOCK: block-bstart-gmov-inputs role=inputs-outputs -->
## 操作数与 header 角色

- 第 31 至 27 位的 `DataType` 选择被复制片段的元素类型；约束接受编码 0 到 14、16 到 20 与 24 到 28，其他编码都是保留的。该 handler 还要求该类型满足 `TileCarrierOrPackedBaselineDataTypeSupported`，并且两个 Tile 都必须使用它。
- 一条终止 `B.IOT` 必须携带源片段与一个目标，且不得携带第二个源。其 `PE_MASK` 选择目标参与者，其 size 编码必须恰好描述源的字节容量。
- `B.IOR` 是可选的。存在时，`RegSrc0` 选择保存该 PE `peer_tid` 的 GPR，且 `RegSrc1`、`RegSrc2` 与 `RegDst` 必须编码为零。省略 `B.IOR` 时，四个 PE 中的 `peer_tid` 都为零。
- `B.DATR` 选择布局。源必须已经使用该布局，目标也按该布局解析。

<!-- PTO-READER-BLOCK: block-bstart-gmov-effects role=effects -->
## 待处理状态与完成

对被掩码选中的每个 PE，该指令束分配一个具有源形状的 Local 目标，并把经 peer 解析的载荷、已定义性与物理区域复制进去。掩码之外的 PE 仍参与 peer 选择、会合与就绪性预检，但不请求、不分配、不写入也不完成任何目标。Shared 状态不变。

该复制不发布任何内存事件，因为它从不访问全局内存。分配之后的失败会调用 `RollBackBundleTileDestinations`，因此被拒绝的尝试不会暴露部分目标。

<!-- PTO-READER-BLOCK: block-bstart-gmov-constraints role=constraints -->
## 合法性与故障边界

- 未知的 TLSU 编码引发 `Fault_IllegalInstruction`；Shared 绑定、畸形绑定、非法 `B.IOR` 取值、非 1 的维度通道、未定义或未完全分配的源、类型或布局不匹配，或目标 size 不等于源容量，都会在复制之前引发 `Fault_TileLegality`。
- 任一 PE 中的 `peer_tid` 大于或等于 4，会在分配之前、任何请求之前引发 `Fault_TileLegality`。
- 若不存在空闲的 Local 目标，解析会引发 `Fault_TileAllocation`。
- 任何非零 `PE_MASK` 都是合法的，并且只控制目标的请求、分配、写入与完成参与。

<!-- PTO-READER-BLOCK: block-bstart-gmov-example role=example -->
## 非规范示例

该演算示例是非规范的；它说明当前 owner，而不替代它。

```asm
BSTART.GMOV U8
B.IOT T#1, mask=0011, size=1, ->T
B.IOR a1, zero, zero, ->zero
BSTOP
```

`T#1` 是经 peer 解析的源片段，`mask=0011` 为四个 PE 中的两个选择目标，`a1` 保存 `peer_tid`。若每个 PE 中的 `a1` 都保存 1，则四个 PE 就 PE 1 发布的片段进行会合，每个被选中的 PE 都发布它的副本；某个 PE 的 `a1` 若保存 2，则解析 PE 2 的片段。两个未选中的 PE 仍要为自己的解析证明就绪性，但不发布任何东西。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.GMOV DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_gmov_32_6c21e223eaa7 | L32 | 32 | 0x00d11181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_gmov_32_6c21e223eaa7 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Field value dispositions

### DataType (`PTO-FIELD-BLOCK-DATATYPE`)

Selects the Tile element data type carried by Block data attributes and typed Block starts.

**Encoded zero:** Code zero selects FP64; zero never means absent, inherited, NONE, or NULL.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | FP64 |
| 1 | assigned | FP32 |
| 2 | assigned | TF32 |
| 3 | assigned | HF32 |
| 4 | assigned | FP16 |
| 5 | assigned | BF16 |
| 6 | assigned | HiF8 |
| 7 | assigned | E4M3 |
| 8 | assigned | E5M2 |
| 9 | assigned | E3M2 |
| 10 | assigned | E2M3 |
| 11 | assigned | E2M1X2 |
| 12 | assigned | E1M2X2 |
| 13 | assigned | E8M0 |
| 14 | assigned | HiF4X2 |
| 15 | assigned | E6M2 |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | assigned | RCPE6M2 |
| 22 | reserved | future extension |
| 23 | reserved | future extension |
| 24 | assigned | U64 |
| 25 | assigned | U32 |
| 26 | assigned | U16 |
| 27 | assigned | U8 |
| 28 | assigned | U4X2 |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Reserved values are held for future extension and reject before architectural effects.

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_gmov_32_6c21e223eaa7 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | byte-preserved Local fragment element type | Encoded zero selects FP64. |

- `bstart_gmov_32_6c21e223eaa7.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | byte-preserved Local fragment element type |
| B.IOT source | Core4 peer-resolved Local source snapshot |
| B.IOT destination | renamed Local destination and per-PE TSize |
| B.IOT PE_MASK | selected destination request/write participants |
| B.IOR.RegSrc0 | each PE's private-GPR absolute peer_tid |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.GMOV.asl -->
```asl
readonly func InstructionContractMatches_BSTART_GMOV(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_gmov_32_6c21e223eaa7);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.GMOV DataType; optional B.DATR Layout; one terminating B.IOT with one Local source and one Local destination; optional B.IOR peer_tid; BSTOP
B.IOS and B.DIM are not members of a GMOV schema.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.GMOV.asl -->
```asl
readonly func InstructionContractHandler_BSTART_GMOV() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_GMOV()
    => TileOperation
begin
    return TileOperation_GMOV;
end;

pure func InstructionContractStartsTileBundle_BSTART_GMOV()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is explicit; omitted B.DATR selects NORM.
- Omitted B.IOR supplies peer_tid zero independently in all four PEs. An explicit zero selector reads the architectural zero GPR and supplies the same value without invoking an omission default.

## Legality

- bstart_gmov_32_6c21e223eaa7.DataType accepts only 0..14, 16..20, 24..28; all other encodings are reserved.
- All four PEs rendezvous and all four peer-resolved source fragments must be allocated and ready, independent of PE_MASK.
- Any nonzero PE_MASK is legal and controls only destination request/allocation/write participation; PE_MASK=0000 is a strict no-op before source access or faults.
- Each PE's absolute peer_tid is 0..3; repeated peer identifiers are legal.

## State effects

- For each selected PE, allocate a new Local destination fragment and copy the byte-preserving peer-resolved source payload and definedness.
- Unselected PEs participate in rendezvous and readiness preflight but do not request, allocate, write, or complete a destination. Shared state is unchanged.

## Memory effects and ordering

### Memory effects

- none; GMOV performs no GM access and emits no PTO memory event

### Ordering

- Snapshot every source fragment and validate all descriptors, readiness, peer selectors, and participant agreement before allocating or writing any selected destination.
- Read-old/write-new behavior preserves a source snapshot when architectural aliases resolve to the same prior value.

## Exceptions

- Reserved DataType, malformed bindings, any Shared binding or B.DIM, incompatible descriptors, non-ready Core4 source, or any PE peer_tid outside 0..3 raises an Illegal Block exception before requests, allocation, destination writes, or events.
- Core4 convergence and source readiness are one combined preflight; a failed attempt exposes no partial destination.

## Examples

- BSTART.GMOV U8; B.IOT T#1, mask=0011, size=1, ->T; B.IOR zero, a0; BSTOP
