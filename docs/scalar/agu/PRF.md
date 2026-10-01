<!-- GENERATED FROM: asl/scalar/agu/PRF.asl -->
# PRF

**Normative ASL source:** `asl/scalar/agu/PRF.asl`

PRF snapshots its scalar sources, forms its encoded address, and issues a non-binding 1-byte-granularity prefetch hint with no destination effect.

## Normative identity {#PTO-INST-SCALAR-PRF}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-prf-purpose role=purpose -->
## What `PRF` does

`PRF` forms the same kind of byte address as `LW` — a base register plus a transformed and shifted register offset — and issues a non-binding prefetch hint for it. Its canonical assembly is `prf [SrcL, SrcR<{.sw,.uw}><<<shamt>]`, and it exposes no destination.

Design point: the hint is non-binding, so `PRF` can never raise a data-access fault. A hint for a misaligned, unmapped, or out-of-range address retires exactly like a hint for a valid one, and software needs no accessibility test of its own before issuing it.

<!-- PTO-READER-BLOCK: scalar-prf-mechanism role=mechanism -->
## How `PRF` forms the address and issues the hint

`SrcL` is read as the base. `SrcR` is transformed by `SrcRType` — `0` keeps the complete `64`-bit value, `1` sign-extends the low `32` bits, `2` zero-extends them — and shifted left by the encoded `shamt`. The offset is added to the base modulo `2^PTO_XLEN`.

The formed address is passed to the hint and then discarded. No encoded field publishes it, so there is no result to read and no base writeback to observe.

Design point: the offset transformation is still architecturally defined even though the hint has no result. Two hints that differ only in `SrcRType` or `shamt` name different addresses; that difference is simply not visible in any architectural state.

<!-- PTO-READER-BLOCK: scalar-prf-inputs role=inputs-outputs -->
## Encoded fields and what the hint consumes

- `SrcL` and `SrcR` are `5`-bit Reg5 sources. Codes `0`..`23` name absolute GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. Reading a `T` or `U` slot neither consumes nor reorders it, and code `0` supplies the constant zero GPR.
- `SrcRType` is assigned for `0`, `1`, and `2`; raw `3` is reserved. `shamt` is assigned for all `32` values `0`..`31`, and encoded zero performs no shift.
- `RegDst` is retained in the encoding but names no destination. Every code `0`..`31` is legal, none of them writes a GPR or pushes a queue slot, and the canonical assembly exposes no destination.

Design point: because `RegDst` is an alias rather than a destination, code `0` in that field is not a discard selector either. The field has no effect at any value, and an implementation cannot turn it into a queue push.

<!-- PTO-READER-BLOCK: scalar-prf-effects role=effects -->
## Effects, ordering, and completion

Both source reads happen before the hint, so the address reflects the pre-instruction values of `SrcL` and `SrcR`.

Successful execution changes no architectural state: no memory byte, no reservation entry, no queue entry, and no register. `TPC` then advances by `4` bytes, the length of this encoding.

Design point: a legal hint records no memory event and creates no ordering edge, so it cannot make an earlier or later access observe anything. The only architectural difference after `PRF` is that `TPC` has moved.

<!-- PTO-READER-BLOCK: scalar-prf-constraints role=constraints -->
## Legality, faults, and restart

Dispatch rejects the instruction with `Fault_IllegalInstruction` before any effect when the fixed bits do not match, when `SrcRType` holds the reserved value `3`, or when a selected `T`/`U` source slot is unavailable because nothing has been pushed into it.

A legal `PRF` performs no alignment test, no translation, and no permission or bounded-memory test. Neither `Fault_DataAlignment` nor `Fault_DataPage` is reachable from a legal encoding.

The rejection happens before the address is formed, so a rejected attempt has no partial effect and `TPC` stays on the faulting instruction; reissue repeats the same encoding checks.

Design point: the only way this form can leave `TPC` unchanged is an encoding rejection, because the legal path has no fault outcome. A rejected hint contributes no hint at all, which keeps the non-binding contract intact.

<!-- PTO-READER-BLOCK: scalar-prf-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- Take `prf [2, 3<.sw><<<3]` with GPR2 = `0x2000` and GPR3 = `0xFFFFFFFE`.
- `SrcRType=1` sign-extends the low `32` bits, giving `-2`; `shamt=3` shifts it left by `3`, giving `-16`.
- The hint address is `0x2000` minus `16`, which is `0x1FF0`. The instruction forms it and discards it.
- No register, queue slot, memory byte, or reservation entry changes; the only architectural difference is that `TPC` has advanced by `4` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
prf [SrcL, SrcR<{.sw,.uw}><<<shamt>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| prf_32_30e6dfe4e3ce | L32 | 32 | 0x00007009 / 0x0000707f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| prf_32_30e6dfe4e3ce | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| prf_32_30e6dfe4e3ce | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| prf_32_30e6dfe4e3ce | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| prf_32_30e6dfe4e3ce | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| prf_32_30e6dfe4e3ce | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| prf_32_30e6dfe4e3ce | RegDst | 5 | 0–31 | none | none | ignored encoded alias field | Encoded zero is the canonical ignored alias value and names no destination. |
| prf_32_30e6dfe4e3ce | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| prf_32_30e6dfe4e3ce | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| prf_32_30e6dfe4e3ce | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| prf_32_30e6dfe4e3ce | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `prf_32_30e6dfe4e3ce.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | ignored encoded alias field |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/PRF.asl -->
```asl
readonly func InstructionContractOperation_PRF() => ScalarOperation
begin
    return ScalarOperation_PRF;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/PRF.asl -->
```asl
readonly func InstructionContractHandler_PRF()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;

pure func InstructionContractAGUAction_PRF()
    => ScalarAGUAction
begin
    return ScalarAGU_Prefetch;
end;

pure func InstructionContractAGUAddressKind_PRF()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_PRF()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_PRF()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_PRF()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_PRF()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_PRF()
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
- Every encoded RegDst value is an assigned non-writing alias. Canonical assembly uses zero and does not expose a destination.
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- Discard the formed address after issuing the non-binding hint; no encoded field publishes a result.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- The 1-byte-granularity hint performs no architectural translation, permission or alignment check, memory access, memory event, reservation update, ordering edge, or cache-placement guarantee.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- For a legal model, form the hint, publish the optional address result, and then advance TPC by 4 bytes.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A legal prefetch model cannot raise a data-access fault. A reserved model rejects before source reads and before optional address publication.

## Examples

- prf [SrcL, SrcR<{.sw,.uw}><<<shamt>]
