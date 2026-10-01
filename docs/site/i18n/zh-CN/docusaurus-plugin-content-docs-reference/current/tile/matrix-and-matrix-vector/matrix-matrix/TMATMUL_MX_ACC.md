<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX_ACC.asl -->
# TMATMUL_MX_ACC

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX_ACC.asl`

Multiply scaled matrices and accumulate into the supplied accumulator Tile.

## Normative identity {#PTO-INST-TILE-TMATMUL-MX-ACC}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tmatmul-mx-acc-purpose role=purpose -->
## TMATMUL_MX_ACC 的作用

`TMATMUL_MX_ACC` 把 M 行 K 列的左矩阵 A 与 K 行 N 列的右矩阵 B 相乘，并把 M x N 的结果 D 发布到一个新分配的 Local CUBE Tile 中。

乘积会加到一个同形状的显式累加器 Tile C 上，而 C 本身保持不变。每个输入都可以使用窄位宽 MX 格式；这样的一侧带有一个按组划分的缩放 Tile。

设计要点：`TMATMUL_MX_ACC` 由 `BSTART.TMATMULMX.ACC`（CUBE Function 6）选中，没有独立 opcode。全部 12 条 CUBE 矩阵指令共用一个指令束处理程序；功能号决定是否使用偏置、累加器、MX 缩放以及 TGEMV 规则（M = 1 且只用 Local 操作数），并且还决定 CScale 是否合法（只有两种 ACC 形式接受）。[矩阵功能表](../../model/legality/matrix-functions.md)列出了所有形式。

<!-- PTO-READER-BLOCK: tile-tmatmul-mx-acc-mechanism role=mechanism -->
## 元素运算

对每个结果行和列，累加和从同一位置的 C 元素开始。设置 `CScaleEn` 时，该 C 值先按本行 U8 CScale 指数的步数逐次减半，并以 RNE 舍入为 FP32；NaN、无穷与零原样通过。随后内层下标按递增顺序从 0 走到 K-1，每一步加上一个乘积。

累加器类型始终为 FP32。当两侧都没有缩放，即两个输入都是 FP16 或 BF16，且当前累加和与两个元素都是有限值时，每一步先把乘积舍入为 FP32，再把累加和舍入为 FP32。这一路径始终使用无饱和的 RNE；`B.DATR` 的 `RMode` 与 `Sat` 字段不会改变它。

其他所有情况下，带缩放一侧的输入先用 `MultiplyWord` 与其缩放载体相乘，两者结果的乘积再以 64 位回绕算术加到原始累加器载体上。这是原始载体算术，而不是解码后的浮点计算，并且不记录任何标志。

设计要点：内层循环以固定顺序遍历 K，且 FP32 路径每一步舍入两次，因此结果不是融合乘加，模型对每组输入给出唯一的逐位精确结果。累加会丢弃标志；CScale 与后处理是仅有的记录数值状态标志的步骤。

随后恰好一条 `B.FPATR` 选择后处理。所有字段为零时，D 保持累加器类型。非零 `PreQuantMode` 把每个有效元素转换为该模式的输出类型，`ReluMode` 为负值选择 ReLU 或泄漏斜率，`RowMaxEn` 与 `GroupMaxEn` 增加由最终 D 值计算的 RowMaxOut 与 GroupMaxOut 目标。[矩阵后处理](../../model/execution/matrix-postprocess.md)与[后处理提交](../../model/execution/postprocess.md)给出精确规则。

`CCTRL` 是 `B.DATR` 的 `PadValueOrByteId` 字段；省略 `B.DATR` 时按 `00` 读取。位 0 置位时，D 以原始累加器类型结果发布，且 `PreQuantMode`、`ReluMode`、`GroupNCode`、`RowMaxEn`、`GroupMaxEn` 与 `MaxAbsEn` 都必须为零。位 1 请求实现预取或复用 C；它是非约束性提示，不能改变结果。

<!-- PTO-READER-BLOCK: tile-tmatmul-mx-acc-inputs-outputs role=inputs-outputs -->
## 操作数角色与布局

Local 数学源按以下顺序绑定：

- `source0` 是累加器 C：有效形状 [M, N]，累加器类型，且与 D 使用相同的 M 布局。除非 `PreQuantMode` 非零，其容量必须等于 D 的容量。助记符条款 `PTO-TMATMUL-MX-ACC-CONTRACT-001` 与分派条款 `PTO-CUBE-ACCUMULATOR-OUTPUT-001` 都要求其编码相对选择器在重命名前不同于 D 零扩展后的 `DstTile` 句柄；可执行检查与此不同，见下文。
- `source1` 是左矩阵 A：有效形状 [M, K]，类型 AType，布局 `CUBE_M16`（M 不超过 16）或 `CUBE_M32`（M 不超过 32）。
- `source2` 是 A 的缩放，仅在 AType 不是 FP16 或 BF16 时绑定：`CUBE_M32` 中的有效形状 [M, G]，其中 G 为 K 除以组大小后向上取整。载体为按 32 分组的 `E8M0`，HiF4X2 则为按 64 分组的 `U32`。
- `source3` 是右矩阵 B：有效形状 [K, N]，类型 BType，布局 `CUBE_N8`。
- `source4` 是 B 的缩放，仅在 BType 不是 FP16 或 BF16 时绑定：`CUBE_M32` 中的有效形状 [N, G]，载体规则相同。一个 `CUBE_M32` 块最多容纳 32 行，因此 Local B 缩放要求 N 不超过 32。
- 设置 `CScaleEn` 时，后面再跟一个源：有效形状为 [M, 1] 的 `U8` `CUBE_M32` Tile，每行保存一个指数。CScale 要求 FP32 累加器。

某一侧不需要缩放时，不绑定它的缩放源，后续源按相同顺序直接跟上。RowMaxIn 与参数 Tile 等后处理源排在所有这些源之后。

`destination0` 是 D：新分配，有效形状 [M, N]，解析得到的 M 布局（A 为 Local 时即 A 的布局），类型为累加器类型，或非零 `PreQuantMode` 的输出类型。

AType 是 `BSTART` 数据类型。BType 是 `B.DATR` 的 `DataType`，省略 `B.DATR` 时等于 AType。`B.DIM` 的 LB0、LB1 与 LB2 分别携带 M、N 与 K，省略时各自默认为 1。

AType 与 BType 各自独立地从 FP16、BF16、E4M3、E5M2、E2M1X2、E1M2X2 与 HiF4X2 中选择。

设计要点：某一侧恰好在需要时才带缩放。FP16 与 BF16 不需要缩放，因此左侧为 FP16、右侧为 E4M3 的形式只绑定右侧缩放，而两侧都为 FP16 的形式走上文所述的 FP32 舍入路径。

设计要点：助记符条款 `PTO-TMATMUL-MX-ACC-CONTRACT-001` 与分派条款 `PTO-CUBE-ACCUMULATOR-OUTPUT-001` 都要求 C 的编码相对选择器在重命名前不同于 D 零扩展后的 `DstTile` 句柄。当前可执行模型先解析 C，再把它的物理 `TileIndex` 与 D 的目标句柄（`DstTile MOD 4`）比较。Issue #367 跟踪此冲突。在写入 D 之前，C 被读入私有副本，并且无论成功还是被拒绝都保持不变；但累加链只有在解析后的 C 索引通过当前比较时才可执行。

协作执行：`B.IOS` 可以用已发布的 Shared Tile 替换完整的右组（B 及其所需的缩放），或替换两组。此时 LB0 表示整个 Core 的 group M，取值 1 到 128，N 与 K 必须是 2 的幂，且每个绑定都需要 `PE_MASK` 1111。group M 不超过 64 时每个 PE 负责 16 行，否则负责 32 行；PE i 从第 i 乘以该行数的行开始，没有行的 PE 不分配任何 Tile。[Shared CUBE 矩阵](../../../block/model/dispatch/shared-cube-matrix.md)定义了该划分。

Shared A 以 [group M, K] 存储，设置 `TransA` 时以 [K, group M] 存储。Shared B 以 [N, K] 存储，设置 `TransB` 时以 [K, N] 存储。每个转置控制只对 Shared 主操作数合法。C、CScale 以及所有目标保持 Local。

<!-- PTO-READER-BLOCK: tile-tmatmul-mx-acc-effects role=effects -->
## 发布与排序

首先进行完整预检：类型、绑定、维度、掩码、Shared 就绪与模式、Local 描述符、别名、M 布局以及后处理源。只有这之后才分配目标组并读取源。[CUBE TMATMUL 分派](../../../block/model/dispatch/cube-tmatmul.md)列出了各个阶段。

D 与任何已启用的 RowMaxOut 和 GroupMaxOut 作为一组发布。D 只在其有效区域内已定义；由于不应用任何 `PadValue`，其填充保持未定义。被拒绝的指令束不发布任何内容，所有源保持不变。

设计要点：分配发生在所有规则检查完成之后、第一次源快照之前。因此合法性故障不会留下已分配的目标，而分配之后发生的故障会回滚整个目标组。

该操作没有全局内存效果。CScale 在计算每个缩放后的 C 元素时记录其标志。后处理把所有输出的标志按位或，并在提交时记录。

协作指令束会在不产生故障的情况下等待，直到每个 Shared 源都整体就绪并已发布。成功的 Shared 读取不改变任何 Shared 描述符、载荷与生命周期。

<!-- PTO-READER-BLOCK: tile-tmatmul-mx-acc-constraints role=constraints -->
## 合法性与故障边界

- 所有绑定的 `PE_MASK=0000` 会跳过描述符、就绪、维度、分配与载荷工作；但命令级 size code 合法性检查仍会先执行：非法的 `B.IOT` size code 仍会引发 `Fault_IllegalInstruction`。
- 缺少 `B.FPATR` 会引发 `Fault_BundleControl`，无法解码的 CUBE 选择器会引发 `Fault_IllegalInstruction`。
- 非法的类型对、源或目标数量、`B.DATR` 字段、`CCTRL` 用法、维度、掩码、描述符、别名、布局或后处理源，会在分配之前引发 `Fault_TileLegality`。
- 目标句柄已满、目标组超出参与 PE 的剩余容量，或目标大小不足以容纳其 CUBE 形状时，引发 `Fault_TileAllocation`。
- 这里 `CScaleEn` 合法，因为只有两种 TMATMUL ACC 形式接受 CScale：Function 2（`TMATMUL_ACC`）与 Function 6（`TMATMUL_MX_ACC`）；`TGEMV_ACC` 拒绝它。它仍要求 FP32 累加器，且 CScale 源不得与任何目标句柄共用索引。

设计要点：M、N 与 K 与 A、B、D 的有效形状比较，而不是与由容量推导的行数比较。M 布局只把 M 限制在 16 或 32 以内，因此这些维度与目标 TSize 无关。

<!-- PTO-READER-BLOCK: tile-tmatmul-mx-acc-example role=example -->
## 非规范演算示例

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

两侧都为 FP16 时不绑定缩放，源依次为 C、A 与 B。取 M = 1，N = 1，K = 2，C = 10.0，左源行为 1.0、2.0，右源列为 3.0、4.0。D 为 10.0 + 3.0 + 8.0 = 21.0，即使 `B.DATR` 选择了其他 `RMode` 也按 RNE 计算。

两侧都为 HiF4X2 且 K = 128 时，每一侧都需要 G = 128 / 64 = 2 的 `U32` 缩放。此时源依次为 C、A、A 的缩放 [16, 2]、B 与 B 的缩放 [16, 2]。

下面两份非规范宏草图以队列解析把 C 映射到不同于目标句柄的物理 `TileIndex` 为条件；这正是当前可执行模型实际检查的条件：

```text
TMATMUL_MX_ACC <M=16, N=16, K=16, FP16>, T#1, T#2, T#3, ->T<1KB>
TMATMUL_MX_ACC <M=16, N=16, K=128, HiF4X2>, T#1, T#2, T#3, T#4, T#5, ->T<1KB>
```
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `matrix-and-matrix-vector`
- **Execution engine:** `CUBE`

## Assembly

```asm
TMATMUL_MX_ACC <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMATMUL_MX_ACC | CUBE |  | 6 |  | TMATMUL_MX_ACC |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | accumulator |
| source1 | left |
| source2 | row-scale |
| source3 | right |
| source4 | column-scale |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX_ACC.asl -->
```asl
readonly func InstructionContractOperation_TMATMUL_MX_ACC()
    => TileOperation
begin
    return TileOperation_TMATMUL_MX_ACC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TMATMULMX.ACC AType
B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType)
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one)
B.DIM LB0 M or cooperative group_M (optional, default 1)
B.DIM LB1 N (optional, default 1)
B.DIM LB2 K (optional, default 1)
B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111)
B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A with encoded selector distinct from DstTile, A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale, optional U8 CScale CUBE_M32 [M,1]
B.IOT D matching A's CUBE_M16/M32 layout with a distinct encoded destination index, optional RowMaxOut, optional GroupMaxOut destinations
B.IOT/B.IOR postprocess operands selected by B.FPATR
BSTOP or the next BSTART completion boundary
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX_ACC.asl -->
```asl
readonly func InstructionContractCubeFunction_TMATMUL_MX_ACC()
    => integer {0..31}
