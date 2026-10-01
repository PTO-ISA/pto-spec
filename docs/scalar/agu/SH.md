<!-- GENERATED FROM: asl/scalar/agu/SH.asl -->
# SH

**Normative ASL source:** `asl/scalar/agu/SH.asl`

SH snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-SH}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sh-purpose role=purpose -->
## What `SH` does

`SH` writes the low `2` bytes of `SrcD` to the address formed from the `SrcL` base plus the transformed `SrcR` register offset. Its canonical assembly is `sh SrcD, [SrcL, SrcR<{.sw,.uw}><<1]`.

Design point: the scale of `2` makes the offset an element index for `2`-byte data. The assembly spells it as `<<1` because the scale is fixed by the opcode, and `sh.u` is the form that omits it.

<!-- PTO-READER-BLOCK: scalar-sh-mechanism role=mechanism -->
## How `SH` forms the address and completes the store

`SrcL` supplies the base. `SrcR` is transformed by `SrcRType` — `0` keeps the complete `64`-bit value, `1` sign-extends the low `32` bits, `2` zero-extends them — and then shifted left by `1`, which multiplies it by `2`. Base and offset are added modulo `2^PTO_XLEN`.

The value written to that address is the low `2` bytes of `SrcD`, least-significant byte at the lowest address. The form has no destination field: nothing in the encoding selects a register or queue slot to write, so a store never publishes a result and never updates a base.

Design point: the scaled offset is always even, so the parity of the effective address equals the parity of `SrcL`. An odd base register makes every address of this form odd, and a `2`-byte access refuses all of them.

<!-- PTO-READER-BLOCK: scalar-sh-inputs role=inputs-outputs -->
## Encoded fields and what the store consumes

- `SrcD`, `SrcL`, and `SrcR` are `5`-bit Reg5 sources. Codes `0`..`23` name absolute GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. Reading a `T` or `U` slot neither consumes nor reorders it, and code `0` supplies the constant zero GPR.
- `SrcRType` is assigned for `0`, `1`, and `2`; raw `3` is reserved. The form has no `shamt` field, so the scale of the offset is fixed at `2`.
- The form has no destination field: nothing in the encoding selects a register or queue slot to write, so a store never publishes a result and never updates a base.

Design point: the form has no shift field, so the multiplier `2` cannot be changed by the program. A stride that is not a multiple of `2` must be produced with `sh.u`, and a stride that is not a power of two at all needs an explicit add.

<!-- PTO-READER-BLOCK: scalar-sh-effects role=effects -->
## Effects, ordering, and completion

Both sources are read before the memory effect, so the stored bytes are the pre-instruction value of `SrcD`.

Successful execution performs one relaxed `2`-byte store and records one store event. A store whose byte range overlaps the `64`-byte reservation granule that contains a valid reservation invalidates that reservation; a store outside the granule leaves it valid. `TPC` then advances by `4` bytes.

Design point: the stored bytes are the low `16` bits of the pre-instruction value of `SrcD`, so a later instruction that overwrites `SrcD` cannot change what reached memory.

<!-- PTO-READER-BLOCK: scalar-sh-constraints role=constraints -->
## Legality, faults, and restart

Dispatch rejects the instruction with `Fault_IllegalInstruction` before any effect when the fixed bits do not match, when `SrcRType` holds the reserved value `3`, or when a selected `T`/`U` source is unavailable because nothing has been pushed into it.

The preflight tests the low bit of the effective address. Because the scaled offset is always even, this test is equivalent to testing the low bit of `SrcL`; a failure raises `Fault_DataAlignment` before translation, and an even address that fails a permission or bounded-memory test raises `Fault_DataPage` at the original address.

A fault writes no memory byte, records no store event, and leaves `TPC` on the faulting instruction. Recovery reissues the whole operation: every source read, the address arithmetic, the preflight, and the store.

Design point: this form cannot repair an odd base. Software that keeps a `2`-byte-aligned pointer can use every offset; software whose base comes from an arbitrary computation must align it or use `sh.u`.

<!-- PTO-READER-BLOCK: scalar-sh-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- Take `sh 6, [2, 3<.sw>]` with GPR2 = `0x1000`, GPR3 = `0xFFFFFFFF`, and GPR6 = `0x000000000000ABCD`.
- `SrcRType=1` sign-extends the low `32` bits to `-1`, and the scale of `2` shifts it left by `1`, giving the offset `-2`.
- The effective address is `0x1000` minus `2`, which is `0x0FFE`; it is even, so the preflight passes.
- The `2` bytes `CD AB` are written at `0x0FFE`, and `TPC` advances by `4` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sh SrcD, [SrcL, SrcR<{.sw,.uw}><<1]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sh_32_bc7d4a7dea28 | L32 | 32 | 0x00001049 / 0x00007fff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sh_32_bc7d4a7dea28 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| sh_32_bc7d4a7dea28 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sh_32_bc7d4a7dea28 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sh_32_bc7d4a7dea28 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sh_32_bc7d4a7dea28 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| sh_32_bc7d4a7dea28 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| sh_32_bc7d4a7dea28 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| sh_32_bc7d4a7dea28 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `sh_32_bc7d4a7dea28.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SH.asl -->
```asl
readonly func InstructionContractOperation_SH() => ScalarOperation
begin
    return ScalarOperation_SH;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SH.asl -->
```asl
readonly func InstructionContractHandler_SH()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SH()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SH()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_SH()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_SH()
    => integer {0..3}
begin
    return 1;
end;

pure func InstructionContractAGUUpdateMode_SH()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SH()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SH()
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
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 1) and add it modulo 2^PTO_XLEN to the SrcL base.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 2-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- sh SrcD, [SrcL, SrcR<{.sw,.uw}><<1]
