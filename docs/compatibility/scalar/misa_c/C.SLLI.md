> DavinciOO 继承 Linx scalar ISA 原文页。Source: `docs/zh/isa/inst/misa_c/C.SLLI.md`
> 本页作为 ordinary GPR / `meta_gpr` 构造能力的参考；opcode/encoding 保持 Linx v0.57。

# C.SLLI

## 说明

T寄存器逻辑左移立即数(*Shift Left Logical by Immediate*)
将前序T队列中指令结果逻辑左移（低位补零，高位舍弃）立即数指示的位数，结果写到T寄存器队列。

本指令的标准形式请见[SLLI](../misa_g/SLLI.md)。

## 汇编语法

```asm
    c.slli t#1, uimm, ->t
```

## 汇编符号

- **t#1**：源寄存器，索引前序第一条输出至T寄存器队列的指令结果。
- **uimm**：对操作数移动位数，范围[0, 31]。
- **->**：用于指示目的寄存器。
- **t**：目的寄存器，代表块内的T寄存器队列。

## 编码格式

> 原 Linx 图片引用已省略；如需查看图形 bitfield，请打开本页 Source 路径对应的 Linx 原文。

## 执行方式

- 转换为十进制数：[UInt()](../LibPseudoCode.md)

```c
    integer datawidth = 64;
    interger uimm = UInt(uimm5);

    bits(datawidth) operand = TR1[63:0];
    bits(datawidth) result = operand << uimm;

    T[id] = result;
```

## 汇编索引模式

```asm
    c.slli  t#1, uimm, ->t               /*单寄存器相对索引*/
```

## 备注

本指令属于[压缩指令扩展](../../instset/compressInstrs.md)，仅在使能了压缩扩展的处理器中支持使用。
