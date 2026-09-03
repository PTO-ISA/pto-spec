<!-- GENERATED FROM: asl/block/attributes/B.DATR.asl -->
# B.DATR

**Normative ASL source:** `asl/block/attributes/B.DATR.asl`

Latches the optional per-block tile layout, data type, padding, comparison, rounding, saturation, and canonicalization attributes.

## Normative identity {#PTO-INST-BLOCK-B-DATR}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-datr-purpose role=purpose -->
## B.DATR 的作用

`B.DATR` 是一条 32 位 Block header 命令，用来记录可选的数据布局、数据类型、转换和数值属性。它修改待处理 Block 元数据，不会立即执行 Tile body 操作。

<!-- PTO-READER-BLOCK: block-b-datr-mechanism role=mechanism -->
## 位置与机制

该命令位于有效 Block header 中，并且在第一条 body 指令之前。重复或位置错误的使用会在待处理 header 状态变化前被拒绝。

命令被接受后，会在待处理 Block 状态中锁存一条带类型的属性记录。只有完整 header、绑定、维度和 body 满足所选操作 schema 后，该操作才会使用这些字段。

<!-- PTO-READER-BLOCK: block-b-datr-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `Layout` 选择 Tile 布局或已分配的转换布局；其确切分配域仍以下方生成契约为准。
- `DataType` 选择元素数据类型或继承哨兵；其确切分配域仍以下方生成契约为准。
- `PadValueOrByteId` 提供由操作选择的填充值或字节标识符；其确切分配域仍以下方生成契约为准。
- `CMode` 选择比较谓词；其确切分配域仍以下方生成契约为准。
- `RMode` 选择舍入模式；其确切分配域仍以下方生成契约为准。
- `Sat` 启用饱和；其确切分配域仍以下方生成契约为准。
- `Canonicalize` 启用私有格式规范化；其确切分配域仍以下方生成契约为准。

<!-- PTO-READER-BLOCK: block-b-datr-effects role=effects -->
## 待处理状态与完成

被接受的 header 命令只改变自己的待处理记录或 carrier。除非本所有者明确指出即时 header 状态更新，否则架构 Tile、Shared、GPR、内存和完成影响都推迟到完整 Block。

<!-- PTO-READER-BLOCK: block-b-datr-constraints role=constraints -->
## 合法性与故障边界

保留编码会在读取或待处理状态变化前被拒绝。位置、重复、角色或完成后 schema 不匹配，会在 body 影响前失败。

