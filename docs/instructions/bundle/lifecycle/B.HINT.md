---
{
  "schema_version": 1,
  "id": "header.header-b.hint",
  "kind": "header",
  "title": "B.HINT",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Lifecycle & Control",
  "sources": {
    "davincioo": "header/B.HINT.md"
  }
}
---
# B.HINT

## 说明

块提示信息(*Block Hint*)<br>
本指令可用于**一体块或分离块**的块头中对硬件执行过程传递的一些**提示信息**。

## 汇编语法

### 块信息提示

```asm
    B.HINT {BR.{likely, unlikely}, TEMP.{hot, warm, cool, none}, PRFSIZE}
```

- **BR表示跳转提示**，可选后缀包括：
    - likely代表大概率跳转；
    - unlikely代表大概率顺延。
- **TEMP表示本块指令的热度**，可选后缀包括：
    - hot代表非常热，需要保留在BCache中;
    - warm代表较热；
    - cool代表较冷;
    - none代表无热度信息。
- **PRFSIZE为预取提示**：产生预取，从当前块指令所在cacheline开始预取`PRFSIZE`个cacheline。

### 程序流起止标记

```asm
    B.HINT TRACE.{begin, end}
```

其中，**TRACE参数**表示程序流的开始或结束标记，包含两个可选后缀：
    
- **begin**：表示程序流的起始位置。
- **end**：表示程序流的结束位置。

需要额外注意的是，`B.HINT TRACE.xx`指令是一条特殊的块起始指令。其作用类似于一条`BSTART`指令，但是会 **开启一个空块**。

## 编码格式

块信息提示指令：

> 原 Linx 图片引用已省略；编码图用本页 bit-level 表格表达。

- **V**：跳转提示有效位，置1时提示有效，置0时硬件自行预测。
- **L/UL**：跳转提示标志位：0大概率顺延，1代表大概率跳转。
- **Temp**：代表本块指令的热度：
    - 11代表非常热;
    - 10代表较热;
    - 01代表较冷;
    - 00代表无热度信息。
- **Prefetch_size**用于编码PRFSIZE。

程序流起止标记指令：

> 原 Linx 图片引用已省略；编码图用本页 bit-level 表格表达。

B/E为开始或结束标志位：**0表示开始**，**1表示结束**。

## 备注

本指令在同一个块头中不允许重复定义。

## Bit-level Encoding

### `B.HINT` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:20]` | `prefetch_size` | 12 | `` |
| `[19]` | `0` | 1 | `0` |
| `[18:17]` | `temp` | 2 | `` |
| `[16]` | `L/UL` | 1 | `` |
| `[15]` | `V` | 1 | `` |
| `[14:12]` | `Func` | 3 | `0` |
| `[11:7]` | `0` | 5 | `0` |
| `[6:4]` | `Opc1` | 3 | `3` |
| `[3:1]` | `Opcode` | 3 | `1` |
| `[0]` | `W` | 1 | `1` |

### `B.HINT_1` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:16]` | `reserve` | 16 | `` |
| `[15]` | `B/E` | 1 | `` |
| `[14:12]` | `Func` | 3 | `1` |
| `[11:7]` | `0` | 5 | `0` |
| `[6:4]` | `Opc1` | 3 | `3` |
| `[3:1]` | `Opcode` | 3 | `1` |
| `[0]` | `W` | 1 | `1` |
