<!-- GENERATED FROM: asl/scalar/sys/BSE.asl -->
# BSE

**Normative ASL source:** `asl/scalar/sys/BSE.asl`

BSE publishes a legacy SendEvent request when MSGB is disabled; enabled contexts use atomic message admission.

## Normative identity {#PTO-INST-SCALAR-BSE}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bse-purpose role=purpose -->
## What BSE does

`BSE` has two modes selected by the current context. When MSGB is disabled, it publishes the legacy `ExecutionControl_SendEvent` request with its source value as the request operand. When MSGB is enabled, the source value is a message control word and BSE attempts atomic message admission.

Neither mode waits for a remote consumer. Disabled mode retires after publishing the request. Enabled mode retires after the local admission result is recorded; queue backpressure or an older fault-capable GM obligation may prevent immediate admission.

<!-- PTO-READER-BLOCK: scalar-bse-mechanism role=mechanism -->
## How the instruction is placed and executed

This instruction is one scalar operation of an active SYS block. The scalar dispatcher first checks that a bundle is active and that its body is active with block kind System; a SYS form outside such a block is rejected with `Fault_BundleControl`, before any encoded-field check and before any architectural effect.

Encoded legality and source availability are then checked, and only then does the handler run.

After the common checks, the dispatcher inspects the current MSGB binding. Disabled mode calls the legacy execution-control helper. Enabled mode calls the [message-send owner](../../arch/state/message-buffer-send.md), which validates the kernel context, Block attributes, older fault-capable work, destination binding, queue capacity, and control fields before admission.

Design point: explicit enablement preserves the old request-only contract for existing software. Enabled mode adds observable message state without changing the BSE encoding. Its control word uses bits 31:0 for the destination endpoint and bits 35:32 for 0 through 10 valid staged words; bits 63:36 are reserved zero.

<!-- PTO-READER-BLOCK: scalar-bse-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

- `SrcL` supplies the complete XLEN legacy request operand or enabled-mode message control word.
- Source selectors `0`..`23` read GPRs, `24`..`27` read `T#1`..`T#4`, and `28`..`31` read `U#1`..`U#4`. Reading a temporary never consumes or reorders it.
- Source selector `0` reads XLEN zero. Disabled mode records that operand; enabled mode interprets it as a zero-word message to endpoint zero.
- There is no destination field, so the instruction never writes a GPR and never pushes `T` or `U`.

<!-- PTO-READER-BLOCK: scalar-bse-effects role=effects -->
## Architectural effects

Disabled mode records the request kind and operand and increments the architecture-request epoch. Enabled admission copies the selected staged words to the destination-owned queue, allocates a transport message identity once, and records the transmit result. An exact replay returns the retained identity without enqueuing another message.

After successful execution, `TPC` advances by `4` bytes. Admission copies message words but does not establish visibility for unrelated GM payload. The source register and any referenced temporary queue entry remain unchanged.

<!-- PTO-READER-BLOCK: scalar-bse-constraints role=constraints -->
## Placement and rejection

Invalid block placement is rejected first, with `Fault_BundleControl`, before the encoded field is even considered.

Every assigned Reg5 source selector follows the common scalar-source availability rule: `0`..`23` are always available, and a `T` or `U` selector is available only while that queue slot holds a value. An unavailable selector raises `Fault_IllegalInstruction` before either mode has an effect.

Disabled mode has no additional operand permission test. Enabled mode requires a current bound kernel context, rejects `atomic` or `far` SYS envelopes, rejects reserved control fields and invalid destinations, and reports `BUSY` without allocating an identity when the target queue or replay-receipt table is full.

<!-- PTO-READER-BLOCK: scalar-bse-example role=example -->
## Non-normative example

With MSGB disabled, `bse a0` publishes `ExecutionControl_SendEvent` with the value in `a0`. With MSGB enabled, `a0 = 0x0000000200000010` selects endpoint 16 and two staged words; admission copies those words, while a later receive claim and ACK remain separate operations.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bse SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bse_32_883b5167edbc | L32 | 32 | 0x0000002b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bse_32_883b5167edbc | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bse_32_883b5167edbc | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/BSE.asl -->
```asl
readonly func InstructionContractOperation_BSE()
    => ScalarOperation
begin
    return ScalarOperation_BSE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSE executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/BSE.asl -->
```asl
readonly func InstructionContractHandler_BSE()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteControlRequest;
end;

pure func InstructionContractRequiresSystemBlock_BSE()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractControlRequest_BSE()
    => ExecutionControlRequest
begin
    return ExecutionControl_SendEvent;
end;

readonly func InstructionContractControlRequestIsNonblocking_BSE()
    => boolean
begin
    return !MessageBufferEnabledForCurrentContext();
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.
- MSGB contexts reset disabled; disabled BSE retains the legacy nonblocking SendEvent request.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- Every assigned Reg5 source selector follows the common scalar-source availability rule.
- Enabled MSGB uses PTO-ARCH-MSGB-SEND-001: control bits 31:0 select the destination endpoint, bits 35:32 give 0..10 valid words, and bits 63:36 are reserved zero.
- Enabled MSGB requires the current bound kernel context and rejects atomic/far envelopes before effects.

## State effects

- When MSGB is disabled, snapshot SrcL, publish ExecutionControl_SendEvent and the exact XLEN operand, increment the architecture-request epoch, then advance TPC.
- When MSGB is enabled, the message-buffer owner preflights and atomically captures staging data, allocates a transport message identity, and publishes the exact admission result.
- Retries of an admitted dynamic occurrence preserve the captured message identity without another enqueue; queue backpressure and invalid controls do not allocate an identity.

## Memory effects and ordering

### Memory effects

- No direct GM payload access. Message admission alone does not make unrelated data visible to a consumer.

### Ordering

- Check block placement and encoded legality before source reads or architectural effects.
- Snapshot every scalar source before the selected system effect, then advance TPC only after success.
- Enabled irreversible admission waits while earlier same-PE GM obligations may fault; this is not a payload visibility fence.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- bse SrcL
