<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TCONCAT.asl -->
# TCONCAT

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TCONCAT.asl`

Concatenate two source Tiles along columns.

## Normative identity {#PTO-INST-TILE-TCONCAT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tconcat-purpose role=purpose -->
## TCONCAT 的作用

`TCONCAT` 是一条由 `SFU` 执行、通过选择器编码的 Tile 操作。它沿列维度拼接左右源 Tile；当前指令契约拥有精确的指令束形式和发布边界。

<!-- PTO-READER-BLOCK: tile-tconcat-mechanism role=mechanism -->
## 元素与 Tile 机制

所有描述符与操作数检查成功后，所属 ASL 处理函数沿列维度拼接左右源 Tile。当前契约允许别名时，源载荷会在目标写入前完成快照。

处理函数使用解析后的有效区域，不把物理填充区当作输入数据。操作专属的数据类型、布局、舍入、饱和与配置档钩子仍由可执行定义拥有。

<!-- PTO-READER-BLOCK: tile-tconcat-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `destination0` 的精确契约角色是“目标”。
- `source0` 的精确契约角色是“左源”。
- `source1` 的精确契约角色是“右源”。

组合后的指令束模式在处理函数运行前固定描述符、形状、布局和适用性检查。

<!-- PTO-READER-BLOCK: tile-tconcat-effects role=effects -->
## 发布、已定义性与填充

只有完整预检后才发布目标可见状态；契约规定原子发布时，载荷、描述符、已定义性、填充和状态同时可见。

本页不暗示当前处理函数契约之外的填充行为。

该操作不产生 GM 内存效果；描述符、载荷、已定义性、填充和数值状态变化仅限于当前契约列出的项目。

<!-- PTO-READER-BLOCK: tile-tconcat-constraints role=constraints -->
## 类型、布局与故障边界

精确的可接受类型或类型组合由下方生成的合法性章节拥有；本指南不会扩大该集合。

下方生成的合法性与异常章节是数据类型组合、布局、维度、容量、已定义性、填充控制、配置档行为和故障类别的权威说明。合法性或分配失败发生在任何部分架构效果之前。

<!-- PTO-READER-BLOCK: tile-tconcat-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `TCONCAT` 示例说明：单行源 `[1, 2]` 与 `[3]` 拼接为 `[1, 2, 3]`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TCONCAT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCONCAT | TEPL | 0x060 | 0 | 3 | TCONCAT |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source-left |
| source1 | source-right |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TCONCAT.asl -->
```asl
readonly func InstructionContractOperation_TCONCAT() => TileOperation
begin
    return TileOperation_TCONCAT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TCONCAT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM LB1 (optional)
B.DIM LB2 (optional)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TCONCAT.asl -->
```asl
readonly func InstructionContractHandler_TCONCAT() => TileSemanticHandler
begin
    return TileHandler_TCONCAT;
end;

pure func InstructionContractDataTypeLegal_TCONCAT(
    data_type: TileDataType) => boolean
begin
    return TileCarrierOrMove24BaselineDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCONCAT(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_TCONCAT(
        destination,
        source_left,
        source_right);
end;

func InstructionContractExecute_TCONCAT(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    assert InstructionContractOperandsLegal_TCONCAT(
        destination,
        source_left,
        source_right);
    TCONCAT(destination, source_left, source_right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- At BSTART the bundle descriptor begins with zero-valued B.DATR and B.DIM state; omitted optional commands retain those reset values, and an encoded zero is a value rather than absence.
- The TileOperandsLegal_TCONCAT schema determines which B.IOR, B.IOT, B.IOS, B.DATR, and B.DIM bindings are required or optional for TCONCAT.

## Legality

- TCONCAT is selected only by its BSTART carrier and selector/function assignment; it has no standalone opcode.
- Before effects, TileOperandsLegal_TCONCAT validates the complete assembled bundle, operand roles, dimensions, data attributes, and applicability.
- B.DATR applicability is exactly [{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}].

## State effects

- Concatenate two source Tiles along columns.
- After complete preflight, execute TCONCAT with the operand bindings listed above; destination definedness changes only as specified by that handler.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- ExecuteTileInstruction supplies the operation fault contract; illegal bundles and reserved selector combinations reject before architectural effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.SFU TCONCAT, DataType; B.DATR (optional); B.DIM LB0; B.DIM LB1 (optional); B.DIM LB2 (optional); B.IOT; BSTOP
