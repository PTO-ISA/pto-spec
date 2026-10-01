<!-- GENERATED FROM: asl/scalar/amo/HL.CASB.asl -->
# HL.CASB

**Normative ASL source:** `asl/scalar/amo/HL.CASB.asl`

HL.CASB atomically compares and conditionally replaces one byte, then publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-HL-CASB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-casb-purpose role=purpose -->
## `HL.CASB` 做什么

`HL.CASB` 是一个在一次比较之下交换一个字节的 48 位标量原子形式。它把 `SrcL` 中地址处的字节与 `SrcR` 的低字节比较，并且只在相等时把 `SrcD` 的低字节写入该地址。无论结果如何，它都会把读出的字节以零扩展补齐到 64 位 `PTO_XLEN` 宽度后，通过 `RegDst` 发布。

该形式由匹配值 `0x0000600b000e` 与掩码 `0xf000707ff83f` 选出。它的访问宽度固定为 `1` 字节，处理程序是 `ScalarHandler_CompareAndSwap`。

<!-- PTO-READER-BLOCK: scalar-hl-casb-mechanism role=mechanism -->
## 字节操作的执行顺序

分派器解码 Reg5 字段，读取 `far` 位，并以 `1` 字节的宽度进入 `CompareAndSwap`：

1. `ProbeDataAccess(address, 1, 1, FALSE)` 先检查对齐，再检查读权限。
2. `ProbeDataAccess(address, 1, 1, TRUE)` 先检查对齐，再检查写权限。
3. 两个翻译后的地址不一致时抛出 `Fault_DataPage`。
4. `LoadTranslatedUnsigned` 读取被寻址的那一个字节。
5. 该字节与 `NormalizeAtomicUnsigned(SrcR, 1)` 比较，后者是零扩展的 `SrcR[7:0]`。
6. 相等时 `StoreTranslated` 写入 `SrcD[7:0]`；一个原子事件记录选定的排序与 `write_performed`，随后返回读出的字节。

设计要点：三个源都在进入 `CompareAndSwap` 之前读出，而目的地只在它返回之后才写入，因此与 `SrcR` 或 `SrcD` 相同的 `RegDst` 不会干扰这次比较。

<!-- PTO-READER-BLOCK: scalar-hl-casb-inputs-outputs role=inputs-outputs -->
## 字段、选择符与路由位

四个寄存器字段都是 Reg5 选择符：编码 `0`..`23` 命名绝对 GPR，`24`..`27` 读取 `T#1`..`T#4`，`28`..`31` 读取 `U#1`..`U#4`，且不会移除该条目。作为目的地时，`RegDst` 在 `1`..`23` 写入 GPR，在 `0` 与 `24`..`29` 丢弃，在编码 `30` 压入 `U`，在编码 `31` 压入 `T`。

| 字段 | Lsb | 宽度 | 在本指令中的角色 |
| --- | ---: | ---: | --- |
| `SrcD` | 6 | 5 | 期望写入的字节源 |
| `RegDst` | 23 | 5 | 旧值目的地 |
| `SrcL` | 31 | 5 | 原子地址源 |
| `SrcR` | 36 | 5 | 期望字节源 |
| `rl` | 41 | 1 | release 排序位 |
| `aq` | 42 | 1 | acquire 排序位 |
| `far` | 43 | 1 | 配置档路由提示 |

设计要点：`far` 从指令第 43 位译出并交给 `AtomicAddress`，后者原样返回其参数。在参考配置档中，`hl.casb.f [a0], a1, a2, ->a3` 与 `hl.casb [a0], a1, a2, ->a3` 读写相同的地址并发布相同的值；`.f` 写法只改变编码中的路由提示。

<!-- PTO-READER-BLOCK: scalar-hl-casb-effects role=effects -->
## 会改变什么

匹配时被寻址的字节收到 `SrcD[7:0]`；不匹配时内存保持不变。两条路径都把读出的字节以零扩展的 64 位值提供给 `RegDst`，因此结果永远不是负数：`0xff` 发布为 `0x00000000000000ff`。

完成的匹配还会在保留的 64 字节颗粒与所存字节重叠时使本地保留失效；不匹配不执行写入，因此不会使其失效。

设计要点：该形式编码为 48 位，分派器按 `length_bits DIV 8` 推进 `TPC`，因此一条完成的 `HL.CASB` 让程序计数器前进 6 字节。该推进只在处理程序无故障之后发生，所以故障时 `TPC` 仍停在该形式开头，恢复后重新执行同样的 6 字节。

