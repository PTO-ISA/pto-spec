<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV.asl -->
# TGEMV

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV.asl`

Multiply the matrix by the vector into the destination.

## Normative identity {#PTO-INST-TILE-TGEMV}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tgemv-purpose role=purpose -->
## TGEMV 的作用

`TGEMV` 是 CUBE 矩阵乘的矩阵-向量形式。M 固定为 1，因此左操作数 A 是一行 K 个元素，右操作数 B 是 K 行 N 列的矩阵，目标 D 是一行 N 个元素。

设计要点：`TGEMV` 由 `BSTART.TGEMV`（CUBE Function 16）选中，没有独立 opcode。全部 12 条 CUBE 矩阵指令共用一个指令束处理程序；功能号决定是否使用偏置、累加器、MX 缩放、M = 1 与仅 Local 规则，以及是否允许 CScale。[矩阵功能表](../../model/legality/matrix-functions.md)列出了所有形式。

<!-- PTO-READER-BLOCK: tile-tgemv-mechanism role=mechanism -->
## 元素运算

对每个结果行和列，累加和从零开始。随后内层下标按递增顺序从 0 走到 K-1，每一步加上一个乘积。

浮点输入的累加器类型为 FP32，有符号整数输入为 S32，无符号整数输入为 U32。当累加器为 FP32、两个输入都是 FP32、TF32、HF32、FP16 或 BF16，且当前累加和与两个元素都是有限值时，每一步先把乘积舍入为 FP32，再把累加和舍入为 FP32。它使用 `B.DATR` 的 `RMode` 与 `Sat`；省略 `B.DATR` 时使用无饱和的 RNE。

其他所有情况下，包括整数输入、8 位与 4 位浮点输入以及 NaN 或无穷值，这一步以 64 位回绕算术把 `MultiplyWord(left, right)` 加到原始累加器载体上。该路径是精确的位运算而非 IEEE 算术，并且不记录任何标志。

设计要点：内层循环以固定顺序遍历 K，且 FP32 路径每一步舍入两次，因此结果不是融合乘加，模型对每组输入给出唯一的逐位精确结果。累加会丢弃标志；后处理是唯一记录数值状态标志的步骤。

随后恰好一条 `B.FPATR` 选择后处理。所有字段为零时，D 保持累加器类型。非零 `PreQuantMode` 把每个有效元素转换为该模式的输出类型，`ReluMode` 为负值选择 ReLU 或泄漏斜率，`RowMaxEn` 与 `GroupMaxEn` 增加由最终 D 值计算的 RowMaxOut 与 GroupMaxOut 目标。[矩阵后处理](../../model/execution/matrix-postprocess.md)与[后处理提交](../../model/execution/postprocess.md)给出精确规则。

`CCTRL` 是 `B.DATR` 的 `PadValueOrByteId` 字段；省略 `B.DATR` 时按 `00` 读取。位 0 置位时，D 以原始累加器类型结果发布，且 `PreQuantMode`、`ReluMode`、`GroupNCode`、`RowMaxEn`、`GroupMaxEn` 与 `MaxAbsEn` 都必须为零。位 1 必须为零，因为此形式没有可预取的 C。

<!-- PTO-READER-BLOCK: tile-tgemv-inputs-outputs role=inputs-outputs -->
## 操作数角色与布局

Local 数学源按以下顺序绑定：

- `source0` 是左向量 A：有效形状 [1, K]，类型 AType，布局 `CUBE_M16` 或 `CUBE_M32`。
- `source1` 是右矩阵 B：有效形状 [K, N]，类型 BType，布局 `CUBE_N8`。

RowMaxIn 与参数 Tile 等后处理源排在所有这些源之后。

`destination0` 是 D：新分配，有效形状 [1, N]，与 A 相同的 M 布局，类型为累加器类型，或非零 `PreQuantMode` 的输出类型。

AType 是 `BSTART` 数据类型。BType 是 `B.DATR` 的 `DataType`，省略 `B.DATR` 时等于 AType。`B.DIM` 的 LB0、LB1 与 LB2 分别携带 M、N 与 K，省略时各自默认为 1。M = 1 规则是强制的：任何其他 LB0 值都会引发 `Fault_TileLegality`。

AType 与 BType 必须都是同一数值类别的普通矩阵类型：同为浮点、同为有符号整数或同为无符号整数。HiF4X2 不是普通矩阵类型；只有 MX 形式接受它。

`TGEMV` 只使用 Local 操作数。任何 Shared 绑定以及非零 `TransA` 或 `TransB` 都会被拒绝，任何共同的非零 `PE_MASK` 都合法。

<!-- PTO-READER-BLOCK: tile-tgemv-effects role=effects -->
## 发布与排序

首先进行完整预检：类型、绑定、维度、掩码、Local 描述符、别名、M 布局以及后处理源。只有这之后才分配目标组并读取源。[CUBE TMATMUL 分派](../../../block/model/dispatch/cube-tmatmul.md)列出了各个阶段。

D 与任何已启用的 RowMaxOut 和 GroupMaxOut 作为一组发布。D 只在其有效区域内已定义；由于不应用任何 `PadValue`，其填充保持未定义。被拒绝的指令束不发布任何内容，所有源保持不变。

设计要点：分配发生在所有规则检查完成之后、第一次源快照之前。因此合法性故障不会留下已分配的目标，而分配之后发生的故障会回滚整个目标组。

该操作没有全局内存效果。后处理是数值状态的唯一来源；它把所有输出的标志按位或，并在提交时记录。

<!-- PTO-READER-BLOCK: tile-tgemv-constraints role=constraints -->
## 合法性与故障边界

- 所有绑定的 `PE_MASK=0000` 是严格无操作，发生在任何描述符读取、故障或分配之前。
- 缺少 `B.FPATR` 会引发 `Fault_BundleControl`，无法解码的 CUBE 选择器会引发 `Fault_IllegalInstruction`。
- 非法的类型对、源或目标数量、`B.DATR` 字段、`CCTRL` 用法、维度、掩码、描述符、别名、布局或后处理源，会在分配之前引发 `Fault_TileLegality`。
- 目标句柄已满、目标大小不足以容纳 D、RowMaxOut 或 GroupMaxOut 的 CUBE 存储，或目标组超出剩余容量时，引发 `Fault_TileAllocation`。
- 设置 `CScaleEn` 会引发 `Fault_TileLegality`，因为只有 `TMATMUL_ACC` 与 `TMATMUL_MX_ACC` 接受 CScale。

设计要点：M、N 与 K 与 A、B、D 的有效形状比较，而不是与由容量推导的行数比较。M 布局只把 M 限制在 16 或 32 以内，因此这些维度与目标 TSize 无关。

<!-- PTO-READER-BLOCK: tile-tgemv-example role=example -->
## 非规范演算示例

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

取 FP16 输入，N = 2，K = 2。左向量为 1.0、2.0。右源各行为 3.0、5.0 与 4.0、6.0。D 为一行：1.0 x 3.0 + 2.0 x 4.0 = 11.0 与 1.0 x 5.0 + 2.0 x 6.0 = 17.0。

以宏形式表示，会打印强制的 M = 1。N = 16 时，`CUBE_M16` 中的 D 仍占一个 16 行块，即 16 x 16 x 4 = 1024 字节，尽管只有第 0 行有效。

```text
TGEMV <M=1, N=16, K=16, FP16>, T#1, T#2, ->T<1KB>
```
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `matrix-and-matrix-vector`
- **Execution engine:** `CUBE`

## Assembly

```asm
TGEMV <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGEMV | CUBE |  | 16 |  | TGEMV |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | left-vector |
| source1 | right-matrix |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV.asl -->
```asl
readonly func InstructionContractOperation_TGEMV()
    => TileOperation
begin
    return TileOperation_TGEMV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TGEMV AType
B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType)
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one)
B.DIM LB0 M (optional, default 1; TGEMV permits only M=1)
B.DIM LB1 N (optional, default 1)
B.DIM LB2 K (optional, default 1)
B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, B CUBE_N8 primary
B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations
B.IOT/B.IOR postprocess operands selected by B.FPATR
BSTOP or the next BSTART completion boundary
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV.asl -->
```asl
readonly func InstructionContractCubeFunction_TGEMV()
    => integer {0..31}
