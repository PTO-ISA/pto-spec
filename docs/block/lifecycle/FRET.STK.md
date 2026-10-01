<!-- GENERATED FROM: asl/block/lifecycle/FRET.STK.asl -->
# FRET.STK

**Normative ASL source:** `asl/block/lifecycle/FRET.STK.asl`

Restores a restartable stack frame whose first stack slot supplies the validated return target.

## Normative identity {#PTO-INST-BLOCK-FRET-STK}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-fret-stk-purpose role=purpose -->
## What FRET.STK does

`FRET.STK` removes a stack frame and returns, in one command, using a return address saved in the frame itself. The range must begin at R10 (`ra`). The value in the first frame slot is both the restored `ra` and the return target.

It pairs with an [FENTRY](FENTRY.md) whose range also began at R10. The stack pointer is GPR 1 (`sp`). The shared frame template is described in [frame lifetime](../model/lifecycle/lifetime.md).

<!-- PTO-READER-BLOCK: block-fret-stk-mechanism role=mechanism -->
## Placement and execution mechanism

`FRET.STK` is a standalone 32-bit command. It does not open or commit a block and does not write `BARG`.

Execution follows a fixed order:

1. Check the endpoints and frame size, including `DstBegin = 10`.
2. Compute `caller_sp = sp + size` and write it to `sp`.
3. Load slot zero from `caller_sp - 8`. An odd value raises `Fault_InstructionPC`. Otherwise the value becomes the return target and is written to R10 and `_ReturnAddress`.
4. Load the remaining registers in range order from `caller_sp - 16` onward.
5. After the last load, decrement the frame depth if it is nonzero, record the last-frame tuple, and write the target to `TPC`.

Design point: slot zero is validated before it is written to `ra`. A bad saved address therefore never reaches `ra`, `_ReturnAddress`, or `TPC`.

<!-- PTO-READER-BLOCK: block-fret-stk-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- `DstBegin`, bits `19:15`, must encode 10. Other ring endpoints are reserved for this command.
- `DstEnd`, bits `24:20`, is the last register of the range, in `2..23`.
- `uimm` is a 12-bit field split across bits `31:25` (value bits `6:0`) and bits `11:7` (value bits `11:7`). The frame size in bytes is `uimm << 3`.

Every field is always encoded; there is no default. Encoded zero in an endpoint names R0 and is reserved. Encoded zero in `uimm` is a real zero-byte frame and is illegal.

<!-- PTO-READER-BLOCK: block-fret-stk-effects role=effects -->
## State effects and ordering

Each load reads one aligned 8 bytes as a relaxed load event and writes its register. Each load and its progress step form one restart event.

Completion decrements `_FrameDepth` when it is nonzero, records the last frame, and writes `TPC` with the slot-zero target. There is no sequential `TPC` increment.

Design point: `sp` is restored before slot zero is read. If slot zero faults, the `sp` update stays committed and is visible to the trap handler. The template records that `sp` was adjusted, so re-executing `FRET.STK` does not adjust it again.

<!-- PTO-READER-BLOCK: block-fret-stk-constraints role=constraints -->
## Legality, faults, and atomicity

- `DstBegin` other than 10, an endpoint outside `2..23`, or a frame smaller than 8 bytes per register raises `Fault_IllegalInstruction` before any effect.
- An odd slot-zero value raises `Fault_InstructionPC` before `ra`, target, slot-zero progress, or later-register effects.
- A load follows the ordinary data-access fault rules and faults precisely at its step.
- While a frame template is in progress, a frame command of another kind, or one at another PC, raises `Fault_IllegalInstruction` instead of continuing it.

The generated legality and exception sections below are authoritative.

