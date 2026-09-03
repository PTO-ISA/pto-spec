<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TGPR2T.asl -->
# TGPR2T

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TGPR2T.asl`

Re-encode four GPR predicate planes into an ordinary CUBE U8 Tile.

## Normative identity {#PTO-INST-TILE-TGPR2T}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tgpr2t-purpose role=purpose -->
## 目的与范围

`TGPR2T` 是该已接受操作的稳定阅读入口。规范 `ASL` 源文件和本页生成的 contract 章节仍是架构行为的唯一 owner。

<!-- PTO-READER-BLOCK: tile-tgpr2t-mechanism role=mechanism -->
## 如何阅读操作

应结合生成的 Decode 与 Operation 章节定位所选形式和语义 handler。本指南不增加另一套执行算法。

<!-- PTO-READER-BLOCK: tile-tgpr2t-inputs role=inputs-outputs -->
## 输入与输出

以生成的 Operands and results 表和 Block composition 章节作为编码角色与架构角色的完整映射，不应从本摘要推断省略的操作数或结果。

<!-- PTO-READER-BLOCK: tile-tgpr2t-effects role=effects -->
## 效果与状态

完整效果边界由生成的 State effects 以及 Memory effects and ordering 章节给出。可执行点只证明 owner 得到覆盖，不构成另一份语义来源。

<!-- PTO-READER-BLOCK: tile-tgpr2t-constraints role=constraints -->
## 边界与故障

下方 Defaults、Legality 与 Exceptions 规定接受域和故障边界。保留值及不支持的组合仍由这些生成章节管理。

<!-- PTO-READER-BLOCK: tile-tgpr2t-example role=example -->
## 非规范用法示例

生成的 `TGPR2T` 示例仅用于拼写与导航。替换操作数时必须遵守下方 owner 定义的 legality 和状态合同。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TGPR2T <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGPR2T | TEPL | 0x07E | 30 | 3 | TGPR2T |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | ordinary numeric U8 CUBE destination |
| source0 | ordered source-only GPR0 |
| source1 | ordered source-only GPR1 |
| source2 | ordered source-only GPR2 |
| source3 | ordered source-only GPR3 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TGPR2T.asl -->
```asl
readonly func InstructionContractOperation_TGPR2T() => TileOperation
begin
    return TileOperation_TGPR2T;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TGPR2T, U8
B.DATR PadValueOrByteId, RMode (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow
B.IOR GPR0, GPR1, GPR2
B.IOR GPR3
B.IOT mask=PE_MASK, <last>, ->destination<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TGPR2T.asl -->
```asl
readonly func InstructionContractHandler_TGPR2T() => TileSemanticHandler
begin
    return TileHandler_TGPR2T;
end;

pure func InstructionContractDataTypeLegal_TGPR2T(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_U8;
end;

readonly func InstructionContractOperandsLegal_TGPR2T(
    destination: TileIndex, source0: TileIndex, source1: TileIndex,
    source2: TileIndex, source3: TileIndex) => boolean
begin
    return TileOperandsLegal_TGPR2T(
        destination, source0, source1, source2, source3);
end;

func InstructionContractExecute_TGPR2T(
    destination: TileIndex, source0: TileIndex, source1: TileIndex,
    source2: TileIndex, source3: TileIndex)
begin
    assert InstructionContractOperandsLegal_TGPR2T(
        destination, source0, source1, source2, source3);
    TGPR2T(destination, source0, source1, source2, source3);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Omitted B.DATR selects Zero padding and ByteOffset0.
- LB1/LB0=32/4 selects CUBE_M32; LB1/LB0=16/8 selects CUBE_M16. Both dimensions are mandatory and LB2 is absent.

## Legality

- TGPR2T uses TEPL Mode 3 Function 30 (0x07E) with U8 operation type.
- Exact dimensions 32x4 select an ordinary numeric CUBE_M32 destination and 16x8 select CUBE_M16; LB2 is absent and the encoded TSize must cover the complete descriptor.
- Four ordered source-only 64-bit GPRs are supplied by exactly two contiguous B.IOR records with arity 3+1; selectors are absolute GPR0..GPR23.
- Zero and Max are the only padding values. PE_MASK=0000 is a strict no-op before schema, GPR reads, allocation, or effects.

## State effects

- Pack M32 rows as eight predicate bits into one selected U8 byte; pack M16 rows as sixteen bits into two selected U8 bytes.
- PadValue is independent of ByteOffset; the operation does not change GPRs or status.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- All four GPR sources and PE mask are snapshotted before destination publication.
- No old destination payload is read; successful publication is atomic.

## Exceptions

- RMode[17] must be zero. PadValue accepts only Zero or Max; Min and Null reject before effects.
- Exactly two immediately contiguous source-only B.IOR records split 3+1 are required, followed by one destination B.IOT. Missing dimensions, an intervening command, wrong order/split, GPR destination, or surplus record rejects before effects.

## Examples

- BSTART.SFU TGPR2T, U8; B.DATR PadValueOrByteId, RMode; B.DIM LB0=ValidCol; B.DIM LB1=ValidRow; B.IOR a0, a1, a2; B.IOR a3; B.IOT mask=1111, <last>, ->T0<TSize>; BSTOP
