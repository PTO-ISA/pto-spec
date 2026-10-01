<!-- GENERATED FROM: asl/scalar/agu/C.SWI.asl -->
# C.SWI

**Normative ASL source:** `asl/scalar/agu/C.SWI.asl`

C.SWI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-C-SWI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-swi-purpose role=purpose -->
## `C.SWI` 做什么

`C.SWI` 是一条 `16` 位压缩存储指令，写入一个小端序 `4` 字节字。基址来自 `SrcL` 选择子，字节位移是符号扩展后的 `simm5` 字段乘以 `4`，写入内存的数据是最新临时队列值 `t#1` 的低 `32` 位。

本形式没有目的字段，也没有回写。

设计要点：只有 `64` 位队列条目的低 `4` 字节进入内存。存储只写出访问大小的字节数，值的第 `k` 个字节取自第 `8k` 到 `8k+7` 位，因此 `C.SWI` 会截断，而 `C.SDI` 写出整个条目。若 `T#1` 为 `0x00000000FFFFFFFF`，`C.SWI` 写入 `FF FF FF FF`，高半部分丢失。

<!-- PTO-READER-BLOCK: scalar-c-swi-mechanism role=mechanism -->
## 地址与存储如何形成

地址路径先对 `SrcL` 取快照，对 `simm5` 做符号扩展，左移 `2` 位，再把两者按 `2^PTO_XLEN` 取模相加。

本形式不计算用于发布的更新基址，因此在成功路径和故障路径上 `SrcL` 对本指令都是只读的。

编码检查与地址预检通过后，处理程序读取 `T#1`，执行一次对齐的小端序 `4` 字节存储，并记录存储事件。

设计要点：缩放因子与 `4` 字节访问匹配。可达字节位移是 `-64` 到 `60`、步长为 `4`；由于位移与所需对齐都是 `4` 的倍数，对齐的基址会让每个可达地址都保持对齐。正是这个更小的缩放因子使可达窗口比 `C.SDI` 的更小。

<!-- PTO-READER-BLOCK: scalar-c-swi-inputs role=inputs-outputs -->
## 编码字段与数据源

- `SrcL` 是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`。
- `simm5` 是按 `4` 缩放的有符号 `5` 位位移；全部 `32` 个编码都是取值。
- 数据源是隐式 `T#1`，通过队列读取且不会被弹出。
- 没有目的字段，因此没有结果寄存器被指定，也没有寄存器被写入。

设计要点：`T#1` 的可用性属于合法性的一部分，在内存操作之前检查。因此有效性标志为清除时会以 `Fault_IllegalInstruction` 拒绝该指令且不写入任何字节，这使存储不会发布陈旧或未定义的队列条目。

<!-- PTO-READER-BLOCK: scalar-c-swi-effects role=effects -->
## 影响、顺序与完成

`SrcL` 快照与 `T#1` 读取先于内存影响，因此两者之间任何别名都使用指令执行前的值。

成功时记录一个 relaxed 存储事件。若被写入的字节范围与包含保留地址的保留颗粒重叠，则清除该保留；若在该颗粒之外，则保留保持有效。

存储完成后 `TPC` 前进 `2` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：事件在字节写入之后记录，因此之后看到该事件的观察者也能看到已写入的值。发生故障的存储两者都不产生。

<!-- PTO-READER-BLOCK: scalar-c-swi-constraints role=constraints -->
## 合法性、故障与重启

`16` 位编码中的固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`；不可用的 `SrcL` `T` 或 `U` 槽位以及不可用的 `T#1` 同样如此。

预检检查有效地址的低 `2` 位。非零值会在翻译之前、权限检查之前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始地址引发 `Fault_DataPage`。

发生故障时不写入任何内存字节，不记录存储事件，保留状态与 `TPC` 都不变。恢复会重新执行 `SrcL` 快照、地址形成、预检、`T#1` 读取与存储，不保留任何进度。

<!-- PTO-READER-BLOCK: scalar-c-swi-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `c.swi t#1, [9, -1]`，设 GPR9 持有 `0x5000`。有符号 `simm5` 为 `-1`，乘以 `4` 得 `-4`，因此有效地址是 `0x5000` 减去 `4`，即 `0x4FFC`。
- 该指令把 `T#1` 的低 `4` 字节写到 `0x4FFC` 至 `0x4FFF`，最低有效字节在前。
- 若 `T#1` 持有 `0x1122334455667788`，写出的字节是 `88 77 66 55`。
- GPR9 仍持有 `0x5000`，`TPC` 变为该指令地址加 `2`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.swi t#1, [srcL, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_swi_16_ca6c111163e5 | C16 | 16 | 0x002a / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_swi_16_ca6c111163e5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_swi_16_ca6c111163e5 | simm5 | 5 | signed | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_swi_16_ca6c111163e5 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| c_swi_16_ca6c111163e5 | simm5 | 5 | 0–31 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 address-base source |
| simm5 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/C.SWI.asl -->
```asl
readonly func InstructionContractOperation_C_SWI() => ScalarOperation
begin
    return ScalarOperation_C_SWI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/C.SWI.asl -->
```asl
readonly func InstructionContractHandler_C_SWI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_C_SWI()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_C_SWI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Compressed;
end;

pure func InstructionContractAGUSizeBytes_C_SWI()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_C_SWI()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_C_SWI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_C_SWI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_C_SWI()
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
- simm5 assigns every signed 5-bit value -16..15; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm5, multiply it by 4, and add it modulo 2^PTO_XLEN to the SrcL base.
- Snapshot implicit T#1 before memory effects and preserve the queue entry after the store.
- Successful execution advances TPC by 2 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 4-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- c.swi t#1, [srcL, simm]