<!-- PTO-READER-BLOCK: block-fret-stk-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
FRET.STK [ra ~ RegDstn], sp!, uimm
```

An `FENTRY` saved R10 to R12 in a 24-byte frame from `sp = 0x8000`, so `sp` is now `0x7FE8` and slot zero at `0x7FF8` holds `0x3000`. `FRET.STK` with `DstEnd = 12` and encoded `uimm` 3 sets `sp` to `0x8000`, loads `0x3000` into R10 as the target, then restores R11 from `0x7FF0` and R12 from `0x7FE8`. `TPC` becomes `0x3000`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
FRET.STK [ra ~ RegDstn], sp!, uimm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fret_stk_32_4fe246bd8241 | L32 | 32 | 0x00003041 / 0x0000707f | [{"field":"DstBegin","operator":"one-of","values":[10]},{"field":"DstEnd","operator":"one-of","values":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fret_stk_32_4fe246bd8241 | DstBegin | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fret_stk_32_4fe246bd8241 | DstEnd | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fret_stk_32_4fe246bd8241 | uimm | 12 | unsigned | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fret_stk_32_4fe246bd8241 | DstBegin | 5 | 10 | none | 0–9, 11–31 | first register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fret_stk_32_4fe246bd8241 | DstEnd | 5 | 2–23 | none | 0–1, 24–31 | last register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fret_stk_32_4fe246bd8241 | uimm | 12 | 0–4095 | none | none | frame byte count, encoded in multiples of eight | Encoded zero is a real zero-byte frame size and is illegal for every nonempty range. |

- `fret_stk_32_4fe246bd8241.DstBegin` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `fret_stk_32_4fe246bd8241.DstEnd` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DstBegin | first register in the inclusive R2..R23 ring range |
| DstEnd | last register in the inclusive R2..R23 ring range |
| uimm | frame byte count, encoded in multiples of eight |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/FRET.STK.asl -->
```asl
readonly func InstructionContractMatches_FRET_STK(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fret_stk_32_4fe246bd8241);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/FRET.STK.asl -->
```asl
readonly func InstructionContractHandler_FRET_STK() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameReturnStack;
end;

func ExecuteFRETSTK(begin_reg: Reg5Selector,
                    end_reg: Reg5Selector,
                    frame_size: Word)
begin
    ReturnFromFrame(begin_reg, end_reg, frame_size, FALSE);
end;

pure func InstructionContractUsesInclusiveRegisterRange_FRET_STK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractRejectsInvalidFrameRange_FRET_STK()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The inclusive register range is the ring R2..R23. Singleton, full-ring, and wraparound ranges are assigned.
- uimm is always present and encodes the frame byte count scaled by eight: the semantic byte count is the encoded value shifted left by three, so the encoding supplies only multiples of eight; encoded zero is real zero and is illegal because every assigned range contains at least one register.
- The range must begin at architectural ra (R10); stack slot zero supplies both restored ra and the return target.

## Legality

- DstBegin and DstEnd select the inclusive R2..R23 callee-save ring; every endpoint outside 2..23 is reserved before effects.
- If the range contains N registers, uimm must be at least 8*N bytes. The encoding supplies only multiples of eight.
- DstBegin must encode R10 exactly; other otherwise legal ring endpoints are reserved for FRET.STK.

## State effects

- Slot zero updates both architectural ra and the retained return-address state; subsequent slots restore the rest of the inclusive range.
- Completion decrements nonzero frame depth, publishes the last-frame tuple, clears progress, and transfers to the validated target.

## Memory effects and ordering

### Memory effects

- Load one aligned eight-byte value per selected destination; slot zero is the return-target load and remains an exact restart boundary.

### Ordering

- Add uimm to sp, load and validate slot zero before restoring ra, then restore the remaining selected registers in ring order.
- After the final restore, publish the validated slot-zero target to TPC; the command does not perform a sequential TPC increment.

## Exceptions

- Reserved endpoints or an insufficient frame size raise Fault_IllegalInstruction before sp, register, memory, target, progress, or TPC effects.
- Each eight-byte stack access is a restart boundary. A recoverable access fault preserves earlier committed events and retries exactly the first uncommitted event from trap-preserved template state.
- An odd slot-zero value raises Fault_InstructionPC before ra, target, slot-zero progress, or later-register effects; an earlier committed sp adjustment remains restart-visible.

## Examples

- FRET.STK [ra ~ RegDstn], sp!, uimm
