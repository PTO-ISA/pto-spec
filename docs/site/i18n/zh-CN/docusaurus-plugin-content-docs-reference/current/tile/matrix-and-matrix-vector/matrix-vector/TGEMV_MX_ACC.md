<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_MX_ACC.asl -->
# TGEMV_MX_ACC

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_MX_ACC.asl`

Multiply the scaled matrix and vector and accumulate into the supplied Tile.

## Normative identity {#PTO-INST-TILE-TGEMV-MX-ACC}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tgemv-mx-acc-purpose role=purpose -->
## 用途

`TGEMV_MX_ACC` 将缩放后的矩阵与向量相乘，并累加到给定 Tile。

<!-- PTO-READER-BLOCK: tile-tgemv-mx-acc-mechanism role=mechanism -->
## 执行机制

ASL DOC 契约通过该指令的选择器编码块载体选择 `TileHandler_TGEMV_MX_ACC`。

源快照之前，必须预检矩阵 绑定模式、M/K/N 维度、操作数布局、DataType、描述符形状、别名、掩码、容量，以及所有必需的 偏置、累加器或 E8M0 缩放 Tile。

<!-- PTO-READER-BLOCK: tile-tgemv-mx-acc-inputs-outputs role=inputs-outputs -->
## 操作数与描述符

`destination0` 是目的地；`source0` 是累加器；`source1` 是左向量；`source2` 是行缩放 Tile；`source3` 是右矩阵；`source4` 是列缩放 Tile。

除非当前契约明确指出状态被消费或替换，否则源保持持久；只有完整预检后才发布目的描述符。

<!-- PTO-READER-BLOCK: tile-tgemv-mx-acc-effects role=effects -->
## 发布与排序

计算之前先快照全部持久输入；目的地和所有启用的辅助输出作为一个原子组发布。

目的地使用当前操作拥有的 CUBE 布局和最终输出类型；当前助记符的累加器输入在计算前取快照，并在成功或拒绝后保持不变。

<!-- PTO-READER-BLOCK: tile-tgemv-mx-acc-constraints role=constraints -->
## 合法性、填充与故障

绑定格式错误、类型或布局不受支持、形状无效、被消费元素未定义、属性非法或目的容量不足时，会在源快照或发布之前拒绝操作。

分配失败触发所有者定义的 Tile 分配故障；其他被拒绝的绑定模式或值条件触发所有者定义的合法性、块控制或内存故障，且不产生部分效果。

<!-- PTO-READER-BLOCK: tile-tgemv-mx-acc-example role=example -->
## 非规范契约草图

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

把 `BSTART.TGEMVMX.ACC AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one); B.DIM LB0 M (optional, default 1; TGEMV permits only M=1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A with encoded selector distinct from DstTile, A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale; B.IOT D matching A's CUBE_M16/M32 layout with a distinct encoded destination index, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary` 作为非规范绑定演练，再以下方生成契约确认精确维度、属性和故障行为。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `matrix-and-matrix-vector`
- **Execution engine:** `CUBE`

## Assembly

```asm
TGEMV_MX_ACC <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGEMV_MX_ACC | CUBE |  | 22 |  | TGEMV_MX_ACC |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | accumulator |
| source1 | left-vector |
| source2 | row-scale |
| source3 | right-matrix |
| source4 | column-scale |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_MX_ACC.asl -->
```asl
readonly func InstructionContractOperation_TGEMV_MX_ACC()
    => TileOperation
begin
    return TileOperation_TGEMV_MX_ACC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TGEMVMX.ACC AType
B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType)
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one)
B.DIM LB0 M (optional, default 1; TGEMV permits only M=1)
B.DIM LB1 N (optional, default 1)
B.DIM LB2 K (optional, default 1)
B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A with encoded selector distinct from DstTile, A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale
B.IOT D matching A's CUBE_M16/M32 layout with a distinct encoded destination index, optional RowMaxOut, optional GroupMaxOut destinations
B.IOT/B.IOR postprocess operands selected by B.FPATR
BSTOP or the next BSTART completion boundary
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_MX_ACC.asl -->
```asl
readonly func InstructionContractCubeFunction_TGEMV_MX_ACC()
    => integer {0..31}
begin
    return 22;
end;

readonly func InstructionContractSharedOperandsAllowed_TGEMV_MX_ACC()
    => boolean
begin
    return FALSE;
end;

readonly func InstructionContractOperandsLegal_TGEMV_MX_ACC(
    destination: TileIndex,
    accumulator: TileIndex,
    left_vector: TileIndex,
    row_scale: TileIndex,
    right_matrix: TileIndex,
    column_scale: TileIndex) => boolean
begin
    return TileOperandsLegal_TGEMV_MX_ACC(
        destination,
        accumulator,
        left_vector,
        row_scale,
        right_matrix,
        column_scale);
end;

readonly func InstructionContractHandler_TGEMV_MX_ACC()
    => TileSemanticHandler
begin
    return TileHandler_TGEMV_MX_ACC;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.
- Omitted LB0, LB1, and LB2 default M, N, and K independently to one; TGEMV fixes M to one.
- Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize. Required E8M0 scales remain ordinary row-major Tiles.
- TransA=0 and TransB=0 select no logical transpose. TGEMV requires both controls to remain zero.
- C and D are both mandatory. In decoded blocks C's six-bit relative selector must differ from zero-extended DstTile before rename; direct Tile calls require destination TileIndex to differ from accumulator TileIndex.
- Omitted CCTRL selects 00: final D output and no transparent-cache hint.

## Legality

- The carrier selects exactly CUBE Function 22 and TileOperation_TGEMV_MX_ACC.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize. Required E8M0 scales remain ordinary row-major Tiles.
- C and D are both mandatory. In decoded blocks C's six-bit relative selector must differ from zero-extended DstTile before rename; direct Tile calls require destination TileIndex to differ from accumulator TileIndex.
- TGEMV is Local-only: TransA and TransB are zero and every effective Shared binding rejects before effects.
- Each matrix side independently requires an E8M0 scale exactly when its MX input type is not FP16 or BF16. C is one explicit Local MxN accumulator source and D is a distinct newly published destination; C's encoded relative selector and D's zero-extended DstTile hand must differ before rename. M is fixed to one and every Shared binding is illegal.
- Every common nonzero four-bit PE_MASK is legal; all four PEs complete cooperative Shared readiness while only selected PEs allocate and publish. Mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.
- B.DATR permits BType, matrix CCTRL via PadValueOrByteId, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.
- For init=1 forms CCTRL[1] must be zero. CCTRL[0]=1 selects raw accumulator-type D and forbids final-output post-processing and auxiliary outputs except legal CScale; CCTRL[1] is an ACC-only non-binding explicit-C cache-use or prefetch hint. Every successful form allocates and publishes D.

## State effects

- Multiply the scaled matrix and vector and accumulate into the supplied Tile.
- After complete preflight, execute TGEMV_MX_ACC with the operand bindings listed above; destination definedness changes only as specified by that handler.
- For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; ordinary Bias, MX scales, and enabled reduction auxiliaries keep their operation-owned layouts.
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

- BSTART.TGEMVMX.ACC AType; B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one); B.DIM LB0 M (optional, default 1; TGEMV permits only M=1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A with encoded selector distinct from DstTile, A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale; B.IOT D matching A's CUBE_M16/M32 layout with a distinct encoded destination index, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary
