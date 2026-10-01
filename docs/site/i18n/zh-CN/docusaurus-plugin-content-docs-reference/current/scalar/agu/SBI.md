<!-- GENERATED FROM: asl/scalar/agu/SBI.asl -->
# SBI

**Normative ASL source:** `asl/scalar/agu/SBI.asl`

SBI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-SBI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sbi-purpose role=purpose -->
## `SBI` 做什么

`SBI` 把 `SrcL` 的低 `8` 位写入由 `SrcR` 基址加一个有符号立即数（不相加缩放）形成的地址。其规范汇编是 `sbi SrcL, [SrcR, simm]`。

设计要点：在这个立即数存储形式中，两个寄存器字段的角色与加载形式相反——`SrcR` 是基址，`SrcL` 承载存储数据。汇编写法是判断哪个字段做什么的可靠依据。

<!-- PTO-READER-BLOCK: scalar-sbi-mechanism role=mechanism -->
## `SBI` 如何形成地址并完成存储

`simm12` 字段从 `12` 位符号扩展到 `PTO_XLEN`，得到 `-2048`..`2047` 字节的位移，并与 `SrcR` 按 `2^PTO_XLEN` 取模相加。中间值不做任何缩放。

`SrcL` 的低字节被写入所得地址。本形式没有目的端字段，因此两个寄存器都不变，也不写入任何队列槽位。

设计要点：非缩放位移可以指向任意字节，因此对齐结果由 `SrcR` 与 `simm12` 共同决定。对 `1` 字节访问而言这从不重要，这正是字节的非缩放立即数存储在实际上不带对齐约束的原因。

<!-- PTO-READER-BLOCK: scalar-sbi-inputs role=inputs-outputs -->
## 编码字段与值的去向

- `SrcL` 提供存储数据，`SrcR` 提供基址。两者都是 `5` 位 Reg5 源：编码 `0`..`23` 命名绝对 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。读取 `T` 或 `U` 槽位既不消费也不重排它，编码 `0` 提供恒为零的 GPR。
- `simm12` 是有符号 `12` 位字段，因此全部 `4096` 个编码都是取值，编码为零提供零位移，并不表示省略。
- 本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：`SrcL` 取编码 `0` 时存储常量零字节，`SrcR` 取编码 `0` 时以架构零 GPR 为基址，因此写入固定低地址的存储完全不需要地址寄存器。

<!-- PTO-READER-BLOCK: scalar-sbi-effects role=effects -->
## 影响、顺序与完成

`SrcL` 与 `SrcR` 在内存效果之前被读取，因此写入的字节是 `SrcL` 在执行前的值。

成功执行会完成一次 relaxed `1` 字节存储并记录一个存储事件。若存储的字节范围与包含有效保留的 `64` 字节保留粒度区重叠，该保留即被作废，因此落在该粒度区内的任何存储都会清除它；粒度区之外的存储则保持其有效。 随后 `TPC` 前移 `4` 字节。

设计要点：内存效果是该指令唯一能造成的状态变化，因为没有回写目的端，也没有队列发布。因此故障后重发恰好重复一次单字节存储。

<!-- PTO-READER-BLOCK: scalar-sbi-constraints role=constraints -->
## 合法性、故障与重启

当固定比特不匹配，或所选 `T`/`U` 源因从未被压入而不可用时，分派会在任何效果之前以 `Fault_IllegalInstruction` 拒绝该指令。

`1` 字节访问天然对齐，因此对本形式而言 `Fault_DataAlignment` 不可达。预检仍会执行对齐测试，随后执行权限与有界内存测试，后者失败会在原始地址引发 `Fault_DataPage`。

故障不写任何内存字节、不记录存储事件，并把 `TPC` 留在故障指令上。恢复会重发整个操作：每一次源读取、地址运算、预检以及存储。

设计要点：故障报告在 `SrcR` 与 `simm12` 产生的原始地址上，因此处理程序可以用同样的两个操作数重新算出同一地址，而无需了解任何翻译细节。

<!-- PTO-READER-BLOCK: scalar-sbi-example role=example -->
## 完整读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 取 `sbi 5, [3, -1]`，设 GPR3 = `0x1000`，GPR5 = `0x000000000000007F`。
- `simm12=-1` 符号扩展为 `-1` 并按编码直接使用，因此有效地址是 `0x0FFF`。
- 字节 `0x7F` 被存储在 `0x0FFF`。
- GPR3 与 GPR5 都不变，没有目的端字段，`TPC` 前移 `4` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sbi SrcL, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sbi_32_f3c6b796f0d9 | L32 | 32 | 0x00000059 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sbi_32_f3c6b796f0d9 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sbi_32_f3c6b796f0d9 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sbi_32_f3c6b796f0d9 | simm12 | 12 | signed | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sbi_32_f3c6b796f0d9 | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| sbi_32_f3c6b796f0d9 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| sbi_32_f3c6b796f0d9 | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| SrcR | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SBI.asl -->
```asl
readonly func InstructionContractOperation_SBI() => ScalarOperation
begin
    return ScalarOperation_SBI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SBI.asl -->
```asl
readonly func InstructionContractHandler_SBI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SBI()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SBI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_SBI()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_SBI()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_SBI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SBI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SBI()
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
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcR base.
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

- sbi SrcL, [SrcR, simm]
