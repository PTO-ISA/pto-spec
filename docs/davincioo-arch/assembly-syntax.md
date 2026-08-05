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

Canonical 顺序为：`BSTART`、可选 `B.DATR/B.DIM`、可选的一次性 `C.B.IOS` prefix、`B.IOT/B.IOR` operand，以及可选 `B.IOD`。每个 opcode 的必需集合以对应指令页为准。

## Local Tile Operands

Local operand 使用 6-bit T/U/M/N producer-age namespace。v5 不提供 `.reuse` 语法。destination size 表示 512 B–32 KB 的完整 logical Tile；每个 PE 获得四分之一 payload。

```asm
B.IOT T#1, T#2, mask=1111, last, ->M<8KB>
```

同一 block 内所有 `B.IOT` 必须使用相同且非零的 `PE_MASK`。`mask=1111` 表示四个 Local payload 都执行，但本身不会建立 rendezvous。

## Shared Binders

C.B.IOS S#n 是一次性 Shared operand binder。cooperative TMATMUL 由后续
Local B.IOT stream 按固定 role 顺序消费；Shared TLOAD/TSTORE 由 B.IOR
消费，Shared TMOV 由 B.IOT companion 消费：

```asm
# non-MX, Local A
C.B.IOS S#right

# non-MX, Shared A
C.B.IOS S#left
C.B.IOS S#right

# MX, Shared A pair
C.B.IOS S#left
C.B.IOS S#scale_left
C.B.IOS S#right
C.B.IOS S#scale_right
```

顺序由 Function 固定，所有 ID 必须不同。TGEMV 不允许任何 binder。

## Shared GM Forms

```asm
/* exactly-one GM -> Shared full load */
BSTART.TLSU TLOAD, FP16
C.B.IOS     S#17
B.IOR       a0, a1, 0, ->SharedTSize<4KB>

/* exactly-one Shared -> GM full store */
BSTART.TLSU TSTORE, FP16
C.B.IOS     S#17
B.IOR       a0, a1, 0

/* per-PE Shared partition store */
BSTART.TLSU TSTORE.SPART, FP16
C.B.IOS     S#17
B.IOR       a0, a1, 0
```

GM→Shared 把 `B.IOR.RegDst[11:9]` 解释为 `SharedTSize`，其中 `000` 非法。Shared store 要求整个 RegDst 字段为零。

## Shared TMOV Forms

```asm
BSTART.TLSU TMOV.L2S.INSERT, FP16
C.B.IOS     S#17
B.IOT       T#1, mask=1100, TSize=4KB, last

BSTART.TLSU TMOV.S2L.BROADCAST, FP16
C.B.IOS     S#17
B.IOT       mask=1111, last, ->T<16KB>
```

TLSU Function 8–11 分别选择 Insert、Publish、Broadcast 与 Extract；Function 12 选择 partition store。

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
