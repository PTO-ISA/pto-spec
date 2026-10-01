<!-- GENERATED FROM: asl/scalar/agu/SBI.asl -->
# SBI

**Normative ASL source:** `asl/scalar/agu/SBI.asl`

SBI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-SBI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sbi-purpose role=purpose -->
## What `SBI` does

`SBI` writes the low `8` bits of `SrcL` to the address formed from the `SrcR` base plus a signed immediate that is added without scaling. Its canonical assembly is `sbi SrcL, [SrcR, simm]`.

Design point: in this immediate store form the two register fields swap roles compared with the load forms — `SrcR` is the base and `SrcL` carries the stored data. The assembly spelling is the reliable guide to which field does what.

<!-- PTO-READER-BLOCK: scalar-sbi-mechanism role=mechanism -->
## How `SBI` forms the address and completes the store

The `simm12` field is sign-extended from `12` bits to `PTO_XLEN`, giving a displacement in `-2048`..`2047` bytes, and added to `SrcR` modulo `2^PTO_XLEN`. No scale is applied to the intermediate value.

The low byte of `SrcL` is written at the resulting address. The form has no destination field, so neither register changes and no queue slot is written.

Design point: an unscaled displacement can name any byte, so the alignment outcome depends on `SrcR` and `simm12` together. For a `1`-byte access that never matters, which is why the unscaled immediate store of a byte carries no alignment constraint in practice.

<!-- PTO-READER-BLOCK: scalar-sbi-inputs role=inputs-outputs -->
## Encoded fields and where the value goes

- `SrcL` supplies the store data and `SrcR` supplies the base. Both are `5`-bit Reg5 sources: codes `0`..`23` name absolute GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. Reading a `T` or `U` slot neither consumes nor reorders it, and code `0` supplies the constant zero GPR.
- `simm12` is a signed `12`-bit field, so all `4096` encodings are values, and encoded zero supplies a zero displacement rather than denoting omission.
- The form has no destination field: nothing in the encoding selects a register or queue slot to write, so a store never publishes a result and never updates a base.

Design point: code `0` in `SrcL` stores the constant zero byte and code `0` in `SrcR` bases the store on the architectural zero GPR, so a store to a fixed low address needs no address register at all.

<!-- PTO-READER-BLOCK: scalar-sbi-effects role=effects -->
## Effects, ordering, and completion

`SrcL` and `SrcR` are read before the memory effect, so the stored byte is the pre-instruction value of `SrcL`.

Successful execution performs one relaxed `1`-byte store and records one store event. A store whose byte range overlaps the `64`-byte reservation granule that contains a valid reservation invalidates that reservation, so a store anywhere inside the granule clears it; a store outside the granule leaves it valid. `TPC` then advances by `4` bytes.

Design point: the memory effect is the only state change the instruction can make, because there is no writeback destination and no queue publication. Reissuing after a fault therefore repeats exactly one byte store.

<!-- PTO-READER-BLOCK: scalar-sbi-constraints role=constraints -->
## Legality, faults, and restart

Dispatch rejects the instruction with `Fault_IllegalInstruction` before any effect when the fixed bits do not match, or when a selected `T`/`U` source is unavailable because nothing has been pushed into it.

A `1`-byte access is naturally aligned, so `Fault_DataAlignment` is unreachable for this form. The preflight still performs the alignment test and then the permission and bounded-memory test, whose failure raises `Fault_DataPage` at the original address.

A fault writes no memory byte, records no store event, and leaves `TPC` on the faulting instruction. Recovery reissues the whole operation: every source read, the address arithmetic, the preflight, and the store.

Design point: the fault is reported at the original address that `SrcR` and `simm12` produced, so a handler can recompute the same address from the same two operands without knowing anything about translation.

<!-- PTO-READER-BLOCK: scalar-sbi-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- Take `sbi 5, [3, -1]` with GPR3 = `0x1000` and GPR5 = `0x000000000000007F`.
- `simm12=-1` sign-extends to `-1` and is used as encoded, so the effective address is `0x0FFF`.
- The byte `0x7F` is stored at `0x0FFF`.
- Neither GPR3 nor GPR5 changes, no destination field exists, and `TPC` advances by `4` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sbi SrcL, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sbi_32_f3c6b796f0d9 | L32 | 32 | 0x00000059 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sbi_32_f3c6b796f0d9 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sbi_32_f3c6b796f0d9 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sbi_32_f3c6b796f0d9 | simm12 | 12 | signed | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sbi_32_f3c6b796f0d9 | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| sbi_32_f3c6b796f0d9 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| sbi_32_f3c6b796f0d9 | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| SrcR | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SBI.asl -->
```asl
readonly func InstructionContractOperation_SBI() => ScalarOperation
begin
    return ScalarOperation_SBI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SBI.asl -->
```asl
readonly func InstructionContractHandler_SBI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SBI()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SBI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_SBI()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_SBI()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_SBI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SBI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SBI()
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
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcR base.
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

- sbi SrcL, [SrcR, simm]
