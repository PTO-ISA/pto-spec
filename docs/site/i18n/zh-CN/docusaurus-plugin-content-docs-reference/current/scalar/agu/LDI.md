<!-- GENERATED FROM: asl/scalar/agu/LDI.asl -->
# LDI

**Normative ASL source:** `asl/scalar/agu/LDI.asl`

LDI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-LDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ldi-purpose role=purpose -->
## `LDI` 的作用

`LDI` 在距基址寄存器的按比例缩放的带符号立即数位移处加载一个 `8` 字节小端单元，因此立即数以 `8` 字节为单位计数，而不是以字节计数。

规范汇编是 `ldi [SrcL, simm], ->{t, u, Rd}`。

设计要点：把 `12` 位字段按 `8` 缩放后，字节窗口扩大到 `-16384`..`16376`，这是 `simm12` 标量加载可获得的最宽覆盖范围，代价是 `8` 字节粒度。

<!-- PTO-READER-BLOCK: scalar-ldi-mechanism role=mechanism -->
## 地址与传输如何形成

`LDI` 把 `simm12` 符号扩展后左移 `3` 位，即地址类型所记录的乘以 `8`。结果与 `SrcL` 快照按模 `2^PTO_XLEN` 相加。

预检先检查 `8` 字节对齐，再转换，然后检查权限与有界内存。成功后小端读取 `8` 字节并记录一个 relaxed 加载事件。

加载到的 `64` 位原样发布；既不做扩展，也不做基址回写。

设计要点：字节位移始终是 `8` 的倍数，因此有效地址的低三位只来自基址。不是 `8` 的倍数的基址会使 `LDI` 的任何编码都不对齐。

<!-- PTO-READER-BLOCK: scalar-ldi-inputs role=inputs-outputs -->
## 编码字段与角色

- `SrcL` 是基址选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `simm12` 为带符号数，覆盖 `-2048`..`2047` 个单位，并按 `8` 缩放，因此字节位移覆盖 `-16384`..`16376`。
- `RegDst` 是目的端选择子。编码 `1`..`23` 写 GPR，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`0` 与 `24`..`29` 不发布任何结果；编码 `0` 是架构零寄存器，其写入被丢弃。
- 设计要点：本编码没有 `SrcRType` 也没有 `shamt` 字段；比例由指令固定，因此没有任何操作数选择 `LDI` 的覆盖范围或粒度。

<!-- PTO-READER-BLOCK: scalar-ldi-effects role=effects -->
## 效果、顺序与完成

基址在内存操作之前取快照，因此之后对同一寄存器的写入无法改变本次加载的地址。

成功时记录一个 relaxed 加载事件，不写内存，保留保持不变，发布加载到的 `64` 位，并使 `TPC` 前进 `4` 字节。

设计要点：同一个 `simm12` 值在这里表示的字节距离与不带比例的 `.u` 形式不同，因此对给定的编码字段，这两种形式不可互换。

<!-- PTO-READER-BLOCK: scalar-ldi-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配或 `SrcL` 选择子指向不可用的 `T`/`U` 队列条目，会在读取基址之前引发 `Fault_IllegalInstruction`。
- 不是 `8` 的倍数的和会在转换之前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始有效地址处引发 `Fault_DataPage`。
- 故障不记录事件、不发布结果，并让 `TPC` 停留在引发故障的指令上以便完整重发。
- 设计要点：由于缩放保留基址的低三位，`LDI` 的对齐检查实际上是基址寄存器的性质，而不是立即数的性质。

<!-- PTO-READER-BLOCK: scalar-ldi-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 当 `SrcL` = `0x2000`、`simm12` = `-1` 时，字节位移是 `-8`，地址是 `0x1FF8`，它是 `8` 字节对齐的。
- 当 `SrcL` = `0x2004` 且 `simm12` 相同时，地址是 `0x1FFC`，它不是 `8` 字节对齐的，因此引发 `Fault_DataAlignment`。
- 成功尝试读到的 `8` 字节原样到达 `RegDst`，最低地址存放最低有效字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ldi [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ldi_32_d82a643f7a2b | L32 | 32 | 0x00003019 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ldi_32_d82a643f7a2b | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ldi_32_d82a643f7a2b | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ldi_32_d82a643f7a2b | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ldi_32_d82a643f7a2b | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| ldi_32_d82a643f7a2b | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| ldi_32_d82a643f7a2b | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LDI.asl -->
```asl
readonly func InstructionContractOperation_LDI() => ScalarOperation
begin
    return ScalarOperation_LDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LDI.asl -->
```asl
readonly func InstructionContractHandler_LDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LDI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LDI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_LDI()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_LDI()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_LDI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LDI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 8.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 8, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 8-byte load, preserve the complete 64-bit loaded bit pattern and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 8-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- ldi [SrcL, simm], ->{t, u, Rd}
