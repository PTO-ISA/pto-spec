> DavinciOO 继承 Linx scalar ISA 原文页。Source: `docs/zh/isa/inst/misa_g/LUI.md`
> 本页作为 ordinary GPR / `meta_gpr` 构造能力的参考；opcode/encoding 保持 Linx v0.56。

# LUI

## 说明

高位立即数加载(*Load Upper Immediate*)  
将符号位扩展的 `20位` 立即数左移 `12位`，并将低 12 位置零后写到目的寄存器中。

## 汇编语法

```
    lui simm, ->{t, u, Rd}
```

## 汇编符号

- **simm**：20位有符号立即数。
- **->**：用于指示目的寄存器。
- **{t,u,Rd}**：表示三种可选的目的寄存器，编码于RegDst域。其中：
    - **t,u**：分别表示块内的T和U寄存器队列。
    - **Rd**：可以索引全局寄存器R1-R23。

## 编码格式

> 原 Linx 图片引用已省略；如需查看图形 bitfield，请打开本页 Source 路径对应的 Linx 原文。

## 执行方式

- 通用寄存器读写：[R\[\]](../LibPseudoCode.md)
- 对数据符号扩展：[SignExtend()](../LibPseudoCode.md)

```c
    integer datawidth = 64;
    bits(datawidth) simm = SignExtend(simm20);
    R[d, datawidth] = simm << 12;
```

## 汇编索引模式

```asm
lui simm,    ->t         /* 指令输出到块内t寄存器 */
lui simm,    ->u         /* 指令输出到块内u寄存器 */
lui simm,    ->a3        /* 指令输出到全局寄存器R1-R23 */
```

## 备注

本指令属于[基础指令集](../../instset/baseInstrs.md)，可用于任意类型的块指令块体中。
