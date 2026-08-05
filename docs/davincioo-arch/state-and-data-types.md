---
{
  "schema_version": 1,
  "id": "overview.state_and_types",
  "kind": "overview",
  "title": "State and Data Types",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": { "davincioo": "STATE_AND_TYPES.md" }
}
---
# State and Data Types

## Logical Size and Physical Payload

| 对象 | 架构大小 | 物理 payload |
| --- | ---: | ---: |
| 普通 logical Tile | 512 B–32 KB | 四个固定的 128 B–8 KB PE fragment |
| Local Tile fragment | logical size / 4 | 单 PE 的 TReg payload |
| Shared register | 512 B–32 KB descriptor capacity | Core-local persistent S0–S255 storage |

`PE_MASK` 不改变 logical size，也不改变四分之一 fragment 的大小。

The executable ASL models the full direct `S0`–`S255` bank. All four PEs in one
core access the same bank; each other core has a private bank.

## Storage and Distribution

Storage class 为 `Local` 或 `Shared`。Distribution 独立描述 logical coordinate 到 PE fragment 的映射，例如 LinearShard4、AxisShard4、MShard4 或静态 partial definition。`Shared` 不是 distribution；broadcast 后内容相同也不形成 `Replicated4` 类型。

## Local T/U/M/N Namespaces

Local source 保留 Linx 6-bit T/U/M/N namespace，即四个深度为 16 的 architectural producer-age window。在 v5 中：

- destination commit 追加 `Q#1`，并推进已有 entry 的 age；
- source operand 只执行绑定，不弹出或压缩 window；
- 不存在 `.reuse` 或 selective source release；
- 已老化出窗口的 architectural version 不能再被后续指令命名；
- 对应 physical payload 仅在所有已绑定 reader 完成后回收；
- masked-off execution 仍推进 metadata，并创建不可读取的 placeholder。

## SharedTile C++ Type

```cpp
SharedTile<TileLeft<...>>
SharedTile<TileLeftScale<...>>
SharedTile<TileRight<...>>
SharedTile<TileRightScale<...>>
```

这些 role 只用于 cooperative TMATMUL。A/ScaleA 同为 Local 或同为 Shared，B/ScaleB 同为 Shared；Shared A 配 Local B 非法。TGEMV、Bias、C、D、max output 与 PostProcess parameter 不接受 SharedTile。

## Shared Architectural and Physical State

C++ source 不直接命名 `Sx`。编译器分配 8-bit absolute Shared index。每个
register 保存 descriptor、payload 和四位 initialization mask，并跨 block
持久存在直到 overwrite 或 core reset。source read 不修改这些状态。

destination 使用 one-step atomic read-modify-write。partial initialized write
要求 descriptor compatible；partial uninitialized write 建立 descriptor；full
`1111` write 可整体替换；`0000` 是 no-op。并发 overlap 没有 architecture
order，属于 programmer error/undefined behavior，hardware 不要求检测。

## Partial and Fully Initialized Shared Registers

- Insert/Publish 可以构造静态 partial value。
- Partial value 只能参与搬运和 TSTORE<pe_scope>。
- uninitialized quarter read 合法，返回 undefined-register value，不产生 trap。
- Shared A 使用 MShard4；它不等价于 broadcast 或 Replicated4。
- 全部 defined region ready 后，full publication 原子生效。

## Logical TileAcc Role

DavinciOO v5 不定义 architectural implicit ACC。PTO C++/SSA 可以用逻辑 TileAcc role 标记 AccType partial sum，但 backend 将其分配为 ordinary physical Local TReg。base/BIAS/ACC 都显式写 D；ACC variant 显式读取 C。

canonical None 且没有 quant/convert/ReLU 时，D 保持 TileAcc role；RowMax/GroupMax 不改变该角色。D==C 仅在 dtype、shape、layout、allocation 完全一致时允许，并采用 read-old/rename-new。

## PTO-AS Types

```text
!pto.tile<AccRole, ...>
!pto.shared_tile<!pto.tile<Left, ...>>
!pto.shared_tile<!pto.tile<ScaleLeft, ...>>
!pto.shared_tile<!pto.tile<Right, ...>>
!pto.shared_tile<!pto.tile<ScaleRight, ...>>
```

verifier 根据 storage role、operation family 与 compile-time PostProcessConfig 判断合法性；TileAcc 是逻辑 role，不对应独立 architectural register file。
