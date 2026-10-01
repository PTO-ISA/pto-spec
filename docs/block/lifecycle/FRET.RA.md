<!-- GENERATED FROM: asl/block/lifecycle/FRET.RA.asl -->
# FRET.RA

**Normative ASL source:** `asl/block/lifecycle/FRET.RA.asl`

Restores a restartable stack frame and returns through the pre-restore architectural return address.

## Normative identity {#PTO-INST-BLOCK-FRET-RA}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-fret-ra-purpose role=purpose -->
## What FRET.RA does

`FRET.RA` removes a stack frame and returns, in one command. It restores registers exactly like [FEXIT](FEXIT.md), and then transfers to the return address that was current before the restore began.

The return address is the return-address state `_ReturnAddress`. Call-form block starts and [SETRET](../../scalar/bru/SETRET.md) write the same value to it and to R10 (`ra`). The stack pointer is GPR 1 (`sp`). The shared frame template is described in [frame lifetime](../model/lifecycle/lifetime.md).

<!-- PTO-READER-BLOCK: block-fret-ra-mechanism role=mechanism -->
## Placement and execution mechanism

`FRET.RA` is a standalone 32-bit command. It does not open or commit a block and does not write `BARG`.

Execution follows a fixed order:

1. Check the endpoints and frame size.
2. Snapshot `_ReturnAddress` as the return target. An odd target raises `Fault_InstructionPC`.
3. Compute `caller_sp = sp + size` and write it to `sp`.
4. Load the registers in range order from `caller_sp - 8`, `caller_sp - 16`, and so on.
5. After the last load, decrement the frame depth if it is nonzero, record the last-frame tuple, and write the snapshotted target to `TPC`.

Design point: the target is captured before any register is restored. If the range includes R10, the restore changes `ra` and `_ReturnAddress`, but the command still returns to the address that was current when it started.

<!-- PTO-READER-BLOCK: block-fret-ra-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- `DstBegin`, bits `19:15`, is the first register of the range.
- `DstEnd`, bits `24:20`, is the last register of the range.
- `uimm` is a 12-bit field split across bits `31:25` (value bits `6:0`) and bits `11:7` (value bits `11:7`). The frame size in bytes is `uimm << 3`.

The range is inclusive over the ring `R2..R23` and wraps from R23 to R2. Every field is always encoded; there is no default. Encoded zero in an endpoint names R0 and is reserved. Encoded zero in `uimm` is a real zero-byte frame and is illegal.

<!-- PTO-READER-BLOCK: block-fret-ra-effects role=effects -->
## State effects and ordering

Each load reads one aligned 8 bytes as a relaxed load event and writes its register. As with `FEXIT`, each load and its progress step form one restart event, and a retried command does not add to `sp` twice or repeat an earlier load.

Completion decrements `_FrameDepth` when it is nonzero, records the last frame, and writes `TPC` with the target. There is no sequential `TPC` increment.

Design point: the transfer is written only after the last register is restored. A fault part-way through leaves `TPC` at the `FRET.RA`, so recovery re-executes it and continues the restore before returning.

<!-- PTO-READER-BLOCK: block-fret-ra-constraints role=constraints -->
## Legality, faults, and atomicity

- An endpoint outside `2..23`, or a frame smaller than 8 bytes per register, raises `Fault_IllegalInstruction` before any effect.
- An odd return target raises `Fault_InstructionPC` before any `sp`, memory, register, frame, or return effect.
- A load follows the ordinary data-access fault rules and faults precisely at its step.
- While a frame template is in progress, a frame command of another kind, or one at another PC, raises `Fault_IllegalInstruction` instead of continuing it.

The generated legality and exception sections below are authoritative.

