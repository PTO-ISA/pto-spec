<!-- GENERATED FROM: asl/scalar/amo/LD.XOR.asl -->
# LD.XOR

**Normative ASL source:** `asl/scalar/amo/LD.XOR.asl`

LD.XOR atomically stores the width-sized bitwise XOR and publishes the prior memory value.

## Normative identity {#PTO-INST-SCALAR-LD-XOR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ld-xor-purpose role=purpose -->
## LD.XOR 的作用

`LD.XOR` 翻转一个 8 字节内存双字中被选中的位。64 位操作数中为 `1` 的每一位在存储值中被取反，为 `0` 的位则保持已存储的位不变，而指令执行前的双字通过 `RegDst` 发布。

<!-- PTO-READER-BLOCK: scalar-ld-xor-mechanism role=mechanism -->
## 如何翻转目标双字

该形式选择 `ScalarHandler_AtomicReadModifyWrite`、访问宽度 `8` 和原子操作 `Atomic_XOR`。读取预检与写入预检都在加载之前完成；随后旧双字与 `SrcR` 做异或，64 位结果存储到同一地址，记录一个 `write_performed` 为 true 的原子事件，并返回旧双字以便发布。

异或覆盖全部 64 位且没有截断：存放 `0x000000000000ff00` 的位置与 `SrcR = 0x0000000000000f0f` 异或后存放 `0x000000000000f00f`。

设计要点：异或是自身的逆运算。对同一位置用同一个操作数执行两次，存储的位会与第一次执行前一模一样，但第二次执行仍然会存储，并仍然通过 `RegDst` 发布翻转后的中间值。

设计要点：操作数与地址在任何内存或目的地效果之前就被快照，因此 `RegDst` 可以与 `SrcR` 是同一个寄存器；异或所用的掩码是执行前的寄存器内容。

<!-- PTO-READER-BLOCK: scalar-ld-xor-inputs-outputs role=inputs-outputs -->
## 字段与操作数角色

`RegDst` 是位于指令位 `7..11` 的 `5` 位字段，`SrcL` 位于位 `15..19`，`SrcR` 位于位 `20..24`，`rl` 位于位 `25`，`aq` 位于位 `26`，`far` 位于位 `27`。

- `SrcL` 读取原子地址；编码为零时读取架构零寄存器。
- `SrcR` 读取翻转掩码；编码为零时提供数值零，从而保持每一个已存储的位不变。

设计要点：`aq` 与 `rl` 为事件选择宽松、获取、释放或获取-释放排序，而 `far` 被交给 `AtomicAddress`，后者原样返回其参数。因此在参考模型中，`ld.xor [a0], a1, ->a2` 与 `ld.xor.f [a0], a1, ->a2` 得到相同地址和相同的存储位。

<!-- PTO-READER-BLOCK: scalar-ld-xor-effects role=effects -->
## 效果

一次完成的 `LD.XOR` 写入 8 字节、记录一个 `write_performed` 为 true 的原子事件、把执行前的双字送到 `RegDst`，并让 `TPC` 前进 4 字节。若写入范围与保留的 64 字节粒度重叠，本地保留会被清除。

设计要点：掩码为零时仍然会把旧的位写回，并仍然记录一次已执行的写入，因此内存内容不变，而保留与事件效果并非不变。

<!-- PTO-READER-BLOCK: scalar-ld-xor-constraints role=constraints -->
## 合法性与故障

地址必须是 8 的倍数。对齐检查在读取预检内部、翻译之前、加载之前运行，写入预检会为写访问重复同样的检查。`Fault_DataAlignment` 与 `Fault_DataPage` 都在原始（翻译前）地址上报告。

故障不会碰该双字：不写目的地、不记录原子事件、不改变保留，也不推进 `TPC`，因此该指令可以重新执行。译码失败或所选 T 或 U 源不可用会更早引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: scalar-ld-xor-example role=example -->
## 非规范示例

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

当 `a0` 存放 8 字节对齐的地址时，`ld.xor [a0], a1, ->a2` 翻转由 `a1` 选中的位。若 `[a0]` 存放 `0x000000000000ff00` 且 `a1` 存放 `0x0000000000000f0f`，该位置得到 `0x000000000000f00f`，`a2` 得到 `0x000000000000ff00`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ld.xor [SrcL], SrcR, ->Rd
ld.xor.aq [SrcL], SrcR, ->Rd
ld.xor.rl [SrcL], SrcR, ->Rd
ld.xor.f [SrcL], SrcR, ->Rd
ld.xor.aqrl [SrcL], SrcR, ->Rd
ld.xor.aqf [SrcL], SrcR, ->Rd
ld.xor.rlf [SrcL], SrcR, ->Rd
ld.xor.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ld_xor_32_33072c0fde61 | L32 | 32 | 0x3000400b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ld_xor_32_33072c0fde61 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ld_xor_32_33072c0fde61 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ld_xor_32_33072c0fde61 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| ld_xor_32_33072c0fde61 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| ld_xor_32_33072c0fde61 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| ld_xor_32_33072c0fde61 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ld_xor_32_33072c0fde61 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the published old value. |
| ld_xor_32_33072c0fde61 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| ld_xor_32_33072c0fde61 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| ld_xor_32_33072c0fde61 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| ld_xor_32_33072c0fde61 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| ld_xor_32_33072c0fde61 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LD.XOR.asl -->
```asl
readonly func InstructionContractOperation_LD_XOR() => ScalarOperation
begin
    return ScalarOperation_LD_XOR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LD.XOR.asl -->
```asl
readonly func InstructionContractHandler_LD_XOR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_LD_XOR()
    => AtomicOperation
begin
    return Atomic_XOR;
end;

pure func InstructionContractAtomicSizeBytes_LD_XOR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractPublishesOldValue_LD_XOR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_LD_XOR()
    => boolean
begin
    return FALSE;
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
- The effective address must be aligned to 8 bytes. aq, rl, and far have no reserved combinations.

## State effects

- Snapshot SrcL and SrcR before every memory or destination effect, so GPR and T/U source aliases observe the pre-instruction values.
- LD.XOR computes the bitwise XOR at 64-bit width and publishes the prior memory value only after a successful atomic commit.
- The published result is the unchanged 64-bit old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 8-byte little-endian value, compute the width-sized bitwise XOR, and write one 8-byte result to the same location.
- On success, record one atomic memory event. A completed overlapping write invalidates the overlapping local reservation; a nonoverlapping reservation remains valid.
- The published result is the unchanged 64-bit old value.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile and does not change ordering, address arithmetic, or the read-modify-write result.

## Exceptions

- The effective address must be aligned to 8 bytes. Alignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- Read and write access probes both complete before the memory load or store, and both probes must resolve to the same translated address.
- On a fault, the instruction publishes no destination, performs no load, store, event, reservation update, or TPC advance. Trap entry saves the original TPC and recovery restores that TPC for full reissue.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- ld.xor [a0], a1, ->a2
- ld.xor.aqrl [t#1], u#1, ->t
- ld.xor.f [sp], a0, ->u
