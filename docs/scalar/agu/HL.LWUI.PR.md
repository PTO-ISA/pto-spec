<!-- GENERATED FROM: asl/scalar/agu/HL.LWUI.PR.asl -->
# HL.LWUI.PR

**Normative ASL source:** `asl/scalar/agu/HL.LWUI.PR.asl`

HL.LWUI.PR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LWUI-PR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lwui-pr-purpose role=purpose -->
## What HL.LWUI.PR does

`HL.LWUI.PR` is a standalone `48`-bit scalar AGU load. It adds a scaled immediate displacement to the `SrcL` base, loads one aligned little-endian `4`-byte value, and zero-extends the transferred bits to `PTO_XLEN` when the result is narrower than that width.

It is a pre-index updating load: the access uses the updated address, and the second destination selector below publishes that same updated base.

Design point: `SrcL` is an unconstrained `Reg5` value while the displacement is always a multiple of `4`, so the access is misaligned exactly when the accessed address is not a multiple of the `4`-byte transfer unit.

<!-- PTO-READER-BLOCK: scalar-hl-lwui-pr-mechanism role=mechanism -->
## How HL.LWUI.PR forms its address and completes the transfer

`simm17` supplies the displacement. It is sign-extended from its `17` bits to `PTO_XLEN`, then left-shifted by `2`, which multiplies it by `4`, and that value is added to `SrcL` modulo `2^PTO_XLEN`. The sum is the accessed address. `SrcL` is read once.

After preflight, the single aligned little-endian `4`-byte load is performed and recorded as one relaxed load event. The executable path normalizes the result with `NormalizeScalarLoadResult`, which zero-extends the `4`-byte result to `PTO_XLEN` because `ScalarAGUSignedLoadOfForm` reports `FALSE` here and leaves the bits above it `0`.

Design point: sign-extending the displacement lets one encoding reach both sides of the base, and the `2`-bit left shift makes every encoded step a `4`-byte step. The cost is an asymmetric range: `262140` is the largest positive byte displacement and `-262144` the most negative.

<!-- PTO-READER-BLOCK: scalar-hl-lwui-pr-inputs role=inputs-outputs -->
## Encoded fields and what they select

- `RegDst0` is a `5`-bit selector for the loaded value.

- `RegDst1` is a `5`-bit selector for the updated base.

- `SrcL` is a `5`-bit selector for the address base.

- `simm17` is a `17`-bit signed immediate; its byte displacement is the value left-shifted by `2`, so a multiple of `4`.

Codes `1`..`23` write absolute GPRs, `30` pushes `U`, `31` pushes `T`, `0` discards only that result, and codes `24`..`29` write nothing.

`SrcL` uses the complete `Reg5` source domain: codes `0`..`23` select absolute GPRs, codes `24`..`27` select `T#1`..`T#4`, and codes `28`..`31` select `U#1`..`U#4` without consuming them. Selector `0` reads the architectural zero GPR.

Design point: a destination selector of `0` discards the result instead of suppressing the instruction, so the load, its memory event, and the `TPC` advance all still happen.

<!-- PTO-READER-BLOCK: scalar-hl-lwui-pr-effects role=effects -->
## Effects, snapshots, and completion order

Sources are snapshotted before the memory operation, so a destination that names `SrcL` only receives its write after the load has completed.

- Successful execution records one relaxed load event, preserves memory contents and reservation state, and publishes the updated base to `RegDst1` only after the memory operation completed.

- After every result has been published, `HL.LWUI.PR` advances `TPC` by `6` bytes; a rejected or faulting attempt does not retire.

<!-- PTO-READER-BLOCK: scalar-hl-lwui-pr-constraints role=constraints -->
## Legality, faults, and restart

Faults are raised in this order: an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before any effect; a misaligned address raises `Fault_DataAlignment` before address translation; a permission or bounded-memory failure raises `Fault_DataPage` at the original address, after translation.

Every encoded field is assigned, so no reserved field value needs rejecting; a fixed-bit mismatch raises `Fault_IllegalInstruction`.

The accessed address is the unconstrained `Reg5` base displaced by a multiple of `4`, so alignment depends on that base and not on the instruction encoding.

Design point: alignment is checked before translation, so a misaligned access cannot change translation state and then fault; `Fault_DataPage` later reports the original address.

A fault emits no successful memory event and no partial memory or destination effect, and leaves `TPC` at the faulting instruction; a retry recomputes the address, the preflight, the transfer, and the publication.

<!-- PTO-READER-BLOCK: scalar-hl-lwui-pr-example role=example -->
## Non-normative reading walkthrough

This walkthrough explains how to use the page and does not add instruction behavior.

- Start with the canonical assembly `hl.lwui.pr [SrcL, simm], ->Dst0, Dst1` and identify the base selector, the immediate displacement, and the destination selectors.

- Read the reachable byte displacement out of the `17` encoded bits and the `2`-bit left shift before relying on this form for a distant access.

- Then check the alignment rule, the effect list, and the ASL contract below against the intended access address.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lwui.pr [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lwui_pr_48_32de19a508f0 | HL48 | 48 | 0x00006019002e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lwui_pr_48_32de19a508f0 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lwui_pr_48_32de19a508f0 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lwui_pr_48_32de19a508f0 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lwui_pr_48_32de19a508f0 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lwui_pr_48_32de19a508f0 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lwui_pr_48_32de19a508f0 | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lwui_pr_48_32de19a508f0 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lwui_pr_48_32de19a508f0 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 updated-base destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LWUI.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LWUI_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LWUI_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LWUI.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LWUI_PR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LWUI_PR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LWUI_PR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LWUI_PR()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_LWUI_PR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_LWUI_PR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LWUI_PR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LWUI_PR()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 4, and add it modulo 2^PTO_XLEN to the SrcL base.
- Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.
- After a successful 4-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 4-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.lwui.pr [SrcL, simm], ->Dst0, Dst1
