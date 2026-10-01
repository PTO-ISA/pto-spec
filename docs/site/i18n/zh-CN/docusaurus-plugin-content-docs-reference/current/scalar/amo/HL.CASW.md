<!-- GENERATED FROM: asl/scalar/amo/HL.CASW.asl -->
# HL.CASW

**Normative ASL source:** `asl/scalar/amo/HL.CASW.asl`

HL.CASW atomically compares and conditionally replaces one word, then publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-HL-CASW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-casw-purpose role=purpose -->
## `HL.CASW` 做什么

`HL.CASW` 有条件地替换 `SrcL` 中地址处的 32 位字。它把该字与 `SrcR` 的低字比较，并且只在两者相等时存入 `SrcD` 的低字。无论结果如何，内存原先持有的字都会通过 `RegDst` 发布，并且该发布值是符号扩展补齐到 64 位 `PTO_XLEN` 宽度，而不是零扩展。

该形式由匹配值 `0x2000600b000e` 与掩码 `0xf000707ff83f` 选出。它的访问宽度为 `4` 字节，因此两次预检都要求地址是 `4` 的倍数，处理程序是 `ScalarHandler_CompareAndSwap`。

<!-- PTO-READER-BLOCK: scalar-hl-casw-mechanism role=mechanism -->
## 先比较，再写入

分派器让 `SrcL` 经过 `ScalarDecodedAtomicAddress`，后者读取该寄存器与 `far` 位并调用 `AtomicAddress`。随后 `CompareAndSwap` 以 `4` 字节宽度执行：

- 读预检测试 `UInt(address) MOD 4`，再检查读权限；写预检对同一地址重复这两项测试。
- 两个翻译后的地址不一致时抛出 `Fault_DataPage`。
- `LoadTranslatedUnsigned` 把四个字节读成一个 32 位字。
- 该字与 `NormalizeAtomicUnsigned(SrcR, 4)` 比较，后者是零扩展的 `SrcR[31:0]`。
- 相等时 `StoreTranslated` 写入 `SrcD` 的低四个字节。一个原子事件记录选定的排序与是否发生写入，随后返回读出的字。

设计要点：只有 `SrcR` 的低 `32` 位进入比较，因此 `SrcR = 0xdeadbeef00000001` 会匹配内存字 `0x00000001`；高 `32` 位无法携带比较所检查的标记。

<!-- PTO-READER-BLOCK: scalar-hl-casw-inputs-outputs role=inputs-outputs -->
## 字段与路由位

- `SrcD` 位于指令第 6 位，宽度 `5`：要写入的字源。
- `RegDst` 位于指令第 23 位，宽度 `5`：旧值的目的地。
- `SrcL` 位于指令第 31 位，宽度 `5`：原子地址源。
- `SrcR` 位于指令第 36 位，宽度 `5`：期望字源。
- `rl` 位于指令第 41 位：release 排序位。
- `aq` 位于指令第 42 位：acquire 排序位。
- `far` 位于指令第 43 位：配置档路由提示。

设计要点：`far` 位于 `aq` 与 `rl` 位之上，并被交给 `AtomicAddress`，后者原样返回其参数。因此包括 `hl.casw.f`、`hl.casw.aqf`、`hl.casw.rlf` 与 `hl.casw.aqrlf` 在内的全部 `8` 种规范写法都选择同一个形式并访问同一个字：`.f` 写法把 `far=1` 编码，在参考配置档中既不改变地址，也不改变写入值或发布值。

<!-- PTO-READER-BLOCK: scalar-hl-casw-effects role=effects -->
## 发布值与内存

匹配时该地址处的四个字节变成 `SrcD` 的低四个字节；不匹配时它们保持不变。匹配的写入在所存四个字节与保留的 64 字节颗粒重叠时使本地保留失效。

设计要点：发布值采用符号扩展，因此第 `31` 位为 1 的字会变成负的 64 位值：内存字 `0x80000001` 发布为 `0xffffffff80000001`。比较是无符号的，因为两侧都做零扩展，所以同一个 `0x80000001` 会精确匹配；需要零扩展副本的程序必须自行对发布值做掩码。

<!-- PTO-READER-BLOCK: scalar-hl-casw-constraints role=constraints -->
## 合法性与故障

`SrcL`、`SrcR`、`SrcD` 和 `RegDst` 的全部 `32` 个选择符编码都已分配，`aq`、`rl` 与 `far` 的每一种组合都能译码为该形式。`T` 或 `U` 队列条目不可用时操作数非法，固定位模式无法译码时译码失败；两者都在任何架构效果之前于 `ReadPC()` 抛出 `Fault_IllegalInstruction`。

