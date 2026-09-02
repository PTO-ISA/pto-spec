<!-- GENERATED FROM: asl/block/execution/BSTART.MSCATTER.MASK.asl -->
# BSTART.MSCATTER.MASK

**Normative ASL source:** `asl/block/execution/BSTART.MSCATTER.MASK.asl`

Scatter Local data through explicit Row or Elem relative-index mode.

## Normative identity {#PTO-INST-BLOCK-BSTART-MSCATTER-MASK}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mscatter-mask-purpose role=purpose -->
## BSTART.MSCATTER.MASK 的作用

`BSTART.MSCATTER.MASK` 是 `MSCATTER.MASK` 形式的 32 位 Block 起始命令。它建立待处理 Block 的身份和选择参数；真正执行 Block body 并提交结果的是完成后的整个 Block，而不是起始命令本身。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-mask-mechanism role=mechanism -->
## 位置与机制

起始命令之后的 header 命令按顺序执行；`BSTOP` 或下一条 `BSTART` 是验证并退休完整 Block 的边界。当前所有者给出以下确切组成检查表：

```text
BSTART.MSCATTER.MASK DataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT DataTile, IndexTile, mask=PE_MASK
B.IOT MaskTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

任何有效前序 Block 成功退休后，该命令初始化新的待处理 `BARG` 或操作描述符，并从顺序 PC 继续执行 header。仅仅成功解码起始命令，不会让 Block 目的结果或内存结果变得可见。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-mask-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `DataType` 选择元素数据类型或继承哨兵；其确切分配域仍以下方生成契约为准。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-mask-effects role=effects -->
## 待处理状态与完成

对适用性和目标检查而言，起始状态转换与前序 Block 退休是全有或全无的。起始命令成功后，后续完成边界会在任何 body 结果提交前验证完整组成。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-mask-constraints role=constraints -->
## 合法性与故障边界

保留选择器、无效目标、完成后的组成错误或前序退休失败，都会在新 Block 或 body 影响之前被拒绝。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-mask-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
BSTART.MSCATTER.MASK DataType
```

假设前序 Block 退休和目标检查成功，`BSTART.MSCATTER.MASK DataType` 会打开待处理的 `BSTART.MSCATTER.MASK` 形式；后续 header/body 命令仍是暂定状态，直到 `BSTOP` 或下一条 `BSTART` 验证完整组成。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MSCATTER.MASK DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_mask_32_2a33eed646f7 | L32 | 32 | 0x00711181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_mask_32_2a33eed646f7 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Field value dispositions

### B.DATR.CMode (`PTO-FIELD-BLOCK-CMODE`)

Selects the operation-defined comparison or indexed-memory mode.

**Encoded zero:** Equality for comparisons; Row mode for indexed TLSU.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | EQ-or-Row |
| 1 | assigned | NE-or-Elem |
| 2 | assigned | LT |
| 3 | assigned | GT |
| 4 | assigned | LE |
| 5 | assigned | GE |
| 6 | reserved | future extension |
| 7 | reserved | future extension |

**Reserved-value behavior:** Codes 6 and 7 are reserved and reject before architectural effects.

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
| bstart_mscatter_mask_32_2a33eed646f7 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | memory transfer element type selector | Encoded zero selects FP64. |

- `bstart_mscatter_mask_32_2a33eed646f7.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | memory transfer element type selector |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |
| B.IOR.RegSrc1 | per-PE private-GPR GM row stride in elements |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MSCATTER.MASK.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MSCATTER_MASK(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mscatter_mask_32_2a33eed646f7);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.MASK DataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT DataTile, IndexTile, mask=PE_MASK
B.IOT MaskTile, mask=PE_MASK, <last>
B.IOR BaseGPR, StrideGPR, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MSCATTER.MASK.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MSCATTER_MASK() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MSCATTER_MASK()
    => TileOperation
begin
    return TileOperation_MSCATTER_MASK;
end;

pure func InstructionContractStartsTileBundle_BSTART_MSCATTER_MASK()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is always encoded and selects the memory transfer type.
- The completed schema requires explicit B.IOR: RegSrc0 supplies the per-PE GM base address and RegSrc1 supplies a nonzero GM row stride in elements no smaller than ValidCol. RegSrc2 and RegDst remain zero. Omitted LB1 defaults to one, omitted LB2 defaults to LB0, and omitted B.DATR uses the operation defaults.
- B.DATR CMode=0 selects Row mode and CMode=1 selects Elem mode; codes 2..5 are inapplicable. Row mode uses a canonical row-major 1 x ValidRow S32/U32 IndexTile and consumes RegSrc1 as a GM row stride in elements. Elem mode uses a row-major S32/U32 IndexTile matching the data valid shape, requires RegSrc1 to encode zero, and treats each index as a relative element displacement from BaseGPR.

## Legality

- bstart_mscatter_mask_32_2a33eed646f7.DataType accepts only 0..14, 16..20, and 24..28 at decode; all other encodings are reserved.
- Indexed TLSU transfer additionally rejects E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 because no nibble selector is encoded.
- The body must complete the exact two-B.IOT schema documented by PTO-TILE-MSCATTER-MASK; no B.IOS or destination is accepted.
- B.IOR RegSrc0 supplies the per-PE GM base and RegSrc1 supplies the GM row stride in elements. RegSrc1 must be at least ValidCol; RegSrc2 and RegDst must be zero.
- For indexed TLSU, B.DATR CMode accepts only Row=0 and Elem=1; CMode 2..5 raises Fault_TileLegality before address generation or effects.
- Row mode requires a canonical row-major 1 x ValidRow S32/U32 IndexTile and a RegSrc1 row-stride value no smaller than ValidCol.
- Elem mode requires a row-major S32/U32 IndexTile matching the data valid shape and requires B.IOR RegSrc1, RegSrc2, and RegDst to encode zero.

## State effects

- Closes any preceding block, initializes a new TileMemory descriptor, and selects TLSU function 7 with encoded DataType.
- No Tile is allocated and no source is consumed by the start instruction.

## Memory effects and ordering

### Memory effects

- Row mode stores data coordinate (r,c) at BaseGPR + (IndexTile[0,r] * row_stride_elements + c) * sizeof(DataType).
- Elem mode stores data coordinate (r,c) at BaseGPR + IndexTile[r,c] * sizeof(DataType).

### Ordering

- The start defines no ordering. B.CATR attributes apply when the completed block commits.

## Exceptions

- Reserved DataType encodings raise Fault_IllegalInstruction before architectural effects.
- Malformed composition, invalid predicate values, type/shape/layout mismatch, packed transfer types, or enabled-lane access faults reject before any store or event.

## Examples

- BSTART.MSCATTER.MASK DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK; B.IOT MaskTile, mask=PE_MASK, <last>; B.IOR BaseGPR, StrideGPR, zero, ->zero; BSTOP