<!-- PTO-READER-BLOCK: scalar-hl-casb-constraints role=constraints -->
## 在哪些情况下被拒绝

- 每个字段值都已分配：`SrcL`、`SrcR`、`SrcD` 和 `RegDst` 的全部 `32` 个选择符编码，以及 `aq`、`rl` 与 `far` 的全部 `8` 种组合。
- 被选中的 `T` 或 `U` 队列条目不可用时操作数非法，固定位模式无法译码时译码失败；两者都在任何架构效果之前于 `ReadPC()` 抛出 `Fault_IllegalInstruction`。
- 每个字节地址都天然对齐，因此这里的对齐检查不会报出 `Fault_DataAlignment`；边界检查仍可能报出 `Fault_DataPage`。
- 抛出故障时不向目的地提供值、不记录原子事件、不改变保留状态，也不推进 `TPC`。

设计要点：只对期望值的低字节做归一化，所以在第 `7` 位以上不同的 `SrcR` 取值与同一个内存字节比较时结果相同；低字节同为 `0x7f` 的两种编码行为一致。

<!-- PTO-READER-BLOCK: scalar-hl-casb-example role=example -->
## 一个匹配的字节，一个不匹配的字节

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

假设被寻址的字节存放 `0x7f`，`SrcR` 的低字节为 `0x7f`，`SrcD` 的低字节为 `0x80`。比较匹配，该字节变为 `0x80`，目的地收到 `0x000000000000007f`。记录的原子事件报告 `write_performed=true`。

若内存字节仍为 `0x7f`，而 `SrcR` 的低字节为 `0x7e`，比较失败：不写入任何内容，目的地仍收到 `0x000000000000007f`，事件报告 `write_performed=false`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.casb [SrcL], SrcR, SrcD, ->Rd
hl.casb.aq [SrcL], SrcR, SrcD, ->Rd
hl.casb.rl [SrcL], SrcR, SrcD, ->Rd
hl.casb.f [SrcL], SrcR, SrcD, ->Rd
hl.casb.aqrl [SrcL], SrcR, SrcD, ->Rd
hl.casb.aqf [SrcL], SrcR, SrcD, ->Rd
hl.casb.rlf [SrcL], SrcR, SrcD, ->Rd
hl.casb.aqrlf [SrcL], SrcR, SrcD, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_casb_48_21fb578617a8 | HL48 | 48 | 0x0000600b000e / 0xf000707ff83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_casb_48_21fb578617a8 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_casb_48_21fb578617a8 | SrcD | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_casb_48_21fb578617a8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_casb_48_21fb578617a8 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_casb_48_21fb578617a8 | aq | 1 | encoding-defined | [{"instruction_lsb":42,"value_lsb":0,"width":1}] |
| hl_casb_48_21fb578617a8 | far | 1 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":1}] |
| hl_casb_48_21fb578617a8 | rl | 1 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_casb_48_21fb578617a8 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| hl_casb_48_21fb578617a8 | SrcD | 5 | 0–31 | none | none | Reg5 desired byte source | Encoded zero supplies numeric zero as the desired value. |
| hl_casb_48_21fb578617a8 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| hl_casb_48_21fb578617a8 | SrcR | 5 | 0–31 | none | none | Reg5 expected byte source | Encoded zero supplies numeric zero as the expected value. |
| hl_casb_48_21fb578617a8 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| hl_casb_48_21fb578617a8 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| hl_casb_48_21fb578617a8 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 expected byte source |
| SrcD | Reg5 desired byte source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/HL.CASB.asl -->
```asl
readonly func InstructionContractOperation_HL_CASB() => ScalarOperation
begin
    return ScalarOperation_HL_CASB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/HL.CASB.asl -->
```asl
readonly func InstructionContractHandler_HL_CASB() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_HL_CASB()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractHasFarField_HL_CASB()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractZeroExtendsOldValue_HL_CASB()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_HL_CASB()
    => boolean
begin
    return FALSE;
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
- Every byte address is naturally aligned.

## State effects

- Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.
- Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.
- The 8-bit old value is zero-extended to XLEN.
- Successful execution advances TPC by 6 bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 1-byte byte and compare it with SrcR truncated to 1 bytes.
- On equality, store SrcD truncated to 1 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.
- Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.
- The 8-bit old value is zero-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.
- far changes only the route hint in the reference profile.

## Exceptions

- Every byte address is naturally aligned. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- hl.casb [a0], a1, a2, ->a3
- hl.casb.aqrlf [t#1], u#1, a0, ->u
