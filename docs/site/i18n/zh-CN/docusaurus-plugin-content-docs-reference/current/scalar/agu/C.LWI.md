<!-- GENERATED FROM: asl/scalar/agu/C.LWI.asl -->
# C.LWI

**Normative ASL source:** `asl/scalar/agu/C.LWI.asl`

C.LWI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-C-LWI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-lwi-purpose role=purpose -->
## `C.LWI` 做什么

`C.LWI` 是一条 `16` 位压缩加载指令，读取一个小端序 `4` 字节字。基址来自 `SrcL` 选择子，字节位移是符号扩展后的 `simm5` 字段乘以 `4`，加载值先符号扩展到完整的 `PTO_XLEN` 宽度，再成为最新的临时队列值。

压缩编码没有目的字段，因此 `C.LWI` 总是发布到 `T` 队列。

设计要点：扩展发生在加载与发布之间，所以队列槽位收到的是扩展后的 `64` 位值，而不是内存系统返回的原始 `32` 位。因此加载四个字节 `FF FF FF FF` 会让 `T#1` 持有 `64` 位全为 1 的值，后续消费者把 `T#1` 与 `-1` 比较即可成功，无需再做扩展。

<!-- PTO-READER-BLOCK: scalar-c-lwi-mechanism role=mechanism -->
## 地址与传输如何形成

地址路径先对 `SrcL` 取快照，对 `simm5` 做符号扩展，左移 `2` 位，再把两者按 `2^PTO_XLEN` 取模相加。

本形式没有基址回写，因此算出的地址被本次访问用掉后即被丢弃；无论访问成功还是发生故障，`SrcL` 都保持指令执行前的值。

编码检查与地址预检通过后，处理程序执行一次对齐的小端序 `4` 字节加载，对结果第 `31` 位做符号扩展，然后压入扩展后的值。只有当加载报告无故障时才执行压入。

设计要点：位移的缩放因子等于访问大小。本形式能编码的每个字节位移都是 `4` 的倍数，有符号 `5` 位字段覆盖 `-64` 到 `60` 字节，步长为 `4`。因此 `4` 字节对齐的基址总是产生 `4` 字节对齐的有效地址，而这正是 `4` 字节访问所要求的。

<!-- PTO-READER-BLOCK: scalar-c-lwi-inputs role=inputs-outputs -->
## 编码字段与结果去向

- `SrcL` 是 `5` 位 Reg5 选择子：编码 `0`..`23` 选择绝对 GPR，编码 `24`..`27` 选择 `T#1`..`T#4`，编码 `28`..`31` 选择 `U#1`..`U#4`。`T` 或 `U` 源被读取时不会被消耗。
- `simm5` 是按 `4` 缩放的有符号 `5` 位位移。全部 `32` 个编码都是取值。
- 目的位置是隐式 `T#1`，通过队列压入到达，压入同时把较旧的条目移向 `T#4`。

设计要点：定位取值的字段同时决定读取多少；缩放因子与扩展规则来自编码，而不是来自数据。由于发布是队列压入，最新的队列条目总是描述最近一次加载。

<!-- PTO-READER-BLOCK: scalar-c-lwi-effects role=effects -->
## 影响、顺序与完成

`SrcL` 的读取发生在任何内存或队列影响之前，因此与将被压入的 `T` 槽位别名的选择子仍提供其指令执行前的值。

执行成功时进行一次 relaxed 的 `4` 字节加载并记录一个加载事件。内存字节以及任何保留状态都不改变。

压入之后，`C.LWI` 把 `TPC` 前进 `2` 字节。被拒绝或发生故障的尝试不会退休，因此 `TPC` 停留在引发故障的指令上。

设计要点：`4` 字节读取与 `64` 位压入是两个步骤，扩展位于两者之间，因此即使实现在内存阶段之后才报告故障，队列依然保持不变：任何部分扩展的值都不会可见。

<!-- PTO-READER-BLOCK: scalar-c-lwi-constraints role=constraints -->
## 合法性、故障与重启

`16` 位编码中的固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`。`SrcL` 编码若选择一个有效性标志为清除的 `T` 或 `U` 槽位，会在同一点引发同样的故障，且不会尝试任何内存访问。

预检检查有效地址的低 `2` 位。非零值会在地址翻译之前、权限检查之前引发 `Fault_DataAlignment`；地址对齐但未通过权限或有界内存检查时，会在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，不写入任何队列槽位，`TPC` 停留在引发故障的指令上。恢复会重新执行整个操作：`SrcL` 快照、地址形成、预检、`4` 字节加载、扩展与压入。

<!-- PTO-READER-BLOCK: scalar-c-lwi-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `c.lwi [7, 5], ->t`，设 GPR7 持有 `0x3004`。有符号 `simm5` 为 `5`，乘以 `4` 得 `20`，因此有效地址是 `0x3004` 加 `20`，即 `0x3018`。
- 该指令按小端序读取 `0x3018` 到 `0x301B` 的 `4` 字节。
- 若这些字节是 `00 00 00 80`，则第 `31` 位为 1，压入的 `T#1` 持有 `0xFFFFFFFF80000000`。
- GPR7 仍持有 `0x3004`，`TPC` 变为该指令地址加 `2`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.lwi [srcL, simm], ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_lwi_16_b224525971da | C16 | 16 | 0x000a / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_lwi_16_b224525971da | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_lwi_16_b224525971da | simm5 | 5 | signed | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_lwi_16_b224525971da | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| c_lwi_16_b224525971da | simm5 | 5 | 0–31 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 address-base source |
| simm5 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/C.LWI.asl -->
```asl
readonly func InstructionContractOperation_C_LWI() => ScalarOperation
begin
    return ScalarOperation_C_LWI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/C.LWI.asl -->
```asl
readonly func InstructionContractHandler_C_LWI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_C_LWI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_C_LWI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Compressed;
end;

pure func InstructionContractAGUSizeBytes_C_LWI()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_C_LWI()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_C_LWI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_C_LWI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_C_LWI()
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
- simm5 assigns every signed 5-bit value -16..15; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm5, multiply it by 4, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 4-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 2 bytes; a rejected or faulting attempt does not retire.

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

- c.lwi [srcL, simm], ->t
