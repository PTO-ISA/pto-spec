<!-- GENERATED FROM: asl/block/execution/BSTART.TMATMUL.BIAS.asl -->
# BSTART.TMATMUL.BIAS

**Normative ASL source:** `asl/block/execution/BSTART.TMATMUL.BIAS.asl`

Starts CUBE Function 1 for the TMATMUL_BIAS Matrix-matrix complete-bundle operation.

## Normative identity {#PTO-INST-BLOCK-BSTART-TMATMUL-BIAS}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-tmatmul-bias-purpose role=purpose -->
## BSTART.TMATMUL.BIAS 的作用

`BSTART.TMATMUL.BIAS` 打开一个指令束，其操作是 CUBE 矩阵乘 `TMATMUL_BIAS`。它是 32 位独立起始命令。其固定位选择 CUBE Function 1 与 `TileOperation_TMATMUL_BIAS`，唯一的编码字段是位 31:27 中的 5 位 `DataType`。该字段成为 AType，即左操作数 A 的元素类型。

结果 D 等于 A（M x K）与 B（K x N）的乘积再加上一行 1 x N 的 Bias；Bias 按输出列广播到每一个输出行。

设计要点：操作身份完全由起始命令确定。随后的命令（`B.DATR`、`B.FPATR`、`B.DIM`、`B.IOS`、`B.IOT` 与 `B.IOR`）只提供类型、形状与操作数。全部 12 个 CUBE 矩阵起始命令都通过同一个处理程序 `ExecuteBundleTMATMULOperation` 提交，该处理程序仅凭 function 编码区分 bias、累加、MX 与 GEMV 变体。

<!-- PTO-READER-BLOCK: block-bstart-tmatmul-bias-mechanism role=mechanism -->
## 放置与执行机制

起始时，`BSTART.TMATMUL.BIAS` 构建一个 Tile 矩阵描述符，其选择器为 1，数据类型为编码的 `DataType`。`DataType` 编码 15、21 到 23 或 29 到 31 不在接受集合内，会被编码检查以 `Fault_IllegalInstruction` 拒绝。所有起始检查都在提交任何活动的前序指令束之前运行，因此被拒绝的起始命令会保留前序指令束。参见[指令束起始分派](../model/dispatch/start.md)。

随后的 header 命令只记录指令束状态。在指令束于 `BSTOP` 或下一条 `BSTART` 处提交之前，不读取任何操作数，也不分配任何 Tile。

提交时，[提交验证](../model/commit/validation.md)运行 Tile 操作，[Tile 执行](../model/dispatch/tile-execution.md)把它路由到 [CUBE TMATMUL 分派](../model/dispatch/cube-tmatmul.md)。`ExecuteBundleTMATMULOperation` 随后按以下顺序工作：

1. 如果每个 Tile 与 Shared 绑定都不选择任何 PE，它直接返回，不产生任何效果。
2. 缺少 `B.FPATR` 会引发 `Fault_BundleControl`。
3. 类型、绑定数量、`B.DATR` 字段、`CCTRL`、维度与 PE 掩码一起检查。任一失败都会引发 `Fault_TileLegality`。
4. 它在不引发故障的情况下等待，直到每个 Shared 源都已发布，然后检查 Shared schema。
5. 它检查 Local 源、结果布局以及后处理源。
6. 它分配目标组、对操作数做快照并计算结果。分配之后发生的故障会回滚这些目标。

设计要点：分配是预检的最后一步。在预留第一个目标之前，所有字段、命令流、描述符、形状与容量规则都已检查完毕，因此被合法性检查拒绝的指令束不会留下已分配的目标，也不会改变任何源。

设计要点：提交失败时，处理在指令束停止之前返回。指令束保持活动、header 保持不变，其后续地址也不会生效，因此陷阱上下文仍描述这个失败的指令束。

<!-- PTO-READER-BLOCK: block-bstart-tmatmul-bias-inputs role=inputs-outputs -->
## 载体、绑定与输入

