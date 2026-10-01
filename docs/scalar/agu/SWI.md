<!-- GENERATED FROM: asl/scalar/agu/SWI.asl -->
# SWI

**Normative ASL source:** `asl/scalar/agu/SWI.asl`

SWI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-SWI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-swi-purpose role=purpose -->
## What SWI does

`SWI` forms one address from a Reg5 base plus a scaled signed displacement and stores the low `4` bytes of another Reg5 source there, little-endian.

Design point: `SWI` has no destination field at all. Its address-update mode is none, so the base register keeps its value and the instruction cannot be used to walk a pointer; a traversal needs an explicit address computation or a post-index form.

<!-- PTO-READER-BLOCK: scalar-swi-mechanism role=mechanism -->
## Address and memory mechanism

The address is formed in three steps, and every step happens before the memory access.

- `simm12` is sign-extended, giving a displacement value from `-2048` through `2047`.
- That value is shifted left by `2`, so the byte displacement is `simm12 * 4`, in the range `-8192` through `8188`.
- The scaled displacement is added to the `SrcR` base modulo `2^PTO_XLEN`.

Preflight then checks the address before any byte is written: a `4`-byte misaligned address raises `Fault_DataAlignment` at the original address, and a later permission or bounded-memory failure raises `Fault_DataPage`. Only after the probe succeeds are the `4` bytes stored from the low byte upward, together with one relaxed store event; a store that overlaps a valid reservation invalidates that reservation.

Design point: the displacement is scaled by `4`, so the low two address bits come entirely from the base register. Choosing a different `simm12` cannot repair a misaligned base, and every address `SWI` can reach has the same alignment as `SrcR`.

Design point: the scaled displacement covers `8192` bytes below and `8188` bytes above the base in steps of `4`, so it reaches a `16` KiB window around the base. Because every scaled displacement is a multiple of `4`, a `4`-byte aligned base keeps the access aligned for every `simm12`.

<!-- PTO-READER-BLOCK: scalar-swi-inputs role=inputs-outputs -->
## Inputs and outputs

- `SrcL` is the Reg5 store-data source.
- `SrcR` is the Reg5 address base.
- `simm12` is the signed displacement.
- There is no `RegDst` field, so `SWI` writes no register, GPR, `T` or `U`.

Design point: encoded zero of `SrcL` or `SrcR` reads the architectural zero GPR, so `swi zero, [a0, 0]` stores four zero bytes. Encoded zero of `simm12` is a real zero displacement and never means omission; every displayed field is encoded explicitly.

<!-- PTO-READER-BLOCK: scalar-swi-effects role=effects -->
## Effects and ordering

Both scalar sources are snapshotted before the memory effect, so a store whose data source is also the base uses the pre-instruction value of that register for both roles.

On success the `4` bytes are committed and the reservation state is updated, then `TPC` advances by `4` bytes. A successful store whose written range overlaps the reservation granule holding the reserved address clears the reservation; a non-overlapping store leaves it valid. On a fault no byte is written, the reservation is left unchanged, and `TPC` stays at the faulting instruction, because the address probe completes before the memory operation. Recovery is a full reissue: address formation, source snapshot, preflight and the memory operation all run again with no retained progress. `SWI` changes no descriptor, numeric-status, block, privilege, predicate or control-flow state.

<!-- PTO-READER-BLOCK: scalar-swi-constraints role=constraints -->
## Alignment, faults, and restart

The `4`-byte access is the complete transfer unit. Both Reg5 source fields use the full common domain: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4` without consuming a queue entry.

The checks run in order. An undecodable form raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`; an unavailable selected T/U source raises `Fault_IllegalInstruction`; then the address probe raises `Fault_DataAlignment` for a misaligned address, and `Fault_DataPage` for an address outside the permitted, bounded region.

Design point: alignment is checked before translation and permission, so a misaligned address in an otherwise inaccessible page reports `Fault_DataAlignment` at the original address and never `Fault_DataPage`.

Design point: `simm12` covers every signed 12-bit value, so there is no reserved displacement and no illegal immediate. The displacement can be any multiple of `4` in its range, including zero.

<!-- PTO-READER-BLOCK: scalar-swi-example role=example -->
## Non-normative address example

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

With `SrcR` holding `256` and `simm12=2`, the displacement is `8` and the access address is `264`. With `simm12=-2` on the same base the address is `248`, and both addresses have the same low two bits as the base, so both are aligned exactly when `256` is. `swi a0, [a1, 2]` stores the low `4` bytes of `a0` at `a1 + 8`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
swi SrcL, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| swi_32_147e55489c41 | L32 | 32 | 0x00002059 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| swi_32_147e55489c41 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| swi_32_147e55489c41 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| swi_32_147e55489c41 | simm12 | 12 | signed | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| swi_32_147e55489c41 | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| swi_32_147e55489c41 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| swi_32_147e55489c41 | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| SrcR | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SWI.asl -->
```asl
readonly func InstructionContractOperation_SWI() => ScalarOperation
begin
    return ScalarOperation_SWI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SWI.asl -->
```asl
readonly func InstructionContractHandler_SWI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SWI()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SWI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_SWI()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_SWI()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_SWI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SWI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SWI()
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
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 4, and add it modulo 2^PTO_XLEN to the SrcR base.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 4-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- swi SrcL, [SrcR, simm]
