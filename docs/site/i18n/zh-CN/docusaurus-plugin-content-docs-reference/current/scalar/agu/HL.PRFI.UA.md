<!-- GENERATED FROM: asl/scalar/agu/HL.PRFI.UA.asl -->
# HL.PRFI.UA

**Normative ASL source:** `asl/scalar/agu/HL.PRFI.UA.asl`

HL.PRFI.UA snapshots its scalar sources, forms its encoded address, and issues a non-binding 1-byte-granularity prefetch hint and publishes the effective address.

## Normative identity {#PTO-INST-SCALAR-HL-PRFI-UA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-prfi-ua-purpose role=purpose -->
## HL.PRFI.UA 的作用

`HL.PRFI.UA` 是一条独立的 `48` 位标量 AGU 指令，使用 `Immediate` 寻址，形成非绑定预取提示，但不执行架构内存访问。

<!-- PTO-READER-BLOCK: scalar-hl-prfi-ua-mechanism role=mechanism -->
## 地址与传输机制

地址路径先对 `simm17` 做符号扩展并乘以 `1`，再把位移与快照中的 `SrcL` 相加，结果按 `2^PTO_XLEN` 取模。

合法的 `model` 选择提示层级。该提示不执行地址翻译、权限检查、对齐检查、内存访问、内存事件、保留状态更新或排序边，也不保证缓存放置。

源值完成快照后，有效地址通过 `RegDst` 发布。

<!-- PTO-READER-BLOCK: scalar-hl-prfi-ua-inputs role=inputs-outputs -->
## 编码输入与输出

- `RegDst` 是一个 `5` 位字段，用来选择有效地址结果。
- `SrcL` 是一个 `5` 位字段，用来选择地址基址。
- `model` 是一个 `5` 位字段，用来选择预取提示层级。
- `simm17` 是一个 `17` 位字段，用来选择乘以 `1` 缩放因子之前的有符号位移。

<!-- PTO-READER-BLOCK: scalar-hl-prfi-ua-effects role=effects -->
## 影响与完成顺序

所有显式和隐式标量源都会在任何内存或目的位置影响之前完成快照，因此别名读取指令执行前的值。

合法提示不记录架构内存事件，也不改变保留状态。

所有结果或回写发布完成后，`HL.PRFI.UA` 把 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退休。

<!-- PTO-READER-BLOCK: scalar-hl-prfi-ua-constraints role=constraints -->
## 合法性、故障与重启

`model` 的 `0`、`1` 和 `2` 已分配；`3..31` 为保留值，并在读取源或发布地址之前选择 `Fault_IllegalInstruction`。

合法预取提示不执行架构访问，因此不会产生数据访问故障。固定位不匹配或选中的 T/U 源不可用，也会在任何影响之前被拒绝。

<!-- PTO-READER-BLOCK: scalar-hl-prfi-ua-example role=example -->
## 非规范阅读步骤

下面只说明如何使用本页，不增加指令行为。

- 从规范汇编形式 `hl.prfi.ua{.l1,.l2,.l3} [SrcL, simm], ->{t, u, Rd}` 开始，找出已编码的地址字段。
- 然后把上面的寻址模式、传输动作、完成影响和故障边界，与下方确切的生成 ASL 契约逐项对照。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.prfi.ua{.l1,.l2,.l3} [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_prfi_ua_48_c37fb30ecb0f | HL48 | 48 | 0x00007029001e / 0x0000707f003f | [{"field":"model","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_prfi_ua_48_c37fb30ecb0f | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_prfi_ua_48_c37fb30ecb0f | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_prfi_ua_48_c37fb30ecb0f | model | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_prfi_ua_48_c37fb30ecb0f | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_prfi_ua_48_c37fb30ecb0f | RegDst | 5 | 0–31 | none | none | Reg5 effective-address destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_prfi_ua_48_c37fb30ecb0f | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_prfi_ua_48_c37fb30ecb0f | model | 5 | 0–2 | none | 3–31 | cache-level hint selector | Encoded zero selects the non-binding L1 cache hint. |
| hl_prfi_ua_48_c37fb30ecb0f | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

- `hl_prfi_ua_48_c37fb30ecb0f.model` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 effective-address destination or discard |
| SrcL | Reg5 address-base source |
| model | cache-level hint selector |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.PRFI.UA.asl -->
```asl
readonly func InstructionContractOperation_HL_PRFI_UA() => ScalarOperation
begin
    return ScalarOperation_HL_PRFI_UA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.PRFI.UA.asl -->
```asl
readonly func InstructionContractHandler_HL_PRFI_UA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;

pure func InstructionContractAGUAction_HL_PRFI_UA()
    => ScalarAGUAction
begin
    return ScalarAGU_Prefetch;
end;

pure func InstructionContractAGUAddressKind_HL_PRFI_UA()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_PRFI_UA()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_PRFI_UA()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_PRFI_UA()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_PRFI_UA()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_PRFI_UA()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- model=0 selects L1, model=1 selects L2, and model=2 selects L3; the cache target is a non-binding performance hint.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 1.
- model codes 0, 1, and 2 are assigned; codes 3..31 are reserved and raise Fault_IllegalInstruction before any scalar source read or architectural effect.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
- Publish the modulo-2^PTO_XLEN effective address through the Reg5 destination after source snapshot.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- The 1-byte-granularity hint performs no architectural translation, permission or alignment check, memory access, memory event, reservation update, ordering edge, or cache-placement guarantee.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- For a legal model, form the hint, publish the optional address result, and then advance TPC by 6 bytes.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A legal prefetch model cannot raise a data-access fault. A reserved model rejects before source reads and before optional address publication.

## Examples

- hl.prfi.ua{.l1,.l2,.l3} [SrcL, simm], ->{t, u, Rd}
