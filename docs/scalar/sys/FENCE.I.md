<!-- GENERATED FROM: asl/scalar/sys/FENCE.I.asl -->
# FENCE.I

**Normative ASL source:** `asl/scalar/sys/FENCE.I.asl`

FENCE.I establishes instruction visibility, invalidates the reservation, and advances the instruction-cache epoch.

## Normative identity {#PTO-INST-SCALAR-FENCE-I}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

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

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.
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

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
