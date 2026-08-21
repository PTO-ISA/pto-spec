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

## Block Structure

header-form block 以 `BSTART.*` 开始，后续 header 依次补充 dimension、attribute 与 operand；下一条 `BSTART.*` 或 `BSTOP` 结束当前 block。

```asm
BSTART.TEPL TADD, FP16
B.DIM       rM, 0, ->LB0
B.DIM       rN, 0, ->LB1
B.IOT       T#1, T#3, mask=1111, last, ->T<4KB>
```

Canonical 顺序为：`BSTART`、可选 `B.DATR/B.DIM`、一次性
`B.IOS` Shared operand、`B.IOT` Local operand，以及 `B.IOR` scalar/GPR
operand。每个 opcode 的必需集合以对应指令页为准。`B.IOD` 已永久删除，
不得作为 dependency header 或保留拼写重新出现。

## Local Tile Operands

Local operand 使用 6-bit T/U/M/N producer-age namespace。v5 不提供 `.reuse`
语法。destination `TSize=001..111` 表示每个参与 PE 独立的
128 B、256 B、512 B、1 KiB、2 KiB、4 KiB 或 8 KiB；总物理容量为该值乘以
`popcount(PE_MASK)`。

```asm
B.IOT T#1, T#2, mask=1111, last, ->M<8KB>
```

同一 ordinary Local operation 内所有 `B.IOT` 使用相同的 `PE_MASK`。
它是四位 PE predicate；多位可同时为 1，`mask=0000` 是 strict no-op，
`mask=1111` 选择全部 PE。consumer 读取硬件重命名后的 Local register，
不再按 mask 选择 payload。mask 本身不建立 rendezvous 或 ordering。

## Shared Binders

B.IOS 使用 absolute `S0..S255`，是一次性 Shared operand binder。source
写作 `B.IOS S17, mask=1111`，destination 写作
`B.IOS mask=0011, ->S17<128B>`。source 的 `TSize=000`，从现有 descriptor
取得大小；destination 的 `TSize=001..111` 与 Local `B.IOT` 完全相同，表示
每个参与 PE 的 128 B–8 KiB。cooperative TMATMUL 由后续 Local B.IOT stream
按固定 role 顺序消费；Shared TLOAD/TSTORE 直接由 `B.IOS+B.IOR` 表达：

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
/* GM -> Shared; each selected PE receives one 128-byte fragment */
BSTART.TLSU TLOAD, FP16
B.IOS       mask=0101, ->S17<128B>
B.IOR       a0, a1, 0

/* Shared -> GM; source descriptor supplies the per-PE size */
BSTART.TLSU TSTORE, FP16
B.IOS       S17, mask=0101
B.IOR       a0, a1, 0
```

Shared destination size 和 mask 只由 `B.IOS` 编码；`B.IOR.RegDst` 必须为零。
Shared source 的 `TSize` 必须为零，大小来自 Shared descriptor。PTO 不定义
Local↔Shared TMOV；TLSU Function 8 是 `MGATHER.CAS`，Function 9–12 和 14
保留给 Linx-only 或未来设计。

## Coupled SYS Body

SYS 为 FALL-only 且可编程。body 紧随 `BSTART.SYS` 开始；`B.TEXT` 只用于 decoupled body。

```asm
BSTART.SYS FALL
FENCE.D.CORE4 RW, RW
BSTOP
```

允许使用 alias `DSB.CORE4 RW,RW`。包含该 collective fence 的 body 必须为 straight-line，并把 fence 放在最后；该 body 是独立的 non-speculative serialization/commit boundary。

## Header Elision and Comments

所选 opcode 不消费的 header 可以省略；必需的 dimension、attribute 与 operand 不得省略。规范性汇编示例使用 `/* ... */` 注释；仅在不表示真实 assembler 语法的说明性文本中使用 `#`。
