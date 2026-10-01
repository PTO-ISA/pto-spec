<!-- GENERATED FROM: asl/scalar/agu/HL.PRF.A.asl -->
# HL.PRF.A

**Normative ASL source:** `asl/scalar/agu/HL.PRF.A.asl`

HL.PRF.A snapshots its scalar sources, forms its encoded address, and issues a non-binding 1-byte-granularity prefetch hint and publishes the effective address.

## Normative identity {#PTO-INST-SCALAR-HL-PRF-A}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-prf-a-purpose role=purpose -->
## What `HL.PRF.A` does

`HL.PRF.A` is a standalone `48`-bit scalar AGU instruction that issues a non-binding 1-byte-granularity prefetch hint and publishes the effective address it formed.

The canonical assembly is `hl.prf.a{.l1,.l2,.l3} [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}`. The `.l1`, `.l2`, and `.l3` suffixes select the level named by the `model` field.

Design point: this form is the register-offset hint that also returns its own sum. Keeping the address lets one traversal hint a line and keep the pointer it used, without recomputing the same add. The suffix `.a` marks that published address.

<!-- PTO-READER-BLOCK: scalar-hl-prf-a-mechanism role=mechanism -->
## How the address and the transfer are formed

`SrcRType` transforms the `SrcR` snapshot, `shamt` shifts the result, and the shifted value is added to the `SrcL` snapshot modulo `2^PTO_XLEN`. The sum is both the hinted address and the published result.

The model then does the address formation and nothing else: no translation, no alignment or permission check, no memory access, no memory event, and no reservation or ordering effect.

Design point: because the prefetch path never probes the address, a hint naming an address outside the permitted region is not a fault. The published value is a computation, not evidence that anything was fetched.

<!-- PTO-READER-BLOCK: scalar-hl-prf-a-inputs role=inputs-outputs -->
## Encoded fields and results

- `SrcL` is a `5`-bit Reg5 selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed.
- `SrcR` uses the same `5`-bit Reg5 domain as the register-offset source.
- `SrcRType` is a `2`-bit register-offset transformation selector. Raw value `00` leaves the whole `SrcR` value unchanged, `01` replaces it with the signed reading of its low `32` bits, `10` with the unsigned reading of those bits, and `11` is reserved.
- `shamt` is a `5`-bit unsigned shift amount applied after the transformation; encoded zero performs no shift.
- `model` is a `5`-bit selector. Value `0` names `L1`, `1` names `L2`, and `2` names `L3`; values `3`..`31` are reserved.
- `RegDst` is a `5`-bit selector that receives the formed address. Codes `1`..`23` write absolute GPRs, code `30` pushes `U`, code `31` pushes `T`, and codes `0` and `24`..`29` discard it.

Design point: a reserved `model` value rejects before the sources are read and before `RegDst` is written, so a rejected hint leaves the destination exactly as it was.

<!-- PTO-READER-BLOCK: scalar-hl-prf-a-effects role=effects -->
## Effects, ordering, and completion

Every scalar source is snapshotted before the destination is written, so a destination that names the base or the offset source still contributes the pre-instruction value to the hinted address.

The hint records no memory event, changes no memory byte, and leaves reservation state and ordering untouched.

`TPC` advances by `6` bytes after the address result is published. A rejected or faulting attempt does not retire.

Design point: the destination is written once, in the publication step, so a load that follows can use the returned pointer directly. Nothing in this instruction reads memory back to build that value.

<!-- PTO-READER-BLOCK: scalar-hl-prf-a-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch, a reserved encoded value, or a source code selecting an unavailable `T` or `U` slot raises `Fault_IllegalInstruction` before any instruction effect.

A reserved `model` value raises `Fault_IllegalInstruction` before the sources are read and before any address is published.

A legal hint raises no data-access fault. Recovery performs a full reissue: the snapshots, the address formation, and the publication are recomputed with no retained progress.

Design point: `RegDst` cannot receive a partial address, because the only write to it happens after every check has passed. A program that retries a rejected hint sees the destination unchanged.

<!-- PTO-READER-BLOCK: scalar-hl-prf-a-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.prf.a.l2 [4, 8<<1], ->20` with GPR4 = `0x4000` and GPR8 = `0x10`.
- `SrcRType` is `00`, so the offset is `0x10` unchanged; `shamt` is `1`, so it becomes `0x20` and the hinted address is `0x4020`.
- `model` is `1`, so the `.l2` suffix and the encoded field agree on the `L2` level.
- GPR20 receives `0x4020`, and `TPC` becomes the instruction address plus `6`.
- A later load through GPR20 still performs its own probe and can still fault.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.prf.a{.l1,.l2,.l3} [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_prf_a_48_267dc57d14f4 | HL48 | 48 | 0x00007009001e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]},{"field":"model","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_prf_a_48_267dc57d14f4 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_prf_a_48_267dc57d14f4 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_prf_a_48_267dc57d14f4 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_prf_a_48_267dc57d14f4 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_prf_a_48_267dc57d14f4 | model | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_prf_a_48_267dc57d14f4 | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_prf_a_48_267dc57d14f4 | RegDst | 5 | 0–31 | none | none | Reg5 effective-address destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_prf_a_48_267dc57d14f4 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_prf_a_48_267dc57d14f4 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_prf_a_48_267dc57d14f4 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_prf_a_48_267dc57d14f4 | model | 5 | 0–2 | none | 3–31 | cache-level hint selector | Encoded zero selects the non-binding L1 cache hint. |
| hl_prf_a_48_267dc57d14f4 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_prf_a_48_267dc57d14f4.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `hl_prf_a_48_267dc57d14f4.model` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 effective-address destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| model | cache-level hint selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.PRF.A.asl -->
```asl
readonly func InstructionContractOperation_HL_PRF_A() => ScalarOperation
begin
    return ScalarOperation_HL_PRF_A;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.PRF.A.asl -->
```asl
readonly func InstructionContractHandler_HL_PRF_A()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;

pure func InstructionContractAGUAction_HL_PRF_A()
    => ScalarAGUAction
begin
    return ScalarAGU_Prefetch;
end;

pure func InstructionContractAGUAddressKind_HL_PRF_A()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_PRF_A()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_PRF_A()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_PRF_A()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_PRF_A()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_PRF_A()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 is reserved. Encoded shamt zero performs no shift.
- model=0 selects L1, model=1 selects L2, and model=2 selects L3; the cache target is a non-binding performance hint.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.
- model codes 0, 1, and 2 are assigned; codes 3..31 are reserved and raise Fault_IllegalInstruction before any scalar source read or architectural effect.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- Publish the modulo-2^PTO_XLEN effective address through the Reg5 destination after source snapshot.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- The 1-byte-granularity hint performs no architectural translation, permission or alignment check, memory access, memory event, reservation update, ordering edge, or cache-placement guarantee.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- For a legal model, form the hint, publish the optional address result, and then advance TPC by 6 bytes.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A legal prefetch model cannot raise a data-access fault. A reserved model rejects before source reads and before optional address publication.

## Examples

- hl.prf.a{.l1,.l2,.l3} [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