begin
    return 16;
end;

readonly func InstructionContractSharedOperandsAllowed_TGEMV()
    => boolean
begin
    return FALSE;
end;

readonly func InstructionContractOperandsLegal_TGEMV(
    destination: TileIndex,
    left_vector: TileIndex,
    right_matrix: TileIndex) => boolean
begin
    return TileOperandsLegal_TGEMV(
        destination,
        left_vector,
        right_matrix);
end;

readonly func InstructionContractHandler_TGEMV()
    => TileSemanticHandler
begin
    return TileHandler_TGEMV;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.
- Omitted LB0, LB1, and LB2 default M, N, and K independently to one; TGEMV fixes M to one.
- Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize.
- TransA=0 and TransB=0 select no logical transpose. TGEMV requires both controls to remain zero.
- Omitted CCTRL selects 00: final D output and no transparent-cache hint.

## Legality

- The carrier selects exactly CUBE Function 16 and TileOperation_TGEMV.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize.
- TGEMV is Local-only: TransA and TransB are zero and every effective Shared binding rejects before effects.
- AType and BType must be supported ordinary Matrix types from one numeric class. M is fixed to one and every Shared binding is illegal.
- Every common nonzero four-bit PE_MASK is legal; all four PEs complete cooperative Shared readiness while only selected PEs allocate and publish. Mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.
- B.DATR permits BType, matrix CCTRL via PadValueOrByteId, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.
- For init=1 forms CCTRL[1] must be zero. CCTRL[0]=1 selects raw accumulator-type D and forbids final-output post-processing and auxiliary outputs except legal CScale; CCTRL[1] is an ACC-only non-binding explicit-C cache-use or prefetch hint. Every successful form allocates and publishes D.

## State effects

- Multiply the matrix by the vector into the destination.
- After complete preflight, execute TGEMV with the operand bindings listed above; destination definedness changes only as specified by that handler.
- For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; Bias uses Local CUBE_N8; RowMaxIn/Out and GroupMaxOut use the resolved M layout; vector quant/PReLU parameters use Local CUBE_N8/U64; MX scales keep their operation-owned layouts.
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

- BSTART.TGEMV AType; B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one); B.DIM LB0 M (optional, default 1; TGEMV permits only M=1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, B CUBE_N8 primary; B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary
