<!-- GENERATED FROM: asl/scalar/agu/C.SDI.asl -->
# C.SDI

**Normative ASL source:** `asl/scalar/agu/C.SDI.asl`

C.SDI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-C-SDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-sdi-purpose role=purpose -->
## What `C.SDI` does

`C.SDI` is a `16`-bit compressed store of one `8`-byte little-endian value. The base is the `SrcL` selector, the byte displacement is the sign-extended `simm5` field multiplied by `8`, and the data written to memory is the newest temporary-queue value, named `t#1` in the assembly.

The form has no destination field and no writeback: it moves one value from the queue to memory and leaves the register file untouched.

Design point: the data source is not an encoded field. The handler reads Reg5 selector code `24`, the queue path for `T#1`, so the assembly shows `t#1` as a fixed operand. Reading a queue entry does not pop it, so `T#1` keeps its value after the store, and two `C.SDI` executions with no queue push between them write the same `64` bits to different addresses.

<!-- PTO-READER-BLOCK: scalar-c-sdi-mechanism role=mechanism -->
## How the address and the store are formed

The address path snapshots `SrcL`, sign-extends `simm5`, shifts it left by `3` bits, and adds the two modulo `2^PTO_XLEN`.

There is no updated-base destination and no writeback step, so the base selector is never modified: not on success and not on a fault.

The handler reads `T#1`, performs one aligned `8`-byte little-endian store, and records the store event. The `64` bits are written byte by byte from the least significant byte at the lowest address.

Design point: because the displacement scale equals the access size, the reachable window is `-128` to `120` bytes in steps of `8`, and an `8`-byte-aligned base always produces an `8`-byte-aligned address. The store can therefore never be rejected for misalignment by its own displacement field.

<!-- PTO-READER-BLOCK: scalar-c-sdi-inputs role=inputs-outputs -->
## Encoded fields and where the data comes from

- `SrcL` is a `5`-bit Reg5 selector: codes `0`..`23` name absolute GPRs, codes `24`..`27` name `T#1`..`T#4`, and codes `28`..`31` name `U#1`..`U#4`.
- `simm5` is a signed `5`-bit displacement scaled by `8`; every encoding is a value and none denotes omission.
- The written value is implicit `T#1`. No field selects it, and no field can replace it with a register.

Design point: `T#1` must be available before the store runs. A queue slot whose validity flag is clear makes the instruction raise `Fault_IllegalInstruction` before the memory operation, so a store never writes an undefined value to memory. The same rule means the store cannot be used to probe whether the queue holds data without also risking the fault.

<!-- PTO-READER-BLOCK: scalar-c-sdi-effects role=effects -->
## Effects, ordering, and completion

The `SrcL` snapshot and the `T#1` read both happen before the memory effect, so a selector that names the queue entry being stored contributes its pre-instruction value.

On success the store records one relaxed store event. A store whose written byte range overlaps the reservation granule containing the reserved address clears the reservation; a store to a range that does not overlap leaves the reservation valid.

After the store completes, `C.SDI` advances `TPC` by `2` bytes. A rejected or faulting attempt does not retire and leaves `TPC` on the same instruction.

Design point: the overlap test uses the original address and the access size, not the granule-aligned address, so a store into the same granule as the reservation always clears it even when the exact bytes differ. Partial invalidation is not possible.

<!-- PTO-READER-BLOCK: scalar-c-sdi-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch in the `16`-bit encoding raises `Fault_IllegalInstruction` before any effect. An `SrcL` code selecting an unavailable `T` or `U` slot, and an unavailable `T#1`, raise the same fault at the same point.

The preflight tests the low `3` bits of the effective address: a nonzero value raises `Fault_DataAlignment` before translation and before the permission check, while an aligned address that fails the permission or bounded-memory test raises `Fault_DataPage` at the original address.

A fault writes no memory byte, records no store event, leaves the reservation unchanged, and keeps `TPC` on the faulting instruction. Recovery reissues the whole operation from the `SrcL` snapshot.

<!-- PTO-READER-BLOCK: scalar-c-sdi-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `c.sdi t#1, [3, 2]` with GPR3 holding `0x4000`. The signed `simm5` is `2`, scaled by `8` gives `16`, so the effective address is `0x4000` plus `16`, which is `0x4010`.
- The stored bytes are the `8` low-order bytes of the current `T#1`, written least significant byte first to `0x4010` through `0x4017`.
- `T#1` keeps its value because the queue read does not pop it, and GPR3 still holds `0x4000`; `TPC` becomes the instruction address plus `2`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.sdi t#1, [srcL, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_sdi_16_bbec69bcfd5d | C16 | 16 | 0x003a / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_sdi_16_bbec69bcfd5d | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_sdi_16_bbec69bcfd5d | simm5 | 5 | signed | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_sdi_16_bbec69bcfd5d | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| c_sdi_16_bbec69bcfd5d | simm5 | 5 | 0–31 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 address-base source |
| simm5 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/C.SDI.asl -->
```asl
readonly func InstructionContractOperation_C_SDI() => ScalarOperation
begin
    return ScalarOperation_C_SDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/C.SDI.asl -->
```asl
readonly func InstructionContractHandler_C_SDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_C_SDI()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_C_SDI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Compressed;
end;

pure func InstructionContractAGUSizeBytes_C_SDI()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_C_SDI()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_C_SDI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_C_SDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_C_SDI()
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
- The implicit store-data source is T#1 and must be available before execution; reading it does not consume it.
- simm5 assigns every signed 5-bit value -16..15; the encoded byte displacement is that value multiplied by 8.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm5, multiply it by 8, and add it modulo 2^PTO_XLEN to the SrcL base.
- Snapshot implicit T#1 before memory effects and preserve the queue entry after the store.
- Successful execution advances TPC by 2 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 8-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- c.sdi t#1, [srcL, simm]
