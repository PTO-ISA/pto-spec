<!-- GENERATED FROM: asl/scalar/sys/TLB.IAV.asl -->
# TLB.IAV

**Normative ASL source:** `asl/scalar/sys/TLB.IAV.asl`

TLB.IAV completes the canonical 48-bit virtual address with ASID scope maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-TLB-IAV}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-tlb-iav-purpose role=purpose -->
## TLB.IAV 的作用

`TLB.IAV` 同步完成带地址空间标识作用域的规范 48 位虚拟地址维护操作。它的编码操作数与 `TLB.IV` 取的是同一类 48 位地址；区别在于维护请求所针对的作用域，这由操作令牌 `Maintenance_TLB_IAV` 指明。

<!-- PTO-READER-BLOCK: scalar-tlb-iav-mechanism role=mechanism -->
## 系统机制

`InstructionContractHandler_TLB_IAV` 返回共用的维护处理程序（`asl/scalar/sys/TLB.IAV.asl:18`），而令牌 `Maintenance_TLB_IAV` 与 `Maintenance_TLB_IV` 一起位于执行器的地址分支（`asl/scalar/model/sys/semantics.asl:142`）。两者共用规范地址测试和同一条特权规则。

`InstructionContractMaintenanceRequiresRootRing_TLB_IAV` 返回 `TRUE`（`asl/scalar/sys/TLB.IAV.asl:42`），因此该操作在执行器检查操作数之前就拒绝 ACR0 之外的任何环。

<!-- PTO-READER-BLOCK: scalar-tlb-iav-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SrcL` 是唯一编码操作数，即来自 R0..R23、T#1..T#4 或 U#1..U#4 的 Reg5 源。该形式没有单独的标识符字段，因此编码操作数只是地址；该操作所指名的地址空间作用域并不携带在指令中（`asl/scalar/sys/TLB.IAV.asl:1`）。

不写任何目的地。成功时操作数出现在维护记录中；被拒绝时什么都不发布。

<!-- PTO-READER-BLOCK: scalar-tlb-iav-effects role=effects -->
## 架构效果

成功时 TLB 纪元递增一，`Maintenance_TLB_IAV` 与已捕获的地址进入维护记录（`asl/scalar/model/sys/semantics.asl:146`）。随后 `TPC` 从派发器的成功路径前进。

设计要点：记录保留操作令牌，因此读者能够把这条按地址空间限定作用域的请求与普通 `TLB.IV` 请求区分开，即使两者推进同一个计数器。

不发生普通标量内存访问，也不写任何寄存器、临时队列或系统寄存器。

<!-- PTO-READER-BLOCK: scalar-tlb-iav-constraints role=constraints -->
## 位置与拒绝边界

与每条 SYS 块指令一样，在活动 SYS 块体之外的尝试会在合法性检查和效果之前引发 `Fault_BundleControl`。随后编码合法性覆盖固定位与 `SrcL` 选择器。

在执行器处，非根环先引发 `Fault_IllegalInstruction`。只有 ACR0 的尝试才会到达规范地址检查，那里的非规范值会引发 `Fault_DataPage`，并以该操作数作为陷阱参数，同时 TLB 纪元不改变（`asl/scalar/model/sys/semantics.asl:143`）。

<!-- PTO-READER-BLOCK: scalar-tlb-iav-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

在 ACR0 且源寄存器持有 0x1234 时，`tlb.iav SrcL` 把 TLB 纪元递增一并以操作数 0x1234 记录 `Maintenance_TLB_IAV`。如果该寄存器持有的值的第 63:48 位不是第 47 位的符号扩展，该次尝试会引发 `Fault_DataPage`，TLB 纪元保持原值。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
tlb.iav SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| tlb_iav_32_95f4937d2917 | L32 | 32 | 0x0020702b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| tlb_iav_32_95f4937d2917 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| tlb_iav_32_95f4937d2917 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/TLB.IAV.asl -->
```asl
readonly func InstructionContractOperation_TLB_IAV()
    => ScalarOperation
begin
    return ScalarOperation_TLB_IAV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
TLB.IAV executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/TLB.IAV.asl -->
```asl
readonly func InstructionContractHandler_TLB_IAV()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_TLB_IAV()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_TLB_IAV()
    => MaintenanceOperation
begin
    return Maintenance_TLB_IAV;
end;

pure func InstructionContractMaintenanceUsesOperand_TLB_IAV()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_TLB_IAV()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- TLB maintenance is assigned only at ACR0 and rejects at every other ring before operand validation.
- The operand must be a canonical 48-bit virtual address.

## State effects

- Success records Maintenance_TLB_IAV and its exact operand token.
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

- tlb.iav SrcL
