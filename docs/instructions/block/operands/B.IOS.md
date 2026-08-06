---
{
  "schema_version": 1,
  "id": "header.header-b.ios",
  "kind": "header",
  "title": "B.IOS",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Operand Bindings",
  "sources": { "davincioo": "header/B.IOS.md" }
}
---
# B.IOS

## 用途

`B.IOS` 绑定一个 Core-private Shared Tile register `S0..S255`。同一个
Core 的四个 PE 共享这 256 个绝对编号寄存器；不同 Core 的 Shared bank
互不相同。`B.IOS` 同时编码 operand role、每 PE allocation size 和本次
operation 的 PE mask。

## 汇编语法

```asm
B.IOS S17, mask=1111
B.IOS mask=0011, ->S17<001>
```

`TSize=000` 是 source form。`TSize=001..111` 是 destination form，并按
128 B、256 B、512 B、1 KiB、2 KiB、4 KiB、8 KiB 声明每个 selected PE
的容量。assembler 必须拒绝 role 与 `BSTART` schema 不一致的写法。

## 32-bit 编码

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:28]` | reserved | 4 | `0000` |
| `[27:20]` | `SharedTID` | 8 | |
| `[19]` | reserved | 1 | `0` |
| `[18:15]` | `PE_MASK` | 4 | |
| `[14:12]` | `funct3` | 3 | `001` |
| `[11:9]` | `TSize` | 3 | |
| `[8:7]` | reserved | 2 | `00` |
| `[6:0]` | opcode | 7 | `0010011` (`0x13`) |

Canonical match/mask 为 `0x00001013 / 0xf00871ff`。reserved bit 非零时该
word 不解码为 `B.IOS`。旧 16-bit `C.B.IOS` mnemonic/form 在重发的 0.58
中不再有效；它的历史 raw bit pattern 与现行 `C.B.DIMI` 重叠，因此该
bit pattern 只按 `C.B.DIMI` 解码，不保留旧 mnemonic 的来源信息。

## PE mask 与 allocation

Mask bit 使用固定 PE identity：`1000=PE0`、`0100=PE1`、`0010=PE2`、
`0001=PE3`。多位可以同时为 1，selected PE 不会向低位 pack。destination
的 Core allocation 为：

```text
popcount(PE_MASK) * per_pe_tsize_bytes
```

`PE_MASK=0000` 是 strict no-op：不 allocation、不 rename、不读 source、
不访问 memory/Shared state、不改变 descriptor/payload/lifetime，也不消费
binder 或产生 fault。

## Persistent Shared state

第一次 nonzero destination write 建立 per-PE descriptor，并把本次 mask
记录为 immutable `allocation_mask`。后续 destination write 可以更新该 mask
的 subset，但不得扩展；扩展时 compiler 必须分配新的 `Sx`。selected lane
的 descriptor-plus-payload 更新是 atomic read-modify-write。架构不保证冲突
访问的顺序，programmer 必须避免 offset 冲突。

读取未 allocation 或未初始化的 Shared lane 与读取 undefined register
相同：结果未定义，但不 trap、不 allocation、也不修改 state。

## Schema

- Shared TLOAD：一个 destination `B.IOS`；size/mask 直接来自本指令。
- Shared TSTORE/TSTORE.SPART：一个 source `B.IOS`；capacity 来自 persistent descriptor。
- Local-to-Shared TMOV：destination `B.IOS` + source-only `B.IOT`，两者 mask 相同。
- Shared-to-Local TMOV：source `B.IOS` + Local destination `B.IOT`，两者 mask 相同。
- Cooperative TMATMUL：所有 Shared binder 都是 source (`TSize=000`) 且 mask=`1111`。
- TGEMV：拒绝任何 `B.IOS`。

一个 block 最多有四个 ordered Shared binder；unconsumed ID 不得重复。成功
operation 只消费其 schema 要求的 binder。trap snapshot 保存
`SharedTID/TSize/PE_MASK/valid/consumed` 全部字段。
