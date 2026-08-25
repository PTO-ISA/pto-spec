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
## 用途

`TMOV` 把源 Tile 的载荷和已定义性一起复制到目的 Tile。

<!-- PTO-READER-BLOCK: tile-tmov-mechanism role=mechanism -->
## 执行机制

ASL DOC 契约通过该指令的选择器编码块载体选择 `TileHandler_TMOV`。

任何源快照之前，必须检查维度、描述符、布局、DataType、源已定义性、被消费的编码、目的容量、掩码，以及操作专用索引或偏移。

<!-- PTO-READER-BLOCK: tile-tmov-inputs-outputs role=inputs-outputs -->
## 操作数与描述符

`destination0` 是目的地；`source0` 是源。

除非当前契约明确指出状态被消费或替换，否则源保持持久；只有完整预检后才发布目的描述符。

<!-- PTO-READER-BLOCK: tile-tmov-effects role=effects -->
## 发布与排序

构造结果之前会先快照源，因此允许的别名看到完整的操作前载荷与已定义性。

完整目的载荷、已定义性、填充 策略和描述符一同发布；拒绝时不会发布部分目的地。

<!-- PTO-READER-BLOCK: tile-tmov-constraints role=constraints -->
## 合法性、填充与故障

绑定格式错误、类型或布局不受支持、形状无效、被消费元素未定义、属性非法或目的容量不足时，会在源快照或发布之前拒绝操作。

分配失败触发所有者定义的 Tile 分配故障；其他被拒绝的绑定模式或值条件触发所有者定义的合法性、块控制或内存故障，且不产生部分效果。

<!-- PTO-READER-BLOCK: tile-tmov-example role=example -->
## 非规范契约草图

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

把 `BSTART.TLSU TMOV, DataType; B.DIM LB0; B.DIM (LB1/LB2 for 2D); B.IOT; BSTOP` 作为非规范绑定演练，再以下方生成契约确认精确维度、属性和故障行为。
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
B.DIM (LB1/LB2 for 2D)
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

- BSTART.TLSU TMOV, DataType; B.DIM LB0; B.DIM (LB1/LB2 for 2D); B.IOT; BSTOP
