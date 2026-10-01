<!-- GENERATED FROM: asl/block/attributes/B.DATR.asl -->
# B.DATR

**Normative ASL source:** `asl/block/attributes/B.DATR.asl`

Latch per-block tile attributes and carrier-independent ExecutionMask controls PredInv and Zero.

## Normative identity {#PTO-INST-BLOCK-B-DATR}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-datr-purpose role=purpose -->
## B.DATR 的作用

`B.DATR`（Block 数据属性）是可选的 32 位 header 命令。它锁存 Block 的 Tile 操作要读取的数据属性：元素 `DataType`、`Layout`、`PadValueOrByteId`、比较模式 `CMode`、舍入模式 `RMode`、`Sat`、`Canonicalize`，以及两个 ExecutionMask 控制 `PredInv` 和 `Zero`。它不改变任何 Tile、寄存器或内存状态。

`B.DATR` 只记录取值。每个 Tile 操作自行决定接受哪些非零字段以及它们的含义；这些由该操作的页面列出。

<!-- PTO-READER-BLOCK: block-b-datr-mechanism role=mechanism -->
## 放置与机制

命令分派器只在 Block 处于活动状态且仍在 header 中（`BSTART` 之后、第一条 body 指令之前）时接受 `B.DATR`，并且每个 Block 只接受一次。否则引发 `Fault_BundleControl`。契约还要求 `B.DATR` 位于任何 `B.IOR`、`B.IOT` 或 `B.IOS` 之前。

写入器 `SetBundleDataAttributeState` 保存七个数据字段。随后 `SetBundleDataAttributesFromCommand` 保存 `PredInv` 与 `Zero` 并置位存在标志。见[数据属性分派模型](../model/dispatch/command-data-attributes.md)和[控制状态模型](../model/state/control-state.md)。

设计要点：取值的合法性在之后完整 Block 执行预检时才检查。`B.DATR` 在操作数绑定之前执行，因此无法知道适用哪些操作特定规则；操作 schema 会在任何目标效果之前以 `Fault_TileLegality` 拒绝不适用的非零字段。

<!-- PTO-READER-BLOCK: block-b-datr-inputs role=inputs-outputs -->
## 编码字段

- `Layout`，第 7 至 11 位：Tile 布局或布局转换。编码 0 为 `NORM`。编码 21 至 26 选择 `ND2M32`、`ND2M16`、`ND2N8`、`M322ND`、`M162ND` 和 `N82ND`。编码 29 选择直接 Local `CUBE_M32`，编码 31 选择 `CUBE_M16`。编码 10 与 11 是权重模式 `TLOAD` 布局。
- `Zero`（第 13 位）与 `PredInv`（第 14 位）：ExecutionMask 控制。第 12 位固定为一。
- `RMode`，第 15 至 17 位：编码 0 至 7 依次为操作默认、`RNE`、`RTZ`、`RTM`、`RTP`、`RNA`、`RTO` 和 `RHB`。
- `DataType`，第 20 至 24 位：编码 0 至 21 与 24 至 28 是具体元素类型，编码 31 为 `DTYPE_NONE`。编码 0 为 `FP64`。
- `Canonicalize`（第 25 位）与 `Sat`（第 26 位）。
- `PadValueOrByteId`，第 27 与 28 位：对带填充值的操作依次为 `Zero`、`Max`、`Min`、`Null`，或为字节标识符。
- `CMode`，第 29 至 31 位：编码 0 至 5 依次为 `EQ`、`NE`、`LT`、`GT`、`LE`、`GE`。

保留的 `DataType` 编码 22、23、29、30，未分配的 `Layout` 编码，以及 `CMode` 编码 6 与 7 无法译码；该命令引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: block-b-datr-effects role=effects -->
## 默认值、省略与编码零

省略 `B.DATR` 时适用 Block 复位值：`PadValueOrByteId` 读作 `Null`，`Layout`、`CMode`、`RMode`、`Sat`、`Canonicalize`、`PredInv` 与 `Zero` 读作零。元素类型来自 `BSTART` 描述符。

设计要点：显式 `B.DATR` 会编码每个字段，因此省略与编码零不同。省略时填充为 `Null`，使有效区域之外的元素保持未定义；显式编码 `00` 选择 `Zero` 填充。同样，显式 `DataType` 为 0 表示 `FP64`，而不是“继承”。

设计要点：编码 31（`DTYPE_NONE`）用于锁存其他字段而不覆盖类型。有效类型按以下顺序解析：具体的 `B.DATR` 类型，然后是具体的 `BSTART` 类型，然后（仅对 `TMOV`）是已配置源的类型。若都无法解析，完整预检引发 `Fault_TileLegality`。

在矩阵与 CUBE schema 中，两个填充位是 `CCTRL`：第 0 位选择原始部分和 `D` 输出并附带缓存替换提示，第 1 位是显式 C 的缓存使用或预取提示。省略时为 `CCTRL=00`，即最终输出路径。

