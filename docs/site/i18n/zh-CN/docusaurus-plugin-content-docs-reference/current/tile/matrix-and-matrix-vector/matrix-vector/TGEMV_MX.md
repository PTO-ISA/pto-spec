<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_MX.asl -->
# TGEMV_MX

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_MX.asl`

Multiply the matrix by the vector using row and column scale Tiles.

## Normative identity {#PTO-INST-TILE-TGEMV-MX}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tgemv-mx-purpose role=purpose -->
## 用途

`TGEMV_MX` 将缩放后的矩阵与向量相乘，并发布到新目的 Tile。

<!-- PTO-READER-BLOCK: tile-tgemv-mx-mechanism role=mechanism -->
## 执行机制

ASL DOC 契约通过该指令的选择器编码块载体选择 `TileHandler_TGEMV_MX`。

源快照之前，必须预检矩阵 绑定模式、M/K/N 维度、操作数布局、DataType、描述符形状、别名、掩码、容量，以及所有必需的 偏置、累加器或 E8M0 缩放 Tile。

<!-- PTO-READER-BLOCK: tile-tgemv-mx-inputs-outputs role=inputs-outputs -->
## 操作数与描述符

`destination0` 是目的地；`source0` 是左向量；`source1` 是行缩放 Tile；`source2` 是右矩阵；`source3` 是列缩放 Tile。

除非当前契约明确指出状态被消费或替换，否则源保持持久；只有完整预检后才发布目的描述符。

<!-- PTO-READER-BLOCK: tile-tgemv-mx-effects role=effects -->
## 发布与排序

计算之前先快照全部持久输入；目的地和所有启用的辅助输出作为一个原子组发布。

目的地使用当前操作拥有的 CUBE 布局和最终输出类型。

<!-- PTO-READER-BLOCK: tile-tgemv-mx-constraints role=constraints -->
## 合法性、填充与故障

绑定格式错误、类型或布局不受支持、形状无效、被消费元素未定义、属性非法或目的容量不足时，会在源快照或发布之前拒绝操作。

分配失败触发所有者定义的 Tile 分配故障；其他被拒绝的绑定模式或值条件触发所有者定义的合法性、块控制或内存故障，且不产生部分效果。

<!-- PTO-READER-BLOCK: tile-tgemv-mx-example role=example -->
## 非规范契约草图

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

把 `BSTART.TGEMVMX AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one); B.DIM LB0 M (optional, default 1; TGEMV permits only M=1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale; B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary` 作为非规范绑定演练，再以下方生成契约确认精确维度、属性和故障行为。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `matrix-and-matrix-vector`
- **Execution engine:** `CUBE`

## Assembly

```asm
TGEMV_MX <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGEMV_MX | CUBE |  | 20 |  | TGEMV_MX |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | left-vector |
| source1 | row-scale |
| source2 | right-matrix |
| source3 | column-scale |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_MX.asl -->
```asl
readonly func InstructionContractOperation_TGEMV_MX()
    => TileOperation
begin
    return TileOperation_TGEMV_MX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TGEMVMX AType
B.DATR BType, RMode, Sat (optional; BType defaults to AType)
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one)
B.DIM LB0 M (optional, default 1; TGEMV permits only M=1)
B.DIM LB1 N (optional, default 1)
B.DIM LB2 K (optional, default 1)
B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale
B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations
B.IOT/B.IOR postprocess operands selected by B.FPATR
BSTOP or the next BSTART completion boundary
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_MX.asl -->
```asl
readonly func InstructionContractCubeFunction_TGEMV_MX()
    => integer {0..31}
begin
    return 20;
end;

readonly func InstructionContractSharedOperandsAllowed_TGEMV_MX()
    => boolean
begin
    return FALSE;
end;

readonly func InstructionContractOperandsLegal_TGEMV_MX(
    destination: TileIndex,
    left_vector: TileIndex,
    row_scale: TileIndex,
    right_matrix: TileIndex,
    column_scale: TileIndex) => boolean
begin
    return TileOperandsLegal_TGEMV_MX(
        destination,
        left_vector,
        row_scale,
        right_matrix,
        column_scale);
end;

readonly func InstructionContractHandler_TGEMV_MX()
    => TileSemanticHandler
begin
    return TileHandler_TGEMV_MX;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.
- Omitted LB0, LB1, and LB2 default M, N, and K independently to one; TGEMV fixes M to one.
- Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize. Required E8M0 scales remain ordinary row-major Tiles.
- TransA=0 and TransB=0 select no logical transpose. TGEMV requires both controls to remain zero.

## Legality

- The carrier selects exactly CUBE Function 20 and TileOperation_TGEMV_MX.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize. Required E8M0 scales remain ordinary row-major Tiles.
- TGEMV is Local-only: TransA and TransB are zero and every effective Shared binding rejects before effects.
- Each matrix side independently requires an E8M0 scale exactly when its MX input type is not FP16 or BF16. M is fixed to one and every Shared binding is illegal.
- Every common nonzero four-bit PE_MASK is legal; all four PEs complete cooperative Shared readiness while only selected PEs allocate and publish. Mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.
- B.DATR permits only BType, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.

## State effects

- Multiply the matrix by the vector using row and column scale Tiles.
- After complete preflight, execute TGEMV_MX with the operand bindings listed above; destination definedness changes only as specified by that handler.
- For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; ordinary Bias, MX scales, and enabled reduction auxiliaries keep their operation-owned layouts.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, field, type, dimension, descriptor, shape, capacity, readiness, alias, and allocation preflight precedes every source snapshot and destination effect.
- D and every enabled reduction output publish as one atomic group; rejection publishes none and successful sources persist.

## Exceptions

- A reserved DataType or fixed-bit mismatch raises Fault_IllegalInstruction before block state changes.
- Missing, duplicate, or non-Matrix B.FPATR use raises Fault_BundleControl before allocation or payload effects.
- Illegal types, dimensions, masks, binding streams, descriptors, shapes, capacities, aliases, readiness, or postprocess values raise Fault_TileLegality before source snapshots and effects.

## Examples

- BSTART.TGEMVMX AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one); B.DIM LB0 M (optional, default 1; TGEMV permits only M=1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale; B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary
