<!-- GENERATED FROM: asl/scalar/amo/CASW.asl -->
# CASW

**Normative ASL source:** `asl/scalar/amo/CASW.asl`

CASW atomically compares and conditionally replaces one word, then publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-CASW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-casw-purpose role=purpose -->
## CASW 的作用

`CASW` 原子读取 `SrcL` 指向地址处的 4 字节字，将其与 `SrcR` 的低 `4` 字节比较，并在比较成功时把 `SrcD` 的低 `4` 字节写入该处。

无故障的匹配与无故障的不匹配都会通过 `RegDst` 发布原来的字。`CASW` 是一个 32 位形式，成功执行使 `TPC` 前进 `4` 字节。

<!-- PTO-READER-BLOCK: scalar-casw-mechanism role=mechanism -->
## 比较并交换的执行序列

`ExecuteDecodedCompareAndSwap` 先读取 `SrcL`、`SrcR` 和 `SrcD`，然后以访问宽度 `4` 调用 `CompareAndSwap`，因此操作数在第一次探测之前就已取好快照。该辅助函数先探测地址的读访问，再探测写访问，并要求两次探测给出同一个转换后地址。

辅助函数载入该转换后地址处的字，并与规范化后的期望值比较。相等时执行写入，不相等时跳过写入；两种情况都会记录一个原子事件，携带载入的字、规范化后的待写值，以及取比较结果的 `write_performed`。

设计要点：在此宽度下 `NormalizeAtomicReturn` 施加 `SignExtend{PTO_XLEN}(value[31:0])`，因此内存字 `0x80000001` 到达 `RegDst` 时是 `0xffffffff80000001`。`CASW` 可以发布负的 XLEN 值；`CASB` 和 `CASH` 不能。

设计要点：比较使用 `NormalizeAtomicUnsigned(SrcR, 4)`，它从 `32` 位零扩展，因此 `SrcR` 的高 `32` 位被忽略。内存字为 `0x00000001` 时，`SrcR = 0xdeadbeef00000001` 能够匹配。

<!-- PTO-READER-BLOCK: scalar-casw-inputs role=inputs-outputs -->
## 操作数、排序与目的地

- `SrcL` 提供原子地址，`SrcR` 提供期望字，`SrcD` 提供待写字；三者都接受绝对 GPR、T 和 U 选择器，且读取队列条目不会消费它。
- `RegDst` 决定原字的去处：编码 `1` 到 `23` 写入对应 GPR，编码 `0` 和编码 `24` 到 `29` 丢弃该值，编码 `30` 和 `31` 将其压入 U 队列或 T 队列。

`aq=0,rl=0` 记录 relaxed 排序，`aq=1,rl=0` 为 acquire，`aq=0,rl=1` 为 release，`aq=1,rl=1` 为 acquire-release，匹配和不匹配都一样。

设计要点：这个 32 位形式没有 `far` 位，所以编码只提供默认平坦地址路径。缺失字段解码为零，而 `AtomicAddress` 原样返回其参数，因此这里的任何路由选择都无法移动访问位置。

<!-- PTO-READER-BLOCK: scalar-casw-effects role=effects -->
## 架构效果

匹配时把待写低字写入内存，并记录一个 `write_performed=true` 的原子事件；不匹配时记录一个 `write_performed=false` 的原子事件，内存保持不变。

设计要点：目的写入由载入的字驱动，且只在故障被置位时跳过，因此未能替换该字的指令仍然报告内存中原有的内容，重试时可以从 `RegDst` 取得该值，而无需再载入一次。

设计要点：记录的事件携带 `NormalizeAtomicUnsigned(desired, 4)`，而不是 XLEN 寄存器值，因此其中的新值正是写入实际提交的低 `32` 位。

两种无故障结果都会使 `TPC` 前进 `4` 字节；匹配时，若写入的字与保留的 64 字节粒度重叠，还会清除保留状态。

<!-- PTO-READER-BLOCK: scalar-casw-constraints role=constraints -->
## 对齐、访问检查与故障顺序

