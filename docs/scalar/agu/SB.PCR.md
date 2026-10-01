<!-- GENERATED FROM: asl/scalar/agu/SB.PCR.asl -->
# SB.PCR

**Normative ASL source:** `asl/scalar/agu/SB.PCR.asl`

SB.PCR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-SB-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sb-pcr-purpose role=purpose -->
## What `SB.PCR` does

`SB.PCR` writes the low `8` bits of `SrcL` to a PC-relative address. It has no base-register field: the address is the current `TPC` plus a signed word displacement. Its canonical assembly is `sb.pcr SrcL, [symbol]`.

Design point: here `SrcL` is the store data and not a base. The form cannot address memory through a register at all, so a byte that must be written to a computed location needs `SB` or `SBI` instead.

<!-- PTO-READER-BLOCK: scalar-sb-pcr-mechanism role=mechanism -->
## How `SB.PCR` forms the address and completes the store

The base is the pre-instruction `TPC` with bits `1`:`0` cleared, and the offset is the sign-extended `simm` field shifted left by `2`. The two values are added modulo `2^PTO_XLEN`.

The value written to that address is the low byte of `SrcL`, which the instruction reads before the store. A `1`-byte access covers exactly one byte, so no byte order question arises.

Design point: the base is `4`-byte aligned and the displacement is a multiple of `4`, so every address this form can produce is `4`-byte aligned. A `1`-byte access never needs that, which makes `SB.PCR` a positional store with no alignment risk.

<!-- PTO-READER-BLOCK: scalar-sb-pcr-inputs role=inputs-outputs -->
## Encoded fields and where the value goes

- `SrcL` is a `5`-bit Reg5 store-data source. Codes `0`..`23` name absolute GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. Reading a `T` or `U` slot neither consumes nor reorders it, and code `0` supplies the constant zero GPR.
- `simm` is a signed `17`-bit word displacement, so all `131072` encodings are values. The byte displacement is a multiple of `4` in the range `-262144` through `262140`.
- The form has no destination field: nothing in the encoding selects a register or queue slot to write, so a store never publishes a result and never updates a base.

Design point: `SrcL` may name code `0`, the architectural zero GPR, which makes the instruction a store of a zero byte. That is a defined operation rather than an omission.

<!-- PTO-READER-BLOCK: scalar-sb-pcr-effects role=effects -->
## Effects, ordering, and completion

`SrcL` is read before the memory effect, so the byte written is the pre-instruction value of that register or queue slot.

Successful execution performs one relaxed `1`-byte store and records one store event. A store whose byte range overlaps the `64`-byte reservation granule that contains a valid reservation invalidates that reservation, so a store anywhere inside the granule clears it; a store outside the granule leaves it valid. `TPC` then advances by `4` bytes.

Design point: the reservation comparison uses the whole granule rather than the reserved byte, so a store to a different address inside the same granule still invalidates the reservation. Software that holds a reservation across stores must keep those stores in other granules.

<!-- PTO-READER-BLOCK: scalar-sb-pcr-constraints role=constraints -->
## Legality, faults, and restart

Dispatch rejects the instruction with `Fault_IllegalInstruction` before any effect when the fixed bits do not match, or when a selected `T`/`U` data source is unavailable because nothing has been pushed into it.

A `1`-byte access is naturally aligned, so `Fault_DataAlignment` is unreachable for this form. The preflight still performs the alignment test and then the permission and bounded-memory test, whose failure raises `Fault_DataPage` at the original address.

A fault writes no memory byte, records no store event, and leaves `TPC` on the faulting instruction. Recovery reissues the whole operation: every source read, the address arithmetic, the preflight, and the store.

Design point: because the preflight precedes the memory effect, a faulting attempt leaves memory exactly as it was, with no partial byte and no partially updated reservation.

<!-- PTO-READER-BLOCK: scalar-sb-pcr-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- Take `sb.pcr 5, [symbol]` executing at `TPC` = `0x2006`, with `simm` equal to `-2` and GPR5 = `0x00000000000000AB`.
- Clearing the low `2` bits of `0x2006` gives the base `0x2004`; the displacement is `-2` times `4`, which is `-8`.
- The effective address is `0x2004` minus `8`, which is `0x1FFC`, and the byte `0xAB` is written there.
- GPR5 keeps its low byte, no destination field exists to publish a result, and `TPC` becomes `0x200A`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sb.pcr SrcL, [symbol]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sb_pcr_32_7625a9a24c59 | L32 | 32 | 0x00000069 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sb_pcr_32_7625a9a24c59 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sb_pcr_32_7625a9a24c59 | simm | 17 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sb_pcr_32_7625a9a24c59 | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| sb_pcr_32_7625a9a24c59 | simm | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SB.PCR.asl -->
```asl
readonly func InstructionContractOperation_SB_PCR() => ScalarOperation
begin
    return ScalarOperation_SB_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SB.PCR.asl -->
```asl
readonly func InstructionContractHandler_SB_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SB_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SB_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_SB_PCR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_SB_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_SB_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SB_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SB_PCR()
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
- simm assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
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

- sb.pcr SrcL, [symbol]
