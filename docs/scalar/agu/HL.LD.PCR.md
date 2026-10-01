<!-- GENERATED FROM: asl/scalar/agu/HL.LD.PCR.asl -->
# HL.LD.PCR

**Normative ASL source:** `asl/scalar/agu/HL.LD.PCR.asl`

HL.LD.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LD-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ld-pcr-purpose role=purpose -->
## What `HL.LD.PCR` does

`HL.LD.PCR` is a `48`-bit PC-relative load of one `8`-byte little-endian value. It derives its base from the current program counter, adds a scaled signed displacement, reads eight bytes, and publishes the complete `64`-bit pattern through `RegDst`.

The canonical assembly is `hl.ld.pcr [<symbol>], ->{t, u, Rd}`.

Design point: the recorded load is not a signed load, and for an `8`-byte transfer the distinction is empty anyway, because the normalization step returns an `8`-byte value unchanged on both the signed and the unsigned path. At this width a single extension behaviour covers every encoding.

<!-- PTO-READER-BLOCK: scalar-hl-ld-pcr-mechanism role=mechanism -->
## How the address and the transfer are formed

The base is the current `TPC` with bits `1`:`0` cleared. The offset is the sign-extended `29`-bit displacement shifted left by `2` bits, and the sum is taken modulo `2^PTO_XLEN`.

The general register file is read by nothing and written by nothing except through the published destination; there is no base register and no writeback.

Once the encoding checks and the address preflight pass, the handler performs one `8`-byte little-endian load and publishes the bytes unchanged to `RegDst`.

Design point: the base is only `4`-byte aligned while the access needs `8`-byte alignment, so the low `3` bits of the effective address matter. Whether a given displacement is legal depends on bit `2` of the aligned `TPC` as well as on the low bit of the encoded displacement: an aligned base whose bit `2` is clear accepts only even word displacements. Roughly half of the encodable window is refused before translation.

<!-- PTO-READER-BLOCK: scalar-hl-ld-pcr-inputs role=inputs-outputs -->
## Encoded fields and where the bytes go

- `RegDst` is a `5`-bit selector: codes `1`..`23` write absolute GPRs, code `30` pushes `U`, code `31` pushes `T`, and codes `0` and `24`..`29` discard the loaded value only.
- The signed `29`-bit displacement is scaled by `4`. Assembled byte values run from `-1073741824` to `1073741820` in steps of `4`.
- The base is implicit: the aligned `TPC`.

Design point: a discard encoding still performs the full load and records its event, so `->Rd` with `RegDst` equal to `0` is a checked memory reference and not a no-op. The only way to suppress the access is to not execute the instruction.

<!-- PTO-READER-BLOCK: scalar-hl-ld-pcr-effects role=effects -->
## Effects, ordering, and completion

Successful execution records one relaxed `8`-byte load event. Memory bytes and any reservation state are unchanged, because a load neither writes memory nor disturbs a reservation.

The destination is published only after the load reported no fault. After publication, `TPC` advances by `6` bytes from the address the base was derived from.

Design point: the eight bytes are read as one access at one address, not as two `4`-byte halves, so a window that crosses a `4`-byte boundary is still a single event with a single alignment requirement based on the first byte's address.

<!-- PTO-READER-BLOCK: scalar-hl-ld-pcr-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch in the `48`-bit encoding raises `Fault_IllegalInstruction` before any effect. No source selector is encoded, so no unavailable `T` or `U` slot can reject this form.

The preflight tests the low `3` bits of the effective address and raises `Fault_DataAlignment` before translation and before the permission check, which is what a `4`-byte-aligned but not `8`-byte-aligned address produces. An `8`-byte-aligned address that fails a permission or bounded-memory test raises `Fault_DataPage` at the original address.

A fault records no load event, publishes no destination value, and leaves `TPC` on the faulting instruction. Recovery re-derives the base and displacement and repeats the preflight and the load.

<!-- PTO-READER-BLOCK: scalar-hl-ld-pcr-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.ld.pcr [<symbol>], ->6` executing at `TPC` = `0x2004`. Clearing the low `2` bits gives the base `0x2004`, which is `4`-byte aligned but not `8`-byte aligned, so bit `2` is set and only odd word displacements keep the address aligned.
- With an encoded displacement of `5`, the assembled displacement is `20` and the effective address is `0x2004` plus `20`, which is `0x2018`.
- The instruction reads the `8` bytes at `0x2018` through `0x201F` and publishes the whole `64`-bit pattern to GPR6.
- With an encoded displacement of `6` instead, the address would be `0x201C`, which is not `8`-byte aligned, and the instruction would raise `Fault_DataAlignment` before translation.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ld.pcr [<symbol>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ld_pcr_48_703673c266da | HL48 | 48 | 0x00003039000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ld_pcr_48_703673c266da | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ld_pcr_48_703673c266da | simm | 29 | signed | [{"instruction_lsb":31,"value_lsb":0,"width":17},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ld_pcr_48_703673c266da | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ld_pcr_48_703673c266da | simm | 29 | 0–536870911 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LD.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_LD_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_LD_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LD.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_LD_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LD_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LD_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_HL_LD_PCR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LD_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_LD_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LD_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LD_PCR()
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
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- After a successful 8-byte load, preserve the complete 64-bit loaded bit pattern and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 8-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.ld.pcr [<symbol>], ->{t, u, Rd}