<!-- PTO-READER-BLOCK: block-fret-ra-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
FRET.RA [RegDst0 ~ RegDstn], sp!, uimm
```

A function saved R8 to R11 in a 48-byte frame, so `sp` is `0x7FD0`, and `_ReturnAddress` is `0x3000`. `FRET.RA` with `DstBegin = 8`, `DstEnd = 11`, and encoded `uimm` 6 snapshots `0x3000`, sets `sp` to `0x8000`, and restores R8 to R11. R10 receives the saved value from `0x7FE8`, which also updates `_ReturnAddress`. `TPC` still becomes `0x3000`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
FRET.RA [RegDst0 ~ RegDstn], sp!, uimm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fret_ra_32_659c886221c1 | L32 | 32 | 0x00002041 / 0x0000707f | [{"field":"DstBegin","operator":"one-of","values":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"DstEnd","operator":"one-of","values":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fret_ra_32_659c886221c1 | DstBegin | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fret_ra_32_659c886221c1 | DstEnd | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fret_ra_32_659c886221c1 | uimm | 12 | unsigned | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fret_ra_32_659c886221c1 | DstBegin | 5 | 2–23 | none | 0–1, 24–31 | first register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fret_ra_32_659c886221c1 | DstEnd | 5 | 2–23 | none | 0–1, 24–31 | last register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fret_ra_32_659c886221c1 | uimm | 12 | 0–4095 | none | none | frame byte count, encoded in multiples of eight | Encoded zero is a real zero-byte frame size and is illegal for every nonempty range. |

- `fret_ra_32_659c886221c1.DstBegin` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `fret_ra_32_659c886221c1.DstEnd` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DstBegin | first register in the inclusive R2..R23 ring range |
| DstEnd | last register in the inclusive R2..R23 ring range |
| uimm | frame byte count, encoded in multiples of eight |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/FRET.RA.asl -->
```asl
readonly func InstructionContractMatches_FRET_RA(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fret_ra_32_659c886221c1);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/FRET.RA.asl -->
```asl
readonly func InstructionContractHandler_FRET_RA() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameReturnAddress;
end;

func ExecuteFRETRA(begin_reg: Reg5Selector,
                   end_reg: Reg5Selector,
                   frame_size: Word)
begin
    ReturnFromFrame(begin_reg, end_reg, frame_size, TRUE);
end;

pure func InstructionContractUsesInclusiveRegisterRange_FRET_RA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractRejectsInvalidFrameRange_FRET_RA()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The inclusive register range is the ring R2..R23. Singleton, full-ring, and wraparound ranges are assigned.
- uimm is always present and encodes the frame byte count scaled by eight: the semantic byte count is the encoded value shifted left by three, so the encoding supplies only multiples of eight; encoded zero is real zero and is illegal because every assigned range contains at least one register.
- The return target is the architectural ra value snapshotted before any restored register can overwrite ra.

## Legality

- DstBegin and DstEnd select the inclusive R2..R23 callee-save ring; every endpoint outside 2..23 is reserved before effects.
- If the range contains N registers, uimm must be at least 8*N bytes. The encoding supplies only multiples of eight.

## State effects

- Restoring a range that contains ra updates the architectural ra value without changing the already snapshotted return target.
- Completion decrements nonzero frame depth, publishes the last-frame tuple, clears progress, and transfers to the validated target.

## Memory effects and ordering

### Memory effects

- Load one aligned eight-byte value per selected destination using the same restartable frame-slot order as FEXIT.

### Ordering

- Snapshot and validate the pre-restore return target, add uimm to sp, then restore descending slots in register-ring order.
- After the final restore, publish the snapshotted target to TPC; the command does not perform a sequential TPC increment.

## Exceptions

- Reserved endpoints or an insufficient frame size raise Fault_IllegalInstruction before sp, register, memory, target, progress, or TPC effects.
- Each eight-byte stack access is a restart boundary. A recoverable access fault preserves earlier committed events and retries exactly the first uncommitted event from trap-preserved template state.
- An odd pre-restore ra raises Fault_InstructionPC before sp, memory, destination, frame, or return effects.

## Examples

- FRET.RA [RegDst0 ~ RegDstn], sp!, uimm
