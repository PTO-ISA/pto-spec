<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TEXTRACT.asl -->
# TEXTRACT

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TEXTRACT.asl`

Extract a rectangular source region at the encoded row and column offsets.

## Normative identity {#PTO-INST-TILE-TEXTRACT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-textract-purpose role=purpose -->
## TEXTRACT 的作用

`TEXTRACT` 是一条由 `SFU` 执行、通过选择器编码的 Tile 操作。它把从编码行偏移和列偏移开始的矩形区域复制到目标；当前指令契约拥有精确的指令束形式和发布边界。

<!-- PTO-READER-BLOCK: tile-textract-mechanism role=mechanism -->
## 元素与 Tile 机制

所有描述符与操作数检查成功后，所属 ASL 处理函数把从编码行偏移和列偏移开始的矩形区域复制到目标。当前契约允许别名时，源载荷会在目标写入前完成快照。

处理函数使用解析后的有效区域，不把物理填充区当作输入数据。操作专属的数据类型、布局、舍入、饱和与配置档钩子仍由可执行定义拥有。

<!-- PTO-READER-BLOCK: tile-textract-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `destination0` 的精确契约角色是“目标”。
- `source0` 的精确契约角色是“源”。
- `natural0` 的精确契约角色是“行偏移”。
- `natural1` 的精确契约角色是“列偏移”。

组合后的指令束模式在处理函数运行前固定描述符、形状、布局和适用性检查。

<!-- PTO-READER-BLOCK: tile-textract-effects role=effects -->
## 发布、已定义性与填充

只有完整预检后才发布目标可见状态；契约规定原子发布时，载荷、描述符、已定义性、填充和状态同时可见。

本页不暗示当前处理函数契约之外的填充行为。

该操作不产生 GM 内存效果；描述符、载荷、已定义性、填充和数值状态变化仅限于当前契约列出的项目。

<!-- PTO-READER-BLOCK: tile-textract-constraints role=constraints -->
## 类型、布局与故障边界

精确的可接受类型或类型组合由下方生成的合法性章节拥有；本指南不会扩大该集合。

下方生成的合法性与异常章节是数据类型组合、布局、维度、容量、已定义性、填充控制、配置档行为和故障类别的权威说明。合法性或分配失败发生在任何部分架构效果之前。

<!-- PTO-READER-BLOCK: tile-textract-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `TEXTRACT` 示例说明：行偏移 `1`、列偏移 `1` 的一乘一目标接收源元素 `[1,1]`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TEXTRACT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TEXTRACT | TEPL | 0x062 | 2 | 3 | TEXTRACT |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| natural0 | row-offset |
| natural1 | column-offset |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TEXTRACT.asl -->
```asl
readonly func InstructionContractOperation_TEXTRACT() => TileOperation
begin
    return TileOperation_TEXTRACT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TEXTRACT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TEXTRACT.asl -->
```asl
readonly func InstructionContractHandler_TEXTRACT() => TileSemanticHandler
begin
    return TileHandler_TEXTRACT;
end;

pure func InstructionContractDataTypeLegal_TEXTRACT(
    data_type: TileDataType) => boolean
begin
    return TileCarrierOrMove24BaselineDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TEXTRACT(
    destination: TileIndex,
    source: TileIndex,
    row_offset: integer {0..65535},
    column_offset: integer {0..65535}) => boolean
begin
    return TileOperandsLegal_TEXTRACT(
        destination,
        source,
        row_offset,
        column_offset);
end;

func InstructionContractExecute_TEXTRACT(
    destination: TileIndex,
    source: TileIndex,
    row_offset: integer {0..65535},
    column_offset: integer {0..65535})
begin
    assert InstructionContractOperandsLegal_TEXTRACT(
        destination,
        source,
        row_offset,
        column_offset);
    TEXTRACT(destination, source, row_offset, column_offset);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- At BSTART the bundle descriptor begins with zero-valued B.DATR and B.DIM state; omitted optional commands retain those reset values, and an encoded zero is a value rather than absence.
- The TileOperandsLegal_TEXTRACT schema determines which B.IOR, B.IOT, B.IOS, B.DATR, and B.DIM bindings are required or optional for TEXTRACT.

## Legality

- TEXTRACT is selected only by its BSTART carrier and selector/function assignment; it has no standalone opcode.
- Before effects, TileOperandsLegal_TEXTRACT validates the complete assembled bundle, operand roles, dimensions, data attributes, and applicability.
- B.DATR applicability is exactly [{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}].

## State effects

- Extract a rectangular source region at the encoded row and column offsets.
- After complete preflight, execute TEXTRACT with the operand bindings listed above; destination definedness changes only as specified by that handler.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- ExecuteTileInstruction supplies the operation fault contract; illegal bundles and reserved selector combinations reject before architectural effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.SFU TEXTRACT, DataType; B.DATR (optional); B.DIM LB0; B.DIM (LB1/LB2 for 2D); B.IOT; B.IOR; BSTOP
