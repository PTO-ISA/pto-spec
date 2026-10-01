<!-- GENERATED FROM: asl/scalar/amo/SWAPH.asl -->
# SWAPH

**Normative ASL source:** `asl/scalar/amo/SWAPH.asl`

SWAPH atomically replaces one halfword and publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-SWAPH}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-swaph-purpose role=purpose -->
## SWAPH 的作用

`SWAPH` 把 `SrcL` 中地址处已对齐的 `2` 字节半字原子替换为 `SrcR` 的低 `16` 位，并发布被替换掉的半字。

这是 `SWAP` 家族的 2 字节成员；字节、字和双字成员分别是 `SWAPB`、`SWAPW` 和 `SWAPD`。

<!-- PTO-READER-BLOCK: scalar-swaph-mechanism role=mechanism -->
## 原子机制

指令契约返回 `ScalarHandler_AtomicReadModifyWrite`，其操作为 `Atomic_SWAP`，访问宽度为 `2` 字节。模型随后执行 `AtomicReadModifyWrite`，它对同一 `2` 字节探测读访问与写访问，并要求两次探测翻译到同一地址后才载入、替换和存储。

`SrcL` 与 `SrcR` 在任何内存或目的效果之前就被快照，而 `RegDst` 只在原子提交报告无故障之后才被写入。

由于处理程序读取的是一个 `2` 字节值，发布的旧值先由 `NormalizeAtomicReturn` 按宽度 `2` 规范化，它返回零扩展后的半字。

<!-- PTO-READER-BLOCK: scalar-swaph-inputs-outputs role=inputs-outputs -->
## 输入与结果

`SrcL` 承载 Reg5 原子地址源；`SrcR` 承载 Reg5 半字替换源；`RegDst` 承载 Reg5 旧值目的；`aq` 与 `rl` 承载排序位；`far` 承载平坦地址路由提示。

`SrcL` 与 `SrcR` 的全部 `32` 个编码都已分配：编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`。

`RegDst` 的全部 `32` 个编码也都已分配。编码 `1..23` 写入所指的绝对 GPR，编码 `0` 与编码 `24..29` 丢弃旧值，编码 `30` 把它压入 `U` 队列，编码 `31` 把它压入 `T` 队列。任一源编码为零时读取架构零寄存器。

设计要点：`16` 位半字填不满一个 XLEN 寄存器，因此该形式总是产生非负结果。`SWAPW` 发布的是符号扩展值，所以同一个被替换的半字经 `SWAPH` 与 `SWAPW` 读出时高位的解释可以不同。

<!-- PTO-READER-BLOCK: scalar-swaph-effects role=effects -->
## 效果与排序

`aq=0,rl=0` 以宽松排序记录原子事件；`aq=1,rl=0` 选择获取，`aq=0,rl=1` 选择释放，`aq=1,rl=1` 选择获取-释放。`far=1` 只是路由提示，参考配置档保持相同的架构地址和结果。

成功时该指令恰好记录一个原子事件，更新内存，保持 `SrcL` 与 `SrcR` 不变，并让 `TPC` 前进 `4` 字节。

完成的写入在与 `64` 字节保留粒度重叠时使本地保留失效，在不同粒度上则保留该保留。

不记录任何数值状态标志。

<!-- PTO-READER-BLOCK: scalar-swaph-constraints role=constraints -->
## 合法性与精确故障

有效地址必须按 `2` 字节对齐；不满足该要求的半字访问会在任何内存效果之前被拒绝。

`aq`、`rl` 和 `far` 的每个取值都已分配，因此没有可拒绝的保留修饰位组合。

检查顺序是固定的：先解码，再操作数合法性，然后是两次探测的对齐、翻译和权限检查。预检失败时不发布目的值、不记录内存事件、不改变保留，也不让 `TPC` 前进；陷入入口保存原始 `TPC` 以便重新执行。

设计要点：读探测与写探测是分别进行的而不是只做一次，因此该指令不会把替换提交到写路径本身不允许的位置。

<!-- PTO-READER-BLOCK: scalar-swaph-example role=example -->
## 非规范示例

取 `a0 = 1024`、`a1 = 6`、`a2 = 0`，并令地址 `1024` 处的 `2` 字节半字存放 `9`。

`swaph [a0], a1, ->a2` 把该半字替换为 `6`，并使 `a2` 存放 `9`。

之前：该半字为 `9`，`a2` 为 `0`。之后：该半字为 `6`，`a2` 为 `9`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
swaph [SrcL], SrcR, ->Rd
swaph.aq [SrcL], SrcR, ->Rd
swaph.rl [SrcL], SrcR, ->Rd
swaph.f [SrcL], SrcR, ->Rd
swaph.aqrl [SrcL], SrcR, ->Rd
swaph.aqf [SrcL], SrcR, ->Rd
swaph.rlf [SrcL], SrcR, ->Rd
swaph.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| swaph_32_8c2d4a28bf25 | L32 | 32 | 0x1000600b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| swaph_32_8c2d4a28bf25 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| swaph_32_8c2d4a28bf25 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| swaph_32_8c2d4a28bf25 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| swaph_32_8c2d4a28bf25 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| swaph_32_8c2d4a28bf25 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| swaph_32_8c2d4a28bf25 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| swaph_32_8c2d4a28bf25 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| swaph_32_8c2d4a28bf25 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| swaph_32_8c2d4a28bf25 | SrcR | 5 | 0–31 | none | none | Reg5 halfword replacement source | Encoded zero supplies numeric zero as the replacement. |
| swaph_32_8c2d4a28bf25 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| swaph_32_8c2d4a28bf25 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| swaph_32_8c2d4a28bf25 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 halfword replacement source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SWAPH.asl -->
```asl
readonly func InstructionContractOperation_SWAPH() => ScalarOperation
begin
    return ScalarOperation_SWAPH;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SWAPH.asl -->
```asl
readonly func InstructionContractHandler_SWAPH() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SWAPH()
    => AtomicOperation
begin
    return Atomic_SWAP;
end;

pure func InstructionContractAtomicSizeBytes_SWAPH()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractZeroExtendsOldValue_SWAPH()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_SWAPH()
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
- The effective address must be aligned to 2 bytes.

## State effects

- Snapshot SrcL and SrcR before any memory or destination effect.
- Publish the prior value only after successful atomic commit.
- The 16-bit old value is zero-extended to XLEN.
- Successful execution advances TPC by four bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 2-byte halfword, store SrcR truncated to 2 bytes, and emit one ordered atomic event.
- A successful overlapping write invalidates the local 64-byte-line reservation; a nonoverlapping write preserves it.
- The 16-bit old value is zero-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile.

## Exceptions

- The effective address must be aligned to 2 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- swaph [a0], a1, ->a2
- swaph.aqrl [t#1], u#1, ->u
- swaph.f [sp], zero, ->t