- 起始命令中的 `DataType` 是 AType。可选的 `B.DATR` 在其 `DataType` 字段中提供 BType；省略 `B.DATR` 时，BType 等于 AType，舍入为 RNE，饱和关闭。AType 与 BType 必须是同一类别的普通矩阵输入类型：都为浮点、都为有符号或都为无符号。
- `B.DATR` 可以设置 BType、`RMode`、`Sat` 以及通过其 `PadValueOrByteId` 字段传递的 `CCTRL`。其 `Layout` 与 `CMode` 必须为零，`Canonicalize` 必须关闭。
- 必须恰好有一条 `B.FPATR`。全零字段表示不做转换、激活或归约；非零字段会增加其所启用的 RowMax、GroupMax、量化或 ReLU 操作数。
- `B.DIM` 的 `LB0`、`LB1` 与 `LB2` 给出 M、N 与 K，省略时各自默认为 1。在协作式指令束中，`LB0` 是整个 Core 的 group_M。
- `B.IOT` 按以下顺序绑定 Local 数学源：A，然后是 B，最后是 Bias。后处理源排在它们之后。
- 目标绑定依次为 D，以及 `B.FPATR` 启用时的 RowMaxOut 与 GroupMaxOut。
- 可选的 `B.IOS` 从 Shared Tile 提供右侧组（B）或两侧矩阵组。补充源与所有目标仍为 Local。

Local A 使用 `CUBE_M16`（M 不超过 16）或 `CUBE_M32`（M 不超过 32），Local B 使用 `CUBE_N8`。Bias 是一个 Local `CUBE_N8` Tile，有 1 行、N 列结果类型的元素。

D 的元素类型随 AType 而定：有符号输入为 `S32`，无符号输入为 `U32`，浮点输入为 `FP32`。非零的 `PreQuantMode` 会为 D 选择该模式指定的输出类型。

设计要点：Bias 按结果类型而不是 AType 检查。类型、布局或形状不符的 Bias Tile 会在分配之前以 `Fault_TileLegality` 被拒绝，因此程序必须以结果类型保存 Bias。

<!-- PTO-READER-BLOCK: block-bstart-tmatmul-bias-effects role=effects -->
## 状态效果与顺序

起始命令只改变指令束状态。它记录一个类型为 `TileMatrix` 的顺序执行 `BARG`，并安装描述符；Tile、Shared Tile 与内存都不改变。

成功时，D 以及每个已启用的 RowMaxOut 与 GroupMaxOut 作为一个原子组发布。被拒绝的指令束不发布其中任何一个。任何源都不会被消耗或修改，成功的读取也不会改变任何 Shared 源的描述符、发布状态与载荷。

D 按 A 的 M 布局分配。当 A 本身为 Shared 时，每个 PE 不超过 16 行时布局为 `CUBE_M16`，不超过 32 行时为 `CUBE_M32`。

`CCTRL` 从 `B.DATR` 读取，缺少 `B.DATR` 时为 `00`。位 0 使 D 以原始累加器类型结果发布，并禁止量化、ReLU 以及 RowMax、GroupMax 与 max-abs 归约。位 1 必须为零，因为此形式没有 C 源。

设计要点：省略 `B.DATR` 与编码填充值 `11` 不同。缺少 `B.DATR` 时 `BundleTMATMULCCTRL` 返回 `00`，因此没有 `B.DATR` 的指令束不会意外请求原始输出。参见[累加器路由](../model/dispatch/cube-accumulator-routing.md)。

设计要点：缓存提示调用的是实现定义的钩子，在可移植模型中不做任何事。它们不能改变结果、故障、分配或发布；只有位 0 选择的输出类型是可观察的。

该指令束没有全局内存效果。

<!-- PTO-READER-BLOCK: block-bstart-tmatmul-bias-constraints role=constraints -->
## 合法性、故障与原子性

带有任何 Shared 源的指令束是协作式的。此时每个绑定都必须使用 `PE_MASK` 1111，group_M 必须在 1 到 128 之间，N 与 K 必须是 2 的幂。group_M 不超过 64 时每个 PE 拥有 16 行，否则拥有 32 行。起始行位于 group_M 或其之后的 PE 会消耗其 Shared 绑定并在没有 Local 效果的情况下结束。参见 [Shared CUBE 矩阵](../model/dispatch/shared-cube-matrix.md)。

只有当对应的主操作数为 Shared 时，`TransA` 与 `TransB` 才合法。尚未发布的 Shared 源会使提交在不引发故障的情况下返回，指令束保持活动。

