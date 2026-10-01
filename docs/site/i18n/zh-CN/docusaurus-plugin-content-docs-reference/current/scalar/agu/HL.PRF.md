<!-- GENERATED FROM: asl/scalar/agu/HL.PRF.asl -->
# HL.PRF

**Normative ASL source:** `asl/scalar/agu/HL.PRF.asl`

HL.PRF snapshots its scalar sources, forms its encoded address, and issues a non-binding 1-byte-granularity prefetch hint with no destination effect.

## Normative identity {#PTO-INST-SCALAR-HL-PRF}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-prf-purpose role=purpose -->
## `HL.PRF` 做什么

`HL.PRF` 是一条独立的 `48` 位标量 AGU 指令，它发出一个非绑定的 1 字节粒度预取提示，且不发布结果。

规范汇编形式是 `hl.prf{.l1,.l2,.l3} [SrcL, SrcR<{.sw,.uw}><<<shamt>]`。`.l1`、`.l2` 与 `.l3` 后缀选择由 `model` 字段命名的层级。

设计要点：本编码完全没有目的字段，因此有效地址形成之后即被丢弃。如果程序还需要它所提示的那个地址，必须用一次普通加法重新算出同样的和，因为本指令无法把它交还。

<!-- PTO-READER-BLOCK: scalar-hl-prf-mechanism role=mechanism -->
## 地址与传输如何形成

`SrcRType` 变换 `SrcR` 的快照，`shamt` 移位该结果，移位后的值按 `2^PTO_XLEN` 取模加到 `SrcL` 的快照上。这个和就是被提示的地址。

随后模型只做地址形成，别的什么都不做：没有翻译，没有对齐或权限检查，没有内存访问，没有内存事件，也没有保留或顺序影响。`model` 命名的层级只是一个提示，不是一次分配。

设计要点：因为预取路径从不探测地址，指向允许区域之外的提示不构成故障。执行成功在架构上可见的结果只有 `TPC` 前进 `6` 字节，以及源寄存器保持原值。

<!-- PTO-READER-BLOCK: scalar-hl-prf-inputs role=inputs-outputs -->
## 编码字段与结果

- `SrcL` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcR` 作为寄存器偏移源，使用同样的 `5` 位 Reg5 域。
- `SrcRType` 是 `2` 位寄存器偏移变换选择子。原始值 `00` 保持整个 `SrcR` 值不变，`01` 用其低 `32` 位的有符号读法替换它，`10` 用这些位的无符号读法替换它，`11` 为保留值。
- `shamt` 是变换之后施加的 `5` 位无符号移位量；编码零表示不移位。
- `model` 是 `5` 位选择子。取值 `0` 命名 `L1`，`1` 命名 `L2`，`2` 命名 `L3`；取值 `3`..`31` 为保留值。
- 本形式没有任何字段接收值，因此该指令没有架构结果。

设计要点：保留的 `model` 取值在源被读取之前就被拒绝，因此一条没有命名合法层级的指令既不会消耗 `T` 或 `U` 条目，也不会改变程序能观察到的任何东西。

<!-- PTO-READER-BLOCK: scalar-hl-prf-effects role=effects -->
## 影响、顺序与完成

所有标量源都在任何影响之前取快照，因此用于提示的基址与偏移值都是指令执行前的值。

该提示不记录内存事件，不改变任何内存字节，也不触碰保留状态与顺序。本形式不写入任何寄存器。

`TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：因为没有目的位置，该指令完全没有架构结果，所以执行成功唯一可观察的后果就是 `TPC` 前进 `6` 字节。

<!-- PTO-READER-BLOCK: scalar-hl-prf-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配，或源编码选中不可用的 `T` 或 `U` 槽位，会在任何指令影响之前引发 `Fault_IllegalInstruction`。

保留的 `model` 取值会在源被读取之前、在任何地址被形成以供使用之前引发 `Fault_IllegalInstruction`。

合法的提示不会引发数据访问故障。恢复会完整重新执行：快照与地址形成都会重新计算，不保留任何进度。

设计要点：保留的 `model` 与不可用的队列源引发同一个故障，并且都在任何读取之前判定，因此一次失败的预取既不能消耗队列条目，也不能作用于只形成了一半的地址。

<!-- PTO-READER-BLOCK: scalar-hl-prf-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.prf.l2 [4, 8<<1]`，GPR4 = `0x4000`，GPR8 = `0x10`。
- `SrcRType` 是 `00`，因此偏移是 `0x10`，保持不变；`shamt` 是 `1`，因此它变为 `0x20`，被提示的地址是 `0x4020`。
- `model` 是 `1`，因此 `.l2` 后缀与编码字段在 `L2` 层级上一致。
- 不写入任何寄存器，不记录内存事件，`TPC` 变为该指令地址加 `6`。
- 之后对 `0x4020` 的加载会自行做预检，仍可能引发故障；那时本指令早已退休。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.prf{.l1,.l2,.l3} [SrcL, SrcR<{.sw,.uw}><<<shamt>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_prf_48_39641863bb21 | HL48 | 48 | 0x00007009000e / 0x00007fff07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]},{"field":"model","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_prf_48_39641863bb21 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_prf_48_39641863bb21 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_prf_48_39641863bb21 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_prf_48_39641863bb21 | model | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_prf_48_39641863bb21 | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_prf_48_39641863bb21 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_prf_48_39641863bb21 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_prf_48_39641863bb21 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_prf_48_39641863bb21 | model | 5 | 0–2 | none | 3–31 | cache-level hint selector | Encoded zero selects the non-binding L1 cache hint. |
| hl_prf_48_39641863bb21 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_prf_48_39641863bb21.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `hl_prf_48_39641863bb21.model` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| model | cache-level hint selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.PRF.asl -->
```asl
readonly func InstructionContractOperation_HL_PRF() => ScalarOperation
begin
    return ScalarOperation_HL_PRF;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.PRF.asl -->
```asl
readonly func InstructionContractHandler_HL_PRF()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;

pure func InstructionContractAGUAction_HL_PRF()
    => ScalarAGUAction
begin
    return ScalarAGU_Prefetch;
end;

pure func InstructionContractAGUAddressKind_HL_PRF()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_PRF()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_PRF()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_PRF()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_PRF()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_PRF()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 is reserved. Encoded shamt zero performs no shift.
- model=0 selects L1, model=1 selects L2, and model=2 selects L3; the cache target is a non-binding performance hint.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.
- model codes 0, 1, and 2 are assigned; codes 3..31 are reserved and raise Fault_IllegalInstruction before any scalar source read or architectural effect.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- Discard the formed address after issuing the non-binding hint; no encoded field publishes a result.
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

- hl.prf{.l1,.l2,.l3} [SrcL, SrcR<{.sw,.uw}><<<shamt>]
