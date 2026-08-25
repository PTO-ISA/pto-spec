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

`FEXIT` is a standalone frame-lifecycle command that validates its register range and stack state before publishing frame or control-flow effects.

<!-- PTO-READER-BLOCK: block-fexit-mechanism role=mechanism -->
## Placement and execution mechanism

`FEXIT` executes as a standalone `32`-bit command and does not require placement inside a `BSTART`/`BSTOP` body.

The accepted carrier uses the `L32` encoding class and resolves every displayed field before the command reads bindings or changes state.

The command snapshots every required source before its first visible effect, then follows the owner-defined commit or restart boundary.

<!-- PTO-READER-BLOCK: block-fexit-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- Encoded operands: `DstBegin` — first register in the inclusive R2..R23 ring range; `DstEnd` — last register in the inclusive R2..R23 ring range; `uimm` — frame byte count, encoded in multiples of eight.
- All operands are resolved from the accepted carrier or named architectural state; no body-local hidden operand stream is created.
- Encoded zero remains an assigned value or a specifically documented rejection; it never silently means an omitted operand.

<!-- PTO-READER-BLOCK: block-fexit-effects role=effects -->
## State effects and ordering

Source validation and snapshot precede every register, queue, frame, memory, event, or control-flow effect.

The command commits at the restart boundaries named by its memory contract; earlier committed steps remain visible only where the owner explicitly permits restart progress.

<!-- PTO-READER-BLOCK: block-fexit-constraints role=constraints -->
## Legality, faults, and atomicity

Fixed bits, reserved values, selector domains, and required Block placement are checked before architectural effects.

The current owner reports invalid schema, state, address, or continuation conditions through `Fault_IllegalInstruction`; no prose on this page creates an additional fault rule.

Rejection occurs before effects unless the current owner explicitly defines a restart boundary with retained progress; completion order remains the ASL order.

<!-- PTO-READER-BLOCK: block-fexit-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
FEXIT [RegDst0 ~ RegDstn], sp!, uimm
```

The shown accepted spelling resolves its fields from the current carrier, snapshots required sources, and then follows the owner-defined state and ordering transition.
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
| fexit_32_37b663f2a34d | uimm | 15 | unsigned | [{"instruction_lsb":25,"value_lsb":3,"width":7},{"instruction_lsb":7,"value_lsb":10,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fexit_32_37b663f2a34d | DstBegin | 5 | 2–23 | none | 0–1, 24–31 | first register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fexit_32_37b663f2a34d | DstEnd | 5 | 2–23 | none | 0–1, 24–31 | last register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fexit_32_37b663f2a34d | uimm | 15 | 0–32767 | none | none | frame byte count, encoded in multiples of eight | Encoded zero is a real zero-byte frame size and is illegal for every nonempty range. |

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
- uimm is always present and represents a byte count in multiples of eight; encoded zero is real zero and is illegal because every assigned range contains at least one register.

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
