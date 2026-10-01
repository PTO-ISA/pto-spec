<!-- GENERATED FROM: asl/scalar/agu/HL.SWP.asl -->
# HL.SWP

**Normative ASL source:** `asl/scalar/agu/HL.SWP.asl`

HL.SWP snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 4-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-SWP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-swp-purpose role=purpose -->
## `HL.SWP` 的作用

`HL.SWP` 把来自 `SrcD` 与 `SrcD1` 的两个相邻 `4` 字节小端单元存储到 `SrcL` 基址加上（在相加之前左移 `2` 位的）`SrcR` 索引处。

规范汇编是 `hl.swp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}><<2]`。

设计要点：固定的 `2` 位移使一个索引单位对应一个 `4` 字节元素，因此索引加 `1` 会把这一对的基址移到前一对的第二个元素上。

<!-- PTO-READER-BLOCK: scalar-hl-swp-mechanism role=mechanism -->
## 两个地址与传输如何形成

偏移量是 `LSL(Modify(SrcR, SrcRType), 2)`，与 `SrcL` 快照按模 `2^PTO_XLEN` 相加。第一个地址是基址加该偏移量，第二个地址是第一个地址加 `4`。

两个地址在任何存储发起之前都经过预检。两次预检都通过后，读取 `SrcD` 与 `SrcD1`，并按地址顺序提交两次 relaxed `4` 字节存储。

本编码没有目的端字段，因此计算出的地址不会发布到任何地方。

设计要点：该移位还意味着相邻索引值访问的是相互重叠的对，因此需要两个索引单位才能越过一整对。

<!-- PTO-READER-BLOCK: scalar-hl-swp-inputs role=inputs-outputs -->
## 编码字段与角色

- `SrcD` 与 `SrcD1` 提供被存储的两个单元。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `SrcL` 是基址，`SrcR` 是索引。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `SrcRType` 选择不变、`.sw` 或 `.uw`；原始值 `3` 保留，并在合法性阶段被拒绝。
- 设计要点：移位后的索引可以来自队列条目，因此由先前指令计算出的对的基址可以直接使用，无需 GPR 拷贝。

<!-- PTO-READER-BLOCK: scalar-hl-swp-effects role=effects -->
## 效果、顺序与完成

所有源在第一次存储之前取快照，因此两个单元与两个地址都来自指令执行前的寄存器值。

成功时写入两个相邻的 `4` 字节范围，按地址顺序记录两个 relaxed 存储事件，并使 `TPC` 前进 `6` 字节。

设计要点：重叠的保留按每个所存范围分别作废，因此即使这一对只有一个单元触及保留粒度，仍会使其作废。

<!-- PTO-READER-BLOCK: scalar-hl-swp-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配、`SrcRType` 取保留值 `3` 或所选 `T`/`U` 源不可用，都会在读取索引、基址或数据之前引发 `Fault_IllegalInstruction`。
- 任一地址不是 `4` 的倍数时，会在任何存储之前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在失败的那个地址处引发 `Fault_DataPage`。
- 故障不记录事件、不写任何单元，并让 `TPC` 停留在引发故障的指令上以便完整重发。
- 设计要点：`SrcRType` 为 `1` 或 `2` 时，索引在移位之前被替换为 `32` 位扩展值，因此由转换决定这一对基址的符号，而移位只负责缩放。

<!-- PTO-READER-BLOCK: scalar-hl-swp-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 当 `SrcL` = `0x3000`、`SrcR` = `1`、`SrcRType` 为 `0` 时，偏移量是 `4`，地址是 `0x3004` 与 `0x3008`。
- 当 `SrcR` = `2` 时偏移量是 `8`，因此这一对起始于前一对的第二个单元处。
- `SrcRType` 为 `3` 会在读取任何源之前被拒绝，因此根本不会形成地址。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.swp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}><<2]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_swp_48_d0efe96e09f0 | HL48 | 48 | 0x00002049001e / 0x00007ffff83f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_swp_48_d0efe96e09f0 | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_swp_48_d0efe96e09f0 | SrcD1 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_swp_48_d0efe96e09f0 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_swp_48_d0efe96e09f0 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_swp_48_d0efe96e09f0 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_swp_48_d0efe96e09f0 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_swp_48_d0efe96e09f0 | SrcD1 | 5 | 0–31 | none | none | Reg5 second store-data source | Encoded zero reads the architectural zero GPR. |
| hl_swp_48_d0efe96e09f0 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_swp_48_d0efe96e09f0 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_swp_48_d0efe96e09f0 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `hl_swp_48_d0efe96e09f0.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcD1 | Reg5 second store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SWP.asl -->
```asl
readonly func InstructionContractOperation_HL_SWP() => ScalarOperation
begin
    return ScalarOperation_HL_SWP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SWP.asl -->
```asl
readonly func InstructionContractHandler_HL_SWP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;

pure func InstructionContractAGUAction_HL_SWP()
    => ScalarAGUAction
begin
    return ScalarAGU_StorePair;
end;

pure func InstructionContractAGUAddressKind_HL_SWP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_SWP()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_SWP()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_SWP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SWP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SWP()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 is reserved. Encoded shamt zero performs no shift.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 2) and add it modulo 2^PTO_XLEN to the SrcL base.
- The pair addresses are address and address plus 4; the instruction performs no base writeback.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 4-byte addresses before either store; on success record two relaxed store events in address order.
- Successful overlapping stores invalidate an overlapping reservation only after complete pair preflight.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 4-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.swp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}><<2]
