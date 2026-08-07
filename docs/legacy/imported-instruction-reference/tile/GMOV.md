---
{
  "schema_version": 1,
  "id": "intrinsic.gmov",
  "kind": "intrinsic",
  "title": "GMOV Intrinsic",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "GMOV.md"
  },
  "opcode": "GMOV",
  "family": "layout-movement",
  "bundle": "BSTART.TLSU GMOV, DataType\nB.IOT source, destination, PE_MASK, TSize\nB.IOR peer_tid",
  "operands": {
    "output": "destination Local Tile",
    "input0": "source Local Tile",
    "input1": "peer_tid GPR",
    "input2": null
  },
  "dtypes": [
    "byte-preserving; source and destination descriptors must match"
  ],
  "encoding": {
    "block": "TLSU",
    "function": 13
  },
  "xlsx": {
    "include": true,
    "category": "Tile Memory Operation\nTile级访存操作",
    "subcategory": "PE间搬运",
    "order": 85,
    "description_section": "PTO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# GMOV Intrinsic

## PTO 语义来源

`GMOV` 是 DavinciOO v5 的 Core 内 PE 间 Local Tile 搬运扩展，公开接口为：

```cpp
template <typename TileDst, typename TileSrc>
PTO_INST RecordEvent GMOV(TileDst &dst, uint64_t peer_tid, TileSrc &src);
```

它从 `peer_tid` 指定 PE 的 Local `src` 读取一个完整逻辑 Tile 对应的固定 PE fragment，并写入本 PE 的 Local `dst`。传输保持字节不变，不做 dtype 转换、layout 变换、重排或广播。

`GMOV` 始终是固定 Core4 collective。它没有 `pe_scope`、`full_scope` 或 Shared 重载；`PE_MASK` 只控制哪些 PE 发出请求并写回 destination，不缩小参与者集合，也不放宽任一 source 的就绪条件。

## DavinciOO Block Intrinsic

```asm
BSTART.TLSU GMOV, DataType
B.IOT       SrcTile, mask=PE_MASK, last, ->DstTile<logical-size>
B.IOR       a0
```

- `BSTART.TLSU Function=13` 选择 `GMOV`。
- `B.IOT` 编码 source、destination、`PE_MASK` 与完整逻辑 Tile 的 `TSize`。
- `B.IOR.RegSrc0` 编码 `peer_tid`；缺省时使用 `zero`。canonical 文本使用
  ABI GPR 名而不是变量占位符。
- 每个参与 PE 实际传输该逻辑 Tile 的固定四分之一 fragment。

## 完成与事件

沿用标准 `RecordEvent`。事件完成只表示本 PE destination 已完成写回；它不建立 GM 可见性，也不替代 Core barrier 或 `SYNCALL<core_scope>()`。

## 约束与合法性

- source/destination 必须是 descriptor-compatible ordinary Local Tile；同一物理输入输出采用 read-old/write-new。
- 所有四个 PE 必须以相同动态顺序到达 collective；不收敛或 participant 不一致非法。
- SharedTile、Tile role 转换及跨 Core peer_tid 不受支持。
- 逻辑 TileAcc role 仍映射到 ordinary physical TReg；GMOV 不访问任何 hidden accumulator state。

## Lowering 摘要

编译器验证 Core4 收敛性与 descriptor 相等性，分配 Local destination，并生成 `BSTART.TLSU Function 13 + B.IOT + B.IOR`。`peer_tid` 保持运行时 GPR 输入，但其值域由硬件执行精确检查。