<!-- PTO-READER-BLOCK: block-b-datr-constraints role=constraints -->
## 合法性与故障

- 放置错误或重复的 `B.DATR` 在锁存字段改变之前引发 `Fault_BundleControl`。
- 只有当完整 Block 为合格的 Local `CUBE_M16` 或 `CUBE_M32` 操作绑定了显式 ExecutionMask 时，非零 `PredInv` 或 `Zero` 才合法。否则预检引发 `Fault_TileLegality`。
- `Canonicalize` 只被 `TCVT` 接受。对于 `CUBE_M16` 或 `CUBE_M32` 上的 `TROWEXPAND` 及其七个算术变体，`RMode` 是 `BroadcastByteOffset`；`RowMajor` 要求为零。
- 所选操作不接受的任何其他非零字段都会在效果之前引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: block-b-datr-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
B.DATR {NORM, FP32, Zero, None, RNE, 0, 0, 0, 0}
B.DATR {ND2M16, DTYPE_NONE, Null, None, Default, 0, 0, 0, 0}
```

第一行用 `FP32` 覆盖 `BSTART` 类型，选择 `Zero` 填充，并请求 `RNE` 舍入。像 `TADD` 这样只接受 `PadValueOrByteId` 与 `Layout` 为非零字段的操作，会在预检时以 `Fault_TileLegality` 拒绝该 `RNE` 编码。第二行通过 `DTYPE_NONE` 保留 `BSTART` 类型，选择 GM 到 `CUBE_M16` 的转换（编码 22），并保持填充为 `Null`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.DATR {layout, datatype, padvalue_or_byteid, cmode, rmode, sat, canonicalize, predinv, zero}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_datr_32_c161a042ff38 | L32 | 32 | 0x00001023 / 0x000c107f | [{"field":"CMode","operator":"one-of","values":[0,1,2,3,4,5]},{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,24,25,26,27,28,31]},{"field":"Layout","operator":"one-of","values":[0,1,3,4,6,8,9,10,11,17,18,20,21,22,23,24,25,26,27,28,29,30,31]}] |

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
| b_datr_32_c161a042ff38 | PredInv | 1 | encoding-defined | [{"instruction_lsb":14,"value_lsb":0,"width":1}] |
| b_datr_32_c161a042ff38 | Zero | 1 | encoding-defined | [{"instruction_lsb":13,"value_lsb":0,"width":1}] |

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
| 15 | assigned | E6M2 |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | assigned | RCPE6M2 |
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
| b_datr_32_c161a042ff38 | PadValueOrByteId | 2 | 0–3 | none | none | operation-selected padding value, byte identifier, or matrix CCTRL raw-partial/cache-hint control | Zero padding, ByteId zero, or matrix CCTRL=00 as selected by the operation schema |
| b_datr_32_c161a042ff38 | Sat | 1 | 0–1 | none | none | saturation enable | disabled |
| b_datr_32_c161a042ff38 | Canonicalize | 1 | 0–1 | none | none | TCVT private-format canonicalization enable | disabled |
| b_datr_32_c161a042ff38 | DataType | 5 | 0–21, 24–28, 31 | none | 22–23, 29–30 | concrete Tile element type or DTYPE_NONE inheritance sentinel | FP64; code 31, not code zero, is DTYPE_NONE |
| b_datr_32_c161a042ff38 | RMode | 3 | 0–7 | none | none | operation-specific selector: numeric rounding where applicable; BroadcastByteOffset for TROWEXPAND* on CUBE_M16/CUBE_M32 | Operation-defined default; row-expansion CUBE_M16/M32 uses zero BroadcastByteOffset, and other operations keep their existing zero meaning. |
| b_datr_32_c161a042ff38 | Layout | 5 | 0–1, 3–4, 6, 8–11, 17–18, 20–31 | none | 2, 5, 7, 12–16, 19 | tile data layout, direct Local CUBE layout selector, or exact GM-to-CUBE/CUBE-to-GM conversion selector | NORM |
| b_datr_32_c161a042ff38 | PredInv | 1 | 0–1 | none | none | ExecutionMask polarity control: zero preserves, one inverts the logical predicate | Normal ExecutionMask polarity; zero means do not invert. |
| b_datr_32_c161a042ff38 | Zero | 1 | 0–1 | none | none | inactive ExecutionMask destination policy: zero MERGE, one ZERO | MERGE inactive-destination policy; zero preserves the prior destination coordinate. |

- `b_datr_32_c161a042ff38.CMode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_datr_32_c161a042ff38.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_datr_32_c161a042ff38.Layout` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| Layout | tile data layout, direct Local CUBE layout selector, or exact GM-to-CUBE/CUBE-to-GM conversion selector |
| DataType | concrete Tile element type or DTYPE_NONE inheritance sentinel |
| PadValueOrByteId | operation-selected padding value, byte identifier, or matrix CCTRL raw-partial/cache-hint control |
| CMode | comparison predicate selector: 0 EQ, 1 NE, 2 LT, 3 GT, 4 LE, 5 GE |
| RMode | operation-specific selector: numeric rounding where applicable; BroadcastByteOffset for TROWEXPAND* on CUBE_M16/CUBE_M32 |
| Sat | saturation enable |
| Canonicalize | TCVT private-format canonicalization enable |
| PredInv | ExecutionMask polarity control: zero preserves, one inverts the logical predicate |
| Zero | inactive ExecutionMask destination policy: zero MERGE, one ZERO |

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
// B.DATR fields retain their operation-selected meanings. Bits [14:13] encode
// carrier-independent ExecutionMask controls PredInv and Zero; bit 12 remains
// fixed. Omission supplies both as zero. Nonzero controls are legal only when
// an eligible Local CUBE_M16/CUBE_M32 complete operation schema binds an
// explicit ExecutionMask. For matrix/CUBE
// operation schemas, PadValueOrByteId is selected as CCTRL[1:0]: CCTRL[0]
// selects raw-partial D plus a cache-replacement hint and CCTRL[1] is an
// explicit-C cache-use/prefetch hint; omission selects 00. For TGPR2T,
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

- B.DATR is optional. When omitted, DataType inherits the typed BSTART DataType, PadValueOrByteId supplies Null padding to pad-valued operations, and Layout, CMode, RMode, Sat, Canonicalize, PredInv, and Zero retain their zero meanings. For direct Local tile operations, Layout 29 selects CUBE_M32 and Layout 31 selects CUBE_M16.
- An explicit B.DATR encodes every field. Concrete DataType codes override the BSTART type; DTYPE_NONE preserves the BSTART type while latching the remaining controls. Encoded DataType zero selects FP64 and encoded PadValueOrByteId zero selects Zero padding or ByteId zero.
- For matrix/CUBE schemas, omitted PadValueOrByteId selects CCTRL=00: final D output and no transparent-cache hint.
- For an eligible Local CUBE_M16/CUBE_M32 operation with an explicit ExecutionMask, PredInv=0 selects normal mask polarity and Zero=0 selects MERGE for inactive destinations. Nonzero PredInv or Zero without an explicit eligible ExecutionMask is illegal.
- For TROWEXPAND* with direct Local CUBE_M16 or CUBE_M32, RMode[2:0] defaults to zero and names BroadcastByteOffset; it is not numeric rounding in that operation context. Other operations retain their current RMode meaning.

## Legality

- B.DATR may appear at most once, after BSTART and before the block body.
- DataType accepts the 27 concrete TileDataType codes plus code 31 DTYPE_NONE; codes 22, 23, and 29..30 are reserved and reject before effects.
- Layout codes 0, 1, 3, 4, 6, 8, 9, 10, 11, 17, 18, 20, 21 through 29, and 30 through 31 are assigned. Codes 10 and 11 are weight-mode TLOAD-only layouts; codes 21 through 26 select ND2M32, ND2M16, ND2N8, M322ND, M162ND, and N82ND respectively; code 29 selects direct Local CUBE_M32 and code 31 selects direct Local CUBE_M16.
- CMode codes 0..5 select EQ, NE, LT, GT, LE, and GE respectively; codes 6..7 are reserved.
- All RMode codes 0..7 are assigned: operation default, RNE, RTZ, RTM, RTP, RNA, RTO, and RHB.
- Canonicalize is legal only for TCVT; each selected tile operation separately constrains the applicable nonzero B.DATR fields and PadValueOrByteId interpretation.
- Matrix/CUBE schemas interpret PadValueOrByteId as CCTRL: bit 0 selects raw-partial D plus a cache-replacement hint, bit 1 is an ACC-only explicit-C cache-use or prefetch hint, and init=1 forms require bit 1 to be zero.
- PredInv and Zero are legal only for eligible Local CUBE_M16/CUBE_M32 schemas that bind an explicit ExecutionMask; otherwise either nonzero control rejects before effects. Bit 12 remains fixed at one.
- TROWEXPAND, TROWEXPANDADD, TROWEXPANDSUB, TROWEXPANDMUL, TROWEXPANDDIV, TROWEXPANDMAX, TROWEXPANDMIN, and TROWEXPANDEXPDIF interpret RMode[2:0] as BroadcastByteOffset only for CUBE_M16/CUBE_M32; RowMajor requires zero. Other operation-specific RMode rules are unchanged.

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
- PredInv=1 or Zero=1 on a schema without an explicit eligible Local CUBE_M16/CUBE_M32 ExecutionMask raises Fault_TileLegality before effects.

## Examples

- B.DATR {NORM, FP32, Zero, None, RNE, 0, 0, 0, 0}
- B.DATR {ND2M16, DTYPE_NONE, Null, None, Default, 0, 0, 0, 0}