`CScaleEn` 必须为零，因为只有 CUBE Function 2 与 6 接受 CScale。

所有绑定的 `PE_MASK` 均为 0000 时是严格无操作：矩阵处理程序不读取任何描述符，也不引发任何故障。

不在接受集合内的 `DataType` 在起始时引发 `Fault_IllegalInstruction`。缺少 `B.FPATR` 会引发 `Fault_BundleControl`。类型、数量、形状、布局、别名或后处理检查失败会引发 `Fault_TileLegality`，目标手已满或容量不足会引发 `Fault_TileAllocation`。这些故障都发生在任何目标发布之前。

<!-- PTO-READER-BLOCK: block-bstart-tmatmul-bias-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

下面的规范宏计算一个 16 x 32 的结果，K 等于 64。A 是 `T#3`，即一个 16 x 64、位于 `CUBE_M16` 的 `FP16` Tile；B 是 `T#2`，即一个 64 x 32、位于 `CUBE_N8` 的 `FP16` Tile；Bias 是 `T#1`，即一个 1 x 32、位于 `CUBE_N8` 的 `FP32` Tile。

```text
TMATMUL_BIAS <M=16, N=32, K=64, FP16>, T#3, T#2, T#1, ->T<2KB>
```

下面是该宏对应的一个物理指令束。全零的 `B.FPATR` 仍然是必需的。

```asm
BSTART.TMATMUL.BIAS FP16
B.FPATR None, None, 0, 0, 0, 0, 0, 0, 0, 0
B.DIM zero, 16, ->LB0
B.DIM zero, 32, ->LB1
B.DIM zero, 64, ->LB2
B.IOT T#3, T#2, mask=1111
B.IOT T#1, mask=1111, last, ->T<5>
BSTOP
```

没有 `B.DATR` 时 BType 也是 `FP16`，因此结果类型为 `FP32`。每个被选中的 PE 由 64 项乘积之和算出 16 x 32 = 512 个元素，每个输出行都加上同样的 32 个 Bias 值。D 是一个位于 `CUBE_M16` 的新 `FP32` Tile，占用 16 个 128 字节的单元，即 2KB，与 SizeCode 5 相符。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TMATMUL.BIAS DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tmatmul_bias_32_4d5a498d12f3 | L32 | 32 | 0x00131181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tmatmul_bias_32_4d5a498d12f3 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_tmatmul_bias_32_4d5a498d12f3 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | tile element data type selector | Encoded zero selects FP64. |

- `bstart_tmatmul_bias_32_4d5a498d12f3.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | tile element data type selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TMATMUL.BIAS.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TMATMUL_BIAS(
    operation: CommandOperation) => boolean
begin
    return operation ==
        CommandOperation_bstart_tmatmul_bias_32_4d5a498d12f3;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TMATMUL.BIAS AType
B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType)
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one)
B.DIM LB0 M or cooperative group_M (optional, default 1)
B.DIM LB1 N (optional, default 1)
B.DIM LB2 K (optional, default 1)
B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111)
B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, B CUBE_N8 primary, CUBE_N8 1xN Bias
B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations
B.IOT/B.IOR postprocess operands selected by B.FPATR
BSTOP or the next BSTART completion boundary
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TMATMUL.BIAS.asl -->
```asl
readonly func InstructionContractTileOperation_BSTART_TMATMUL_BIAS()
    => TileOperation
begin
    return TileOperation_TMATMUL_BIAS;
end;

readonly func InstructionContractCubeFunction_BSTART_TMATMUL_BIAS()
    => integer {0..31}
begin
    return 1;
end;

readonly func InstructionContractSharedOperandsAllowed_BSTART_TMATMUL_BIAS()
    => boolean
begin
    return TRUE;
end;

readonly func InstructionContractHandler_BSTART_TMATMUL_BIAS()
    => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.
- Omitted LB0 defaults Local M or cooperative group_M to one; omitted LB1 and LB2 default N and K to one.
- Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize. Bias uses Local CUBE_N8; it is a logical 1xN accumulator-type source (FP32 for MX) broadcast by logical output column.
- TransA=0 and TransB=0 select no logical transpose. Each nonzero control is legal only when the corresponding primary is Shared.
- Omitted CCTRL selects 00: final D output and no transparent-cache hint.

