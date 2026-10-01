<!-- GENERATED FROM: asl/scalar/model/sys/registers.asl -->
# Registers

**Normative ASL source:** `asl/scalar/model/sys/registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-SYS-REGISTERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-sys-registers-purpose role=purpose-scope -->
## 用途与范围

本单元按 24 位地址实现标量系统寄存器（SSR）转移。它检查访问环权限和访问类别，把地址路由到基本寄存器或上下文寄存器，并运行 `SSRGET`、`SSRSET` 和 `SSRSWAP` 所用的读、写和交换辅助函数。

这些辅助函数是 `ReadSystemRegisterAddress`、`WriteSystemRegisterAddress`、`SwapSystemRegisterAddress`，以及分派所调用的四个 `Execute...` 包装函数。

<!-- PTO-READER-BLOCK: scalar-model-sys-registers-concepts role=concepts-state -->
## 概念与可见状态

SSR 地址是 24 位的 `SystemRegisterAddress`。地址分为两类：

- 基本寄存器是 14 个固定地址，例如 0x0000 `THREAD_PTR`、0x0020 `CORE_STATE`、0x0027 `TILE_CAPACITY` 和 0x0C00 `CYCLE`。`BaseSystemRegisterOfAddress` 把它们映射到 `SystemRegister` 枚举。
- 扩展寄存器是其他地址。位 15:12 表示访问环存储体，位 11:0 表示其中的寄存器。大多数存放在按位 15:0 索引的 `_ExtendedSystemRegisters` 中。

访问类别为只读、只写、读写或未知。生成的 `SystemRegisterAccessOf` 为每个地址返回其类别。

本模型中的访问环（ACR）权限很简单：位 11:0 小于 0x0F00 的地址对每个访问环开放；其他地址需要 ACR0。

<!-- PTO-READER-BLOCK: scalar-model-sys-registers-rules role=rules-interactions -->
## 规则与交互

当访问环缺少权限，或类别为未知或只写时，`ReadSystemRegisterAddress` 拒绝读取。拒绝会引发 `Fault_IllegalInstruction` 并返回 0。否则它读取基本寄存器，或五个具有特殊读取行为的扩展寄存器之一（0x0F02 陷阱状态、0x0F03 陷阱参数、0x0F08 中断挂起、0x0F09 最高挂起中断、0x0F20 时间），或所存储的扩展值。

当访问环缺少权限，或类别为未知或只读时，`WriteSystemRegisterAddress` 拒绝写入。对 0x0F02、0x0F03 和 0x0F0A（中断结束）的写入有特殊效果，对 0x0F21 的写入还会刷新该访问环的定时器挂起状态。

`ExecuteSystemRegisterSet` 和 `ExecuteSystemRegisterSwap` 在读取其 Reg5 源之前检查权限。

设计要点：失败的检查先于任何源读取或寄存器访问。因此被拒绝的转移不读取源、不写目标，也不改变寄存器。

`SwapSystemRegisterAddress` 在读取之前要求读权限、写权限和读写类别。

设计要点：交换预检之所以存在，是因为某些读取带有效果。ASL 注释指出了只读寄存器上的定时器挂起刷新。先检查两个方向，意味着被拒绝的交换不会先执行读侧效果、再在写入时失败。

读取类辅助函数仅当 `_LastFault` 为 `Fault_None` 时才写入目标。

<!-- PTO-READER-BLOCK: scalar-model-sys-registers-boundaries role=boundaries -->
## 架构边界

`SystemRegisterFileIndexOf` 断言位 23:16 为零。只有类别查找接受了该地址时，非零高字节才会到达这一断言；生成的表只接受位 23:16 为零的地址。

对基本寄存器的写入交给[SYS 语义](semantics.md)中的 `WriteSystemRegister`。在那里只有 `THREAD_PTR`、`GLOBAL_PTR`、`CORE_STATE` 和 `CORE_FEATURE_ENABLE` 可写，写入 `CORE_STATE` 还会根据位 3:0 更新当前访问环。

陷阱、中断和定时器寄存器由各自的架构单元拥有；本单元只负责路由到它们。

<!-- PTO-READER-BLOCK: scalar-model-sys-registers-example role=example-usage -->
## 非规范阅读示例

考虑在 ACR2 对地址 0x0010（`TIME`）执行 `SSRSWAP`，再在 ACR0 对地址 0x1F03 执行。

| 情形 | 权限 | 类别 | 结果 |
| --- | --- | --- | --- |
| ACR2 下的 0x0010 | 开放，因为 0x010 小于 0xF00 | 只读 | `Fault_IllegalInstruction`；不读也不写 |
| ACR0 下的 0x1F03 | ACR0 | 读写 | 返回访问环 1 的旧陷阱参数，并存入新值 |

第二种情形中，访问环存储体取自位 15:12，为 1，因此交换作用于访问环 1 的 `_ACRTrapArgument0`。

<!-- PTO-READER-BLOCK: scalar-model-sys-registers-related role=related-owners-navigation -->
## 相关所有者

- [SYS 语义](semantics.md)拥有基本寄存器的读写以及 `CORE_STATE` 的附带效果。
- [SYS 分派](../dispatch/sys.md)译码 SSR 地址和目标。
- [访问控制](../../../arch/system-registers/access-control.md)拥有 `CurrentACR`。
- [中断](../../../arch/system-registers/interrupt.md)和[定时器](../../../arch/system-registers/timer.md)拥有特殊的扩展寄存器。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/sys/registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-SYS-REGISTERS","surface":"scalar","classification":["model","sys","registers"],"depends_on":["PTO-SCALAR-MODEL-SYS-SEMANTICS","PTO-ARCH-SYSTEM-REGISTERS-MAINTENANCE"]}
// PTO-REQ-SCALAR-SSR-001, PTO-REQ-RESET-001: canonical 24-bit
// system-register addressing with explicit Access Control Ring checks.

readonly func SystemRegisterAccessPermitted(
    address: SystemRegisterAddress, write: boolean,
    ring: AccessControlRing) => boolean
begin
    // Base registers are available at every level. Context, translation, and
    // debug register families are ACR0-only in the PTO v0 profile.
    return UInt(address[11:0]) < 0x0f00 || ring == 0;
end;

pure func IsBaseSystemRegisterAddress(address: SystemRegisterAddress) => boolean
begin
    return address == Zeros{24} + 0x0000 ||
           address == Zeros{24} + 0x0001 ||
           address == Zeros{24} + 0x0010 ||
           address == Zeros{24} + 0x0020 ||
           address == Zeros{24} + 0x0021 ||
           address == Zeros{24} + 0x0022 ||
           address == Zeros{24} + 0x0023 ||
           address == Zeros{24} + 0x0024 ||
           address == Zeros{24} + 0x0025 ||
           address == Zeros{24} + 0x0026 ||
           address == Zeros{24} + 0x0027 ||
           address == Zeros{24} + 0x0050 ||
           address == Zeros{24} + 0x0051 ||
           address == Zeros{24} + 0x0c00;
end;

pure func BaseSystemRegisterOfAddress(address: SystemRegisterAddress) => SystemRegister
begin
    case UInt(address) of
        when 0x0000 => return SystemRegister_THREAD_PTR;
        when 0x0001 => return SystemRegister_GLOBAL_PTR;
        when 0x0010 => return SystemRegister_TIME;
        when 0x0020 => return SystemRegister_CORE_STATE;
        when 0x0021 => return SystemRegister_CORE_ID;
        when 0x0022 => return SystemRegister_VENDOR;
        when 0x0023 => return SystemRegister_VERSION;
        when 0x0024 => return SystemRegister_CORE_FEATURE;
        when 0x0025 => return SystemRegister_CORE_FEATURE_ENABLE;
        when 0x0026 => return SystemRegister_THREAD_ID;
        when 0x0027 => return SystemRegister_TILE_CAPACITY;
        when 0x0050 => return SystemRegister_BLOCKNUM;
        when 0x0051 => return SystemRegister_BLOCKID;
        when 0x0c00 => return SystemRegister_CYCLE;
        otherwise => unreachable;
    end;
end;

pure func SystemRegisterFileIndexOf(address: SystemRegisterAddress)
        => SystemRegisterFileIndex
begin
    assert address[23:16] == Zeros{8};
    return UInt(address[15:0]) as SystemRegisterFileIndex;
end;

func ReadSystemRegisterAddress(address: SystemRegisterAddress) => Word
begin
    if !SystemRegisterAccessPermitted(address, FALSE, CurrentACR()) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return Zeros{PTO_XLEN};
    end;
    let access = SystemRegisterAccessOf(address);
    if access == SystemRegisterAccess_Unknown ||
       access == SystemRegisterAccess_WriteOnly then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return Zeros{PTO_XLEN};
    end;
    if IsBaseSystemRegisterAddress(address) then
        return ReadSystemRegister(BaseSystemRegisterOfAddress(address));
    end;

    let low_index = UInt(address[11:0]);
    let ring = UInt(address[15:12]) as AccessControlRing;
    if low_index == 0x0f02 then return PackTrapStatus(ring); end;
    if low_index == 0x0f03 then return _ACRTrapArgument0[[ring]]; end;
    if low_index == 0x0f08 then return ReadInterruptPending(ring); end;
    if low_index == 0x0f09 then return ReadTopPendingInterrupt(ring); end;
    if low_index == 0x0f20 then return ReadMonotonicTime(); end;
    return _ExtendedSystemRegisters[[SystemRegisterFileIndexOf(address)]];
end;

readonly func SystemRegisterWritePermitted(address: SystemRegisterAddress)
    => boolean
begin
    let access = SystemRegisterAccessOf(address);
    return SystemRegisterAccessPermitted(address, TRUE, CurrentACR()) &&
           access != SystemRegisterAccess_Unknown &&
           access != SystemRegisterAccess_ReadOnly;
end;

readonly func SystemRegisterSwapPermitted(address: SystemRegisterAddress)
    => boolean
begin
    return SystemRegisterAccessPermitted(address, FALSE, CurrentACR()) &&
           SystemRegisterAccessPermitted(address, TRUE, CurrentACR()) &&
           SystemRegisterAccessOf(address) == SystemRegisterAccess_ReadWrite;
end;

func WriteSystemRegisterAddress(address: SystemRegisterAddress, value: Word)
begin
    if !SystemRegisterWritePermitted(address) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    if IsBaseSystemRegisterAddress(address) then
        WriteSystemRegister(BaseSystemRegisterOfAddress(address), value);
        return;
    end;

    let low_index = UInt(address[11:0]);
    let ring = UInt(address[15:12]) as AccessControlRing;
    if low_index == 0x0f02 then
        UnpackTrapStatus(ring, value);
    elsif low_index == 0x0f03 then
        _ACRTrapArgument0[[ring]] = value;
    else
        if low_index == 0x0f0a then
            EndOfInterrupt(ring, value);
        else
            _ExtendedSystemRegisters[[SystemRegisterFileIndexOf(address)]] = value;
            if low_index == 0x0f21 then RefreshTimerPending(ring); end;
        end;
    end;
end;

func SwapSystemRegisterAddress(address: SystemRegisterAddress, value: Word) => Word
begin
    // A swap is a read/write transaction.  Preflight both permissions and the
    // access class before reading so a rejected swap cannot trigger read-side
    // effects such as timer-pending refresh on a read-only register.
    if !SystemRegisterSwapPermitted(address) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return Zeros{PTO_XLEN};
    end;
    let old_value = ReadSystemRegisterAddress(address);
    if _LastFault == Fault_None then WriteSystemRegisterAddress(address, value); end;
    return old_value;
end;

func ExecuteSystemRegisterGet(destination: Reg5Selector,
                              address: SystemRegisterAddress)
begin
    let value = ReadSystemRegisterAddress(address);
    if _LastFault == Fault_None then WriteScalarDestination(destination, value); end;
end;

func ExecuteCompressedSystemRegisterGet(address: SystemRegisterAddress)
begin
    let value = ReadSystemRegisterAddress(address);
    if _LastFault == Fault_None then WriteCompressedTResult(value); end;
end;

func ExecuteSystemRegisterSet(source: Reg5Selector,
                              address: SystemRegisterAddress)
begin
    if !SystemRegisterWritePermitted(address) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    let value = ReadScalarRegisterOperand(source);
    WriteSystemRegisterAddress(address, value);
end;

func ExecuteSystemRegisterSwap(destination: Reg5Selector, source: Reg5Selector,
                               address: SystemRegisterAddress)
begin
    if !SystemRegisterSwapPermitted(address) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    let value = ReadScalarRegisterOperand(source);
    let old_value = SwapSystemRegisterAddress(address, value);
    if _LastFault == Fault_None then WriteScalarDestination(destination, old_value); end;
end;
```
<!-- GENERATED-ASL-END: unit -->
