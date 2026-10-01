<!-- GENERATED FROM: asl/scalar/agu/HL.LH.PCR.asl -->
# HL.LH.PCR

**Normative ASL source:** `asl/scalar/agu/HL.LH.PCR.asl`

HL.LH.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LH-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lh-pcr-purpose role=purpose -->
## What `HL.LH.PCR` does

`HL.LH.PCR` is a standalone 48-bit load whose address is relative to the current instruction position instead of a register. It loads one 2-byte value into one destination.

<!-- PTO-READER-BLOCK: scalar-hl-lh-pcr-mechanism role=mechanism -->
## Address and load mechanism

The base is the current instruction position with bits `1:0` cleared, so it is aligned to `4` bytes even when the instruction starts on the second halfword of a word.

The decoded `simm` is sign-extended and multiplied by `4`, then added to that base modulo `2^PTO_XLEN`.

Once the `2`-byte address passes the alignment check and then the translation and permission check, the instruction performs one little-endian `2`-byte load and records one relaxed load event.

No index update happens: the form writes no base register and reads no register for its address.

The byte at the accessed address becomes bits `7:0` of the result and later bytes fill higher bits, so the value is little-endian, and the instruction will sign-extend the loaded value to `PTO_XLEN`, keeping the low `16` bits and copying bit `15` into every higher bit.

**Design point:** clearing bits `1:0` of the instruction position before adding the displacement makes the base independent of which halfword the instruction starts at, so moving the instruction between halfword offsets still reaches the same target.

<!-- PTO-READER-BLOCK: scalar-hl-lh-pcr-inputs role=inputs-outputs -->
## Inputs and destinations

- The address base is implicit: the current instruction position with bits `1:0` cleared. No base register is encoded, so this form reads no scalar register for its address.
- `simm` covers every signed 29-bit value from `-268435456` through `268435455`, and each unit of it moves the address by `4` bytes.
- `RegDst` is the only destination field: codes `1..23` write absolute GPRs, code `30` pushes U, code `31` pushes T, and codes `0` and `24..29` discard only the loaded value.
- Every displayed operand field is encoded explicitly, so encoded zero is a value and never denotes omission.

<!-- PTO-READER-BLOCK: scalar-hl-lh-pcr-effects role=effects -->
## Effects and ordering

The current instruction position is read once at the start of the attempt and the displacement is applied to that snapshot, so the address that faults and the address that is accessed are the same address even though the position later advances.

A successful attempt records one relaxed load event, leaves memory and reservation state unchanged, publishes the loaded value, and advances `TPC` by `6` bytes.

**Design point:** the position is snapshotted at the start of the attempt because the same attempt later advances `TPC` by `6` bytes. Forming the address after that advance would make a reissue compute a different target.

<!-- PTO-READER-BLOCK: scalar-hl-lh-pcr-constraints role=constraints -->
## Alignment, faults, and restart

The effective address must be aligned to the `2`-byte transfer size. Misalignment raises `Fault_DataAlignment` before translation; a translation or bounded-memory failure after that raises `Fault_DataPage` at the original address.

A fixed-bit mismatch, a reserved field value, or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before any instruction effect.

A fault emits no load event and writes no destination, and the address it records is the address that failed. Recovery reissues the whole instruction: the address, the source snapshot, every probe, the load, and every destination are recomputed with no retained progress.

**Design point:** the alignment check runs before translation, so an access that is both unaligned and outside the permitted region reports `Fault_DataAlignment`, not `Fault_DataPage`. The fault saves its address as the trap argument and redirects `TPC` to the trap entry, which is what lets a handler reissue the instruction with no retained progress.

<!-- PTO-READER-BLOCK: scalar-hl-lh-pcr-example role=example -->
## Non-normative address example

This example illustrates the current address and publication rule and does not replace the normative load contract.

If the instruction position is `0x1002`, bits `1:0` are cleared to give the base `0x1000`; with a decoded displacement of `3` the scaled value is `12`, so the accessed address is `0x100c`.

If that address is aligned and permitted, the result is published and `TPC` advances by `6` bytes, from `0x1002` to `0x1008`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lh.pcr [<symbol>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lh_pcr_48_37df3cfe0d6e | HL48 | 48 | 0x00001039000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lh_pcr_48_37df3cfe0d6e | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lh_pcr_48_37df3cfe0d6e | simm | 29 | signed | [{"instruction_lsb":31,"value_lsb":0,"width":17},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lh_pcr_48_37df3cfe0d6e | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lh_pcr_48_37df3cfe0d6e | simm | 29 | 0–536870911 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LH.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_LH_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_LH_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LH.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_LH_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LH_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LH_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_HL_LH_PCR()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_LH_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_LH_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LH_PCR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LH_PCR()
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
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- After a successful 2-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
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

- hl.lh.pcr [<symbol>], ->{t, u, Rd}
