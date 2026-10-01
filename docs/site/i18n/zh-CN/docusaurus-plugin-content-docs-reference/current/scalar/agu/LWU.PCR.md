<!-- GENERATED FROM: asl/scalar/agu/LWU.PCR.asl -->
# LWU.PCR

**Normative ASL source:** `asl/scalar/agu/LWU.PCR.asl`

LWU.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-LWU-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lwu-pcr-purpose role=purpose -->
## `LWU.PCR` 做什么

`LWU.PCR` 从 PC 相对地址加载小端 `4` 字节字，并零扩展到 `PTO_XLEN`。它没有源寄存器字段：基址来自当前 `TPC`。其规范汇编是 `lwu.pcr [symbol], ->{t, u, Rd}`。

设计要点：加载字被零扩展，因此发布的值位 `63`:`32` 恒为 `0`，且落在 `0`..`4294967295` 之间。若某个 `32` 位模式必须保持为负数，就需要使用会符号扩展的 PC 相对加载形式。

<!-- PTO-READER-BLOCK: scalar-lwu-pcr-mechanism role=mechanism -->
## `LWU.PCR` 如何形成地址并完成访问

基址是执行前的 `TPC`，并把位 `1`:`0` 清零，从而满足 `4` 字节对齐。`simm17` 字段符号扩展到 `PTO_XLEN` 后左移 `2` 位，两个值按 `2^PTO_XLEN` 取模相加。

该和被一次小端 `4` 字节加载使用。此形式没有基址回写，也没有第二个目的端。只有在加载报告无故障时，加载字的位 `31`:`0` 才被零扩展并通过 `RegDst` 写入。

设计要点：清掉 `TPC[1:0]` 使位移拥有一个稳定基址，即使变长指令把 `TPC` 留在某个字的第二个半字上也是如此。因此位于 `0x1002` 与 `0x1006` 的两条指令在相同字段下访问相距 `4` 字节的位置，且两个地址都保持 `4` 字节对齐。

<!-- PTO-READER-BLOCK: scalar-lwu-pcr-inputs role=inputs-outputs -->
## 编码字段与值的去向

- `simm17` 是有符号 `17` 位字位移，因此全部 `131072` 个编码都是取值。它产生的字节位移是 `-262144` 到 `262140` 之间 `4` 的倍数。
- `RegDst` 是 `5` 位目的端：编码 `1`..`23` 写绝对 GPR，编码 `30` 压入 `U` 队列，编码 `31` 压入 `T` 队列，编码 `0` 与 `24`..`29` 丢弃加载值。

设计要点：没有基址选择子需要校验，因此即使目的端仍可压入队列项，本形式也没有`T`/`U` 不可用的拒绝路径。固定操作码模式是唯一可能非法的编码值。

<!-- PTO-READER-BLOCK: scalar-lwu-pcr-effects role=effects -->
## 影响、顺序与完成

基址在内存与目的端效果之前从 `TPC` 读出，而 `TPC` 前移是最后一步，因此地址不会受该指令自身退休的影响。

成功执行会完成一次 relaxed `4` 字节加载并记录一个加载事件。内存字节不变，保留状态得以保持。随后 `TPC` 前移 `4` 字节。

设计要点：位移为 `0` 时读取的是包含该指令自身的对齐字的 `4` 字节，因此自引用数据访问无需任何寄存器准备。基址被向下对齐，所以被访问的字不一定是该指令所占的那个字。

<!-- PTO-READER-BLOCK: scalar-lwu-pcr-constraints role=constraints -->
## 合法性、故障与重启

当固定编码比特不匹配时，分派会在任何效果之前以 `Fault_IllegalInstruction` 拒绝该指令。

基址满足 `4` 字节对齐，缩放后的位移是 `4` 的倍数，因此 `4` 字节访问总是对齐的，对本形式而言 `Fault_DataAlignment` 不可达。对齐但未通过权限或有界内存测试的地址会在原始地址引发 `Fault_DataPage`；PTO v0 的翻译是恒等函数，因此不存在单独的翻译故障。

故障不记录加载事件、不写目的端，并把 `TPC` 留在故障指令上，因此重发会从同一个 `TPC` 重新计算同一个对齐基址。

设计要点：对齐结果由编码而非地址决定，因此 `Fault_DataPage` 是本形式唯一可能引发的数据故障。捕获 `Fault_DataAlignment` 的处理程序永远不会从这里看到它。

<!-- PTO-READER-BLOCK: scalar-lwu-pcr-example role=example -->
## 完整读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 取 `lwu.pcr [symbol], ->5`，执行时 `TPC` = `0x1002`，编码的 `simm17` 等于 `3`。
- 把 `0x1002` 的低 `2` 位清零得到基址 `0x1000`；位移是 `3` 乘 `4`，即 `12`。
- 有效地址是 `0x1000` 加 `12`，即 `0x100C`。
- `0x100C` 满足 `4` 字节对齐，预检通过；`0x100C` 到 `0x100F` 的 `4` 字节被零扩展写入 GPR5，`TPC` 变为 `0x1006`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lwu.pcr [symbol], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lwu_pcr_32_df27ea51c564 | L32 | 32 | 0x00006039 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lwu_pcr_32_df27ea51c564 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lwu_pcr_32_df27ea51c564 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lwu_pcr_32_df27ea51c564 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lwu_pcr_32_df27ea51c564 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LWU.PCR.asl -->
```asl
readonly func InstructionContractOperation_LWU_PCR() => ScalarOperation
begin
    return ScalarOperation_LWU_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LWU.PCR.asl -->
```asl
readonly func InstructionContractHandler_LWU_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LWU_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LWU_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_LWU_PCR()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_LWU_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_LWU_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LWU_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LWU_PCR()
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
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- After a successful 4-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 4-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- lwu.pcr [symbol], ->{t, u, Rd}
