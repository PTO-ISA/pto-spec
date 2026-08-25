<!-- GENERATED FROM: asl/arch/data-types/system-registers.asl -->
# System Registers

**Normative ASL source:** `asl/arch/data-types/system-registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-SYSTEM-REGISTERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-system-register-types-purpose-scope role=purpose-scope -->
## 目的与范围

本单元定义基础系统寄存器、访问类别以及缓存/TLB 维护操作的共享符号命名空间。

它只提供类型化身份；地址映射、访问控制、寄存器状态和维护效果由其他归属单元定义。

<!-- PTO-READER-BLOCK: arch-system-register-types-concepts-state role=concepts-state -->
## 概念与可见状态

- `SystemRegister` 命名线程/全局指针、时间/周期、核/线程身份、厂商/版本/特性、Tile 容量以及块身份寄存器。
- `SystemRegisterAccess` 区分未知、只读、只写和可读写四种访问类别。
- `MaintenanceOperation` 命名数据缓存、指令缓存、束缓存和 TLB 的失效或清理变体。

<!-- PTO-READER-BLOCK: arch-system-register-types-rules-interactions role=rules-interactions -->
## 规则与交互

枚举成员只标识寄存器或操作，并不分配编码地址。

访问类别与当前访问控制环以及具体读写行为彼此独立。

维护变体保持相互独立，包括已声明的全缓存、虚拟地址和组/路形式。

<!-- PTO-READER-BLOCK: arch-system-register-types-boundaries role=boundaries -->
## 架构边界

本单元不创建系统寄存器文件，也不规定复位值；这些契约应查阅状态和寻址归属单元。

声明某个维护操作身份并不自动保证相应指令可用，也不定义纪元变化；这些效果由执行归属单元提供。

<!-- PTO-READER-BLOCK: arch-system-register-types-example-usage role=example-usage -->
## 非规范阅读示例

`SystemRegister_TIME` 命名一个系统寄存器。

其架构地址和数值行为分别由寻址归属单元及计时器/状态归属单元定义。

`Maintenance_TLB_IALL` 标识全部表项 TLB 操作。

调用该操作的指令仍负责定义合法性、操作数和可见的维护状态变化。

<!-- PTO-READER-BLOCK: arch-system-register-types-related-owners role=related-owners-navigation -->
## 相关归属单元

- [系统寄存器寻址](../system-registers/addressing.md)
- [系统寄存器访问控制](../system-registers/access-control.md)
- [维护行为](../system-registers/maintenance.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/system-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-SYSTEM-REGISTERS","surface":"arch","classification":["data-types","system-registers"],"depends_on":["PTO-ARCH-DATA-TYPES-MEMORY-OPERATIONS"]}
type SystemRegister of enumeration {
    SystemRegister_THREAD_PTR,
    SystemRegister_GLOBAL_PTR,
    SystemRegister_TIME,
    SystemRegister_CORE_STATE,
    SystemRegister_CORE_ID,
    SystemRegister_THREAD_ID,
    SystemRegister_VENDOR,
    SystemRegister_VERSION,
    SystemRegister_CORE_FEATURE,
    SystemRegister_CORE_FEATURE_ENABLE,
    SystemRegister_TILE_CAPACITY,
    SystemRegister_BLOCKNUM,
    SystemRegister_BLOCKID,
    SystemRegister_CYCLE
};

type SystemRegisterAccess of enumeration {
    SystemRegisterAccess_Unknown,
    SystemRegisterAccess_ReadOnly,
    SystemRegisterAccess_WriteOnly,
    SystemRegisterAccess_ReadWrite
};

type MaintenanceOperation of enumeration {
    Maintenance_DC_IALL,
    Maintenance_DC_IVA,
    Maintenance_DC_ISW,
    Maintenance_DC_ZVA,
    Maintenance_DC_CVA,
    Maintenance_DC_CIVA,
    Maintenance_DC_CSW,
    Maintenance_DC_CISW,
    Maintenance_IC_IALL,
    Maintenance_IC_IVA,
    Maintenance_BC_IALL,
    Maintenance_BC_IVA,
    Maintenance_TLB_IV,
    Maintenance_TLB_IAV,
    Maintenance_TLB_IA,
    Maintenance_TLB_IALL
};
```
<!-- GENERATED-ASL-END: unit -->
