<!-- GENERATED FROM: asl/scalar/agu/HL.LHUI.asl -->
# HL.LHUI

**Normative ASL source:** `asl/scalar/agu/HL.LHUI.asl`

HL.LHUI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LHUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lhui-purpose role=purpose -->
## What HL.LHUI does

`HL.LHUI` is a standalone `48`-bit scalar AGU load. It adds a scaled immediate displacement to the `SrcL` base, loads one aligned little-endian `2`-byte value, and zero-extends the transferred bits to `PTO_XLEN` when the result is narrower than that width.

It performs no address-base writeback, so beyond memory the only architectural state it changes is the destination selector below.

Design point: `SrcL` is an unconstrained `Reg5` value while the displacement is always a multiple of `2`, so the access is misaligned exactly when the accessed address is not a multiple of the `2`-byte transfer unit.

<!-- PTO-READER-BLOCK: scalar-hl-lhui-mechanism role=mechanism -->
## How HL.LHUI forms its address and completes the transfer

`simm22` supplies the displacement. It is sign-extended from its `22` bits to `PTO_XLEN`, then left-shifted by `1`, which multiplies it by `2`, and that value is added to `SrcL` modulo `2^PTO_XLEN`. That sum is the accessed address. `SrcL` is read once.

After preflight, the single aligned little-endian `2`-byte load is performed and recorded as one relaxed load event. The executable path normalizes the result with `NormalizeScalarLoadResult`, which zero-extends the `2`-byte result to `PTO_XLEN` because `ScalarAGUSignedLoadOfForm` reports `FALSE` here and leaves the bits above it `0`.

Design point: sign-extending the displacement lets one encoding reach both sides of the base, and the `1`-bit left shift makes every encoded step a `2`-byte step. The cost is an asymmetric range: `4194302` is the largest positive byte displacement and `-4194304` the most negative.

<!-- PTO-READER-BLOCK: scalar-hl-lhui-inputs role=inputs-outputs -->
## Encoded fields and what they select

- `RegDst` is a `5`-bit selector for the loaded value.

- `SrcL` is a `5`-bit selector for the address base.

- `simm22` is a `22`-bit signed immediate; its byte displacement is the value left-shifted by `1`, so a multiple of `2`.

Codes `1`..`23` write absolute GPRs, `30` pushes `U`, `31` pushes `T`, `0` discards only that result, and codes `24`..`29` write nothing.

`SrcL` uses the complete `Reg5` source domain: codes `0`..`23` select absolute GPRs, codes `24`..`27` select `T#1`..`T#4`, and codes `28`..`31` select `U#1`..`U#4` without consuming them. Selector `0` reads the architectural zero GPR.

Design point: a destination selector of `0` discards the result instead of suppressing the instruction, so the load, its memory event, and the `TPC` advance all still happen.

<!-- PTO-READER-BLOCK: scalar-hl-lhui-effects role=effects -->
## Effects, snapshots, and completion order

Sources are snapshotted before the memory operation, so a destination that names `SrcL` only receives its write after the load has completed.

- Successful execution records one relaxed load event, preserves memory contents and reservation state, and writes nothing back.

- After every result has been published, `HL.LHUI` advances `TPC` by `6` bytes; a rejected or faulting attempt does not retire.

<!-- PTO-READER-BLOCK: scalar-hl-lhui-constraints role=constraints -->
## Legality, faults, and restart

Faults are raised in this order: an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before any effect; a misaligned address raises `Fault_DataAlignment` before address translation; a permission or bounded-memory failure raises `Fault_DataPage` at the original address, after translation.

Every encoded field is assigned, so no reserved field value needs rejecting; a fixed-bit mismatch raises `Fault_IllegalInstruction`.

The accessed address is the unconstrained `Reg5` base displaced by a multiple of `2`, so alignment depends on that base and not on the instruction encoding.

Design point: alignment is checked before translation, so a misaligned access cannot change translation state and then fault; `Fault_DataPage` later reports the original address.

A fault emits no successful memory event and no partial memory or destination effect, and leaves `TPC` at the faulting instruction; a retry recomputes the address, the preflight, the transfer, and the publication.

<!-- PTO-READER-BLOCK: scalar-hl-lhui-example role=example -->
## Non-normative reading walkthrough

This walkthrough explains how to use the page and does not add instruction behavior.

- Start with the canonical assembly `hl.lhui [SrcL, simm], ->{t, u, Rd}` and identify the base selector, the immediate displacement, and the destination selector.

- Read the reachable byte displacement out of the `22` encoded bits and the `1`-bit left shift before relying on this form for a distant access.

- Then check the alignment rule, the effect list, and the ASL contract below against the intended access address.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lhui [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lhui_48_6450dca3aad9 | HL48 | 48 | 0x00005019000e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lhui_48_6450dca3aad9 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lhui_48_6450dca3aad9 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lhui_48_6450dca3aad9 | simm22 | 22 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":10}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lhui_48_6450dca3aad9 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lhui_48_6450dca3aad9 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lhui_48_6450dca3aad9 | simm22 | 22 | 0–4194303 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm22 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LHUI.asl -->
```asl
readonly func InstructionContractOperation_HL_LHUI() => ScalarOperation
begin
    return ScalarOperation_HL_LHUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LHUI.asl -->
```asl
readonly func InstructionContractHandler_HL_LHUI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LHUI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LHUI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LHUI()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_LHUI()
    => integer {0..3}
begin
    return 1;
end;

pure func InstructionContractAGUUpdateMode_HL_LHUI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LHUI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LHUI()
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
- simm22 assigns every signed 22-bit value -2097152..2097151; the encoded byte displacement is that value multiplied by 2.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Sign-extend simm22, multiply it by 2, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 2-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 2-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.lhui [SrcL, simm], ->{t, u, Rd}