地址必须是 `4` 的倍数；否则读预检以原始地址报出 `Fault_DataAlignment`。预检故障不发布目的地值、不记录原子事件、不改变保留状态，也不推进 `TPC`。

设计要点：决定步长的是 48 位编码本身。分派器加上 `length_bits DIV 8`，对 `HL.CASW` 而言是 6，因此下一条指令从本条之后 6 字节开始，发生故障的实例会重新执行同样的 6 字节。

<!-- PTO-READER-BLOCK: scalar-hl-casw-example role=example -->
## 交换一个看起来为负的字

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

当 `SrcL` 处的字等于 `0x80000001`、`SrcR` 的低字等于 `0x80000001`、`SrcD` 的低字等于 `0x55667788` 时，比较匹配：四个字节变成 `0x55667788`，`RegDst` 收到 `0xffffffff80000001`，事件报告 `write_performed=true`。

当 `SrcR` 的低字等于 `0x00000002` 时，比较失败：内存保持 `0x80000001`，`RegDst` 仍收到 `0xffffffff80000001`，事件报告 `write_performed=false`。而 `SrcR = 0xdeadbeef00000001` 与内存字 `0x00000001` 的情形表明，`SrcR` 的高位不在比较范围内。

```asm
hl.casw.aqrlf [a0], a1, a2, ->a3
hl.casw.aqrl [a0], a1, a2, ->a3
```
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.casw [SrcL], SrcR, SrcD, ->Rd
hl.casw.aq [SrcL], SrcR, SrcD, ->Rd
hl.casw.rl [SrcL], SrcR, SrcD, ->Rd
hl.casw.f [SrcL], SrcR, SrcD, ->Rd
hl.casw.aqrl [SrcL], SrcR, SrcD, ->Rd
hl.casw.aqf [SrcL], SrcR, SrcD, ->Rd
hl.casw.rlf [SrcL], SrcR, SrcD, ->Rd
hl.casw.aqrlf [SrcL], SrcR, SrcD, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_casw_48_a89b3d58d8f0 | HL48 | 48 | 0x2000600b000e / 0xf000707ff83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_casw_48_a89b3d58d8f0 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_casw_48_a89b3d58d8f0 | SrcD | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_casw_48_a89b3d58d8f0 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_casw_48_a89b3d58d8f0 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_casw_48_a89b3d58d8f0 | aq | 1 | encoding-defined | [{"instruction_lsb":42,"value_lsb":0,"width":1}] |
| hl_casw_48_a89b3d58d8f0 | far | 1 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":1}] |
| hl_casw_48_a89b3d58d8f0 | rl | 1 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_casw_48_a89b3d58d8f0 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| hl_casw_48_a89b3d58d8f0 | SrcD | 5 | 0–31 | none | none | Reg5 desired word source | Encoded zero supplies numeric zero as the desired value. |
| hl_casw_48_a89b3d58d8f0 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| hl_casw_48_a89b3d58d8f0 | SrcR | 5 | 0–31 | none | none | Reg5 expected word source | Encoded zero supplies numeric zero as the expected value. |
| hl_casw_48_a89b3d58d8f0 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| hl_casw_48_a89b3d58d8f0 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| hl_casw_48_a89b3d58d8f0 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 expected word source |
| SrcD | Reg5 desired word source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/HL.CASW.asl -->
```asl
readonly func InstructionContractOperation_HL_CASW() => ScalarOperation
begin
    return ScalarOperation_HL_CASW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/HL.CASW.asl -->
```asl
readonly func InstructionContractHandler_HL_CASW() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_HL_CASW()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractHasFarField_HL_CASW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractZeroExtendsOldValue_HL_CASW()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractSignExtendsOldValue_HL_CASW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, SrcD, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the old value.
- aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.
- far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same address and atomic result.

## Legality

- All 32 SrcL, SrcR, and SrcD Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.
- All aq, rl, and far combinations are assigned.
- The effective address must be aligned to 4 bytes.

## State effects

- Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.
- Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.
- The 32-bit old value is sign-extended to XLEN.
- Successful execution advances TPC by 6 bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 4-byte word and compare it with SrcR truncated to 4 bytes.
- On equality, store SrcD truncated to 4 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.
- Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.
- The 32-bit old value is sign-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.
- far changes only the route hint in the reference profile.

## Exceptions

- The effective address must be aligned to 4 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- hl.casw [a0], a1, a2, ->a3
- hl.casw.aqrlf [t#1], u#1, a0, ->u
