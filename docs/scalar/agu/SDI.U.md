<!-- GENERATED FROM: asl/scalar/agu/SDI.U.asl -->
# SDI.U

**Normative ASL source:** `asl/scalar/agu/SDI.U.asl`

SDI.U snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-SDI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sdi-u-purpose role=purpose -->
## What `SDI.U` does

`SDI.U` writes the low `8` bytes of `SrcL` to the address formed from the `SrcR` base plus a signed immediate. Its canonical assembly is `sdi.u SrcL, [SrcR, simm]`.

Design point: the base is `SrcR` and the stored data is `SrcL`, the reverse of the load forms' field usage, and the `.u` marker then removes the `8`-byte scale that `SDI` applies to the same immediate field.

<!-- PTO-READER-BLOCK: scalar-sdi-u-mechanism role=mechanism -->
## How `SDI.U` forms the address and completes the store

`simm12` is sign-extended from `12` bits to `PTO_XLEN`, giving a displacement in `-2048`..`2047` bytes, and added to `SrcR` modulo `2^PTO_XLEN`. No scale is applied to the intermediate value.

The value written to that address is the low `8` bytes of `SrcL`, least-significant byte at the lowest address. The form has no destination field: nothing in the encoding selects a register or queue slot to write, so a store never publishes a result and never updates a base.

Design point: an unscaled `8`-byte store succeeds only when the base plus displacement is a multiple of `8`, so an `8`-byte-aligned base accepts just one displacement in every `8`. The program must keep the byte count aligned itself.

<!-- PTO-READER-BLOCK: scalar-sdi-u-inputs role=inputs-outputs -->
## Encoded fields and what the store consumes

- `SrcL` supplies the store data and `SrcR` supplies the base. Both are `5`-bit Reg5 sources: codes `0`..`23` name absolute GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. Reading a `T` or `U` slot neither consumes nor reorders it, and code `0` supplies the constant zero GPR.
- `simm12` is a signed `12`-bit field, so all `4096` encodings are values, and encoded zero supplies a zero displacement rather than denoting omission. The encodable byte displacements are `-2048` through `2047` bytes.
- The form has no destination field: nothing in the encoding selects a register or queue slot to write, so a store never publishes a result and never updates a base.

Design point: the `12`-bit field is sign-extended before the addition, so the encodable byte displacements run from `-2048` to `2047` rather than from `0` to `4095`.

<!-- PTO-READER-BLOCK: scalar-sdi-u-effects role=effects -->
## Effects, ordering, and completion

`SrcL` and `SrcR` are read before the memory effect, so the stored bytes are the pre-instruction value of `SrcL`.

Successful execution performs one relaxed `8`-byte store and records one store event. A store whose byte range overlaps the `64`-byte reservation granule that contains a valid reservation invalidates that reservation; a store outside the granule leaves it valid. `TPC` then advances by `4` bytes.

Design point: the instruction changes memory and possibly the reservation state, and nothing else. Neither `SrcL` nor `SrcR` is written, so it cannot disturb a pointer the program keeps in the base.

<!-- PTO-READER-BLOCK: scalar-sdi-u-constraints role=constraints -->
## Legality, faults, and restart

Dispatch rejects the instruction with `Fault_IllegalInstruction` before any effect when the fixed bits do not match, or when a selected `T`/`U` source is unavailable because nothing has been pushed into it.

The preflight tests the low `3` bits of the effective address, because the access is `8` bytes wide. An unaligned value raises `Fault_DataAlignment` before translation; an aligned address that fails a permission or bounded-memory test raises `Fault_DataPage` at the original address.

A fault writes no memory byte, records no store event, and leaves `TPC` on the faulting instruction. Recovery reissues the whole operation: every source read, the address arithmetic, the preflight, and the store.

Design point: because the displacement is unscaled, `Fault_DataAlignment` is reachable from any base whose low three bits are not zero. The scaled `SDI` removes that risk by construction, so the choice between the two forms is a choice about who guarantees the alignment.

<!-- PTO-READER-BLOCK: scalar-sdi-u-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- Take `sdi.u 6, [3, 4]` with GPR3 = `0x2000` and GPR6 = `0x0123456789ABCDEF`.
- The displacement is `4` bytes, so the effective address is `0x2004`.
- `0x2004` is a multiple of `4` but not of `8`, so the preflight raises `Fault_DataAlignment` and no byte is written, even though the base itself is `8`-byte aligned.
- With `sdi` instead, the same field would be multiplied by `8` and the address would be `0x2020`, where the `8` bytes would be stored.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sdi.u SrcL, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sdi_u_32_cba5a4a04e7b | L32 | 32 | 0x00007059 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sdi_u_32_cba5a4a04e7b | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sdi_u_32_cba5a4a04e7b | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sdi_u_32_cba5a4a04e7b | simm12 | 12 | signed | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sdi_u_32_cba5a4a04e7b | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| sdi_u_32_cba5a4a04e7b | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| sdi_u_32_cba5a4a04e7b | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| SrcR | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SDI.U.asl -->
```asl
readonly func InstructionContractOperation_SDI_U() => ScalarOperation
begin
    return ScalarOperation_SDI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SDI.U.asl -->
```asl
readonly func InstructionContractHandler_SDI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SDI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SDI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_SDI_U()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_SDI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_SDI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SDI_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SDI_U()
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
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcR base.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

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

- sdi.u SrcL, [SrcR, simm]
