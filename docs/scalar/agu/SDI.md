<!-- GENERATED FROM: asl/scalar/agu/SDI.asl -->
# SDI

**Normative ASL source:** `asl/scalar/agu/SDI.asl`

SDI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-SDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sdi-purpose role=purpose -->
## What `SDI` does

`SDI` writes the low `8` bytes of `SrcL` to the address formed from the `SrcR` base plus a signed immediate. Its canonical assembly is `sdi SrcL, [SrcR, simm]`.

Design point: the immediate counts `8`-byte elements, so the encodable byte displacements are `-16384` through `16376`, all multiples of `8`. Only the low three bits of the base can break alignment.

<!-- PTO-READER-BLOCK: scalar-sdi-mechanism role=mechanism -->
## How `SDI` forms the address and completes the store

`simm12` is sign-extended from `12` bits to `PTO_XLEN` and then shifted left by `3`, which multiplies it by `8`. The scaled displacement is added to `SrcR` modulo `2^PTO_XLEN`.

The value written to that address is the low `8` bytes of `SrcL`, least-significant byte at the lowest address. The form has no destination field: nothing in the encoding selects a register or queue slot to write, so a store never publishes a result and never updates a base.

Design point: the scale is applied after the sign extension, so the negative end of the range stays negative: an encoded `-1` produces the displacement `-8`, not `131064`.

<!-- PTO-READER-BLOCK: scalar-sdi-inputs role=inputs-outputs -->
## Encoded fields and what the store consumes

- `SrcL` supplies the store data and `SrcR` supplies the base. Both are `5`-bit Reg5 sources: codes `0`..`23` name absolute GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. Reading a `T` or `U` slot neither consumes nor reorders it, and code `0` supplies the constant zero GPR.
- `simm12` is a signed `12`-bit field, so all `4096` encodings are values, and encoded zero supplies a zero displacement rather than denoting omission. The encodable byte displacements are `-16384` through `16376` bytes.
- The form has no destination field: nothing in the encoding selects a register or queue slot to write, so a store never publishes a result and never updates a base.

Design point: the base field is `SrcR` and the data field is `SrcL`. A program that reuses the load-form convention by mistake stores the wrong register's value at an address computed from the wrong register, and the encoding gives no warning.

<!-- PTO-READER-BLOCK: scalar-sdi-effects role=effects -->
## Effects, ordering, and completion

`SrcL` and `SrcR` are read before the memory effect, so the stored bytes are the pre-instruction value of `SrcL`.

Successful execution performs one relaxed `8`-byte store and records one store event. A store whose byte range overlaps the `64`-byte reservation granule that contains a valid reservation invalidates that reservation; a store outside the granule leaves it valid. `TPC` then advances by `4` bytes.

Design point: the store writes the complete `64`-bit `SrcL` value with no extension or truncation step, so the low byte of the value lands at the lowest address and the high byte at the highest.

<!-- PTO-READER-BLOCK: scalar-sdi-constraints role=constraints -->
## Legality, faults, and restart

Dispatch rejects the instruction with `Fault_IllegalInstruction` before any effect when the fixed bits do not match, or when a selected `T`/`U` source is unavailable because nothing has been pushed into it.

The preflight tests the low `3` bits of the effective address. Because the scaled displacement is always a multiple of `8`, the test is equivalent to testing the low three bits of `SrcR`; a failure raises `Fault_DataAlignment` before translation, and an aligned address that fails a permission or bounded-memory test raises `Fault_DataPage` at the original address.

A fault writes no memory byte, records no store event, and leaves `TPC` on the faulting instruction. Recovery reissues the whole operation: every source read, the address arithmetic, the preflight, and the store.

Design point: with an `8`-byte-aligned base no legal immediate can produce a misaligned address, so this form has no alignment failure to report for such a base. Software that cannot guarantee the base alignment must use `SDI.U` and accept that the alignment becomes its own responsibility.

<!-- PTO-READER-BLOCK: scalar-sdi-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- Take `sdi 6, [3, -1]` with GPR3 = `0x2008` and GPR6 = `0x0123456789ABCDEF`.
- `simm12=-1` sign-extends to `-1`, and the scale of `8` shifts it left by `3`, giving the displacement `-8`.
- The effective address is `0x2008` minus `8`, which is `0x2000`; it is a multiple of `8`, so the preflight passes.
- The `8` bytes `EF CD AB 89 67 45 23 01` are written at `0x2000`, and `TPC` advances by `4` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sdi SrcL, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sdi_32_fab563230a66 | L32 | 32 | 0x00003059 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sdi_32_fab563230a66 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sdi_32_fab563230a66 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sdi_32_fab563230a66 | simm12 | 12 | signed | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sdi_32_fab563230a66 | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| sdi_32_fab563230a66 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| sdi_32_fab563230a66 | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| SrcR | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SDI.asl -->
```asl
readonly func InstructionContractOperation_SDI() => ScalarOperation
begin
    return ScalarOperation_SDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SDI.asl -->
```asl
readonly func InstructionContractHandler_SDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SDI()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SDI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_SDI()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_SDI()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_SDI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SDI()
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
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 8.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 8, and add it modulo 2^PTO_XLEN to the SrcR base.
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

- sdi SrcL, [SrcR, simm]
