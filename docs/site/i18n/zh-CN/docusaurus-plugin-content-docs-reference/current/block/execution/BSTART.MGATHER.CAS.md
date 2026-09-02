<!-- GENERATED FROM: asl/block/execution/BSTART.MGATHER.CAS.asl -->
# BSTART.MGATHER.CAS

**Normative ASL source:** `asl/block/execution/BSTART.MGATHER.CAS.asl`

Atomically compare and conditionally replace GM elements at signed or unsigned byte displacements.

## Normative identity {#PTO-INST-BLOCK-BSTART-MGATHER-CAS}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-purpose role=purpose -->
## BSTART.MGATHER.CAS 的作用

`BSTART.MGATHER.CAS` 是 `MGATHER.CAS` 形式的 32 位 Block 起始命令。它建立待处理 Block 的身份和选择参数；真正执行 Block body 并提交结果的是完成后的整个 Block，而不是起始命令本身。

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-mechanism role=mechanism -->
## 位置与机制

起始命令之后的 header 命令按顺序执行；`BSTOP` 或下一条 `BSTART` 是验证并退休完整 Block 的边界。当前所有者给出以下确切组成检查表：

```text
BSTART.MGATHER.CAS DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT IndexTile, ExpectedTile, mask=PE_MASK
B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

任何有效前序 Block 成功退休后，该命令初始化新的待处理 `BARG` 或操作描述符，并从顺序 PC 继续执行 header。仅仅成功解码起始命令，不会让 Block 目的结果或内存结果变得可见。

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `DataType` 选择元素数据类型或继承哨兵；其确切分配域仍以下方生成契约为准。

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-effects role=effects -->
## 待处理状态与完成

对适用性和目标检查而言，起始状态转换与前序 Block 退休是全有或全无的。起始命令成功后，后续完成边界会在任何 body 结果提交前验证完整组成。

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-constraints role=constraints -->
## 合法性与故障边界

保留选择器、无效目标、完成后的组成错误或前序退休失败，都会在新 Block 或 body 影响之前被拒绝。

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
BSTART.MGATHER.CAS DataType
```

假设前序 Block 退休和目标检查成功，`BSTART.MGATHER.CAS DataType` 会打开待处理的 `BSTART.MGATHER.CAS` 形式；后续 header/body 命令仍是暂定状态，直到 `BSTOP` 或下一条 `BSTART` 验证完整组成。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MGATHER.CAS DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mgather_cas_32_fd8c8a3b720a | L32 | 32 | 0x00811181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mgather_cas_32_fd8c8a3b720a | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_mgather_cas_32_fd8c8a3b720a | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | transfer, comparison, replacement, and destination element type | Encoded zero selects FP64. |

- `bstart_mgather_cas_32_fd8c8a3b720a.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | transfer, comparison, replacement, and destination element type |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MGATHER.CAS.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MGATHER_CAS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mgather_cas_32_fd8c8a3b720a);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.CAS DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT IndexTile, ExpectedTile, mask=PE_MASK
B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MGATHER.CAS.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MGATHER_CAS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MGATHER_CAS()
    => TileOperation
begin
    return TileOperation_MGATHER_CAS;
end;

pure func InstructionContractStartsTileBundle_BSTART_MGATHER_CAS()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is always encoded and selects the transfer, comparison, replacement, and destination element type.
- The completed schema requires explicit B.IOR: RegSrc0 supplies the per-PE byte-address base; RegSrc1, RegSrc2, and RegDst must encode zero. Omitted LB1 defaults to one, omitted LB2 defaults to LB0, and omitted B.DATR uses the operation defaults.
- Each IndexTile logical element is a signed or unsigned byte displacement relative to BaseGPR.

## Legality

- bstart_mgather_cas_32_fd8c8a3b720a.DataType accepts only 0..14, 16..20, and 24..28 at decode; all other encodings are reserved.
- Indexed TLSU transfer additionally rejects E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 because MGATHER.CAS carries no nibble selector.
- The body must complete the exact two-B.IOT Local schema documented by PTO-TILE-MGATHER-CAS. B.IOS and extra bindings are not accepted.
- PE_MASK=0000 is a strict no-op before all schema, GPR, source, dimension, allocation, address, and fault checks.
- IndexTile must be allocated, fully defined, generically indexable, and use S32 or U32. Each logical element is sign- or zero-extended as a byte displacement.
- B.IOR RegSrc0 supplies the per-PE byte-address base; RegSrc1, RegSrc2, and RegDst must encode zero.

## State effects

- Closes any preceding block, initializes a TileMemory descriptor, and selects TLSU function 8 with the encoded transfer DataType.
- No destination is allocated until the completed block passes schema, source, dimension, and complete access preflight.

## Memory effects and ordering

### Memory effects

- For each valid coordinate, atomically access BaseGPR plus the corresponding signed or unsigned byte displacement from IndexTile.
- All lane addresses are preflighted before the first atomic event. Duplicate-address lanes serialize in an implementation-defined order.

### Ordering

- Each valid lane is one atomic read-modify-write under the block aq/rl attributes. No fixed order is defined between duplicate-address lanes or between PEs.

## Exceptions

- Reserved DataType encodings raise Fault_IllegalInstruction before architectural effects.
- At bundle completion, malformed two-command B.IOT composition, missing B.IOR or LB0, packed transfer types, non-S32/U32 indices, mismatched source type or shape, invalid dimensions, or any read/write access fault is rejected before destination allocation, atomic events, or memory writes.

## Examples

- BSTART.MGATHER.CAS DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, ExpectedTile, mask=PE_MASK; B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
