<!-- GENERATED FROM: asl/scalar/amo/SWAPB.asl -->
# SWAPB

**Normative ASL source:** `asl/scalar/amo/SWAPB.asl`

SWAPB atomically replaces one byte and publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-SWAPB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-swapb-purpose role=purpose -->
## SWAPB 的作用

`SWAPB` 把 `SrcL` 中地址处的 `1` 字节值原子替换为 `SrcR` 的低 `8` 位，并发布被替换掉的字节。

这是 `SWAP` 家族的 1 字节成员。每个字节地址都是自然对齐的，因此该形式除地址必须是真实字节地址之外没有对齐限制。

<!-- PTO-READER-BLOCK: scalar-swapb-mechanism role=mechanism -->
## 原子机制

指令契约返回 `ScalarHandler_AtomicReadModifyWrite`，其操作为 `Atomic_SWAP`，访问宽度为 `1` 字节。模型随后执行 `AtomicReadModifyWrite`，它对同一 `1` 字节探测读访问与写访问，并要求两次探测翻译到同一地址后才载入、替换和存储。

`SrcL` 与 `SrcR` 在任何内存或目的效果之前就被快照，而 `RegDst` 只在原子提交报告无故障之后才被写入。

由于处理程序读取的是一个 `1` 字节值，发布的旧值先由 `NormalizeAtomicReturn` 按宽度 `1` 规范化，它返回零扩展后的字节。

<!-- PTO-READER-BLOCK: scalar-swapb-inputs-outputs role=inputs-outputs -->
## 输入与结果

`SrcL` 承载 Reg5 原子地址源；`SrcR` 承载 Reg5 字节替换源；`RegDst` 承载 Reg5 旧值目的；`aq` 与 `rl` 承载排序位；`far` 承载平坦地址路由提示。

`SrcL` 与 `SrcR` 的全部 `32` 个编码都已分配：编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`。

`RegDst` 的全部 `32` 个编码也都已分配。编码 `1..23` 写入所指的绝对 GPR，编码 `0` 与编码 `24..29` 丢弃旧值，编码 `30` 把它压入 `U` 队列，编码 `31` 把它压入 `T` 队列。任一源编码为零时读取架构零寄存器。

设计要点：`SrcR` 与 `RegDst` 宽度相同并共享同一编码空间，因此一条指令可以同时把 `T#1` 命名为替换源和目的。快照在前、目的写入在后，因此目的收到的是旧的内存字节，而不是刚刚从队列读出的值。

<!-- PTO-READER-BLOCK: scalar-swapb-effects role=effects -->
## 效果与排序

`aq=0,rl=0` 以宽松排序记录原子事件；`aq=1,rl=0` 选择获取，`aq=0,rl=1` 选择释放，`aq=1,rl=1` 选择获取-释放。`far=1` 只是路由提示，参考配置档保持相同的架构地址和结果。

成功时该指令恰好记录一个原子事件，更新内存，保持 `SrcL` 与 `SrcR` 不变，并让 `TPC` 前进 `4` 字节。

完成的写入在与 `64` 字节保留粒度重叠时使本地保留失效，在不同粒度上则保留该保留。

不记录任何数值状态标志，也不记录对任何其他位置的内存排序效果。

<!-- PTO-READER-BLOCK: scalar-swapb-constraints role=constraints -->
## 合法性与精确故障

`aq`、`rl` 和 `far` 的每个取值都已分配，因此没有可拒绝的保留修饰位组合。

检查顺序是固定的：先解码，再操作数合法性，最后是读探测与写探测。翻译和权限失败报告原始地址，并且两次探测必须在翻译后的地址上一致。

预检失败时不发布目的值、不记录内存事件、不改变保留，也不让 `TPC` 前进。陷入入口保存原始 `TPC`，因此该指令可以重新执行。

设计要点：目的只在无故障路径上写入，因此发生故障的 `SWAPB` 不会在目的寄存器里留下一个陈旧值，让软件误以为是交换前的内存字节。

<!-- PTO-READER-BLOCK: scalar-swapb-example role=example -->
## 非规范示例

取 `a0 = 1024`、`a1 = 1`、`a2 = 0`，并令地址 `1024` 处的字节存放 `5`。

`swapb [a0], a1, ->a2` 把该字节替换为 `1`，并使 `a2` 存放 `5`。

之前：该字节为 `5`，`a2` 为 `0`。之后：该字节为 `1`，`a2` 为 `5`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
swapb [SrcL], SrcR, ->Rd
swapb.aq [SrcL], SrcR, ->Rd
swapb.rl [SrcL], SrcR, ->Rd
swapb.f [SrcL], SrcR, ->Rd
swapb.aqrl [SrcL], SrcR, ->Rd
swapb.aqf [SrcL], SrcR, ->Rd
swapb.rlf [SrcL], SrcR, ->Rd
swapb.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| swapb_32_80733f03b77f | L32 | 32 | 0x0000600b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| swapb_32_80733f03b77f | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| swapb_32_80733f03b77f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| swapb_32_80733f03b77f | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| swapb_32_80733f03b77f | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| swapb_32_80733f03b77f | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| swapb_32_80733f03b77f | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| swapb_32_80733f03b77f | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| swapb_32_80733f03b77f | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| swapb_32_80733f03b77f | SrcR | 5 | 0–31 | none | none | Reg5 byte replacement source | Encoded zero supplies numeric zero as the replacement. |
| swapb_32_80733f03b77f | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| swapb_32_80733f03b77f | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| swapb_32_80733f03b77f | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 byte replacement source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SWAPB.asl -->
```asl
readonly func InstructionContractOperation_SWAPB() => ScalarOperation
begin
    return ScalarOperation_SWAPB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SWAPB.asl -->
```asl
readonly func InstructionContractHandler_SWAPB() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SWAPB()
    => AtomicOperation
begin
    return Atomic_SWAP;
end;

pure func InstructionContractAtomicSizeBytes_SWAPB()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractZeroExtendsOldValue_SWAPB()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_SWAPB()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the old value.
- aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.
- far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same architectural address and atomic result.

## Legality

- All 32 SrcL and SrcR Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.
- All aq, rl, and far combinations are assigned.
- Every byte address is naturally aligned.

## State effects

- Snapshot SrcL and SrcR before any memory or destination effect.
- Publish the prior value only after successful atomic commit.
- The 8-bit old value is zero-extended to XLEN.
- Successful execution advances TPC by four bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 1-byte byte, store SrcR truncated to 1 bytes, and emit one ordered atomic event.
- A successful overlapping write invalidates the local 64-byte-line reservation; a nonoverlapping write preserves it.
- The 8-bit old value is zero-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile.

## Exceptions

- Every byte address is naturally aligned. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- swapb [a0], a1, ->a2
- swapb.aqrl [t#1], u#1, ->u
- swapb.f [sp], zero, ->t
