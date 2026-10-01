<!-- GENERATED FROM: asl/scalar/agu/LH.asl -->
# LH

**Normative ASL source:** `asl/scalar/agu/LH.asl`

LH snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-LH}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lh-purpose role=purpose -->
## What `LH` does

`LH` loads one signed `2`-byte little-endian halfword from a base register plus a transformed, shifted index, and sign-extends it to the full destination width.

The canonical assembly is `lh [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}`.

Design point: `LH` is the signed halfword read of the family, so a stored `0x8000` comes back as a negative `64`-bit value. Its unsigned twin `LHU` shares the addressing and differs only in the extension.

<!-- PTO-READER-BLOCK: scalar-lh-mechanism role=mechanism -->
## How the address and the transfer are formed

The offset is the `SrcR` index after the `SrcRType` transformation, shifted left by the encoded `shamt`, then added to the `SrcL` snapshot modulo `2^PTO_XLEN`.

Preflight checks `2`-byte alignment, then translation, then permission and bounded memory. On success `2` bytes are read little-endian, the low-addressed byte becoming the least significant byte, and one relaxed load event is recorded.

The halfword is sign-extended to `PTO_XLEN` and published through `RegDst`. No base register is updated.

Design point: with `shamt` at least `1` the offset is even, so the parity of the effective address is the parity of the base. Only `shamt` `0` lets an odd index produce an odd sum, and the sum is what the alignment stage judges.

<!-- PTO-READER-BLOCK: scalar-lh-inputs role=inputs-outputs -->
## Encoded fields and roles

- `SrcL` is the base selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `SrcR` is the index selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `SrcRType` selects unchanged, `.sw`, or `.uw` and reserves `3`; `shamt` covers `0`..`31` and is applied after the transformation.
- `RegDst` is the destination selector. Codes `1`..`23` write GPRs, `30` pushes the `U` queue, `31` pushes the `T` queue, and `0` plus `24`..`29` publish nothing; code `0` is the architectural zero GPR, whose writes are discarded.
- Design point: `SrcRType` is a `2`-bit field with one reserved pattern, and the reserved pattern is rejected in the legality stage instead of being treated as a fourth transformation.

<!-- PTO-READER-BLOCK: scalar-lh-effects role=effects -->
## Effects, ordering, and completion

Every source is snapshotted before the memory access, so an encoding whose destination is also its base still computes the address from the pre-instruction base.

Success records one relaxed load event, leaves memory and the reservation unchanged, publishes the sign-extended halfword, and advances `TPC` by `4` bytes.

Design point: publication happens only after the probe passes, so a faulting `LH` leaves `RegDst` at its previous value even when the destination names the base register.

<!-- PTO-READER-BLOCK: scalar-lh-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch, a reserved `SrcRType`, or an unavailable `T`/`U` source raises `Fault_IllegalInstruction` at the instruction address before any instruction effect.
- A sum that is not a multiple of `2` raises `Fault_DataAlignment` before translation; a later permission or bounded-memory failure raises `Fault_DataPage` at the original effective address.
- A fault records no event, publishes nothing, and leaves `TPC` on the faulting instruction for a full reissue.
- Design point: a misaligned halfword address is reported before translation and before permission, so an address that would also fail the permission check is reported as `Fault_DataAlignment`.

<!-- PTO-READER-BLOCK: scalar-lh-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- With `SrcL` = `0x100`, `SrcR` = `1`, `shamt` `1`, and `SrcRType` `0`, the offset is `2` and the address is `0x102`.
- Bytes `00 80` at `0x102` are the little-endian halfword `0x8000`, which sign-extends to `0xFFFFFFFFFFFF8000` in `RegDst`.
- Changing `shamt` to `0` and using an odd index would move the access to an odd address and raise `Fault_DataAlignment`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lh [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lh_32_d0f04d7d7696 | L32 | 32 | 0x00001009 / 0x0000707f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lh_32_d0f04d7d7696 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lh_32_d0f04d7d7696 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lh_32_d0f04d7d7696 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lh_32_d0f04d7d7696 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| lh_32_d0f04d7d7696 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lh_32_d0f04d7d7696 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lh_32_d0f04d7d7696 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lh_32_d0f04d7d7696 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| lh_32_d0f04d7d7696 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| lh_32_d0f04d7d7696 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `lh_32_d0f04d7d7696.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LH.asl -->
```asl
readonly func InstructionContractOperation_LH() => ScalarOperation
begin
    return ScalarOperation_LH;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LH.asl -->
```asl
readonly func InstructionContractHandler_LH()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LH()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LH()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_LH()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_LH()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LH()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LH()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LH()
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
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 2-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

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

- lh [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
