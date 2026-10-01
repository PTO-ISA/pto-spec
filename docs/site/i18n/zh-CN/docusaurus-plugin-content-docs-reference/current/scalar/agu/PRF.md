<!-- GENERATED FROM: asl/scalar/agu/PRF.asl -->
# PRF

**Normative ASL source:** `asl/scalar/agu/PRF.asl`

PRF snapshots its scalar sources, forms its encoded address, and issues a non-binding 1-byte-granularity prefetch hint with no destination effect.

## Normative identity {#PTO-INST-SCALAR-PRF}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-prf-purpose role=purpose -->
## `PRF` 做什么

`PRF` 形成与 `LW` 同类别的字节地址——基址寄存器加经过转换并移位的寄存器偏移量——并为其发出非绑定的预取提示。其规范汇编是 `prf [SrcL, SrcR<{.sw,.uw}><<<shamt>]`，且不暴露任何目的端。

设计要点：提示是非绑定的，因此 `PRF` 永远不会引发数据访问故障。对未对齐、未映射或超出范围地址的提示，与对有效地址的提示一样正常退休，软件在发出提示前无需自行做可访问性测试。

<!-- PTO-READER-BLOCK: scalar-prf-mechanism role=mechanism -->
## `PRF` 如何形成地址并发出提示

`SrcL` 作为基址被读取。`SrcR` 由 `SrcRType` 转换——`0` 保留完整的 `64` 位值，`1` 符号扩展低 `32` 位，`2` 零扩展低 `32` 位——并按编码的 `shamt` 左移。偏移量与基址按 `2^PTO_XLEN` 取模相加。

形成的地址被交给提示，随后被丢弃。没有任何编码字段发布它，因此既没有结果可读，也没有基址回写可观察。

设计要点：即使提示没有结果，偏移量转换在架构上仍有定义。仅在 `SrcRType` 或 `shamt` 上不同的两个提示指向不同地址；这一差别只是在任何架构状态中都不可见。

<!-- PTO-READER-BLOCK: scalar-prf-inputs role=inputs-outputs -->
## 编码字段与提示消费的内容

- `SrcL` 与 `SrcR` 是 `5` 位 Reg5 源。编码 `0`..`23` 命名绝对 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。读取 `T` 或 `U` 槽位既不消费也不重排它，编码 `0` 提供恒为零的 GPR。
- `SrcRType` 的 `0`、`1`、`2` 均已分配；原始值 `3` 为保留值。`shamt` 的全部 `32` 个值 `0`..`31` 均已分配，编码为零时不执行移位。
- `RegDst` 保留在编码中，但不命名任何目的端。编码 `0`..`31` 全部合法，它们都不写GPR、不压入队列槽位，规范汇编也不暴露目的端。

设计要点：由于 `RegDst` 是别名而非目的端，该字段中的编码 `0` 也不是丢弃选择子。该字段在任何取值下都没有效果，实现也无法把它变成一次队列压入。

<!-- PTO-READER-BLOCK: scalar-prf-effects role=effects -->
## 影响、顺序与完成

两次源读取都发生在提示之前，因此地址反映的是 `SrcL` 与 `SrcR` 在执行前的值。

成功执行不改变任何架构状态：没有内存字节、没有保留项、没有队列项，也没有寄存器变化。随后 `TPC` 前移 `4` 字节，即本编码的长度。

设计要点：合法提示不记录内存事件，也不产生顺序边，因此它无法让更早或更晚的访问观察到任何东西。`PRF` 之后唯一的架构差别就是 `TPC` 已经移动。

<!-- PTO-READER-BLOCK: scalar-prf-constraints role=constraints -->
## 合法性、故障与重启

当固定比特不匹配、`SrcRType` 取保留值 `3`，或所选 `T`/`U` 源槽位因从未被压入而不可用时，分派会在任何效果之前以 `Fault_IllegalInstruction` 拒绝该指令。

合法的 `PRF` 不执行对齐测试、不翻译，也不做权限或有界内存测试。对合法编码而言，`Fault_DataAlignment` 与 `Fault_DataPage` 都不可达。

拒绝发生在地址形成之前，因此被拒绝的尝试没有部分效果，`TPC` 停在故障指令上；重发会重复同样的编码检查。

设计要点：本形式让 `TPC` 保持不动的唯一途径是编码拒绝，因为合法路径没有故障结果。被拒绝的提示不产生任何提示，从而保持非绑定契约完整。

<!-- PTO-READER-BLOCK: scalar-prf-example role=example -->
## 完整读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 取 `prf [2, 3<.sw><<<3]`，设 GPR2 = `0x2000`，GPR3 = `0xFFFFFFFE`。
- `SrcRType=1` 符号扩展低 `32` 位，得 `-2`；`shamt=3` 再左移 `3` 位，得 `-16`。
- 提示地址是 `0x2000` 减 `16`，即 `0x1FF0`。指令形成该地址后将其丢弃。
- 寄存器、队列槽位、内存字节与保留项都不变；唯一的架构差别是 `TPC` 前移了 `4` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
prf [SrcL, SrcR<{.sw,.uw}><<<shamt>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| prf_32_30e6dfe4e3ce | L32 | 32 | 0x00007009 / 0x0000707f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| prf_32_30e6dfe4e3ce | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| prf_32_30e6dfe4e3ce | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| prf_32_30e6dfe4e3ce | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| prf_32_30e6dfe4e3ce | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| prf_32_30e6dfe4e3ce | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| prf_32_30e6dfe4e3ce | RegDst | 5 | 0–31 | none | none | ignored encoded alias field | Encoded zero is the canonical ignored alias value and names no destination. |
| prf_32_30e6dfe4e3ce | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| prf_32_30e6dfe4e3ce | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| prf_32_30e6dfe4e3ce | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| prf_32_30e6dfe4e3ce | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `prf_32_30e6dfe4e3ce.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | ignored encoded alias field |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/PRF.asl -->
```asl
readonly func InstructionContractOperation_PRF() => ScalarOperation
begin
    return ScalarOperation_PRF;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/PRF.asl -->
```asl
readonly func InstructionContractHandler_PRF()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;

pure func InstructionContractAGUAction_PRF()
    => ScalarAGUAction
begin
    return ScalarAGU_Prefetch;
end;

pure func InstructionContractAGUAddressKind_PRF()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_PRF()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_PRF()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_PRF()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_PRF()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_PRF()
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
- Every encoded RegDst value is an assigned non-writing alias. Canonical assembly uses zero and does not expose a destination.
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- Discard the formed address after issuing the non-binding hint; no encoded field publishes a result.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- The 1-byte-granularity hint performs no architectural translation, permission or alignment check, memory access, memory event, reservation update, ordering edge, or cache-placement guarantee.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- For a legal model, form the hint, publish the optional address result, and then advance TPC by 4 bytes.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A legal prefetch model cannot raise a data-access fault. A reserved model rejects before source reads and before optional address publication.

## Examples

- prf [SrcL, SrcR<{.sw,.uw}><<<shamt>]
