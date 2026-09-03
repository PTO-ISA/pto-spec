<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MSCATTER_MIN.asl -->
# MSCATTER_MIN

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MSCATTER_MIN.asl`

GM indexed mscatter.min operation.

## Normative identity {#PTO-INST-TILE-MSCATTER-MIN}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mscatter-min-purpose role=purpose -->
## 目的与范围

`MSCATTER_MIN` 是该已接受操作的稳定阅读入口。规范 `ASL` 源文件和本页生成的 contract 章节仍是架构行为的唯一 owner。

<!-- PTO-READER-BLOCK: tile-mscatter-min-mechanism role=mechanism -->
## 如何阅读操作

应结合生成的 Decode 与 Operation 章节定位所选形式和语义 handler。本指南不增加另一套执行算法。

<!-- PTO-READER-BLOCK: tile-mscatter-min-inputs role=inputs-outputs -->
## 输入与输出

以生成的 Operands and results 表和 Block composition 章节作为编码角色与架构角色的完整映射，不应从本摘要推断省略的操作数或结果。

<!-- PTO-READER-BLOCK: tile-mscatter-min-effects role=effects -->
## 效果与状态

完整效果边界由生成的 State effects 以及 Memory effects and ordering 章节给出。可执行点只证明 owner 得到覆盖，不构成另一份语义来源。

<!-- PTO-READER-BLOCK: tile-mscatter-min-constraints role=constraints -->
## 边界与故障

下方 Defaults、Legality 与 Exceptions 规定接受域和故障边界。保留值及不支持的组合仍由这些生成章节管理。

<!-- PTO-READER-BLOCK: tile-mscatter-min-example role=example -->
## 非规范用法示例

生成的 `MSCATTER_MIN` 示例仅用于拼写与导航。替换操作数时必须遵守下方 owner 定义的 legality 和状态合同。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MSCATTER_MIN <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MSCATTER_MIN | TLSU |  | 20 |  | GM_RED_VALUE |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| address | base-address |
| source0 | indices |
| source1 | value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MSCATTER_MIN.asl -->
```asl
readonly func InstructionContractMatches_MSCATTER_MIN(operation: TileOperation) => boolean
begin
    return operation == TileOperation_MSCATTER_MIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.MIN DataType
B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MSCATTER_MIN.asl -->
```asl
readonly func InstructionContractHandler_MSCATTER_MIN() => TileSemanticHandler
begin
    return TileHandler_GM_RED_VALUE;
end;
readonly func InstructionContractOperation_MSCATTER_MIN() => TileOperation
begin
    return TileOperation_MSCATTER_MIN;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- GM indexed operation uses byte-displacement addresses and complete preflight.

## Legality

- GM-only; Shared, vector, packed, and U128 forms are rejected.

## State effects

- All valid requests take effect; atom forms publish observed old values.

## Memory effects and ordering

### Memory effects

- One intrinsic atomic RMW per valid request.

### Ordering

- Duplicate-address events serialize in implementation-defined order.

## Exceptions

- Legality and access faults occur before effects.

## Examples

- BSTART.MSCATTER.MIN DataType
