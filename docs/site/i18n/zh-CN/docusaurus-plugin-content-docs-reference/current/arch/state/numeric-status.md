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

`asl/arch/state/numeric-status.asl` 拥有两个函数和一条契约子句。`NumericStatusFlags` 是一个返回 `bits(5)` 的 `readonly` 函数，`RecordNumericStatusFlags` 接受一个 `flags: bits(5)` 参数。两者都作用于 `_SystemRegisters.core_state[36:32]`，而 `NDF-BEGIN` 子句 `PTO-NUMERIC-STATUS-STICKY-001` 固定了该位映射以及粘滞更新规则。

`core_state` 是 `asl/arch/system-registers/addressing.asl` 中声明的 `BaseSystemRegisterState` 记录的一个字段，类型为 `Word`；`Word` 是 `bits(PTO_XLEN)`，其中 `PTO_XLEN` 为 `64`。因此这五个标志是一个更宽寄存器的子字段，而不是独立寄存器。

<!-- PTO-READER-BLOCK: arch-numeric-status-concepts-state role=concepts-state -->
## 共享字中的标志布局

`NumericStatusFlags` 只是读取 `core_state[36:32]`。该子句按从高到低的顺序命名这些位，因此位 `36` 是 `NV`，位 `35` 是 `DZ`，位 `34` 是 `OF`，位 `33` 是 `UF`，位 `32` 是 `NX`。

其他代码会读写字中的相邻位：`asl/arch/system-registers/access-control.asl` 中的 `SetCurrentACR` 把当前环写入 `core_state[3:0]`，而 `asl/scalar/model/fsu/scalar-fp.asl` 中的 `ScalarFPActiveRoundingMode` 从 `core_state[39:37]` 读取当前生效的舍入模式。

Design point：这五个标志没有专用寄存器，也没有自己的复位值；它们是一个字中的 `36:32` 位，同一个字还在 `39:37` 位保存舍入模式、在 `3:0` 位保存环选择。可观察的结果是：读取地址 `0x0020` 处的 `CORE_STATE` 只能把标志作为组合字的一部分返回，需要单个字段的软件必须把其他字段掩掉。

<!-- PTO-READER-BLOCK: arch-numeric-status-rules-interactions role=rules-interactions -->
## 粘滞更新及其调用者

`RecordNumericStatusFlags(flags)` 把 `NumericStatusFlags() OR flags` 写回 `core_state[36:32]`。该函数体没有条件分支、没有断言、也没有故障调用，因此记录状态本身不增加失败路径，且任何一次调用都无法清除先前调用已置位的比特。

`RecordNumericStatusFlags` 在 `asl/` 下有 `14` 个调用点。例如 `asl/scalar/model/fsu/scalar-fp.asl` 中的 `ScalarFPRecordFlags` 转发标量浮点结果标志，`TileCommitConversionResult` 记录 Tile 转换发布时的标志，而 Tile 执行所有者 `ExecuteTileUnary`（其最后一条语句是 `ScalarFPRecordFlags(flags)`）、`ExecuteTileScalar` 以及比较、归约、扩展、矩阵缩放、谓词载体、后处理和 `expdif` 等辅助函数都通过同一函数记录。`ExecuteTileBinary` 不在其中：它用 `TileProfileBinary` 计算值，而后者以 `let (result, -) = TileProfileBinaryWithFlags(op, data_type, left, right);` 丢弃标志向量。

Design point：`RecordNumericStatusFlags` 只写 `36:32` 位，因此会累积的 Tile 或标量运算不会干扰与之共享该字的舍入模式字段和环选择字段。对 `CORE_STATE` 系统寄存器的软件写入则不是子字段写入：`asl/scalar/model/sys/semantics.asl` 中的 `WriteSystemRegister` 存储整个 `Word`，随后用 `value[3:0]` 设置 `_CurrentACR`。因此，通过写 `CORE_STATE` 清除这五个标志也会替换舍入模式和当前环，模型中不存在只清除状态的通路。

<!-- PTO-READER-BLOCK: arch-numeric-status-boundaries role=boundaries -->
## 架构边界

本所有者只存储并累积这五个比特；它不决定哪个运算产生 `NV`、`DZ`、`OF`、`UF` 或 `NX`。这些向量由负责计算的数值所有者构造，例如 `asl/tile/model/execution/` 中的 `TileProfileUnary` 和 `TileProfileBinaryWithFlags`。

并非每次记录调用都携带信息。`TileConvertValue` 与 `TileProfileConvert` 的整数路径返回 `Zeros{5}`，而 `TileCommitConversionResult` 仍然记录该值，结果使已存储字段保持不变。

该子句覆盖的是成功的数值运算。`RecordNumericStatusFlags` 本身没有成功判定，也没有故障参数，因此是否记录由调用方决定，这里不再复核。

<!-- PTO-READER-BLOCK: arch-numeric-status-example-usage role=example-usage -->
## 非规范状态示例

假设已存储字段读出 `10000`。之后某个运算提供 `00001`，已存储值成为 `10001`，因为写入是旧值与新值的 OR。再提供 `00000` 会让 `10001` 保持不变。用 `Zeros{PTO_XLEN} + 3` 写 `CORE_STATE` 会把 `3` 存入整个字，于是五个标志都读回 `00000`，同时当前环变为 `3`。

<!-- PTO-READER-BLOCK: arch-numeric-status-related-owners role=related-owners-navigation -->
## 相关所有者

- [系统寄存器寻址](../system-registers/addressing.md)拥有这里使用的 `_SystemRegisters` 与 `core_state` 存储。
- [访问控制](../system-registers/access-control.md)拥有 `AccessControlRingBits` 以及 `core_state[3:0]` 的编码。
- [标量浮点](../../scalar/model/fsu/scalar-fp.md)通过 `ScalarFPRecordFlags` 转发标量浮点标志。
- [Tile 数值格式](../../tile/model/numeric/formats.md)在 Tile 发布边界记录转换标志。
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
