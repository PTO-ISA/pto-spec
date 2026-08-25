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

`FRET.RA` is a standalone frame-lifecycle command that validates its register range and stack state before publishing frame or control-flow effects.

<!-- PTO-READER-BLOCK: block-fret-ra-mechanism role=mechanism -->
## Placement and execution mechanism

`FRET.RA` executes as a standalone `32`-bit command and does not require placement inside a `BSTART`/`BSTOP` body.

The accepted carrier uses the `L32` encoding class and resolves every displayed field before the command reads bindings or changes state.

The command snapshots every required source before its first visible effect, then follows the owner-defined commit or restart boundary.

<!-- PTO-READER-BLOCK: block-fret-ra-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- Encoded operands: `DstBegin` — first register in the inclusive R2..R23 ring range; `DstEnd` — last register in the inclusive R2..R23 ring range; `uimm` — frame byte count, encoded in multiples of eight.
- All operands are resolved from the accepted carrier or named architectural state; no body-local hidden operand stream is created.
- Encoded zero remains an assigned value or a specifically documented rejection; it never silently means an omitted operand.

<!-- PTO-READER-BLOCK: block-fret-ra-effects role=effects -->
## State effects and ordering

Source validation and snapshot precede every register, queue, frame, memory, event, or control-flow effect.

The command commits at the restart boundaries named by its memory contract; earlier committed steps remain visible only where the owner explicitly permits restart progress.

<!-- PTO-READER-BLOCK: block-fret-ra-constraints role=constraints -->
## Legality, faults, and atomicity

Fixed bits, reserved values, selector domains, and required Block placement are checked before architectural effects.

The current owner reports invalid schema, state, address, or continuation conditions through `Fault_IllegalInstruction`, `Fault_InstructionPC`; no prose on this page creates an additional fault rule.

Rejection occurs before effects unless the current owner explicitly defines a restart boundary with retained progress; completion order remains the ASL order.

<!-- PTO-READER-BLOCK: block-fret-ra-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
FRET.RA [RegDst0 ~ RegDstn], sp!, uimm
```

The shown accepted spelling resolves its fields from the current carrier, snapshots required sources, and then follows the owner-defined state and ordering transition.
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
| fret_ra_32_659c886221c1 | uimm | 15 | unsigned | [{"instruction_lsb":25,"value_lsb":3,"width":7},{"instruction_lsb":7,"value_lsb":10,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fret_ra_32_659c886221c1 | DstBegin | 5 | 2–23 | none | 0–1, 24–31 | first register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fret_ra_32_659c886221c1 | DstEnd | 5 | 2–23 | none | 0–1, 24–31 | last register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fret_ra_32_659c886221c1 | uimm | 15 | 0–32767 | none | none | frame byte count, encoded in multiples of eight | Encoded zero is a real zero-byte frame size and is illegal for every nonempty range. |

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
- uimm is always present and represents a byte count in multiples of eight; encoded zero is real zero and is illegal because every assigned range contains at least one register.
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
