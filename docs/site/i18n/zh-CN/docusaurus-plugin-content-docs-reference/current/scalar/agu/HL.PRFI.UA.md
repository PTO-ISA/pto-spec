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
## `HL.PRFI.UA` 做什么

`HL.PRFI.UA` 是一条独立的 `48` 位标量 AGU 指令，它用立即数位移发出一个非绑定的 1 字节粒度预取提示，并把它形成的有效地址发布出去。

规范汇编形式是 `hl.prfi.ua{.l1,.l2,.l3} [SrcL, simm], ->{t, u, Rd}`。`.l1`、`.l2` 与 `.l3` 后缀选择由 `model` 字段命名的层级。

设计要点：本形式是立即数提示中同时返回自身求和结果的那一个。保留地址让一条指令既能指向某行，又能把下一个指针交给遍历，无需重新计算同样的加法。后缀 `.ua` 标记在未缩放立即数之上被发布的地址。

<!-- PTO-READER-BLOCK: scalar-hl-prfi-ua-mechanism role=mechanism -->
## 地址与传输如何形成

符号扩展后的 `simm17` 按 `2^PTO_XLEN` 取模加到 `SrcL` 的快照上。缩放因子是 `1`：编码值就是字节距离，而不是单元个数。这个和既是被提示的地址，也是被发布的结果。

随后模型只做地址形成，别的什么都不做：没有翻译，没有对齐或权限检查，没有内存访问，没有内存事件，也没有保留或顺序影响。

设计要点：因为预取路径从不探测地址，指向允许区域之外的提示不构成故障。被发布的值是一次计算，并不能证明任何数据被取回。

<!-- PTO-READER-BLOCK: scalar-hl-prfi-ua-inputs role=inputs-outputs -->
## 编码字段与结果

- `SrcL` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `simm17` 是有符号 `17` 位位移，在编码中由两段承载，即第 `36`..`47` 位与第 `6`..`10` 位，覆盖 `-65536`..`65535` 字节。
- `model` 是 `5` 位选择子。取值 `0` 命名 `L1`，`1` 命名 `L2`，`2` 命名 `L3`；取值 `3`..`31` 为保留值。
- `RegDst` 是接收所形成地址的 `5` 位选择子。编码 `1`..`23` 写入绝对 GPR，编码 `30` 压入 `U`，编码 `31` 压入 `T`，编码 `0` 与 `24`..`29` 丢弃它。

设计要点：保留的 `model` 取值在源被读取之前、在 `RegDst` 被写入之前就被拒绝，因此被拒绝的提示会让目的位置保持原样。

<!-- PTO-READER-BLOCK: scalar-hl-prfi-ua-effects role=effects -->
## 影响、顺序与完成

所有标量源都在目的位置被写入之前取快照，因此指定 `SrcL` 的目的位置仍然为被提示的地址贡献指令执行前的基址。

该提示不记录内存事件，不改变任何内存字节，也不触碰保留状态与顺序。

地址结果发布之后 `TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：目的位置只在发布步骤写入一次，因此这个值不可能是指令执行前基址与执行后基址的混合。被拒绝之后重试时，起点是同一份寄存器状态。

<!-- PTO-READER-BLOCK: scalar-hl-prfi-ua-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配，或源编码选中不可用的 `T` 或 `U` 槽位，会在任何指令影响之前引发 `Fault_IllegalInstruction`。

保留的 `model` 取值会在源被读取之前、在任何地址被发布之前引发 `Fault_IllegalInstruction`。

合法的提示不会引发数据访问故障。恢复会完整重新执行：快照、地址形成与发布都会重新计算，不保留任何进度。

设计要点：立即数不与任何范围比较，因为有符号 `17` 位的每个取值都已分配，因此没有任何立即数取值会成为提示被拒绝的理由。只有固定位、`model` 字段与源编码能够拒绝。

<!-- PTO-READER-BLOCK: scalar-hl-prfi-ua-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.prfi.ua.l3 [6, -64], ->20`，GPR6 = `0x1000`。
- 缩放因子是 `1`，因此字节位移是 `-64`，被提示的地址是 `0x0FC0`。
- `model` 是 `2`，因此 `.l3` 后缀与编码字段在 `L3` 层级上一致。
- GPR20 收到 `0x0FC0`，`TPC` 变为该指令地址加 `6`。
- 之后通过 GPR20 发起的加载仍会自行做预检，仍可能引发故障。
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
