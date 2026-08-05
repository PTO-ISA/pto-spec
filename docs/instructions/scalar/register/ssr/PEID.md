# PEID

> DavinciOO v5 scalar SSR 扩展；Linx v0.57 未分配该寄存器。

## 作用

`PEID`（Processing Element ID Register）向编译器和程序提供当前 Core 内的固定 PE 编号。它是 v5 SPMD 编程模型中 `thread_id` 的架构来源。

| 属性 | 定义 |
| --- | --- |
| SSR ID | `0x0802` |
| 地址空间 | Linx light-core custom space（`0x0800–0x08FF`） |
| 宽度 | 64 bit |
| 访问属性 | 只读（RO） |
| `[1:0]` | 当前 PE 编号：PE0–PE3 分别为 `0..3` |
| `[63:2]` | 恒为零 |

该值在一个程序实例执行期间不可变。读取无副作用，异常恢复、flush 或 replay 不得改变读取值；每条读取必须返回实际执行该指令的 PE 编号。

## 编号分配与兼容性

Linx v0.57 将 `0x0800–0x08FF` 留给 light-core 自定义 SSR，现行公开分配如下：

| SSR ID | 现有定义 |
| --- | --- |
| `0x0800` | `TR1`，每线程私有 RW 寄存器 |
| `0x0801` | `TR2`，每线程私有 RW 寄存器 |
| `0x0802` | `PEID`，DavinciOO v5 新增只读寄存器 |
| `0x0803–0x080F` | 保留 |
| `0x0810` | `SYSCNT` |
| `0x0820` | `CW` |
| `0x0830–0x083A` | `MSGBCR`、`MSGBD1–MSGBD10` |

DavinciOO、Linx v0.57 与 PTOISA 当前仓库中均没有其他 `0x0802` 分配。选择该编号不会占用 common SSR 空间，也不会与逻辑 Core ID `LXLCID=0x0021` 或 `BLOCKID=0x0051` 冲突。

## 访问与 lowering

`0x0802` 可由现有 32-bit `SSRGET` 的 12-bit SSR-ID 直接编码，不需要新增指令或使用 `HL.SSRGET`：

```asm
ssrget 0x0802, ->a0
```

C++ 源级接口为：

```cpp
uint32_t get_thread_id();
```

编译器固定将其降低为 `SSRGET PEID`，并可使用结果范围 `[0,3]` 做分析。`C.SSRGET` 仅保留 Linx 既有的 `TP`、`GP`、`EBSTATEP` 压缩映射，不增加 `PEID` form。

## 非法访问

- `SSRSET PEID` 非法并触发既有 illegal-SSR exception。
- `SSRSWAP PEID` 因包含写入而非法，并触发同一异常。
- 实现不得把非法写入静默忽略，也不得允许软件改变 `PEID`。

`PEID` 只表示 Core 内 PE rank。需要构造跨 Core 的全局编号时，软件可以显式组合 Linx `LXLCID` 与 `PEID`；`LXLCID`、`BLOCKID` 均不能替代 `PEID`。
