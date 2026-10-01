<!-- GENERATED FROM: asl/arch/memory-model/global-memory-access.asl -->
# Global Memory Access

**Normative ASL source:** `asl/arch/memory-model/global-memory-access.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-gm-access-purpose role=purpose-scope -->
## 目的与范围

本单元拥有 `TLOAD`、`TSTORE` 以及 Shared store 形式所依赖的跨 PE 全局内存寻址契约。在该契约之中，它实现的是谓词部分：Shared store 的各功能号接受哪些 `PE_MASK` 取值，以及某个掩码位命名的是哪个 PE。

该契约为 `PTO-ARCH-GM-ACCESS-001`。本单元有两个可执行函数，自身没有状态；它所述的地址算术与预检位于传输执行体与步长助手函数中。

<!-- PTO-READER-BLOCK: arch-gm-access-concepts role=concepts-state -->
## 地址输入与参与状态

- 存在 `B.IOR` 时，它提供 GM base 的绝对 GPR 选择子与以字节为单位的行步长的绝对 GPR 选择子；每个被选中的 PE 在自己的私有 GPR 文件中解析这两个选择子。
- 没有 `B.IOR` 时，base 默认为零，步长默认为稠密物理行宽字节数；显式编码的零步长保持为零，而不是变成默认值。
- 字节地址是 `base + row * stride + column * element size`。
- 打包的四位列改为在每个按字节对齐的行基址上取 `floor(column / 2)`，并用列奇偶选择低半字节或高半字节。
- `SharedStorePEMaskLegal` 与 `SharedGMPESelected` 是 `pure func` 谓词：它们不读任何架构状态，因此一次 Shared store 的掩码合法性只取决于它的功能号与四位掩码。
- 这些谓词收到的掩码来自 `_BundleSharedBindings`：`asl/block/model/dispatch/shared-tlsu.asl` 传入 `shared_mask`，而 `PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY` 拥有 `PTOPEMaskBitOfPEIdentity`。

<!-- PTO-READER-BLOCK: arch-gm-access-rules role=rules-interactions -->
## 掩码规则与 PE 选择

`SharedStorePEMaskLegal(function, pe_mask)` 在 `pe_mask` 为 `Zeros{4}` 时返回真，否则返回 `function == 1`。请仔细读第二个分支：它并不检验掩码是否为全一。非零子集对功能号 `1` 被接受，对任何其他功能号都不被接受，而其他每个功能号只接受全零掩码。

`SharedGMPESelected(pe_mask, pe)` 返回 `pe_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1'`，因此掩码位 `3` 是 PE0，掩码位 `0` 是 PE3。

设计要点：零掩码对每个功能号都合法，因为它在该功能号判定之前就被处理；而非零子集只对功能号 `1` 合法。因此，用功能号 `14` 加子集掩码写出的 Shared store 会被调用者作为 `Fault_TileLegality` 拒绝，而不是被静默忽略；而功能号 `14` 确实接受的零掩码，正是 `SharedGMPESelected` 映射到每个 PE 的全 PE 选择。

设计要点：base 取默认值与步长取默认值是两种不同的操作。缺失 `B.IOR` 给出 base 为零与稠密物理行宽步长；而显式编码的零 GPR 值给出 base 为零与零步长，于是该请求的所有行都别名到 GM 的同一行。`SharedStorePEMaskLegal` 与 `SharedGMPESelected` 都不实现这些：取默认值属于实体化每 PE base 与步长字的指令束分派。

<!-- PTO-READER-BLOCK: arch-gm-access-boundaries role=boundaries -->
## 预检与顺序边界

该条款规定：被选中的 PE 访问在任何效果之前先被预检，且架构不定义它们之间的顺序。本文件既不含预检也不含顺序：传输执行体先探测每个元素，只有探测通过之后才记录或执行它；而该条款正是使得缺失的跨 PE 顺序成为已定义属性而不是遗漏的原因。因此，让两个参与 PE 触及相同 GM 字节的程序没有保证结果，必须避免该冲突。

字节地址公式也不在这里计算。`asl/tile/model/memory/stride.asl` 中的 `TileMemoryStridedByteAddress` 先形成 `row_base` 为 `base_address + row * row_stride_bytes`，然后对四位数据加上 `column DIVRM 2`，否则加上 `column * TileElementBytes(data_type)`；`TileMemoryStridedByteHighNibble` 就是那个 `column MOD 2 == 1` 判定。`SharedStorePEMaskLegal` 的调用者例如有 `asl/tile/memory-and-data-movement/regular/TSTORE.asl` 与 `asl/block/model/dispatch/shared-tlsu.asl`。

<!-- PTO-READER-BLOCK: arch-gm-access-example role=example-usage -->
## 非规范性掩码示例

`SharedStorePEMaskLegal(1, '0001')` 为真，`SharedStorePEMaskLegal(14, '1100')` 为假，因为只有 `function == 1` 分支接受非零掩码。`SharedStorePEMaskLegal(2, '1111')` 出于同样原因也为假。

`SharedGMPESelected('0001', 3)` 为真，`SharedGMPESelected('0001', 0)` 为假，因为 PE3 映射到位 `0`。零掩码通过该助手函数不选中任何 PE，这正是该条款把零掩码无效果规则单独陈述的原因。

本示例仅作为阅读辅助：先应用上面的规则，再到规范性 ASL 拥有者中确认结果。它不增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-gm-access-related role=related-owners-navigation -->
## 相关拥有者

- `PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY` 拥有 `PTOPEMaskBitOfPEIdentity` 与 PE 身份编号。
- `asl/tile/model/memory/stride.asl` 计算该条款用文字陈述的字节地址与半字节选择。
- [原子性](atomicity.md) 记录这些传输产生的事件；[地址空间](address-space.md) 是它们之下的字节存储。
- `PTO-ARCH-MEMORY-MODEL-ORDERING` 对这些传输发出的 Tile 请求进行分类。
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
