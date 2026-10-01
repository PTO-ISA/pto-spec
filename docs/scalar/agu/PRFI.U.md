<!-- GENERATED FROM: asl/scalar/agu/PRFI.U.asl -->
# PRFI.U

**Normative ASL source:** `asl/scalar/agu/PRFI.U.asl`

PRFI.U snapshots its scalar sources, forms its encoded address, and issues a non-binding 1-byte-granularity prefetch hint with no destination effect.

## Normative identity {#PTO-INST-SCALAR-PRFI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-prfi-u-purpose role=purpose -->
## What `PRFI.U` does

`PRFI.U` forms a byte address from `SrcL` plus an immediate that is added without scaling, and issues a non-binding prefetch hint for it. Its canonical assembly is `prfi.u [SrcL, simm]`, and the form exposes no destination.

Design point: a hint needs no alignment check, and that is what makes an unscaled immediate useful here. `PRFI.U` can name any byte in `-2048`..`2047` around the base, including the addresses a `4`-byte load would refuse with `Fault_DataAlignment`.

<!-- PTO-READER-BLOCK: scalar-prfi-u-mechanism role=mechanism -->
## How `PRFI.U` forms the address and issues the hint

`simm12` is sign-extended from its `12` bits to `PTO_XLEN` and added to the `SrcL` base modulo `2^PTO_XLEN`. The sum is passed to the hint and then discarded.

The encoding retains a `RegDst` field that names no destination, and no other field publishes a result. `SrcL` therefore keeps its value and no queue slot is written.

Design point: the only architectural trace the operation leaves is the `TPC` advance. The formed address is not stored anywhere, so two consecutive hints for the same address are indistinguishable from one.

<!-- PTO-READER-BLOCK: scalar-prfi-u-inputs role=inputs-outputs -->
## Encoded fields and what the hint consumes

- `SrcL` is a `5`-bit Reg5 source. Codes `0`..`23` name absolute GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. Reading a `T` or `U` slot neither consumes nor reorders it, and code `0` supplies the constant zero GPR.
- `simm12` is a signed `12`-bit field, so all `4096` encodings are values, and encoded zero supplies a zero displacement rather than denoting omission.
- `RegDst` is retained as an ignored alias: every code `0`..`31` is legal, none writes a register or pushes a queue slot, and the canonical assembly exposes no destination.

Design point: the hint still reads `SrcL`, because the address is formed from it, and that read is why an unavailable `T`/`U` source is a rejection reason. Nothing about the read is published afterwards.

<!-- PTO-READER-BLOCK: scalar-prfi-u-effects role=effects -->
## Effects, ordering, and completion

`SrcL` is read before the hint, so the address uses the pre-instruction value even if a later instruction overwrites that register.

Successful execution changes no memory byte, reservation entry, queue entry, or register. `TPC` then advances by `4` bytes, the length of this encoding.

Design point: with no memory event and no ordering edge, this form cannot change what another agent observes. Its only visible effect is that the instruction retires and `TPC` moves to the next instruction.

<!-- PTO-READER-BLOCK: scalar-prfi-u-constraints role=constraints -->
## Legality, faults, and restart

Dispatch rejects the instruction with `Fault_IllegalInstruction` before any effect when the fixed bits do not match, or when a selected `T`/`U` source slot is unavailable because nothing has been pushed into it.

A legal `PRFI.U` performs no alignment, translation, permission, or bounded-memory test, so neither `Fault_DataAlignment` nor `Fault_DataPage` is reachable from a legal encoding.

The rejection happens before the address is formed, so a rejected attempt has no partial effect and `TPC` stays on the faulting instruction; reissue repeats the same encoding checks.

Design point: there is no data-fault path to restart, so the only restart this form can require is an encoding or source-availability rejection, which software resolves by changing the instruction rather than by fixing an address.

<!-- PTO-READER-BLOCK: scalar-prfi-u-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- Take `prfi.u [3, 2]` with GPR3 = `0x1000`.
- `simm12=2` sign-extends to `2`, so the hint address is `0x1002`.
- `0x1002` is not `4`-byte aligned, but a hint performs no alignment check, so nothing is refused.
- The address is discarded: no register, queue slot, or memory byte changes, and `TPC` advances by `4` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
prfi.u [SrcL, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| prfi_u_32_167b42882547 | L32 | 32 | 0x00007029 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| prfi_u_32_167b42882547 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| prfi_u_32_167b42882547 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| prfi_u_32_167b42882547 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| prfi_u_32_167b42882547 | RegDst | 5 | 0–31 | none | none | ignored encoded alias field | Encoded zero is the canonical ignored alias value and names no destination. |
| prfi_u_32_167b42882547 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| prfi_u_32_167b42882547 | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | ignored encoded alias field |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/PRFI.U.asl -->
```asl
readonly func InstructionContractOperation_PRFI_U() => ScalarOperation
begin
    return ScalarOperation_PRFI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/PRFI.U.asl -->
```asl
readonly func InstructionContractHandler_PRFI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;

pure func InstructionContractAGUAction_PRFI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Prefetch;
end;

pure func InstructionContractAGUAddressKind_PRFI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_PRFI_U()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_PRFI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_PRFI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_PRFI_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_PRFI_U()
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
- Every encoded RegDst value is an assigned non-writing alias. Canonical assembly uses zero and does not expose a destination.
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 1.

## State effects

- Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
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

- prfi.u [SrcL, simm]
