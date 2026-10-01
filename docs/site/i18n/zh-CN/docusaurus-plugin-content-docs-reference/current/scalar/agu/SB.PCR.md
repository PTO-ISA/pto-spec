<!-- GENERATED FROM: asl/scalar/agu/SB.PCR.asl -->
# SB.PCR

**Normative ASL source:** `asl/scalar/agu/SB.PCR.asl`

SB.PCR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-SB-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sb-pcr-purpose role=purpose -->
## `SB.PCR` 做什么

`SB.PCR` 把 `SrcL` 的低 `8` 位写入一个 PC 相对地址。它没有基址寄存器字段：地址是当前 `TPC` 加一个有符号字位移。其规范汇编是 `sb.pcr SrcL, [symbol]`。

设计要点：这里 `SrcL` 是存储数据，而不是基址。本形式完全无法通过寄存器寻址内存，因此要把一个字节写入计算得到的位置，必须改用 `SB` 或 `SBI`。

<!-- PTO-READER-BLOCK: scalar-sb-pcr-mechanism role=mechanism -->
## `SB.PCR` 如何形成地址并完成存储

基址是执行前的 `TPC` 并把位 `1`:`0` 清零，偏移量是符号扩展后的 `simm` 字段左移 `2` 位。两个值按 `2^PTO_XLEN` 取模相加。

写入该地址的值是 `SrcL` 的低字节，指令在存储之前读取它。`1` 字节访问恰好覆盖一个字节，因此不存在字节序问题。

设计要点：基址满足 `4` 字节对齐，位移是 `4` 的倍数，因此本形式能产生的每个地址都满足 `4` 字节对齐。`1` 字节访问从不需要这一点，这使 `SB.PCR` 成为没有对齐风险的位置式存储。

<!-- PTO-READER-BLOCK: scalar-sb-pcr-inputs role=inputs-outputs -->
## 编码字段与值的去向

- `SrcL` 是 `5` 位 Reg5 存储数据源。编码 `0`..`23` 命名绝对 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。读取 `T` 或 `U` 槽位既不消费也不重排它，编码 `0` 提供恒为零的 GPR。
- `simm` 是有符号 `17` 位字位移，因此全部 `131072` 个编码都是取值。字节位移是 `-262144` 到 `262140` 之间 `4` 的倍数。
- 本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：`SrcL` 可以命名编码 `0`，即架构零 GPR，这使该指令成为一次零字节存储。这是一个有定义的操作，而不是省略。

<!-- PTO-READER-BLOCK: scalar-sb-pcr-effects role=effects -->
## 影响、顺序与完成

`SrcL` 在内存效果之前被读取，因此写入的字节是该寄存器或队列槽位在执行前的值。

成功执行会完成一次 relaxed `1` 字节存储并记录一个存储事件。若存储的字节范围与包含有效保留的 `64` 字节保留粒度区重叠，该保留即被作废，因此落在该粒度区内的任何存储都会清除它；粒度区之外的存储则保持其有效。 随后 `TPC` 前移 `4` 字节。

设计要点：保留比较使用的是整个粒度区而不是被保留的那个字节，因此写入同一粒度区内另一个地址同样会作废该保留。若软件要在多次存储之间保持保留，就必须把这些存储放在其他粒度区。

<!-- PTO-READER-BLOCK: scalar-sb-pcr-constraints role=constraints -->
## 合法性、故障与重启

当固定比特不匹配，或所选 `T`/`U` 数据源因从未被压入而不可用时，分派会在任何效果之前以 `Fault_IllegalInstruction` 拒绝该指令。

`1` 字节访问天然对齐，因此对本形式而言 `Fault_DataAlignment` 不可达。预检仍会执行对齐测试，随后执行权限与有界内存测试，后者失败会在原始地址引发 `Fault_DataPage`。

故障不写任何内存字节、不记录存储事件，并把 `TPC` 留在故障指令上。恢复会重发整个操作：每一次源读取、地址运算、预检以及存储。

设计要点：由于预检先于内存效果，发生故障的尝试会让内存完全保持原样，既没有部分写入的字节，也没有被部分更新的保留。

<!-- PTO-READER-BLOCK: scalar-sb-pcr-example role=example -->
## 完整读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 取 `sb.pcr 5, [symbol]`，执行时 `TPC` = `0x2006`，`simm` 等于 `-2`，GPR5 = `0x00000000000000AB`。
- 把 `0x2006` 的低 `2` 位清零得到基址 `0x2004`；位移是 `-2` 乘 `4`，即 `-8`。
- 有效地址是 `0x2004` 减 `8`，即 `0x1FFC`，字节 `0xAB` 被写入该处。
- GPR5 的低字节保持不变，没有目的端字段可发布结果，`TPC` 变为 `0x200A`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sb.pcr SrcL, [symbol]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sb_pcr_32_7625a9a24c59 | L32 | 32 | 0x00000069 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sb_pcr_32_7625a9a24c59 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sb_pcr_32_7625a9a24c59 | simm | 17 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sb_pcr_32_7625a9a24c59 | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| sb_pcr_32_7625a9a24c59 | simm | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SB.PCR.asl -->
```asl
readonly func InstructionContractOperation_SB_PCR() => ScalarOperation
begin
    return ScalarOperation_SB_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SB.PCR.asl -->
```asl
readonly func InstructionContractHandler_SB_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SB_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SB_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_SB_PCR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_SB_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_SB_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SB_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SB_PCR()
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
- simm assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 1-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 1-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- sb.pcr SrcL, [symbol]
