---
{
  "schema_version": 1,
  "id": "overview.assembly_syntax",
  "kind": "overview",
  "title": "Assembly Syntax",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": { "davincioo": "ASSEMBLY_SYNTAX.md" }
}
---
# Assembly Syntax

> Historical, non-normative material. This page is excluded from the active PTO architecture and release closure.

## Block Structure

header-form block 以 `BSTART.*` 开始，后续 header 依次补充 dimension、attribute 与 operand；下一条 `BSTART.*` 或 `BSTOP` 结束当前 block。

```asm
BSTART.TEPL TADD, FP16
B.DIM       rM, 0, ->LB0
B.DIM       rN, 0, ->LB1
B.IOT       T#1, T#3, mask=1111, last, ->T<4KB>
```

Canonical 顺序为：`BSTART`、可选 `B.DATR/B.DIM`、可选的一次性 `B.IOS`
prefix、`B.IOT/B.IOR` operand，以及可选 `B.IOD`。B.IOR 最多出现一次；
其 canonical arity 在收集完整 bundle 后由所有 schema-contributing header
共同决定。

## Local Tile Operands

Local operand 使用 6-bit T/U/M/N producer-age namespace。v5 不提供
`.reuse` 语法。destination size 表示每个 selected PE 的 128 B–8 KB；Core
allocation 为 `popcount(PE_MASK)` 倍。

```asm
B.IOT T#1, T#2, mask=1111, last, ->M<8KB>
```

同一 ordinary Local operation 内所有 `B.IOT` 使用相同的 `PE_MASK`。
Shared operation 把 `B.IOS.PE_MASK` 作为四位 PE predicate；多位可同时为 1，
`mask=0000` 是 strict no-op，`mask=1111` 选择全部 PE region。mask 本身不建立
rendezvous。

## Shared Binders

B.IOS 使用 absolute `S0..S255`，是一次性 Shared operand binder。source
写作 `B.IOS S17, mask=1111`，destination 写作
`B.IOS mask=0011, ->S17<128B>`。cooperative TMATMUL 由后续
cooperative CUBE 按固定 role 顺序消费 Shared binder；Shared TLOAD、TSTORE
和 TMOV 由选中的 TLSU operation 消费：

```asm
# non-MX, Local A
B.IOS S17, mask=1111

# non-MX, Shared A
B.IOS S16, mask=1111
B.IOS S17, mask=1111

# MX, Shared A pair
B.IOS S16, mask=1111
B.IOS S18, mask=1111
B.IOS S17, mask=1111
B.IOS S19, mask=1111
```

顺序由 Function 固定，所有 ID 必须不同。TGEMV 不允许任何 binder。

## Shared GM Forms

```asm
/* exactly-one GM -> Shared full load */
BSTART.TLSU TLOAD, FP16
B.IOS       mask=0101, ->S17<1KB>
B.IOR       a0, a1

/* exactly-one Shared -> GM full store */
BSTART.TLSU TSTORE, FP16
B.IOS       S17, mask=0101
B.IOR       a0, a1

/* per-PE Shared partition store */
BSTART.TLSU TSTORE.SPART, FP16
B.IOS       S17, mask=0101
B.IOR       a0, a1
```

`B.IOR.RegSrc0` 是 base，`RegSrc1` 是以 element 为单位的 row
stride；这两个字段与原 TLOAD/TSTORE 编码相同。Shared size/mask 不再
借用 `RegDst` 或 mask-only `B.IOT`。

## Shared TMOV Forms

```asm
BSTART.TLSU TMOV.L2S.INSERT, FP16
B.IOS       mask=1100, ->S17<1KB>
B.IOT       T#1, mask=1100, last

BSTART.TLSU TMOV.S2L.BROADCAST, FP16
B.IOS       S17, mask=1111
B.IOT       mask=1111, last, ->T<4KB>
```

TLSU Function 9–12 分别选择 Insert、Publish、Broadcast 与 Extract；Function 14 选择 partition store。

## Coupled SYS Body

SYS 为 FALL-only 且可编程。body 紧随 `BSTART.SYS` 开始；`B.TEXT` 只用于 decoupled body。

```asm
BSTART.SYS FALL
FENCE.D.CORE4 RW, RW
BSTOP
```

允许使用 alias `DSB.CORE4 RW,RW`。包含该 collective fence 的 body 必须为 straight-line，并把 fence 放在最后；该 body 是独立的 non-speculative serialization/commit boundary。

## Header Elision and Comments

每个 schema-contributing header 定义自己的 default contribution。所选
operation 不消费的 header 可以省略；必需的 dimension 与 attribute 仍以对应
指令页为准。B.IOR 可以省略，被消费的 register operand 默认使用
`zero`，除非所选 operation 定义其他缺省值；TLOAD/TSTORE 的 row
stride 缺省为 `LB2/Col`。编码值零是 `zero` selector，不是 absence marker。规范性汇编示例
使用 `/* ... */` 注释；仅在不表示真实 assembler 语法的说明性文本中使用
`#`。
