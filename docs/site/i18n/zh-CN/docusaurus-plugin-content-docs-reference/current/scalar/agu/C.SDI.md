<!-- GENERATED FROM: asl/scalar/agu/C.SDI.asl -->
# C.SDI

**Normative ASL source:** `asl/scalar/agu/C.SDI.asl`

C.SDI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-C-SDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-sdi-purpose role=purpose -->
## `C.SDI` 做什么

`C.SDI` 是一条 `16` 位压缩存储指令，写入一个小端序 `8` 字节值。基址来自 `SrcL` 选择子，字节位移是符号扩展后的 `simm5` 字段乘以 `8`，写入内存的数据是最新的临时队列值，在汇编中记作 `t#1`。

本形式没有目的字段也没有回写：它把一个值从队列搬到内存，寄存器文件保持不变。

设计要点：数据源不是编码字段。处理程序读取 Reg5 选择子编码 `24`，也就是 `T#1` 的队列路径，所以汇编把 `t#1` 写成固定操作数。读取队列条目不会弹出它，因此存储之后 `T#1` 仍持有同一个值；只要两次 `C.SDI` 之间没有其他指令向队列压入新值，它们就会把同样的 `64` 位写到不同地址。

<!-- PTO-READER-BLOCK: scalar-c-sdi-mechanism role=mechanism -->
## 地址与存储如何形成

地址路径先对 `SrcL` 取快照，对 `simm5` 做符号扩展，左移 `3` 位，再把两者按 `2^PTO_XLEN` 取模相加。

本形式没有更新基址的目的位置，也没有回写步骤，因此基址选择子永远不会被修改：成功时不会，发生故障时也不会。

处理程序读取 `T#1`，执行一次对齐的小端序 `8` 字节存储，并记录存储事件。这 `64` 位按字节写出，最低有效字节位于最低地址。

设计要点：由于位移的缩放因子等于访问大小，可达窗口是 `-128` 到 `120` 字节、步长为 `8`，`8` 字节对齐的基址总是产生 `8` 字节对齐的地址。因此这条存储不可能仅因自身的位移字段而被判为未对齐。

<!-- PTO-READER-BLOCK: scalar-c-sdi-inputs role=inputs-outputs -->
## 编码字段与数据来源

- `SrcL` 是 `5` 位 Reg5 选择子：编码 `0`..`23` 选择绝对 GPR，编码 `24`..`27` 选择 `T#1`..`T#4`，编码 `28`..`31` 选择 `U#1`..`U#4`。
- `simm5` 是按 `8` 缩放的有符号 `5` 位位移；每个编码都是取值，没有一个表示省略。
- 被写入的值是隐式 `T#1`。没有字段选择它，也没有字段能用寄存器替换它。

设计要点：存储执行前 `T#1` 必须可用。若某个队列槽位的有效性标志为清除，指令会在内存操作之前引发 `Fault_IllegalInstruction`，因此存储永远不会把未定义的值写入内存。同一条规则也意味着，不能用存储去探测队列里是否有数据而不承担该故障。

<!-- PTO-READER-BLOCK: scalar-c-sdi-effects role=effects -->
## 影响、顺序与完成

`SrcL` 快照与 `T#1` 读取都发生在内存影响之前，因此若选择子正好指向将被存储的那个队列条目，它贡献的仍是指令执行前的值。

成功时该存储记录一个 relaxed 存储事件。若被写入的字节范围与包含保留地址的保留颗粒重叠，则清除该保留；若写入范围不重叠，则保留保持有效。

存储完成后，`C.SDI` 把 `TPC` 前进 `2` 字节。被拒绝或发生故障的尝试不会退休，`TPC` 停留在同一条指令上。

设计要点：重叠判断使用原始地址与访问大小，而不是按颗粒对齐后的地址，因此只要写进同一颗粒就会清除保留，即使具体字节不同。部分失效是不可能的。

<!-- PTO-READER-BLOCK: scalar-c-sdi-constraints role=constraints -->
## 合法性、故障与重启

`16` 位编码中的固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`。`SrcL` 编码选中不可用的 `T` 或 `U` 槽位，以及 `T#1` 不可用，都会在同一点引发同样的故障。

预检检查有效地址的低 `3` 位：非零值会在翻译之前、权限检查之前引发 `Fault_DataAlignment`；地址对齐但未通过权限或有界内存检查时，会在原始地址引发 `Fault_DataPage`。

发生故障时不写入任何内存字节，不记录存储事件，保留状态不变，`TPC` 停留在引发故障的指令上。恢复会从 `SrcL` 快照开始重新执行整个操作。

<!-- PTO-READER-BLOCK: scalar-c-sdi-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `c.sdi t#1, [3, 2]`，设 GPR3 持有 `0x4000`。有符号 `simm5` 为 `2`，乘以 `8` 得 `16`，因此有效地址是 `0x4000` 加 `16`，即 `0x4010`。
- 被存储的字节是当前 `T#1` 的低 `8` 个字节，最低有效字节先写到 `0x4010` 至 `0x4017`。
- `T#1` 保持其值，因为队列读取不会弹出它；GPR3 仍持有 `0x4000`，`TPC` 变为该指令地址加 `2`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.sdi t#1, [srcL, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_sdi_16_bbec69bcfd5d | C16 | 16 | 0x003a / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_sdi_16_bbec69bcfd5d | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_sdi_16_bbec69bcfd5d | simm5 | 5 | signed | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_sdi_16_bbec69bcfd5d | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| c_sdi_16_bbec69bcfd5d | simm5 | 5 | 0–31 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 address-base source |
| simm5 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/C.SDI.asl -->
```asl
readonly func InstructionContractOperation_C_SDI() => ScalarOperation
begin
    return ScalarOperation_C_SDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/C.SDI.asl -->
```asl
readonly func InstructionContractHandler_C_SDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_C_SDI()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_C_SDI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Compressed;
end;

pure func InstructionContractAGUSizeBytes_C_SDI()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_C_SDI()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_C_SDI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_C_SDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_C_SDI()
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
- The implicit store-data source is T#1 and must be available before execution; reading it does not consume it.
- simm5 assigns every signed 5-bit value -16..15; the encoded byte displacement is that value multiplied by 8.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm5, multiply it by 8, and add it modulo 2^PTO_XLEN to the SrcL base.
- Snapshot implicit T#1 before memory effects and preserve the queue entry after the store.
- Successful execution advances TPC by 2 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 8-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- c.sdi t#1, [srcL, simm]
