<!-- GENERATED FROM: asl/scalar/amo/SWAPW.asl -->
# SWAPW

**Normative ASL source:** `asl/scalar/amo/SWAPW.asl`

SWAPW atomically replaces one word and publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-SWAPW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-swapw-purpose role=purpose -->
## SWAPW 的作用

`SWAPW` 把 `SrcL` 中地址处已对齐的 `4` 字节字原子替换为 `SrcR` 的低 `32` 位，并发布被替换掉的字。

这是 `SWAP` 家族的 4 字节成员；字节、半字和双字成员分别是 `SWAPB`、`SWAPH` 和 `SWAPD`。

<!-- PTO-READER-BLOCK: scalar-swapw-mechanism role=mechanism -->
## 原子机制

指令契约返回 `ScalarHandler_AtomicReadModifyWrite`，其操作为 `Atomic_SWAP`，访问宽度为 `4` 字节。模型随后执行 `AtomicReadModifyWrite`，它对同一 `4` 字节探测读访问与写访问，并要求两次探测翻译到同一地址后才载入、替换和存储。

`SrcL` 与 `SrcR` 在任何内存或目的效果之前就被快照，而 `RegDst` 只在原子提交报告无故障之后才被写入。

由于处理程序读取的是一个 `4` 字节值，发布的旧值先由 `NormalizeAtomicReturn` 按宽度 `4` 规范化，它返回符号扩展后的字。

<!-- PTO-READER-BLOCK: scalar-swapw-inputs-outputs role=inputs-outputs -->
## 输入与结果

`SrcL` 承载 Reg5 原子地址源；`SrcR` 承载 Reg5 字替换源；`RegDst` 承载 Reg5 旧值目的；`aq` 与 `rl` 承载排序位；`far` 承载平坦地址路由提示。

`SrcL` 与 `SrcR` 的全部 `32` 个编码都已分配：编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`。

`RegDst` 的全部 `32` 个编码也都已分配。编码 `1..23` 写入所指的绝对 GPR，编码 `0` 与编码 `24..29` 丢弃旧值，编码 `30` 把它压入 `U` 队列，编码 `31` 把它压入 `T` 队列。任一源编码为零时读取架构零寄存器。

设计要点：该形式发布符号扩展的 `32` 位值，这正是 `LW` 对 `32` 位载入使用的同一套规范化。替换一侧则是截断而非扩展，因此 `SrcR` 永远不需要预先掩码到 `32` 位。

<!-- PTO-READER-BLOCK: scalar-swapw-effects role=effects -->
## 效果与排序

`aq=0,rl=0` 以宽松排序记录原子事件；`aq=1,rl=0` 选择获取，`aq=0,rl=1` 选择释放，`aq=1,rl=1` 选择获取-释放。`far=1` 只是路由提示，参考配置档保持相同的架构地址和结果。

成功时该指令恰好记录一个原子事件，更新内存，保持 `SrcL` 与 `SrcR` 不变，并让 `TPC` 前进 `4` 字节。

完成的写入在与 `64` 字节保留粒度重叠时使本地保留失效，在不同粒度上则保留该保留。

不记录任何数值状态标志。

<!-- PTO-READER-BLOCK: scalar-swapw-constraints role=constraints -->
## 合法性与精确故障

有效地址必须按 `4` 字节对齐。对齐、读翻译与权限、写翻译与权限以及翻译后地址的相等性都在效果之前检查，每次失败都报告原始地址。

`aq`、`rl` 和 `far` 的每个取值都已分配，因此没有可拒绝的保留修饰位组合。

预检失败时不发布目的值、不记录内存事件、不改变保留，也不让 `TPC` 前进；陷入入口保存原始 `TPC` 以便重新执行。

设计要点：由于目的只在无故障路径上发布，发生故障的 `SWAPW` 不会被误读为一次恰好旧值为零的成功交换。

<!-- PTO-READER-BLOCK: scalar-swapw-example role=example -->
## 非规范示例

取 `a0 = 1024`、`a1 = 7`、`a2 = 0`，并令地址 `1024` 处的 `4` 字节字存放 `5`。

`swapw [a0], a1, ->a2` 把该字替换为 `7`，并使 `a2` 存放 `5`。

之前：该字为 `5`，`a2` 为 `0`。之后：该字为 `7`，`a2` 为 `5`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
swapw [SrcL], SrcR, ->Rd
swapw.aq [SrcL], SrcR, ->Rd
swapw.rl [SrcL], SrcR, ->Rd
swapw.f [SrcL], SrcR, ->Rd
swapw.aqrl [SrcL], SrcR, ->Rd
swapw.aqf [SrcL], SrcR, ->Rd
swapw.rlf [SrcL], SrcR, ->Rd
swapw.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| swapw_32_ef15c3ebac33 | L32 | 32 | 0x2000600b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| swapw_32_ef15c3ebac33 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| swapw_32_ef15c3ebac33 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| swapw_32_ef15c3ebac33 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| swapw_32_ef15c3ebac33 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| swapw_32_ef15c3ebac33 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| swapw_32_ef15c3ebac33 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| swapw_32_ef15c3ebac33 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| swapw_32_ef15c3ebac33 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| swapw_32_ef15c3ebac33 | SrcR | 5 | 0–31 | none | none | Reg5 word replacement source | Encoded zero supplies numeric zero as the replacement. |
| swapw_32_ef15c3ebac33 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| swapw_32_ef15c3ebac33 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| swapw_32_ef15c3ebac33 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 word replacement source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SWAPW.asl -->
```asl
readonly func InstructionContractOperation_SWAPW() => ScalarOperation
begin
    return ScalarOperation_SWAPW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SWAPW.asl -->
```asl
readonly func InstructionContractHandler_SWAPW() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SWAPW()
    => AtomicOperation
begin
    return Atomic_SWAP;
end;

pure func InstructionContractAtomicSizeBytes_SWAPW()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractZeroExtendsOldValue_SWAPW()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractSignExtendsOldValue_SWAPW()
    => boolean
begin
    return TRUE;
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
- The effective address must be aligned to 4 bytes.

## State effects

- Snapshot SrcL and SrcR before any memory or destination effect.
- Publish the prior value only after successful atomic commit.
- The 32-bit old value is sign-extended to XLEN.
- Successful execution advances TPC by four bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 4-byte word, store SrcR truncated to 4 bytes, and emit one ordered atomic event.
- A successful overlapping write invalidates the local 64-byte-line reservation; a nonoverlapping write preserves it.
- The 32-bit old value is sign-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile.

## Exceptions

- The effective address must be aligned to 4 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- swapw [a0], a1, ->a2
- swapw.aqrl [t#1], u#1, ->u
- swapw.f [sp], zero, ->t