<!-- PTO-READER-BLOCK: block-b-datr-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
B.DATR {layout, datatype, padvalue_or_byteid, cmode, rmode, sat, canonicalize}
```

假设当前存在兼容的有效 header，并且之前没有冲突的 `B.DATR` 命令。把 `B.DATR {layout, datatype, padvalue_or_byteid, cmode, rmode, sat, canonicalize}` 放在下一个 header 槽，会记录该命令的待处理字段；它本身不会执行最终的 body 操作。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.DATR {layout, datatype, padvalue_or_byteid, cmode, rmode, sat, canonicalize}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_datr_32_c161a042ff38 | L32 | 32 | 0x00001023 / 0x000c707f | [{"field":"CMode","operator":"one-of","values":[0,1,2,3,4,5]},{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28,31]},{"field":"Layout","operator":"one-of","values":[0,1,3,4,6,8,9,17,18,20,21,22,23,24,25,26,27,28,29,30,31]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_datr_32_c161a042ff38 | CMode | 3 | encoding-defined | [{"instruction_lsb":29,"value_lsb":0,"width":3}] |
| b_datr_32_c161a042ff38 | PadValueOrByteId | 2 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":2}] |
| b_datr_32_c161a042ff38 | Sat | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| b_datr_32_c161a042ff38 | Canonicalize | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |
| b_datr_32_c161a042ff38 | DataType | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| b_datr_32_c161a042ff38 | RMode | 3 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":3}] |
| b_datr_32_c161a042ff38 | Layout | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Field value dispositions

### CMode (`PTO-FIELD-BLOCK-CMODE`)

Selects the comparison relation used by TCMP and TCMPS.

**Encoded zero:** Code zero selects equality comparison.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | EQ |
| 1 | assigned | NE |
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

### PadValueOrByteId (`PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID`)

Carries the operation-selected PadValue or ByteId union field.

**Encoded zero:** For PadValue operations code zero selects Zero; for ByteId operations it selects ByteId zero.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | Zero-or-ByteId0 |
| 1 | assigned | Max-or-ByteId1 |
| 2 | assigned | Min-or-ByteId2 |
| 3 | assigned | Null-or-ByteId3 |

**Reserved-value behavior:** All four encodings are assigned; the selected operation separately validates whether the field is PadValue, ByteId, or inapplicable.

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_datr_32_c161a042ff38 | CMode | 3 | 0–5 | none | 6–7 | comparison predicate selector: 0 EQ, 1 NE, 2 LT, 3 GT, 4 LE, 5 GE | EQ |
| b_datr_32_c161a042ff38 | PadValueOrByteId | 2 | 0–3 | none | none | operation-selected padding value or byte identifier | Zero padding, or ByteId zero when the selected operation interprets the union as a byte identifier |
| b_datr_32_c161a042ff38 | Sat | 1 | 0–1 | none | none | saturation enable | disabled |
| b_datr_32_c161a042ff38 | Canonicalize | 1 | 0–1 | none | none | TCVT private-format canonicalization enable | disabled |
| b_datr_32_c161a042ff38 | DataType | 5 | 0–14, 16–20, 24–28, 31 | none | 15, 21–23, 29–30 | concrete Tile element type or DTYPE_NONE inheritance sentinel | FP64; code 31, not code zero, is DTYPE_NONE |
| b_datr_32_c161a042ff38 | RMode | 3 | 0–7 | none | none | rounding selector: 0 operation default, 1 RNE, 2 RTZ, 3 RTM, 4 RTP, 5 RNA, 6 RTO, 7 RHB | operation-defined default rounding |
| b_datr_32_c161a042ff38 | Layout | 5 | 0–1, 3–4, 6, 8–9, 17–18, 20–31 | none | 2, 5, 7, 10–16, 19 | tile data layout, direct Local CUBE layout selector, or exact GM-to-CUBE/CUBE-to-GM conversion selector | NORM |

- `b_datr_32_c161a042ff38.CMode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_datr_32_c161a042ff38.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_datr_32_c161a042ff38.Layout` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| Layout | tile data layout, direct Local CUBE layout selector, or exact GM-to-CUBE/CUBE-to-GM conversion selector |
| DataType | concrete Tile element type or DTYPE_NONE inheritance sentinel |
| PadValueOrByteId | operation-selected padding value or byte identifier |
| CMode | comparison predicate selector: 0 EQ, 1 NE, 2 LT, 3 GT, 4 LE, 5 GE |
| RMode | rounding selector: 0 operation default, 1 RNE, 2 RTZ, 3 RTM, 4 RTP, 5 RNA, 6 RTO, 7 RHB |
| Sat | saturation enable |
| Canonicalize | TCVT private-format canonicalization enable |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/attributes/B.DATR.asl -->
```asl
readonly func InstructionContractMatches_B_DATR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_datr_32_c161a042ff38);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Optional header command after BSTART and before B.IOR, B.IOT, B.IOS, or the first body instruction; at most one B.DATR is permitted.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/attributes/B.DATR.asl -->
```asl
// B.DATR fields retain their operation-selected meanings. For TGPR2T,
// PadValueOrByteId is numeric U8 Zero/Max whole-tile padding, RMode[16:15]
// selects ByteOffset 0..3, and RMode[17] is reserved-zero. Null padding is
// rejected by TGPR2T before allocation or publication.
// DataType code 31 has the canonical spelling DTYPE_NONE. It is an encoded
// field sentinel, not a TileDataType. A concrete B.DATR type overrides the
// BSTART type; DTYPE_NONE preserves a concrete BSTART type and still latches
// the remaining B.DATR controls. If no concrete type can be resolved, complete
// bundle preflight raises Fault_TileLegality before allocation or effects.
readonly func InstructionContractHandler_B_DATR() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleDataAttributes;
end;

pure func InstructionContractHeaderOnly_B_DATR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractDuplicateRejects_B_DATR()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.DATR is optional. When omitted, DataType inherits the typed BSTART DataType, PadValueOrByteId supplies Null padding to pad-valued operations, and Layout, CMode, RMode, Sat, and Canonicalize retain their zero meanings. For direct Local tile operations, Layout 29 selects CUBE_M32 and Layout 31 selects CUBE_M16.
- An explicit B.DATR encodes every field. Concrete DataType codes override the BSTART type; DTYPE_NONE preserves the BSTART type while latching the remaining controls. Encoded DataType zero selects FP64 and encoded PadValueOrByteId zero selects Zero padding or ByteId zero.

## Legality

- B.DATR may appear at most once, after BSTART and before the block body.
- DataType accepts the 25 concrete TileDataType codes plus code 31 DTYPE_NONE; codes 15, 21..23, and 29..30 are reserved and reject before effects.
- Layout codes 0, 1, 3, 4, 6, 8, 9, 17, 18, 20, 21 through 29, and 30 through 31 are assigned. Codes 21 through 26 select ND2M32, ND2M16, ND2N8, M322ND, M162ND, and N82ND respectively; code 29 selects direct Local CUBE_M32 and code 31 selects direct Local CUBE_M16.
- CMode codes 0..5 select EQ, NE, LT, GT, LE, and GE respectively; codes 6..7 are reserved.
- All RMode codes 0..7 are assigned: operation default, RNE, RTZ, RTM, RTP, RNA, RTO, and RHB.
- Canonicalize is legal only for TCVT; each selected tile operation separately constrains the applicable nonzero B.DATR fields and PadValueOrByteId interpretation.

## State effects

- Latch the accepted bundle data attributes for the current block and mark B.DATR present without modifying tile or memory state.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- A duplicate B.DATR or a B.DATR outside an active block header raises Illegal Block Exception before attribute state changes.
- Reserved DataType or CMode, unassigned Layout, unsupported Layout, or operation-inapplicable nonzero fields raise an architectural fault before effects.

## Examples

- B.DATR {NORM, FP32, Zero, None, RNE, 0, 0}
- B.DATR {ND2M16, DTYPE_NONE, Null, None, Default, 0, 0}
