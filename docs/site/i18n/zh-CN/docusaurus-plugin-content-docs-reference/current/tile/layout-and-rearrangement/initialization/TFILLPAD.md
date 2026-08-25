<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/initialization/TFILLPAD.asl -->
# TFILLPAD

**Normative ASL source:** `asl/tile/layout-and-rearrangement/initialization/TFILLPAD.asl`

Copy the source and fill destination padding elements with the bound scalar.

## Normative identity {#PTO-INST-TILE-TFILLPAD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tfillpad-purpose role=purpose -->
## TFILLPAD 的作用

`TFILLPAD` 是一条由 `SFU` 执行、通过选择器编码的 Tile 操作。它复制有效源区域，并把绑定标量写入物理目标填充区；当前指令契约拥有精确的指令束形式和发布边界。

<!-- PTO-READER-BLOCK: tile-tfillpad-mechanism role=mechanism -->
## 元素与 Tile 机制

所有描述符与操作数检查成功后，所属 ASL 处理函数复制有效源区域，并把绑定标量写入物理目标填充区。当前契约允许别名时，源载荷会在目标写入前完成快照。

处理函数使用解析后的有效区域，不把物理填充区当作输入数据。操作专属的数据类型、布局、舍入、饱和与配置档钩子仍由可执行定义拥有。

<!-- PTO-READER-BLOCK: tile-tfillpad-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `destination0` 的精确契约角色是“目标”。
- `source0` 的精确契约角色是“源”。
- `scalar0` 的精确契约角色是“填充值”。

组合后的指令束模式在处理函数运行前固定描述符、形状、布局和适用性检查。

<!-- PTO-READER-BLOCK: tile-tfillpad-effects role=effects -->
## 发布、已定义性与填充

源与标量完成快照后，有效坐标复制源值，所有非有效物理坐标写入绑定标量。

成功时，完整物理目标被标记为已定义，并设置 `contents_defined=TRUE`；载荷、已定义性与描述符同时发布。

该操作不产生 GM 内存效果；描述符、载荷、已定义性、填充和数值状态变化仅限于当前契约列出的项目。

<!-- PTO-READER-BLOCK: tile-tfillpad-constraints role=constraints -->
## 类型、布局与故障边界

精确的可接受类型或类型组合由下方生成的合法性章节拥有；本指南不会扩大该集合。

下方生成的合法性与异常章节是数据类型组合、布局、维度、容量、已定义性、填充控制、配置档行为和故障类别的权威说明。合法性或分配失败发生在任何部分架构效果之前。

<!-- PTO-READER-BLOCK: tile-tfillpad-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `TFILLPAD` 示例说明：有效源值 `5` 保持为 `5`，物理填充区接收绑定标量 `9`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TFILLPAD <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TFILLPAD | TEPL | 0x065 | 5 | 3 | TFILLPAD |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| scalar0 | padding |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/initialization/TFILLPAD.asl -->
```asl
readonly func InstructionContractOperation_TFILLPAD() => TileOperation
begin
    return TileOperation_TFILLPAD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TFILLPAD, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/initialization/TFILLPAD.asl -->
```asl
readonly func InstructionContractHandler_TFILLPAD() => TileSemanticHandler
begin
    return TileHandler_TFILLPAD;
end;

pure func InstructionContractDataTypeLegal_TFILLPAD(
    data_type: TileDataType) => boolean
begin
    return TileFillPadDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TFILLPAD(
    destination: TileIndex,
    source: TileIndex,
    padding: Word) => boolean
begin
    return TileOperandsLegal_TFILLPAD(destination, source, padding);
end;

func InstructionContractExecute_TFILLPAD(
    destination: TileIndex,
    source: TileIndex,
    padding: Word)
begin
    assert InstructionContractOperandsLegal_TFILLPAD(
        destination,
        source,
        padding);
    TFILLPAD(destination, source, padding);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- At BSTART the bundle descriptor begins with zero-valued B.DATR and B.DIM state; omitted optional commands retain those reset values, and an encoded zero is a value rather than absence.
- The TileOperandsLegal_TFILLPAD schema determines which B.IOR, B.IOT, B.IOS, B.DATR, and B.DIM bindings are required or optional for TFILLPAD.
- B.IOR.RegSrc0 supplies the padding scalar; omitted B.IOR selects zero and only the low selected-element-width bits participate.

## Legality

- TFILLPAD is selected only by its BSTART carrier and selector/function assignment; it has no standalone opcode.
- Before effects, TileOperandsLegal_TFILLPAD validates the complete assembled bundle, operand roles, dimensions, data attributes, and applicability.
- B.DATR applicability is exactly [{"allowed_nonzero_fields":["PadValueOrByteId","Layout"],"pad_union":"pad-value"}].

## State effects

- Snapshot the source and bound scalar, copy every valid source coordinate, and write the bound scalar to every non-valid physical destination coordinate.
- Mark the full physical destination defined, set contents_defined=TRUE, and publish payload, definedness, and descriptor atomically after complete preflight.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- ExecuteTileInstruction supplies the operation fault contract; illegal bundles and reserved selector combinations reject before architectural effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.SFU TFILLPAD, DataType; B.DATR (optional); B.DIM LB0; B.DIM (LB1/LB2 for 2D); B.IOT; BSTOP
