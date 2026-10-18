<!-- GENERATED FROM: asl/scalar/sys/SYNC.CORE.asl -->
# SYNC.CORE

**Normative ASL source:** `asl/scalar/sys/SYNC.CORE.asl`

Waits for all four PEs at the same Core-local phase boundary and completes their earlier GM obligations.

## Normative identity {#PTO-INST-SCALAR-SYNC-CORE}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sync-core-purpose role=purpose -->
## SYNC.CORE 的用途
`SYNC.CORE` 为一次内核调用中同一 Core 的四个 PE 建立局部阶段边界。它确保后续工作不会越过一个尚未完成的早期阶段；该阶段要求所有参与 PE 及其 GM 义务都已完成。

<!-- PTO-READER-BLOCK: scalar-sync-core-mechanism role=mechanism -->
## 会合机制
每个 PE 在同一调用和动态顺序中到达同一个静态 `SYNC.CORE`。只有当更早的工作不再可能发生故障或需要恢复时，到达才成为不可撤销。已经验证但尚未完成的早期 GM 工作可以在到达后继续存在，但集体完成必须等待它通过实际的生产、发出和完成路径得到解决。PE 会停驻，直到四个参与者都已到达且截止点之前的 GM 义务全部完成；随后已完成的代会被保留，直到每个停驻 PE 恰好消费一次释放。

<!-- PTO-READER-BLOCK: scalar-sync-core-inputs-outputs role=inputs-outputs -->
## 输入与输出
该指令没有编码操作数，并且始终指代当前 Core 的 PE0、PE1、PE2 和 PE3。它不产生寄存器值或内存值。其可观察结果是：会合和所需 GM 推进完成后，每个参与者都可以越过同一个阶段边界继续执行。

<!-- PTO-READER-BLOCK: scalar-sync-core-effects role=effects -->
## 状态与排序效果
被阻塞的 PE 将 `TPC` 保持在 `SYNC.CORE`。完成后，每个参与者较早的合格 GM 操作都排在每个参与者较晚的合格 GM 操作之前；同时使各参与者当前的本地保留失效，并允许每个 PE 恰好前进一次。释放信号会一直保留到被消费，从而避免较快的 PE 丢失完成通知。

<!-- PTO-READER-BLOCK: scalar-sync-core-constraints role=constraints -->
## 合法包络与拒绝
唯一合法的主体是 `BSTART.SYS FALL`、一个精确的 `sync.core` 指令字 `0x0330a02b` 和 `BSTOP`。该指令要求存在活动内核调用，且不能从处理程序来源的执行进入。错误的块类型或转移、额外主体操作、畸形或不可取指的结束指令，以及处理程序进入，都会在记录任何屏障到达之前拒绝；既有的包、指令或取指故障指出失败检查。

<!-- PTO-READER-BLOCK: scalar-sync-core-example role=example -->
## 阶段边界示例
```text
BSTART.SYS FALL
sync.core
BSTOP
```
若 PE0、PE1 和 PE2 先到达该序列，它们都会停驻并把 `TPC` 保持在 `sync.core`。当 PE3 不可撤销地到达且先前 GM 义务已经完成后，PE3 继续执行，保留的释放则让另外三个 PE 各继续一次。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sync.core
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sync_core_32_0330a02b7c32 | L32 | 32 | 0x0330a02b / 0xffffffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/SYNC.CORE.asl -->
```asl
readonly func InstructionContractOperation_SYNC_CORE() => ScalarOperation
begin
    return ScalarOperation_SYNC_CORE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
The only canonical body is BSTART.SYS FALL, sync.core, BSTOP.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/SYNC.CORE.asl -->
```asl
readonly func InstructionContractHandler_SYNC_CORE() => ScalarSemanticHandler
begin
    return ScalarHandler_SyncCore;
end;

pure func InstructionContractRequiresSystemBlock_SYNC_CORE() => boolean
begin
    return TRUE;
end;

func ExecuteSyncCore()
begin
    if _CurrentMemoryOrigin == MemoryEventOrigin_Handler then
        SetFault(Fault_BundleControl, ReadTPC());
        return;
    end;
    if !_KernelInvocationActiveByCore[[_CurrentModelCore]] ||
       _CurrentKernelInvocation == 0 then
        SetFault(Fault_BundleControl, ReadTPC());
        return;
    end;
    if !VerificationGMProgressIsDeferred() then
        ProgressKernelGMObligationsForCore(_CurrentModelCore,
            _CurrentKernelInvocation);
    end;
    if _LastFault != Fault_None then return; end;
    SyncCore();
end;

pure func InstructionContractParticipantCount_SYNC_CORE() => integer {4}
begin
    return 4;
end;

pure func InstructionContractExactMatch_SYNC_CORE() => bits(32)
begin
    return '00000011001100001010000000101011';
end;

pure func InstructionContractExactMask_SYNC_CORE() => bits(32)
begin
    return Ones{32};
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SYNC.CORE has no operands and includes PE0, PE1, PE2, and PE3.

## Legality

- Only the exact 32-bit word 0x0330a02b decodes as SYNC.CORE. The active bundle must be a Fallthrough SYS block with exactly one SYNC.CORE body operation and a required BSTOP.

## State effects

- A blocked PE does not advance its PC. On completion, the barrier generation is retained until each parked PE consumes its release once, and each participant's current local reservation is invalidated.

## Memory effects and ordering

### Memory effects

- Completion orders earlier qualifying GM operations before later qualifying GM operations for every participant pair, after those earlier operations reach their existing completion and visibility point.

### Ordering

- A PE parks at SYNC.CORE until all four PEs have irrevocably arrived at the same static instruction in the same dynamic order and invocation and every earlier GM obligation has completed. Arrival cannot be irrevocable while older work may still fault or require recovery.

## Exceptions

- The complete SYS envelope is validated before collective arrival. Wrong block composition raises Fault_BundleControl; a nonmatching instruction encoding raises Fault_IllegalInstruction.

## Examples

- sync.core
