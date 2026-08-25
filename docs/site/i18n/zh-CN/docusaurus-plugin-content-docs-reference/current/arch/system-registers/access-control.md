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

本单元定义当前 Access Control Ring 状态、其四位表示、可移植陷阱目标、允许的服务请求以及陷阱向量查找。

<!-- PTO-READER-BLOCK: arch-access-control-concepts-state role=concepts-state -->
## ACR 状态与编码

`CurrentACR` 返回 `_CurrentACR`。`AccessControlRingBits` 把环值 `0` 到 `15` 映射到对应的四位二进制值。

`SetCurrentACR` 同时更新 `_CurrentACR` 和 `core_state[3:0]`，使保存的环与其系统寄存器表示保持同步。

<!-- PTO-READER-BLOCK: arch-access-control-rules-interactions role=rules-interactions -->
## 陷阱与服务路由

`TrapTargetForFault` 把源 ACR0 映射到目标 ACR0，把每个非零源映射到目标 ACR1。`TrapTargetForInterrupt` 使用相同规则。

来自 ACR1 时，允许服务请求类型 `0000` 和 `0010`。来自 ACR2 到 ACR15 时，允许无符号值不大于 `2` 的请求类型；ACR0 不允许任何请求。

对于允许的请求，类型 `0001` 的目标是 ACR1，其他每个允许类型的目标都是 ACR0。

<!-- PTO-READER-BLOCK: arch-access-control-boundaries role=boundaries -->
## 陷阱向量查找边界

`TrapVectorEntry` 读取扩展系统寄存器索引 `target * 4096 + 0x0f01`。非零条目是向量基址；零条目回退到给定的故障地址。

`ServiceRequestTarget` 会断言请求已经获得许可。调用者必须先确认许可，才能请求目标。

<!-- PTO-READER-BLOCK: arch-access-control-example-usage role=example-usage -->
## 非规范路由示例

来自 ACR2 的 `0001` 类型请求被允许，并且目标为 ACR1。同一请求来自 ACR1 时不被允许，因此不能把它传给 `ServiceRequestTarget`。

<!-- PTO-READER-BLOCK: arch-access-control-related-owners role=related-owners-navigation -->
## 相关所有者

- [执行上下文](../programming-model/execution-context.md)是声明的依赖项。
- [上下文寄存器](context.md)定义环加低位索引的寻址规则。
- [陷阱上下文](../state/trap-context.md)保存源 ACR，并在可移植恢复后还原它。
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
