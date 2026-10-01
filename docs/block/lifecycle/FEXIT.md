<!-- GENERATED FROM: asl/block/lifecycle/FEXIT.asl -->
# FEXIT

**Normative ASL source:** `asl/block/lifecycle/FEXIT.asl`

Destroys a restartable stack frame and restores one inclusive callee-save register-ring range.

## Normative identity {#PTO-INST-BLOCK-FEXIT}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-fexit-purpose role=purpose -->
## What FEXIT does

`FEXIT` removes a stack frame in one command. It raises the stack pointer by the frame size and reloads a range of callee-save registers from the frame, one 8-byte slot per register. It undoes a matching [FENTRY](FENTRY.md) and then continues with the next instruction. [FRET.RA](FRET.RA.md) and [FRET.STK](FRET.STK.md) do the same restore and also return.

The stack pointer is GPR 1 (`sp`). The shared frame template is described in [frame lifetime](../model/lifecycle/lifetime.md).

<!-- PTO-READER-BLOCK: block-fexit-mechanism role=mechanism -->
## Placement and execution mechanism

`FEXIT` is a standalone 32-bit command. It does not open or commit a block and does not write `BARG`.

Execution follows a fixed order:

1. Check the endpoints and frame size.
2. Reconstruct the caller stack pointer as `caller_sp = sp + size` and record it with the instruction PC, range, and frame size.
3. Write `sp = caller_sp`.
4. Load the registers in range order from `caller_sp - 8`, `caller_sp - 16`, and so on, one load per step.
5. After the last load, decrement the frame depth if it is nonzero, record the last-frame tuple, and advance `TPC` by 4.

Design point: `sp` is restored before the first load, and the template records that it has done so. A retried `FEXIT` therefore does not add the frame size to `sp` a second time.

<!-- PTO-READER-BLOCK: block-fexit-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- `DstBegin`, bits `19:15`, is the first register of the range.
- `DstEnd`, bits `24:20`, is the last register of the range.
- `uimm` is a 12-bit field split across bits `31:25` (value bits `6:0`) and bits `11:7` (value bits `11:7`). The frame size in bytes is `uimm << 3`.

The range is inclusive over the ring `R2..R23` and wraps from R23 to R2 when `DstEnd` is below `DstBegin`. Slot `k` of the range is at `caller_sp - 8*(k+1)`, the same slot `FENTRY` used for the same range.

Design point: every field is always encoded; there is no default. Encoded zero in an endpoint names R0, which is outside the ring and reserved. Encoded zero in `uimm` is a real zero-byte frame and is illegal.

<!-- PTO-READER-BLOCK: block-fexit-effects role=effects -->
## State effects and ordering

Each load reads one aligned 8 bytes as a relaxed load event and writes the destination register. Restoring R10 also updates the return-address state `_ReturnAddress`.

Design point: each load, its register write, and its progress step commit together as one restart event. If a load faults, earlier restored registers and the `sp` update remain. Re-executing the same `FEXIT` at the same PC resumes with the first register not yet restored and does not repeat an earlier load.

Completion decrements `_FrameDepth` only when it is nonzero, and records `DstBegin`, `DstEnd`, and the frame size as the last frame.

<!-- PTO-READER-BLOCK: block-fexit-constraints role=constraints -->
## Legality, faults, and atomicity

- An endpoint outside `2..23` raises `Fault_IllegalInstruction` before any `sp`, register, or memory effect.
- A frame smaller than 8 bytes per register raises `Fault_IllegalInstruction` before any effect.
- A load follows the ordinary data-access fault rules and faults precisely at its step.
- While a frame template is in progress, a frame command of another kind, or one at another PC, raises `Fault_IllegalInstruction` instead of continuing it.

The generated legality and exception sections below are authoritative.

