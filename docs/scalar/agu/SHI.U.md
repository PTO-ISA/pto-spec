<!-- GENERATED FROM: asl/scalar/agu/SHI.U.asl -->
# SHI.U

**Normative ASL source:** `asl/scalar/agu/SHI.U.asl`

SHI.U snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-SHI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-shi-u-purpose role=purpose -->
## What `SHI.U` does

`SHI.U` writes the low `2` bytes of `SrcL` to the address formed from the `SrcR` base plus a signed immediate. Its canonical assembly is `shi.u SrcL, [SrcR, simm]`.

Design point: `SrcR` is the base and `SrcL` supplies the stored halfword, and the `.u` marker keeps the immediate unscaled. The `12`-bit field therefore counts bytes and can name an odd address directly.

<!-- PTO-READER-BLOCK: scalar-shi-u-mechanism role=mechanism -->
## How `SHI.U` forms the address and completes the store

`simm12` is sign-extended from `12` bits to `PTO_XLEN`, giving a displacement in `-2048`..`2047` bytes, and added to `SrcR` modulo `2^PTO_XLEN`. No scale is applied to the intermediate value.

The value written to that address is the low `2` bytes of `SrcL`, least-significant byte at the lowest address. The form has no destination field: nothing in the encoding selects a register or queue slot to write, so a store never publishes a result and never updates a base.

Design point: the displacement range is `-2048` through `2047` bytes, which is smaller than the scaled `SHI` range of `-4096` through `4094`. The two forms trade reach against byte granularity for the same encoded field.

<!-- PTO-READER-BLOCK: scalar-shi-u-inputs role=inputs-outputs -->
## Encoded fields and what the store consumes

- `SrcL` supplies the store data and `SrcR` supplies the base. Both are `5`-bit Reg5 sources: codes `0`..`23` name absolute GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. Reading a `T` or `U` slot neither consumes nor reorders it, and code `0` supplies the constant zero GPR.
- `simm12` is a signed `12`-bit field, so all `4096` encodings are values, and encoded zero supplies a zero displacement rather than denoting omission. The encodable byte displacements are `-2048` through `2047` bytes.
- The form has no destination field: nothing in the encoding selects a register or queue slot to write, so a store never publishes a result and never updates a base.

Design point: only the low `16` bits of `SrcL` reach memory. The store is defined for every `SrcL` code, including code `0`, which stores a zero halfword.

<!-- PTO-READER-BLOCK: scalar-shi-u-effects role=effects -->
## Effects, ordering, and completion

`SrcL` and `SrcR` are read before the memory effect, so the stored bytes are the pre-instruction value of `SrcL`.

Successful execution performs one relaxed `2`-byte store and records one store event. A store whose byte range overlaps the `64`-byte reservation granule that contains a valid reservation invalidates that reservation; a store outside the granule leaves it valid. `TPC` then advances by `4` bytes.

Design point: the base register is read for the address and never written back, so a store loop must advance its pointer with a separate instruction. Nothing in the encoding can express an update.

<!-- PTO-READER-BLOCK: scalar-shi-u-constraints role=constraints -->
## Legality, faults, and restart

Dispatch rejects the instruction with `Fault_IllegalInstruction` before any effect when the fixed bits do not match, or when a selected `T`/`U` source is unavailable because nothing has been pushed into it.

The preflight tests the low bit of the effective address, because the access is `2` bytes wide. An unaligned value raises `Fault_DataAlignment` before translation; an even address that fails a permission or bounded-memory test raises `Fault_DataPage` at the original address.

A fault writes no memory byte, records no store event, and leaves `TPC` on the faulting instruction. Recovery reissues the whole operation: every source read, the address arithmetic, the preflight, and the store.

Design point: parity is the whole alignment rule for a `2`-byte store, so an odd base is acceptable here as long as the byte displacement is odd too. That freedom disappears in `SHI`, whose even displacements make an odd base permanently misaligned.

<!-- PTO-READER-BLOCK: scalar-shi-u-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- Take `shi.u 5, [3, 1]` with GPR3 = `0x2000` and GPR5 = `0x0000000000001234`.
- The displacement is `1` byte, so the effective address is `0x2001`.
- `0x2001` is odd, so the preflight raises `Fault_DataAlignment`: no byte is written, no event is recorded, and `TPC` stays on the instruction.
- With `simm12=2` the address would be `0x2002`; the `2` bytes `34 12` are written there and `TPC` advances by `4` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
shi.u SrcL, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| shi_u_32_caaf3ed72a8f | L32 | 32 | 0x00005059 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| shi_u_32_caaf3ed72a8f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| shi_u_32_caaf3ed72a8f | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| shi_u_32_caaf3ed72a8f | simm12 | 12 | signed | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| shi_u_32_caaf3ed72a8f | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| shi_u_32_caaf3ed72a8f | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| shi_u_32_caaf3ed72a8f | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| SrcR | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SHI.U.asl -->
```asl
readonly func InstructionContractOperation_SHI_U() => ScalarOperation
begin
    return ScalarOperation_SHI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SHI.U.asl -->
```asl
readonly func InstructionContractHandler_SHI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SHI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SHI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_SHI_U()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_SHI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_SHI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SHI_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SHI_U()
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
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcR base.
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

- shi.u SrcL, [SrcR, simm]
