<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TTRANS.asl -->
# TTRANS

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TTRANS.asl`

Transpose the source Tile into the destination.

## Normative identity {#PTO-INST-TILE-TTRANS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-ttrans-purpose role=purpose -->
## TTRANS 的作用

`TTRANS` 把源 Tile 转置到目标。

<!-- PTO-READER-BLOCK: tile-c-ttrans-mechanism role=mechanism -->
## 操作机制

完整 bundle schema 通过后，源的行与列坐标在目标中交换角色。

<!-- PTO-READER-BLOCK: tile-c-ttrans-inputs-outputs role=inputs-outputs -->
## 操作数、形状与类型

- `destination0` 标识目的 Tile。

- `source0` 提供持久源 Tile。

- 封闭的适用 DataType 集合为 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`HiF8`、`E4M3`、`E5M2`、`E3M2`、`E2M3`、`E2M1X2`、`E1M2X2`、`E8M0`、`S64`、`S32`、`S16`、`S8`、`S4X2`、`U64`、`U32`、`U16`、`U8`、`U4X2`。

- `LB0`、`LB1`、`LB2` 按该助记符契约补全有效形状与物理形状；所有必需有效范围都必须非零。

<!-- PTO-READER-BLOCK: tile-c-ttrans-effects role=effects -->
## 已定义性、填充与发布

所有源描述符与载荷都会在目标发布前完成验证和快照。

完整目标载荷、描述符、已定义性、填充状态与适用数值状态会原子发布；拒绝路径不发布任何部分。

源 Tile 在成功执行后保持不变。

<!-- PTO-READER-BLOCK: tile-c-ttrans-constraints role=constraints -->
## 合法性、故障与顺序边界

完整绑定模式、维度、DataType、布局、源已定义性、数值编码、目标容量与分配都会在效果前预检。

合法性或分配检查失败会引发相应 Tile 故障，不留下部分目标、状态或内存效果。

<!-- PTO-READER-BLOCK: tile-c-ttrans-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

`TTRANS <bundle operands>` 先完成完整预检与源快照，再原子发布助记符定义的结果与填充状态。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TTRANS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TTRANS | TEPL | 0x06E | 14 | 3 | TTRANS |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TTRANS.asl -->
```asl
readonly func InstructionContractOperation_TTRANS() => TileOperation
begin
    return TileOperation_TTRANS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TTRANS, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TTRANS.asl -->
```asl
readonly func InstructionContractHandler_TTRANS() => TileSemanticHandler
begin
    return TileHandler_TTRANS;
end;

pure func InstructionContractDataTypeLegal_TTRANS(
    data_type: TileDataType) => boolean
begin
    return TileCarrierOrMove24BaselineDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TTRANS(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_TTRANS(destination, source);
end;

func InstructionContractExecute_TTRANS(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TTRANS(destination, source);
    TTRANS(destination, source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- At BSTART the bundle descriptor begins with zero-valued B.DATR and B.DIM state; omitted optional commands retain those reset values, and an encoded zero is a value rather than absence.
- The TileOperandsLegal_TTRANS schema determines which B.IOR, B.IOT, B.IOS, B.DATR, and B.DIM bindings are required or optional for TTRANS.

## Legality

- TTRANS is selected only by its BSTART carrier and selector/function assignment; it has no standalone opcode.
- Before effects, TileOperandsLegal_TTRANS validates the complete assembled bundle, operand roles, dimensions, data attributes, and applicability.
- B.DATR applicability is exactly [{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}].

## State effects

- Transpose the source Tile into the destination.
- After complete preflight, execute TTRANS with the operand bindings listed above; destination definedness changes only as specified by that handler.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- ExecuteTileInstruction supplies the operation fault contract; illegal bundles and reserved selector combinations reject before architectural effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.SFU TTRANS, DataType; B.DATR (optional); B.DIM LB0; B.DIM (LB1/LB2 for 2D); B.IOT; BSTOP
