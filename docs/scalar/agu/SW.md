<!-- GENERATED FROM: asl/scalar/agu/SW.asl -->
# SW

**Normative ASL source:** `asl/scalar/agu/SW.asl`

SW snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-SW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sw-purpose role=purpose -->
## What `SW` does

`SW` writes the low `4` bytes of `SrcD` to the address formed from the `SrcL` base plus the transformed `SrcR` register offset. Its canonical assembly is `sw SrcD, [SrcL, SrcR<{.sw,.uw}><<2]`.

Design point: the scale of `4` turns the offset into a word index for `4`-byte data. The assembly writes it as `<<2`, and `sw.u` is the sibling form without it.

<!-- PTO-READER-BLOCK: scalar-sw-mechanism role=mechanism -->
## How `SW` forms the address and completes the store

`SrcL` supplies the base. `SrcR` is transformed by `SrcRType` — `0` keeps the complete `64`-bit value, `1` sign-extends the low `32` bits, `2` zero-extends them — and then shifted left by `2`, which multiplies it by `4`. Base and offset are added modulo `2^PTO_XLEN`.

The value written to that address is the low `4` bytes of `SrcD`, least-significant byte at the lowest address. The form has no destination field: nothing in the encoding selects a register or queue slot to write, so a store never publishes a result and never updates a base.

Design point: the scaled offset is always a multiple of `4`, so the alignment of the effective address equals the alignment of `SrcL`. A base that is not `4`-byte aligned makes every address of this form unaligned.

<!-- PTO-READER-BLOCK: scalar-sw-inputs role=inputs-outputs -->
## Encoded fields and what the store consumes

- `SrcD`, `SrcL`, and `SrcR` are `5`-bit Reg5 sources. Codes `0`..`23` name absolute GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. Reading a `T` or `U` slot neither consumes nor reorders it, and code `0` supplies the constant zero GPR.
- `SrcRType` is assigned for `0`, `1`, and `2`; raw `3` is reserved. The form has no `shamt` field, so the scale of the offset is fixed at `4`.
- The form has no destination field: nothing in the encoding selects a register or queue slot to write, so a store never publishes a result and never updates a base.

Design point: the transformation is applied before the scale, so `SrcRType` decides the sign of the index for the whole word range. With `<.uw>` and GPR3 = `0xFFFFFFFE`, the scaled offset is `0x00000003FFFFFFF8`, not `-8`.

<!-- PTO-READER-BLOCK: scalar-sw-effects role=effects -->
## Effects, ordering, and completion

Both sources are read before the memory effect, so the stored bytes are the pre-instruction value of `SrcD`.

Successful execution performs one relaxed `4`-byte store and records one store event. A store whose byte range overlaps the `64`-byte reservation granule that contains a valid reservation invalidates that reservation; a store outside the granule leaves it valid. `TPC` then advances by `4` bytes.

Design point: the sum of base and offset wraps modulo `2^PTO_XLEN`, so a base near the end of the address space can roll over to a low address. The store itself cannot update `SrcL`, so the program must keep the pointer elsewhere.

<!-- PTO-READER-BLOCK: scalar-sw-constraints role=constraints -->
## Legality, faults, and restart

Dispatch rejects the instruction with `Fault_IllegalInstruction` before any effect when the fixed bits do not match, when `SrcRType` holds the reserved value `3`, or when a selected `T`/`U` source is unavailable because nothing has been pushed into it.

The preflight tests the low `2` bits of the effective address. Because the scaled offset is always a multiple of `4`, the test is equivalent to testing the low two bits of `SrcL`; a failure raises `Fault_DataAlignment` before translation, and an aligned address that fails a permission or bounded-memory test raises `Fault_DataPage` at the original address.

A fault writes no memory byte, records no store event, and leaves `TPC` on the faulting instruction. Recovery reissues the whole operation: every source read, the address arithmetic, the preflight, and the store.

Design point: because alignment depends only on the base, a program with one aligned array pointer can use every offset safely. The offsets are word counts, which is why the scale belongs to the mnemonic.

<!-- PTO-READER-BLOCK: scalar-sw-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- Take `sw 6, [2, 3<.sw>]` with GPR2 = `0x1000`, GPR3 = `0xFFFFFFFF`, and GPR6 = `0x00000000DEADBEEF`.
- `SrcRType=1` sign-extends the low `32` bits to `-1`, and the scale of `4` shifts it left by `2`, giving the offset `-4`.
- The effective address is `0x1000` minus `4`, which is `0x0FFC`; it is a multiple of `4`, so the preflight passes and the `4` bytes `EF BE AD DE` are written there.
- No register changes, and `TPC` advances by `4` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sw SrcD, [SrcL, SrcR<{.sw,.uw}><<2]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sw_32_28ad317b1b41 | L32 | 32 | 0x00002049 / 0x00007fff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sw_32_28ad317b1b41 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| sw_32_28ad317b1b41 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sw_32_28ad317b1b41 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sw_32_28ad317b1b41 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sw_32_28ad317b1b41 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| sw_32_28ad317b1b41 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| sw_32_28ad317b1b41 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| sw_32_28ad317b1b41 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `sw_32_28ad317b1b41.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SW.asl -->
```asl
readonly func InstructionContractOperation_SW() => ScalarOperation
begin
    return ScalarOperation_SW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SW.asl -->
```asl
readonly func InstructionContractHandler_SW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SW()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SW()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_SW()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_SW()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_SW()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SW()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SW()
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
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 2) and add it modulo 2^PTO_XLEN to the SrcL base.
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

- sw SrcD, [SrcL, SrcR<{.sw,.uw}><<2]
