<!-- GENERATED FROM: asl/scalar/agu/HL.LWU.PCR.asl -->
# HL.LWU.PCR

**Normative ASL source:** `asl/scalar/agu/HL.LWU.PCR.asl`

HL.LWU.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LWU-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lwu-pcr-purpose role=purpose -->
## What HL.LWU.PCR does

`HL.LWU.PCR` is a standalone `48`-bit scalar AGU load whose address is relative to the instruction stream. It forms the address from the aligned current instruction pointer plus a scaled symbol displacement, loads one aligned little-endian `4`-byte value, and zero-extends the transferred bits to `PTO_XLEN` when the result is narrower than that width.

No register supplies the base. The same encoding therefore reaches different memory whenever the code runs from a different address, and no address-base writeback exists.

Design point: the instruction pointer is not an operand, so the form consumes no program-visible register and publishes only one result. The address still advances with the code, which is what makes the form usable from position-independent code without adding a base register to the encoding.

<!-- PTO-READER-BLOCK: scalar-hl-lwu-pcr-mechanism role=mechanism -->
## How HL.LWU.PCR forms its address and completes the transfer

The base is the current `TPC` with bits `[1:0]` cleared, so it is always a multiple of `4`. The encoded `simm` field is sign-extended to `PTO_XLEN` and left-shifted by 2, a factor of 4, and the product is added to that base modulo `2^PTO_XLEN`. The reachable byte displacement runs from `-1073741824` through `1073741820`.

After preflight, the single aligned little-endian `4`-byte load is performed and recorded as one relaxed load event. The executable path normalizes the result with `NormalizeScalarLoadResult`, which zero-extends the `4`-byte result to `PTO_XLEN` because `ScalarAGUSignedLoadOfForm` reports `FALSE` here and leaves the bits above it `0`.

Nothing is written back to an address base, because the form has no base operand.

Design point: sign-extending the displacement lets one encoding reach bytes before and after the instruction, while clearing the two pointer bits and shifting the displacement keeps the sum a multiple of `4`, which is the `4`-byte transfer unit.

<!-- PTO-READER-BLOCK: scalar-hl-lwu-pcr-inputs role=inputs-outputs -->
## Encoded fields and what they select

- `RegDst` is a `5`-bit selector for the loaded value.

- `simm` is a `29`-bit signed symbol displacement; the encoded byte displacement is that value multiplied by `4`.

Codes `1`..`23` write absolute GPRs, `30` pushes `U`, `31` pushes `T`, `0` discards only that result, and codes `24`..`29` write nothing.

There is no encoded base selector and no register offset, so this form reads no general-purpose register and no selected `T` or `U` source can be unavailable to it.

Design point: a destination selector of `0` discards the result instead of suppressing the instruction, so the load, its memory event, and the `TPC` advance all still happen.

<!-- PTO-READER-BLOCK: scalar-hl-lwu-pcr-effects role=effects -->
## Effects, snapshots, and completion order

The aligned base and the displacement are computed before the memory operation, so publishing into `RegDst` cannot change which bytes were read.

- Successful execution records one relaxed load event, preserves memory contents and reservation state, and writes nothing back.

- After the result has been published, `HL.LWU.PCR` advances `TPC` by `6` bytes; a rejected or faulting attempt does not retire.

<!-- PTO-READER-BLOCK: scalar-hl-lwu-pcr-constraints role=constraints -->
## Legality, faults, and restart

A permission or bounded-memory failure raises `Fault_DataPage` at the original address. `Fault_IllegalInstruction` is reserved here for a fixed-bit mismatch, and a reserved field value cannot occur because every encoded field of this form is assigned.

`Fault_DataAlignment` is unreachable for this form: the base has its low two bits cleared and the scaled displacement is a multiple of `4`, so the sum is always a multiple of `4`, which is the `4`-byte transfer unit.

Design point: clearing the pointer bits before the addition is what keeps the address aligned regardless of which halfword the instruction starts at. Without that step a code-relative load could fault on alignment instead of loading.

A fault emits no successful memory event and no partial memory or destination effect, and leaves `TPC` at the faulting instruction; a retry recomputes the aligned base, the displacement, the preflight, the transfer, and the publication.

<!-- PTO-READER-BLOCK: scalar-hl-lwu-pcr-example role=example -->
## Non-normative reading walkthrough

This walkthrough explains how to use the page and does not add instruction behavior.

- Start with the canonical assembly `hl.lwu.pcr [<symbol>], ->{t, u, Rd}` and identify the symbol displacement and the destination selector.

- Remember that the base is the aligned current `TPC` and not a register before reusing the same encoding at another code address.

- Then check the address, effect, and fault statements above against the ASL contract below, including that alignment is not among the raised faults.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lwu.pcr [<symbol>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lwu_pcr_48_95ba33b7b68c | HL48 | 48 | 0x00006039000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lwu_pcr_48_95ba33b7b68c | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lwu_pcr_48_95ba33b7b68c | simm | 29 | signed | [{"instruction_lsb":31,"value_lsb":0,"width":17},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lwu_pcr_48_95ba33b7b68c | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lwu_pcr_48_95ba33b7b68c | simm | 29 | 0–536870911 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LWU.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_LWU_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_LWU_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LWU.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_LWU_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LWU_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LWU_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_HL_LWU_PCR()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_LWU_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_LWU_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LWU_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LWU_PCR()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm assigns every signed 29-bit value -268435456..268435455; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
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

- hl.lwu.pcr [<symbol>], ->{t, u, Rd}
