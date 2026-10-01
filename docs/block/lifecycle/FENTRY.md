<!-- GENERATED FROM: asl/block/lifecycle/FENTRY.asl -->
# FENTRY

**Normative ASL source:** `asl/block/lifecycle/FENTRY.asl`

Creates a restartable stack frame by snapshotting and storing one inclusive callee-save register-ring range.

## Normative identity {#PTO-INST-BLOCK-FENTRY}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-fentry-purpose role=purpose -->
## What FENTRY does

`FENTRY` creates a stack frame in one command. It lowers the stack pointer by the frame size and saves a range of callee-save registers into the new frame, one 8-byte slot per register. It is the entry half of a pair: [FEXIT](FEXIT.md), [FRET.RA](FRET.RA.md), and [FRET.STK](FRET.STK.md) undo it.

The stack pointer is GPR 1 (`sp`). The shared frame template behind all four commands is described in [frame lifetime](../model/lifecycle/lifetime.md).

<!-- PTO-READER-BLOCK: block-fentry-mechanism role=mechanism -->
## Placement and execution mechanism

`FENTRY` is a standalone 32-bit command. It does not open or commit a block and does not write `BARG`.

Execution follows a fixed order:

1. Check the endpoints and frame size.
2. Record the instruction PC, range, frame size, and the current `sp` as the caller `sp`, and copy every source register into the template.
3. Write `sp = caller_sp - size`.
4. Store the saved registers in range order to `caller_sp - 8`, `caller_sp - 16`, and so on, one store per step.
5. After the last store, increment the frame depth, record the last-frame tuple, and advance `TPC` by 4.

Design point: the source registers are copied before `sp` changes, and a retried `FENTRY` stores the copies, not the current register values. A restart therefore saves exactly the values the command first observed.

<!-- PTO-READER-BLOCK: block-fentry-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- `SrcBegin`, bits `19:15`, is the first register of the range.
- `SrcEnd`, bits `24:20`, is the last register of the range.
- `uimm` is a 12-bit field split across bits `31:25` (value bits `6:0`) and bits `11:7` (value bits `11:7`). The frame size in bytes is `uimm << 3`.

The range is inclusive over the ring `R2..R23`. When `SrcEnd` is below `SrcBegin`, the range wraps from R23 to R2. A singleton range and the full 22-register ring are both legal.

Design point: every field is always encoded; there is no default. Encoded zero in `SrcBegin` or `SrcEnd` names R0, which is outside the ring and reserved. Encoded zero in `uimm` is a real zero-byte frame, which is illegal because every range holds at least one register.

<!-- PTO-READER-BLOCK: block-fentry-effects role=effects -->
## State effects and ordering

Each store is one aligned 8-byte relaxed store event. The stores go to descending slots below the caller `sp`: the first register of the range is at `caller_sp - 8`.

Completion increments `_FrameDepth` (it saturates at its upper bound) and records `SrcBegin`, `SrcEnd`, and the frame size as the last frame.

Design point: each store and its progress step commit together, so every store is a restart boundary. If a store faults, earlier stores and the `sp` update remain, and the template keeps the progress. Re-executing the same `FENTRY` at the same PC resumes with the first unsaved register. It does not reread the source registers, adjust `sp` again, or repeat an earlier store.

<!-- PTO-READER-BLOCK: block-fentry-constraints role=constraints -->
## Legality, faults, and atomicity

- An endpoint outside `2..23` raises `Fault_IllegalInstruction` before any effect.
- A frame smaller than 8 bytes per register raises `Fault_IllegalInstruction` before any effect.
- A store follows the ordinary data-access fault rules. A misaligned or unmapped slot raises `Fault_DataAlignment` or `Fault_DataPage` at that step.
- While a frame template is in progress, a frame command of another kind, or one at another PC, raises `Fault_IllegalInstruction` instead of continuing it.

The generated legality and exception sections below are authoritative.

