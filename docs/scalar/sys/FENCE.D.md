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

`FENCE.D` is the data-ordering fence with explicit predecessor and successor access-class masks. Both masks are 4-bit immediates in the encoding, not registers, so the fence describes which kinds of access must be ordered without reading any operand from the scalar register file.

<!-- PTO-READER-BLOCK: scalar-fence-d-mechanism role=mechanism -->
## System mechanism

`InstructionContractHandler_FENCE_D` selects `ScalarHandler_FenceData` (`asl/scalar/sys/FENCE.D.asl:18`), and `InstructionContractFenceInvalidatesReservation_FENCE_D` returns `TRUE` (`asl/scalar/sys/FENCE.D.asl:36`). The dispatcher decodes `PRED_IMM` and `SUCC_IMM` as two 4-bit fields and passes them to `FenceData` in that order (`asl/scalar/model/dispatch/sys.asl:81`).

`FenceData` performs four steps in sequence: clear the local reservation, store the predecessor mask, store the successor mask, then test bit 3 of both masks (`asl/scalar/model/sys/semantics.asl:72`).

<!-- PTO-READER-BLOCK: scalar-fence-d-inputs role=inputs-outputs -->
## Inputs and outputs

`PRED_IMM` is the 4-bit predecessor access-class mask and `SUCC_IMM` is the 4-bit successor mask (`asl/scalar/sys/FENCE.D.asl:1`). All sixteen values of each field are assigned, so no mask value is reserved and no field is optional.

`FENCE.D` has no destination operand. It reads no register, so nothing is snapshotted from the register file, and encoded zero is an assigned mask value rather than an omitted operand.

<!-- PTO-READER-BLOCK: scalar-fence-d-effects role=effects -->
## Architectural effects

The fence clears the local reservation and records both masks as one data-fence event. If bit 3 of either mask is set, the instruction-cache epoch also advances by one (`asl/scalar/model/sys/semantics.asl:77`). `TPC` then advances by the instruction length, since the handler writes no `TPC` of its own.

Design point: the epoch step is conditional on a bit that is visible in the encoding. A fence with mask 8 in either position therefore has an instruction-visibility side effect, while a fence with masks 1 and 1 does not, and the same encoded instruction always behaves the same way.

The instruction has no memory effect: `memory_effects` is `none`, and `FenceData` touches no memory. It also writes no register or temporary queue.

<!-- PTO-READER-BLOCK: scalar-fence-d-constraints role=constraints -->
## Placement and rejection

`FENCE.D` executes in the body of an active SYS block. An attempt outside one raises `Fault_BundleControl` before the masks are read, so the reservation, the recorded masks, and the instruction-cache epoch all keep their previous values.

Because every 4-bit mask value is assigned, there is no reserved-encoding rejection for these fields. The fixed bits of the 32-bit form are still checked before the handler runs, and no access-ring restriction applies to the operation.

<!-- PTO-READER-BLOCK: scalar-fence-d-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

Run `fence.d 8, 1` in a SYS block body. The reservation is cleared, the predecessor mask 8 and successor mask 1 are recorded as one fence event, and because bit 3 of the predecessor mask is set the instruction-cache epoch advances by one. Running `fence.d 1, 1` clears the reservation and records the masks with no epoch change.
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