## Legality

- The carrier selects exactly CUBE Function 1 and TileOperation_TMATMUL_BIAS.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize. Bias uses Local CUBE_N8; it is a logical 1xN accumulator-type source (FP32 for MX) broadcast by logical output column.
- A Shared primary must satisfy hardware-maintained whole-parent readiness and publication before payload access; fixed-quarter allocation or initialization masks are not a prerequisite. Any cooperative Local-A/Shared-B or Shared-A/Shared-B TMATMUL interprets LB0 as Core-total group_M in 1..128; Shared A has exact physical valid shape [group_M,K] with physical index m*pitch+k (K-major) for TransA=0 or [K,group_M] with physical index k*pitch+m (M-major) for TransA=1; Shared B has exact physical valid shape [N,K] with physical index n*pitch+k (K-major, ordinary dense column-major/DN-equivalent) for TransB=0 or [K,N] with physical index k*pitch+n (N-major, ordinary dense row-major) for TransB=1; physical columns may be legally padded, and PE i uses valid_M=clamp(group_M-i*M_per_PE,0,M_per_PE) with M_per_PE 16 for group_M<=64 and 32 for group_M>=65. TransA and TransB apply only to their corresponding Shared primary. Right-only Shared inherits Local A layout; all-Shared ACC inherits C layout; all-Shared non-ACC selects M16 through M=16 and M32 through M=32.
- AType and BType must be supported ordinary Matrix types from one numeric class. Bias uses one Local CUBE_N8 logical 1xN accumulator-type source (FP32 for MX), broadcast by logical output column. Published Shared operands may replace the right group or both matrix groups; supplementary operands and destinations remain Local.
- Every cooperative nonzero PE_MASK must be 1111; all four PEs complete Shared readiness, while zero-row PEs suppress every compute-only Local resolution and effect. Mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.
- B.DATR permits BType, matrix CCTRL via PadValueOrByteId, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.
- For init=1 forms CCTRL[1] must be zero. CCTRL[0]=1 selects raw accumulator-type D and forbids final-output post-processing and auxiliary outputs except legal CScale; CCTRL[1] is an ACC-only non-binding explicit-C cache-use or prefetch hint. Every successful form allocates and publishes D.

## State effects

- Start a CUBE Function 1 descriptor with encoded DataType preserved as AType.
- At block completion execute TileOperation_TMATMUL_BIAS using the resolved M, N, K, input types, mathematical operands, and B.FPATR postprocess schema.
- Publish the complete output group atomically after successful preflight and computation; do not consume mathematical or postprocess sources.
- For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; Bias uses Local CUBE_N8; RowMaxIn/Out and GroupMaxOut use the resolved M layout; vector quant/PReLU parameters use Local CUBE_N8/U64; MX scales keep their operation-owned layouts.
- Successful Shared primary reads leave every Shared descriptor, mask, publication state, payload, and lifetime unchanged.
- Always publish D; CCTRL[0]=1 publishes raw accumulator-type D and may hint cache replacement, while ACC CCTRL[1]=1 may hint cache use or prefetch of explicit C. Hint handling is not architecturally observable.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, field, type, dimension, descriptor, shape, capacity, readiness, alias, and allocation preflight precedes every source snapshot and destination effect.
- D and every enabled reduction output publish as one atomic group; rejection publishes none and successful sources persist.
- Transparent-cache hints occur only after complete preflight and cannot alter source snapshots, D allocation or publication, faults, or numeric status.

## Exceptions

- A reserved DataType or fixed-bit mismatch raises Fault_IllegalInstruction before block state changes.
- Missing, duplicate, or non-Matrix B.FPATR use raises Fault_BundleControl before allocation or payload effects.
- Illegal types, dimensions, masks, binding streams, descriptors, shapes, capacities, aliases, readiness, or postprocess values raise Fault_TileLegality before source snapshots and effects.

## Examples

- BSTART.TMATMUL.BIAS AType; B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one); B.DIM LB0 M or cooperative group_M (optional, default 1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111); B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, B CUBE_N8 primary, CUBE_N8 1xN Bias; B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary
