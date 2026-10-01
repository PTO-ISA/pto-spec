<!-- GENERATED FROM: asl/scalar/agu/LD.asl -->
# LD

**Normative ASL source:** `asl/scalar/agu/LD.asl`

LD snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-LD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ld-purpose role=purpose -->
## What `LD` does

`LD` loads one full `8`-byte little-endian unit through an indexed address and publishes all `64` loaded bits. It is the widest member of the register-indexed load family.

The canonical assembly is `ld [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}`.

Design point: the transfer is `8` bytes but the shift is a programmed `5`-bit field, so one instruction serves both a byte-stride walk with `shamt` `0` and an `8`-byte-stride table walk with `shamt` `3`.

<!-- PTO-READER-BLOCK: scalar-ld-mechanism role=mechanism -->
## How the address and the transfer are formed

The index is `SrcR` after the `SrcRType` transformation, shifted left by `shamt`, then added to the `SrcL` snapshot modulo `2^PTO_XLEN`. The shift is applied to the transformed `64`-bit value, so `.sw` and `.uw` are decided before any shifting happens.

Preflight tests `8`-byte alignment first, then translation, then permission and bounded memory. On success `8` bytes are read little-endian and one relaxed load event is recorded.

The value needs no extension: every loaded bit becomes the destination word. No base write-back is performed.

Design point: `shamt` can move an otherwise aligned base off an `8`-byte boundary, because the alignment rule applies to the sum and not to the base. `shamt` `1` with an index of `3` produces an offset of `6`.

<!-- PTO-READER-BLOCK: scalar-ld-inputs role=inputs-outputs -->
## Encoded fields and roles

- `SrcL` is the base selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `SrcR` is the index selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `SrcRType` selects unchanged, `.sw`, or `.uw`; `3` is reserved. `shamt` covers `0`..`31`.
- `RegDst` is the destination selector. Codes `1`..`23` write GPRs, `30` pushes the `U` queue, `31` pushes the `T` queue, and `0` plus `24`..`29` publish nothing; code `0` is the architectural zero GPR, whose writes are discarded.
- Design point: a `.uw` index is a zero-extension of the low `32` bits of `SrcR`, so a `32`-bit negative index becomes a large positive offset that is then reduced only by the `64`-bit wrap of the addition.

<!-- PTO-READER-BLOCK: scalar-ld-effects role=effects -->
## Effects, ordering, and completion

Every source is snapshotted before the memory access and before the destination is written, so a destination that names the base or the index still receives the loaded value only after the address has been computed from the old contents.

Success records one relaxed load event, changes no byte of memory, preserves the reservation, publishes the full `64`-bit value, and advances `TPC` by `4` bytes.

Design point: the load leaves reservation state untouched, so reading a guarded word does not break a reservation taken on the same address.

<!-- PTO-READER-BLOCK: scalar-ld-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch, a reserved `SrcRType`, or an unavailable `T`/`U` source raises `Fault_IllegalInstruction` before any instruction effect.
- A sum that is not a multiple of `8` raises `Fault_DataAlignment` before translation; a later permission or bounded-memory failure raises `Fault_DataPage` at the original effective address.
- A fault records no load event, publishes nothing to `RegDst`, and leaves `TPC` on the faulting instruction so the attempt can be reissued in full.
- Design point: alignment is judged on the sum, so an aligned base is not sufficient; the shifted index contributes to the low three bits as well.

<!-- PTO-READER-BLOCK: scalar-ld-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- With `SrcL` = `0x2000`, `SrcR` = `3`, `shamt` `1`, and `SrcRType` `0`, the offset is `6` and the sum `0x2006` is not `8`-byte aligned, so `Fault_DataAlignment` is raised.
- With the same registers and `shamt` `3`, the offset is `24` and the address `0x2018`; `8` bytes are loaded from there.
- If those bytes are `01 02 03 04 05 06 07 08` in memory order, `RegDst` receives `0x0807060504030201`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ld [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ld_32_7c48838bc4e6 | L32 | 32 | 0x00003009 / 0x0000707f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ld_32_7c48838bc4e6 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ld_32_7c48838bc4e6 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ld_32_7c48838bc4e6 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| ld_32_7c48838bc4e6 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| ld_32_7c48838bc4e6 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ld_32_7c48838bc4e6 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| ld_32_7c48838bc4e6 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| ld_32_7c48838bc4e6 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| ld_32_7c48838bc4e6 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| ld_32_7c48838bc4e6 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `ld_32_7c48838bc4e6.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LD.asl -->
```asl
readonly func InstructionContractOperation_LD() => ScalarOperation
begin
    return ScalarOperation_LD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LD.asl -->
```asl
readonly func InstructionContractHandler_LD()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LD()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LD()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_LD()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_LD()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LD()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LD()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LD()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 is reserved. Encoded shamt zero performs no shift.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 8-byte load, preserve the complete 64-bit loaded bit pattern and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

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

- ld [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
