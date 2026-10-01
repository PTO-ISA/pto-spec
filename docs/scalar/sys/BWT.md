<!-- GENERATED FROM: asl/scalar/sys/BWT.asl -->
# BWT

**Normative ASL source:** `asl/scalar/sys/BWT.asl`

BWT publishes the WaitTimeout nonblocking execution-control request.

## Normative identity {#PTO-INST-SCALAR-BWT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bwt-purpose role=purpose -->
## What BWT does

`BWT` publishes one execution-control request to the architecture, carrying its source value as the request operand. The request is `ExecutionControl_WaitTimeout`.

It is a nonblocking request: the instruction publishes the request and retires. It does not suspend the thread and it does not wait for a wakeup before the next instruction.

<!-- PTO-READER-BLOCK: scalar-bwt-mechanism role=mechanism -->
## How the instruction is placed and executed

This instruction is one scalar operation of an active SYS block. The scalar dispatcher first checks that a bundle is active and that its body is active with block kind System; a SYS form outside such a block is rejected with `Fault_BundleControl`, before any encoded-field check and before any architectural effect.

Encoded legality and source availability are then checked, and only then does the handler run.

The handler reads `SrcL`, then publishes the request through the shared execution-control rule. That rule stores the request kind, stores the exact XLEN operand, and advances the architecture-request epoch by one. It consults no permission table, so the request is published unconditionally once the placement and operand checks have passed.

Design point: only the request kind and its operand are recorded, and the model defines no asleep, mailbox, timeout-counter, or pending-wake state for this request. That is what makes the request nonblocking in a testable sense: there is no additional architectural state that a later instruction could observe, so retiring immediately is the complete behavior.

<!-- PTO-READER-BLOCK: scalar-bwt-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

- `SrcL` is the source selector and supplies the complete XLEN request operand.
- Source selectors `0`..`23` read GPRs, `24`..`27` read `T#1`..`T#4`, and `28`..`31` read `U#1`..`U#4`. Reading a temporary never consumes or reorders it.
- Source selector `0` always reads XLEN zero, and zero is a legal operand value: it is recorded as the operand, not treated as an omission.
- There is no destination field, so the instruction never writes a GPR and never pushes `T` or `U`.

<!-- PTO-READER-BLOCK: scalar-bwt-effects role=effects -->
## Architectural effects

The published effects are the recorded request kind, the recorded operand and one increment of the architecture-request epoch. The source register and its queue entry, if any, are unchanged, because the instruction only reads them.

`TPC` advances by `4` bytes. The instruction performs no memory access and leaves no reservation, so it cannot itself be the reason a later atomic or load-linked operation fails.

<!-- PTO-READER-BLOCK: scalar-bwt-constraints role=constraints -->
## Placement and rejection

Invalid block placement is rejected first, with `Fault_BundleControl`, before the encoded field is even considered.

Every assigned Reg5 source selector follows the common scalar-source availability rule: `0`..`23` are always available, and a `T` or `U` selector is available only while that queue slot holds a value. An unavailable selector raises `Fault_IllegalInstruction` before the request is published, so a rejected `BWT` records nothing and does not advance the request epoch.

There is no per-request permission test in the handler, so the operand value itself never causes a rejection.

<!-- PTO-READER-BLOCK: scalar-bwt-example role=example -->
## Non-normative example

`bwt a0` reads the operand from `a0`, publishes `ExecutionControl_WaitTimeout` with that operand, advances the architecture-request epoch by one, and advances `TPC` by `4` bytes. Execution continues with the next instruction without waiting.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bwt SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bwt_32_5a0fe4a8e61f | L32 | 32 | 0x0030002b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bwt_32_5a0fe4a8e61f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bwt_32_5a0fe4a8e61f | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/BWT.asl -->
```asl
readonly func InstructionContractOperation_BWT()
    => ScalarOperation
begin
    return ScalarOperation_BWT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BWT executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/BWT.asl -->
```asl
readonly func InstructionContractHandler_BWT()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteControlRequest;
end;

pure func InstructionContractRequiresSystemBlock_BWT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractControlRequest_BWT()
    => ExecutionControlRequest
begin
    return ExecutionControl_WaitTimeout;
end;

pure func InstructionContractControlRequestIsNonblocking_BWT()
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
- Every assigned Reg5 source selector follows the common scalar-source availability rule.

## State effects

- Snapshot SrcL, publish ExecutionControl_WaitTimeout and the exact XLEN operand, increment the architecture-request epoch, then advance TPC.
- PTO defines no additional asleep, mailbox, timeout-counter, or pending-wake state for this nonblocking request.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Check block placement and encoded legality before source reads or architectural effects.
- Snapshot every scalar source before the selected system effect, then advance TPC only after success.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- bwt SrcL
