<!-- GENERATED FROM: asl/arch/system-registers/context.asl -->
# Context

**Normative ASL source:** `asl/arch/system-registers/context.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-SYSTEM-REGISTERS-CONTEXT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-system-context-purpose-scope role=purpose-scope -->
## 用途与范围

本单元拥有一条算术规则以及建立在其上的两个访问辅助函数：环号与低位上下文寄存器索引如何共同选中扩展系统寄存器文件中的一个条目，以及一次读取或写入如何到达该条目。

它只覆盖寻址。哪个低位索引表示什么、哪个环可以访问给定寄存器，以及某个寄存器具体做什么，都由本站点其他所有者拥有。

<!-- PTO-READER-BLOCK: arch-system-context-concepts-state role=concepts-state -->
## 相对环的索引

`ContextRegisterIndex` 接受一个 `AccessControlRing` 和一个 0 到 4095 范围内的低位索引，返回 `ring * 4096 + low_index` 转换为 `SystemRegisterFileIndex` 的结果。

结果是 `_ExtendedSystemRegisters` 上的一个扁平索引。因为乘数是 4096，每个环拥有一个由 4096 个连续条目组成的窗口，不同环的窗口从不重叠。

`ReadContextRegister` 返回该索引处的条目。`WriteContextRegister` 用传入的 `Word` 替换同一索引处的条目。

<!-- PTO-READER-BLOCK: arch-system-context-rules-interactions role=rules-interactions -->
## 辅助函数如何相互作用

两个辅助函数通过同一个函数推导索引，因此对相同环号与低位索引的读取和写入总是访问同一个元素。

设计要点：低位索引被限制在 4095，只有环号乘以 4096，因此环号无法改变窗口内被选中的条目。一个环为某个低位索引保存的取值永远不会落到另一个环的存储上。

这两个辅助函数是本所有者定义的全部访问路径。环之间的并发、窗口的内容以及寄存器特有的副作用都不属于它们。

<!-- PTO-READER-BLOCK: arch-system-context-boundaries role=boundaries -->
## 架构边界

低位索引是环窗口内的偏移量，而不是寄存器标识。偏移量的含义来自居住在该处的寄存器的所有者：中断所有者定义中断配置、待处理中断位图和最高优先待处理中断，定时器所有者定义比较值，本页对其余每个偏移量保持沉默。

基础系统寄存器通过另一条解码路径访问，因此它们的寄存器不在本页经过这些辅助函数。

设计要点：辅助函数接受 `AccessControlRing` 而不是普通整数，因此为某个环算出的索引不能被悄悄当作另一个环的索引复用，除非经过显式转换。

<!-- PTO-READER-BLOCK: arch-system-context-example-usage role=example-usage -->
## 非规范索引示例

对于 ACR1 和低位索引 `0x0f21`，辅助函数访问 ACR1 在该偏移量处的窗口。对于 ACR2 和同一个低位索引，它们访问 ACR2 在同一偏移量处的窗口，而这两个条目并不相同。

读取 ACR1 的 `0x0f21` 永远不会返回 ACR2 在 `0x0f21` 存储的内容，这正是为某一个环写入的定时器比较值永远不会为另一个环触发的原因。

<!-- PTO-READER-BLOCK: arch-system-context-related-owners role=related-owners-navigation -->
## 相关所有者

- [访问控制](access-control.md)定义 `AccessControlRing` 与当前环状态，并且是声明的依赖项。
- [中断寄存器](interrupt.md)为通过这些辅助函数读写的各个中断偏移量赋予含义。
- [定时器寄存器](timer.md)通过同样的辅助函数为每个环存储比较值。
- [系统寄存器寻址](addressing.md)拥有由另一条解码路径到达的基础系统寄存器记录。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/system-registers/context.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-CONTEXT","surface":"arch","classification":["system-registers","context"],"depends_on":["PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL"]}
pure func ContextRegisterIndex(ring: AccessControlRing,
                               low_index: integer {0..4095})
    => SystemRegisterFileIndex
begin
    return ((ring * 4096) + low_index) as SystemRegisterFileIndex;
end;


readonly func ReadContextRegister(ring: AccessControlRing,
                                       low_index: integer {0..4095}) => Word
begin
    return _ExtendedSystemRegisters[[
        ContextRegisterIndex(ring, low_index)]];
end;

func WriteContextRegister(ring: AccessControlRing,
                               low_index: integer {0..4095}, value: Word)
begin
    _ExtendedSystemRegisters[[ContextRegisterIndex(ring, low_index)]] =
        value;
end;
```
<!-- GENERATED-ASL-END: unit -->