地址必须是 `4` 的倍数。`ProbeDataAccess` 在地址转换之前、权限检查之前测试 `UInt(address) MOD 4`，并在余数非零时报告 `Fault_DataAlignment`。

读探测先执行，因此先报告它的对齐结果或 `Fault_DataPage`。写探测随后以同样的宽度和对齐要求进行，之后两次转换后的地址必须一致，否则抛出 `Fault_DataPage`。

设计要点：这些检查都在载入之前完成，因此出错时 `CASW` 不写入内存、不记录原子事件、不清除保留状态、不写目的寄存器，并让 `TPC` 停在同一指令上。参考模型把地址转换为其自身，所以那里该比较不会失败，而边界检查仍可能失败。

报告的故障携带原始 `SrcL` 地址。解码失败，或所选 `T#1` 到 `T#4`、`U#1` 到 `U#4` 源不可用，会在处理函数运行之前抛出 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: scalar-casw-example role=example -->
## 一个匹配的字，和一个不匹配的字

下面的演示只帮助理解当前契约，并不替代原子操作。

假设该地址处的字为 `0x80000001`，`SrcR` 的低 `4` 字节为 `0x80000001`，`SrcD` 为 `0x55667788`。比较成功，于是 `CASW` 写入 `0x55667788`，在 `RegDst` 中发布 `0xffffffff80000001`，并记录一个 `write_performed=true` 的原子事件。

设内存中仍是同一个字 `0x80000001`，但 `SrcR` 的低 `4` 字节为 `0x00000002`。比较失败，内存保持 `0x80000001`，记录的事件为 `write_performed=false`，`RegDst` 仍然收到 `0xffffffff80000001`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
casw [SrcL], SrcR, SrcD, ->Rd
casw.aq [SrcL], SrcR, SrcD, ->Rd
casw.rl [SrcL], SrcR, SrcD, ->Rd
casw.aqrl [SrcL], SrcR, SrcD, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| casw_32_cb29e4287223 | L32 | 32 | 0x0000201b / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| casw_32_cb29e4287223 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| casw_32_cb29e4287223 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| casw_32_cb29e4287223 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| casw_32_cb29e4287223 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| casw_32_cb29e4287223 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| casw_32_cb29e4287223 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| casw_32_cb29e4287223 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| casw_32_cb29e4287223 | SrcD | 5 | 0–31 | none | none | Reg5 desired word source | Encoded zero supplies numeric zero as the desired value. |
| casw_32_cb29e4287223 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| casw_32_cb29e4287223 | SrcR | 5 | 0–31 | none | none | Reg5 expected word source | Encoded zero supplies numeric zero as the expected value. |
| casw_32_cb29e4287223 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| casw_32_cb29e4287223 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 expected word source |
| SrcD | Reg5 desired word source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/CASW.asl -->
```asl
readonly func InstructionContractOperation_CASW() => ScalarOperation
begin
    return ScalarOperation_CASW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/CASW.asl -->
```asl
readonly func InstructionContractHandler_CASW() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_CASW()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractHasFarField_CASW()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractZeroExtendsOldValue_CASW()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractSignExtendsOldValue_CASW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, SrcD, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the old value.
- aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.
- The short form has no far field and therefore uses the default flat-address route.

## Legality

- All 32 SrcL, SrcR, and SrcD Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.
- All aq and rl combinations are assigned; the short form has implicit far zero.
- The effective address must be aligned to 4 bytes.

## State effects

- Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.
- Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.
- The 32-bit old value is sign-extended to XLEN.
- Successful execution advances TPC by 4 bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 4-byte word and compare it with SrcR truncated to 4 bytes.
- On equality, store SrcD truncated to 4 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.
- Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.
- The 32-bit old value is sign-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.
- The short form always uses the default flat-address route.

## Exceptions

- The effective address must be aligned to 4 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- casw [a0], a1, a2, ->a3
- casw.aqrl [t#1], u#1, a0, ->u