<!-- PTO-READER-BLOCK: block-fentry-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
FENTRY [RegSrc0 ~ RegSrcn], sp!, uimm
```

Take `SrcBegin = 8`, `SrcEnd = 11`, and a 48-byte frame (encoded `uimm` 6), with `sp = 0x8000`. The range holds 4 registers, so the minimum frame is 32 bytes and 48 is legal. `sp` becomes `0x7FD0`. R8 is stored at `0x7FF8`, R9 at `0x7FF0`, R10 at `0x7FE8`, and R11 at `0x7FE0`. The 16 bytes from `0x7FD0` to `0x7FDF` are part of the frame but are not written. `FEXIT` with the same range and size restores all four registers and returns `sp` to `0x8000`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
FENTRY [RegSrc0 ~ RegSrcn], sp!, uimm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fentry_32_a47584ec13b6 | L32 | 32 | 0x00000041 / 0x0000707f | [{"field":"SrcBegin","operator":"one-of","values":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"SrcEnd","operator":"one-of","values":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fentry_32_a47584ec13b6 | SrcBegin | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fentry_32_a47584ec13b6 | SrcEnd | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fentry_32_a47584ec13b6 | uimm | 12 | unsigned | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fentry_32_a47584ec13b6 | SrcBegin | 5 | 2–23 | none | 0–1, 24–31 | first register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fentry_32_a47584ec13b6 | SrcEnd | 5 | 2–23 | none | 0–1, 24–31 | last register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fentry_32_a47584ec13b6 | uimm | 12 | 0–4095 | none | none | frame byte count, encoded in multiples of eight | Encoded zero is a real zero-byte frame size and is illegal for every nonempty range. |

- `fentry_32_a47584ec13b6.SrcBegin` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `fentry_32_a47584ec13b6.SrcEnd` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcBegin | first register in the inclusive R2..R23 ring range |
| SrcEnd | last register in the inclusive R2..R23 ring range |
| uimm | frame byte count, encoded in multiples of eight |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/FENTRY.asl -->
```asl
readonly func InstructionContractMatches_FENTRY(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fentry_32_a47584ec13b6);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/FENTRY.asl -->
```asl
readonly func InstructionContractHandler_FENTRY() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameEntry;
end;

func ExecuteFENTRY(begin_reg: Reg5Selector,
                   end_reg: Reg5Selector,
                   frame_size: Word)
begin
    EnterFrame(begin_reg, end_reg, frame_size);
end;

pure func InstructionContractUsesInclusiveRegisterRange_FENTRY()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractRejectsInvalidFrameRange_FENTRY()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The inclusive register range is the ring R2..R23. Singleton, full-ring, and wraparound ranges are assigned.
- uimm is always present and encodes the frame byte count scaled by eight: the semantic byte count is the encoded value shifted left by three, so the encoding supplies only multiples of eight; encoded zero is real zero and is illegal because every assigned range contains at least one register.
- The source range is snapshotted before sp changes, so a range containing sp stores the caller sp.

## Legality

- SrcBegin and SrcEnd select the inclusive R2..R23 callee-save ring; every endpoint outside 2..23 is reserved before effects.
- If the range contains N registers, uimm must be at least 8*N bytes. The encoding supplies only multiples of eight.

## State effects

- The accepted start records instruction PC, endpoints, count, frame size, caller sp, complete source snapshot, and zero progress.
- After the final store, increment frame depth, publish the last-frame tuple, clear active progress, and retire once.

## Memory effects and ordering

### Memory effects

- Store one aligned eight-byte snapshot per selected register into consecutive descending slots below the caller sp.
- Every store records one relaxed store event and follows the ordinary PTO precise data-access fault contract.

### Ordering

- Snapshot the complete source range, subtract uimm from sp, then store snapshots in range order to caller_sp-8, caller_sp-16, and subsequent descending slots.
- Each store and progress advance commit atomically; recovery never rereads source registers or repeats an earlier store.

## Exceptions

- Reserved endpoints or an insufficient frame size raise Fault_IllegalInstruction before sp, register, memory, target, progress, or TPC effects.
- Each eight-byte stack access is a restart boundary. A recoverable access fault preserves earlier committed events and retries exactly the first uncommitted event from trap-preserved template state.

## Examples

- FENTRY [RegSrc0 ~ RegSrcn], sp!, uimm
