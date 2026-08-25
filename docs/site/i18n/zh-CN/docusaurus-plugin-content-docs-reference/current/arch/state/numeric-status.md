<!-- GENERATED FROM: asl/arch/state/numeric-status.asl -->
# Numeric Status

**Normative ASL source:** `asl/arch/state/numeric-status.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-NUMERIC-STATUS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-numeric-status-purpose-scope role=purpose-scope -->
## 用途与范围

本单元拥有五个架构可见的数值状态标志，以及成功数值操作之后应用的粘滞更新规则。

<!-- PTO-READER-BLOCK: arch-numeric-status-concepts-state role=concepts-state -->
## 标志布局

`NumericStatusFlags` 读取 `CORE_STATE[36:32]`。从位 `36` 到位 `32`，五个标志依次是 NV、DZ、OF、UF 和 NX。

<!-- PTO-READER-BLOCK: arch-numeric-status-rules-interactions role=rules-interactions -->
## 粘滞更新规则

`RecordNumericStatusFlags` 把给定五位值与当前状态进行 OR，并把结果写回 `CORE_STATE[36:32]`。

因此，成功的数值操作可以设置标志，但不能清除先前操作已经设置的标志。

<!-- PTO-READER-BLOCK: arch-numeric-status-boundaries role=boundaries -->
## 架构边界

本所有者定义状态布局和累积操作，但不决定哪个数值操作产生 NV、DZ、OF、UF 或 NX；该决定属于数值操作的当前 ASL 所有者，以及适用时的配置档钩子。

<!-- PTO-READER-BLOCK: arch-numeric-status-example-usage role=example-usage -->
## 非规范粘滞标志示例

如果当前五位状态是 `10000`，之后一次成功操作提供 `00001`，记录值将变成 `10001`。随后提供 `00000` 时，`10001` 保持不变。

<!-- PTO-READER-BLOCK: arch-numeric-status-related-owners role=related-owners-navigation -->
## 相关所有者

- [系统寄存器寻址](../system-registers/addressing.md)拥有本页使用的 `core_state` 存储。
- [参考配置档](../profile/reference-profile.md)为配置档定义的数值钩子提供具体实现。
- [架构概览](../overview/architecture.md)建立当前所有者层级。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/numeric-status.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-NUMERIC-STATUS","surface":"arch","classification":["state","numeric-status"],"depends_on":["PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING"]}
// NDF-BEGIN: PTO-NUMERIC-STATUS-STICKY-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Numeric execution flags MUST map to CORE_STATE[36:32] as NV, DZ, OF, UF,
// and NX, and a successful numeric operation MUST OR its produced flags into
// the existing sticky status without clearing an earlier flag.
// NDF-END: PTO-NUMERIC-STATUS-STICKY-001
// DOC-BEGIN: state
readonly func NumericStatusFlags() => bits(5)
begin
    return _SystemRegisters.core_state[36:32];
end;

func RecordNumericStatusFlags(flags: bits(5))
begin
    _SystemRegisters.core_state[36:32] = NumericStatusFlags() OR flags;
end;
// DOC-END: state
```
<!-- GENERATED-ASL-END: unit -->
