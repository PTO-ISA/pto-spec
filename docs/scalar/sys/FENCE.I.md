<!-- GENERATED FROM: asl/scalar/sys/FENCE.I.asl -->
# FENCE.I

**Normative ASL source:** `asl/scalar/sys/FENCE.I.asl`

FENCE.I establishes instruction visibility, invalidates the reservation, and advances the instruction-cache epoch.

## Normative identity {#PTO-INST-SCALAR-FENCE-I}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fence-i-purpose role=purpose -->
## What FENCE.I does

`FENCE.I` is the instruction-visibility fence. It has no operand, no mask, and no destination: the entire 32-bit form is fixed, and the instruction's whole job is to make the instruction-cache epoch move and to clear the local reservation.

<!-- PTO-READER-BLOCK: scalar-fence-i-mechanism role=mechanism -->
## System mechanism

`InstructionContractHandler_FENCE_I` selects `ScalarHandler_FenceInstruction` (`asl/scalar/sys/FENCE.I.asl:18`), and both `InstructionContractFenceInvalidatesReservation_FENCE_I` and `InstructionContractAdvancesInstructionEpoch_FENCE_I` return `TRUE` (`asl/scalar/sys/FENCE.I.asl:30`). `FenceInstruction` implements exactly those two steps, and its ASL comment states that the executable byte-array model already has coherent instruction and data storage, so the epoch is what makes the architectural visibility point explicit (`asl/scalar/model/sys/semantics.asl:83`).

The instruction requires the body of an active SYS block, like the other SYS-block instructions.

<!-- PTO-READER-BLOCK: scalar-fence-i-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

There is no encoded operand at all. Every bit of the form is fixed, so no selector, mask, or immediate can be varied, and the instruction cannot be used to name a narrower scope than the whole instruction stream.

`FENCE.I` writes no destination register, no temporary queue entry, and no system register. Its only outputs are the reservation state and the instruction-cache epoch.

<!-- PTO-READER-BLOCK: scalar-fence-i-effects role=effects -->
## Architectural effects

The instruction clears the local reservation, which is the `_ReservationValid` state that a later `StoreConditional` needs in order to succeed (`asl/scalar/model/amo/semantics.asl:93`), and advances the instruction-cache epoch by exactly one. It then advances `TPC` by 4 bytes for this 32-bit form.

Design point: `FENCE.I` takes no mask, so its effect is unconditional where `fence.d` is conditional. There is no encoding of `fence.i` that leaves the instruction-cache epoch unchanged, and no encoding of `fence.d` that always advances it.

The instruction emits no data-memory event and performs no ordinary scalar memory access, so it does not change any memory location. Ordering against data accesses is the job of `FENCE.D`.

<!-- PTO-READER-BLOCK: scalar-fence-i-constraints role=constraints -->
## Placement and rejection

The only rejection available is placement. An attempt outside an active SYS block body raises `Fault_BundleControl` and returns before the handler, so the reservation stays valid and the epoch keeps its value. There is no reserved encoding to reject, since all bits are fixed, and no operand to validate.

No access ring is required. The ring restriction in the maintenance path belongs to the four TLB operations, and `FENCE.I` does not use that path at all.

<!-- PTO-READER-BLOCK: scalar-fence-i-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

Execute `fence.i` inside a SYS block body. The reservation is cleared, the instruction-cache epoch advances by one, and `TPC` moves on by 4 bytes. An attempt in a Standard block body raises `Fault_BundleControl` instead.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fence.i
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fence_i_32_a321a2a186b1 | L32 | 32 | 0x1000202b / 0xffffffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/FENCE.I.asl -->
```asl
readonly func InstructionContractOperation_FENCE_I()
    => ScalarOperation
begin
    return ScalarOperation_FENCE_I;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
FENCE.I executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/FENCE.I.asl -->
```asl
readonly func InstructionContractHandler_FENCE_I()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FenceInstruction;
end;

pure func InstructionContractRequiresSystemBlock_FENCE_I()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractFenceInvalidatesReservation_FENCE_I()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAdvancesInstructionEpoch_FENCE_I()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The instruction has no operand or mask field.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.

## State effects

- Invalidate the local reservation, advance the instruction-cache epoch exactly once, and advance TPC.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Check block placement and encoded legality before architectural effects.
- Invalidate the local reservation and advance the instruction-cache epoch exactly once; FENCE.I emits no data-memory event.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- fence.i
