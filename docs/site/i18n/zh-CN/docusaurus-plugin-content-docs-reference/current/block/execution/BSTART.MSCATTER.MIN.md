<!-- GENERATED FROM: asl/block/execution/BSTART.MSCATTER.MIN.asl -->
# BSTART.MSCATTER.MIN

**Normative ASL source:** `asl/block/execution/BSTART.MSCATTER.MIN.asl`

Starts GM indexed mscatter.min operation.

## Normative identity {#PTO-INST-BLOCK-BSTART-MSCATTER-MIN}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mscatter-min-purpose role=purpose -->
## 目的与范围

`BSTART.MSCATTER.MIN` 是该已接受操作的稳定阅读入口。规范 `ASL` 源文件和本页生成的 contract 章节仍是架构行为的唯一 owner。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-min-mechanism role=mechanism -->
## 如何阅读操作

应结合生成的 Decode 与 Operation 章节定位所选形式和语义 handler。本指南不增加另一套执行算法。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-min-inputs role=inputs-outputs -->
## 输入与输出

以生成的 Operands and results 表和 Block composition 章节作为编码角色与架构角色的完整映射，不应从本摘要推断省略的操作数或结果。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-min-effects role=effects -->
## 效果与状态

完整效果边界由生成的 State effects 以及 Memory effects and ordering 章节给出。可执行点只证明 owner 得到覆盖，不构成另一份语义来源。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-min-constraints role=constraints -->
## 边界与故障

下方 Defaults、Legality 与 Exceptions 规定接受域和故障边界。保留值及不支持的组合仍由这些生成章节管理。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-min-example role=example -->
## 非规范用法示例

生成的 `BSTART.MSCATTER.MIN` 示例仅用于拼写与导航。替换操作数时必须遵守下方 owner 定义的 legality 和状态合同。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MSCATTER.MIN DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_min_32_gm20 | L32 | 32 | 0x01411181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_min_32_gm20 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Field value dispositions

### DataType (`PTO-FIELD-BLOCK-DATATYPE`)

Selects the Tile element data type carried by Block data attributes and typed Block starts.

**Encoded zero:** Code zero selects FP64; zero never means absent, inherited, NONE, or NULL.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | FP64 |
| 1 | assigned | FP32 |
| 2 | assigned | TF32 |
| 3 | assigned | HF32 |
| 4 | assigned | FP16 |
| 5 | assigned | BF16 |
| 6 | assigned | HiF8 |
| 7 | assigned | E4M3 |
| 8 | assigned | E5M2 |
| 9 | assigned | E3M2 |
| 10 | assigned | E2M3 |
| 11 | assigned | E2M1X2 |
| 12 | assigned | E1M2X2 |
| 13 | assigned | E8M0 |
| 14 | assigned | HiF4X2 |
| 15 | reserved | future extension |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | reserved | future extension |
| 22 | reserved | future extension |
| 23 | reserved | future extension |
| 24 | assigned | U64 |
| 25 | assigned | U32 |
| 26 | assigned | U16 |
| 27 | assigned | U8 |
| 28 | assigned | U4X2 |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Reserved values are held for future extension and reject before architectural effects.

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_mscatter_min_32_gm20 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | GM operation type | Encoded zero is interpreted by the selected operation. |

- `bstart_mscatter_min_32_gm20.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | GM operation type |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MSCATTER.MIN.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MSCATTER_MIN(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mscatter_min_32_gm20);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.MIN DataType
B.DIM LB0=ValidCol
B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MSCATTER.MIN.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MSCATTER_MIN() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MSCATTER_MIN()
    => TileOperation
begin
    return TileOperation_MSCATTER_MIN;
end;

pure func InstructionContractStartsTileBundle_BSTART_MSCATTER_MIN()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- PE_MASK=0000 is a strict no-effect case; B.IOR and valid dimensions are required otherwise.

## Legality

- GM-only operation; Shared and vector forms are excluded.

## State effects

- Opens a complete GM indexed block.

## Memory effects and ordering

### Memory effects

- Complete preflight precedes atomic effects.

### Ordering

- Duplicate effective addresses serialize in implementation-defined order.

## Exceptions

- Reserved DataTypes fault IllegalInstruction; unsupported operation/type tuples fault TileLegality; access faults are preflighted.

## Examples

- BSTART.MSCATTER.MIN DataType