begin
    return 6;
end;

readonly func InstructionContractSharedOperandsAllowed_TMATMUL_MX_ACC()
    => boolean
begin
    return TRUE;
end;

readonly func InstructionContractOperandsLegal_TMATMUL_MX_ACC(
    destination: TileIndex,
    accumulator: TileIndex,
    left: TileIndex,
    row_scale: TileIndex,
    right: TileIndex,
    column_scale: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL_MX_ACC(
        destination,
        accumulator,
        left,
        row_scale,
        right,
        column_scale);
end;

readonly func InstructionContractHandler_TMATMUL_MX_ACC()
    => TileSemanticHandler
begin
    return TileHandler_TMATMUL_MX_ACC;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.
- Omitted LB0 defaults Local M or cooperative group_M to one; omitted LB1 and LB2 default N and K to one.
- Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize; when a Local Matrix-MX scale is required, its M/N major is at most 32 because Local scales use one-block CUBE_M32, while Shared scales remain ordinary Tiles. Each side uses group-32 E8M0 or HiF4X2 group-64 U32 scale; Local scales use CUBE_M32 and Shared scales remain ordinary Tiles.
- TransA=0 and TransB=0 select no logical transpose. Each nonzero control is legal only when the corresponding primary is Shared.
- C and D are both mandatory. CScaleEn accepts one final U8 CUBE_M32 [M,1] Local mathematical source only with FP32 C; omission defaults CScaleEn to zero. In decoded blocks C's six-bit relative selector must differ from zero-extended DstTile before rename; direct Tile calls require destination TileIndex to differ from accumulator TileIndex.
- Omitted CCTRL selects 00: final D output and no transparent-cache hint.

## Legality

- The carrier selects exactly CUBE Function 6 and TileOperation_TMATMUL_MX_ACC.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize; when a Local Matrix-MX scale is required, its M/N major is at most 32 because Local scales use one-block CUBE_M32, while Shared scales remain ordinary Tiles. Each side uses group-32 E8M0 or HiF4X2 group-64 U32 scale; Local scales use CUBE_M32 and Shared scales remain ordinary Tiles.
- C and D are both mandatory. CScaleEn accepts one final U8 CUBE_M32 [M,1] Local mathematical source only with FP32 C; omission defaults CScaleEn to zero. In decoded blocks C's six-bit relative selector must differ from zero-extended DstTile before rename; direct Tile calls require destination TileIndex to differ from accumulator TileIndex.
- A Shared primary must satisfy hardware-maintained whole-parent readiness and publication before payload access; fixed-quarter allocation or initialization masks are not a prerequisite. Any cooperative Local-A/Shared-B or Shared-A/Shared-B TMATMUL interprets LB0 as Core-total group_M in 1..128; Shared A has exact physical valid shape [group_M,K] with physical index m*pitch+k (K-major) for TransA=0 or [K,group_M] with physical index k*pitch+m (M-major) for TransA=1; Shared B has exact physical valid shape [N,K] with physical index n*pitch+k (K-major, ordinary dense column-major/DN-equivalent) for TransB=0 or [K,N] with physical index k*pitch+n (N-major, ordinary dense row-major) for TransB=1; physical columns may be legally padded, and PE i uses valid_M=clamp(group_M-i*M_per_PE,0,M_per_PE) with M_per_PE 16 for group_M<=64 and 32 for group_M>=65. TransA and TransB apply only to their corresponding Shared primary. Right-only Shared inherits Local A layout; all-Shared ACC inherits C layout; all-Shared non-ACC selects M16 through M=16 and M32 through M=32.
- Each non-FP16/BF16 side requires its assigned scale: group-32 E8M0 for MX FP8/FP4 or group-64 U32 for HiF4X2. C is one explicit Local MxN accumulator source and D is a distinct newly published destination; C's encoded relative selector and D's zero-extended DstTile hand must differ before rename. Published Shared operands may replace the right group or both matrix groups; supplementary operands and destinations remain Local.
- Every cooperative nonzero PE_MASK must be 1111; all four PEs complete Shared readiness, while zero-row PEs suppress every compute-only Local resolution and effect. Mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.
- B.DATR permits BType, matrix CCTRL via PadValueOrByteId, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.
- For init=1 forms CCTRL[1] must be zero. CCTRL[0]=1 selects raw accumulator-type D and forbids final-output post-processing and auxiliary outputs except legal CScale; CCTRL[1] is an ACC-only non-binding explicit-C cache-use or prefetch hint. Every successful form allocates and publishes D.

## State effects

- Multiply scaled matrices and accumulate into the supplied accumulator Tile.
- After complete preflight, execute TMATMUL_MX_ACC with the operand bindings listed above; destination definedness changes only as specified by that handler.
- For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; Bias uses Local CUBE_N8; RowMaxIn/Out and GroupMaxOut use the resolved M layout; vector quant/PReLU parameters use Local CUBE_N8/U64; MX scales keep their operation-owned layouts.
- Successful Shared primary reads leave every Shared descriptor, mask, publication state, payload, and lifetime unchanged.
- C is snapshotted before multiplication and remains descriptor-and-payload unchanged after success or rejection.
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

- BSTART.TMATMULMX.ACC AType; B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one); B.DIM LB0 M or cooperative group_M (optional, default 1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111); B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A with encoded selector distinct from DstTile, A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale; B.IOT D matching A's CUBE_M16/M32 layout with a distinct encoded destination index, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary
