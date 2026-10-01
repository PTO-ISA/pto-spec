<!-- GENERATED FROM: asl/arch/features/extension-first-use.asl -->
# Extension First Use

**Normative ASL source:** `asl/arch/features/extension-first-use.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-FEATURES-EXTENSION-FIRST-USE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-extension-first-use-purpose role=purpose-scope -->
## 用途与范围

本单元包含一个枚举和两个 `impdef` 函数。`ExtensionFirstUseKind` 只有两个取值：`ExtensionFirstUseKind_VECTOR` 与 `ExtensionFirstUseKind_CUBE`；不存在表示“没有扩展”的第三个取值。

`ExtensionFirstUseEnabled` 回答某个种类是否已启用，`RaiseExtensionFirstUse` 则是陷阱请求。两者的可移植函数体都返回 `FALSE`，因此该钩子的可移植配置是禁用且无效果的。

<!-- PTO-READER-BLOCK: arch-extension-first-use-concepts role=concepts-state -->
## 钩子输入与可移植取值

两个函数与该枚举就是本文件的全部可执行内容；本单元不声明状态变量、启用位或计数器。

- `ExtensionFirstUseEnabled(kind: ExtensionFirstUseKind) => boolean` 是 `readonly impdef`，其函数体只有一条 `return FALSE`。
- `RaiseExtensionFirstUse(kind: ExtensionFirstUseKind, source: AccessControlRing, manager: AccessControlRing) => boolean` 是 `impdef`，其函数体只有一条 `return FALSE`。
- `AccessControlRing` 是整数范围 `0..15`，因此每个环参数有 `16` 个可能取值。
- `asl/` 下没有任何单元调用这两个函数。

设计要点：尽管两者的可移植函数体都只是返回一个值，`ExtensionFirstUseEnabled` 是 `readonly` 而 `RaiseExtensionFirstUse` 不是。因此第一个函数的替换实现不得写架构状态，而第二个函数的替换实现可以写；这也正是由陷阱请求来承担排序与重试义务的原因。

设计要点：陷阱请求把源环与管理者环作为参数接收，而不是读取 `CurrentACR()`。它的可移植函数体只依赖其参数，调用方必须显式给出两个环身份，而不能依赖当前环。

<!-- PTO-READER-BLOCK: arch-extension-first-use-rules role=rules-interactions -->
## 默认与启用规则

两个钩子的可移植结果对每个参数都是 `FALSE`：`ExtensionFirstUseEnabled` 忽略 `kind`，`RaiseExtensionFirstUse` 忽略全部三个参数，因此它对两个种类以及全部 `256` 个环组合都返回 `FALSE`。

设计要点：NDF 条款 `PTO-ARCH-EXTENSION-FIRST-USE-001` 列出了启用配置档必须定义的七项义务：覆盖种类、启用状态、源与管理者 ACR、精确陷阱封装、效果前排序、重试状态以及上下文保存进度。这七项都不由本单元固定，因此同一次调用可以在某个配置档中产生陷阱，而在另一个配置档中无效果。

设计要点：`FaultCode` 有 `16` 个成员，其中没有任何一个名为扩展首次使用。所声明依赖中可达的陷阱入口机制是 `SetFault(code, address)`：它保存陷阱上下文、记录 `_LastFault` 与 `_FaultAddress`、写入每环陷阱字段、切换当前 ACR，并把 TPC 重定向到 `TrapVectorEntry(ring, address)`。因此，启用首次使用陷阱的配置档只能从现有故障码中选择一个，并通过该向量入口重新进入；钩子自身只返回一个 `boolean`。

<!-- PTO-READER-BLOCK: arch-extension-first-use-boundaries role=boundaries -->
## 架构边界

该钩子不会创建扩展状态，不会检测某条指令首次使用了扩展，也不增加任何指令覆盖范围。`ExtensionFirstUseKind` 只命名两个种类；它并不说明哪些指令使用它们。

由于 `asl/` 下没有任何单元调用这两个函数，没有任何指令从本页获得首次使用行为。调用点是否存在完全由指令归属单元或配置档决定，而 NDF 条款要求启用配置档把该调用放在效果之前并定义重试边界。

每种类型的默认值、覆盖范围表以及专门的故障码都不在归属文件中。

<!-- PTO-READER-BLOCK: arch-extension-first-use-example role=example-usage -->
## 非规范配置档示例

读者可以代入已声明的函数体来计算可移植钩子：`ExtensionFirstUseEnabled(ExtensionFirstUseKind_CUBE)` 为 `FALSE`。

对 `0..15` 中的任意 `source` 与 `manager`，`RaiseExtensionFirstUse(ExtensionFirstUseKind_CUBE, source, manager)` 都为 `FALSE`，`ExtensionFirstUseKind_VECTOR` 同样如此；不会请求任何陷阱，也不会切换任何环。

本示例块只用于帮助阅读：先应用上文规则，再到规范 ASL 所有者中确认结果。它不会增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-extension-first-use-related role=related-owners-navigation -->
## 相关归属单元

- [故障精度](../memory-model/fault-precision.md) 拥有 `SetFault` 与陷阱记录。
- [访问控制](../system-registers/access-control.md) 拥有 `CurrentACR()`、`SetCurrentACR`、`TrapTargetForFault` 与 `TrapVectorEntry`。
- [故障类型](../data-types/fault.md) 列出配置档必须从中选择的 `FaultCode` 成员。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/features/extension-first-use.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-FEATURES-EXTENSION-FIRST-USE","surface":"arch","classification":["features","extension-first-use"],"depends_on":["PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION"]}
// NDF-BEGIN: PTO-ARCH-EXTENSION-FIRST-USE-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// A target profile MAY provide a precise extension first-use trap. The
// portable default MUST remain disabled and effect-free. An enabling profile
// MUST define covered kinds, enable state, source and manager ACRs, the exact
// trap envelope, pre-effect ordering, retry state, and context-save progress.
// NDF-END: PTO-ARCH-EXTENSION-FIRST-USE-001

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
