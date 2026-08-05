> DavinciOO 继承 Linx scalar ISA 原文页。Source: `docs/zh/isa/inst/misa_g/CLZ.md`
> 本页作为 ordinary GPR / `meta_gpr` 构造能力的参考；opcode/encoding 保持 Linx v0.56。

# CLZ

## 说明

计数前导零位(*Count Leading Zero bits*)  
从源操作数的 `M` 位开始，连续 `N` 位的范围内，从高位至低位计数遇到第一个`1`之前二进制`0`的位数，将计数结果写到目的寄存器中。

## 汇编语法

```
    clz SrcL, M, N, ->{t, u, Rd}
```

## 汇编符号

- **SrcL**：源寄存器，可以索引全局寄存器R0-R23和前序1-4条输出至T队列或U队列的指令结果。
- **M**：计数范围的起始位，取值范围为：[63, 0]。该参数编码于imms字段。
- **N**：计数范围的总位数，取值范围为：[64, 1]。该参数减1后编码于imml字段。
- **->**：用于指示目的寄存器。
- **{t,u,Rd}**：表示三种可选的目的寄存器，编码于RegDst域。其中：
    - **t,u**：分别表示块内的T和U寄存器队列。
    - **Rd**：可以索引全局寄存器R1-R23。

## 编码格式

> 原 Linx 图片引用已省略；如需查看图形 bitfield，请打开本页 Source 路径对应的 Linx 原文。

## 执行方式

- 转换为十进制数：[UInt()](../LibPseudoCode.md)
- 通用寄存器读写：[R\[\]](../LibPseudoCode.md)

```c
    integer d = UInt(RegDst);
    integer s = UInt(SrcL);
    integer M = UInt(imms);
    integer N = UInt(imml) + 1;

    bits(64) operand = R[s, datawidth];
    bits(128) newoperand = (operand << 64) | operand;

    bits(64) result = 0;
    foreach (i from (N-1) to 0 by 1 in dec) {
        if newoperand[M+i] == 0b0 then result++;
        else break;
    }

    R[d, 64] = result;
```

> 原 Linx 图片引用已省略；如需查看图形 bitfield，请打开本页 Source 路径对应的 Linx 原文。

## 汇编索引模式

指令输出到块内t寄存器:
```asm
clz a1,  m, n,    ->t             /* 单寄存器绝对索引 */
clz t#1, m, n,    ->t             /* 单寄存器相对索引 */
clz u#1, m, n,    ->t             /* 单寄存器相对索引 */
```

指令输出到块内u寄存器：
```asm
clz a1,  m, n,    ->u             /* 单寄存器绝对索引 */
clz t#1, m, n,    ->u             /* 单寄存器相对索引 */
clz u#1, m, n,    ->u             /* 单寄存器相对索引 */
```

指令输出到全局寄存器R1-R23：
```asm
clz a1,  m, n,    ->a3            /* 单寄存器绝对索引 */
clz t#1, m, n,    ->a3            /* 单寄存器相对索引 */
clz u#1, m, n,    ->a3            /* 单寄存器相对索引 */
```

## 备注

本指令属于[基础指令集](../../instset/baseInstrs.md)，可用于任意类型的块指令块体中。
