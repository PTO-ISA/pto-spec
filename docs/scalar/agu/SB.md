<!-- GENERATED FROM: asl/scalar/agu/SB.asl -->
# SB

**Normative ASL source:** `asl/scalar/agu/SB.asl`

SB snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-SB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sb-purpose role=purpose -->
## What `SB` does

`SB` writes the low `8` bits of `SrcD` to the address formed from the `SrcL` base plus a transformed `SrcR` register offset. Its canonical assembly is `sb SrcD, [SrcL, SrcR<{.sw,.uw}>]`.

Design point: the register-offset store forms have no shift field, so `SB` uses the fixed scale of `1` and adds the offset unchanged. A byte-granular index register therefore needs no preparation, while `SW` and `SD` expect their index to count their own element sizes.

<!-- PTO-READER-BLOCK: scalar-sb-mechanism role=mechanism -->
## How `SB` forms the address and completes the store

`SrcL` supplies the base. `SrcR` is transformed by `SrcRType` — `0` keeps the complete `64`-bit value, `1` sign-extends the low `32` bits, `2` zero-extends them — and the scale of `1` leaves it unshifted. Base and offset are added modulo `2^PTO_XLEN`.

The byte written to that address is the low byte of `SrcD`, read before the store. The form has no destination field, so no register or queue slot is written and no base is updated.

Design point: because the offset is not scaled, the alignment of the effective address depends on the offset register's low bits as well as the base's. An odd `SrcR` gives an odd address, which a `1`-byte access accepts; the same value in `SH` would be doubled first.

<!-- PTO-READER-BLOCK: scalar-sb-inputs role=inputs-outputs -->
## Encoded fields and where the value goes

- `SrcD`, `SrcL`, and `SrcR` are `5`-bit Reg5 sources. Codes `0`..`23` name absolute GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. Reading a `T` or `U` slot neither consumes nor reorders it, and code `0` supplies the constant zero GPR.
- `SrcRType` is assigned for `0`, `1`, and `2`; raw `3` is reserved. The form has no `shamt` field, so the scale of the offset is fixed at `1`.
- The form has no destination field: nothing in the encoding selects a register or queue slot to write, so a store never publishes a result and never updates a base.

Design point: `SrcD` is validated for availability exactly like an address source, so `sb 24, [2, 3]` requires a valid `T#1` entry, and an entry that has never been pushed makes the whole instruction illegal.

<!-- PTO-READER-BLOCK: scalar-sb-effects role=effects -->
## Effects, ordering, and completion

All three sources are read before the memory effect, so the stored byte is the pre-instruction value of `SrcD`.

Successful execution performs one relaxed `1`-byte store and records one store event. A store whose byte range overlaps the `64`-byte reservation granule that contains a valid reservation invalidates that reservation, so a store anywhere inside the granule clears it; a store outside the granule leaves it valid. `TPC` then advances by `4` bytes.

Design point: the data read and the memory effect are the only architectural events of the form, so the byte written is exactly the low byte that `SrcD` held when the attempt began; a later instruction that overwrites `SrcD` cannot change what was stored.

<!-- PTO-READER-BLOCK: scalar-sb-constraints role=constraints -->
## Legality, faults, and restart

Dispatch rejects the instruction with `Fault_IllegalInstruction` before any effect when the fixed bits do not match, when `SrcRType` holds the reserved value `3`, or when a selected `T`/`U` source is unavailable because nothing has been pushed into it.

A `1`-byte access is naturally aligned, so `Fault_DataAlignment` is unreachable for this form. The preflight still performs the alignment test and then the permission and bounded-memory test, whose failure raises `Fault_DataPage` at the original address.

A fault writes no memory byte, records no store event, and leaves `TPC` on the faulting instruction. Recovery reissues the whole operation: every source read, the address arithmetic, the preflight, and the store.

Design point: `SrcRType=3` is refused during the encoding checks rather than mapped to some other transformation, so no encoding of `SB` can silently compute an address the three assigned modifiers would not produce.

<!-- PTO-READER-BLOCK: scalar-sb-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- Take `sb 6, [2, 3<.sw>]` with GPR2 = `0x1001`, GPR3 = `0xFFFFFFFF`, and GPR6 = `0x00000000000000CD`.
- `SrcRType=1` sign-extends the low `32` bits, so the offset is `-1`, and the fixed scale of `1` leaves it unchanged.
- The effective address is `0x1001` minus `1`, which is `0x1000`.
- The byte `0xCD` is written at `0x1000`, `TPC` advances by `4` bytes, and no register changes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sb SrcD, [SrcL, SrcR<{.sw,.uw}>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sb_32_43c106ae3749 | L32 | 32 | 0x00000049 / 0x00007fff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sb_32_43c106ae3749 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| sb_32_43c106ae3749 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sb_32_43c106ae3749 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sb_32_43c106ae3749 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sb_32_43c106ae3749 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| sb_32_43c106ae3749 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| sb_32_43c106ae3749 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| sb_32_43c106ae3749 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `sb_32_43c106ae3749.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SB.asl -->
```asl
readonly func InstructionContractOperation_SB() => ScalarOperation
begin
    return ScalarOperation_SB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SB.asl -->
```asl
readonly func InstructionContractHandler_SB()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SB()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SB()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_SB()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_SB()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_SB()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SB()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SB()
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
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 1-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 1-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- sb SrcD, [SrcL, SrcR<{.sw,.uw}>]
