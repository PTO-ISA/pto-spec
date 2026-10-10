<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TMOV.asl -->
# TMOV

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TMOV.asl`

Copy the source Tile payload and definedness into the destination.

## Normative identity {#PTO-INST-TILE-TMOV}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tmov-purpose role=purpose -->
## TMOV 的作用

Local `TMOV` 把一个持久的 Local Tile 复制到一个新重命名的 Local 目标中。它精确复制载荷与逐元素已定义性；它不转换数值。

设计要点：`TMOV` 由 `BSTART.TMOV`（Function 2）选中，没有独立 opcode。同一个 `BSTART.TMOV` Function 2 也承载规范的 Shared 形式：Local 源到 Shared 目标，以及 Shared 源到 Local 目标，并配合 `B.SUBVIEW` 或 `B.ASSEMBLE` 范围。[BSTART.TMOV](../../../block/execution/BSTART.TMOV.md)拥有这些模式。

<!-- PTO-READER-BLOCK: tile-tmov-mechanism role=mechanism -->
## 复制机制

没有 ExecutionMask 时，目标接收源载荷与源已定义性记录。在源中未定义的元素在目标中仍保持未定义。

存在 ExecutionMask 时，源必须在掩码要求的坐标上已定义。随后每个非活动有效元素接收该掩码规定的零值或合并值，并且整个有效区域被标记为已定义。

设计要点：`BSTART` `DataType` 只是载体解释。源后备类型只能在元素位宽相同时与之不同，并且目标保持源后备类型。因此 `TMOV` 从不改变元素位；数值转换请使用 `TCVT`。

<!-- PTO-READER-BLOCK: tile-tmov-inputs-outputs role=inputs-outputs -->
## 操作数与描述符

- `source0` 是持久的 Local 源。
- `destination0` 是新重命名的 Local 目标。

目标必须在物理行列、有效行列、布局与存储类别上与源完全一致，其类型必须等于源后备类型。

`BSTART.TMOV` 接受 `DTYPE_NONE`（代码 31）。当 `B.DATR` 与 `BSTART` 都没有给出具体类型时，操作类型为源描述符类型。`B.DATR` 只能携带 `Layout`，其填充字段必须为零。

载体兼容性排除 4 位类型：4 位后备类型只有在等于操作类型时才被接受。

<!-- PTO-READER-BLOCK: tile-tmov-effects role=effects -->
## 效果与顺序

源保持不变。目标载荷、已定义性与描述符在指令束完成时变为可见；被拒绝的指令束没有任何目标效果。

Local `TMOV` 没有全局内存效果，也不记录数值状态。

<!-- PTO-READER-BLOCK: tile-tmov-constraints role=constraints -->
## 合法性与故障

形状、布局、存储类别或载体位宽不匹配，目标类型不同于源后备类型，或 `Layout` 之外的非零 `B.DATR` 字段，都会在任何架构效果之前被拒绝。

设计要点：这里要求形状完全一致，而不是调整大小。需要不同有效区域或填充的程序必须使用拥有该变化的操作。

<!-- PTO-READER-BLOCK: tile-tmov-example role=example -->
## 非规范契约草图

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

源 Tile 以 RowMajor 保存 8 x 64 个 `FP32` 元素，元素 `[0,0]` 保存 `0x3f800000`。操作类型为同样 32 位宽的 `S32` 时，该复制合法：目标为 8 x 64 的 `FP32`，元素 `[0,0]` 仍保存 `0x3f800000`。若为 `FP16`，位宽不同，该指令束会被拒绝。

以宏形式表示，类型匹配的复制写作下面的形式。目标容纳 8 x 64 x 4 = 2048 字节。

```text
TMOV <FP32>, T#1, ->T<2KB>
```
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `TLSU`

## Assembly

```asm
TMOV <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMOV | TLSU |  | 2 |  | TMOV |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TMOV.asl -->
```asl
readonly func InstructionContractOperation_TMOV() => TileOperation
begin
    return TileOperation_TMOV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TLSU TMOV, DataType
B.DIM LB0
B.DIM LB1 (optional)
B.DIM LB2 (optional)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TMOV.asl -->
```asl
readonly func InstructionContractHandler_TMOV() => TileSemanticHandler
begin
    return TileHandler_TMOV;
end;

readonly func InstructionContractOperandsLegal_TMOV(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_TMOV(destination, source);
end;

func InstructionContractExecute_TMOV(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TMOV(destination, source);
    TMOV(destination, source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- At BSTART the bundle descriptor begins with zero-valued B.DATR and B.DIM state; omitted optional commands retain those reset values, and an encoded zero is a value rather than absence.
- The TileOperandsLegal_TMOV schema determines which B.IOR, B.IOT, B.IOS, B.DATR, and B.DIM bindings are required or optional for TMOV.

## Legality

- TMOV is selected only by its BSTART carrier and selector/function assignment; it has no standalone opcode.
- Before effects, TileOperandsLegal_TMOV validates the complete assembled bundle, operand roles, dimensions, data attributes, and applicability.
- B.DATR applicability is exactly [{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}].
- The selected DataType is a carrier interpretation. Each non-packed source backing DataType may differ only at the same element width, and the newly allocated destination preserves the source backing DataType; multi-source operations require one common backing DataType.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- Copy the source Tile payload and definedness into the destination.
- After complete preflight, execute TMOV with the operand bindings listed above; destination definedness changes only as specified by that handler.

## Memory effects and ordering

### Memory effects

- Perform only the global, Local, or Shared data movement named by the mnemonic after complete access, shape, stride, and descriptor validation; a fault produces no partial destination or memory effect.

### Ordering

- none

## Exceptions

- ExecuteTileInstruction supplies the operation fault contract; illegal bundles and reserved selector combinations reject before architectural effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.TLSU TMOV, DataType; B.DIM LB0; B.DIM LB1 (optional); B.DIM LB2 (optional); B.IOT; BSTOP
