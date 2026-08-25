<!-- GENERATED FROM: asl/arch/profile/extension-first-use.asl -->
# Extension First Use

**Normative ASL source:** `asl/arch/profile/extension-first-use.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-EXTENSION-FIRST-USE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-extension-first-use-purpose role=purpose-scope -->
## 用途与范围

本单元定义可选 `VECTOR` 或 `CUBE` 扩展状态的精确首次使用陷阱配置档钩子。可移植默认值为禁用且无效果。

<!-- PTO-READER-BLOCK: arch-extension-first-use-concepts role=concepts-state -->
## 钩子输入

- `ExtensionFirstUseKind` 区分 `ExtensionFirstUseKind_VECTOR` 与 `ExtensionFirstUseKind_CUBE`。
- `ExtensionFirstUseEnabled` 查询具名种类是否启用。
- `RaiseExtensionFirstUse` 接收扩展种类、源 `AccessControlRing` 与管理者 `AccessControlRing`。

<!-- PTO-READER-BLOCK: arch-extension-first-use-rules role=rules-interactions -->
## 默认与启用规则

可移植定义为禁用且无效果。

两个 `impdef` 函数都通过返回假来实现该默认值。

启用该机制的具名配置档定义覆盖种类、启用状态、源 ACR 与管理者 ACR、精确陷阱封装、效果前排序、重试状态以及上下文保存进度。

<!-- PTO-READER-BLOCK: arch-extension-first-use-boundaries role=boundaries -->
## 架构边界

该钩子不会创建扩展状态，也不会推断一条指令何时首次使用它。指令与配置档所有者决定是否在效果前调用该钩子；禁用行为保持无效果。

<!-- PTO-READER-BLOCK: arch-extension-first-use-example role=example-usage -->
## 非规范配置档示例

本示例块只用于帮助阅读：先应用上文规则，再到规范 ASL 所有者中确认结果。它不会增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-extension-first-use-related role=related-owners-navigation -->
## 相关所有者

- 故障精度单元提供配置档可用的陷阱入口机制。
- 受覆盖指令所有者提供效果前调用点与重试边界。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/profile/extension-first-use.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-EXTENSION-FIRST-USE","surface":"arch","classification":["profile","extension-first-use"],"depends_on":["PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION"]}
// NDF-BEGIN: PTO-ARCH-EXTENSION-FIRST-USE-PROFILE-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// A target profile MAY provide a precise extension first-use trap. The
// portable default MUST remain disabled and effect-free. An enabling profile
// MUST define covered kinds, enable state, source and manager ACRs, the exact
// trap envelope, pre-effect ordering, retry state, and context-save progress.
// NDF-END: PTO-ARCH-EXTENSION-FIRST-USE-PROFILE-001

type ExtensionFirstUseKind of enumeration {
    ExtensionFirstUseKind_VECTOR,
    ExtensionFirstUseKind_CUBE
};

readonly impdef func ExtensionFirstUseEnabled(kind: ExtensionFirstUseKind)
    => boolean
begin
    return FALSE;
end;

impdef func RaiseExtensionFirstUse(kind: ExtensionFirstUseKind,
                                  source: AccessControlRing,
                                  manager: AccessControlRing) => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: unit -->
