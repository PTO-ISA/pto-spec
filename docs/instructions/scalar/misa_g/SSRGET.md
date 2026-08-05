> 本页是 PTO ISA 0.58 标量指令的规范页；opcode、encoding、操作数与语义以本页和 canonical catalog 为准。

# SSRGET

## 说明

读取系统寄存器(*System Status Register Get*)
读取 **SSR-ID** 对应系统寄存器中的值并写到目的寄存器中。

## 汇编语法

```
    ssrget SSR-ID, ->{t, u, Rd}
```

## 汇编符号

- **SSR-ID**：12位系统寄存器索引ID，默认SSR-ID[15:12]为0。映射关系请见[系统寄存器](../../register/ssr/ssrintro.md)介绍章节。
- **->**：用于指示目的寄存器。
- **{t,u,Rd}**：表示三种可选的目的寄存器，编码于RegDst域。其中：
    - **t,u**：分别表示块内的T和U寄存器队列。
    - **Rd**：可以索引全局寄存器R1-R23。

## 编码格式

> 原 Linx 图片引用已省略；如需查看图形 bitfield，请打开本页 Source 路径对应的 Linx 原文。

SSR-ID的映射表请见[系统寄存器](../../register/ssr/ssrintro.md)介绍。

## 执行方式

- 转换为十进制数：[UInt()](../LibPseudoCode.md)
- 通用寄存器读写：[R\[\]](../LibPseudoCode.md)
- 系统寄存器读写：[SSR\[\]](../LibPseudoCode.md)

```c
    integer d = UInt(RegDst);

    bits(datawidth) data = SSR[SSR-ID];
    R[d, datawidth] = data;
```

## 汇编索引模式

指令输出到块内t寄存器:
```asm
ssrget SSR-ID,           ->t
```

指令输出到块内u寄存器：
```asm
ssrget SSR-ID,           ->u
```

指令输出到全局寄存器R1-R23：
```asm
ssrget SSR-ID,           ->a3
```

## 注意事项

1. 本指令只能访问SSR-ID[15:12]为0的系统寄存器。
2. 如果访问SSR-ID[15:12]不为0的系统寄存器，需使用48bit的[HL.SSRGET](../misa_h/HL.SSRGET.md)指令。

## DavinciOO v5 扩展

DavinciOO v5 在 Linx light-core 自定义空间分配只读 [PEID](../register/ssr/PEID.md)，SSR ID 为 `0x0802`。该编号可由本指令的 12-bit `SSR-ID` 直接编码：

```asm
ssrget 0x0802, ->a0    # a0 = 当前 PE 编号 0..3
```

源级 `get_thread_id()` 固定降低为该读取。`C.SSRGET` 的既有压缩映射不增加 `PEID`，因此不能用压缩 form 读取它。

## 备注

本指令属于[基础指令集](../../instset/baseInstrs.md)，可用于任意类型的块指令块体中。
