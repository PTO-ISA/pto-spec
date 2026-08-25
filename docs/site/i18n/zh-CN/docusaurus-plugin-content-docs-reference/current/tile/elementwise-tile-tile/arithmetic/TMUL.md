<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/arithmetic/TMUL.asl -->
# TMUL

**Normative ASL source:** `asl/tile/elementwise-tile-tile/arithmetic/TMUL.asl`

Multiply corresponding elements of two Local Tiles.

## Normative identity {#PTO-INST-TILE-TMUL}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tmul-purpose role=purpose -->
## 用途

`TMUL` 逐元素相乘两个 Local Tile。

<!-- PTO-READER-BLOCK: tile-tmul-mechanism role=mechanism -->
## 执行机制

ASL DOC 契约通过该指令的选择器编码块载体选择 `TileHandler_ExecuteTileBinary`。

源快照之前，必须检查绑定模式、维度、DataType、行主序布局、源已定义性与编码、PE_MASK、目的容量和适用属性。

<!-- PTO-READER-BLOCK: tile-tmul-inputs-outputs role=inputs-outputs -->
## 操作数与描述符

`destination0` 是新 Local 目的地；`source0` 是左因子；`source1` 是右因子。

除非当前契约明确指出状态被消费或替换，否则源保持持久；只有完整预检后才发布目的描述符。

<!-- PTO-READER-BLOCK: tile-tmul-effects role=effects -->
## 发布与排序

每个有效坐标都按所选元素类型执行操作；目的地发布之前会快照全部源和私有 GPR 标量操作数。

有效载荷、选中的物理填充的已定义性、描述符和适用的粘滞数值标志原子发布；拒绝时没有架构效果。

<!-- PTO-READER-BLOCK: tile-tmul-constraints role=constraints -->
## 合法性、填充与故障

绑定格式错误、类型或布局不受支持、形状无效、被消费元素未定义、属性非法或目的容量不足时，会在源快照或发布之前拒绝操作。

分配失败触发所有者定义的 Tile 分配故障；其他被拒绝的绑定模式或值条件触发所有者定义的合法性、块控制或内存故障，且不产生部分效果。

<!-- PTO-READER-BLOCK: tile-tmul-example role=example -->
## 非规范契约草图

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

把 `BSTART.VEC TMUL, U64; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP` 作为非规范绑定演练，再以下方生成契约确认精确维度、属性和故障行为。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TMUL <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMUL | TEPL | 0x002 | 2 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | left factor |
| source1 | right factor |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/arithmetic/TMUL.asl -->
```asl
readonly func InstructionContractOperation_TMUL() => TileOperation
begin
    return TileOperation_TMUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TMUL, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/arithmetic/TMUL.asl -->
```asl
pure func InstructionContractDataTypeLegal_TMUL(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TMUL(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_MUL,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TMUL() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TMUL(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_MUL,
        destination,
        source_left,
        source_right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.

## Legality

- TMUL is BSTART.VEC Mode 0 Function 2 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies two ordered Local sources and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of S32, U32, FP32, S16, U16, FP16, or BF16.
- Sources are fully defined and all three Tiles match physical shape, valid shape, row-major layout, DataType, and PE_MASK.
- Only B.DATR PadValueOrByteId is applicable.

## State effects

- Publish the elementwise products after complete preflight.
- Pad the remaining physical region using the selected PadValue; Null padding is undefined.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both sources are snapshotted before destination writes.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched sources, unsupported DataType, or invalid destination capacity raises Fault_TileLegality before effects.

## Examples

- BSTART.VEC TMUL, U64; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
