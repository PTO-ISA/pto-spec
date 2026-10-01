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

`SSRSWAP` 用一步原子操作交换一个系统寄存器与一个标量值。它读取被寻址的寄存器，把 `SrcL` 的值存入其位置，并把读到的值发布到 Reg5 目的地。

<!-- PTO-READER-BLOCK: scalar-ssrswap-mechanism role=mechanism -->
## 系统机制

`InstructionContractHandler_SSRSWAP` 选择 `ScalarHandler_ExecuteSystemRegisterSwap`（`asl/scalar/sys/SSRSWAP.asl:18`），派发器解码全部三个操作数：`RegDst`、`SrcL` 以及 12 位 `SSR_ID` 地址（`asl/scalar/model/dispatch/sys.asl:116`）。`InstructionContractSystemTransferKind_SSRSWAP` 返回 `'10'`，即把交换与读取或写入区分开的传送种类（`asl/scalar/sys/SSRSWAP.asl:30`）。

该辅助函数在读取任何内容之前先对两个方向做预检：`ExecuteSystemRegisterSwap` 要求 `SystemRegisterSwapPermitted`，而它要求读权限、写权限以及读写访问类别（`asl/scalar/model/sys/registers.asl:168`）。

<!-- PTO-READER-BLOCK: scalar-ssrswap-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SSR_ID` 是 12 位地址，`SrcL` 是新值的 Reg5 源，`RegDst` 是 Reg5 目的地选择器 `discard, R1..R23, push U, or push T`（`asl/scalar/sys/SSRSWAP.asl:1`）。目的地接收的是寄存器的旧值，而不是被写入的值。

`SrcL` 中的编码零命名架构零 GPR，这使该交换成为用一条指令读取并清除某寄存器的方式。

<!-- PTO-READER-BLOCK: scalar-ssrswap-effects role=effects -->
## 架构效果

成功的尝试快照源、读取寄存器旧值、写入新值、把旧值发布到目的地，并把 `TPC` 推进 4 字节。如果读取引发了故障，则跳过寄存器写入，同时也跳过目的地写入（`asl/scalar/model/sys/registers.asl:140`）。

设计要点：交换是一次读/写事务，因此两个方向的权限都在读取之前检查。ASL 注释给出了原因：读取可能带有副作用，其中记录的示例是对一个不可写寄存器的定时器待决刷新。只先检查读方向会让本应失败的交换仍然执行那次读侧副作用。

不执行普通标量内存访问。

<!-- PTO-READER-BLOCK: scalar-ssrswap-constraints role=constraints -->
## 位置与拒绝边界

在活动 SYS 块体之外，该次尝试在操作数处理开始之前引发 `Fault_BundleControl`。随后交换预检在任一方向缺少环权限，或访问类别为未知、只读或只写时以 `Fault_IllegalInstruction` 拒绝。除读写之外的任何访问类别都不能被交换。

设计要点：地址 0x1F02 是一个读写上下文寄存器，但它的低位索引处于或高于 0x0F00，因此即使同一地址模式在别的库中是开放的，它也需要 ACR0。因此在 ACR1 交换该地址会出错，而不是返回 ring 1 的值。

<!-- PTO-READER-BLOCK: scalar-ssrswap-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

在 ACR0，`ssrswap SrcL, SSR_ID, ->{t, u, Rd}` 在 `SSR_ID` 为 0x1F02 且源持有 8 时写入打包的 ring 1 陷阱状态寄存器，并把该寄存器的先前值返回给目的地；写入的值在该寄存器中留下陷阱号 8、零原因以及被清除的状态标志。改用 `SSR_ID` 0x0010 重复则被拒绝，因为 `TIME` 是只读的，而交换要求读写类别。
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
