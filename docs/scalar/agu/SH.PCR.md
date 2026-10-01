<!-- GENERATED FROM: asl/scalar/agu/SH.PCR.asl -->
# SH.PCR

**Normative ASL source:** `asl/scalar/agu/SH.PCR.asl`

SH.PCR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-SH-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sh-pcr-purpose role=purpose -->
## What `SH.PCR` does

`SH.PCR` writes the low `2` bytes of `SrcL` to a PC-relative address. It has no base-register field: the address is the current `TPC` plus a signed `17`-bit word displacement. Its canonical assembly is `sh.pcr SrcL, [symbol]`.

Design point: the base is `4`-byte aligned and the displacement is a multiple of `4`, so every address this form can produce is even. A `2`-byte access only needs an even address, and `Fault_DataAlignment` is therefore unreachable here.

<!-- PTO-READER-BLOCK: scalar-sh-pcr-mechanism role=mechanism -->
## How `SH.PCR` forms the address and completes the store

The base is the pre-instruction `TPC` with bits `1`:`0` cleared, and the offset is the sign-extended `simm` field shifted left by `2`. The two values are added modulo `2^PTO_XLEN`.

The value written to that address is the low `2` bytes of `SrcL`, least-significant byte at the lowest address, read before the store. The form has no destination field: nothing in the encoding selects a register or queue slot to write, so a store never publishes a result and never updates a base.

Design point: the stored value is the low `16` bits of `SrcL`, written with the least-significant byte at the lower address. Software that wants the upper half of a `32`-bit value in memory must shift it down before the store.

<!-- PTO-READER-BLOCK: scalar-sh-pcr-inputs role=inputs-outputs -->
## Encoded fields and what the store consumes

- `SrcL` is a `5`-bit Reg5 store-data source. Codes `0`..`23` name absolute GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. Reading a `T` or `U` slot neither consumes nor reorders it, and code `0` supplies the constant zero GPR.
- `simm` is a signed `17`-bit word displacement, so all `131072` encodings are values. The byte displacement is a multiple of `4` in the range `-262144` through `262140`.
- The form has no destination field: nothing in the encoding selects a register or queue slot to write, so a store never publishes a result and never updates a base.

Design point: the displacement is scaled by `4` even though the access is `2` bytes, because every PC-relative form of this family shares one scale. The scale is not the access size, and the reachable byte range is `-262144` through `262140`.

<!-- PTO-READER-BLOCK: scalar-sh-pcr-effects role=effects -->
## Effects, ordering, and completion

`SrcL` is read before the memory effect, and the `TPC` advance is the last step, so the address never depends on the instruction's own retirement.

Successful execution performs one relaxed `2`-byte store and records one store event. A store whose byte range overlaps the `64`-byte reservation granule that contains a valid reservation invalidates that reservation; a store outside the granule leaves it valid. `TPC` then advances by `4` bytes.

Design point: `TPC` advances only after the store event, and only when no fault was recorded, so a faulting attempt leaves both memory and `TPC` untouched. The store and the retirement are one all-or-nothing step.

<!-- PTO-READER-BLOCK: scalar-sh-pcr-constraints role=constraints -->
## Legality, faults, and restart

Dispatch rejects the instruction with `Fault_IllegalInstruction` before any effect when the fixed bits do not match, or when a selected `T`/`U` data source is unavailable because nothing has been pushed into it.

A `2`-byte access needs an even address, and every address this form produces is a multiple of `4`, so `Fault_DataAlignment` is unreachable. The preflight still runs the alignment test and then the permission and bounded-memory test, whose failure raises `Fault_DataPage` at the original address.

A fault writes no memory byte, records no store event, and leaves `TPC` on the faulting instruction. Recovery reissues the whole operation: every source read, the address arithmetic, the preflight, and the store.

Design point: because the alignment outcome is fixed by the encoding, the only data fault available to this form is `Fault_DataPage`. A program cannot provoke an alignment fault from `SH.PCR` with any pair of encoded operands.

<!-- PTO-READER-BLOCK: scalar-sh-pcr-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- Take `sh.pcr 5, [symbol]` executing at `TPC` = `0x1010`, with `simm` equal to `-1` and GPR5 = `0x0000000000001234`.
- The base is `0x1010` and the displacement is `-1` times `4`, which is `-4`, so the effective address is `0x100C`.
- `0x100C` is even, so the preflight passes and the `2` bytes `34 12` are written there, low byte first.
- GPR5 is unchanged, and `TPC` becomes `0x1014`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sh.pcr SrcL, [symbol]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sh_pcr_32_14ba505eb3c2 | L32 | 32 | 0x00001069 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sh_pcr_32_14ba505eb3c2 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sh_pcr_32_14ba505eb3c2 | simm | 17 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sh_pcr_32_14ba505eb3c2 | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| sh_pcr_32_14ba505eb3c2 | simm | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SH.PCR.asl -->
```asl
readonly func InstructionContractOperation_SH_PCR() => ScalarOperation
begin
    return ScalarOperation_SH_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SH.PCR.asl -->
```asl
readonly func InstructionContractHandler_SH_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SH_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SH_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_SH_PCR()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_SH_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_SH_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SH_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SH_PCR()
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
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
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

- sh.pcr SrcL, [symbol]
