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
## What HL.PRF.A does

`HL.PRF.A` is a standalone `48`-bit scalar AGU instruction that forms a non-binding prefetch hint without performing an architectural memory access using `Register` addressing.

<!-- PTO-READER-BLOCK: scalar-hl-prf-a-mechanism role=mechanism -->
## Address and transfer mechanism

The register-offset path applies the encoded `SrcRType` transformation to `SrcR`, shifts that result left by `shamt`, and adds it to the snapshotted `SrcL` value modulo `2^PTO_XLEN`.

A legal `model` selects the hint level. The hint performs no translation, permission check, alignment check, memory access, memory event, reservation update, ordering edge, or cache-placement guarantee.

The effective address is published through `RegDst` after source snapshot.

<!-- PTO-READER-BLOCK: scalar-hl-prf-a-inputs role=inputs-outputs -->
## Encoded inputs and outputs

- `RegDst` is a `5`-bit field selecting the effective-address result.
- `SrcL` is a `5`-bit field selecting the address base.
- `SrcR` is a `5`-bit field selecting the register offset.
- `SrcRType` is a `2`-bit field selecting the register-offset transformation.
- `model` is a `5`-bit field selecting the prefetch hint level.
- `shamt` is a `5`-bit field selecting the post-transformation left shift.

<!-- PTO-READER-BLOCK: scalar-hl-prf-a-effects role=effects -->
## Effects and completion order

All explicit and implicit scalar sources are snapshotted before any memory or destination effect, so aliases use pre-instruction values.

A legal hint records no architectural memory event and does not change reservation state.

After all result or writeback publication, `HL.PRF.A` advances `TPC` by `6` bytes; a rejected or faulting attempt does not retire.

<!-- PTO-READER-BLOCK: scalar-hl-prf-a-constraints role=constraints -->
## Legality, faults, and restart

`model` values `0`, `1`, and `2` are assigned; values `3..31` are reserved and cause `Fault_IllegalInstruction` before source reads or address publication.

A legal prefetch hint cannot raise a data-access fault because it performs no architectural access. Fixed-bit mismatches or unavailable selected T/U sources are rejected before effects.

<!-- PTO-READER-BLOCK: scalar-hl-prf-a-example role=example -->
## Non-normative reading walkthrough

This walkthrough explains how to use the page and does not add instruction behavior.

- Start with the canonical assembly `hl.prf.a{.l1,.l2,.l3} [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->{t, u, Rd}` and identify the encoded address fields.
- Then compare the address mode, transfer action, completion effects, and fault boundary above with the exact generated ASL contract below.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.prf.a{.l1,.l2,.l3} [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_prf_a_48_267dc57d14f4 | HL48 | 48 | 0x00007009001e / 0x0000707f07ff | [{"field":"model","operator":"one-of","values":[0,1,2]}] |

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
| hl_prf_a_48_267dc57d14f4 | SrcRType | 2 | 0–3 | none | none | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_prf_a_48_267dc57d14f4 | model | 5 | 0–2 | none | 3–31 | cache-level hint selector | Encoded zero selects the non-binding L1 cache hint. |
| hl_prf_a_48_267dc57d14f4 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

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
- SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 negates the full PTO_XLEN value. Encoded shamt zero performs no shift.
- model=0 selects L1, model=1 selects L2, and model=2 selects L3; the cache target is a non-binding performance hint.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- All four SrcRType values and all shamt values 0..31 are assigned; apply the modifier before the shift.
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

- hl.prf.a{.l1,.l2,.l3} [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->{t, u, Rd}
