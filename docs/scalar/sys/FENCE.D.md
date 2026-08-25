<!-- GENERATED FROM: asl/scalar/sys/FENCE.D.asl -->
# FENCE.D

**Normative ASL source:** `asl/scalar/sys/FENCE.D.asl`

FENCE.D records predecessor/successor ordering masks and invalidates the local reservation.

## Normative identity {#PTO-INST-SCALAR-FENCE-D}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fence-d-purpose role=purpose -->
## What FENCE.D does

`FENCE.D` records predecessor and successor access-class masks as one data-fence event, invalidates the local reservation, and retires as a scalar operation inside an active SYS block.

<!-- PTO-READER-BLOCK: scalar-fence-d-mechanism role=mechanism -->
## Fence mechanism

`PRED_IMM` and `SUCC_IMM` are independent 4-bit masks. The instruction records both exact values in architectural fence state and in the emitted fence event.

If either mask contains the instruction-visibility bit, `FENCE.D` also advances the instruction-cache epoch.

<!-- PTO-READER-BLOCK: scalar-fence-d-inputs role=inputs-outputs -->
## Inputs and result shape

Both masks accept all `16` encoded values from `0` through `15`. Encoded zero is an assigned all-zero mask, not an omitted operand.

`FENCE.D` has no Reg5 source and no scalar destination; its visible result is the ordering event and system-state updates.

<!-- PTO-READER-BLOCK: scalar-fence-d-effects role=effects -->
## Effects and ordering

A successful execution invalidates the local reservation, records both masks, emits one acquire-release fence event for the current memory agent, and advances `TPC`.

The instruction does not itself load or store data memory; its ordering effect is represented by the exact masks in the emitted fence event.

<!-- PTO-READER-BLOCK: scalar-fence-d-constraints role=constraints -->
## Placement and fault boundary

`FENCE.D` is legal only in the body of an active SYS block. Invalid placement raises an Illegal Block Exception before encoded-field checks or effects.

A fixed-bit mismatch raises `Fault_IllegalInstruction` before reservation, fence-state, event, cache-epoch, or `TPC` effects.

<!-- PTO-READER-BLOCK: scalar-fence-d-example role=example -->
## Non-normative mask examples

These examples illustrate assigned mask values; they do not replace the normative fence relation.

With both masks equal to `0`, `FENCE.D` still invalidates the reservation and emits one fence event, but it does not advance the instruction-cache epoch. With both masks equal to `15`, it records all-one masks and advances that epoch because the instruction-visibility bit is present.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fence.d pred_imm, succ_imm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fence_d_32_f4783f17d84d | L32 | 32 | 0x0000202b / 0xf00fffff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fence_d_32_f4783f17d84d | PRED_IMM | 4 | encoding-defined | [{"instruction_lsb":24,"value_lsb":0,"width":4}] |
| fence_d_32_f4783f17d84d | SUCC_IMM | 4 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":4}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fence_d_32_f4783f17d84d | PRED_IMM | 4 | 0–15 | none | none | fence predecessor access-class mask | Encoded zero selects value zero of the fence predecessor access-class mask. |
| fence_d_32_f4783f17d84d | SUCC_IMM | 4 | 0–15 | none | none | fence successor access-class mask | Encoded zero selects value zero of the fence successor access-class mask. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| PRED_IMM | fence predecessor access-class mask |
| SUCC_IMM | fence successor access-class mask |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/FENCE.D.asl -->
```asl
readonly func InstructionContractOperation_FENCE_D()
    => ScalarOperation
begin
    return ScalarOperation_FENCE_D;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
FENCE.D executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/FENCE.D.asl -->
```asl
readonly func InstructionContractHandler_FENCE_D()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FenceData;
end;

pure func InstructionContractRequiresSystemBlock_FENCE_D()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractFenceMaskWidth_FENCE_D()
    => integer {4}
begin
    return 4;
end;

pure func InstructionContractFenceInvalidatesReservation_FENCE_D()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- All sixteen values of each four-bit predecessor and successor mask are assigned.

## State effects

- Invalidate the local reservation, record both masks, emit the fence event, and advance TPC.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Record the exact predecessor and successor masks as one data-fence event.
- If either mask carries the instruction-visibility bit, advance the instruction-cache epoch.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- fence.d pred_imm, succ_imm
