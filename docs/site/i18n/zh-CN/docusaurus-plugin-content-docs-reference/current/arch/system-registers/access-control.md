<!-- GENERATED FROM: asl/arch/system-registers/access-control.asl -->
# Access Control

**Normative ASL source:** `asl/arch/system-registers/access-control.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-access-control-purpose-scope role=purpose-scope -->
## 用途与范围

`asl/arch/system-registers/access-control.asl` 拥有当前访问控制环以及围绕它的环运算：`CurrentACR`、`AccessControlRingBits`、`SetCurrentACR`、`TrapTargetForFault`、`TrapTargetForInterrupt`、`ServiceRequestPermitted`、`ServiceRequestTarget` 与 `TrapVectorEntry`。`AccessControlRing` 是 `integer {0..15}`，而 `asl/arch/programming-model/core-pe-topology.asl` 中的 `PTO_ACR_COUNT` 是 `16`。

该文件没有声明 `NDF-BEGIN` 子句；它的规范内容就是这八个函数体，加上它们所读取的状态 `_CurrentACR` 与 `_ExtendedSystemRegisters`，二者声明在 `asl/arch/programming-model/execution-context.asl`。

<!-- PTO-READER-BLOCK: arch-access-control-concepts-state role=concepts-state -->
## 环状态及其编号

`CurrentACR()` 返回 `_CurrentACR`。`SetCurrentACR(ring)` 写入 `_CurrentACR`，同时把 `AccessControlRingBits(ring)` 写入 `_SystemRegisters.core_state[3:0]`，因此环既出现在自己的变量中，也出现在 `CORE_STATE` 字的低半字节中。`AccessControlRingBits` 把 `0` 映射为 `0000`，直到把 `15` 映射为 `1111`，因此该半字节就是环编号本身。

反方向位于系统寄存器写路径中：`asl/scalar/model/sys/semantics.asl` 中的 `WriteSystemRegister` 存储软件对 `CORE_STATE` 的写入，随后用 `value[3:0]` 设置 `_CurrentACR`；`asl/arch/system-registers/addressing.asl` 中的 `ResetProfileState` 以 `_CurrentACR = 0` 结束。

设计要点：环不需要查编号表，也不需要单独的有效标志，因为 `AccessControlRing` 已经被约束在 `0..15`，而 `AccessControlRingBits` 在该范围内是完备的。从 `_CurrentACR` 读出的值总能写入该半字节，已保存的半字节也总能通过 `UInt(ecstate[3:0]) as AccessControlRing` 还原。

<!-- PTO-READER-BLOCK: arch-access-control-rules-interactions role=rules-interactions -->
## 陷阱与服务请求路由

`TrapTargetForFault(source)` 对源 `0` 返回 `0`，对其他任何源返回 `1`；`TrapTargetForInterrupt(source)` 返回的正是 `TrapTargetForFault(source)`：当前环为 `0` 时发生的陷阱留在环 `0`，而在环 `1` 到 `15` 中发生的陷阱都投递到环 `1`。

`ServiceRequestPermitted(source, request_type)` 从源 `1` 只接受 `0000` 与 `0010`；从源 `2` 及以上接受任何无符号值至多为 `2` 的 `request_type`；从源 `0` 返回 `FALSE`。`ServiceRequestTarget(source, request_type)` 断言该许可成立，对 `0001` 返回 `1`，否则返回 `0`。

设计要点：两级路由意味着一个槽位服务多个环。`SetFaultWithCause` 用路由得到的目标环调用 `SaveTrapContext(ring, source_ring)`，而 `_TrapContexts` 每个环只有一个槽位，所以环 `7` 与环 `2` 中的故障都保存到槽位 `1`，后一次保存替换前一次；已保存的 `source_acr` 字段让每次保存的来源仍可恢复。

<!-- PTO-READER-BLOCK: arch-access-control-boundaries role=boundaries -->
## 陷阱向量查找边界

`TrapVectorEntry(target, fault_address)` 把索引计算为 `(target * 4096) + 0x0f01`，类型为 `SystemRegisterFileIndex`，并返回该处存储的字，除非它是 `Zeros{PTO_XLEN}`，此时返回 `fault_address`。最高环对应的索引 `15 * 4096 + 0x0f01` = `65281`，位于声明的范围 `0` 到 `65535` 之内。

`ResetProfileState` 为全部 `16` 个环清除低索引 `0x0f00` 到 `0x0fb7`，因此在复位状态下每个环的 `0x0f01` 向量基址都为零。唯一的例外是低索引 `0x0f07`，它被预置为 `3`，使外部与定时器中断收集在起始时处于使能状态。

设计要点：向量基址为零表示“使用故障地址”，而不是“无效表项”，因此复位状态就是一个可用的恒等向量：在软件向目标环的 `0x0f01` 寄存器存入非零基址之前，故障会回到报告它的那个地址继续执行，而存入的零无法把某个环向量到地址 `0`。

<!-- PTO-READER-BLOCK: arch-access-control-example-usage role=example-usage -->
## 非规范路由示例

`TrapTargetForFault(0)` 为 `0`，`TrapTargetForFault(3)` 为 `1`，因此当前环为 `3` 时发生的故障会进入环 `1`。`ServiceRequestPermitted(2, '0001')` 为 `TRUE`，因为 `0001` 的无符号值至多为 `2`，并且 `ServiceRequestTarget(2, '0001')` 返回 `1`；同样的类型从环 `1` 发出则不被许可，因为那里的集合只有 `0000` 与 `0010`，所以把 `0001` 传给 `ServiceRequestTarget(1, '0001')` 会使其断言失败。

`asl/arch/memory-model/fault-precision.asl` 中的 `RaiseServiceRequest` 执行整套序列：它计算恢复地址，把上下文保存到由 `ServiceRequestTarget` 选出的环，改写已保存的 TPC 与上下文寄存器 `0x0f43`，记录陷阱号 `6`，用 `SetCurrentACR` 选中目标，并安装 `TrapVectorEntry(target_ring, source_tpc)`。

仅在 `asl/arch/memory-model/fault-precision.asl` 内，`CurrentACR` 出现 `4` 次，`SetCurrentACR` 与 `TrapVectorEntry` 各出现 `3` 次，而 `TrapTargetForFault`、`TrapTargetForInterrupt`、`ServiceRequestPermitted` 与 `ServiceRequestTarget` 各出现一次。

<!-- PTO-READER-BLOCK: arch-access-control-related-owners role=related-owners-navigation -->
## 相关所有者

- [执行上下文](../programming-model/execution-context.md)是第 1 行的依赖，并声明 `_CurrentACR` 与 `_ExtendedSystemRegisters`。
- [上下文寄存器](context.md)拥有 `ContextRegisterIndex` 以及环加低索引寻址规则。
- [陷阱上下文](../state/trap-context.md)保存 `source_acr`，写入已保存的环半字节并恢复 `_CurrentACR`。
- [故障精确性](../memory-model/fault-precision.md)调用陷阱目标与服务请求辅助函数。
- [系统寄存器寻址](addressing.md)拥有 `core_state`，其中承载环半字节。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/system-registers/access-control.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL","surface":"arch","classification":["system-registers","access-control"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT"]}
readonly func CurrentACR() => AccessControlRing
begin
    return _CurrentACR;
end;

pure func AccessControlRingBits(ring: AccessControlRing) => bits(4)
begin
    case ring of
        when 0 => return '0000';
        when 1 => return '0001';
        when 2 => return '0010';
        when 3 => return '0011';
        when 4 => return '0100';
        when 5 => return '0101';
        when 6 => return '0110';
        when 7 => return '0111';
        when 8 => return '1000';
        when 9 => return '1001';
        when 10 => return '1010';
        when 11 => return '1011';
        when 12 => return '1100';
        when 13 => return '1101';
        when 14 => return '1110';
        when 15 => return '1111';
    end;
end;

func SetCurrentACR(ring: AccessControlRing)
begin
    _CurrentACR = ring;
    _SystemRegisters.core_state[3:0] = AccessControlRingBits(ring);
end;

pure func TrapTargetForFault(source: AccessControlRing) => AccessControlRing
begin
    if source == 0 then return 0; else return 1; end;
end;

pure func TrapTargetForInterrupt(source: AccessControlRing) => AccessControlRing
begin
    return TrapTargetForFault(source);
end;

pure func ServiceRequestPermitted(source: AccessControlRing,
                                  request_type: bits(4)) => boolean
begin
    if source == 1 then
        return request_type == '0000' || request_type == '0010';
    elsif source >= 2 then
        return UInt(request_type) <= 2;
    else
        return FALSE;
    end;
end;

pure func ServiceRequestTarget(source: AccessControlRing,
                               request_type: bits(4)) => AccessControlRing
begin
    assert ServiceRequestPermitted(source, request_type);
    if request_type == '0001' then return 1; else return 0; end;
end;

readonly func TrapVectorEntry(target: AccessControlRing,
                              fault_address: Word) => Word
begin
    let index = ((target * 4096) + 0x0f01) as SystemRegisterFileIndex;
    let vector_base = _ExtendedSystemRegisters[[index]];
    if vector_base == Zeros{PTO_XLEN} then return fault_address;
    else return vector_base;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
