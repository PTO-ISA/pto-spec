<!-- GENERATED FROM: asl/scalar/amo/LW.UMAX.asl -->
# LW.UMAX

**Normative ASL source:** `asl/scalar/amo/LW.UMAX.asl`

LW.UMAX atomically stores the width-sized unsigned maximum and publishes the prior memory value.

## Normative identity {#PTO-INST-SCALAR-LW-UMAX}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lw-umax-purpose role=purpose -->
## LW.UMAX 的作用
`LW.UMAX` 原子地更新一个对齐的 4 字节内存值，并同时发布被替换的值。该形式记录的摘要为：LW.UMAX atomically stores the width-sized unsigned maximum and publishes the prior memory value.
`LW` 前缀标明宽度：每次操作 4 字节内存。旧值经 `RegDst` 命名的 Reg5 目的发布，该目的可以是 GPR 或临时队列。

<!-- PTO-READER-BLOCK: scalar-lw-umax-mechanism role=mechanism -->
## 原子机制
指令契约以宽度 `4` 选择 `ScalarHandler_AtomicReadModifyWrite`，并把该操作映射到 `Atomic_UMAX`。标量分派调用 `AtomicReadModifyWrite`：对同一地址做两次预检，然后读取、合并、写回，并返回内存旧值。
`Atomic_UMAX` 比较 `UInt(old_value)` 与 `UInt(operand)`，返回较大者。
这里分派把 `write_result` 设为 `TRUE`，因此辅助函数的返回值经 `NormalizeAtomicReturn` 写入 `RegDst`。在大小为 `4` 时，该辅助函数把低 32 位符号扩展到 `PTO_XLEN`。
设计要点：两个源都在目的被写入前读出。`RegDst` 可以与 `SrcL` 相同，因此旧值可能覆盖提供地址的寄存器，但地址与操作数已被捕获，原子提交不受影响。

<!-- PTO-READER-BLOCK: scalar-lw-umax-inputs-outputs role=inputs-outputs -->
## 输入与结果
`SrcL` 是提供原子地址的 Reg5 源。`SrcR` 提供原子操作数，旧值从该地址读出，写入的值来自该地址原有的值，按无符号整数比较并保留较大者。`RegDst` 是接收内存旧值的 Reg5 目的。
`aq` 是获取位，`rl` 是释放位：二者共同为原子事件选择宽松、获取、释放或获取-释放排序。`far` 只是路由提示：`AtomicAddress` 原样返回其 `address` 参数，所以 `far` 不改变架构地址、排序或结果。
全部 32 个 Reg5 目的编码都已分配且都合法：`0` 与 `24`..`29` 丢弃发布值，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`1`..`23` 写入具名绝对 GPR。源编码 `0`..`23` 命名 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。

<!-- PTO-READER-BLOCK: scalar-lw-umax-effects role=effects -->
## 效果、发布与排序
成功执行时读出旧值、计算无符号最大值、把结果写回、记录一个原子内存事件，并在原子提交之后经 `RegDst` 发布符号扩展后的旧值。辅助函数原样返回旧值，符号扩展由调用方施加。
完成的写入会使与写入范围重叠的本地保留失效，而不会影响不重叠的保留；该判定发生在 `StoreTranslated` 内部，并以 64 字节保留粒度为依据。成功执行随后使 `TPC` 前进 `4` 字节。
设计要点：同样的 4 字节有两种处理方式。存储写入原始 32 位结果，而发布值被符号扩展到 `PTO_XLEN`，因此需要未改动的 32 位模式的程序必须读取发布值的低半部分。

<!-- PTO-READER-BLOCK: scalar-lw-umax-constraints role=constraints -->
## 合法性与精确故障
有效地址必须按 `4` 字节对齐。`ProbeDataAccess` 在查询地址翻译之前先按访问宽度比较地址，因此对齐错误先于翻译或权限故障被报告，且失败的预检报告原始架构地址。
任何故障下该指令都不发布目的值，也不加载、不存储、不记录内存事件、不更新保留、不推进 `TPC`。还存在另一种结果：两次预检都通过但解析到不同的翻译地址，此时辅助函数以原始地址置 `Fault_DataPage`，且不改动内存。
当没有任何形式能解码该 32 位模式时（本形式在掩码 `0xf000707f` 下匹配 `0x6000200b`），以及当某个具名源选择了当前无效的临时队列项时，都会在任何效果之前触发 `Fault_IllegalInstruction`。`SrcL` 的编码零读取架构零寄存器作为地址，`SrcR` 的编码零提供数值零作为操作数。
设计要点：只有整个操作成功时才写目的，因此陷入绝不会让调用方持有一个失败尝试其实并未替换掉的旧值。

