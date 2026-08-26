<!-- GENERATED FROM: asl/arch/memory-model/global-memory-access.asl -->
# Global Memory Access

**Normative ASL source:** `asl/arch/memory-model/global-memory-access.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-gm-access-purpose role=purpose-scope -->
## 用途与范围

本单元拥有 `TLOAD` 与 `TSTORE` 使用的跨 PE 全局内存寻址契约，包括 `B.IOR` 默认值、紧凑四位列、Shared 存储的 PE 掩码合法性以及预检边界。

<!-- PTO-READER-BLOCK: arch-gm-access-concepts role=concepts-state -->
## 地址输入

- 存在的 `B.IOR` 提供 GM 基址与字节行步长的绝对 GPR 选择器。
- 每个被选中的 PE 都在自己的私有 GPR 文件中解析这两个选择器。
- 没有 `B.IOR` 时，基址为零，步长为密集物理行宽；显式编码的零步长仍保持为零。

<!-- PTO-READER-BLOCK: arch-gm-access-rules role=rules-interactions -->
## 寻址与参与

字节地址由基址、行号乘步长以及列号乘元素大小构成。紧凑四位数据在每个字节对齐行中选择 `floor(column / 2)`，并用列号奇偶性选择半字节。

零掩码表示无操作。Shared `Function` 为 `1` 时必须使用 `'1111'`；其他情况下，只有 `Function` 为 `14` 时才接受非零子集。

`SharedStorePEMaskLegal` 实现这条掩码规则。`SharedGMPESelected` 通过 `PTOPEMaskBitOfPEIdentity` 映射 PE 标识。

<!-- PTO-READER-BLOCK: arch-gm-access-boundaries role=boundaries -->
## 预检与排序边界

所有被选中 PE 的访问都在任何效果发生前完成检查。架构不规定这些 PE 访问彼此之间的顺序，因此程序应避免冲突的 GM 区域，而不是依赖未声明的 PE 间顺序。

<!-- PTO-READER-BLOCK: arch-gm-access-example role=example-usage -->
## 非规范地址示例

本示例块只用于帮助阅读：先应用上文规则，再到规范 ASL 所有者中确认结果。它不会增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-gm-access-related role=related-owners-navigation -->
## 相关所有者

- 标量寄存器与 Core/PE 拓扑单元定义选择器和代理上下文。
- 原子性单元记录产生的内存事件；`TLOAD` 与 `TSTORE` 所有者定义具体传输。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/global-memory-access.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS","surface":"arch","classification":["memory-model","global-memory-access"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS","PTO-ARCH-MEMORY-MODEL-ATOMICITY","PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY"]}

// NDF-BEGIN: PTO-ARCH-GM-ACCESS-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// A TLOAD or TSTORE B.IOR binding MUST encode an absolute GPR selector for the
// GM base and an absolute GPR selector for row stride in bytes.
// Each selected PE MUST resolve both selectors in its private GPR file. When
// B.IOR is absent, base MUST default to zero and stride MUST default to the
// dense physical row width in bytes; an explicitly encoded zero stride MUST
// remain zero. The byte address is base + row * stride + column * element size;
// packed four-bit columns select floor(column / 2) from each byte-aligned row
// base and use column parity to select the low or high nibble.
// Shared TSTORE Function 1 MAY use any nonzero participating PE subset.
// PE_MASK zero MUST have no effect. Selected PE accesses
// MUST be preflighted before any effect, and the architecture defines no order
// among them. Programmers MUST avoid conflicting GM regions.
// NDF-END: PTO-ARCH-GM-ACCESS-001

pure func SharedStorePEMaskLegal(function: integer {0..31},
                                 pe_mask: bits(4)) => boolean
begin
    if pe_mask == Zeros{4} then return TRUE; end;
    return function == 1;
end;

pure func SharedGMPESelected(pe_mask: bits(4), pe: MemoryAgentId) => boolean
begin
    return pe_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1';
end;
```
<!-- GENERATED-ASL-END: unit -->
