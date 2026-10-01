<!-- GENERATED FROM: asl/scalar/sys/DC.ZVA.asl -->
# DC.ZVA

**Normative ASL source:** `asl/scalar/sys/DC.ZVA.asl`

DC.ZVA completes the data-cache zero-by-address scope token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-ZVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dc-zva-purpose role=purpose -->
## DC.ZVA 的作用

`DC.ZVA` 是按地址将数据缓存清零的操作。它从 `SrcL` 取得目标地址并同步完成，同时记录操作令牌 `Maintenance_DC_ZVA` 与确切的操作数（`asl/scalar/sys/DC.ZVA.asl:23`）。

<!-- PTO-READER-BLOCK: scalar-dc-zva-mechanism role=mechanism -->
## 系统机制

`InstructionContractHandler_DC_ZVA` 选择共用的维护处理程序（`asl/scalar/sys/DC.ZVA.asl:11`），而 `InstructionContractMaintenanceUsesOperand_DC_ZVA` 返回 `TRUE`，使派发器在调用之前读取源寄存器（`asl/scalar/model/dispatch/sys.asl:30`）。

执行器的数据缓存组包含全部八个 `DC.*` 操作，因此 `Maintenance_DC_ZVA` 推进的是 `_DataCacheEpoch`，而不是装入一个建模的零块（`asl/scalar/model/sys/semantics.asl:134`）。

该指令只在活动 SYS 块体中适用（`asl/scalar/model/sys/semantics.asl:322`）。

<!-- PTO-READER-BLOCK: scalar-dc-zva-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SrcL` 是 Reg5 源：R0..R23、T#1..T#4 或 U#1..U#4。它的值就是请求所指名数据块的地址。

没有目的地。被捕获的地址只作为维护记录的操作数字段发布，编码零表示架构零 GPR，而不是省略的操作数。

<!-- PTO-READER-BLOCK: scalar-dc-zva-effects role=effects -->
## 架构效果

成功的尝试把数据缓存纪元递增一，并用 `Maintenance_DC_ZVA` 与该操作数替换维护记录（`asl/scalar/model/sys/semantics.asl:137`）。引发故障时会跳过记录更新，因此记录不会被写一半。

设计要点：把清零建模为一次纪元推进，使该指令不会获得内存结果。随后从同一地址执行的普通加载是一次普通内存访问，与这条指令的纪元没有已定义的关系，因此软件无法仅通过 `DC.ZVA` 观察到某个位置已被填零。

该次尝试不执行普通标量内存访问，也不写任何寄存器或队列。成功之后 `TPC` 按指令长度前进。

<!-- PTO-READER-BLOCK: scalar-dc-zva-constraints role=constraints -->
## 位置与拒绝边界

第一道门是位置必须在活动 SYS 块体内；失败会引发 `Fault_BundleControl` 并不触碰执行器。第二道是固定位与 Reg5 编码检查，它在处理程序之前运行。

任何 `DC.*` 操作都不受访问环限制（`asl/scalar/model/sys/semantics.asl:123`），地址操作数也不要求是规范地址，因为只有 `TLB.IV` 与 `TLB.IAV` 会测试规范形式。

<!-- PTO-READER-BLOCK: scalar-dc-zva-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

在源寄存器持有 0x2000 时运行 `dc.zva SrcL`。该次尝试检查位置与编码，快照 0x2000，把数据缓存纪元递增一，并以操作数 0x2000 记录 `Maintenance_DC_ZVA`。没有任何内存位置改变，因此随后从 0x2000 加载由普通内存路径服务。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
dc.zva SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_zva_32_0859a1d7aa5b | L32 | 32 | 0x0070602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_zva_32_0859a1d7aa5b | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| dc_zva_32_0859a1d7aa5b | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.ZVA.asl -->
```asl
readonly func InstructionContractOperation_DC_ZVA()
    => ScalarOperation
begin
    return ScalarOperation_DC_ZVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
DC.ZVA executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.ZVA.asl -->
```asl
readonly func InstructionContractHandler_DC_ZVA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_ZVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_ZVA()
    => MaintenanceOperation
begin
    return Maintenance_DC_ZVA;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_ZVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_ZVA()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- Cache maintenance is a local synchronous hint completion at every ACR.

## State effects

- Success records Maintenance_DC_ZVA and its exact operand token.
- Success advances exactly one data-cache, instruction-cache, bundle-cache, or TLB epoch and then advances TPC.

## Memory effects and ordering

### Memory effects

- No ordinary scalar memory access is performed; success records the operation and operand and advances the selected maintenance epoch.

### Ordering

- Check block placement and encoded legality before source reads or architectural effects.
- Snapshot every scalar source before the selected system effect, then advance TPC only after success.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- dc.zva SrcL