<!-- PTO-READER-BLOCK: scalar-lw-umax-example role=example -->
## 非规范示例
本示例说明当前的 ASL 归属，不替代规范操作。
八种可接受写法由可选的 `.aq`、`.rl` 与 `.f` 后缀组合而成；目的也可写作 `->t` 或 `->u`。
```text
lw.umax [SrcL], SrcR, ->Rd
lw.umax.aq [SrcL], SrcR, ->Rd
lw.umax.rl [SrcL], SrcR, ->Rd
lw.umax.f [SrcL], SrcR, ->Rd
lw.umax.aqrl [SrcL], SrcR, ->Rd
lw.umax.aqf [SrcL], SrcR, ->Rd
lw.umax.rlf [SrcL], SrcR, ->Rd
lw.umax.aqrlf [SrcL], SrcR, ->Rd
```
从内存读出的低 32 位为 `0xffffffff`；`SrcR` 命名的寄存器中存放 `1`。
按无符号整数比较，内存中的值更大，因此写回 `0xffffffff`。
发布值是旧的 `0xffffffff` 经符号扩展后的 `0xffffffffffffffff`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lw.umax [SrcL], SrcR, ->Rd
lw.umax.aq [SrcL], SrcR, ->Rd
lw.umax.rl [SrcL], SrcR, ->Rd
lw.umax.f [SrcL], SrcR, ->Rd
lw.umax.aqrl [SrcL], SrcR, ->Rd
lw.umax.aqf [SrcL], SrcR, ->Rd
lw.umax.rlf [SrcL], SrcR, ->Rd
lw.umax.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lw_umax_32_3c6a5a534674 | L32 | 32 | 0x6000200b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lw_umax_32_3c6a5a534674 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lw_umax_32_3c6a5a534674 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lw_umax_32_3c6a5a534674 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lw_umax_32_3c6a5a534674 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| lw_umax_32_3c6a5a534674 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| lw_umax_32_3c6a5a534674 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lw_umax_32_3c6a5a534674 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the published old value. |
| lw_umax_32_3c6a5a534674 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| lw_umax_32_3c6a5a534674 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| lw_umax_32_3c6a5a534674 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| lw_umax_32_3c6a5a534674 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| lw_umax_32_3c6a5a534674 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LW.UMAX.asl -->
```asl
readonly func InstructionContractOperation_LW_UMAX() => ScalarOperation
begin
    return ScalarOperation_LW_UMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LW.UMAX.asl -->
```asl
readonly func InstructionContractHandler_LW_UMAX()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_LW_UMAX()
    => AtomicOperation
begin
    return Atomic_UMAX;
end;

pure func InstructionContractAtomicSizeBytes_LW_UMAX()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractPublishesOldValue_LW_UMAX()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_LW_UMAX()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the published old value.
- aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.
- far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same architectural address and atomic result.

## Legality

- All 32 Reg5 source encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 Reg5 destination encodings are assigned. Destination code 0 and destination codes 24..29 discard. Destination code 30 pushes U, destination code 31 pushes T, and codes 1..23 write the named absolute GPR.
- The effective address must be aligned to 4 bytes. aq, rl, and far have no reserved combinations.

## State effects

- Snapshot SrcL and SrcR before every memory or destination effect, so GPR and T/U source aliases observe the pre-instruction values.
- LW.UMAX computes the unsigned maximum at 32-bit width and publishes the prior memory value only after a successful atomic commit.
- The published old value is sign-extended from 32 bits to XLEN.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 4-byte little-endian value, compute the width-sized unsigned maximum, and write one 4-byte result to the same location.
- On success, record one atomic memory event. A completed overlapping write invalidates the overlapping local reservation; a nonoverlapping reservation remains valid.
- The published old value is sign-extended from 32 bits to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile and does not change ordering, address arithmetic, or the read-modify-write result.

## Exceptions

- The effective address must be aligned to 4 bytes. Alignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- Read and write access probes both complete before the memory load or store, and both probes must resolve to the same translated address.
- On a fault, the instruction publishes no destination, performs no load, store, event, reservation update, or TPC advance. Trap entry saves the original TPC and recovery restores that TPC for full reissue.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- lw.umax [a0], a1, ->a2
- lw.umax.aqrl [t#1], u#1, ->t
- lw.umax.f [sp], a0, ->u
