<!-- GENERATED FROM: asl/scalar/sys/SSRSWAP.asl -->
# SSRSWAP

**Normative ASL source:** `asl/scalar/sys/SSRSWAP.asl`

SSRSWAP atomically swaps the complete encoded system-register address.

## Normative identity {#PTO-INST-SCALAR-SSRSWAP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ssrswap-purpose role=purpose -->
## SSRSWAP 的作用

`SSRSWAP` 原子交换已分配的 RW 系统寄存器，并发布其旧 XLEN 值。

<!-- PTO-READER-BLOCK: scalar-ssrswap-mechanism role=mechanism -->
## 系统机制

ASL DOC 区域选择 `ScalarHandler_ExecuteSystemRegisterSwap`。读取源或改变系统状态之前，必须先检查位置和编码合法性。

该指令占用活动 SYS 块体中的一个标量操作位置。

<!-- PTO-READER-BLOCK: scalar-ssrswap-inputs-outputs role=inputs-outputs -->
## 输入与输出

`RegDst` 承载 Reg5 目的地：丢弃、R1..R23、压入 U 或压入 T；`SSR_ID` 承载系统寄存器标识符；`SrcL` 承载 Reg5 源：R0..R23、T#1..T#4 或 U#1..U#4。

编码零是已分配的字段值，从不表示省略操作数。

<!-- PTO-READER-BLOCK: scalar-ssrswap-effects role=effects -->
## 架构效果

读写预检完成后，所选 RW 系统寄存器与快照得到的 `SrcL` 原子交换，并通过 `RegDst` 发布旧 XLEN 值。

交换被拒绝时，除普通陷阱进入外，不会更新寄存器、目的地、队列、读取副作用或 `TPC`。

<!-- PTO-READER-BLOCK: scalar-ssrswap-constraints role=constraints -->
## 位置与拒绝边界

消费源值或旧寄存器值之前，必须先确认读写权限和 RW 访问类别。

无效的 SYS 块位置会在字段检查之前被拒绝。保留编码或访问拒绝除普通陷阱包络外，不产生目的地、队列、系统状态或 `TPC` 效果。

<!-- PTO-READER-BLOCK: scalar-ssrswap-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

可从 `ssrswap SrcL, SSR_ID, ->{t, u, Rd}` 开始，先沿编码字段完成预检，再继续查看所选系统效果。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ssrswap SrcL, SSR_ID, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ssrswap_32_a01c7e2c7c29 | L32 | 32 | 0x0000203b / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ssrswap_32_a01c7e2c7c29 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ssrswap_32_a01c7e2c7c29 | SSR_ID | 12 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |
| ssrswap_32_a01c7e2c7c29 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ssrswap_32_a01c7e2c7c29 | RegDst | 5 | 0–31 | none | none | Reg5 destination: discard, R1..R23, push U, or push T | Encoded zero names the architectural zero GPR. |
| ssrswap_32_a01c7e2c7c29 | SSR_ID | 12 | 0–4095 | none | none | system-register identifier | Encoded zero selects value zero of the system-register identifier. |
| ssrswap_32_a01c7e2c7c29 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination: discard, R1..R23, push U, or push T |
| SSR_ID | system-register identifier |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/SSRSWAP.asl -->
```asl
readonly func InstructionContractOperation_SSRSWAP()
    => ScalarOperation
begin
    return ScalarOperation_SSRSWAP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
SSRSWAP executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/SSRSWAP.asl -->
```asl
readonly func InstructionContractHandler_SSRSWAP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterSwap;
end;

pure func InstructionContractRequiresSystemBlock_SSRSWAP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSystemTransferKind_SSRSWAP()
    => bits(2)
begin
    return '10';
end;

pure func InstructionContractSystemAddressWidth_SSRSWAP()
    => integer {5,12,24}
begin
    return 12;
end;

pure func InstructionContractPushesTemporaryT_SSRSWAP()
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
- The complete encoded address is checked against its RO, WO, RW, unknown-address, and current-ACR access rules before effects.

## State effects

- Atomically exchange the selected RW system register with the snapshotted source and publish the old value through RegDst.
- A rejected swap performs neither read-side effects nor register, destination, queue, or TPC effects.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Preflight read permission, write permission, and RW access class before reading SrcL or the old register value.
- Snapshot SrcL, read the old value, write the new value, publish the old value, and then advance TPC.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- ssrswap SrcL, SSR_ID, ->{t, u, Rd}
