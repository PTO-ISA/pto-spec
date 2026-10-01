<!-- GENERATED FROM: asl/scalar/agu/LHU.asl -->
# LHU

**Normative ASL source:** `asl/scalar/agu/LHU.asl`

LHU snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-LHU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lhu-purpose role=purpose -->
## `LHU` 的作用

`LHU` 从索引地址加载一个无符号 `2` 字节小端半字。加载到的半字做零扩展，因此目的端持有 `0`..`65535` 范围内的值。

规范汇编是 `lhu [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}`。

设计要点：`LHU` 不产生符号位，因此成功加载后 `RegDst` 第 `16` 位及以上始终为 `0`；经 `LHU` 读到的半字绝不会看起来像负数。

<!-- PTO-READER-BLOCK: scalar-lhu-mechanism role=mechanism -->
## 地址与传输如何形成

索引是 `SrcR` 经 `SrcRType` 转换后按 `shamt` 左移的值，再与 `SrcL` 快照按模 `2^PTO_XLEN` 相加。转换在移位之前替换整个索引字。

预检依次执行 `2` 字节对齐检查、转换、权限与有界内存检查。成功后小端读取 `2` 字节并记录一个 relaxed 加载事件。

该半字被零扩展到 `PTO_XLEN` 并通过 `RegDst` 发布；基址寄存器保持原值。

设计要点：编码的 `shamt` 与访问宽度无关，因此 `LHU` 可以遍历步长为 `2^shamt` 字节、而非恰好 `2` 字节的表。

<!-- PTO-READER-BLOCK: scalar-lhu-inputs role=inputs-outputs -->
## 编码字段与角色

- `SrcL` 是基址选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `SrcR` 是索引选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `SrcRType` 分配了 `0`、`1`、`2` 并保留 `3`；`shamt` 覆盖 `0`..`31`。
- `RegDst` 是目的端选择子。编码 `1`..`23` 写 GPR，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`0` 与 `24`..`29` 不发布任何结果；编码 `0` 是架构零寄存器，其写入被丢弃。
- 设计要点：由于索引可以是队列条目，半字表的基址或索引可以直接来自 `T` 或 `U` 队列，无需GPR 拷贝。

<!-- PTO-READER-BLOCK: scalar-lhu-effects role=effects -->
## 效果、顺序与完成

所有源都在内存操作之前取快照，因此源与 `RegDst` 之间的别名不会改变地址或读到的值。

成功时记录一个 relaxed 加载事件，不改变任何内存字节，保留保持不变，发布零扩展后的半字，并使 `TPC` 前进 `4` 字节。

设计要点：成功时只有目的端发生变化；内存、保留以及所有其他寄存器都保持指令执行前的值。

<!-- PTO-READER-BLOCK: scalar-lhu-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配、`SrcRType` 取保留值或所选 `T`/`U` 源不可用，都会在形成地址之前引发 `Fault_IllegalInstruction`。
- 奇数之和会在转换之前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始有效地址处引发 `Fault_DataPage`。
- 故障不记录事件，不向 `RegDst` 发布结果，并让 `TPC` 停留在引发故障的指令上，使尝试可以重发。
- 设计要点：`shamt` 为 `0` 时地址的奇偶性由基址与索引共同决定，因此奇数基址配奇数索引仍然可用。

<!-- PTO-READER-BLOCK: scalar-lhu-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 当 `SrcL` = `0x100`、`SrcR` = `2`、`shamt` 为 `0`、`SrcRType` 为 `0` 时，地址是 `0x102`，满足 `2` 字节对齐。
- `0x102` 处的字节 `00 80` 是半字 `0x8000`，`LHU` 将其发布为 `0x8000`。
- `shamt` 为 `0` 而索引为 `1` 时会得到 `0x101`，即奇数地址，因此会改为引发 `Fault_DataAlignment`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lhu [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lhu_32_730caf67ecd1 | L32 | 32 | 0x00005009 / 0x0000707f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lhu_32_730caf67ecd1 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lhu_32_730caf67ecd1 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lhu_32_730caf67ecd1 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lhu_32_730caf67ecd1 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| lhu_32_730caf67ecd1 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lhu_32_730caf67ecd1 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lhu_32_730caf67ecd1 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lhu_32_730caf67ecd1 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| lhu_32_730caf67ecd1 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| lhu_32_730caf67ecd1 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `lhu_32_730caf67ecd1.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LHU.asl -->
```asl
readonly func InstructionContractOperation_LHU() => ScalarOperation
begin
    return ScalarOperation_LHU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LHU.asl -->
```asl
readonly func InstructionContractHandler_LHU()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LHU()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LHU()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_LHU()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_LHU()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LHU()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LHU()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LHU()
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
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 2-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 2-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- lhu [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
