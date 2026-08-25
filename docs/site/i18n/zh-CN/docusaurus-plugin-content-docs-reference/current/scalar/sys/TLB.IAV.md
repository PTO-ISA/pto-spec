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

`TLB.IAV` 同步完成所分配的缓存或地址翻译维护请求，并记录精确操作令牌。

<!-- PTO-READER-BLOCK: scalar-tlb-iav-mechanism role=mechanism -->
## 系统机制

ASL DOC 区域选择 `ScalarHandler_ExecuteMaintenance`。读取源或改变系统状态之前，必须先检查位置和编码合法性。

该指令占用活动 SYS 块体中的一个标量操作位置。

<!-- PTO-READER-BLOCK: scalar-tlb-iav-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SrcL` 承载 Reg5 源：R0..R23、T#1..T#4 或 U#1..U#4。

编码零是已分配的字段值，从不表示省略操作数。

<!-- PTO-READER-BLOCK: scalar-tlb-iav-effects role=effects -->
## 架构效果

成功时，维护记录接收 `Maintenance_TLB_IAV` 和精确捕获的操作数令牌。

选中的缓存或 TLB 纪元恰好递增一次，然后 `TPC` 前进；该操作是同步完成的本地提示。

<!-- PTO-READER-BLOCK: scalar-tlb-iav-constraints role=constraints -->
## 位置与拒绝边界

TLB 维护只在 `ACR0` 接受；环权限先于操作数验证进行检查。操作数必须是携带 ASID 作用域的规范 48 位虚拟地址。

无效的 SYS 块位置会在字段检查之前被拒绝。保留编码或访问拒绝除普通陷阱包络外，不产生目的地、队列、系统状态或 `TPC` 效果。

<!-- PTO-READER-BLOCK: scalar-tlb-iav-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

可从 `tlb.iav SrcL` 开始，先沿编码字段完成预检，再继续查看所选系统效果。
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
