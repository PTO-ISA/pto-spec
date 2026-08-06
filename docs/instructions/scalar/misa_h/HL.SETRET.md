> 本页是 PTO ISA 0.58 标量指令的规范页；opcode、encoding、操作数与语义以本页和 canonical catalog 为准。

# HL.SETRET

## 说明

设置返回地址(*Set Return Address*)
立即数左移1位(低位置零)后与当前指令的`TPC`相加，结果写到ra寄存器中。

## 汇编语法

```asm
    hl.setret uimm, ->ra
```

## 汇编符号

- **uimm**：32位无符号立即数，编码于imm32域。
- **->**：用于指示目的寄存器。
- **ra**：目的寄存器，全局寄存器ra(r10)。

## 编码格式

- 低16bit编码：

> 原 Linx 图片引用已省略；如需查看图形 bitfield，请打开本页 Source 路径对应的 Linx 原文。

- 高32bit编码：

> 原 Linx 图片引用已省略；如需查看图形 bitfield，请打开本页 Source 路径对应的 Linx 原文。

## 执行方式

- 转换为十进制数：[UInt()](../LibPseudoCode.md)
- 通用寄存器读写：[R\[\]](../LibPseudoCode.md)
- 将数据无符号扩展：[ZeroExtend()](../LibPseudoCode.md)

```c
    bits(64) uimm = ZeroExtend(imm32);
    bits(64) result = tpc + (uimm << 1);
    R[10, 64] = result;
```

## 汇编索引模式

```asm
    hl.setret uimm,    ->ra         /* 只能写到全局的ra寄存器 */
```

!!! note "注意！"

    1. 该指令**只能写全局的ra寄存器**。
    2. 该指令仅在**CALL**和**ICALL**跳转的块内使用。

## 备注

本指令属于[增强指令扩展](../../instset/haflLongInstrs.md)，，允许使用在不同块类型块内。
