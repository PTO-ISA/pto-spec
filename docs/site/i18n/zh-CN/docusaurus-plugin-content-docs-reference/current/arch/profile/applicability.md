<!-- GENERATED FROM: asl/arch/profile/applicability.asl -->
# Applicability

**Normative ASL source:** `asl/arch/profile/applicability.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-APPLICABILITY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-profile-applicability-purpose role=purpose-scope -->
## 用途与范围

本单元实现 PTO v0 的系统寄存器访问控制规则。它判断给定 `AccessControlRing` 是否允许读取或写入某个 `SystemRegisterAddress`。

<!-- PTO-READER-BLOCK: arch-profile-applicability-concepts role=concepts-state -->
## 地址与权限输入

- 判断接收寄存器 `address`、`write` 标志以及当前 `ring`。
- PTO v0 规则使用地址低 `12` 位和 ACR 层级编号。
- 基础寄存器位于低于 `0x0f00` 的地址；上下文、地址转换和调试寄存器族从该边界开始。

<!-- PTO-READER-BLOCK: arch-profile-applicability-rules role=rules-interactions -->
## 访问规则

当地址低 `12` 位小于 `0x0f00` 时，`SystemRegisterAccessPermitted` 返回真。达到或超过 `0x0f00` 时，只有 `ring == 0` 才返回真。当前实现对读取与写入使用同一边界。

<!-- PTO-READER-BLOCK: arch-profile-applicability-boundaries role=boundaries -->
## 配置档边界

这是 PTO v0 参考配置档的 `implementation` 函数。它并不承诺每个未来具名配置档都采用相同地址分界或权限规则。

<!-- PTO-READER-BLOCK: arch-profile-applicability-example role=example-usage -->
## 非规范访问示例

本示例块只用于帮助阅读：先应用上文规则，再到规范 ASL 所有者中确认结果。它不会增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-profile-applicability-related role=related-owners-navigation -->
## 相关所有者

- 配置档重置建立初始 ACR 与寄存器状态。
- 系统寄存器访问指令在产生效果前调用该配置档判定函数。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/profile/applicability.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-APPLICABILITY","surface":"arch","classification":["profile","applicability"],"depends_on":["PTO-ARCH-PROFILE-RESET"]}
readonly implementation func SystemRegisterAccessPermitted(
    address: SystemRegisterAddress, write: boolean,
    ring: AccessControlRing) => boolean
begin
    // Base registers are available at every level. Context, translation, and
    // debug register families are ACR0-only in the PTO v0 profile.
    return UInt(address[11:0]) < 0x0f00 || ring == 0;
end;
```
<!-- GENERATED-ASL-END: unit -->