<!-- PTO-READER-BLOCK: block-fexit-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
FEXIT [RegDst0 ~ RegDstn], sp!, uimm
```

After `FENTRY` saved R8 to R11 in a 48-byte frame, `sp` is `0x7FD0`. `FEXIT` with `DstBegin = 8`, `DstEnd = 11`, and encoded `uimm` 6 computes `caller_sp = 0x7FD0 + 48 = 0x8000` and writes it to `sp`. It then loads R8 from `0x7FF8`, R9 from `0x7FF0`, R10 from `0x7FE8`, and R11 from `0x7FE0`. If the load of R10 faults, R8, R9, and `sp` are already restored; the retry loads R10 and R11 only.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
FEXIT [RegDst0 ~ RegDstn], sp!, uimm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fexit_32_37b663f2a34d | L32 | 32 | 0x00001041 / 0x0000707f | [{"field":"DstBegin","operator":"one-of","values":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"DstEnd","operator":"one-of","values":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fexit_32_37b663f2a34d | DstBegin | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fexit_32_37b663f2a34d | DstEnd | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fexit_32_37b663f2a34d | uimm | 12 | unsigned | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fexit_32_37b663f2a34d | DstBegin | 5 | 2–23 | none | 0–1, 24–31 | first register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fexit_32_37b663f2a34d | DstEnd | 5 | 2–23 | none | 0–1, 24–31 | last register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fexit_32_37b663f2a34d | uimm | 12 | 0–4095 | none | none | frame byte count, encoded in multiples of eight | Encoded zero is a real zero-byte frame size and is illegal for every nonempty range. |

- `fexit_32_37b663f2a34d.DstBegin` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `fexit_32_37b663f2a34d.DstEnd` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DstBegin | first register in the inclusive R2..R23 ring range |
| DstEnd | last register in the inclusive R2..R23 ring range |
| uimm | frame byte count, encoded in multiples of eight |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/FEXIT.asl -->
```asl
readonly func InstructionContractMatches_FEXIT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fexit_32_37b663f2a34d);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/FEXIT.asl -->
```asl
readonly func InstructionContractHandler_FEXIT() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameExit;
end;

func ExecuteFEXIT(begin_reg: Reg5Selector,
                  end_reg: Reg5Selector,
                  frame_size: Word)
begin
    ExitFrame(begin_reg, end_reg, frame_size);
end;

pure func InstructionContractUsesInclusiveRegisterRange_FEXIT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractRejectsInvalidFrameRange_FEXIT()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The inclusive register range is the ring R2..R23. Singleton, full-ring, and wraparound ranges are assigned.
- uimm is always present and encodes the frame byte count scaled by eight: the semantic byte count is the encoded value shifted left by three, so the encoding supplies only multiples of eight; encoded zero is real zero and is illegal because every assigned range contains at least one register.

## Legality

- DstBegin and DstEnd select the inclusive R2..R23 callee-save ring; every endpoint outside 2..23 is reserved before effects.
- If the range contains N registers, uimm must be at least 8*N bytes. The encoding supplies only multiples of eight.

## State effects

- The accepted start records instruction PC, endpoints, count, frame size, reconstructed caller sp, and zero progress.
- After the final load, decrement nonzero frame depth, publish the last-frame tuple, clear active progress, and retire once.

## Memory effects and ordering

### Memory effects

- Load one aligned eight-byte value per selected destination from caller_sp-8, caller_sp-16, and subsequent descending slots.

### Ordering

- Add uimm to sp first, then load descending caller-frame slots in inclusive register-ring order.
- Each load, destination write, and progress advance commit as one restart event; recovery does not add sp twice or repeat earlier loads.

## Exceptions

- Reserved endpoints or an insufficient frame size raise Fault_IllegalInstruction before sp, register, memory, target, progress, or TPC effects.
- Each eight-byte stack access is a restart boundary. A recoverable access fault preserves earlier committed events and retries exactly the first uncommitted event from trap-preserved template state.

## Examples

- FEXIT [RegDst0 ~ RegDstn], sp!, uimm
