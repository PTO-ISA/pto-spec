<!-- GENERATED FROM: asl/scalar/agu/HL.PRFI.UA.asl -->
# HL.PRFI.UA

**Normative ASL source:** `asl/scalar/agu/HL.PRFI.UA.asl`

HL.PRFI.UA snapshots its scalar sources, forms its encoded address, and issues a non-binding 1-byte-granularity prefetch hint and publishes the effective address.

## Normative identity {#PTO-INST-SCALAR-HL-PRFI-UA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-prfi-ua-purpose role=purpose -->
## What `HL.PRFI.UA` does

`HL.PRFI.UA` is a standalone `48`-bit scalar AGU instruction that issues a non-binding 1-byte-granularity prefetch hint with an immediate displacement and publishes the effective address it formed.

The canonical assembly is `hl.prfi.ua{.l1,.l2,.l3} [SrcL, simm], ->{t, u, Rd}`. The `.l1`, `.l2`, and `.l3` suffixes select the level named by the `model` field.

Design point: this form is the immediate hint that also returns its own sum. Keeping the address lets one instruction point at a line and hand the traversal its next pointer, without recomputing the same add. The suffix `.ua` marks the published address on an unscaled immediate.

<!-- PTO-READER-BLOCK: scalar-hl-prfi-ua-mechanism role=mechanism -->
## How the address and the transfer are formed

The sign-extended `simm17` value is added to the `SrcL` snapshot modulo `2^PTO_XLEN`. The scale is `1`: the encoded value is the byte distance, not a count of units. The sum is both the hinted address and the published result.

The model then does the address formation and nothing else: no translation, no alignment or permission check, no memory access, no memory event, and no reservation or ordering effect.

Design point: because the prefetch path never probes the address, a hint naming an address outside the permitted region is not a fault. The published value is a computation, not evidence that anything was fetched.

<!-- PTO-READER-BLOCK: scalar-hl-prfi-ua-inputs role=inputs-outputs -->
## Encoded fields and results

- `SrcL` is a `5`-bit Reg5 selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed.
- `simm17` is a signed `17`-bit displacement carried in the encoding as two pieces at bits `36`..`47` and bits `6`..`10`, covering `-65536`..`65535` bytes.
- `model` is a `5`-bit selector. Value `0` names `L1`, `1` names `L2`, and `2` names `L3`; values `3`..`31` are reserved.
- `RegDst` is a `5`-bit selector that receives the formed address. Codes `1`..`23` write absolute GPRs, code `30` pushes `U`, code `31` pushes `T`, and codes `0` and `24`..`29` discard it.

Design point: a reserved `model` value rejects before the source is read and before `RegDst` is written, so a rejected hint leaves the destination exactly as it was.

<!-- PTO-READER-BLOCK: scalar-hl-prfi-ua-effects role=effects -->
## Effects, ordering, and completion

Every scalar source is snapshotted before the destination is written, so a destination that names `SrcL` still contributes the pre-instruction base to the hinted address.

The hint records no memory event, changes no memory byte, and leaves reservation state and ordering untouched.

`TPC` advances by `6` bytes after the address result is published. A rejected or faulting attempt does not retire.

Design point: the destination is written once, in the publication step, so the value cannot be a mixture of a pre-instruction base and a post-instruction one. A retry after a rejection starts from the same register state.

<!-- PTO-READER-BLOCK: scalar-hl-prfi-ua-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch, or a source code selecting an unavailable `T` or `U` slot, raises `Fault_IllegalInstruction` before any instruction effect.

A reserved `model` value raises `Fault_IllegalInstruction` before the source is read and before any address is published.

A legal hint raises no data-access fault. Recovery performs a full reissue: the snapshot, the address formation, and the publication are recomputed with no retained progress.

Design point: the immediate is compared against nothing, because every signed `17`-bit value is assigned, so no immediate value can be the reason a hint rejects. Only the fixed bits, the `model` field, and the source codes can reject.

<!-- PTO-READER-BLOCK: scalar-hl-prfi-ua-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.prfi.ua.l3 [6, -64], ->20` with GPR6 = `0x1000`.
- The scale is `1`, so the byte displacement is `-64` and the hinted address is `0x0FC0`.
- `model` is `2`, so the `.l3` suffix and the encoded field agree on the `L3` level.
- GPR20 receives `0x0FC0`, and `TPC` becomes the instruction address plus `6`.
- A later load through GPR20 still performs its own probe and can still fault.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.prfi.ua{.l1,.l2,.l3} [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_prfi_ua_48_c37fb30ecb0f | HL48 | 48 | 0x00007029001e / 0x0000707f003f | [{"field":"model","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_prfi_ua_48_c37fb30ecb0f | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_prfi_ua_48_c37fb30ecb0f | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_prfi_ua_48_c37fb30ecb0f | model | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_prfi_ua_48_c37fb30ecb0f | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_prfi_ua_48_c37fb30ecb0f | RegDst | 5 | 0–31 | none | none | Reg5 effective-address destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_prfi_ua_48_c37fb30ecb0f | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_prfi_ua_48_c37fb30ecb0f | model | 5 | 0–2 | none | 3–31 | cache-level hint selector | Encoded zero selects the non-binding L1 cache hint. |
| hl_prfi_ua_48_c37fb30ecb0f | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

- `hl_prfi_ua_48_c37fb30ecb0f.model` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 effective-address destination or discard |
| SrcL | Reg5 address-base source |
| model | cache-level hint selector |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.PRFI.UA.asl -->
```asl
readonly func InstructionContractOperation_HL_PRFI_UA() => ScalarOperation
begin
    return ScalarOperation_HL_PRFI_UA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.PRFI.UA.asl -->
```asl
readonly func InstructionContractHandler_HL_PRFI_UA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;

pure func InstructionContractAGUAction_HL_PRFI_UA()
    => ScalarAGUAction
begin
    return ScalarAGU_Prefetch;
end;

pure func InstructionContractAGUAddressKind_HL_PRFI_UA()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_PRFI_UA()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_PRFI_UA()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_PRFI_UA()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_PRFI_UA()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_PRFI_UA()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- model=0 selects L1, model=1 selects L2, and model=2 selects L3; the cache target is a non-binding performance hint.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 1.
- model codes 0, 1, and 2 are assigned; codes 3..31 are reserved and raise Fault_IllegalInstruction before any scalar source read or architectural effect.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
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

- hl.prfi.ua{.l1,.l2,.l3} [SrcL, simm], ->{t, u, Rd}
