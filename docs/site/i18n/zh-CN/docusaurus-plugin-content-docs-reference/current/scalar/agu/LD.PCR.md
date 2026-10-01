<!-- GENERATED FROM: asl/scalar/agu/LD.PCR.asl -->
# LD.PCR

**Normative ASL source:** `asl/scalar/agu/LD.PCR.asl`

LD.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-LD-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ld-pcr-purpose role=purpose -->
## `LD.PCR` 的作用

`LD.PCR` 从相对于指令自身的地址加载一个 `8` 字节小端单元。它不读取基址寄存器：参考点是对齐后的当前 `TPC`。

规范汇编是 `ld.pcr [symbol], ->{t, u, Rd}`。

设计要点：`LD.PCR` 是本 PC 相对组中唯一访问宽度（`8` 字节）大于 `4` 字节位移比例的成员，因此对齐由和的第 `2` 位决定。

<!-- PTO-READER-BLOCK: scalar-ld-pcr-mechanism role=mechanism -->
## 地址与传输如何形成

基址是清掉第 `1:0` 位后的 `TPC`，因此参考点是本指令的 `4` 字节对齐地址。`simm17` 被符号扩展、乘以 `4`，并按模 `2^PTO_XLEN` 相加。

预检先检查 `8` 字节对齐，再转换，然后检查权限与有界内存。成功后小端读取 `8` 字节并记录一个 relaxed 加载事件。

加载到的全部 `64` 位原样通过 `RegDst` 发布；既没有需要更新的基址寄存器，也没有扩展步骤。

设计要点：清位后的基址与按比例缩放的位移都是 `4` 的倍数，因此和始终是 `4` 的倍数。若和为 `4` 模 `8`，即使编码本身没有任何错误，也会引发 `Fault_DataAlignment`。

<!-- PTO-READER-BLOCK: scalar-ld-pcr-inputs role=inputs-outputs -->
## 编码字段与角色

- `TPC` 是隐式基址。加上位移之前先清掉第 `1:0` 位，而 `TPC` 此时仍持有正在执行的指令地址。
- `simm17` 为带符号数，覆盖 `-65536`..`65535` 个单位；每个单位是 `4` 字节，因此字节位移覆盖 `-262144`..`262140`。
- `RegDst` 是本编码中唯一的选择子。编码 `1`..`23` 写 GPR，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`0` 与 `24`..`29` 不发布任何结果；编码 `0` 是架构零寄存器，其写入被丢弃。
- 设计要点：没有寄存器操作数，编码就有空间容纳 `17` 位位移，这正是 `32` 位指令能在自身地址周围达到 `262144` 字节覆盖范围的原因。

<!-- PTO-READER-BLOCK: scalar-ld-pcr-effects role=effects -->
## 效果、顺序与完成

基址在内存操作之前从 `TPC` 读取，因此位移始终相对于本指令，而不会相对于下一条指令。

成功时记录一个 relaxed 加载事件，不改变任何内存字节，保留保持不变，发布加载到的 `8` 字节，并使 `TPC` 前进 `4` 字节。

设计要点：由于地址与指令绑定，同一编码无论代码放在哪里都加载同一个相对单元；只有依赖允许区域的故障会随放置位置不同。

<!-- PTO-READER-BLOCK: scalar-ld-pcr-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配会在任何内存或目的端效果之前于指令地址处引发 `Fault_IllegalInstruction`。
- 不是 `8` 的倍数的地址会在转换之前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始有效地址处引发 `Fault_DataPage`。
- 故障不记录加载事件、不发布结果，并让 `TPC` 停留在引发故障的指令上，使尝试可以原样重发。
- 设计要点：`LD.PCR` 之所以能引发 `Fault_DataAlignment`，正是因为它的对齐要求比编码所保证的`4` 的倍数更严格。

<!-- PTO-READER-BLOCK: scalar-ld-pcr-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 当 `TPC` = `0x100`、`simm17` = `3` 时，字节位移是 `12`，地址是 `0x10C`。
- `0x10C` 模 `8` 余 `4`，因此预检引发 `Fault_DataAlignment`，且不加载任何字节。
- 当 `simm17` = `2` 时地址是 `0x108`，它是 `8` 字节对齐的，该处的 `8` 字节作为一个 `64` 位值发布。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ld.pcr [symbol], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ld_pcr_32_99bc3d2d487b | L32 | 32 | 0x00003039 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ld_pcr_32_99bc3d2d487b | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ld_pcr_32_99bc3d2d487b | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ld_pcr_32_99bc3d2d487b | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| ld_pcr_32_99bc3d2d487b | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LD.PCR.asl -->
```asl
readonly func InstructionContractOperation_LD_PCR() => ScalarOperation
begin
    return ScalarOperation_LD_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LD.PCR.asl -->
```asl
readonly func InstructionContractHandler_LD_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LD_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LD_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_LD_PCR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_LD_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_LD_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LD_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LD_PCR()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
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

- ld.pcr [symbol], ->{t, u, Rd}
