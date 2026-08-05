---
{
  "schema_version": 1,
  "id": "header.header-b.dim",
  "kind": "header",
  "title": "B.DIM",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Dimensions & Attributes",
  "sources": {
    "davincioo": "header/B.DIM.md"
  }
}
---
# B.DIM

## 说明

**B.DIM (Block Dimension)** 用于设置 block 执行维度。DavinciOO v5 superscalar profile 中，`B.DIM` 是 canonical shape/dimension header，直接采用 Linx block ISA bit-level encoding。

普通 tile op 使用 `B.DIM` 描述 PE-local valid-region / row-stride contract 或等价 loop dimension。当前 active tile profile 的默认约定为 `LB0=ValidCol`、`LB1=ValidRow`、`LB2=Col`；其中 `Col` 是 row-major Tile 中第二行起始 stride，单位为 element。Matrix/CUBE 使用 `LB0/LB1/LB2 = M/N/K`。对于 PTO valid-region 或 mask metadata，frontend / lowering 应规约为当前 block 所需的 Linx-style dimension 与 data attribute contract；当前 active profile 不引入新的 metadata header。

`B.DIM` 是按需声明的 header。一个 block 只需要编码该 opcode profile 实际消费的 `LB` register；未被消费的维度不需要用占位 `B.DIM` 填充。这样可以减少一维或低维 tile op 的 header 条数。

## 汇编格式

```asm
B.DIM RegSrc, imm, ->{LB0, LB1, LB2}
```

参数说明：

| 参数 | 说明 |
| --- | --- |
| `RegSrc` | 全局寄存器输入 |
| `imm` | unsigned immediate |
| `LB0/LB1/LB2` | 目标 loop-bound / dimension register |

每层维度值通过 `RegSrc + imm` 计算得到，只有结果低 16 bit 有效：

```c
bits(64) result = RegSrc + imm;
LBx = result[15:0];   // x = 0, 1, 2
```

## Bit-level Encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:20]` | `imm17[11:0]` | 12 |  |
| `[19:15]` | `RegSrc` | 5 |  |
| `[14:12]` | `LoopNest` | 3 |  |
| `[11:7]` | `imm17[16:12]` | 5 |  |
| `[6:4]` | `Opc1` | 3 | `4` |
| `[3:1]` | `Opcode` | 3 | `1` |
| `[0]` | `W` | 1 | `1` |

## 字段编码

### `LoopNest`

| `LoopNest` | 目的寄存器 |
| --- | --- |
| `0` | `LB0`，最内层 loop bound / dimension |
| `1` | `LB1`，中间层 loop bound / dimension |
| `2` | `LB2`，最外层 loop bound / dimension |
| `>2` | invalid |

### `imm17`

`imm17` 由 `[31:20]` 和 `[11:7]` 拼接形成。硬件计算 `RegSrc + imm17`，并将低 16 bit 写入目标 `LBx`。

## 使用约定

- 普通 tile op 的 active 约定为 `LB0=ValidCol`、`LB1=ValidRow`、`LB2=Col / row stride`，除非具体 opcode profile 另有说明。
- 一维普通 tile op 可以只声明 `LB0`，将其解释为 valid column / element count；`LB1/LB2` 可以省略。
- 二维 row-major 普通 tile op 如果需要按行访问或描述 valid-region，通常需要声明 `LB0/LB1/LB2`；`LB2` 表示 Tile 总列数 / 第二行起始 stride，单位为 element。
- 只有 opcode profile 明确不消费 `LB2` 时，二维 op 才能省略 `LB2`。
- Matrix/CUBE 使用 `LB0/LB1/LB2 = M/N/K`；这些 profile 需要完整 `M/N/K` 时不得省略对应 `B.DIM`。
- 一个 block 可以包含多条 `B.DIM`，分别设置不同 `LoopNest`。
- 如果某个 opcode profile 会读取某个 `LBx`，但该 `LBx` 既没有被 `B.DIM` 声明，也没有被该 profile 定义缺省值，则该 block 非法。
- 当前 active profile 不使用额外 metadata header 表达 shape、valid-region 或 mask。
